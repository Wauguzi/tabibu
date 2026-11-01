import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_hive.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';

import 'practitioner_model_test.dart' show practitionerJson;

/// The generated [PractitionerHiveAdapter] as it was before working-hours
/// fields, writing only Hive indices 0-19.
class _LegacyPractitionerHiveAdapter extends TypeAdapter<PractitionerHive> {
  @override
  final typeId = 2;

  @override
  PractitionerHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PractitionerHive(
      uid: fields[0] as String,
      title: fields[1] as String,
      firstName: fields[2] as String,
      lastName: fields[3] as String,
      profilePictureUrl: fields[4] as String,
      isPathologist: fields[5] as bool,
      specialties: (fields[6] as List).cast<String>(),
      bio: fields[7] as String,
      facilityId: fields[8] as String,
      facilityMflCode: fields[9] as String,
      facilityName: fields[10] as String,
      county: fields[11] as String,
      subCounty: fields[12] as String,
      geohash: fields[13] as String,
      isAvailable: fields[14] as bool,
      appointmentsHandled: (fields[15] as num).toInt(),
      ordersCreated: (fields[16] as num).toInt(),
      reportsSigned: (fields[17] as num).toInt(),
      lastUpdatedAt: fields[18] as String,
      synced: fields[19] as bool,
      workingDays: const [1, 2, 3, 4, 5],
      dayStartMinute: 480,
      dayEndMinute: 1020,
      busySlots: const [],
    );
  }

  @override
  void write(BinaryWriter writer, PractitionerHive obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.firstName)
      ..writeByte(3)
      ..write(obj.lastName)
      ..writeByte(4)
      ..write(obj.profilePictureUrl)
      ..writeByte(5)
      ..write(obj.isPathologist)
      ..writeByte(6)
      ..write(obj.specialties)
      ..writeByte(7)
      ..write(obj.bio)
      ..writeByte(8)
      ..write(obj.facilityId)
      ..writeByte(9)
      ..write(obj.facilityMflCode)
      ..writeByte(10)
      ..write(obj.facilityName)
      ..writeByte(11)
      ..write(obj.county)
      ..writeByte(12)
      ..write(obj.subCounty)
      ..writeByte(13)
      ..write(obj.geohash)
      ..writeByte(14)
      ..write(obj.isAvailable)
      ..writeByte(15)
      ..write(obj.appointmentsHandled)
      ..writeByte(16)
      ..write(obj.ordersCreated)
      ..writeByte(17)
      ..write(obj.reportsSigned)
      ..writeByte(18)
      ..write(obj.lastUpdatedAt)
      ..writeByte(19)
      ..write(obj.synced);
  }
}

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
      expect(hive.workingDays, model.workingDays);
      expect(hive.dayStartMinute, model.dayStartMinute);
      expect(hive.dayEndMinute, model.dayEndMinute);
      expect(hive.busySlots, model.busySlots);
      expect(hive.synced, model.synced);
    });

    test('toModel round-trips, keeping an unsynced row unsynced', () {
      final model = PractitionerModel.fromJson(
        practitionerJson(),
      ).copyWith(synced: false);
      final roundTripped = PractitionerHive.fromModel(model).toModel();
      expect(roundTripped, model);
      expect(roundTripped.synced, isFalse);
      expect(roundTripped.workingDays, model.workingDays);
      expect(roundTripped.dayStartMinute, model.dayStartMinute);
      expect(roundTripped.dayEndMinute, model.dayEndMinute);
      expect(roundTripped.busySlots, model.busySlots);
    });

    test('an old cached row loads with working-hours defaults', () async {
      final dir = Directory.systemTemp.createTempSync(
        'tabibu_practitioner_hive_',
      );
      Hive
        ..init(dir.path)
        ..registerAdapter(_LegacyPractitionerHiveAdapter());

      const boxName = 'practitioners_legacy';
      final box = await Hive.openBox<PractitionerHive>(boxName);
      final written = PractitionerHive.fromModel(
        PractitionerModel.fromJson(practitionerJson()).copyWith(
          workingDays: [7],
          dayStartMinute: 0,
          dayEndMinute: 1,
          busySlots: ['should-not-persist'],
        ),
      );
      await box.put('doctor-1', written);
      await box.close();

      Hive.registerAdapter(PractitionerHiveAdapter(), override: true);
      final reopened = await Hive.openBox<PractitionerHive>(boxName);
      final loaded = reopened.get('doctor-1')!;

      expect(loaded.uid, written.uid);
      expect(loaded.title, written.title);
      expect(loaded.firstName, written.firstName);
      expect(loaded.lastName, written.lastName);
      expect(loaded.profilePictureUrl, written.profilePictureUrl);
      expect(loaded.isPathologist, written.isPathologist);
      expect(loaded.specialties, written.specialties);
      expect(loaded.bio, written.bio);
      expect(loaded.facilityId, written.facilityId);
      expect(loaded.facilityMflCode, written.facilityMflCode);
      expect(loaded.facilityName, written.facilityName);
      expect(loaded.county, written.county);
      expect(loaded.subCounty, written.subCounty);
      expect(loaded.geohash, written.geohash);
      expect(loaded.isAvailable, written.isAvailable);
      expect(loaded.appointmentsHandled, written.appointmentsHandled);
      expect(loaded.ordersCreated, written.ordersCreated);
      expect(loaded.reportsSigned, written.reportsSigned);
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
