// The SDK's callbacks can throw platform exceptions that do not extend
// Exception, so failures are caught bare.
// ignore_for_file: avoid_catches_without_on_clauses

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:freerasp/freerasp.dart';
import 'package:tabibu/core/constants/rasp_config.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/core/services/notification_service.dart';
import 'package:tabibu/core/services/security_notice_gate.dart';
import 'package:tabibu/l10n/l10n.dart';

/// Severity tiers, after OWASP MASVS risk levels (threat model T-10).
///
/// - critical: notify, then terminate in production; the environment is
///   actively compromised (root, hooks, tampering, a debugger, stripped
///   obfuscation).
/// - severe: notify and emit on [RaspService.threatStream]; elevated risk
///   (unofficial store, emulator, multi-instance, cloning, bootloader,
///   malware).
/// - advisory: notify and log only (VPN, no passcode, screenshot, weak
///   Wi-Fi, spoofing, ADB).
///
/// Every detection is logged and emitted. The notice a person sees passes a
/// [SecurityNoticeGate] first, so a repeated condition is not a repeated
/// notice; a critical threat in production is always shown, just before the
/// app closes.
enum SecurityThreatLevel { critical, severe, advisory }

/// The coarse area a person is told about. The detection itself stays in
/// logs: naming it tells a legitimate user nothing they can act on, and
/// tells whoever triggered it which check to defeat next.
enum SecurityHint { device, app, otherApp, network }

class SecurityThreatEvent {
  const SecurityThreatEvent({
    required this.threatName,
    required this.level,
    required this.message,
  });

  final String threatName;
  final SecurityThreatLevel level;

  /// Diagnostic text for logs and Crashlytics; never shown to a person.
  final String message;

  @override
  String toString() =>
      'SecurityThreatEvent($threatName, ${level.name}): $message';
}

/// [Talsec.instance] behind an interface, so the service is testable
/// without platform channels.
abstract class RaspPlatform {
  Future<void> start(TalsecConfig config);
  Future<void> attachListener(ThreatCallback callback);
  Future<void> blockScreenCapture({required bool enabled});
  Future<void> storeExternalId(String id);
}

class RaspPlatformImpl implements RaspPlatform {
  @override
  Future<void> start(TalsecConfig config) => Talsec.instance.start(config);

  @override
  Future<void> attachListener(ThreatCallback callback) =>
      Talsec.instance.attachListener(callback);

  @override
  Future<void> blockScreenCapture({required bool enabled}) =>
      Talsec.instance.blockScreenCapture(enabled: enabled);

  @override
  Future<void> storeExternalId(String id) =>
      Talsec.instance.storeExternalId(id);
}

/// Injected so tests can check termination without calling [exit].
typedef CriticalThreatHandler = void Function(SecurityThreatEvent event);

/// Runtime application self-protection, backed by freeRASP (§10, T-10).
/// Initialised in bootstrap before `runApp`; detections are notified on the
/// account and security channel and recorded to Crashlytics.
class RaspService {
  RaspService({
    RaspPlatform? platform,
    CriticalThreatHandler? onCritical,
    SecurityNoticeGate? noticeGate,
  }) : _platform = platform ?? RaspPlatformImpl(),
       _onCritical = onCritical ?? _defaultCriticalHandler,
       _noticeGate = noticeGate ?? SecurityNoticeGate() {
    // Derived once, so the gate decides each event once however many
    // listeners noticeStream has.
    _threatController.stream.where(_admitsNotice).listen(_noticeController.add);
    _noticeController.stream.listen((event) => unawaited(_notify(event)));
  }

  /// One id for every security notice, so an admitted notice replaces the
  /// previous one in the shade instead of stacking.
  static const securityNoticeId = 0x7A51;

  final RaspPlatform _platform;
  final CriticalThreatHandler _onCritical;
  final SecurityNoticeGate _noticeGate;
  bool _isProd = false;

  /// Outside production, so the demo can be recorded from a debug or
  /// profile build.
  bool _screenCaptureAllowed = false;

  final StreamController<SecurityThreatEvent> _threatController =
      StreamController<SecurityThreatEvent>.broadcast();
  final StreamController<SecurityThreatEvent> _noticeController =
      StreamController<SecurityThreatEvent>.broadcast();

