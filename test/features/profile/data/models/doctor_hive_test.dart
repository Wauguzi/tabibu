import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/profile/data/models/doctor_hive.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';

import 'doctor_model_test.dart' show doctorJson;

/// The generated [DoctorHiveAdapter] as it was before working-hours fields,
/// writing only Hive indices 0-29.
class _LegacyDoctorHiveAdapter extends TypeAdapter<DoctorHive> {
  @override
  final typeId = 1;

  @override
  DoctorHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DoctorHive(
      uid: fields[0] as String,
      title: fields[1] as String,
      firstName: fields[2] as String,
      lastName: fields[3] as String,
      email: fields[4] as String,
      phoneNumber: fields[5] as String,
      profilePictureUrl: fields[6] as String,
      isPathologist: fields[7] as bool,
      specialties: (fields[8] as List).cast<String>(),
      bio: fields[9] as String,
      kmpdcNumber: fields[10] as String,
      licenseUrls: (fields[11] as List).cast<String>(),
      verificationStatus: fields[12] as String,
      facilityId: fields[13] as String,
      facilityMflCode: fields[14] as String,
      facilityName: fields[15] as String,
      county: fields[16] as String,
      subCounty: fields[17] as String,
      geohash: fields[18] as String,
      isAvailable: fields[19] as bool,
      fcmTokens: (fields[20] as List).cast<String>(),
      language: fields[21] as String,
      receiveNotifications: fields[22] as bool,
      appointmentsHandled: (fields[23] as num).toInt(),
      ordersCreated: (fields[24] as num).toInt(),
      reportsSigned: (fields[25] as num).toInt(),
      termsAcceptedAt: fields[26] as String,
      createdAt: fields[27] as String,
      lastUpdatedAt: fields[28] as String,
      synced: fields[29] as bool,
      workingDays: const [1, 2, 3, 4, 5],
      dayStartMinute: 480,
      dayEndMinute: 1020,
      busySlots: const [],
    );
  }

  @override
  void write(BinaryWriter writer, DoctorHive obj) {
    writer
      ..writeByte(30)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.firstName)
      ..writeByte(3)
      ..write(obj.lastName)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.phoneNumber)
      ..writeByte(6)
      ..write(obj.profilePictureUrl)
      ..writeByte(7)
      ..write(obj.isPathologist)
      ..writeByte(8)
      ..write(obj.specialties)
      ..writeByte(9)
      ..write(obj.bio)
      ..writeByte(10)
      ..write(obj.kmpdcNumber)
      ..writeByte(11)
      ..write(obj.licenseUrls)
      ..writeByte(12)
      ..write(obj.verificationStatus)
      ..writeByte(13)
      ..write(obj.facilityId)
      ..writeByte(14)
      ..write(obj.facilityMflCode)
      ..writeByte(15)
      ..write(obj.facilityName)
      ..writeByte(16)
      ..write(obj.county)
      ..writeByte(17)
      ..write(obj.subCounty)
      ..writeByte(18)
      ..write(obj.geohash)
      ..writeByte(19)
      ..write(obj.isAvailable)
      ..writeByte(20)
      ..write(obj.fcmTokens)
      ..writeByte(21)
      ..write(obj.language)
      ..writeByte(22)
      ..write(obj.receiveNotifications)
      ..writeByte(23)
      ..write(obj.appointmentsHandled)
      ..writeByte(24)
      ..write(obj.ordersCreated)
      ..writeByte(25)
      ..write(obj.reportsSigned)
      ..writeByte(26)
      ..write(obj.termsAcceptedAt)
      ..writeByte(27)
      ..write(obj.createdAt)
      ..writeByte(28)
      ..write(obj.lastUpdatedAt)
      ..writeByte(29)
      ..write(obj.synced);
  }
}

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
      expect(hive.workingDays, model.workingDays);
      expect(hive.dayStartMinute, model.dayStartMinute);
      expect(hive.dayEndMinute, model.dayEndMinute);
      expect(hive.busySlots, model.busySlots);
      expect(hive.synced, model.synced);
    });

    test('toModel round-trips, keeping an unsynced row unsynced', () {
      final model = DoctorModel.fromJson(doctorJson()).copyWith(synced: false);
      final roundTripped = DoctorHive.fromModel(model).toModel();
      expect(roundTripped, model);
      expect(roundTripped.synced, isFalse);
      expect(roundTripped.workingDays, model.workingDays);
      expect(roundTripped.dayStartMinute, model.dayStartMinute);
      expect(roundTripped.dayEndMinute, model.dayEndMinute);
      expect(roundTripped.busySlots, model.busySlots);
    });

    test('an old cached row loads with working-hours defaults', () async {
      final dir = Directory.systemTemp.createTempSync('tabibu_doctor_hive_');
      Hive
        ..init(dir.path)
        ..registerAdapter(_LegacyDoctorHiveAdapter());

      const boxName = 'doctors_legacy';
      final box = await Hive.openBox<DoctorHive>(boxName);
      final written = DoctorHive.fromModel(
        DoctorModel.fromJson(doctorJson()).copyWith(
          workingDays: [7],
          dayStartMinute: 0,
          dayEndMinute: 1,
          busySlots: ['should-not-persist'],
        ),
      );
      await box.put('doctor-1', written);
      await box.close();

      Hive.registerAdapter(DoctorHiveAdapter(), override: true);
      final reopened = await Hive.openBox<DoctorHive>(boxName);
      final loaded = reopened.get('doctor-1')!;

      expect(loaded.uid, written.uid);
      expect(loaded.title, written.title);
      expect(loaded.firstName, written.firstName);
      expect(loaded.lastName, written.lastName);
      expect(loaded.email, written.email);
      expect(loaded.phoneNumber, written.phoneNumber);
      expect(loaded.profilePictureUrl, written.profilePictureUrl);
      expect(loaded.isPathologist, written.isPathologist);
      expect(loaded.specialties, written.specialties);
      expect(loaded.bio, written.bio);
      expect(loaded.kmpdcNumber, written.kmpdcNumber);
      expect(loaded.licenseUrls, written.licenseUrls);
      expect(loaded.verificationStatus, written.verificationStatus);
      expect(loaded.facilityId, written.facilityId);
      expect(loaded.facilityMflCode, written.facilityMflCode);
      expect(loaded.facilityName, written.facilityName);
      expect(loaded.county, written.county);
      expect(loaded.subCounty, written.subCounty);
      expect(loaded.geohash, written.geohash);
      expect(loaded.isAvailable, written.isAvailable);
      expect(loaded.fcmTokens, written.fcmTokens);
      expect(loaded.language, written.language);
      expect(loaded.receiveNotifications, written.receiveNotifications);
      expect(loaded.appointmentsHandled, written.appointmentsHandled);
      expect(loaded.ordersCreated, written.ordersCreated);
      expect(loaded.reportsSigned, written.reportsSigned);
      expect(loaded.termsAcceptedAt, written.termsAcceptedAt);
      expect(loaded.createdAt, written.createdAt);
      expect(loaded.lastUpdatedAt, written.lastUpdatedAt);
      expect(loaded.synced, written.synced);
      expect(loaded.workingDays, [1, 2, 3, 4, 5]);
      expect(loaded.dayStartMinute, 480);
      expect(loaded.dayEndMinute, 1020);
      expect(loaded.busySlots, isEmpty);

      await reopened.close();
      await Hive.close();
      dir.deleteSync(recursive: true);
    });
  });
}
