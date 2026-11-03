import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/helpers/reference_data_helper.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/alerts/data/models/notifiable_disease_model.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/presentation/widgets/case_history_row.dart';
import 'package:tabibu/features/preread/data/datasources/preread_storage.dart';
import 'package:tabibu/features/preread/data/models/preread_model.dart';
import 'package:tabibu/features/preread/presentation/widgets/slide_viewer.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';
import 'package:tabibu/features/reports/blocs/case_workspace_bloc/case_workspace_bloc.dart';
import 'package:tabibu/features/reports/blocs/case_workspace_bloc/case_workspace_event.dart';
import 'package:tabibu/features/reports/blocs/case_workspace_bloc/case_workspace_state.dart';
import 'package:tabibu/features/reports/data/models/notifiable_finding_model.dart';
import 'package:tabibu/features/reports/data/models/report_draft_model.dart';
import 'package:tabibu/features/reports/presentation/widgets/case_request_view.dart';
import 'package:tabibu/features/reports/presentation/widgets/sample_received_view.dart';
import 'package:tabibu/features/reports/presentation/widgets/signed_case_view.dart';
import 'package:tabibu/features/reports/presentation/widgets/workspace_facts.dart';
import 'package:tabibu/features/reports/presentation/widgets/workspace_score_card.dart';
import 'package:tabibu/features/reports/presentation/widgets/workspace_sign_sheet.dart';
import 'package:tabibu/features/worklist/presentation/widgets/ai_mark.dart';
import 'package:tabibu/l10n/l10n.dart';

/// CS-01 + CS-07. The pathologist turns a pre-read into a signed report.
class CaseWorkspaceScreen extends StatefulWidget {
  const CaseWorkspaceScreen({
    required this.caseUid,
    @visibleForTesting this.reference,
    @visibleForTesting this.storage,
    super.key,
  });

  final String caseUid;
  final ReferenceDataHelper? reference;
  final PrereadStorage? storage;

  static const int fieldMax = 2000;

  @override
  State<CaseWorkspaceScreen> createState() => _CaseWorkspaceScreenState();
}

class _CaseWorkspaceScreenState extends State<CaseWorkspaceScreen> {
  late final String _uid;
  late final DoctorModel _me;
  late final ReferenceDataHelper _reference;
  late final PrereadStorage _storage;

  final _diagnosis = TextEditingController();
  final _comments = TextEditingController();
  final _scoreComment = TextEditingController();

  String? _findingsVerdict;
  String? _impressionVerdict;
  String? _urgencyVerdict;
  String? _measurementsVerdict;
  String? _tilesVerdict;
  int? _overall;

  bool _heatmapOn = true;
  bool _writeOwn = false;
  String? _slideUrl;
  String? _heatmapUrl;
  String _loadedRun = '';
  List<NotifiableDiseaseModel> _confirmable = const [];
  var _registerLoaded = false;

  @override
  void initState() {
    super.initState();
    final session = context.read<AuthBloc>().state.session;
    _me = switch (session) {
      PractitionerSession(:final doctor) => doctor,
      _ => DoctorModel.empty(),
    };
    _uid = _me.uid;
    _reference = widget.reference ?? getIt<ReferenceDataHelper>();
    _storage = widget.storage ?? getIt<PrereadStorage>();

    final bloc = context.read<CaseWorkspaceBloc>();
    if (bloc.state.caseUid != widget.caseUid) {
      bloc.add(
        CaseWorkspaceOpened(caseUid: widget.caseUid, pathologistUid: _uid),
      );
    }
    _syncFields(bloc.state.draft);
    // Rebuild so AI-frame vs "Your edit" switches on the first keystroke (H-2).
    _diagnosis.addListener(_onFieldEdited);
    _comments.addListener(_onFieldEdited);
    unawaited(_loadRegister(bloc.state));
    unawaited(_loadImages(bloc.state.preread));
  }

