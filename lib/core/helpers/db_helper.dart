import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/alerts/data/models/alert_clinician_brief_hive.dart';
import 'package:tabibu/features/alerts/data/models/alert_receipt_hive.dart';
import 'package:tabibu/features/alerts/data/models/public_alert_hive.dart';
import 'package:tabibu/features/appointments/data/models/appointment_hive.dart';
import 'package:tabibu/features/appointments/data/models/appointment_intake_hive.dart';
import 'package:tabibu/features/auth/data/models/onboarding_hive.dart';
import 'package:tabibu/features/cases/data/models/case_hive.dart';
import 'package:tabibu/features/cases/data/models/case_log_entry_hive.dart';
import 'package:tabibu/features/cases/data/models/case_payment_hive.dart';
import 'package:tabibu/features/cases/data/models/notes_translation_hive.dart';
import 'package:tabibu/features/cases/data/models/risk_check_hive.dart';
import 'package:tabibu/features/cases/data/models/share_code_hive.dart';
import 'package:tabibu/features/conversations/data/models/conversation_cursor_hive.dart';
import 'package:tabibu/features/conversations/data/models/conversation_hive.dart';
import 'package:tabibu/features/conversations/data/models/message_hive.dart';
import 'package:tabibu/features/conversations/data/models/message_transcript_hive.dart';
import 'package:tabibu/features/notifications/data/models/notification_hive.dart';
import 'package:tabibu/features/patients/data/models/patient_hive.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_hive.dart';
import 'package:tabibu/features/profile/data/models/doctor_hive.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_hive.dart';
import 'package:tabibu/features/reports/data/models/preread_score_hive.dart';
import 'package:tabibu/features/reports/data/models/report_draft_hive.dart';
import 'package:tabibu/features/reports/data/models/report_text_approved_hive.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_hive.dart';

/// Typed box access for the Hive helper: the only place that touches a box, so
/// every failure surfaces as an [AppError] and tests can substitute it.
abstract class DBHelper {
  Future<void> put<T>(String boxName, String key, T value);
  Future<void> putAll<T>(String boxName, Map<String, T> values);
  Future<T?> get<T>(String boxName, String key);
  Future<List<T>> getAll<T>(String boxName);
  Future<void> delete<T>(String boxName, String key);
  Future<void> clearBox<T>(String boxName);

  /// Closes and deletes each box through its own type. `Hive.box<dynamic>`
  /// refuses a box opened typed, so an untyped close fails and the data
  /// stays on disk.
  Future<void> deleteAll(Map<Type, String> boxes);
}

@Singleton(as: DBHelper)
class DBHelperImpl implements DBHelper {
  DBHelperImpl();

  final Logger _logger = Logger();

