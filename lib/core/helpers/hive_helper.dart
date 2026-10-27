// ignore_for_file: document_ignores, avoid_catches_without_on_clauses

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tabibu/core/helpers/db_helper.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/utils/sync_cursor.dart';
import 'package:tabibu/features/auth/data/models/onboarding_hive.dart';
import 'package:tabibu/features/patients/data/models/patient_hive.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_hive.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/features/profile/data/models/doctor_hive.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';

/// The offline cache (architecture §6). Reads are scoped to the signed-in
/// person; there is no unscoped read of patients.
abstract class HiveHelper {
  Future<void> initBoxes();

  /// Deletes every encrypted box and rotates the key, because a clinic phone
  /// is often shared (§6, T-11). Device preferences survive.
  Future<void> clearOnSignOut();

  /// Called with the signed-in uid before a session's first cached read. A
  /// cache filled for someone else (a session that ended without a sign-out:
  /// an expired token, a deleted account, a killed app) is wiped first, so
  /// one person never opens another's rows on a shared device.
  Future<void> scopeTo(String uid);

  // Device preferences (unencrypted; not health data).
  Future<OnboardingHive?> getCachedOnboarding();
  Future<void> cacheOnboarding({required bool isOnboarded});
  Future<void> updateLanguage({required String languageString});

  /// [fromCloud] rows never replace an unsynced local edit, and only replace
  /// an older row.
  Future<void> cachePatients(
    List<PatientModel> patients, {
    required bool fromCloud,
  });

  /// The record whose `uid` is [uid]: a patient's own.
  Future<PatientModel?> getCachedOwnPatientRecord(String uid);

  /// Records whose care team includes [doctorUid].
  Future<List<PatientModel>> getCachedCarePatients(String doctorUid);

  /// Delta cursor for [doctorUid]'s care list, or null to pull everything.
  Future<String?> carePatientsCursor(String doctorUid);

  Future<void> cacheDoctorProfile(
    DoctorModel doctor, {
    required bool fromCloud,
  });
  Future<DoctorModel?> getCachedDoctorProfile(String uid);

  Future<void> cachePractitioners(
    List<PractitionerModel> practitioners, {
    required bool fromCloud,
  });
  Future<List<PractitionerModel>> getCachedPractitioners();
  Future<String?> practitionersCursor();
}

@Singleton(as: HiveHelper)
class HiveHelperImpl implements HiveHelper {
  HiveHelperImpl({DBHelper? dbHelper, FlutterSecureStorage? secureStorage})
    : _db = dbHelper ?? getIt<DBHelper>(),
      _secureStorage = secureStorage ?? getIt<FlutterSecureStorage>(),
      _initHive = Hive.initFlutter;

  /// Tests run Hive against a temporary directory instead.
  @visibleForTesting
  HiveHelperImpl.withInit({
    required this._initHive,
    DBHelper? dbHelper,
    FlutterSecureStorage? secureStorage,
  }) : _db = dbHelper ?? getIt<DBHelper>(),
       _secureStorage = secureStorage ?? getIt<FlutterSecureStorage>();

  final DBHelper _db;
  final FlutterSecureStorage _secureStorage;
  final Future<void> Function() _initHive;
  final Logger _logger = Logger();

  static const patientsBox = 'patients';
  static const doctorProfileBox = 'doctorProfile';
  static const practitionersBox = 'practitioners';
  static const onboardingBox = 'onboarding';
  static const _onboardingKey = 'device';

  /// Everything holding a person's data. A box added here needs its case in
  /// `DBHelper.deleteAll`, or deleting it throws.
  static const Map<Type, String> _encryptedBoxes = {
    PatientHive: patientsBox,
    DoctorHive: doctorProfileBox,
    PractitionerHive: practitionersBox,
  };

  static const _keyName = 'hiveKey';
  static const _ownerName = 'hiveOwnerUid';

  // A corrupted Keystore entry can deadlock the platform channel instead of
  // throwing, which would leave the app on the native splash (§15 rule 2).
  static const _secureStorageTimeout = Duration(seconds: 5);

