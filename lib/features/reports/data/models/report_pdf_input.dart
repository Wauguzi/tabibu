import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/models/report_response_model.dart';
import 'package:tabibu/features/reports/data/models/report_text_approved_model.dart';

part 'report_pdf_input.freezed.dart';
part 'report_pdf_input.g.dart';

/// One labelled line on a PDF block.
@freezed
abstract class PdfLine with _$PdfLine {
  const factory PdfLine({
    @JsonKey(name: 'label') @Default('') String label,
    @JsonKey(name: 'value') @Default('') String value,
  }) = _PdfLine;

  const PdfLine._();

  factory PdfLine.fromJson(Map<String, dynamic> json) =>
      _$PdfLineFromJson(json);

  factory PdfLine.empty() => const PdfLine();
}

/// A titled block of lines on the PDF body.
@freezed
abstract class PdfBlock with _$PdfBlock {
  // Nested lines must call toJson(); freezed puts this on the factory.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory PdfBlock({
    @JsonKey(name: 'title') @Default('') String title,
    @JsonKey(name: 'lines') @Default(<PdfLine>[]) List<PdfLine> lines,
  }) = _PdfBlock;

  const PdfBlock._();

  factory PdfBlock.fromJson(Map<String, dynamic> json) =>
      _$PdfBlockFromJson(json);

  factory PdfBlock.empty() => const PdfBlock();
}

/// Header fields shown at the top of a signed report PDF.
@freezed
abstract class PdfHeader with _$PdfHeader {
  const factory PdfHeader({
    @JsonKey(name: 'orderNumber') @Default('') String orderNumber,
    @JsonKey(name: 'testName') @Default('') String testName,
    @JsonKey(name: 'templateLabel') @Default('') String templateLabel,
    @JsonKey(name: 'version') @Default(0) int version,

    /// The stage's wire value (`Initial`, `Addended`, `Amended`); the PDF
    /// builder localises it.
    @JsonKey(name: 'stage') @Default('') String stage,
    @JsonKey(name: 'doctorName') @Default('') String doctorName,
    @JsonKey(name: 'doctorFacilityName') @Default('') String doctorFacilityName,
    @JsonKey(name: 'signedByFacilityName')
    @Default('')
    String signedByFacilityName,
    @JsonKey(name: 'sampleCollectedAt') @Default('') String sampleCollectedAt,
    @JsonKey(name: 'sampleReceivedAt') @Default('') String sampleReceivedAt,
    @JsonKey(name: 'labAccessionNo') @Default('') String labAccessionNo,
    @JsonKey(name: 'releasedAtLabel') @Default('') String releasedAtLabel,
  }) = _PdfHeader;

  const PdfHeader._();

  factory PdfHeader.fromJson(Map<String, dynamic> json) =>
      _$PdfHeaderFromJson(json);

  factory PdfHeader.empty() => const PdfHeader();
}

/// Patient subject block on a signed report PDF.
@freezed
abstract class PdfSubject with _$PdfSubject {
  const factory PdfSubject({
    @JsonKey(name: 'displayName') @Default('') String displayName,
    @JsonKey(name: 'ageLabel') @Default('') String ageLabel,
    @JsonKey(name: 'sex') @Default('') String sex,
    @JsonKey(name: 'residence') @Default('') String residence,
  }) = _PdfSubject;

  const PdfSubject._();

  factory PdfSubject.fromJson(Map<String, dynamic> json) =>
      _$PdfSubjectFromJson(json);

  factory PdfSubject.empty() => const PdfSubject();

  /// Years and months from [dateOfBirth] ISO string to [now].
  static String ageLabelFromDateOfBirth(String dateOfBirth, DateTime now) {
    final born = DateTime.tryParse(dateOfBirth);
    if (born == null) return '';
    var years = now.year - born.year;
    var months = now.month - born.month;
    if (now.day < born.day) months -= 1;
    if (months < 0) {
      years -= 1;
      months += 12;
    }
    if (years < 0) return '';
    return '$years years $months months';
  }
}

