// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facility_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FacilityModel _$FacilityModelFromJson(Map<String, dynamic> json) =>
    _FacilityModel(
      facilityId: json['facilityId'] as String,
      mflCode: json['mflCode'] as String,
      name: json['name'] as String,
      kephLevel: json['kephLevel'] as String,
      facilityType: json['facilityType'] as String,
      owner: json['owner'] as String,
      wardId: (json['wardId'] as num).toInt(),
      ward: json['ward'] as String,
      subCountyId: (json['subCountyId'] as num).toInt(),
      subCounty: json['subCounty'] as String,
      countyId: (json['countyId'] as num).toInt(),
      county: json['county'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      geohash: json['geohash'] as String,
      isLocationApproximate: json['isLocationApproximate'] as bool,
      isLab: json['isLab'] as bool,
      operationStatus: json['operationStatus'] as String,
      isOperational: json['isOperational'] as bool,
    );

Map<String, dynamic> _$FacilityModelToJson(_FacilityModel instance) =>
    <String, dynamic>{
      'facilityId': instance.facilityId,
      'mflCode': instance.mflCode,
      'name': instance.name,
      'kephLevel': instance.kephLevel,
      'facilityType': instance.facilityType,
      'owner': instance.owner,
      'wardId': instance.wardId,
      'ward': instance.ward,
      'subCountyId': instance.subCountyId,
      'subCounty': instance.subCounty,
      'countyId': instance.countyId,
      'county': instance.county,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'geohash': instance.geohash,
      'isLocationApproximate': instance.isLocationApproximate,
      'isLab': instance.isLab,
      'operationStatus': instance.operationStatus,
      'isOperational': instance.isOperational,
    };
