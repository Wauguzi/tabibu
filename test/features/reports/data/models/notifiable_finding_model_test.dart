import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/reports/data/models/notifiable_finding_hive.dart';
import 'package:tabibu/features/reports/data/models/notifiable_finding_model.dart';

Map<String, dynamic> findingJson() => {
  'diseaseId': 'malaria',
  'alertRequested': true,
};

void main() {
  group('NotifiableFindingModel', () {
    test('fromJson round-trips through toJson', () {
      final json = findingJson();
      expect(NotifiableFindingModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = NotifiableFindingModel.fromJson({});
      expect(model.diseaseId, '');
      expect(model.alertRequested, isFalse);
    });
  });

  group('NotifiableFindingHive', () {
    test('fromModel maps every field and round-trips', () {
      final model = NotifiableFindingModel.fromJson(findingJson());
      expect(NotifiableFindingHive.fromModel(model).toModel(), model);
    });
  });
}
