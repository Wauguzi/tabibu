// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DoctorModel _$DoctorModelFromJson(Map<String, dynamic> json) => _DoctorModel(
  uid: json['uid'] as String,
  title: json['title'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String,
  phoneNumber: json['phoneNumber'] as String,
  profilePictureUrl: json['profilePictureUrl'] as String,
  isPathologist: json['isPathologist'] as bool,
  specialization: json['specialization'] as String,
  bio: json['bio'] as String,
  kmpdcNumber: json['kmpdcNumber'] as String,
  licenseUrl: json['licenseUrl'] as String,
  verificationStatus: json['verificationStatus'] as String,
  facilityId: json['facilityId'] as String,
  facilityMflCode: json['facilityMflCode'] as String,
  facilityName: json['facilityName'] as String,
  county: json['county'] as String,
  subCounty: json['subCounty'] as String,
  geohash: json['geohash'] as String,
  isAvailable: json['isAvailable'] as bool,
  fcmTokens: (json['fcmTokens'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  language: json['language'] as String,
  receiveNotifications: json['receiveNotifications'] as bool,
  appointmentsHandled: (json['appointmentsHandled'] as num).toInt(),
  ordersCreated: (json['ordersCreated'] as num).toInt(),
  reportsSigned: (json['reportsSigned'] as num).toInt(),
  termsAcceptedAt: json['termsAcceptedAt'] as String,
  createdAt: json['createdAt'] as String,
  lastUpdatedAt: json['lastUpdatedAt'] as String,
);

Map<String, dynamic> _$DoctorModelToJson(_DoctorModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'title': instance.title,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'profilePictureUrl': instance.profilePictureUrl,
      'isPathologist': instance.isPathologist,
      'specialization': instance.specialization,
      'bio': instance.bio,
      'kmpdcNumber': instance.kmpdcNumber,
      'licenseUrl': instance.licenseUrl,
      'verificationStatus': instance.verificationStatus,
      'facilityId': instance.facilityId,
      'facilityMflCode': instance.facilityMflCode,
      'facilityName': instance.facilityName,
      'county': instance.county,
      'subCounty': instance.subCounty,
      'geohash': instance.geohash,
      'isAvailable': instance.isAvailable,
      'fcmTokens': instance.fcmTokens,
      'language': instance.language,
      'receiveNotifications': instance.receiveNotifications,
      'appointmentsHandled': instance.appointmentsHandled,
      'ordersCreated': instance.ordersCreated,
      'reportsSigned': instance.reportsSigned,
      'termsAcceptedAt': instance.termsAcceptedAt,
      'createdAt': instance.createdAt,
      'lastUpdatedAt': instance.lastUpdatedAt,
    };
