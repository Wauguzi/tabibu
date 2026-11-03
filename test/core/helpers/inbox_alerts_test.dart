import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/helpers/inbox_alerts.dart';
import 'package:tabibu/features/notifications/data/models/notification_model.dart';

void main() {
  final now = DateTime.utc(2026, 11, 4, 9);

  NotificationModel row(
    String uid, {
    Duration age = Duration.zero,
    String scope = 'Cloud',
    String status = 'Unread',
  }) => NotificationModel(
    uid: uid,
    scope: scope,
    status: status,
    creationDate: now.subtract(age).toIso8601String(),
  );

  InboxAlerts alerts() => InboxAlerts(now: () => now);

  test('the first load only records what is there', () {
    final inbox = alerts();

    expect(inbox.arrivals([row('a'), row('b')]), isEmpty);
    // Same rows again: still nothing.
    expect(inbox.arrivals([row('a'), row('b')]), isEmpty);
  });

  test('a new unread cloud row after that is announced once', () {
    final inbox = alerts()..arrivals([row('a')]);

    final first = inbox.arrivals([row('a'), row('b')]);
    expect(first.map((r) => r.uid), ['b']);
    expect(inbox.arrivals([row('a'), row('b')]), isEmpty);
  });

  test('a row that is old, local or already read is history', () {
    final inbox = alerts()..arrivals([row('a')]);

    final shown = inbox.arrivals([
      row('a'),
      row('old', age: const Duration(minutes: 5)),
      row('local', scope: 'Local'),
      row('read', status: 'Read'),
      row('news', age: const Duration(seconds: 20)),
    ]);

    expect(shown.map((r) => r.uid), ['news']);
  });

  test('a row with no readable date is not announced', () {
    final inbox = alerts()..arrivals([row('a')]);

    final shown = inbox.arrivals([
      row('a'),
      const NotificationModel(uid: 'nodate', creationDate: 'not a date'),
    ]);

    expect(shown, isEmpty);
  });

  test('a new sign-in starts from nothing', () {
    final inbox = alerts()
      ..arrivals([row('a')])
      ..reset();

    // The first load after the reset is seeded again, not announced.
    expect(inbox.arrivals([row('a'), row('b')]), isEmpty);
    expect(inbox.arrivals([row('a'), row('b'), row('c')]).map((r) => r.uid), [
      'c',
    ]);
  });
}
