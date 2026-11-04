import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabibu/core/constants/enums.dart';

/// FCM topic subscription for patient public alerts (07 §6.3).
///
/// On the web, topics are unsupported: every method is a no-op.
@lazySingleton
class AlertTopicService {
  AlertTopicService({
    required FirebaseMessaging messaging,
    required SharedPreferences preferences,
  }) : this.internal(
         messaging: messaging,
         preferences: preferences,
         forceWeb: false,
         useRealWebCheck: true,
       );

  /// Test constructor: set [_forceWeb] to simulate unsupported platforms.
  @visibleForTesting
  AlertTopicService.internal({
    required this._messaging,
    required this._preferences,
    required this._forceWeb,
    required this._useRealWebCheck,
  });

  final FirebaseMessaging _messaging;
  final SharedPreferences _preferences;
  final bool _forceWeb;
  final bool _useRealWebCheck;
  final Logger _logger = Logger();

  static const storedTopicKey = 'alert_topic_current';
  static const pendingUnsubscribeKey = 'alert_topic_pending_unsubscribe';

  bool get _isWeb => _useRealWebCheck ? kIsWeb : _forceWeb;

  /// The county and language topic `deliverAlert` publishes to; a demo
  /// account takes the demo variant, which only synthetic alerts reach.
  static String topicName({
    required int countyId,
    required String language,
    bool demo = false,
  }) => demo
      ? 'alerts_patient_demo_${countyId}_$language'
      : 'alerts_patient_${countyId}_$language';

  String? get storedTopic => _preferences.getString(storedTopicKey);

  String? get pendingUnsubscribe =>
      _preferences.getString(pendingUnsubscribeKey);

  /// Subscribe to [topic], unsubscribing the previous stored topic first.
  Future<void> syncSubscription({
    required String topic,
    required bool receiveNotifications,
  }) async {
    if (_isWeb) return;
    try {
      await _retryPendingUnsubscribe();
      if (!receiveNotifications) {
        await _unsubscribeStored();
        return;
      }
      final current = storedTopic;
      if (current == topic) return;
      if (current != null && current.isNotEmpty) {
        await _messaging.unsubscribeFromTopic(current);
      }
      await _messaging.subscribeToTopic(topic);
      await _preferences.setString(storedTopicKey, topic);
      await _preferences.remove(pendingUnsubscribeKey);
    } on FirebaseException catch (e, stackTrace) {
      if (kDebugMode) {
        _logger.e('Alert topic sync failed: $e', stackTrace: stackTrace);
      }
      throw AppError.fromFirebaseCode(e.code);
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        _logger.e('Alert topic sync failed: $e', stackTrace: stackTrace);
      }
      throw AppError.unknown;
    }
  }

  /// Best-effort unsubscribe before sign-out; queues a retry on failure.
  Future<void> unsubscribeBeforeSignOut() async {
    if (_isWeb) return;
    final current = storedTopic;
    if (current == null || current.isEmpty) {
      await _preferences.remove(pendingUnsubscribeKey);
      return;
    }
    try {
      await _messaging.unsubscribeFromTopic(current);
      await _preferences.remove(storedTopicKey);
      await _preferences.remove(pendingUnsubscribeKey);
    } on Exception catch (e) {
      if (kDebugMode) _logger.w('Alert topic unsubscribe deferred: $e');
      await _preferences.setString(pendingUnsubscribeKey, current);
      await _preferences.remove(storedTopicKey);
    }
  }

  /// Retries a deferred unsubscribe from a previous sign-out.
  Future<void> retryPendingUnsubscribeOnSignIn() async {
    if (_isWeb) return;
    await _retryPendingUnsubscribe();
  }

  Future<void> _retryPendingUnsubscribe() async {
    final pending = pendingUnsubscribe;
    if (pending == null || pending.isEmpty) return;
    try {
      await _messaging.unsubscribeFromTopic(pending);
      await _preferences.remove(pendingUnsubscribeKey);
    } on Exception catch (e) {
      if (kDebugMode) _logger.w('Pending alert topic unsubscribe failed: $e');
    }
  }

  Future<void> _unsubscribeStored() async {
    final current = storedTopic;
    if (current == null || current.isEmpty) return;
    await _messaging.unsubscribeFromTopic(current);
    await _preferences.remove(storedTopicKey);
  }
}
