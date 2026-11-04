import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_styles.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/presentation/result_copy.dart';
import 'package:tabibu/features/cases/presentation/widgets/case_history_row.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_bloc.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_event.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/presentation/report_download.dart';
import 'package:tabibu/features/reports/presentation/widgets/report_file_card.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P-11b / P-13. Waiting with the doctor, or a shared result (no report text
/// until released — S-3).
class PatientResultScreen extends StatefulWidget {
  const PatientResultScreen({required this.caseUid, this.download, super.key});

  final String caseUid;

  /// Test seam; production builds a [ReportDownload] on first download.
  final ReportDownload? download;

  @override
  State<PatientResultScreen> createState() => _PatientResultScreenState();
}

class _PatientResultScreenState extends State<PatientResultScreen> {
  late final PatientModel _patient;

  @override
  void initState() {
    super.initState();
    final session = context.read<AuthBloc>().state.session;
    _patient = switch (session) {
      PatientSession(:final patient) => patient,
      _ => PatientModel.empty(),
    };
    final cases = context.read<CasesBloc>();
    if (cases.state.cases.isEmpty) {
      cases.add(CasesRequested(uid: _patient.uid, role: .patient));
    }
    cases.add(CaseLogRequested(caseUid: widget.caseUid, role: .patient));
    context.read<AppointmentsBloc>().add(
      AppointmentsRequested(uid: _patient.uid, role: .patient),
    );
    final reader = context.read<ReportReaderBloc>();
    if (reader.state.caseUid != widget.caseUid ||
        reader.state.role != .patient) {
      reader.add(
        ReportReaderOpened(
          uid: _patient.uid,
          role: .patient,
          caseUid: widget.caseUid,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final casesState = context.watch<CasesBloc>().state;
    final appointments = context.watch<AppointmentsBloc>().state.appointments;
    final caseModel = casesState.cases.firstWhereOrNull(
      (c) => c.uid == widget.caseUid,
    );
    final loading =
        caseModel == null &&
        (casesState is CasesInitial || casesState is CasesLoadInProgress);

    return Scaffold(
      body: SafeArea(
        child: loading
            ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: TopBar(
                      backLabel: l10n.commonBack,
                      onBack: context.pop,
                    ),
                  ),
                  Expanded(
                    child: LoadingView(semanticLabel: l10n.resultsLoadingLabel),
                  ),
                ],
              )
            : caseModel == null
            ? Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TopBar(backLabel: l10n.commonBack, onBack: context.pop),
              )
            : _body(
                caseModel: caseModel,
                casesState: casesState,
                appointments: appointments,
                language: language,
              ),
      ),
    );
  }

  Widget _body({
    required CaseModel caseModel,
    required CasesState casesState,
    required List<AppointmentModel> appointments,
    required String language,
  }) {
    final released = caseModel.resultStateValue == .released;
    if (!released) {
      return _WaitingBody(
        caseModel: caseModel,
        report: _reportFor(caseModel, casesState.reports),
        appointments: appointments,
        language: language,
      );
    }
    return _SharedBody(
      caseModel: caseModel,
      report: _reportFor(caseModel, casesState.reports),
      patient: _patient,
      language: language,
      download: widget.download,
    );
  }

  PathologyReportModel? _reportFor(
    CaseModel c,
    List<PathologyReportModel> reports,
  ) {
    if (c.currentReportUid.isEmpty) {
      return reports.firstWhereOrNull((r) => r.caseUid == c.uid);
    }
    return reports.firstWhereOrNull((r) => r.uid == c.currentReportUid);
  }
}

class _WaitingBody extends StatelessWidget {
  const _WaitingBody({
    required this.caseModel,
    required this.report,
    required this.appointments,
    required this.language,
  });

  final CaseModel caseModel;
  final PathologyReportModel? report;
  final List<AppointmentModel> appointments;
  final String language;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final testName = caseModel.tests.firstOrNull?.name ?? '';
    final discussion = appointments.firstWhereOrNull(
      (a) => a.uid == caseModel.discussionAppointmentUid,
    );
    final discussAt = discussion == null
        ? null
        : nairobiTimeOf(discussion.scheduledStart);
    final dateLabel = discussAt == null
        ? ''
        : DateFormat('EEE d MMM', language).format(discussAt);

