import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/services/report_labels.dart';
import 'package:tabibu/features/reports/presentation/widgets/report_text_card.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The signed diagnosis, with its type, and the comments when there are any.
/// Both are the pathologist's words, untouched.
class ReportDiagnosisCard extends StatelessWidget {
  const ReportDiagnosisCard({required this.report, super.key});

  final PathologyReportModel report;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final section = reportSectionLabel(l10n, ReportSection.diagnosis.value);
    final type = reportDiagnosisTypeLabel(l10n, report.diagnosisType);
    return ReportTextCard(
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
      ],
    );
  }
}
