import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// What sits under a signed report: the neutral provenance line, and, until
/// the patient may see the report, the private notice. [patientName] is the
/// patient's full name, shortened here to the first name.
class ReportFooterNotices extends StatelessWidget {
  const ReportFooterNotices({
    required this.report,
    required this.patientName,
    super.key,
  });

  final PathologyReportModel report;
  final String patientName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final first = patientName.trim().split(RegExp(r'\s+')).first;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        NoticeCard(
          icon: Assets.icons.infoIcon,
          variant: .neutral,
          body: l10n.doctorReportFootnote,
        ),
        if (!report.releasedToPatient) ...[
          const SizedBox(height: AppSpacing.sm),
          NoticeCard(
            icon: Assets.icons.passwordIcon,
            variant: .private,
            title: l10n.doctorReportPrivacyTitle(
              first.isEmpty ? l10n.reportPdfPatient : first,
            ),
            body: l10n.doctorReportPrivacyBody,
          ),
        ],
      ],
    );
  }
}
