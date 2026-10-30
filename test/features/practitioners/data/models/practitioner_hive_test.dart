import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_hive.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';

import 'practitioner_model_test.dart' show practitionerJson;

void main() {
  group('PractitionerHive', () {
    test('fromModel maps every field in order', () {
      final model = PractitionerModel.fromJson(practitionerJson());
      final hive = PractitionerHive.fromModel(model);
      expect(hive.uid, model.uid);
      expect(hive.title, model.title);
      expect(hive.isPathologist, model.isPathologist);
      expect(hive.facilityName, model.facilityName);
      expect(hive.isAvailable, model.isAvailable);
      expect(hive.reportsSigned, model.reportsSigned);
      expect(hive.lastUpdatedAt, model.lastUpdatedAt);
      expect(hive.synced, model.synced);
    });

    test('toModel round-trips, keeping an unsynced row unsynced', () {
      final model = PractitionerModel.fromJson(
        practitionerJson(),
      ).copyWith(synced: false);
      final roundTripped = PractitionerHive.fromModel(model).toModel();
      expect(roundTripped, model);
      expect(roundTripped.synced, isFalse);
    });
  });
}
