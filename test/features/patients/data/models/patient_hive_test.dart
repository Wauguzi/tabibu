import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/patients/data/models/patient_hive.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';

import 'patient_model_test.dart' show patientJson;

void main() {
  group('PatientHive', () {
    test('fromModel maps every field in order', () {
      final model = PatientModel.fromJson(patientJson());
      final hive = PatientHive.fromModel(model);
      expect(hive.patientId, model.patientId);
      expect(hive.uid, model.uid);
      expect(hive.isRegistered, model.isRegistered);
      expect(hive.sex, model.sex);
      expect(hive.doctorUids, model.doctorUids);
      expect(hive.language, model.language);
      expect(hive.casesReported, model.casesReported);
      expect(hive.lastUpdatedAt, model.lastUpdatedAt);
      expect(hive.synced, model.synced);
    });

    test('toModel round-trips, keeping an unsynced row unsynced', () {
      final model = PatientModel.fromJson(
        patientJson(),
      ).copyWith(synced: false);
      final roundTripped = PatientHive.fromModel(model).toModel();
      expect(roundTripped, model);
      expect(roundTripped.synced, isFalse);
    });
  });
}
