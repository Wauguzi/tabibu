import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/helpers/reference_data_helper.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/alerts/blocs/alert_review_bloc/alert_review_bloc.dart';
import 'package:tabibu/features/alerts/blocs/alert_review_bloc/alert_review_event.dart';
import 'package:tabibu/features/alerts/blocs/alert_review_bloc/alert_review_state.dart';
import 'package:tabibu/features/alerts/data/models/alert_model.dart';
import 'package:tabibu/features/alerts/data/models/notifiable_disease_model.dart';
import 'package:tabibu/features/alerts/presentation/widgets/alert_demo_banner.dart';
import 'package:tabibu/features/alerts/presentation/widgets/alert_draft_card.dart';
import 'package:tabibu/features/alerts/presentation/widgets/alert_edit_sheet.dart';
import 'package:tabibu/features/alerts/presentation/widgets/alert_evidence_card.dart';
import 'package:tabibu/features/alerts/presentation/widgets/alert_reject_sheet.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// D-ALERT. The approver's review of an AI-drafted area alert: both
/// languages' drafts in [AiDraftFrame], the evidence as plain facts, then
/// Approve as is, Edit and (in the `•••` menu) Reject.
///
/// The bloc decides what a decision sends: it takes the revisions of the
/// alert on screen, never fresh ones. A person without the approver claim
/// sees nothing and the screen asks for nothing (S-2).
class AlertReviewScreen extends StatefulWidget {
  const AlertReviewScreen({required this.alertUid, super.key});

  final String alertUid;

  @override
  State<AlertReviewScreen> createState() => _AlertReviewScreenState();
}

class _AlertReviewScreenState extends State<AlertReviewScreen> {
  late final bool _canApprove;

  late final Future<List<NotifiableDiseaseModel>> _register = _loadRegister();

  @override
  void initState() {
    super.initState();
    final session = context.read<AuthBloc>().state.session;
    _canApprove =
        session is PractitionerSession && session.roles.canApproveAlerts;
    if (_canApprove) _reload(context);
  }

  Future<List<NotifiableDiseaseModel>> _loadRegister() async {
    try {
      return await getIt<ReferenceDataHelper>().notifiableDiseases();
    } on Object {
      // The register only names the disease; the review works without it.
      return const [];
    }
  }

  void _reload(BuildContext context) => context.read<AlertReviewBloc>().add(
    AlertReviewOpened(alertUid: widget.alertUid),
  );

  void _onState(BuildContext context, AlertReviewState state) {
    final ours = state.current?.uid == widget.alertUid;
    switch (state) {
      case AlertDecisionSuccess(:final decision) when ours:
        // Reject leaves no screen of its own (F-9); an approval replaces
        // this one, so back never returns to a decided draft (F-1).
        if (decision == .reject) {
          const DoctorHomeRoute().go(context);
        } else {
          AlertSentRoute(alertUid: widget.alertUid).pushReplacement(context);
        }
      case AlertDecisionFailure(:final error) when ours:
        _showError(context, error);
        // A changed draft or evidence is refused by the server; reading it
        // again puts the new text, and its revisions, in front of the
        // approver. Offline there is nothing newer to read.
        if (error != .noInternet) _reload(context);
      case AlertReviewLoadFailure(:final error) when ours:
        _showError(context, error);
      case _:
        break;
    }
  }

  void _showError(BuildContext context, AppError error) {
    final l10n = context.l10n;
    unawaited(
      showTabibuNotification(
        context,
        message: error.description(l10n),
        isError: true,
        dismissLabel: l10n.commonDismiss,
      ),
    );
  }

  Future<void> _more(BuildContext context) async {
    final l10n = context.l10n;
    final chosen = await showOptionsSheet<bool>(
      context,
      title: l10n.alertReviewTitle,
      actions: [
        OptionsAction(
          value: true,
          icon: Assets.icons.cancelCircleIcon,
          label: l10n.alertReviewReject,
          supporting: l10n.alertReviewRejectSub,
          destructive: true,
        ),
      ],
    );
    if (chosen != true || !context.mounted) return;
    final reason = await showAlertRejectSheet(context);
    if (reason == null || !context.mounted) return;
    context.read<AlertReviewBloc>().add(
      AlertRejectRequested(alertUid: widget.alertUid, reason: reason),
    );
  }

  Future<void> _edit(
    BuildContext context,
    AlertModel alert,
    String language,
  ) async {
    final bloc = context.read<AlertReviewBloc>();
    final keys = [
      for (final clinician in [true, false])
        alertDraftKey(clinician: clinician, language: language),
    ];
    final edited = await showAlertEditSheet(
      context,
      language: language,
      area: alert.countyName,
      segments: {
        for (final key in keys)
          if (alert.machineText.containsKey(key)) key: alert.machineText[key]!,
      },
    );
    if (edited == null || !context.mounted) return;
    // The bloc sends the revisions of whatever it holds now. If that is no
    // longer the draft these edits started from, they are not approved blind.
    final now = bloc.state.current;
    if (now == null ||
        now.uid != alert.uid ||
        now.draftRevision != alert.draftRevision ||
        now.evidenceRevision != alert.evidenceRevision) {
      return;
    }
    // Every draft key goes: the bloc compares the whole set to the draft and
    // decides between Approve and ApproveEdited.
    bloc.add(
      AlertApproveRequested(
        alertUid: alert.uid,
        editedText: {...alert.machineText, ...edited},
      ),
    );
  }

