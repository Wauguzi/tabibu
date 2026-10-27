import 'dart:async';
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

  /// A push names its channel in `data.channel`; anything else is a case
  /// update, the quietest.
  static NotificationChannel fromId(String? id) =>
      values.firstWhere((c) => c.id == id, orElse: () => caseUpdates);

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

  // Resolved only when needed: FirebaseMessaging.instance throws when
  // Firebase never initialised.
  FirebaseMessaging _messaging() => FirebaseMessaging.instance;
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
    await _allowForegroundBannersOnIos();
    await _requestPermission();
    _listenToPushes();
  }

  /// A push carries the case or alert uid in `data.payload`. A tap joins
  /// [taps]; one that arrives while the app is open is shown as a local
  /// banner on Android, which otherwise shows nothing in the foreground
  /// (iOS shows it through the options above).
  void _listenToPushes() {
    try {
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        final payload = _payloadOf(message);
        if (payload != null) _taps.add(payload);
      });
      if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
      FirebaseMessaging.onMessage.listen((message) {
        final notification = message.notification;
        if (notification == null) return;
        unawaited(
          showNotification(
            title: notification.title ?? '',
            message: notification.body ?? '',
            channel: NotificationChannel.fromId(
              message.data['channel'] as String?,
            ),
            payload: _payloadOf(message),
          ),
        );
      });
    } on Object catch (e, stackTrace) {
      if (kDebugMode) _logger.w('Push listeners not attached: $e');
      _report(e, stackTrace);
    }
  }

  static String? _payloadOf(RemoteMessage message) {
    final payload = message.data['payload'];
    return payload is String && payload.isNotEmpty ? payload : null;
  }

  /// This install's FCM token, or null where there is none yet (an iOS
  /// simulator, no APNs token, Firebase not initialised). Never throws.
  Future<String?> deviceToken() async {
    try {
      return await _messaging().getToken();
    } on Object catch (e) {
      if (kDebugMode) _logger.w('No FCM token: $e');
      return null;
    }
  }

  /// FCM rotates tokens; each new one must reach the profile.
  Stream<String> get tokenRefreshes {
    try {
      return _messaging().onTokenRefresh;
    } on Object catch (_) {
      return const Stream.empty();
    }
  }

  /// Since firebase_messaging 16.7 its iOS plugin answers foreground
  /// notifications before this one, and with no options set it answers
  /// "show nothing", so banners vanish while the app is open. Setting its
  /// options to ours makes its answer the one we want. Never fatal.
  Future<void> _allowForegroundBannersOnIos() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;
    try {
      await _messaging().setForegroundNotificationPresentationOptions(
        alert: true,
      );
    } on Object catch (e, stackTrace) {
      if (kDebugMode) _logger.w('Foreground banner options not set: $e');
      _report(e, stackTrace);
    }
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

  /// The payload of the local or push notification that launched the app,
  /// read once after the decision route resolves (notifications engine §7).
  Future<String?> launchPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      final payload = details.notificationResponse?.payload;
      if (payload != null && payload.isNotEmpty) return payload;
    }
    try {
      final push = await _messaging().getInitialMessage();
      return push == null ? null : _payloadOf(push);
    } on Object catch (_) {
      return null;
    }
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

  /// Never throws. A notification is a side effect, and it sits on sign-in
  /// paths where a plugin exception would stop navigation and leave people
  /// on the form. Failures are recorded, not swallowed silently.
  ///
  /// [id] defaults to a fresh one, so notifications stack; a fixed [id]
  /// replaces its predecessor instead (security notices do).
  Future<void> showNotification({
    required String title,
    required String message,
    NotificationChannel channel = NotificationChannel.account,
    String? payload,
    int? id,
  }) async {
    try {
      final l10n = _deviceL10n();
      await _plugin.show(
        id: id ?? DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF,
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
