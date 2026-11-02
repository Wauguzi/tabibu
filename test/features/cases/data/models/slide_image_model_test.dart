import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/cases/data/models/slide_image_hive.dart';
import 'package:tabibu/features/cases/data/models/slide_image_model.dart';

Map<String, dynamic> slideImageJson() => {
  'imageUid': 'uid-image-1',
  'path': 'cases/uid-case-1/slides/uid-image-1.tiff',
  'contentType': 'image/tiff',
  'micronsPerPixel': 0.25,
  'uploadedByUid': 'uid-doctor-1',
  'uploadedAt': '2030-05-01T10:00:00.000Z',
};

void main() {
  group('SlideImageModel', () {
    test('fromJson parses a full row and round-trips through toJson', () {
      final json = slideImageJson();
      final model = SlideImageModel.fromJson(json);
      expect(model.imageUid, 'uid-image-1');
      expect(model.micronsPerPixel, 0.25);
      expect(model.toJson(), json);
    });

    test('a row missing every key reads the defaults', () {
      final model = SlideImageModel.fromJson({});
      expect(model, SlideImageModel.empty());
    });
  });

  group('SlideImageHive', () {
    test('fromModel maps every field', () {
      final hive = SlideImageHive.fromModel(
        SlideImageModel.fromJson(slideImageJson()),
      );
      expect(hive.imageUid, 'uid-image-1');
      expect(hive.path, 'cases/uid-case-1/slides/uid-image-1.tiff');
      expect(hive.contentType, 'image/tiff');
      expect(hive.micronsPerPixel, 0.25);
      expect(hive.uploadedByUid, 'uid-doctor-1');
      expect(hive.uploadedAt, '2030-05-01T10:00:00.000Z');
    });

    test('toModel round-trips', () {
      final model = SlideImageModel.fromJson(slideImageJson());
      expect(SlideImageHive.fromModel(model).toModel(), model);
    });
  });
}
