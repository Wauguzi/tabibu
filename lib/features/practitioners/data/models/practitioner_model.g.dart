// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practitioner_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PractitionerModel _$PractitionerModelFromJson(Map<String, dynamic> json) =>
    _PractitionerModel(
      uid: json['uid'] as String,
      title: json['title'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      profilePictureUrl: json['profilePictureUrl'] as String,
      isPathologist: json['isPathologist'] as bool,
      specialization: json['specialization'] as String,
      bio: json['bio'] as String,
      facilityId: json['facilityId'] as String,
      facilityMflCode: json['facilityMflCode'] as String,
      facilityName: json['facilityName'] as String,
      county: json['county'] as String,
      subCounty: json['subCounty'] as String,
      geohash: json['geohash'] as String,
      isAvailable: json['isAvailable'] as bool,
      appointmentsHandled: (json['appointmentsHandled'] as num).toInt(),
      ordersCreated: (json['ordersCreated'] as num).toInt(),
      reportsSigned: (json['reportsSigned'] as num).toInt(),
      lastUpdatedAt: json['lastUpdatedAt'] as String,
    );

Map<String, dynamic> _$PractitionerModelToJson(_PractitionerModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'title': instance.title,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'profilePictureUrl': instance.profilePictureUrl,
      'isPathologist': instance.isPathologist,
      'specialization': instance.specialization,
      'bio': instance.bio,
      'facilityId': instance.facilityId,
      'facilityMflCode': instance.facilityMflCode,
      'facilityName': instance.facilityName,
      'county': instance.county,
      'subCounty': instance.subCounty,
      'geohash': instance.geohash,
      'isAvailable': instance.isAvailable,
      'appointmentsHandled': instance.appointmentsHandled,
      'ordersCreated': instance.ordersCreated,
      'reportsSigned': instance.reportsSigned,
      'lastUpdatedAt': instance.lastUpdatedAt,
    };