  /// For root-level UI that challenges a severe threat. A critical threat
  /// terminates the app and may not be observed here first.
  Stream<SecurityThreatEvent> get threatStream => _threatController.stream;

  /// The detections that became a notice: [threatStream] through the gate.
  /// A critical threat in production is not here; it is always shown.
  Stream<SecurityThreatEvent> get noticeStream => _noticeController.stream;

  /// [isProd] is true for release binaries only: debug builds are signed
  /// with the debug key, so enforcing certificates there would kill them.
  Future<void> initialize({required bool isProd}) async {
    // freeRASP has no web implementation.
    if (kIsWeb) return;
    _isProd = isProd;

    // Restored first, so a detection at startup cannot repeat a notice seen
    // before the relaunch.
    await _noticeGate.load();

    // Before start, so no early event is missed.
    await _platform.attachListener(_buildCallback());
    await _platform.start(_buildConfig(isProd: isProd));

    // In production, screens render black in screenshots and recordings, so
    // patient data never leaves through a capture. Allowed elsewhere, so the
    // demo can be recorded.
    _screenCaptureAllowed = !isProd;
    try {
      await _platform.blockScreenCapture(enabled: isProd);
    } catch (e) {
      log('[RaspService] blockScreenCapture failed: $e');
    }
  }

  /// Ties Talsec Portal reports to the signed-in uid. Called after sign-in;
  /// nobody is signed in at bootstrap.
  Future<void> bindUser(String uid) async {
    if (kIsWeb || uid.isEmpty) return;
    try {
      await _platform.storeExternalId(uid);
    } catch (e) {
      log('[RaspService] storeExternalId failed: $e');
    }
  }

  TalsecConfig _buildConfig({required bool isProd}) => TalsecConfig(
    androidConfig: defaultTargetPlatform == TargetPlatform.android
        ? AndroidConfig(
            packageName: RaspConfig.androidPackageName,
            signingCertHashes: isProd
                ? RaspConfig.prodSigningCertHashes
                : RaspConfig.devSigningCertHashes,
            supportedStores: RaspConfig.supportedStores,
          )
        : null,
    iosConfig: defaultTargetPlatform == TargetPlatform.iOS
        ? IOSConfig(
            bundleIds: RaspConfig.iosBundleIds,
            teamId: RaspConfig.iosTeamId,
          )
        : null,
    watcherMail: RaspConfig.watcherMail,
    isProd: isProd,
    // The SDK's own kill when freeRASP itself is bypassed.
    killOnBypass: isProd,
  );

  ThreatCallback _buildCallback() => ThreatCallback(
    onPrivilegedAccess: () => handleThreat(Threat.privilegedAccess),
    onHooks: () => handleThreat(Threat.hooks),
    onAppIntegrity: () => handleThreat(Threat.appIntegrity),
    onDebug: () => handleThreat(Threat.debug),
    onObfuscationIssues: () => handleThreat(Threat.obfuscationIssues),
    onUnofficialStore: () => handleThreat(Threat.unofficialStore),
    onSimulator: () => handleThreat(Threat.simulator),
    onMultiInstance: () => handleThreat(Threat.multiInstance),
    onDeviceBinding: () => handleThreat(Threat.deviceBinding),
    onBootloader: () => handleThreat(Threat.bootloader),
    onPasscode: () => handleThreat(Threat.passcode),
    onSecureHardwareNotAvailable: () =>
        handleThreat(Threat.secureHardwareNotAvailable),
    onSystemVPN: () => handleThreat(Threat.systemVPN),
    onDevMode: () => handleThreat(Threat.devMode),
    onADBEnabled: () => handleThreat(Threat.adbEnabled),
    onScreenshot: () => handleThreat(Threat.screenshot),
    onScreenRecording: () => handleThreat(Threat.screenRecording),
    onUnsecureWiFi: () => handleThreat(Threat.unsecureWiFi),
    onTimeSpoofing: () => handleThreat(Threat.timeSpoofing),
    onLocationSpoofing: () => handleThreat(Threat.locationSpoofing),
    onAutomation: () => handleThreat(Threat.automation),
    onDeviceID: () => handleThreat(Threat.deviceId),
    onMalware: handleMalware,
  );