  void _onFieldEdited() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _diagnosis
      ..removeListener(_onFieldEdited)
      ..dispose();
    _comments
      ..removeListener(_onFieldEdited)
      ..dispose();
    _scoreComment.dispose();
    super.dispose();
  }

  void _syncFields(ReportDraftModel? draft) {
    if (draft == null) return;
    if (_diagnosis.text != draft.diagnosis) {
      _diagnosis.text = draft.diagnosis;
    }
    if (_comments.text != draft.comments) {
      _comments.text = draft.comments;
    }
  }

  Future<void> _loadRegister(CaseWorkspaceState state) async {
    if (_registerLoaded) return;
    final caseModel = state.caseModel;
    if (caseModel == null) return;
    final diseases = await _reference.notifiableDiseases();
    if (!mounted) return;
    final ids = [for (final t in caseModel.tests) t.labTestId];
    setState(() {
      _confirmable = confirmableDiseases(diseases, ids);
      _registerLoaded = true;
    });
  }

  Future<void> _loadImages(PrereadModel? preread) async {
    final run = preread?.uid ?? '';
    if (run.isEmpty || run == _loadedRun) return;
    _loadedRun = run;
    final imagePath = preread!.imagePaths.isEmpty
        ? ''
        : preread.imagePaths.first;
    final slide = imagePath.isEmpty
        ? null
        : await _storage.downloadUrl(imagePath);
    final heat = preread.segmentationPath.isEmpty
        ? null
        : await _storage.downloadUrl(preread.segmentationPath);
    if (!mounted) return;
    setState(() {
      _slideUrl = slide;
      _heatmapUrl = heat;
    });
  }

  void _add(CaseWorkspaceEvent event) =>
      context.read<CaseWorkspaceBloc>().add(event);

  void _saveDraft(ReportDraftModel draft) {
    final fields = <String, dynamic>{};
    final diagnosis = _diagnosis.text.trim();
    final comments = _comments.text.trim();
    if (diagnosis != draft.diagnosis) fields['diagnosis'] = diagnosis;
    if (comments != draft.comments) fields['comments'] = comments;
    if (fields.isEmpty) return;
    _add(CaseDraftEdited(fields: fields));
  }

  void _setCritical(ReportDraftModel draft, bool value) {
    if (draft.isCritical == value) return;
    _add(CaseDraftEdited(fields: {'isCritical': value}));
  }

  void _setDiagnosisType(ReportDraftModel draft, DiagnosisType type) {
    if (draft.diagnosisType == type.value) return;
    _add(CaseDraftEdited(fields: {'diagnosisType': type.value}));
  }

  void _toggleNotifiable(
    ReportDraftModel draft,
    String diseaseId, {
    required bool on,
  }) {
    final next = [
      for (final f in draft.notifiableFindings)
        if (f.diseaseId != diseaseId) f,
      if (on) NotifiableFindingModel(diseaseId: diseaseId),
    ];
    _add(
      CaseDraftEdited(
        fields: {
          'notifiableFindings': [for (final f in next) f.toJson()],
        },
      ),
    );
  }

  void _saveScore() {
    final overall = _overall;
    if (overall == null ||
        _findingsVerdict == null ||
        _impressionVerdict == null ||
        _urgencyVerdict == null ||
        _measurementsVerdict == null ||
        _tilesVerdict == null) {
      return;
    }
    _add(
      CasePrereadScored(
        overall: overall,
        findingsVerdict: _findingsVerdict!,
        impressionVerdict: _impressionVerdict!,
        urgencyVerdict: _urgencyVerdict!,
        measurementsVerdict: _measurementsVerdict!,
        segmentationVerdict: _tilesVerdict!,
        comment: _scoreComment.text,
      ),
    );
  }

  Future<void> _openSign(CaseWorkspaceState state) async {
    final language = Localizations.localeOf(context).languageCode;
    final findings =
        state.draft?.notifiableFindings ?? const <NotifiableFindingModel>[];
    final ticked = <String>[
      for (final f in findings)
        for (final d in _confirmable)
          if (d.diseaseId == f.diseaseId) workspaceDiseaseName(d, language),
    ];
    final signed = await showWorkspaceSignSheet(
      context,
      signedBy: _me.fullName,
      goesTo: state.caseModel?.doctorName ?? '',
      notifiableDisease: ticked.join(', '),
      scoreCard: state.needsScore
          ? WorkspaceScoreCard(
              findings: _findingsVerdict,
              impression: _impressionVerdict,
              urgency: _urgencyVerdict,
              measurements: _measurementsVerdict,
              tiles: _tilesVerdict,
              overall: _overall,
              comment: _scoreComment,
              onFindings: (v) => setState(() => _findingsVerdict = v),
              onImpression: (v) => setState(() => _impressionVerdict = v),
              onUrgency: (v) => setState(() => _urgencyVerdict = v),
              onMeasurements: (v) => setState(() => _measurementsVerdict = v),
              onTiles: (v) => setState(() => _tilesVerdict = v),
              onOverall: (v) => setState(() => _overall = v),
              onSave: _saveScore,
            )
          : null,
    );
    if (signed && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<CaseWorkspaceBloc, CaseWorkspaceState>(
      listenWhen: (previous, current) =>
          previous.draft != current.draft ||
          previous.preread != current.preread ||
          previous.caseModel != current.caseModel ||
          current is CaseDraftSaveSuccess ||
          current is CaseScoreSuccess ||
          current is CaseRequestDeclineSuccess ||
          current is CaseWorkspaceWriteFailure ||
          current is CaseWorkspaceLoadFailure,
      listener: (context, state) {
        _syncFields(state.draft);
        unawaited(_loadRegister(state));
        unawaited(_loadImages(state.preread));
        if (state is CaseDraftSaveSuccess) {
          unawaited(
            showTabibuNotification(
              context,
              message: state.offline
                  ? l10n.workspaceDraftSavedOffline
                  : l10n.workspaceDraftSaved,
              isError: false,
              dismissLabel: l10n.commonDismiss,
            ),
          );
        } else if (state is CaseRequestDeclineSuccess) {
          unawaited(
            showTabibuNotification(
              context,
              message: l10n.workspaceRequestDeclined,
              isError: false,
              dismissLabel: l10n.commonDismiss,
            ),
          );
          context.pop();
        } else if (state is CaseWorkspaceWriteFailure ||
            state is CaseWorkspaceLoadFailure) {
          final error = state is CaseWorkspaceWriteFailure
              ? state.error
              : (state as CaseWorkspaceLoadFailure).error;
          unawaited(
            showTabibuNotification(
              context,
              message: error.description(l10n),
              isError: true,
              dismissLabel: l10n.commonDismiss,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.signed != null && state.caseModel != null) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenMargin,
                      AppSpacing.md,
                      AppSpacing.screenMargin,
                      0,
                    ),
                    child: TopBar(
                      backLabel: l10n.commonBack,
                      onBack: context.pop,
                      title: state.caseModel!.orderNumber,
                      subtitle: workspaceSubtitle(state.caseModel),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.screenMargin),
                      children: [
                        SignedCaseView(
                          report: state.signed!,
                          caseModel: state.caseModel!,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final asked = state.caseModel;
        // Asked, not yet accepted: only the request can be read.
        if (asked != null &&
            asked.currentStageValue == .pathologistRequested &&
            asked.requestedPathologistUid == _uid &&
            state.draft == null) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenMargin,
                      AppSpacing.md,
                      AppSpacing.screenMargin,
                      0,
                    ),
                    child: TopBar(
                      backLabel: l10n.commonBack,
                      onBack: context.pop,
                      title: asked.orderNumber,
                      subtitle: workspaceSubtitle(asked),
                    ),
                  ),
                  Expanded(
                    child: CaseRequestView(
                      caseModel: asked,
                      busy: state is CaseWorkspaceWriteInProgress,
                      onAccept: () => _add(const CaseRequestAccepted()),
                      onDecline: (reason) =>
                          _add(CaseRequestDeclined(reason: reason)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Taken, sample not recorded: the report waits for its accession.
        if (asked != null &&
            asked.pathologistUid == _uid &&
            asked.awaitsSample &&
            state.draft == null) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenMargin,
                      AppSpacing.md,
                      AppSpacing.screenMargin,
                      0,
                    ),
                    child: TopBar(
                      backLabel: l10n.commonBack,
                      onBack: context.pop,
                      title: asked.orderNumber,
                      subtitle: workspaceSubtitle(asked),
                    ),
                  ),
                  Expanded(
                    child: SampleReceivedView(
                      caseModel: asked,
                      busy: state is CaseWorkspaceWriteInProgress,
                      onRecord: (accession) =>
                          _add(CaseSampleReceived(labAccessionNo: accession)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final draft = state.draft;
        final preread = state.preread;
        final ready = preread?.isReady == true;
        final locked = state.needsScore;
        final loading = state is CaseWorkspaceLoadInProgress && draft == null;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenMargin,
                    AppSpacing.md,
                    AppSpacing.screenMargin,
                    0,
                  ),
                  child: TopBar(
                    backLabel: l10n.commonBack,
                    onBack: context.pop,
                    title: state.caseModel?.orderNumber ?? '',
                    subtitle: workspaceSubtitle(state.caseModel),
                  ),
                ),
                Expanded(
                  child: loading
                      ? Center(
                          child: LoadingView(
                            semanticLabel: MaterialLocalizations.of(
                              context,
                            ).modalBarrierDismissLabel,
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.all(
                            AppSpacing.screenMargin,
                          ),
                          children: [
                            if (state.offline) ...[
                              ConnectivityBanner(
                                state: .offline,
                                title: l10n.notificationsOfflineTitle,
                                body: l10n.notificationsOfflineBody,
                                retryLabel: l10n.commonRetry,
                                onRetry: () => _add(
                                  CaseWorkspaceOpened(
                                    caseUid: widget.caseUid,
                                    pathologistUid: _uid,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],
                            _Chips(
                              priority: state.caseModel?.priorityValue,
                              ready: ready,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            if (_slideUrl != null)
                              SlideViewer(
                                image: NetworkImage(_slideUrl!),
                                heatmap: _heatmapUrl == null
                                    ? null
                                    : NetworkImage(_heatmapUrl!),
                                heatmapOn: _heatmapOn,
                                onHeatmapChanged: (v) =>
                                    setState(() => _heatmapOn = v),
                                heatmapLabel: l10n.workspaceHeatmap,
                                tilesLabel: '',
                                scaleLabel: workspaceScaleLabel(
                                  preread?.micronsPerPixel ?? 0,
                                ),
                                legendLow: l10n.workspaceLegendNormal,
                                legendHigh: preread?.profileValue == .malaria
                                    ? l10n.workspaceLegendLikelyParasite
                                    : l10n.workspaceLegendLikelyTumour,
                                // No ARB keys yet (bundle 35 skipped zoom).
                                zoomInLabel: '＋',
                                zoomOutLabel: '－',
                              ),
                            if (ready && preread != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              _PrereadCard(preread: preread),
                            ],
                            if (locked) ...[
                              const SizedBox(height: AppSpacing.md),
                              WorkspaceScoreCard(
                                findings: _findingsVerdict,
                                impression: _impressionVerdict,
                                urgency: _urgencyVerdict,
                                measurements: _measurementsVerdict,
                                tiles: _tilesVerdict,
                                overall: _overall,
                                comment: _scoreComment,
                                onFindings: (v) =>
                                    setState(() => _findingsVerdict = v),
                                onImpression: (v) =>
                                    setState(() => _impressionVerdict = v),
                                onUrgency: (v) =>
                                    setState(() => _urgencyVerdict = v),
                                onMeasurements: (v) =>
                                    setState(() => _measurementsVerdict = v),
                                onTiles: (v) =>
                                    setState(() => _tilesVerdict = v),
                                onOverall: (v) => setState(() => _overall = v),
                                onSave: _saveScore,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                l10n.scoreLockLine,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                            if (draft != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              _ReportSection(
                                draft: draft,
                                preread: preread,
                                locked: locked,
                                writeOwn: _writeOwn,
                                diagnosis: _diagnosis,
                                comments: _comments,
                                confirmable: _confirmable,
                                onWriteOwn: () =>
                                    setState(() => _writeOwn = true),
                                onStartFromAi: () =>
                                    _add(const CaseDraftStartedFromPreread()),
                                onDiagnosisType: (t) =>
                                    _setDiagnosisType(draft, t),
                                onCritical: (v) => _setCritical(draft, v),
                                onNotifiable: (id, {required on}) =>
                                    _toggleNotifiable(draft, id, on: on),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.md),
                            CaseHistoryRow(
                              caseUid: widget.caseUid,
                              role: .pathologist,
                            ),
                          ],
                        ),
                ),
                if (draft != null)
                  BottomActionBar(
                    secondary: TabibuButton.outline(
                      label: l10n.workspaceSaveDraft,
                      onTap: locked ? null : () => _saveDraft(draft),
                    ),
                    primary: TabibuButton.primary(
                      label: l10n.workspaceSignReport,
                      onTap: draft.diagnosis.trim().isEmpty || locked
                          ? null
                          : () => _openSign(state),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({required this.priority, required this.ready});

  final Urgency? priority;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        if (priority != null && priority != .routine)
          StatusChip(label: priority!.description(l10n), tone: .attention),
        if (ready) AiMark(label: l10n.deskAiDraftReady),
      ],
    );
  }
}

class _PrereadCard extends StatelessWidget {
  const _PrereadCard({required this.preread});

  final PrereadModel preread;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final draft = preread.draft;
    final band = ConfidenceBand.fromValue(draft.confidenceBand);
    final percent = (draft.confidence * 100).round();
    final bandText = switch (band) {
      .low => l10n.deskLowConfidenceRow('$percent%'),
      .moderate => l10n.deskBandRow(l10n.deskBandModerate, '$percent%'),
      .high => l10n.deskBandRow(l10n.deskBandHigh, '$percent%'),
    };
    final models = preread.models.values.where((v) => v.isNotEmpty).join(', ');
    final measurements = workspaceMeasurementRows(preread.measurements);

    return AiDraftFrame(
      label: l10n.workspaceAiPreread,
      detail: models.isEmpty ? null : models,
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Text(bandText, style: textTheme.titleSmall),
          if (draft.urgency.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              draft.urgencyValue.description(l10n),
              style: textTheme.bodyMedium,
            ),
          ],
          if (measurements.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.reportPdfMeasurements, style: textTheme.titleSmall),
            for (final (key, value) in measurements)
              Text('$key · $value', style: textTheme.bodyMedium),
          ],
          if (draft.impression.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.reportSectionImpression, style: textTheme.titleSmall),
            Text(draft.impression, style: textTheme.bodyMedium),
          ],
          if (draft.findings.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.reportQuestionFindings, style: textTheme.titleSmall),
            for (final finding in draft.findings)
              if (finding.text.isNotEmpty)
                Text(finding.text, style: textTheme.bodyMedium),
          ],
          if (draft.nextSteps.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.signedCaseNextSteps, style: textTheme.titleSmall),
            for (final step in draft.nextSteps)
              Text(step, style: textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _ReportSection extends StatelessWidget {
  const _ReportSection({
    required this.draft,
    required this.preread,
    required this.locked,
    required this.writeOwn,
    required this.diagnosis,
    required this.comments,
    required this.confirmable,
    required this.onWriteOwn,
    required this.onStartFromAi,
    required this.onDiagnosisType,
    required this.onCritical,
    required this.onNotifiable,
  });

  final ReportDraftModel draft;
  final PrereadModel? preread;
  final bool locked;
  final bool writeOwn;
  final TextEditingController diagnosis;
  final TextEditingController comments;
  final List<NotifiableDiseaseModel> confirmable;
  final VoidCallback onWriteOwn;
  final VoidCallback onStartFromAi;
  final ValueChanged<DiagnosisType> onDiagnosisType;
  final ValueChanged<bool> onCritical;
  final void Function(String diseaseId, {required bool on}) onNotifiable;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final ready = preread?.isReady == true;
    final showChooser =
        !locked &&
        draft.diagnosis.isEmpty &&
        ready &&
        !writeOwn &&
        !draft.startedFromPreread;

    if (showChooser) {
      return Column(
        crossAxisAlignment: .stretch,
        children: [
          TabibuButton.primary(
            label: l10n.workspaceStartFromAiDraft,
            onTap: onStartFromAi,
          ),
          const SizedBox(height: AppSpacing.sm),
          TabibuButton.outline(
            label: l10n.workspaceWriteOwn,
            onTap: onWriteOwn,
          ),
        ],
      );
    }

    final aiDiagnosis = preread?.draft.impression ?? '';
    final aiComments = preread == null ? '' : workspaceAiComments(preread!);
    final diagnosisFramed =
        draft.startedFromPreread && diagnosis.text.trim() == aiDiagnosis.trim();
    final commentsFramed =
        draft.startedFromPreread && comments.text.trim() == aiComments.trim();
    final diagnosisEdited =
        draft.startedFromPreread &&
        diagnosis.text.trim().isNotEmpty &&
        !diagnosisFramed;
    final commentsEdited =
        draft.startedFromPreread &&
        comments.text.trim().isNotEmpty &&
        !commentsFramed;

    Widget wrapField({
      required bool framed,
      required bool edited,
      required Widget field,
    }) {
      if (framed) {
        return AiDraftFrame(label: l10n.workspaceAiDraft, child: field);
      }
      if (edited) {
        return Column(
          crossAxisAlignment: .stretch,
          children: [
            Text(
              l10n.workspaceYourEdit,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            field,
          ],
        );
      }
      return field;
    }

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Wrap(
          spacing: AppSpacing.xs,
          children: [
            for (final type in DiagnosisType.values)
              TabibuFilterChip(
                label: switch (type) {
                  .finalDiagnosis => l10n.reportPdfDiagnosisTypeFinal,
                  .provisional => l10n.reportPdfDiagnosisTypeProvisional,
                  .inconclusive => l10n.reportPdfDiagnosisTypeInconclusive,
                },
                selected: draft.diagnosisType == type.value,
                onTap: locked ? null : () => onDiagnosisType(type),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        wrapField(
          framed: diagnosisFramed,
          edited: diagnosisEdited,
          field: TabibuTextField(
            label: l10n.reportSectionDiagnosis,
            controller: diagnosis,
            maxLines: 4,
            maxLength: CaseWorkspaceScreen.fieldMax,
            readOnly: locked,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        wrapField(
          framed: commentsFramed,
          edited: commentsEdited,
          field: TabibuTextField(
            label: l10n.reportSectionComments,
            controller: comments,
            maxLines: 6,
            maxLength: CaseWorkspaceScreen.fieldMax,
            readOnly: locked,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        CheckRow(
          label: l10n.workspaceCriticalFinding,
          value: draft.isCritical,
          onChanged: locked ? null : onCritical,
        ),
        if (confirmable.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.workspaceNotifiableExplainer,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          for (final disease in confirmable) ...[
            const SizedBox(height: AppSpacing.xs),
            CheckRow(
              label: l10n.workspacePositiveFor(
                workspaceDiseaseName(disease, language),
              ),
              value: draft.notifiableFindings.any(
                (f) => f.diseaseId == disease.diseaseId,
              ),
              onChanged: locked
                  ? null
                  : (on) => onNotifiable(disease.diseaseId, on: on),
            ),
          ],
        ],
      ],
    );
  }
}
