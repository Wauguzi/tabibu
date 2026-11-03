import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/reports/blocs/case_workspace_bloc/case_workspace_bloc.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/services/report_labels.dart';
import 'package:tabibu/features/reports/presentation/widgets/report_text_card.dart';
import 'package:tabibu/features/reports/presentation/widgets/revision_sheet.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// CS-08's signed half (H-4): the chips, the banner, the signed report
/// verbatim, the provenance footnote, and the compare / revise actions for
/// the signer only. No AI panel, no draft frame, no heatmap, no change count.
class SignedCaseView extends StatelessWidget {
  const SignedCaseView({
    required this.report,
    required this.caseModel,
    this.onRevisionStarted,
    this.busy = false,
    super.key,
  });

  final PathologyReportModel report;
  final CaseModel caseModel;

  /// Called after the sheet confirms; kind is `Amendment` or `Addendum`.
  final void Function(String kind, String text)? onRevisionStarted;

  /// True while a revision start is in flight (disables the buttons).
  final bool busy;

  /// Stages where the server accepts Amendment / Addendum.
  static bool canReviseStage(CaseStage stage) =>
      CaseWorkspaceBloc.revisionStages.contains(stage);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final me = switch (context.watch<AuthBloc>().state.session) {
      PractitionerSession(:final doctor) => doctor.uid,
      _ => '',
    };
    final signedAt = nairobiTimeOf(report.signedAt);
    final date = signedAt == null
        ? ''
        : DateFormat('d MMM, h:mm a', language).format(signedAt);
    final doctor = caseModel.doctorName;
    final section = reportSectionLabel(l10n, ReportSection.diagnosis.value);
    final type = reportDiagnosisTypeLabel(l10n, report.diagnosisType);
    final isSigner = report.pathologistUid == me && me.isNotEmpty;
    final canRevise =
        isSigner &&
        canReviseStage(caseModel.currentStageValue) &&
        onRevisionStarted != null;
    final versionLine = _versionLine(l10n, date);

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            StatusChip(label: l10n.caseStepSigned, tone: .signed),
            if (doctor.isNotEmpty)
              StatusChip(
                label: l10n.signedCaseSentChip(doctor),
                tone: .neutral,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        NoticeCard(
          variant: .signed,
          title: l10n.signedCaseSignedByYou,
          body: l10n.signedCaseSentLine(date, doctor),
        ),
        if (versionLine != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(versionLine, style: Theme.of(context).textTheme.bodyMedium),
        ],
        const SizedBox(height: AppSpacing.md),
        ReportTextCard(
          title: l10n.reportPdfSignedReport,
          entries: [
            (
              type.isEmpty ? section : '$section · $type',
              report.diagnosis.isEmpty
                  ? l10n.reportPdfMissingValue
                  : report.diagnosis,
            ),
            if (report.comments.isNotEmpty)
              (
                reportSectionLabel(l10n, ReportSection.comments.value),
                report.comments,
              ),
            for (final m in report.measurements) (m.key, m.formatted),
            for (final a in report.addenda)
              (
                l10n.signedCaseAddendumEntry(_shortDate(a.signedAt, language)),
                a.text,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        NoticeCard(
          variant: .neutral,
          icon: Assets.icons.infoIcon,
          body: l10n.signedCaseDraftKept,
        ),
        if (isSigner) ...[
          const SizedBox(height: AppSpacing.lg),
          TabibuButton.secondary(
            label: l10n.signedCaseCompare,
            onTap: busy
                ? null
                : () =>
                      CompareRoute(caseUid: caseModel.uid).push<void>(context),
          ),
        ],
        if (canRevise) ...[
          const SizedBox(height: AppSpacing.sm),
          TabibuButton.outline(
            label: l10n.signedCaseAmend,
            onTap: busy
                ? null
                : () async {
                    final reason = await AmendSheet.show(context);
                    if (reason == null || !context.mounted) return;
                    onRevisionStarted!('Amendment', reason);
                  },
          ),
          const SizedBox(height: AppSpacing.sm),
          TabibuButton.outline(
            label: l10n.signedCaseAddendum,
            onTap: busy
                ? null
                : () async {
                    final text = await AddendumSheet.show(context);
                    if (text == null || !context.mounted) return;
                    onRevisionStarted!('Addendum', text);
                  },
          ),
        ],
      ],
    );
  }

  String? _versionLine(AppLocalizations l10n, String date) {
    if (report.version <= 0) return null;
    return switch (report.stageValue) {
      .amended => l10n.signedCaseVersionAmended(
        report.version,
        date,
        report.amendmentReason,
      ),
      .addended => l10n.signedCaseVersionAddendum(date),
      .initial => l10n.signedCaseVersion(report.version),
    };
  }

  static String _shortDate(String iso, String language) {
    final at = nairobiTimeOf(iso);
    if (at == null) return '';
    return DateFormat('d MMM, h:mm a', language).format(at);
  }
}