/// Signer block on a signed report PDF.
@freezed
abstract class PdfSignature with _$PdfSignature {
  const factory PdfSignature({
    @JsonKey(name: 'title') @Default('') String title,
    @JsonKey(name: 'name') @Default('') String name,
    @JsonKey(name: 'kmpdcNumber') @Default('') String kmpdcNumber,
    @JsonKey(name: 'signedAtLabel') @Default('') String signedAtLabel,
    @JsonKey(name: 'contentRef') @Default('') String contentRef,
    @JsonKey(name: 'png') @Default(<int>[]) List<int> png,
  }) = _PdfSignature;

  const PdfSignature._();

  factory PdfSignature.fromJson(Map<String, dynamic> json) =>
      _$PdfSignatureFromJson(json);

  factory PdfSignature.empty() => const PdfSignature();
}

/// Footer fields on a signed report PDF.
@freezed
abstract class PdfFooter with _$PdfFooter {
  const factory PdfFooter({
    @JsonKey(name: 'patientName') @Default('') String patientName,
    @JsonKey(name: 'labAccessionNo') @Default('') String labAccessionNo,
    @JsonKey(name: 'pageLabel') @Default('') String pageLabel,
    @JsonKey(name: 'disclaimer') @Default('') String disclaimer,
    @JsonKey(name: 'supportContact') @Default('') String supportContact,
  }) = _PdfFooter;

  const PdfFooter._();

  factory PdfFooter.fromJson(Map<String, dynamic> json) =>
      _$PdfFooterFromJson(json);

  factory PdfFooter.empty() => const PdfFooter();
}

