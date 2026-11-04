import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_bloc.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_event.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_state.dart';
import 'package:tabibu/features/reports/data/models/report_text_model.dart';
import 'package:tabibu/features/reports/presentation/widgets/approved_explanation_card.dart';
import 'package:tabibu/features/reports/presentation/widgets/explanation_draft_card.dart';
import 'package:tabibu/features/reports/presentation/widgets/explanation_edit_sheet.dart';
import 'package:tabibu/features/reports/presentation/widgets/explanation_language.dart';
import 'package:tabibu/features/reports/presentation/widgets/settled_sheet.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The bottom of the doctor's report (R-4): the one path by which AI-written
/// text reaches a patient, and only through the doctor's own tap.
///
/// Before release it offers Mark as discussed. After it, each AI draft waits
/// in [AiDraftFrame] for Approve as is, Edit or Reject, and each approved
/// text sits outside any frame. Nothing here sends an event except from a
/// tap; it shows nothing to anyone but the doctor who opened the case.
class ExplanationReviewSection extends StatelessWidget {
  const ExplanationReviewSection({
    required this.caseUid,
    required this.patientName,
    super.key,
  });

  final String caseUid;

  /// The patient's full name, shortened here to the first name.
  final String patientName;

  String _firstName(AppLocalizations l10n) {
    final first = patientName.trim().split(RegExp(r'\s+')).first;
    return first.isEmpty ? l10n.reportPdfPatient : first;
  }

  Future<void> _markDiscussed(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showSettledSheet<bool>(
      context,
      title: l10n.explanationMarkTitle(_firstName(l10n)),
      subtitle: l10n.explanationReleaseNote,
      cancelLabel: l10n.commonCancel,
      builder: (sheet) => TabibuButton.primary(
        label: l10n.explanationConfirm,
        onTap: () => Navigator.of(sheet).pop(true),
      ),
    );
    if (confirmed != true || !context.mounted) return;
    context.read<ReportReaderBloc>().add(const ReportDiscussedRequested());
  }

  Future<void> _edit(
    BuildContext context,
    String language,
    ReportTextModel draft,
  ) async {
    final edited = await showExplanationEditSheet(
      context,
      language: explanationLanguageName(context.l10n, language),
      segments: draft.machineText,
    );
    if (edited == null || !context.mounted) return;
    context.read<ReportReaderBloc>().add(
      ExplanationDecisionRequested(language: language, editedText: edited),
    );
  }

  Future<void> _reject(
    BuildContext context,
    String language,
    String title,
  ) async {
    final l10n = context.l10n;
    final chosen = await showOptionsSheet<bool>(
      context,
      title: title,
      actions: [
        OptionsAction(
          value: true,
          icon: Assets.icons.cancelCircleIcon,
          label: l10n.alertReviewReject,
          destructive: true,
        ),
      ],
    );
    if (chosen != true || !context.mounted) return;
    final confirmed = await showSettledSheet<bool>(
      context,
      title: title,
      subtitle: l10n.explanationRejectBody,
      cancelLabel: l10n.commonCancel,
      builder: (sheet) => TabibuButton.primary(
        label: l10n.alertReviewReject,
        onTap: () => Navigator.of(sheet).pop(true),
      ),
    );
    if (confirmed != true || !context.mounted) return;
    context.read<ReportReaderBloc>().add(
      ExplanationDecisionRequested(language: language, reject: true),
    );
  }

  void _reload(BuildContext context, ReportReaderState state) {
    context.read<ReportReaderBloc>().add(
      ReportReaderOpened(uid: state.uid, role: .doctor, caseUid: caseUid),
    );
  }

  Widget _emptyPhaseCard({
    required AppLocalizations l10n,
    required ReportReaderState state,
    required bool busy,
    required BuildContext context,
  }) {
    final (body, icon, actions) = switch (state.explanationPhase) {
      .pending => (
        l10n.explanationWaitingForDraft,
        Assets.icons.hourglassIcon,
        <Widget>[
          TabibuButton.ghost(
            label: l10n.commonRetry,
            isLoading: state is ReportReaderLoadInProgress,
            onTap: busy ? null : () => _reload(context, state),
          ),
        ],
      ),
      .failed => (
        l10n.explanationFailedBody,
        Assets.icons.cancelCircleIcon,
        const <Widget>[],
      ),
      .rejected => (
        l10n.explanationRejectedBody,
        Assets.icons.cancelCircleIcon,
        const <Widget>[],
      ),
      .none => (
        l10n.explanationWaitingForDraft,
        Assets.icons.hourglassIcon,
        <Widget>[
          TabibuButton.ghost(
            label: l10n.commonRetry,
            isLoading: state is ReportReaderLoadInProgress,
            onTap: busy ? null : () => _reload(context, state),
          ),
        ],
      ),
    };

    return NoticeCard(
      icon: icon,
      variant: state.explanationPhase == .failed ? .attention : .neutral,
      body: body,
      action: actions.isEmpty
          ? null
          : Column(
              crossAxisAlignment: .stretch,
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.xs),
                  actions[i],
                ],
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<ReportReaderBloc, ReportReaderState>(
      listenWhen: (_, current) =>
          current is ReportReaderWriteFailure && current.caseUid == caseUid,
      listener: (context, state) {
        if (state case ReportReaderWriteFailure(:final error)) {
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
        final report = state.report;
        if (state.role != .doctor || state.caseUid != caseUid) {
          return const SizedBox.shrink();
        }
        if (report == null) return const SizedBox.shrink();

        final writing = state is ReportReaderWriteInProgress;
        // A reload in flight could overwrite a decision's result.
        final busy = writing || state is ReportReaderLoadInProgress;

        if (!report.releasedToPatient) {
          return TabibuButton.primary(
            label: l10n.explanationMarkButton,
            isLoading: writing,
            onTap: busy ? null : () => _markDiscussed(context),
          );
        }

        final name = _firstName(l10n);
        final drafts = state.explanations.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
        final approved = state.approved.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        Widget draftCard(String language, ReportTextModel draft) {
          final title = l10n.explanationDraftTitle(
            name,
            explanationLanguageName(l10n, language),
          );
          return ExplanationDraftCard(
            title: title,
            segments: draft.machineText.values.toList(),
            busy: busy,
            onApprove: () => context.read<ReportReaderBloc>().add(
              ExplanationDecisionRequested(language: language),
            ),
            onEdit: () => _edit(context, language, draft),
            onMore: () => _reject(context, language, title),
          );
        }

        final cards = <Widget>[
          for (final MapEntry(:key, value: draft) in drafts)
            draftCard(key, draft),
          for (final MapEntry(:key, value: text) in approved)
            ApprovedExplanationCard(
              language: explanationLanguageName(l10n, key),
              segments: text.approvedText.values.toList(),
            ),
          if (drafts.isEmpty && approved.isEmpty)
            _emptyPhaseCard(
              l10n: l10n,
              state: state,
              busy: busy,
              context: context,
            ),
        ];

        return Column(
          crossAxisAlignment: .stretch,
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.md),
              cards[i],
            ],
          ],
        );
      },
    );
  }
}
