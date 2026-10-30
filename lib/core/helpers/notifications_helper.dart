import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/core/services/notification_service.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The notices a bloc raises after an action, in the person's chosen
/// language. A bloc cannot build localised text itself (no Flutter imports),
/// so it calls this.
///
/// Lock screens are public: no name, diagnosis or result in any text here
/// (S-3). Every method is best-effort and never throws.
@lazySingleton
class NotificationsHelper {
  NotificationsHelper({
    NotificationService? notificationService,
    HiveHelper? hiveHelper,
  }) : _notifications = notificationService ?? getIt<NotificationService>(),
       _cache = hiveHelper ?? getIt<HiveHelper>();

  final NotificationService _notifications;
  final HiveHelper _cache;
  final Logger _logger = Logger();

  Future<void> notifyPatientRegistered() => _account(
    (l10n) => (l10n.notificationWelcomeTitle, l10n.notificationWelcomeMessage),
  );

  Future<void> notifyLicenceReceived() => _account(
    (l10n) => (
      l10n.notificationLicenceReceivedTitle,
      l10n.notificationLicenceReceivedMessage,
    ),
  );

  Future<void> _account(
    (String, String) Function(AppLocalizations l10n) text,
  ) async {
    try {
      final (title, message) = text(await _l10n());
      await _notifications.showNotification(title: title, message: message);
    } on Object catch (e) {
      if (kDebugMode) _logger.w('Notice not shown: $e');
    }
  }

  /// The language chosen on A2, else the device's when supported.
  Future<AppLocalizations> _l10n() async {
    final chosen = (await _cache.getCachedOnboarding())?.languageString ?? '';
    final code = chosen.isNotEmpty
        ? chosen
        : WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final supported = AppLocalizations.supportedLocales.any(
      (l) => l.languageCode == code,
    );
    return lookupAppLocalizations(Locale(supported ? code : 'en'));
  }
}