/// In-memory PDF layout input. Never cached.
@freezed
abstract class ReportPdfInput with _$ReportPdfInput {
  // Nested value objects must call toJson(); freezed puts this on the factory.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory ReportPdfInput({
    @JsonKey(name: 'locale') @Default('en') String locale,
    @JsonKey(name: 'viewerRole') @Default('') String viewerRole,
    @JsonKey(name: 'header') @Default(PdfHeader()) PdfHeader header,
    @JsonKey(name: 'subject') @Default(PdfSubject()) PdfSubject subject,
    @JsonKey(name: 'blocks') @Default(<PdfBlock>[]) List<PdfBlock> blocks,
    @JsonKey(name: 'measurements')
    @Default(<String>[])
    List<String> measurements,
    @JsonKey(name: 'addenda') @Default(<String>[]) List<String> addenda,
    @JsonKey(name: 'amendmentReason') @Default('') String amendmentReason,
    @JsonKey(name: 'isCritical') @Default(false) bool isCritical,
    @JsonKey(name: 'signature') @Default(PdfSignature()) PdfSignature signature,
    @JsonKey(name: 'translation')
    @Default(<String, String>{})
    Map<String, String> translation,
    @JsonKey(name: 'watermark') @Default('') String watermark,
    @JsonKey(name: 'footer') @Default(PdfFooter()) PdfFooter footer,
    @JsonKey(name: 'generatedAtLabel') @Default('') String generatedAtLabel,
  }) = _ReportPdfInput;

  const ReportPdfInput._();

  factory ReportPdfInput.fromJson(Map<String, dynamic> json) =>
      _$ReportPdfInputFromJson(json);

  factory ReportPdfInput.empty() => const ReportPdfInput();

  /// Builds PDF input from a signed report, or throws [AppError] when refused.
  factory ReportPdfInput.fromSignedReport({
    required PathologyReportModel report,
    required String locale,
    required String viewerRole,
    required String viewerUid,
    required String patientUid,
    required String patientDisplayName,
    required String dateOfBirth,
    required String sex,
    required String county,
    required String subCounty,
    required String doctorName,
    required String doctorFacilityName,
    required String clinicalNotes,
    required String disclaimer,
    required String generatedAtLabel,
    required DateTime now,
    bool isDraft = false,
    ReportTextApprovedModel? translation,
    List<int> signaturePng = const [],
    String supportContact = '',
  }) {
    if (isDraft) {
      throw AppError.dataNotFound;
    }
    if (report.statusValue != ReportStatus.signed) {
      throw AppError.dataNotFound;
    }

    final role = ActorRole.fromValue(viewerRole);
    final isReportReader = report.isReader(viewerUid);
    final isReleasedPatient =
        role == ActorRole.patient &&
        viewerUid == patientUid &&
        report.releasedToPatient;

    if (role == ActorRole.patient && !report.releasedToPatient) {
      throw AppError.permissionDenied;
    }
    if (!isReportReader && !isReleasedPatient) {
      throw AppError.permissionDenied;
    }

    // Without its source hash a translation can't be tied to this version.
    if (translation != null &&
        (translation.sourceSha256.isEmpty ||
            translation.sourceSha256 != report.contentSha256)) {
      throw AppError.permissionDenied;
    }

    final residence = [
      county,
      subCounty,
    ].where((part) => part.isNotEmpty).join(', ');

    final blocks = <PdfBlock>[
      PdfBlock(
        title: 'Diagnosis',
        lines: [PdfLine(label: report.diagnosisType, value: report.diagnosis)],
      ),
      PdfBlock(
        title: 'Comments',
        lines: [PdfLine(value: report.comments)],
      ),
      PdfBlock(
        title: 'Clinical notes',
        lines: [PdfLine(value: clinicalNotes)],
      ),
      ..._blocksFromResponses(report.responses),
    ];

    return ReportPdfInput(
      locale: locale,
      viewerRole: viewerRole,
      header: PdfHeader(
        orderNumber: report.orderNumber,
        testName: report.testName,
        templateLabel: report.templateKey,
        version: report.version,
        stage: report.stageValue.value,
        doctorName: doctorName,
        doctorFacilityName: doctorFacilityName,
        signedByFacilityName: report.signedByFacilityName,
        sampleCollectedAt: report.sampleCollectedAt,
        sampleReceivedAt: report.sampleReceivedAt,
        labAccessionNo: report.labAccessionNo,
        releasedAtLabel: report.releasedAt,
      ),
      subject: PdfSubject(
        displayName: patientDisplayName,
        ageLabel: PdfSubject.ageLabelFromDateOfBirth(dateOfBirth, now),
        sex: sex,
        residence: residence,
      ),
      blocks: blocks,
      measurements: report.measurements.map((m) => m.formatted).toList(),
      addenda: report.addenda.map((a) => a.text).toList(),
      amendmentReason: report.amendmentReason,
      isCritical: report.isCritical,
      signature: PdfSignature(
        title: report.signedByTitle,
        name: report.signedByName,
        kmpdcNumber: report.signedByKmpdcNumber,
        signedAtLabel: report.signedAt,
        contentRef: report.contentSha256,
        png: signaturePng,
      ),
      translation: translation?.approvedText ?? const {},
      footer: PdfFooter(
        patientName: patientDisplayName,
        labAccessionNo: report.labAccessionNo,
        disclaimer: disclaimer,
        supportContact: supportContact,
      ),
      generatedAtLabel: generatedAtLabel,
    );
  }
}

List<PdfBlock> _blocksFromResponses(List<ReportResponseModel> responses) {
  final bySection = <String, List<PdfLine>>{};
  final order = <String>[];
  for (final response in responses) {
    final key = response.section.isEmpty ? 'Other' : response.section;
    if (!bySection.containsKey(key)) {
      order.add(key);
      bySection[key] = [];
    }
    bySection[key]!.add(
      PdfLine(label: response.question, value: response.answer),
    );
  }
  return [
    for (final key in order) PdfBlock(title: key, lines: bySection[key]!),
  ];
}
