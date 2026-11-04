import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tabibu/core/constants/enums.dart';

/// How a person signed in, as GA4's `method` parameter.
enum SignInMethod {
  email,
  google;

  String get value => name;
}

/// One method per user-visible action (architecture §5 rule 7). Parameters
/// are roles, methods and purposes only: never a name, email, phone, uid,
/// share code or anything about a patient's health.
///
/// Every call swallows its own failure: analytics never breaks the action
/// it describes.
@lazySingleton
class AnalyticsService {
  AnalyticsService({required this._analytics});

  final FirebaseAnalytics _analytics;
  final Logger _logger = Logger();

  Future<void> logLogin(SignInMethod method) =>
      _guard(() => _analytics.logLogin(loginMethod: method.value));

  /// The Auth account exists; the profile does not yet.
  Future<void> logSignUp(SignInMethod method) =>
      _guard(() => _analytics.logSignUp(signUpMethod: method.value));

  /// The sign-up callable succeeded. A practitioner is still pending.
  Future<void> logCompleteSignUp(Role role) => _guard(
    () => _analytics.logEvent(
      name: 'complete_sign_up',
      parameters: {'role': role.name},
    ),
  );

  Future<void> logEmailVerified() =>
      _guard(() => _analytics.logEvent(name: 'email_verified'));

  Future<void> logPasswordResetRequested() =>
      _guard(() => _analytics.logEvent(name: 'password_reset_requested'));

  Future<void> logLanguageChanged(AppLanguage language) => _guard(
    () => _analytics.logEvent(
      name: 'language_changed',
      parameters: {'language': language.value},
    ),
  );

  Future<void> logProfileSettingChanged(
    ProfileSetting setting, {
    required bool value,
  }) => _guard(
    () => _analytics.logEvent(
      name: 'profile_setting_changed',
      parameters: {'setting': setting.name, 'value': value ? 1 : 0},
    ),
  );

  Future<void> logSignOut() =>
      _guard(() => _analytics.logEvent(name: 'sign_out'));

  /// Ties later events to a role, never to a person.
  Future<void> setRole(Role? role) =>
      _guard(() => _analytics.setUserProperty(name: 'role', value: role?.name));

  /// Share events carry the purpose only (T-18: never a code, name or id).
  Future<void> logShareCreated({required String purpose}) => _guard(
    () => _analytics.logEvent(
      name: 'share_created',
      parameters: {'purpose': purpose},
    ),
  );

  Future<void> logShareReissued({required String purpose}) => _guard(
    () => _analytics.logEvent(
      name: 'share_reissued',
      parameters: {'purpose': purpose},
    ),
  );

  Future<void> logShareRevoked({required String purpose}) => _guard(
    () => _analytics.logEvent(
      name: 'share_revoked',
      parameters: {'purpose': purpose},
    ),
  );

  Future<void> logShareViewerRemoved() =>
      _guard(() => _analytics.logEvent(name: 'share_viewer_removed'));

  Future<void> logShareRedeemed({required String purpose}) => _guard(
    () => _analytics.logEvent(
      name: 'share_redeemed',
      parameters: {'purpose': purpose},
    ),
  );

  /// Group consult events carry no ids, names or text.
  Future<void> logMdtOpened() =>
      _guard(() => _analytics.logEvent(name: 'mdt_opened'));

  Future<void> logMdtInvited({required int count}) => _guard(
    () =>
        _analytics.logEvent(name: 'mdt_invited', parameters: {'count': count}),
  );

  Future<void> logMdtResponded({required bool accepted}) => _guard(
    () => _analytics.logEvent(
      name: 'mdt_responded',
      parameters: {'accepted': accepted ? 1 : 0},
    ),
  );

  Future<void> logMdtLeft() =>
      _guard(() => _analytics.logEvent(name: 'mdt_left'));

  Future<void> logMdtMemberRemoved() =>
      _guard(() => _analytics.logEvent(name: 'mdt_member_removed'));

  Future<void> logMdtMessageSent() =>
      _guard(() => _analytics.logEvent(name: 'mdt_message_sent'));

  /// Appointment chat events carry no ids, names or text.
  Future<void> logChatMessageSent() =>
      _guard(() => _analytics.logEvent(name: 'chat_message_sent'));

  /// Voice note sent: duration bucket only — never audio, path or ids.
  Future<void> logChatVoiceNoteSent({required String durationBucket}) => _guard(
    () => _analytics.logEvent(
      name: 'chat_voice_note_sent',
      parameters: {'duration_bucket': durationBucket},
    ),
  );

  Future<void> logMdtVoiceNoteSent({required String durationBucket}) => _guard(
    () => _analytics.logEvent(
      name: 'mdt_voice_note_sent',
      parameters: {'duration_bucket': durationBucket},
    ),
  );

  /// Voice recording lifecycle carries the surface only ('chat', 'mdt' or
  /// 'symptom') — never audio, transcript, ids or paths.
  Future<void> logVoiceRecordingStarted({required String surface}) => _guard(
    () => _analytics.logEvent(
      name: 'voice_recording_started',
      parameters: {'surface': surface},
    ),
  );

  Future<void> logVoiceRecordingDiscarded({required String surface}) => _guard(
    () => _analytics.logEvent(
      name: 'voice_recording_discarded',
      parameters: {'surface': surface},
    ),
  );

