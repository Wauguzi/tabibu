import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';

/// How a person signed in, as GA4's `method` parameter.
enum SignInMethod {
  email,
  google;

  String get value => name;
}

/// One method per user-visible action (architecture §5 rule 7). Parameters
/// are roles and methods only: never a name, email, phone, uid or anything
/// about a patient's health.
///
/// Every call swallows its own failure: analytics never breaks the action
/// it describes.
@lazySingleton
class AnalyticsService {
  AnalyticsService({FirebaseAnalytics? analytics})
    : _analytics = analytics ?? getIt<FirebaseAnalytics>();

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

  Future<void> logPasswordResetRequested() =>
      _guard(() => _analytics.logEvent(name: 'password_reset_requested'));

  Future<void> logLanguageChanged(AppLanguage language) => _guard(
    () => _analytics.logEvent(
      name: 'language_changed',
      parameters: {'language': language.value},
    ),
  );

  Future<void> logSignOut() =>
      _guard(() => _analytics.logEvent(name: 'sign_out'));

  /// Ties later events to a role, never to a person.
  Future<void> setRole(Role? role) =>
      _guard(() => _analytics.setUserProperty(name: 'role', value: role?.name));

  Future<void> _guard(Future<void> Function() body) async {
    try {
      await body();
    } on Object catch (e) {
      if (kDebugMode) _logger.w('Analytics event dropped: $e');
    }
  }
}
