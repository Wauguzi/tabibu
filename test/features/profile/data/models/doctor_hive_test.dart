import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/profile/data/models/doctor_hive.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';

import 'doctor_model_test.dart' show doctorJson;

void main() {
  group('DoctorHive', () {
    test('fromModel maps every field in order', () {
      final model = DoctorModel.fromJson(doctorJson());
      final hive = DoctorHive.fromModel(model);
      expect(hive.uid, model.uid);
      expect(hive.title, model.title);
      expect(hive.isPathologist, model.isPathologist);
      expect(hive.verificationStatus, model.verificationStatus);
      expect(hive.facilityId, model.facilityId);
      expect(hive.fcmTokens, model.fcmTokens);
      expect(hive.reportsSigned, model.reportsSigned);
      expect(hive.termsAcceptedAt, model.termsAcceptedAt);
      expect(hive.synced, model.synced);
    });

    test('toModel round-trips, keeping an unsynced row unsynced', () {
      final model = DoctorModel.fromJson(doctorJson()).copyWith(synced: false);
      final roundTripped = DoctorHive.fromModel(model).toModel();
      expect(roundTripped, model);
      expect(roundTripped.synced, isFalse);
    });
  });
}
