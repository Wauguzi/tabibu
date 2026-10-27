import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/utils/sync_cursor.dart';

void main() {
  test('timestamps are UTC with a Z suffix', () {
    final stamp = syncTimestamp(DateTime.utc(2026, 10, 27, 9));
    expect(stamp, '2026-10-27T09:00:00.000Z');
  });

  group('syncCursorFrom', () {
    test('null when nothing is cached', () {
      expect(syncCursorFrom(const []), isNull);
      expect(syncCursorFrom(const ['', 'not a date']), isNull);
    });

    test('a day before the newest row, ignoring malformed ones', () {
      expect(
        syncCursorFrom(const [
          '2026-10-25T09:00:00.000Z',
          'garbage',
          '2026-10-27T09:00:00.000Z',
        ]),
        '2026-10-26T09:00:00.000Z',
      );
    });
  });

  group('cloudRowWins', () {
    test('never over an unsynced local edit', () {
      expect(
        cloudRowWins(
          cachedSynced: false,
          cachedLastUpdatedAt: '2026-10-25T09:00:00.000Z',
          incomingLastUpdatedAt: '2026-10-27T09:00:00.000Z',
        ),
        isFalse,
      );
    });

    test('a newer or equal row wins; an older one does not', () {
      bool wins(String incoming) => cloudRowWins(
        cachedSynced: true,
        cachedLastUpdatedAt: '2026-10-26T09:00:00.000Z',
        incomingLastUpdatedAt: incoming,
      );
      expect(wins('2026-10-27T09:00:00.000Z'), isTrue);
      expect(wins('2026-10-26T09:00:00.000Z'), isTrue);
      expect(wins('2026-10-25T09:00:00.000Z'), isFalse);
    });

    test('an unreadable timestamp lets the cloud row in', () {
      expect(
        cloudRowWins(
          cachedSynced: true,
          cachedLastUpdatedAt: '',
          incomingLastUpdatedAt: '2026-10-25T09:00:00.000Z',
        ),
        isTrue,
      );
    });
  });
}
