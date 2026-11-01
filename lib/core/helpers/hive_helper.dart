// ignore_for_file: document_ignores, avoid_catches_without_on_clauses

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tabibu/core/helpers/db_helper.dart';
import 'package:tabibu/core/utils/sync_cursor.dart';
import 'package:tabibu/features/alerts/data/models/alert_clinician_brief_hive.dart';
import 'package:tabibu/features/alerts/data/models/alert_receipt_hive.dart';
import 'package:tabibu/features/alerts/data/models/alert_text_hive.dart';
import 'package:tabibu/features/alerts/data/models/guidance_bullet_hive.dart';
import 'package:tabibu/features/alerts/data/models/guidance_source_hive.dart';
import 'package:tabibu/features/alerts/data/models/public_alert_hive.dart';
import 'package:tabibu/features/appointments/data/models/appointment_hive.dart';
import 'package:tabibu/features/appointments/data/models/appointment_intake_hive.dart';
import 'package:tabibu/features/appointments/data/models/intake_draft_hive.dart';
import 'package:tabibu/features/auth/data/models/onboarding_hive.dart';
import 'package:tabibu/features/cases/data/models/case_hive.dart';
import 'package:tabibu/features/cases/data/models/case_log_entry_hive.dart';
import 'package:tabibu/features/cases/data/models/case_payment_hive.dart';
import 'package:tabibu/features/cases/data/models/notes_translation_hive.dart';
import 'package:tabibu/features/cases/data/models/ordered_test_hive.dart';
import 'package:tabibu/features/cases/data/models/risk_check_hive.dart';
import 'package:tabibu/features/cases/data/models/share_code_hive.dart';
import 'package:tabibu/features/cases/data/models/slide_image_hive.dart';
import 'package:tabibu/features/conversations/data/models/case_summary_hive.dart';
import 'package:tabibu/features/conversations/data/models/conversation_cursor_hive.dart';
import 'package:tabibu/features/conversations/data/models/conversation_hive.dart';
import 'package:tabibu/features/conversations/data/models/conversation_member_hive.dart';
import 'package:tabibu/features/conversations/data/models/message_hive.dart';
import 'package:tabibu/features/conversations/data/models/message_preview_hive.dart';
import 'package:tabibu/features/conversations/data/models/message_transcript_hive.dart';
import 'package:tabibu/features/notifications/data/models/notification_hive.dart';
import 'package:tabibu/features/notifications/data/models/notification_metadata_hive.dart';
import 'package:tabibu/features/patients/data/models/patient_hive.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_hive.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/features/profile/data/models/doctor_hive.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';
import 'package:tabibu/features/reports/data/models/notifiable_finding_hive.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_hive.dart';
import 'package:tabibu/features/reports/data/models/preread_score_hive.dart';
import 'package:tabibu/features/reports/data/models/report_addendum_hive.dart';
import 'package:tabibu/features/reports/data/models/report_draft_hive.dart';
import 'package:tabibu/features/reports/data/models/report_measurement_hive.dart';
import 'package:tabibu/features/reports/data/models/report_response_hive.dart';
import 'package:tabibu/features/reports/data/models/report_text_approved_hive.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_hive.dart';

/// The offline cache (architecture §6). Reads are scoped to the signed-in
/// person; there is no unscoped read of patients.
abstract class HiveHelper {
  Future<void> initBoxes();

  /// The messages box, opened on first use rather than before runApp.
  Future<LazyBox<MessageHive>> messagesBox();

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
  HiveHelperImpl({required DBHelper dbHelper, required this._secureStorage})
    : _db = dbHelper,
      _initHive = Hive.initFlutter;

  /// Tests run Hive against a temporary directory instead.
  @visibleForTesting
  HiveHelperImpl.withInit({
    required this._initHive,
    required DBHelper dbHelper,
    required this._secureStorage,
  }) : _db = dbHelper;

  final DBHelper _db;
  final FlutterSecureStorage _secureStorage;
  final Future<void> Function() _initHive;
  final Logger _logger = Logger();
  Future<LazyBox<MessageHive>>? _messagesBox;

  static const patientsBox = 'patients';
  static const doctorProfileBox = 'doctorProfile';
  static const practitionersBox = 'practitioners';
  static const onboardingBox = 'onboarding';
  static const _onboardingKey = 'device';

  // Cases.
  static const casesBox = 'cases';
  static const caseLogsBox = 'caseLogs';
  static const casePaymentsBox = 'casePayments';
  static const shareCodesBox = 'shareCodes';
  static const riskChecksBox = 'riskChecks';
  static const notesTranslationsBox = 'notesTranslations';