  @visibleForTesting
  void handleThreat(Threat threat) => _dispatch(_classify(threat));

  /// Android only. Package names go to the log, never to the person.
  @visibleForTesting
  void handleMalware(List<SuspiciousAppInfo?> apps) {
    final names = apps.isEmpty
        ? 'unknown'
        : apps
              .whereType<SuspiciousAppInfo>()
              .map((a) => a.packageInfo.packageName)
              .join(', ');
    _dispatch(
      SecurityThreatEvent(
        threatName: 'malware',
        level: SecurityThreatLevel.severe,
        message: 'Suspicious applications detected on device: $names',
      ),
    );
  }

  void _dispatch(SecurityThreatEvent event) {
    // Every detection is logged and emitted; only the notice is gated.
    _threatController.add(event);
    _log(event);
    if (event.level == SecurityThreatLevel.critical && _isProd) {
      // Outside the gate: the app is about to close and must say why.
      unawaited(_notifyThenTerminate(event));
    }
  }

  bool _admitsNotice(SecurityThreatEvent event) {
    if (event.level == SecurityThreatLevel.critical && _isProd) return false;
    // A permitted capture must not put a security notice into the recording.
    if (_screenCaptureAllowed &&
        (event.threatName == Threat.screenshot.name ||
            event.threatName == Threat.screenRecording.name)) {
      return false;
    }
    return _noticeGate.admit(noticeKeyFor(event));
  }

  /// What the person would read: severity and hint. Two detections with the
  /// same key produce the same text, so the gate treats them as one notice.
  @visibleForTesting
  static String noticeKeyFor(SecurityThreatEvent event) =>
      '${event.level.name}:${hintFor(event.threatName).name}';

  Future<void> _notifyThenTerminate(SecurityThreatEvent event) async {
    // Both finish before the close: the notice, so it does not read as a
    // crash, and the saved windows, so the next launch does not repeat it.
    // The gate records synchronously first, so a detection arriving
    // meanwhile is already gated.
    await Future.wait([
      _noticeGate.record(noticeKeyFor(event)),
      _notify(event),
    ]);
    _onCritical(event);
  }

  /// Keyed on the threat name, so a threat added by a later freeRASP release
  /// still gets the device hint.
  @visibleForTesting
  static SecurityHint hintFor(String threatName) => switch (threatName) {
    'appIntegrity' ||
    'unofficialStore' ||
    'obfuscationIssues' ||
    'multiInstance' ||
    'debug' ||
    'hooks' => SecurityHint.app,
    'malware' ||
    'screenshot' ||
    'screenRecording' ||
    'automation' => SecurityHint.otherApp,
    'systemVPN' ||
    'unsecureWiFi' ||
    'timeSpoofing' ||
    'locationSpoofing' => SecurityHint.network,
    _ => SecurityHint.device,
  };

  /// RASP runs before `runApp`, with no BuildContext: the chosen language
  /// from the onboarding box, else the device's, else English.
  Future<AppLocalizations> _localisations() async {
    String? code;
    try {
      final chosen =
          (await getIt<HiveHelper>().getCachedOnboarding())?.languageString;
      if (chosen != null && chosen.isNotEmpty) code = chosen;
    } catch (_) {
      // DI or the cache may not be up; the device language stands in.
    }
    code ??= PlatformDispatcher.instance.locale.languageCode;
    final supported = AppLocalizations.supportedLocales.any(
      (l) => l.languageCode == code,
    );
    return lookupAppLocalizations(Locale(supported ? code : 'en'));
  }

  Future<void> _notify(SecurityThreatEvent event) async {
    try {
      final l10n = await _localisations();
      final title = switch (event.level) {
        SecurityThreatLevel.critical => l10n.notificationSecurityAlertTitle,
        SecurityThreatLevel.severe => l10n.notificationSecurityWarningTitle,
        SecurityThreatLevel.advisory => l10n.notificationSecurityNoticeTitle,
      };
      final hint = switch (hintFor(event.threatName)) {
        SecurityHint.device => l10n.notificationSecurityHintDevice,
        SecurityHint.app => l10n.notificationSecurityHintApp,
        SecurityHint.otherApp => l10n.notificationSecurityHintOtherApp,
        SecurityHint.network => l10n.notificationSecurityHintNetwork,
      };
      final message = event.level == SecurityThreatLevel.critical
          ? '$hint ${l10n.notificationSecurityClosing}'
          : hint;
      await NotificationService().showNotification(
        title: title,
        message: message,
        id: securityNoticeId,
      );
    } catch (_) {
      // Notifications may be unavailable; the event is already logged.
    }
  }

