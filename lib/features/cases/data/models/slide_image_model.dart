import 'package:freezed_annotation/freezed_annotation.dart';

part 'slide_image_model.freezed.dart';
part 'slide_image_model.g.dart';

/// One registered slide image on a case; `path` is a Storage path, never a URL.
@freezed
abstract class SlideImageModel with _$SlideImageModel {
  const factory SlideImageModel({
    @JsonKey(name: 'imageUid') @Default('') String imageUid,
    @JsonKey(name: 'path') @Default('') String path,
    @JsonKey(name: 'contentType') @Default('') String contentType,
    @JsonKey(name: 'micronsPerPixel') @Default(0.0) double micronsPerPixel,
    @JsonKey(name: 'uploadedByUid') @Default('') String uploadedByUid,
    @JsonKey(name: 'uploadedAt') @Default('') String uploadedAt,
  }) = _SlideImageModel;

  factory SlideImageModel.fromJson(Map<String, dynamic> json) =>
      _$SlideImageModelFromJson(json);

  factory SlideImageModel.empty() => const SlideImageModel();
}
