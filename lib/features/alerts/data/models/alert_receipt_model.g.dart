// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_receipt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AlertReceiptModel _$AlertReceiptModelFromJson(Map<String, dynamic> json) =>
    _AlertReceiptModel(
      alertUid: json['alertUid'] as String? ?? '',
      readAt: json['readAt'] as String? ?? '',
      lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
    );

Map<String, dynamic> _$AlertReceiptModelToJson(_AlertReceiptModel instance) =>
    <String, dynamic>{
      'alertUid': instance.alertUid,
      'readAt': instance.readAt,
      'lastUpdatedAt': instance.lastUpdatedAt,
    };