  Future<void> logVoicePlaybackStarted() =>
      _guard(() => _analytics.logEvent(name: 'voice_playback_started'));

  Future<void> logVoicePlaybackPaused() =>
      _guard(() => _analytics.logEvent(name: 'voice_playback_paused'));

  Future<void> logChatClosed() =>
      _guard(() => _analytics.logEvent(name: 'chat_closed'));

  /// Slides registered by one upload request: a count, never a uid, name,
  /// path or anything read off the image.
  Future<void> logSlidesUploaded({required int count}) => _guard(
    () => _analytics.logEvent(
      name: 'slides_uploaded',
      parameters: {'count': count},
    ),
  );

  /// Case request outcomes carry no reason text.
  Future<void> logCaseRequestAccepted() =>
      _guard(() => _analytics.logEvent(name: 'case_request_accepted'));

  Future<void> logCaseRequestDeclined() =>
      _guard(() => _analytics.logEvent(name: 'case_request_declined'));

  Future<void> logSampleReceived() =>
      _guard(() => _analytics.logEvent(name: 'sample_received'));

  Future<void> logDraftSaved() =>
      _guard(() => _analytics.logEvent(name: 'draft_saved'));

  Future<void> logScoreSubmitted() =>
      _guard(() => _analytics.logEvent(name: 'score_submitted'));

  /// Report events carry the draft kind only: initial, amendment, addendum.
  Future<void> logReportSigned({required String kind}) => _guard(
    () =>
        _analytics.logEvent(name: 'report_signed', parameters: {'kind': kind}),
  );

  Future<void> logRevisionStarted({required String kind}) => _guard(
    () => _analytics.logEvent(
      name: 'revision_started',
      parameters: {'kind': kind},
    ),
  );

  Future<void> logRevisionDiscarded() =>
      _guard(() => _analytics.logEvent(name: 'revision_discarded'));

  /// Order events carry a test count only, never ids, notes or results.
  Future<void> logOrderCreated({required int count}) => _guard(
    () => _analytics.logEvent(
      name: 'order_created',
      parameters: {'count': count},
    ),
  );

  Future<void> logPathologistRequested() =>
      _guard(() => _analytics.logEvent(name: 'pathologist_requested'));

  /// Appointment outcomes carry an accepted flag only, never reasons or notes.
  Future<void> logAppointmentRequested() =>
      _guard(() => _analytics.logEvent(name: 'appointment_requested'));

  /// Symptom voice transcription succeeded. Duration bucket and language
  /// flag only — never audio, transcript or paths.
  Future<void> logSymptomVoiceTranscribed({
    required String durationBucket,
    required bool englishOrSwahili,
  }) => _guard(
    () => _analytics.logEvent(
      name: 'symptom_voice_transcribed',
      parameters: {
        'duration_bucket': durationBucket,
        'en_or_sw': englishOrSwahili ? 1 : 0,
      },
    ),
  );

  Future<void> logAppointmentResponded({required bool accepted}) => _guard(
    () => _analytics.logEvent(
      name: 'appointment_responded',
      parameters: {'accepted': accepted ? 1 : 0},
    ),
  );

  Future<void> logAppointmentCancelled() =>
      _guard(() => _analytics.logEvent(name: 'appointment_cancelled'));

  Future<void> logAppointmentRescheduled() =>
      _guard(() => _analytics.logEvent(name: 'appointment_rescheduled'));

  Future<void> logAppointmentCompleted() =>
      _guard(() => _analytics.logEvent(name: 'appointment_completed'));

  Future<void> logReportDiscussed() =>
      _guard(() => _analytics.logEvent(name: 'report_discussed'));

  Future<void> logExplanationReviewed({required bool approved}) => _guard(
    () => _analytics.logEvent(
      name: 'explanation_reviewed',
      parameters: {'approved': approved ? 1 : 0},
    ),
  );

  /// Alert decisions carry the decision only, never text or reasons.
  Future<void> logAlertReviewed({required ApprovalDecision decision}) => _guard(
    () => _analytics.logEvent(
      name: 'alert_reviewed',
      parameters: {'decision': decision.name},
    ),
  );

  Future<void> logCaseNotesSaved() =>
      _guard(() => _analytics.logEvent(name: 'case_notes_saved'));

  /// Lock events carry settings only, never a PIN or biometric result.
  Future<void> logLockEnabled() =>
      _guard(() => _analytics.logEvent(name: 'lock_enabled'));

  Future<void> logLockDisabled() =>
      _guard(() => _analytics.logEvent(name: 'lock_disabled'));

  Future<void> logLockBiometricsChanged({required bool enabled}) => _guard(
    () => _analytics.logEvent(
      name: 'lock_biometrics_changed',
      parameters: {'enabled': enabled ? 1 : 0},
    ),
  );

  Future<void> logLockTimeoutChanged({required int seconds}) => _guard(
    () => _analytics.logEvent(
      name: 'lock_timeout_changed',
      parameters: {'seconds': seconds},
    ),
  );

  Future<void> logNotificationsMarkedRead() =>
      _guard(() => _analytics.logEvent(name: 'notifications_marked_read'));

  Future<void> _guard(Future<void> Function() body) async {
    try {
      await body();
    } on Object catch (e) {
      if (kDebugMode) _logger.w('Analytics event dropped: $e');
    }
  }
}
