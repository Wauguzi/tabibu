import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabibu/core/services/security_notice_gate.dart';

void main() {
  late DateTime now;

  SecurityNoticeGate gate() => SecurityNoticeGate(clock: () => now);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    now = DateTime.utc(2026, 10, 2, 9);
  });

  test('admits the first notice', () {
    expect(gate().admit('advisory:network'), isTrue);
  });

  test('a burst reads as one notice: nothing else inside the quiet window', () {
    final g = gate();
    expect(g.admit('advisory:network'), isTrue);

    now = now.add(const Duration(seconds: 2));
    expect(g.admit('advisory:network'), isFalse, reason: 'same notice');
    expect(g.admit('advisory:device'), isFalse, reason: 'another notice');

    now = now.add(const Duration(minutes: 14));
    expect(g.admit('advisory:device'), isFalse, reason: 'still quiet');
  });

  test('after the quiet window, a different notice is admitted', () {
    final g = gate()..admit('advisory:network');

    now = now.add(const Duration(minutes: 15));
    expect(g.admit('advisory:device'), isTrue);
  });

  test('the same notice waits out the repeat window, so a lasting condition '
      'is not re-announced all day', () {
    final g = gate()..admit('advisory:network');

    now = now.add(const Duration(hours: 23, minutes: 59));
    expect(g.admit('advisory:network'), isFalse);

    now = now.add(const Duration(minutes: 1));
    expect(g.admit('advisory:network'), isTrue);
  });

  test('a suppressed detection does not restart the windows', () {
    final g = gate()..admit('advisory:network');

    // Suppressed attempts every minute for 14 minutes...
    for (var i = 0; i < 14; i++) {
      now = now.add(const Duration(minutes: 1));
      expect(g.admit('advisory:device'), isFalse);
    }
    // ...and the window still ends 15 minutes after the one notice shown.
    now = now.add(const Duration(minutes: 1));
    expect(g.admit('advisory:device'), isTrue);
  });

  test('awaiting record means the windows are saved, so a relaunch '
      'straight after (a critical alert closes the app) sees them', () async {
    await gate().record('critical:app');

    now = now.add(const Duration(minutes: 1));
    final relaunched = gate();
    await relaunched.load();
    expect(relaunched.admit('critical:app'), isFalse);
  });

  test('a recorded notice (a critical alert, always shown) counts toward '
      'both windows', () async {
    final g = gate();
    await g.record('critical:app');

    now = now.add(const Duration(minutes: 1));
    expect(g.admit('advisory:network'), isFalse);
  });

  test('survives a relaunch: a new gate loads the windows from '
      'storage', () async {
    gate().admit('advisory:network');
    // Let the unawaited save land.
    await Future<void>.delayed(Duration.zero);

    now = now.add(const Duration(minutes: 5));
    final relaunched = gate();
    await relaunched.load();

    expect(relaunched.admit('advisory:device'), isFalse, reason: 'quiet');
    now = now.add(const Duration(hours: 1));
    expect(relaunched.admit('advisory:network'), isFalse, reason: 'repeat');
    expect(relaunched.admit('advisory:device'), isTrue);
  });

  test('unreadable storage leaves an empty gate rather than '
      'throwing', () async {
    SharedPreferences.setMockInitialValues({
      'security_notice_last_any': 'not a date',
      'security_notice_last_by_key': '{not json',
    });
    final g = gate();
    await g.load();

    expect(g.admit('advisory:network'), isTrue);
  });

  test('storage that cannot be reached still gates the session', () async {
    final g = SecurityNoticeGate(
      clock: () => now,
      preferences: () async => throw Exception('no plugin'),
    );
    await g.load();

    expect(g.admit('advisory:network'), isTrue);
    expect(g.admit('advisory:network'), isFalse);
  });
}