  // Reports.
  static const pathologyReportsBox = 'pathologyReports';
  static const reportDraftsBox = 'reportDrafts';
  static const prereadScoresBox = 'prereadScores';
  static const worklistBox = 'worklist';
  static const reportTextsBox = 'reportTexts';

  // Appointments.
  static const appointmentsBox = 'appointments';
  static const appointmentIntakesBox = 'appointmentIntakes';

  // Conversations.
  static const conversationsBox = 'conversations';
  static const conversationCursorsBox = 'conversationCursors';
  static const messagesBoxName = 'messages';
  static const messageTranscriptsBox = 'messageTranscripts';

  // Notifications.
  static const notificationsBox = 'notifications';

  // Alerts.
  static const publicAlertsBox = 'publicAlerts';
  static const alertClinicianBriefsBox = 'alertClinicianBriefs';
  static const alertReceiptsBox = 'alertReceipts';

  /// Voice notes and images cached as files; wiped on sign-out (T-11).
  static const _mediaCacheDirName = 'tabibu_media';

  /// Everything holding a person's data. A box added here needs its case in
  /// `DBHelper.deleteAll`, or deleting it throws.
  static const Map<Type, String> _encryptedBoxes = {
    PatientHive: patientsBox,
    DoctorHive: doctorProfileBox,
    PractitionerHive: practitionersBox,
    // Cases.
    CaseHive: casesBox,
    CaseLogEntryHive: caseLogsBox,
    CasePaymentHive: casePaymentsBox,
    ShareCodeHive: shareCodesBox,
    RiskCheckHive: riskChecksBox,
    NotesTranslationHive: notesTranslationsBox,
    // Reports.
    PathologyReportHive: pathologyReportsBox,
    ReportDraftHive: reportDraftsBox,
    PrereadScoreHive: prereadScoresBox,
    WorklistEntryHive: worklistBox,
    ReportTextApprovedHive: reportTextsBox,
    // Appointments.
    AppointmentHive: appointmentsBox,
    AppointmentIntakeHive: appointmentIntakesBox,
    // Conversations.
    ConversationHive: conversationsBox,
    ConversationCursorHive: conversationCursorsBox,
    MessageHive: messagesBoxName,
    MessageTranscriptHive: messageTranscriptsBox,
    // Notifications.
    NotificationHive: notificationsBox,
    // Alerts.
    PublicAlertHive: publicAlertsBox,
    AlertClinicianBriefHive: alertClinicianBriefsBox,
    AlertReceiptHive: alertReceiptsBox,
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
    _messagesBox = null;
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
    if (!Hive.isAdapterRegistered(41)) {
      Hive.registerAdapter(NotificationMetadataHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(40)) {
      Hive.registerAdapter(NotificationHiveAdapter());
    }
    // Nested types first: each before the type that holds it.
    if (!Hive.isAdapterRegistered(47)) {
      Hive.registerAdapter(AlertTextHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(48)) {
      Hive.registerAdapter(GuidanceBulletHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(49)) {
      Hive.registerAdapter(GuidanceSourceHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(50)) {
      Hive.registerAdapter(AlertClinicianBriefHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(46)) {
      Hive.registerAdapter(PublicAlertHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(51)) {
      Hive.registerAdapter(AlertReceiptHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(OrderedTestHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(SlideImageHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(CasePaymentHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(ShareCodeHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(RiskCheckHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(NotesTranslationHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(CaseLogEntryHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(CaseHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(33)) {
      Hive.registerAdapter(ConversationMemberHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(34)) {
      Hive.registerAdapter(CaseSummaryHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(36)) {
      Hive.registerAdapter(MessagePreviewHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(37)) {
      Hive.registerAdapter(ConversationCursorHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(38)) {
      Hive.registerAdapter(MessageTranscriptHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(35)) {
      Hive.registerAdapter(MessageHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(32)) {
      Hive.registerAdapter(ConversationHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(17)) {
      Hive.registerAdapter(ReportResponseHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(18)) {
      Hive.registerAdapter(ReportAddendumHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(19)) {
      Hive.registerAdapter(ReportMeasurementHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(52)) {
      Hive.registerAdapter(NotifiableFindingHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(16)) {
      Hive.registerAdapter(PathologyReportHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter(ReportDraftHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(21)) {
      Hive.registerAdapter(PrereadScoreHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(22)) {
      Hive.registerAdapter(WorklistEntryHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(23)) {
      Hive.registerAdapter(ReportTextApprovedHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(26)) {
      Hive.registerAdapter(IntakeDraftHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(25)) {
      Hive.registerAdapter(AppointmentIntakeHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(24)) {
      Hive.registerAdapter(AppointmentHiveAdapter());
    }
  }

  Future<void> _openEncryptedBoxes(HiveAesCipher cipher) async {
    final stopwatch = Stopwatch()..start();
    await Hive.openBox<PatientHive>(patientsBox, encryptionCipher: cipher);
    await Hive.openBox<DoctorHive>(doctorProfileBox, encryptionCipher: cipher);
    await Hive.openBox<PractitionerHive>(
      practitionersBox,
      encryptionCipher: cipher,
    );
    // Cases.
    await Hive.openBox<CaseHive>(casesBox, encryptionCipher: cipher);
    await Hive.openBox<CaseLogEntryHive>(caseLogsBox, encryptionCipher: cipher);
    await Hive.openBox<CasePaymentHive>(
      casePaymentsBox,
      encryptionCipher: cipher,
    );
    await Hive.openBox<ShareCodeHive>(shareCodesBox, encryptionCipher: cipher);
    await Hive.openBox<RiskCheckHive>(riskChecksBox, encryptionCipher: cipher);
    await Hive.openBox<NotesTranslationHive>(
      notesTranslationsBox,
      encryptionCipher: cipher,
    );
    // Reports.
    await Hive.openBox<PathologyReportHive>(
      pathologyReportsBox,
      encryptionCipher: cipher,
    );
    await Hive.openBox<ReportDraftHive>(
      reportDraftsBox,
      encryptionCipher: cipher,
    );
    await Hive.openBox<PrereadScoreHive>(
      prereadScoresBox,
      encryptionCipher: cipher,
    );
    await Hive.openBox<WorklistEntryHive>(
      worklistBox,
      encryptionCipher: cipher,
    );
    await Hive.openBox<ReportTextApprovedHive>(
      reportTextsBox,
      encryptionCipher: cipher,
    );
    // Appointments.
    await Hive.openBox<AppointmentHive>(
      appointmentsBox,
      encryptionCipher: cipher,
    );
    await Hive.openBox<AppointmentIntakeHive>(
      appointmentIntakesBox,
      encryptionCipher: cipher,
    );
    // Conversations.
    await Hive.openBox<ConversationHive>(
      conversationsBox,
      encryptionCipher: cipher,
    );
    await Hive.openBox<ConversationCursorHive>(
      conversationCursorsBox,
      encryptionCipher: cipher,
    );
    await Hive.openBox<MessageTranscriptHive>(
      messageTranscriptsBox,
      encryptionCipher: cipher,
    );
    // Notifications.
    await Hive.openBox<NotificationHive>(
      notificationsBox,
      encryptionCipher: cipher,
    );
    // Alerts.
    await Hive.openBox<PublicAlertHive>(
      publicAlertsBox,
      encryptionCipher: cipher,
    );
    await Hive.openBox<AlertClinicianBriefHive>(
      alertClinicianBriefsBox,
      encryptionCipher: cipher,
    );
    await Hive.openBox<AlertReceiptHive>(
      alertReceiptsBox,
      encryptionCipher: cipher,
    );
    stopwatch.stop();
    // One less than the map: messages opens lazily through messagesBox().
    if (kDebugMode) {
      _logger.i(
        'Hive opened ${_encryptedBoxes.length - 1} encrypted boxes '
        'in ${stopwatch.elapsedMilliseconds}ms',
      );
    }
  }

  @override
  Future<LazyBox<MessageHive>> messagesBox() =>
      _messagesBox ??= _openMessagesBox();

  Future<LazyBox<MessageHive>> _openMessagesBox() async {
    if (Hive.isBoxOpen(messagesBoxName)) {
      return Hive.lazyBox<MessageHive>(messagesBoxName);
    }
    return await Hive.openLazyBox<MessageHive>(
      messagesBoxName,
      encryptionCipher: await _cipher(rotate: false),
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
    _messagesBox = null;
    await _clearMediaCache();
    await _openEncryptedBoxes(await _cipher(rotate: true));
    await _secureStorage.delete(key: _ownerName).timeout(_secureStorageTimeout);
  }

  /// Deletes the cached voice notes and images, best effort: a failure is
  /// logged in debug and never blocks sign-out.
  Future<void> _clearMediaCache() async {
    try {
      final cache = await getApplicationCacheDirectory();
      final dir = Directory('${cache.path}/$_mediaCacheDirName');
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    } catch (e) {
      if (kDebugMode) _logger.w('Media cache delete failed: $e');
    }
  }

  @override
  Future<void> scopeTo(String uid) async {
    final owner = await _secureStorage
        .read(key: _ownerName)
        .timeout(_secureStorageTimeout);
    if (owner == uid) return;
    // Unowned rows can only be a write that landed after a sign-out.
    await clearOnSignOut();
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
