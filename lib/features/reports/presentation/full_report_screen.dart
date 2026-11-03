import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/models/report_pdf_input.dart';
import 'package:tabibu/features/reports/data/services/report_labels.dart';
import 'package:tabibu/features/reports/presentation/widgets/report_dates.dart';
import 'package:tabibu/features/reports/presentation/widgets/report_diagnosis_card.dart';
import 'package:tabibu/features/reports/presentation/widgets/report_footer_notices.dart';
import 'package:tabibu/features/reports/presentation/widgets/report_measurements_card.dart';
import 'package:tabibu/features/reports/presentation/widgets/report_reader_scaffold.dart';
import 'package:tabibu/features/reports/presentation/widgets/report_signed_banner.dart';
import 'package:tabibu/features/reports/presentation/widgets/report_text_card.dart';
import 'package:tabibu/l10n/l10n.dart';

/// D-REPORT-FULL. Every part of the signed report as the PDF carries it, with
/// the PDF's labels. No download or share here.
class FullReportScreen extends StatelessWidget {
  const FullReportScreen({required this.caseUid, super.key});

  final String caseUid;

  @override
  Widget build(BuildContext context) =>
      ReportReaderScaffold(caseUid: caseUid, bodyBuilder: _cards);

  List<Widget> _cards(
    BuildContext context,
    PathologyReportModel report,
    CaseModel? caseModel,
  ) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final patientName = caseModel?.patientName ?? '';
    final blocks = reportBlocksFromResponses(report.responses);
    return [
      ReportSignedBanner(report: report),
      KeyValueCard(
        title: l10n.doctorReportSpecimen,
        rows: _specimenRows(context, report, caseModel, locale),
      ),
      ReportDiagnosisCard(report: report),
      for (final block in blocks)
        ReportTextCard(
          title: reportSectionLabel(l10n, block.sectionKey),
          entries: [
            for (final line in block.lines)
              (reportQuestionLabel(l10n, line.label), line.value),
          ],
        ),
      if (report.measurements.isNotEmpty)
        ReportMeasurementsCard(report: report),
      for (final addendum in report.addenda)
        ReportTextCard(
          title: l10n.reportPdfAddendum(
            reportDateTimeLabel(addendum.signedAt, locale, withYear: true),
          ),
          entries: [(addendum.signedByName, addendum.text)],
        ),
      ReportFooterNotices(report: report, patientName: patientName),
    ];
  }

  List<(String, String)> _specimenRows(
    BuildContext context,
    PathologyReportModel report,
    CaseModel? caseModel,
    String locale,
  ) {
    final l10n = context.l10n;
    final orderNumber = caseModel?.orderNumber.isNotEmpty == true
        ? caseModel!.orderNumber
        : report.orderNumber;
    final name = caseModel?.patientName ?? '';
    final age = caseModel?.patientAgeYears ?? 0;
    final sex = Sex.fromValue(caseModel?.patientSex ?? '')?.description(l10n);
    final who = name.isEmpty
        ? ''
        : age > 0
        ? l10n.doctorReportPatientLine(name, age, orderNumber)
        : [name, orderNumber].where((p) => p.isNotEmpty).join(' · ');
    final patient = [who, ?sex].where((part) => part.isNotEmpty).join(' · ');
    final collected = reportDateTimeLabel(
      report.sampleCollectedAt,
      locale,
      withYear: true,
    );
    final received = reportDateTimeLabel(
      report.sampleReceivedAt,
      locale,
      withYear: true,
    );
    return [
      if (patient.isNotEmpty) (l10n.reportPdfPatient, patient),
      if (collected.isNotEmpty) (l10n.reportPdfCollected, collected),
      if (received.isNotEmpty) (l10n.reportPdfReceived, received),
      if (report.labAccessionNo.isNotEmpty)
        (l10n.doctorReportLabNumber, report.labAccessionNo),
    ];
  }
}
