import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Decides which security detections become a notice the user sees.
///
/// freeRASP reports a condition every time it observes it: each screenshot
/// attempt, each scan that still finds a VPN, developer mode or a weak
/// network, and often several checks at once on startup. Showing each one
/// told testers the app was broken. Every detection is still logged and
/// emitted on the raw threat stream; this only limits the notices, by two
/// rules:
///
/// - **[quietWindow]**: after any notice, no other for this long, so a burst
///   reads as one message;
/// - **[repeatWindow]**: the same notice (same `key`) at most once in this
///   long, so a lasting condition is not re-announced all day.
///
/// A suppressed detection does not restart either window. The times are
/// kept in [SharedPreferences] so relaunching the app does not repeat a
/// notice; when storage is unavailable the gate still works for the session.
class SecurityNoticeGate {
  SecurityNoticeGate({
    Future<SharedPreferences> Function()? preferences,
    DateTime Function()? clock,
    this.quietWindow = const Duration(minutes: 15),
    this.repeatWindow = const Duration(hours: 24),
  }) : _preferences = preferences ?? SharedPreferences.getInstance,
       _clock = clock ?? DateTime.now;

  static const _lastAnyKey = 'security_notice_last_any';
  static const _lastByKeyKey = 'security_notice_last_by_key';

  final Future<SharedPreferences> Function() _preferences;
  final DateTime Function() _clock;
  final Duration quietWindow;
  final Duration repeatWindow;

  DateTime? _lastAny;
  final Map<String, DateTime> _lastByKey = {};

  /// Restores the windows from storage. Call before the first [admit]; a
  /// failure leaves the gate empty rather than throwing.
  Future<void> load() async {
    try {
      final prefs = await _preferences();
      _lastAny = DateTime.tryParse(prefs.getString(_lastAnyKey) ?? '');
      final raw = prefs.getString(_lastByKeyKey);
      if (raw == null) return;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      for (final MapEntry(:key, :value) in decoded.entries) {
        final at = value is String ? DateTime.tryParse(value) : null;
        if (key is String && at != null) _lastByKey[key] = at;
      }
    } on Object catch (_) {
      // Storage is a convenience here; the session windows still apply.
    }
  }

  /// Whether a notice identified by [key] may be shown now, recording it
  /// when it may. [key] names what the user would read (severity and
  /// hint), so two detections that produce the same text share a key.
  bool admit(String key) {
    final now = _clock();
    final lastAny = _lastAny;
    if (lastAny != null && now.difference(lastAny) < quietWindow) {
      return false;
    }
    final lastSame = _lastByKey[key];
    if (lastSame != null && now.difference(lastSame) < repeatWindow) {
      return false;
    }
    _record(key, now);
    return true;
  }

  /// Records a notice shown outside the gate (a critical alert, which is
  /// always shown), so the windows still count it. The windows update at
  /// once; the returned future completes when they are saved, which a caller
  /// about to terminate the app must wait for, or the next launch restores
  /// the old windows and repeats the notice.
  Future<void> record(String key) {
    final at = _clock();
    _lastAny = at;
    _lastByKey[key] = at;
    return _save();
  }

  void _record(String key, DateTime at) {
    _lastAny = at;
    _lastByKey[key] = at;
    unawaited(_save());
  }

  Future<void> _save() async {
    try {
      final prefs = await _preferences();
      await prefs.setString(_lastAnyKey, _lastAny!.toUtc().toIso8601String());
      await prefs.setString(
        _lastByKeyKey,
        jsonEncode({
          for (final MapEntry(:key, :value) in _lastByKey.entries)
            key: value.toUtc().toIso8601String(),
        }),
      );
    } on Object catch (_) {
      // Not persisted this time; the in-memory windows still hold.
    }
  }
}
