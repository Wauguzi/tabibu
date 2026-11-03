import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/presentation/widgets/report_dates.dart';
import 'package:tabibu/l10n/l10n.dart';

/// Who signed the report, where and when. It carries no AI wording: the
/// signed banner is the only mark on a signed report.
class ReportSignedBanner extends StatelessWidget {
  const ReportSignedBanner({required this.report, super.key});

  final PathologyReportModel report;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final signer = [
      report.signedByTitle,
      report.signedByName,
    ].where((part) => part.isNotEmpty).join(' ');
    final signedAt = reportDateTimeLabel(
      report.signedAt,
      Localizations.localeOf(context).languageCode,
    );
    final lab = report.signedByFacilityName;
    final body = lab.isEmpty || signedAt.isEmpty
        ? '$lab$signedAt'
        : l10n.doctorReportSignedAt(lab, signedAt);
    return NoticeCard(
      variant: .signed,
      title: l10n.doctorReportSignedBy(signer),
      body: body,
    );
  }
}