  static SecurityThreatEvent _classify(Threat threat) {
    final (level, message) = switch (threat) {
      Threat.privilegedAccess => (
        SecurityThreatLevel.critical,
        'Root or jailbreak detected.',
      ),
      Threat.hooks => (
        SecurityThreatLevel.critical,
        'Hooking framework (Frida, Xposed) detected.',
      ),
      Threat.appIntegrity => (
        SecurityThreatLevel.critical,
        'Binary tampered with or re-signed with an untrusted certificate.',
      ),
      Threat.debug => (
        SecurityThreatLevel.critical,
        'Debugger attached in production.',
      ),
      Threat.obfuscationIssues => (
        SecurityThreatLevel.critical,
        'Code obfuscation is missing.',
      ),
      Threat.unofficialStore => (
        SecurityThreatLevel.severe,
        'Installed from an unofficial distribution channel.',
      ),
      Threat.simulator => (
        SecurityThreatLevel.severe,
        'Running on an emulator or simulator.',
      ),
      Threat.multiInstance => (
        SecurityThreatLevel.severe,
        'Multiple concurrent instances of the app.',
      ),
      Threat.deviceBinding => (
        SecurityThreatLevel.severe,
        'Device-binding anomaly: possible app clone.',
      ),
      Threat.bootloader => (
        SecurityThreatLevel.severe,
        'Bootloader unlocked; chain of trust broken.',
      ),
      Threat.passcode => (SecurityThreatLevel.advisory, 'No screen lock set.'),
      Threat.secureHardwareNotAvailable => (
        SecurityThreatLevel.advisory,
        'Secure hardware unavailable; software key storage.',
      ),
      Threat.systemVPN => (
        SecurityThreatLevel.advisory,
        'Traffic routed through a system VPN.',
      ),
      Threat.devMode => (
        SecurityThreatLevel.advisory,
        'Developer mode enabled.',
      ),
      Threat.adbEnabled => (
        SecurityThreatLevel.advisory,
        'USB debugging enabled.',
      ),
      Threat.screenshot => (
        SecurityThreatLevel.advisory,
        'Screenshot taken while Tabibu was in the foreground.',
      ),
      Threat.screenRecording => (
        SecurityThreatLevel.advisory,
        'Screen recording while Tabibu was in the foreground.',
      ),
      Threat.unsecureWiFi => (
        SecurityThreatLevel.advisory,
        'Connected to an open or weakly secured Wi-Fi network.',
      ),
      Threat.timeSpoofing => (
        SecurityThreatLevel.advisory,
        'Device clock manipulation detected.',
      ),
      Threat.locationSpoofing => (
        SecurityThreatLevel.advisory,
        'Location spoofing detected.',
      ),
      Threat.automation => (
        SecurityThreatLevel.advisory,
        'Automated interaction detected.',
      ),
      Threat.deviceId => (
        SecurityThreatLevel.advisory,
        'Reinstall detected; device identity changed.',
      ),
    };
    return SecurityThreatEvent(
      threatName: threat.name,
      level: level,
      message: message,
    );
  }

  void _log(SecurityThreatEvent event) {
    log(
      '[RaspService] ${event.threatName} (${event.level.name}): '
      '${event.message}',
    );
    try {
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          Exception(event.message),
          StackTrace.current,
          reason: '[RASP] ${event.threatName}',
          fatal: event.level == SecurityThreatLevel.critical,
        ),
      );
    } catch (_) {
      // Crashlytics is unavailable when Firebase did not initialise.
    }
  }

  /// `killOnBypass` already terminates at the SDK when freeRASP itself is
  /// bypassed; this covers threats that reach the callbacks.
  static void _defaultCriticalHandler(SecurityThreatEvent event) {
    log('[RaspService] Critical threat, terminating: ${event.message}');
    exit(0);
  }

  Future<void> dispose() => _threatController.close();
}
