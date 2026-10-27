// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_county_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubCountyModel _$SubCountyModelFromJson(Map<String, dynamic> json) =>
    _SubCountyModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      countyId: (json['countyId'] as num).toInt(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      geohash: json['geohash'] as String,
    );

Map<String, dynamic> _$SubCountyModelToJson(_SubCountyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'countyId': instance.countyId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'geohash': instance.geohash,
    };
