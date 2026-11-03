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
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/services/report_labels.dart';
import 'package:tabibu/features/reports/presentation/widgets/report_text_card.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// CS-08's signed half (H-4): the chips, the banner, the signed report
/// verbatim, the provenance footnote, and the compare link for the signer
/// only. No AI panel, no draft frame, no heatmap, no change count.
class SignedCaseView extends StatelessWidget {
  const SignedCaseView({
    required this.report,
    required this.caseModel,
    super.key,
  });

  final PathologyReportModel report;
  final CaseModel caseModel;

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
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        NoticeCard(
          variant: .neutral,
          icon: Assets.icons.infoIcon,
          body: l10n.signedCaseDraftKept,
        ),
        if (report.pathologistUid == me) ...[
          const SizedBox(height: AppSpacing.lg),
          TabibuButton.secondary(
            label: l10n.signedCaseCompare,
            onTap: () =>
                CompareRoute(caseUid: caseModel.uid).push<void>(context),
          ),
        ],
      ],
    );
  }
}
