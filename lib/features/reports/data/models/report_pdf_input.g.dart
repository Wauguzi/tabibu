// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_pdf_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PdfLine _$PdfLineFromJson(Map<String, dynamic> json) => _PdfLine(
  label: json['label'] as String? ?? '',
  value: json['value'] as String? ?? '',
);

Map<String, dynamic> _$PdfLineToJson(_PdfLine instance) => <String, dynamic>{
  'label': instance.label,
  'value': instance.value,
};

_PdfBlock _$PdfBlockFromJson(Map<String, dynamic> json) => _PdfBlock(
  sectionKey: json['sectionKey'] as String? ?? '',
  lines:
      (json['lines'] as List<dynamic>?)
          ?.map((e) => PdfLine.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <PdfLine>[],
);

Map<String, dynamic> _$PdfBlockToJson(_PdfBlock instance) => <String, dynamic>{
  'sectionKey': instance.sectionKey,
  'lines': instance.lines.map((e) => e.toJson()).toList(),
};

_PdfMeasurement _$PdfMeasurementFromJson(Map<String, dynamic> json) =>
    _PdfMeasurement(
      key: json['key'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );

Map<String, dynamic> _$PdfMeasurementToJson(_PdfMeasurement instance) =>
    <String, dynamic>{'key': instance.key, 'value': instance.value};

_PdfAddendum _$PdfAddendumFromJson(Map<String, dynamic> json) => _PdfAddendum(
  text: json['text'] as String? ?? '',
  signedAt: json['signedAt'] as String? ?? '',
);

Map<String, dynamic> _$PdfAddendumToJson(_PdfAddendum instance) =>
    <String, dynamic>{'text': instance.text, 'signedAt': instance.signedAt};

_PdfHeader _$PdfHeaderFromJson(Map<String, dynamic> json) => _PdfHeader(
  orderNumber: json['orderNumber'] as String? ?? '',
  testName: json['testName'] as String? ?? '',
  templateLabel: json['templateLabel'] as String? ?? '',
  version: (json['version'] as num?)?.toInt() ?? 0,
  stage: json['stage'] as String? ?? '',
  doctorName: json['doctorName'] as String? ?? '',
  doctorFacilityName: json['doctorFacilityName'] as String? ?? '',
  signedByFacilityName: json['signedByFacilityName'] as String? ?? '',
  sampleCollectedAt: json['sampleCollectedAt'] as String? ?? '',
  sampleReceivedAt: json['sampleReceivedAt'] as String? ?? '',
  labAccessionNo: json['labAccessionNo'] as String? ?? '',
  releasedAtLabel: json['releasedAtLabel'] as String? ?? '',
);

Map<String, dynamic> _$PdfHeaderToJson(_PdfHeader instance) =>
    <String, dynamic>{
      'orderNumber': instance.orderNumber,
      'testName': instance.testName,
      'templateLabel': instance.templateLabel,
      'version': instance.version,
      'stage': instance.stage,
      'doctorName': instance.doctorName,
      'doctorFacilityName': instance.doctorFacilityName,
      'signedByFacilityName': instance.signedByFacilityName,
      'sampleCollectedAt': instance.sampleCollectedAt,
      'sampleReceivedAt': instance.sampleReceivedAt,
      'labAccessionNo': instance.labAccessionNo,
      'releasedAtLabel': instance.releasedAtLabel,
    };

_PdfSubject _$PdfSubjectFromJson(Map<String, dynamic> json) => _PdfSubject(
  displayName: json['displayName'] as String? ?? '',
  ageYears: (json['ageYears'] as num?)?.toInt() ?? -1,
  ageMonths: (json['ageMonths'] as num?)?.toInt() ?? -1,
  sex: json['sex'] as String? ?? '',
  residence: json['residence'] as String? ?? '',
);

Map<String, dynamic> _$PdfSubjectToJson(_PdfSubject instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'ageYears': instance.ageYears,
      'ageMonths': instance.ageMonths,
      'sex': instance.sex,
      'residence': instance.residence,
    };

_PdfSignature _$PdfSignatureFromJson(Map<String, dynamic> json) =>
    _PdfSignature(
      title: json['title'] as String? ?? '',
      name: json['name'] as String? ?? '',
      kmpdcNumber: json['kmpdcNumber'] as String? ?? '',
      signedAtLabel: json['signedAtLabel'] as String? ?? '',
      contentRef: json['contentRef'] as String? ?? '',
      png:
          (json['png'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const <int>[],
    );

Map<String, dynamic> _$PdfSignatureToJson(_PdfSignature instance) =>
    <String, dynamic>{
      'title': instance.title,
      'name': instance.name,
      'kmpdcNumber': instance.kmpdcNumber,
      'signedAtLabel': instance.signedAtLabel,
      'contentRef': instance.contentRef,
      'png': instance.png,
    };

_PdfFooter _$PdfFooterFromJson(Map<String, dynamic> json) => _PdfFooter(
  patientName: json['patientName'] as String? ?? '',
  labAccessionNo: json['labAccessionNo'] as String? ?? '',
  supportContact: json['supportContact'] as String? ?? '',
);

Map<String, dynamic> _$PdfFooterToJson(_PdfFooter instance) =>
    <String, dynamic>{
      'patientName': instance.patientName,
      'labAccessionNo': instance.labAccessionNo,
      'supportContact': instance.supportContact,
    };

_ReportPdfInput _$ReportPdfInputFromJson(Map<String, dynamic> json) =>
    _ReportPdfInput(
      viewerRole: json['viewerRole'] as String? ?? '',
      header: json['header'] == null
          ? const PdfHeader()
          : PdfHeader.fromJson(json['header'] as Map<String, dynamic>),
      subject: json['subject'] == null
          ? const PdfSubject()
          : PdfSubject.fromJson(json['subject'] as Map<String, dynamic>),
      blocks:
          (json['blocks'] as List<dynamic>?)
              ?.map((e) => PdfBlock.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PdfBlock>[],
      measurements:
          (json['measurements'] as List<dynamic>?)
              ?.map((e) => PdfMeasurement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PdfMeasurement>[],
      addenda:
          (json['addenda'] as List<dynamic>?)
              ?.map((e) => PdfAddendum.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PdfAddendum>[],
      amendmentReason: json['amendmentReason'] as String? ?? '',
      isCritical: json['isCritical'] as bool? ?? false,
      signature: json['signature'] == null
          ? const PdfSignature()
          : PdfSignature.fromJson(json['signature'] as Map<String, dynamic>),
      translation:
          (json['translation'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const <String, String>{},
      translationApproverName: json['translationApproverName'] as String? ?? '',
      translationLanguage: json['translationLanguage'] as String? ?? '',
      watermark: json['watermark'] as String? ?? '',
      footer: json['footer'] == null
          ? const PdfFooter()
          : PdfFooter.fromJson(json['footer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReportPdfInputToJson(_ReportPdfInput instance) =>
    <String, dynamic>{
      'viewerRole': instance.viewerRole,
      'header': instance.header.toJson(),
      'subject': instance.subject.toJson(),
      'blocks': instance.blocks.map((e) => e.toJson()).toList(),
      'measurements': instance.measurements.map((e) => e.toJson()).toList(),
      'addenda': instance.addenda.map((e) => e.toJson()).toList(),
      'amendmentReason': instance.amendmentReason,
      'isCritical': instance.isCritical,
      'signature': instance.signature.toJson(),
      'translation': instance.translation,
      'translationApproverName': instance.translationApproverName,
      'translationLanguage': instance.translationLanguage,
      'watermark': instance.watermark,
      'footer': instance.footer.toJson(),
    };
