import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The report's signed measurements, formatted as the PDF formats them.
class ReportMeasurementsCard extends StatelessWidget {
  const ReportMeasurementsCard({required this.report, super.key});

  final PathologyReportModel report;

  @override
  Widget build(BuildContext context) => KeyValueCard(
    title: context.l10n.reportPdfMeasurements,
    rows: [for (final m in report.measurements) (m.key, m.formatted)],
  );
}
