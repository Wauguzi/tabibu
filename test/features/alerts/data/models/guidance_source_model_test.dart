import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/alerts/data/models/guidance_source_hive.dart';
import 'package:tabibu/features/alerts/data/models/guidance_source_model.dart';

Map<String, dynamic> sourceJson() => {
  'sourceId': 'S1',
  'title': 'IDSR Handbook',
  'publisher': 'MoH',
  'url': 'https://example.com/s1',
  'publishedOn': '2024-01-01',
  'accessedOn': '2026-01-01',
};

void main() {
  group('GuidanceSourceModel', () {
    test('fromJson round-trips through toJson', () {
      final json = sourceJson();
      expect(GuidanceSourceModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = GuidanceSourceModel.fromJson({});
      expect(model.sourceId, '');
      expect(model.accessedOn, '');
    });
  });

  group('GuidanceSourceHive', () {
    test('fromModel maps every field and round-trips', () {
      final model = GuidanceSourceModel.fromJson(sourceJson());
      expect(GuidanceSourceHive.fromModel(model).toModel(), model);
    });
  });
}
