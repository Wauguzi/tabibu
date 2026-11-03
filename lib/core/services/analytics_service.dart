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

  /// Slides registered by one upload request: a count, never a uid, name,
  /// path or anything read off the image.
  Future<void> logSlidesUploaded({required int count}) => _guard(
    () => _analytics.logEvent(
      name: 'slides_uploaded',
      parameters: {'count': count},
    ),
  );

  Future<void> _guard(Future<void> Function() body) async {
    try {
      await body();
    } on Object catch (e) {
      if (kDebugMode) _logger.w('Analytics event dropped: $e');
    }
  }
}