  Future<R> _guard<R>(String operation, Future<R> Function() body) async {
    try {
      return await body();
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        _logger.e('DB $operation failed: $e', stackTrace: stackTrace);
      }
      throw AppError.unknown;
      // A closed or mistyped box raises HiveError, which is an Error; an
      // `on Exception` alone lets it escape unmapped.
      // ignore: avoid_catching_errors
    } on HiveError catch (e, stackTrace) {
      if (kDebugMode) {
        _logger.e('DB $operation failed: $e', stackTrace: stackTrace);
      }
      throw AppError.unknown;
    }
  }

  @override
  Future<void> put<T>(String boxName, String key, T value) =>
      _guard('put($boxName)', () => Hive.box<T>(boxName).put(key, value));

  @override
  Future<void> putAll<T>(String boxName, Map<String, T> values) =>
      _guard('putAll($boxName)', () => Hive.box<T>(boxName).putAll(values));

  @override
  Future<T?> get<T>(String boxName, String key) =>
      _guard('get($boxName)', () async => Hive.box<T>(boxName).get(key));

  @override
  Future<List<T>> getAll<T>(String boxName) => _guard(
    'getAll($boxName)',
    () async => Hive.box<T>(boxName).values.toList(),
  );

  @override
  Future<void> delete<T>(String boxName, String key) =>
      _guard('delete($boxName)', () => Hive.box<T>(boxName).delete(key));

  @override
  Future<void> clearBox<T>(String boxName) =>
      _guard('clearBox($boxName)', () => Hive.box<T>(boxName).clear());

  @override
  Future<void> deleteAll(Map<Type, String> boxes) async {
    for (final MapEntry(key: type, value: name) in boxes.entries) {
      if (type == PatientHive) {
        await _closeAndDelete<PatientHive>(name);
      } else if (type == DoctorHive) {
        await _closeAndDelete<DoctorHive>(name);
      } else if (type == PractitionerHive) {
        await _closeAndDelete<PractitionerHive>(name);
      } else if (type == OnboardingHive) {
        await _closeAndDelete<OnboardingHive>(name);
        // Cases.
      } else if (type == CaseHive) {
        await _closeAndDelete<CaseHive>(name);
      } else if (type == CaseLogEntryHive) {
        await _closeAndDelete<CaseLogEntryHive>(name);
      } else if (type == CasePaymentHive) {
        await _closeAndDelete<CasePaymentHive>(name);
      } else if (type == ShareCodeHive) {
        await _closeAndDelete<ShareCodeHive>(name);
      } else if (type == RiskCheckHive) {
        await _closeAndDelete<RiskCheckHive>(name);
      } else if (type == NotesTranslationHive) {
        await _closeAndDelete<NotesTranslationHive>(name);
        // Reports.
      } else if (type == PathologyReportHive) {
        await _closeAndDelete<PathologyReportHive>(name);
      } else if (type == ReportDraftHive) {
        await _closeAndDelete<ReportDraftHive>(name);
      } else if (type == PrereadScoreHive) {
        await _closeAndDelete<PrereadScoreHive>(name);
      } else if (type == WorklistEntryHive) {
        await _closeAndDelete<WorklistEntryHive>(name);
      } else if (type == ReportTextApprovedHive) {
        await _closeAndDelete<ReportTextApprovedHive>(name);
        // Appointments.
      } else if (type == AppointmentHive) {
        await _closeAndDelete<AppointmentHive>(name);
      } else if (type == AppointmentIntakeHive) {
        await _closeAndDelete<AppointmentIntakeHive>(name);
        // Conversations.
      } else if (type == ConversationHive) {
        await _closeAndDelete<ConversationHive>(name);
      } else if (type == ConversationCursorHive) {
        await _closeAndDelete<ConversationCursorHive>(name);
      } else if (type == MessageHive) {
        await _closeAndDeleteLazy<MessageHive>(name);
      } else if (type == MessageTranscriptHive) {
        await _closeAndDelete<MessageTranscriptHive>(name);
        // Notifications.
      } else if (type == NotificationHive) {
        await _closeAndDelete<NotificationHive>(name);
        // Alerts.
      } else if (type == PublicAlertHive) {
        await _closeAndDelete<PublicAlertHive>(name);
      } else if (type == AlertClinicianBriefHive) {
        await _closeAndDelete<AlertClinicianBriefHive>(name);
      } else if (type == AlertReceiptHive) {
        await _closeAndDelete<AlertReceiptHive>(name);
      } else {
        // A box missing here would survive sign-out; fail loudly instead.
        throw StateError('DBHelper.deleteAll has no case for $type.');
      }
    }
  }

  Future<void> _closeAndDelete<T>(String name) =>
      _guard('deleteAll($name)', () async {
        if (Hive.isBoxOpen(name)) await Hive.box<T>(name).close();
        await Hive.deleteBoxFromDisk(name);
      });

  /// Lazy boxes close through their own accessor. The files delete the same
  /// way whether or not the box was ever opened: missing files are a no-op.
  Future<void> _closeAndDeleteLazy<T>(String name) =>
      _guard('deleteAll($name)', () async {
        if (Hive.isBoxOpen(name)) await Hive.lazyBox<T>(name).close();
        await Hive.deleteBoxFromDisk(name);
      });
}