  String _testName(
    List<NotifiableDiseaseModel> register,
    AlertModel alert,
    String language,
  ) {
    final disease = register.firstWhereOrNull(
      (d) => d.diseaseId == alert.diseaseId,
    );
    if (disease == null) return alert.diseaseId;
    final test =
        disease.labTests.firstWhereOrNull(
          (t) => t.strengthValue == .confirms,
        ) ??
        disease.labTests.firstOrNull;
    if (test != null && test.name.isNotEmpty) return test.name;
    return language == 'sw' && disease.nameSw.isNotEmpty
        ? disease.nameSw
        : disease.nameEn;
  }

  @override
  Widget build(BuildContext context) {
    if (!_canApprove) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AlertReviewBloc, AlertReviewState>(
          listenWhen: (_, next) =>
              next is AlertDecisionSuccess ||
              next is AlertDecisionFailure ||
              next is AlertReviewLoadFailure,
          listener: _onState,
          builder: (context, state) {
            final alert = state.current?.uid == widget.alertUid
                ? state.current
                : null;
            final deciding = state is AlertDecisionInProgress;
            final topBar = TopBar(
              backLabel: l10n.commonBack,
              onBack: context.pop,
            );

            if (state is AlertDecisionSuccess) {
              // The listener is leaving this screen.
              return LoadingView(semanticLabel: l10n.alertReviewTitle);
            }
            if (alert == null) {
              final error = switch (state) {
                AlertReviewLoadFailure(:final error) => error,
                AlertDecisionFailure(:final error) => error,
                _ => null,
              };
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.screenMargin),
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: [
                    topBar,
                    Expanded(
                      child: error == null
                          ? LoadingView(semanticLabel: l10n.alertReviewTitle)
                          : Center(
                              child: EmptyState(
                                title: error.description(l10n),
                                actions: [
                                  TabibuButton.secondary(
                                    label: l10n.commonRetry,
                                    onTap: () => _reload(context),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              );
            }
            if (!alert.isAwaitingDecision) {
              // Decided, withdrawn or expired: there is nothing to approve,
              // and its drafts are no longer "not sent" to show.
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.screenMargin),
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: [
                    topBar,
                    Expanded(
                      child: Center(
                        child: EmptyState(title: l10n.errorDataNotFound),
                      ),
                    ),
                  ],
                ),
              );
            }
            return _Review(
              alert: alert,
              register: _register,
              deciding: deciding,
              testName: _testName,
              onMore: () => unawaited(_more(context)),
              onEdit: (language) => unawaited(_edit(context, alert, language)),
              onApprove: () => context.read<AlertReviewBloc>().add(
                AlertApproveRequested(alertUid: alert.uid),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Review extends StatelessWidget {
  const _Review({
    required this.alert,
    required this.register,
    required this.deciding,
    required this.testName,
    required this.onMore,
    required this.onEdit,
    required this.onApprove,
  });

  final AlertModel alert;
  final Future<List<NotifiableDiseaseModel>> register;
  final bool deciding;
  final String Function(List<NotifiableDiseaseModel>, AlertModel, String)
  testName;
  final VoidCallback onMore;
  final ValueChanged<String> onEdit;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    // Approving takes the whole draft: an alert missing a key is shown but
    // cannot be approved, since the server would refuse its edits too.
    final complete = alertDraftKeys.every(alert.machineText.containsKey);
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenMargin,
              AppSpacing.screenMargin,
              AppSpacing.screenMargin,
              AppSpacing.md,
            ),
            children: [
              TopBar(
                backLabel: l10n.commonBack,
                onBack: context.pop,
                title: l10n.alertReviewTitle,
                subtitle: alert.countyName.isEmpty ? null : alert.countyName,
                trailing: MoreButton(
                  semanticLabel: l10n.notificationsMoreLabel,
                  onTap: deciding ? null : onMore,
                ),
              ),
              if (alert.synthetic) ...[
                const SizedBox(height: AppSpacing.md),
                const AlertDemoBanner(),
              ],
              const SizedBox(height: AppSpacing.md),
              FutureBuilder<List<NotifiableDiseaseModel>>(
                future: register,
                builder: (context, snapshot) => AlertEvidenceCard(
                  evidence: alert.evidence,
                  area: alert.countyName,
                  test: testName(
                    snapshot.data ?? const <NotifiableDiseaseModel>[],
                    alert,
                    language,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.alertReviewDraftsTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              for (final draftLanguage in alertDraftLanguages) ...[
                const SizedBox(height: AppSpacing.sm),
                AlertDraftCard(
                  language: draftLanguage,
                  drafts: alert.machineText,
                  area: alert.countyName,
                  busy: deciding,
                  onEdit: () => onEdit(draftLanguage),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              NoticeCard(
                variant: .neutral,
                icon: Assets.icons.infoIcon,
                body: l10n.alertReviewApprovalNotice,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenMargin,
            AppSpacing.sm,
            AppSpacing.screenMargin,
            AppSpacing.md,
          ),
          child: TabibuButton.primary(
            label: l10n.alertReviewApproveAsIs,
            isLoading: deciding,
            onTap: deciding || !complete ? null : onApprove,
          ),
        ),
      ],
    );
  }
}
