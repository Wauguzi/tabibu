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

/// One section block on the PDF body. [sectionKey] is a [ReportSection]
/// wire value; the builder localises it, falling back to the key itself.
@freezed
abstract class PdfBlock with _$PdfBlock {
  // Nested lines must call toJson(); freezed puts this on the factory.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory PdfBlock({
    @JsonKey(name: 'sectionKey') @Default('') String sectionKey,
    @JsonKey(name: 'lines') @Default(<PdfLine>[]) List<PdfLine> lines,
  }) = _PdfBlock;

  const PdfBlock._();

  factory PdfBlock.fromJson(Map<String, dynamic> json) =>
      _$PdfBlockFromJson(json);

  factory PdfBlock.empty() => const PdfBlock();
}

/// One measurement row: the measure key as stored, and the formatted
/// value with its unit.
@freezed
abstract class PdfMeasurement with _$PdfMeasurement {
  const factory PdfMeasurement({
    @JsonKey(name: 'key') @Default('') String key,
    @JsonKey(name: 'value') @Default('') String value,
  }) = _PdfMeasurement;

  const PdfMeasurement._();

  factory PdfMeasurement.fromJson(Map<String, dynamic> json) =>
      _$PdfMeasurementFromJson(json);

  factory PdfMeasurement.empty() => const PdfMeasurement();
}

/// One signed addendum: its text and the ISO signing timestamp.
@freezed
abstract class PdfAddendum with _$PdfAddendum {
  const factory PdfAddendum({
    @JsonKey(name: 'text') @Default('') String text,
    @JsonKey(name: 'signedAt') @Default('') String signedAt,
  }) = _PdfAddendum;

  const PdfAddendum._();

  factory PdfAddendum.fromJson(Map<String, dynamic> json) =>
      _$PdfAddendumFromJson(json);

  factory PdfAddendum.empty() => const PdfAddendum();
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

    /// Completed years and leftover months at report time; both -1 when the
    /// date of birth is unknown or in the future.
    @JsonKey(name: 'ageYears') @Default(-1) int ageYears,
    @JsonKey(name: 'ageMonths') @Default(-1) int ageMonths,
    @JsonKey(name: 'sex') @Default('') String sex,
    @JsonKey(name: 'residence') @Default('') String residence,
  }) = _PdfSubject;

  const PdfSubject._();

  factory PdfSubject.fromJson(Map<String, dynamic> json) =>
      _$PdfSubjectFromJson(json);

  factory PdfSubject.empty() => const PdfSubject();

  /// Completed years and leftover months from [dateOfBirth] ISO string to
  /// [now]; (-1, -1) when the string is invalid or in the future.
  static ({int years, int months}) ageFromDateOfBirth(
    String dateOfBirth,
    DateTime now,
  ) {
    const unknown = (years: -1, months: -1);
    final born = DateTime.tryParse(dateOfBirth);
    if (born == null) return unknown;
    var years = now.year - born.year;
    var months = now.month - born.month;
    if (now.day < born.day) months -= 1;
    if (months < 0) {
      years -= 1;
      months += 12;
    }
    if (years < 0) return unknown;
    return (years: years, months: months);
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
    /// Wire value from [ActorRole] (`'Doctor'`, `'Patient'`, …), never
    /// [Role.name]: anything else reads as the patient (fail closed).
    @JsonKey(name: 'viewerRole') @Default('') String viewerRole,
    @JsonKey(name: 'header') @Default(PdfHeader()) PdfHeader header,
    @JsonKey(name: 'subject') @Default(PdfSubject()) PdfSubject subject,
    @JsonKey(name: 'blocks') @Default(<PdfBlock>[]) List<PdfBlock> blocks,
    @JsonKey(name: 'measurements')
    @Default(<PdfMeasurement>[])
    List<PdfMeasurement> measurements,
    @JsonKey(name: 'addenda')
    @Default(<PdfAddendum>[])
    List<PdfAddendum> addenda,
    @JsonKey(name: 'amendmentReason') @Default('') String amendmentReason,
    @JsonKey(name: 'isCritical') @Default(false) bool isCritical,
    @JsonKey(name: 'signature') @Default(PdfSignature()) PdfSignature signature,
    @JsonKey(name: 'translation')
    @Default(<String, String>{})
    Map<String, String> translation,
    @JsonKey(name: 'translationApproverName')
    @Default('')
    String translationApproverName,
    @JsonKey(name: 'translationLanguage')
    @Default('')
    String translationLanguage,
    @JsonKey(name: 'watermark') @Default('') String watermark,
    @JsonKey(name: 'footer') @Default(PdfFooter()) PdfFooter footer,
  }) = _ReportPdfInput;

  const ReportPdfInput._();

  factory ReportPdfInput.fromJson(Map<String, dynamic> json) =>
      _$ReportPdfInputFromJson(json);

  factory ReportPdfInput.empty() => const ReportPdfInput();

  /// Builds PDF input from a signed report, or throws [AppError] when refused.
  factory ReportPdfInput.fromSignedReport({
    required PathologyReportModel report,
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

    // Unknown roles read as the patient: failing closed keeps the release
    // gate for callers that pass Role.name ('patient') or a typo instead of
    // the wire value.
    final role = ActorRole.values.any((r) => r.value == viewerRole)
        ? ActorRole.fromValue(viewerRole)
        : ActorRole.patient;
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
        sectionKey: ReportSection.diagnosis.value,
        lines: [PdfLine(label: report.diagnosisType, value: report.diagnosis)],
      ),
      PdfBlock(
        sectionKey: ReportSection.comments.value,
        lines: [PdfLine(value: report.comments)],
      ),
      PdfBlock(
        sectionKey: ReportSection.clinicalNotes.value,
        lines: [PdfLine(value: clinicalNotes)],
      ),
      ...reportBlocksFromResponses(report.responses),
    ];
    final age = PdfSubject.ageFromDateOfBirth(dateOfBirth, now);

    return ReportPdfInput(
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
        ageYears: age.years,
        ageMonths: age.months,
        sex: sex,
        residence: residence,
      ),
      blocks: blocks,
      measurements: report.measurements
          .map((m) => PdfMeasurement(key: m.key, value: m.formatted))
          .toList(),
      addenda: report.addenda
          .map((a) => PdfAddendum(text: a.text, signedAt: a.signedAt))
          .toList(),
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
      translationApproverName: translation?.approverName ?? '',
      translationLanguage: translation?.language ?? '',
      footer: PdfFooter(
        patientName: patientDisplayName,
        labAccessionNo: report.labAccessionNo,
        supportContact: supportContact,
      ),
    );
  }
}

/// The responses grouped into one block per section, in the PDF's order.
List<PdfBlock> reportBlocksFromResponses(List<ReportResponseModel> responses) {
  // Question order restarts in every section, so sections sort by their
  // enum position (every template lists them in that order) and only then
  // by question order; an unknown section goes last.
  int rank(String section) {
    final known = ReportSection.values.where((s) => s.value == section);
    return known.isEmpty ? ReportSection.values.length : known.first.index;
  }

  final sorted = responses.toList()
    ..sort((a, b) {
      final bySection = rank(a.section).compareTo(rank(b.section));
      return bySection != 0 ? bySection : a.order.compareTo(b.order);
    });
  final bySection = <String, List<PdfLine>>{};
  final order = <String>[];
  for (final response in sorted) {
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
    for (final key in order) PdfBlock(sectionKey: key, lines: bySection[key]!),
  ];
}
