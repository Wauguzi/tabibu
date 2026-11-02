// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slide_image_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SlideImageModel _$SlideImageModelFromJson(Map<String, dynamic> json) =>
    _SlideImageModel(
      imageUid: json['imageUid'] as String? ?? '',
      path: json['path'] as String? ?? '',
      contentType: json['contentType'] as String? ?? '',
      micronsPerPixel: (json['micronsPerPixel'] as num?)?.toDouble() ?? 0.0,
      uploadedByUid: json['uploadedByUid'] as String? ?? '',
      uploadedAt: json['uploadedAt'] as String? ?? '',
    );

Map<String, dynamic> _$SlideImageModelToJson(_SlideImageModel instance) =>
    <String, dynamic>{
      'imageUid': instance.imageUid,
      'path': instance.path,
      'contentType': instance.contentType,
      'micronsPerPixel': instance.micronsPerPixel,
      'uploadedByUid': instance.uploadedByUid,
      'uploadedAt': instance.uploadedAt,
    };
