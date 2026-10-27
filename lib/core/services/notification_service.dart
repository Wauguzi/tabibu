import 'dart:async';
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/l10n/l10n.dart';

/// Android channels (notifications engine §7). People can mute each one
/// separately in system settings, so a kind of message never changes
/// channel once shipped.
enum NotificationChannel {
  /// Sign-in, sign-up, password reset and security notices (RASP).
  account('account', Importance.high),

  /// Approved outbreak alerts.
  alerts('alerts', Importance.high),

  /// A case moved: a report signed, a result released, an invitation.
  caseUpdates('case_updates', Importance.defaultImportance);

  const NotificationChannel(this.id, this.importance);

  final String id;
  final Importance importance;

  String name(AppLocalizations l10n) => switch (this) {
    account => l10n.notificationChannelAccount,
    alerts => l10n.notificationChannelAlerts,
    caseUpdates => l10n.notificationChannelCaseUpdates,
  };

  String description(AppLocalizations l10n) => switch (this) {
    account => l10n.notificationChannelAccountDescription,
    alerts => l10n.notificationChannelAlertsDescription,
    caseUpdates => l10n.notificationChannelCaseUpdatesDescription,
  };
}

/// Local notifications: foreground banners, and the notices the app raises
/// itself. Push text from Cloud Functions arrives through FCM instead.
///
/// Lock screens are public: a caller never puts a diagnosis, a name or a
/// result in [showNotification]'s text (S-3).
class NotificationService {
  factory NotificationService() => _instance;

  NotificationService._(this._plugin);

  @visibleForTesting
  NotificationService.withPlugin(FlutterLocalNotificationsPlugin plugin)
    : _plugin = plugin;

  static final NotificationService _instance = NotificationService._(
    FlutterLocalNotificationsPlugin(),
  );

  final FlutterLocalNotificationsPlugin _plugin;
  final Logger _logger = Logger();
  final StreamController<String> _taps = StreamController<String>.broadcast();

  /// `res/drawable/ic_notification.xml`, kept from the resource shrinker by
  /// `res/raw/keep.xml`. One constant for [initialize] and every show: the
  /// plugin stores the name at initialize and re-reads it on each show, so
  /// two literals that drift apart break notifications silently.
  static const androidIcon = 'ic_notification';

  /// Payloads of notifications tapped while the app runs; the router's tap
  /// handler listens.
  Stream<String> get taps => _taps.stream;

  Future<void> initialize() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings(androidIcon),
      // Permission is requested through permission_handler, at a moment the
      // app chooses, not when the plugin starts.
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) _taps.add(payload);
      },
    );
    await _createChannels();
    await _requestPermission();
  }

  Future<void> _createChannels() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;
    final l10n = _deviceL10n();
    for (final channel in NotificationChannel.values) {
      await android.createNotificationChannel(
        AndroidNotificationChannel(
          channel.id,
          channel.name(l10n),
          description: channel.description(l10n),
          importance: channel.importance,
        ),
      );
    }
  }

  /// Channels are named before any screen exists, so in the device's
  /// language when the app supports it.
  AppLocalizations _deviceL10n() {
    final device = PlatformDispatcher.instance.locale;
    final supported = AppLocalizations.supportedLocales.any(
      (l) => l.languageCode == device.languageCode,
    );
    return lookupAppLocalizations(
      supported ? Locale(device.languageCode) : const Locale('en'),
    );
  }

  Future<void> _requestPermission() async {
    if (await Permission.notification.isGranted) return;
    await Permission.notification.request();
  }

  /// The payload of the notification that launched the app, read once after
  /// the decision route resolves (notifications engine §7).
  Future<String?> launchPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    final payload = details.notificationResponse?.payload;
    return payload == null || payload.isEmpty ? null : payload;
  }

  /// Asks for permission if it was not granted. True when app settings were
  /// opened instead, so the caller waits for the app to resume.
  Future<bool> requestOrOpenSettings() async {
    final status = await Permission.notification.status;
    if (status.isGranted) return false;
    if (status.isDenied) {
      final result = await Permission.notification.request();
      // iOS denies permanently on the first refusal.
      if (!result.isPermanentlyDenied) return false;
    }
    await openAppSettings();
    return true;
  }

  Future<bool> areNotificationsGranted() => Permission.notification.isGranted;

  /// Never throws. A notification is a side effect, and it once sat on a
  /// sign-in path where a plugin exception stopped navigation and left
  /// people on the form. Failures are recorded, not swallowed silently.
  Future<void> showNotification({
    required String title,
    required String message,
    NotificationChannel channel = NotificationChannel.account,
    String? payload,
  }) async {
    try {
      final l10n = _deviceL10n();
      await _plugin.show(
        id: DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF,
        title: title,
        body: message,
        payload: payload,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name(l10n),
            channelDescription: channel.description(l10n),
            importance: channel.importance,
            priority: channel.importance == Importance.high
                ? Priority.high
                : Priority.defaultPriority,
            // Named on every show: if initialize() failed, the plugin has
            // no stored default and unboxes a null on Android.
            icon: androidIcon,
            color: AppColors.primaryLight,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBanner: true,
            presentList: true,
            presentSound: false,
          ),
        ),
      );
    } on Object catch (e, stackTrace) {
      if (kDebugMode) _logger.w('showNotification failed: $e');
      _report(e, stackTrace);
    }
  }

  /// Crashlytics throws when Firebase never initialised, which this path can
  /// reach; reporting must not reintroduce the failure it reports.
  void _report(Object error, StackTrace stackTrace) {
    try {
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'showNotification failed (non-fatal)',
        ),
      );
    } on Object catch (e) {
      if (kDebugMode) _logger.w('Crashlytics unavailable: $e');
    }
  }

  Future<void> cancelNotification(int id) => _plugin.cancel(id: id);

  Future<void> cancelAllNotifications() => _plugin.cancelAll();
}