  // What Android's plugin returns after it wiped itself on a decryption
  // failure; a status message, never a key.
  static const _secureStorageResetSentinel = 'Data has been reset';

  @override
  Future<void> initBoxes() async {
    await _initHive();
    _registerAdapters();
    await Hive.openBox<OnboardingHive>(onboardingBox);

    HiveAesCipher cipher;
    try {
      cipher = await _cipher(rotate: false);
    } catch (e) {
      // An unreadable key cannot decrypt the boxes either.
      if (kDebugMode) _logger.w('Hive key unreadable, rotating: $e');
      await _db.deleteAll(_encryptedBoxes);
      cipher = await _cipher(rotate: true);
    }

    try {
      await _openEncryptedBoxes(cipher);
    } catch (e) {
      if (kDebugMode) _logger.w('Hive boxes unreadable, recreating: $e');
      await _db.deleteAll(_encryptedBoxes);
      await _openEncryptedBoxes(cipher);
    }
  }

  void _registerAdapters() {
    // Hand-maintained on purpose: the generated registrar is imported by
    // nothing (hive_adapter_registration_test.dart).
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PatientHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DoctorHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(PractitionerHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(OnboardingHiveAdapter());
    }
  }

  Future<void> _openEncryptedBoxes(HiveAesCipher cipher) async {
    await Hive.openBox<PatientHive>(patientsBox, encryptionCipher: cipher);
    await Hive.openBox<DoctorHive>(doctorProfileBox, encryptionCipher: cipher);
    await Hive.openBox<PractitionerHive>(
      practitionersBox,
      encryptionCipher: cipher,
    );
  }

  Future<HiveAesCipher> _cipher({required bool rotate}) async {
    if (!rotate) {
      final stored = await _secureStorage
          .read(key: _keyName)
          .timeout(_secureStorageTimeout);
      if (stored != null && stored != _secureStorageResetSentinel) {
        final key = base64Decode(stored);
        if (key.length != 32) {
          throw StateError('Hive key has ${key.length} bytes, expected 32.');
        }
        return HiveAesCipher(key);
      }
    }

    try {
      await _secureStorage.delete(key: _keyName).timeout(_secureStorageTimeout);
    } catch (_) {
      // The entry may already be gone or unreadable; a new one replaces it.
    }
    final key = Hive.generateSecureKey();
    await _secureStorage
        .write(key: _keyName, value: base64Encode(key))
        .timeout(_secureStorageTimeout);
    return HiveAesCipher(key);
  }

  @override
  Future<void> clearOnSignOut() async {
    // A box cleared but kept would still be encrypted with the old key, so
    // the boxes are deleted, not cleared, before the key rotates.
    await _db.deleteAll(_encryptedBoxes);
    await _openEncryptedBoxes(await _cipher(rotate: true));
    await _secureStorage.delete(key: _ownerName).timeout(_secureStorageTimeout);
  }

  @override
  Future<void> scopeTo(String uid) async {
    final owner = await _secureStorage
        .read(key: _ownerName)
        .timeout(_secureStorageTimeout);
    if (owner == uid) return;
    if (owner != null) await clearOnSignOut();
    await _secureStorage
        .write(key: _ownerName, value: uid)
        .timeout(_secureStorageTimeout);
  }

  @override
  Future<OnboardingHive?> getCachedOnboarding() =>
      _db.get<OnboardingHive>(onboardingBox, _onboardingKey);

  @override
  Future<void> cacheOnboarding({required bool isOnboarded}) async {
    final existing = await getCachedOnboarding();
    await _db.put<OnboardingHive>(
      onboardingBox,
      _onboardingKey,
      OnboardingHive(
        isOnboarded: isOnboarded,
        languageString: existing?.languageString ?? '',
      ),
    );
  }

  @override
  Future<void> updateLanguage({required String languageString}) async {
    final existing = await getCachedOnboarding();
    await _db.put<OnboardingHive>(
      onboardingBox,
      _onboardingKey,
      OnboardingHive(
        isOnboarded: existing?.isOnboarded ?? false,
        languageString: languageString,
      ),
    );
  }

