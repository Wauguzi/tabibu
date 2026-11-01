// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_addendum_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReportAddendumModel _$ReportAddendumModelFromJson(Map<String, dynamic> json) =>
    _ReportAddendumModel(
      uid: json['uid'] as String? ?? '',
      text: json['text'] as String? ?? '',
      reportVersion: (json['reportVersion'] as num?)?.toInt() ?? 0,
      signedByUid: json['signedByUid'] as String? ?? '',
      signedByName: json['signedByName'] as String? ?? '',
      signedAt: json['signedAt'] as String? ?? '',
    );

Map<String, dynamic> _$ReportAddendumModelToJson(
  _ReportAddendumModel instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'text': instance.text,
  'reportVersion': instance.reportVersion,
  'signedByUid': instance.signedByUid,
  'signedByName': instance.signedByName,
  'signedAt': instance.signedAt,
};
