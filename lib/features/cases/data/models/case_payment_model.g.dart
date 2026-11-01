// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CasePaymentModel _$CasePaymentModelFromJson(Map<String, dynamic> json) =>
    _CasePaymentModel(
      caseUid: json['caseUid'] as String? ?? '',
      method: json['method'] as String? ?? 'Cash',
      insurerId: json['insurerId'] as String? ?? '',
      insurerName: json['insurerName'] as String? ?? '',
      policyNumber: json['policyNumber'] as String? ?? '',
      createdByUid: json['createdByUid'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
    );

Map<String, dynamic> _$CasePaymentModelToJson(_CasePaymentModel instance) =>
    <String, dynamic>{
      'caseUid': instance.caseUid,
      'method': instance.method,
      'insurerId': instance.insurerId,
      'insurerName': instance.insurerName,
      'policyNumber': instance.policyNumber,
      'createdByUid': instance.createdByUid,
      'createdAt': instance.createdAt,
      'lastUpdatedAt': instance.lastUpdatedAt,
    };
