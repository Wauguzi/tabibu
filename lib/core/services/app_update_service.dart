import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tabibu/core/utils/app_version.dart';

/// The force-update gate the decision route awaits (architecture §8, §10).
///
/// `force_update` switches the gate on; `min_required_version` is the
/// oldest build let through. Both defaults let every build through, so a
/// failed Remote Config fetch never locks anyone out.
@lazySingleton
class AppUpdateService {
  AppUpdateService({
    @ignoreParam Future<String> Function()? currentVersion,
    @ignoreParam this._remoteConfig,
  }) : _currentVersion = currentVersion ?? _platformVersion;

  final Future<String> Function() _currentVersion;
  final FirebaseRemoteConfig? _remoteConfig;

  static Future<String> _platformVersion() async =>
      (await PackageInfo.fromPlatform()).version;

  FirebaseRemoteConfig get _config =>
      _remoteConfig ?? FirebaseRemoteConfig.instance;

  /// On resume after a real background (§9), so a release published while
  /// the app slept is enforced without a relaunch. A failed fetch keeps the
  /// values already active.
  Future<void> refresh() async {
    try {
      await _config.fetchAndActivate().timeout(const Duration(seconds: 10));
    } on Object catch (_) {}
  }

  Future<bool> isUpdateRequired() async {
    if (!_config.getBool('force_update')) return false;
    final minimum = _config.getString('min_required_version').trim();
    if (minimum.isEmpty) return false;
    return compareVersions(await _currentVersion(), minimum) < 0;
  }

  /// The store page for this platform, or null when not configured.
  /// The update screen's copy from Remote Config, or [fallback] (the ARB
  /// string) when it is unset or cannot be read.
  String remoteText(String key, String fallback) {
    try {
      final value = _config.getString(key).trim();
      return value.isEmpty ? fallback : value;
    } on Object catch (_) {
      return fallback;
    }
  }

  Uri? storeUrl({required bool isIos}) {
    final raw = _config
        .getString(isIos ? 'store_url_ios' : 'store_url_android')
        .trim()
        .replaceAll('"', '');
    final uri = Uri.tryParse(raw);
    return uri != null && uri.isAbsolute ? uri : null;
  }
}
