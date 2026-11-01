// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_code_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShareCodeModel _$ShareCodeModelFromJson(Map<String, dynamic> json) =>
    _ShareCodeModel(
      uid: json['uid'] as String? ?? '',
      caseUid: json['caseUid'] as String? ?? '',
      reportUid: json['reportUid'] as String? ?? '',
      purpose: json['purpose'] as String? ?? 'Join',
      createdByUid: json['createdByUid'] as String? ?? '',
      createdByRole: json['createdByRole'] as String? ?? '',
      recipientUid: json['recipientUid'] as String? ?? '',
      status: json['status'] as String? ?? 'Pending',
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      reissueCount: (json['reissueCount'] as num?)?.toInt() ?? 0,
      expiresAt: json['expiresAt'] as String? ?? '',
      redeemedAt: json['redeemedAt'] as String? ?? '',
      notificationUid: json['notificationUid'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
    );

Map<String, dynamic> _$ShareCodeModelToJson(_ShareCodeModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'caseUid': instance.caseUid,
      'reportUid': instance.reportUid,
      'purpose': instance.purpose,
      'createdByUid': instance.createdByUid,
      'createdByRole': instance.createdByRole,
      'recipientUid': instance.recipientUid,
      'status': instance.status,
      'attempts': instance.attempts,
      'reissueCount': instance.reissueCount,
      'expiresAt': instance.expiresAt,
      'redeemedAt': instance.redeemedAt,
      'notificationUid': instance.notificationUid,
      'createdAt': instance.createdAt,
      'lastUpdatedAt': instance.lastUpdatedAt,
    };