    final steps = _timelineSteps(
      l10n: l10n,
      language: language,
      caseModel: caseModel,
      report: report,
      discussAt: discussAt,
    );
    final current = steps.indexWhere((s) => s.state == .inProgress);
    final progressStep = current < 0 ? steps.length : current + 1;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        TopBar(
          backLabel: l10n.commonBack,
          onBack: context.pop,
          title: l10n.resultsWaitingTitle(testName),
          subtitle: l10n.resultsWaitingSubtitleFor(caseModel.doctorName),
        ),
        const SizedBox(height: AppSpacing.md),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: .topLeft,
              end: .bottomRight,
              colors: isDark
                  ? [AppColors.lavenderDark, AppColors.skyDark]
                  : [AppColors.lavenderLight, AppColors.skyLight],
            ),
            borderRadius: BorderRadius.circular(AppRadii.hero),
          ),
          child: Padding(
            padding: AppStyles.cardPadding,
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                Align(
                  alignment: .centerLeft,
                  child: IconTile(
                    icon: Assets.icons.documentIcon,
                    tone: .lavender,
                    size: .l,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.resultsWaitingHeadline,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: .w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.resultsWaitingBodyFor(caseModel.doctorName, dateLabel),
                  style: textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.resultsWaitingExplanation,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        VerificationTimeline(
          title: l10n.resultsTimelineTitle,
          progressLabel: l10n.stepProgress(progressStep, steps.length),
          steps: steps,
        ),
        // No report content while waiting (S-3).
        if (discussion != null && discussion.uid.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          TabibuButton.primary(
            label: l10n.resultsSeeAppointment,
            onTap: () => PatientAppointmentRoute(
              appointmentUid: discussion.uid,
            ).push<void>(context),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        CaseHistoryRow(caseUid: caseModel.uid, role: .patient),
      ],
    );
  }

  List<VerificationStep> _timelineSteps({
    required AppLocalizations l10n,
    required String language,
    required CaseModel caseModel,
    required PathologyReportModel? report,
    required DateTime? discussAt,
  }) {
    final sampleAt = nairobiTimeOf(
      caseModel.sampleCollectedAt.isNotEmpty
          ? caseModel.sampleCollectedAt
          : caseModel.sampleReceivedAt,
    );
    final signedAt = nairobiTimeOf(report?.signedAt ?? '');
    final facility = caseModel.doctorFacilityName;
    final pathologist = caseModel.pathologistName.isNotEmpty
        ? caseModel.pathologistName
        : (report?.signedByName ?? '');
    final lab = report?.signedByFacilityName.isNotEmpty == true
        ? report!.signedByFacilityName
        : facility;

    final sampleDone = sampleAt != null;
    final reviewedDone =
        signedAt != null || caseModel.currentReportUid.isNotEmpty;
    // With the doctor: talk is current; otherwise still later.
    final talkCurrent =
        caseModel.resultStateValue == .withDoctor ||
        caseModel.resultStateValue == .updateWithDoctor;

    String fmtDate(DateTime? at) =>
        at == null ? '' : DateFormat('EEE d MMM', language).format(at);
    String fmtTime(DateTime? at) =>
        at == null ? '' : DateFormat('h:mm a', language).format(at);

    return [
      VerificationStep(
        title: l10n.resultsStepSample,
        supporting: l10n.resultsStepSampleDetailFor(
          fmtDate(sampleAt),
          facility,
        ),
        state: sampleDone ? .done : .upNext,
        chipLabel: sampleDone ? l10n.resultsStepDone : l10n.resultsStepLater,
        stateLabel: sampleDone ? l10n.resultsStepDone : l10n.resultsStepLater,
        icon: Assets.icons.testTubeIcon,
      ),
      VerificationStep(
        title: l10n.resultsStepReviewed,
        supporting: l10n.resultsStepReviewedDetailFor(
          fmtDate(signedAt),
          pathologist,
          lab,
        ),
        state: reviewedDone ? .done : (sampleDone ? .inProgress : .upNext),
        chipLabel: reviewedDone
            ? l10n.resultsStepDone
            : (sampleDone ? l10n.resultsStepNext : l10n.resultsStepLater),
        stateLabel: reviewedDone
            ? l10n.resultsStepDone
            : (sampleDone ? l10n.resultsStepNext : l10n.resultsStepLater),
        icon: Assets.icons.verificationBadge,
      ),
      VerificationStep(
        title: l10n.resultsStepTalkFor(caseModel.doctorName),
        supporting: l10n.resultsStepTalkDetailFor(
          fmtDate(discussAt),
          fmtTime(discussAt),
        ),
        state: talkCurrent && reviewedDone
            ? .inProgress
            : (reviewedDone ? .upNext : .upNext),
        chipLabel: talkCurrent && reviewedDone
            ? l10n.resultsStepNext
            : l10n.resultsStepLater,
        stateLabel: talkCurrent && reviewedDone
            ? l10n.resultsStepNext
            : l10n.resultsStepLater,
        icon: Assets.icons.calendarIcon,
      ),
      VerificationStep(
        title: l10n.resultsStepRead,
        supporting: l10n.resultsStepReadDetail,
        state: .upNext,
        chipLabel: l10n.resultsStepLater,
        stateLabel: l10n.resultsStepLater,
        icon: Assets.icons.documentIcon,
      ),
    ];
  }
}

enum _ShareMenu { whoCanSee, sharedReports }

class _SharedBody extends StatefulWidget {
  const _SharedBody({
    required this.caseModel,
    required this.report,
    required this.patient,
    required this.language,
    this.download,
  });

  final CaseModel caseModel;
  final PathologyReportModel? report;
  final PatientModel patient;
  final String language;
  final ReportDownload? download;

  @override
  State<_SharedBody> createState() => _SharedBodyState();
}

class _SharedBodyState extends State<_SharedBody> {
  bool _downloading = false;
  bool _failed = false;
  ReportDownload? _download;

  ReportDownload get _reportDownload =>
      _download ??= widget.download ?? ReportDownload();

  Future<void> _onDownload() async {
    final report = widget.report;
    if (report == null || _downloading) return;
    // The browser has no temp files or share sheet: say so at once instead
    // of failing the attempt.
    if (kIsWeb) {
      setState(() => _failed = true);
      return;
    }
    setState(() {
      _downloading = true;
      _failed = false;
    });
    final l10n = context.l10n;
    try {
      await _reportDownload.sharePatientReport(
        report: report,
        caseModel: widget.caseModel,
        patient: widget.patient,
        language: widget.language,
        l10n: l10n,
        now: DateTime.now().toUtc(),
      );
      if (!mounted) return;
      setState(() => _downloading = false);
    } on AppError {
      if (!mounted) return;
      setState(() {
        _downloading = false;
        _failed = true;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _downloading = false;
        _failed = true;
      });
    }
  }

  Future<void> _onMore() async {
    final l10n = context.l10n;
    final chosen = await showOptionsSheet<_ShareMenu>(
      context,
      title: l10n.shareTitle,
      actions: [
        OptionsAction(
          value: _ShareMenu.whoCanSee,
          icon: Assets.icons.personIcon,
          label: l10n.shareWhoCanSeeTitle,
        ),
        OptionsAction(
          value: _ShareMenu.sharedReports,
          icon: Assets.icons.shareIcon,
          label: l10n.shareListTitle,
        ),
      ],
    );
    if (chosen == null || !mounted) return;
    final route = switch (chosen) {
      .whoCanSee => WhoCanSeeRoute(caseUid: widget.caseModel.uid),
      .sharedReports => const SharedReportsRoute(),
    };
    unawaited(route.push<void>(context));
  }

  @override
  Widget build(BuildContext context) {
    final caseModel = widget.caseModel;
    final report = widget.report;
    final language = widget.language;
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final testName =
        caseModel.tests.firstOrNull?.name ?? report?.testName ?? '';
    final releasedAt = nairobiTimeOf(
      caseModel.releasedAt.isNotEmpty
          ? caseModel.releasedAt
          : (report?.signedAt ?? ''),
    );
    final dateLabel = releasedAt == null
        ? ''
        : DateFormat('EEE d MMM', language).format(releasedAt);
    final note = (report?.comments.isNotEmpty == true)
        ? report!.comments
        : (report?.diagnosis ?? '');
    final facility = caseModel.doctorFacilityName.isNotEmpty
        ? caseModel.doctorFacilityName
        : (report?.signedByFacilityName ?? '');
    final fileName = dateLabel.isEmpty
        ? '$testName.pdf'
        : '$testName · $dateLabel.pdf';

    // Next-steps checklist only when the report carries them as text — the
    // model has no nextSteps field, so omit (bundle: otherwise omit).
    // ListenCard omitted (H-9 / explanations only).

    // Only text the doctor approved can open P-14 (F-8); the reader's drafts
    // are never read here.
    final reader = context.watch<ReportReaderBloc>().state;
    final explained =
        reader.caseUid == caseModel.uid &&
        reader.role == .patient &&
        reader.approved.isNotEmpty;
    final explainedDoctor = caseModel.doctorName.isNotEmpty
        ? caseModel.doctorName
        : (reader.approved.values.firstOrNull?.approverName ?? '');

    final canDownload = report != null && !_downloading;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        TopBar(
          backLabel: l10n.commonBack,
          onBack: context.pop,
          title: testName,
          trailing: MoreButton(
            semanticLabel: l10n.notificationsMoreLabel,
            onTap: _onMore,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: .centerLeft,
          child: StatusChip(label: l10n.resultDetailShared, tone: .signed),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.resultDetailSharedBy(caseModel.doctorName),
          style: textTheme.headlineSmall?.copyWith(fontWeight: .w600),
        ),
        if (dateLabel.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            [dateLabel, if (facility.isNotEmpty) facility].join(' · '),
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
        if (note.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.brightness == .dark
                  ? scheme.surfaceContainerHigh
                  : scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadii.card),
              boxShadow: AppShadows.card(),
            ),
            child: Padding(
              padding: AppStyles.cardPadding,
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  Text(
                    l10n.resultDetailFromDoctor(caseModel.doctorName),
                    style: textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(note, style: textTheme.bodyLarge),
                ],
              ),
            ),
          ),
        ],
        if (explained) ...[
          const SizedBox(height: AppSpacing.md),
          ListRowCard(
            leading: IconTile(icon: Assets.icons.notesIcon, tone: .lavender),
            title: explainedDoctor.isEmpty
                ? l10n.explainedAiAttribution
                : l10n.explainedHeadline(explainedDoctor),
            subtitle: explainedDoctor.isEmpty
                ? null
                : l10n.explainedAiAttribution,
            onTap: () => ExplainedResultRoute(
              caseUid: caseModel.uid,
            ).push<void>(context),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        ReportFileCard(
          title: l10n.resultDetailFullReport,
          fileName: fileName,
          meta: l10n.resultDetailFileMeta('PDF', facility),
          downloadLabel: _downloading
              ? l10n.resultsLoadingLabel
              : l10n.resultDetailDownload,
          onDownload: canDownload ? _onDownload : null,
          shareLabel: l10n.resultDetailShare,
          onShare: () =>
              ShareReportRoute(caseUid: caseModel.uid).push<void>(context),
        ),
        if (_downloading) ...[
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            label: l10n.resultsLoadingLabel,
            child: const LinearProgressIndicator(),
          ),
        ],
        if (_failed) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            kIsWeb ? l10n.resultDetailWebDownload : l10n.errorUnknown,
            style: textTheme.bodyMedium?.copyWith(color: scheme.error),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        TabibuButton.primary(
          label: l10n.resultDetailBookFollowUp,
          onTap: caseModel.doctorUid.isEmpty
              ? null
              : () => PractitionerProfileRoute(
                  doctorUid: caseModel.doctorUid,
                ).push<void>(context),
        ),
        const SizedBox(height: AppSpacing.md),
        CaseHistoryRow(caseUid: caseModel.uid, role: .patient),
      ],
    );
  }
}
