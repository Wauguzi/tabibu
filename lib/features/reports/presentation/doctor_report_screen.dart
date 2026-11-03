import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/reports/presentation/widgets/explanation_review_section.dart';
import 'package:tabibu/features/reports/presentation/widgets/report_diagnosis_card.dart';
import 'package:tabibu/features/reports/presentation/widgets/report_footer_notices.dart';
import 'package:tabibu/features/reports/presentation/widgets/report_measurements_card.dart';
import 'package:tabibu/features/reports/presentation/widgets/report_reader_scaffold.dart';
import 'package:tabibu/features/reports/presentation/widgets/report_signed_banner.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// D-REPORT-SUMMARY. The case's signed report as its doctor reads it: who
/// signed it, the diagnosis and comments, the measurements. The report is
/// signed and human-made; the AI explanations appear only in the review
/// section at the bottom (R-4), each in its draft frame until approved.
class DoctorReportScreen extends StatelessWidget {
  const DoctorReportScreen({required this.caseUid, super.key});

  final String caseUid;

  Future<void> _openOptions(BuildContext context) async {
    final l10n = context.l10n;
    final open = await showOptionsSheet<bool>(
      context,
      title: l10n.reportPdfTitle,
      actions: [
        OptionsAction(
          value: true,
          icon: Assets.icons.documentIcon,
          label: l10n.doctorReportOpenFull,
          supporting: l10n.doctorReportOpenFullSubtitle,
        ),
      ],
    );
    if (open != true || !context.mounted) return;
    await FullReportRoute(caseUid: caseUid).push<void>(context);
  }

  @override
  Widget build(BuildContext context) => ReportReaderScaffold(
    caseUid: caseUid,
    trailing: MoreButton(
      semanticLabel: context.l10n.notificationsMoreLabel,
      onTap: () => _openOptions(context),
    ),
    bodyBuilder: (context, report, caseModel) => [
      ReportSignedBanner(report: report),
      ReportDiagnosisCard(report: report),
      if (report.measurements.isNotEmpty)
        ReportMeasurementsCard(report: report),
      ReportFooterNotices(
        report: report,
        patientName: caseModel?.patientName ?? '',
      ),
      ExplanationReviewSection(
        caseUid: caseUid,
        patientName: caseModel?.patientName ?? '',
      ),
    ],
  );
}