  /// Whether [incoming] may replace [cached] (sync rule, §6).
  bool _accepts({
    required bool fromCloud,
    required ({bool synced, String lastUpdatedAt})? cached,
    required String incoming,
  }) =>
      !fromCloud ||
      cached == null ||
      cloudRowWins(
        cachedSynced: cached.synced,
        cachedLastUpdatedAt: cached.lastUpdatedAt,
        incomingLastUpdatedAt: incoming,
      );

  @override
  Future<void> cachePatients(
    List<PatientModel> patients, {
    required bool fromCloud,
  }) async {
    final cached = {
      for (final row in await _db.getAll<PatientHive>(patientsBox))
        row.patientId: (synced: row.synced, lastUpdatedAt: row.lastUpdatedAt),
    };
    await _db.putAll<PatientHive>(patientsBox, {
      for (final p in patients)
        if (_accepts(
          fromCloud: fromCloud,
          cached: cached[p.patientId],
          incoming: p.lastUpdatedAt,
        ))
          p.patientId: PatientHive.fromModel(
            fromCloud ? p.copyWith(synced: true) : p,
          ),
    });
  }

  @override
  Future<PatientModel?> getCachedOwnPatientRecord(String uid) async {
    if (uid.isEmpty) return null;
    for (final row in await _db.getAll<PatientHive>(patientsBox)) {
      if (row.uid == uid) return row.toModel();
    }
    return null;
  }

  @override
  Future<List<PatientModel>> getCachedCarePatients(String doctorUid) async {
    if (doctorUid.isEmpty) return const [];
    return [
      for (final row in await _db.getAll<PatientHive>(patientsBox))
        if (row.doctorUids.contains(doctorUid)) row.toModel(),
    ];
  }

  @override
  Future<String?> carePatientsCursor(String doctorUid) async => syncCursorFrom(
    (await getCachedCarePatients(doctorUid)).map((p) => p.lastUpdatedAt),
  );

  @override
  Future<void> cacheDoctorProfile(
    DoctorModel doctor, {
    required bool fromCloud,
  }) async {
    final row = await _db.get<DoctorHive>(doctorProfileBox, doctor.uid);
    if (!_accepts(
      fromCloud: fromCloud,
      cached: row == null
          ? null
          : (synced: row.synced, lastUpdatedAt: row.lastUpdatedAt),
      incoming: doctor.lastUpdatedAt,
    )) {
      return;
    }
    await _db.put<DoctorHive>(
      doctorProfileBox,
      doctor.uid,
      DoctorHive.fromModel(fromCloud ? doctor.copyWith(synced: true) : doctor),
    );
  }

  @override
  Future<DoctorModel?> getCachedDoctorProfile(String uid) async => uid.isEmpty
      ? null
      : (await _db.get<DoctorHive>(doctorProfileBox, uid))?.toModel();

  @override
  Future<void> cachePractitioners(
    List<PractitionerModel> practitioners, {
    required bool fromCloud,
  }) async {
    final cached = {
      for (final row in await _db.getAll<PractitionerHive>(practitionersBox))
        row.uid: (synced: row.synced, lastUpdatedAt: row.lastUpdatedAt),
    };
    await _db.putAll<PractitionerHive>(practitionersBox, {
      for (final p in practitioners)
        if (_accepts(
          fromCloud: fromCloud,
          cached: cached[p.uid],
          incoming: p.lastUpdatedAt,
        ))
          p.uid: PractitionerHive.fromModel(
            fromCloud ? p.copyWith(synced: true) : p,
          ),
    });
  }

  @override
  Future<List<PractitionerModel>> getCachedPractitioners() async => [
    for (final row in await _db.getAll<PractitionerHive>(practitionersBox))
      row.toModel(),
  ];

  @override
  Future<String?> practitionersCursor() async => syncCursorFrom(
    (await getCachedPractitioners()).map((p) => p.lastUpdatedAt),
  );
}
