import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/cases/data/models/slide_image_model.dart';

part 'slide_image_hive.g.dart';

/// Cached [SlideImageModel], in the same field order.
@HiveType(typeId: 6)
class SlideImageHive {
  SlideImageHive({
    required this.imageUid,
    required this.path,
    required this.contentType,
    required this.micronsPerPixel,
    required this.uploadedByUid,
    required this.uploadedAt,
  });

  factory SlideImageHive.fromModel(SlideImageModel model) {
    return SlideImageHive(
      imageUid: model.imageUid,
      path: model.path,
      contentType: model.contentType,
      micronsPerPixel: model.micronsPerPixel,
      uploadedByUid: model.uploadedByUid,
      uploadedAt: model.uploadedAt,
    );
  }

  SlideImageModel toModel() {
    return SlideImageModel(
      imageUid: imageUid,
      path: path,
      contentType: contentType,
      micronsPerPixel: micronsPerPixel,
      uploadedByUid: uploadedByUid,
      uploadedAt: uploadedAt,
    );
  }

  @HiveField(0)
  final String imageUid;

  @HiveField(1)
  final String path;

  @HiveField(2)
  final String contentType;

  @HiveField(3)
  final double micronsPerPixel;

  @HiveField(4)
  final String uploadedByUid;

  @HiveField(5)
  final String uploadedAt;
}
