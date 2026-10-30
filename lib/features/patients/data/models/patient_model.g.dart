// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PatientModel _$PatientModelFromJson(Map<String, dynamic> json) =>
    _PatientModel(
      patientId: json['patientId'] as String,
      uid: json['uid'] as String,
      isRegistered: json['isRegistered'] as bool,
      createdByUid: json['createdByUid'] as String,
      firstName: json['firstName'] as String,
      middleName: json['middleName'] as String,
      lastName: json['lastName'] as String,
      sex: json['sex'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      profilePictureUrl: json['profilePictureUrl'] as String,
      county: json['county'] as String,
      subCounty: json['subCounty'] as String,
      geohash: json['geohash'] as String,
      doctorUids: (json['doctorUids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      fcmTokens: (json['fcmTokens'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      language: json['language'] as String,
      receiveNotifications: json['receiveNotifications'] as bool,
      casesReported: (json['casesReported'] as num).toInt(),
      appointmentsBooked: (json['appointmentsBooked'] as num).toInt(),
      createdAt: json['createdAt'] as String,
      lastUpdatedAt: json['lastUpdatedAt'] as String,
    );

Map<String, dynamic> _$PatientModelToJson(_PatientModel instance) =>
    <String, dynamic>{
      'patientId': instance.patientId,
      'uid': instance.uid,
      'isRegistered': instance.isRegistered,
      'createdByUid': instance.createdByUid,
      'firstName': instance.firstName,
      'middleName': instance.middleName,
      'lastName': instance.lastName,
      'sex': instance.sex,
      'dateOfBirth': instance.dateOfBirth,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'profilePictureUrl': instance.profilePictureUrl,
      'county': instance.county,
      'subCounty': instance.subCounty,
      'geohash': instance.geohash,
      'doctorUids': instance.doctorUids,
      'fcmTokens': instance.fcmTokens,
      'language': instance.language,
      'receiveNotifications': instance.receiveNotifications,
      'casesReported': instance.casesReported,
      'appointmentsBooked': instance.appointmentsBooked,
      'createdAt': instance.createdAt,
      'lastUpdatedAt': instance.lastUpdatedAt,
    };
