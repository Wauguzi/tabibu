import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';

void main() {
  group('nairobi time', () {
    test('a UTC instant reads in Nairobi time', () {
      final t = nairobiTimeOf('2026-11-01T22:30:00.000Z')!;
      expect((t.year, t.month, t.day, t.hour), (2026, 11, 2, 1));
    });

    test('unparsable stamps are null', () {
      expect(nairobiTimeOf(''), isNull);
      expect(nairobiTimeOf('not a date'), isNull);
    });

    test('the device zone never changes the reading', () {
      final utc = DateTime.utc(2026, 11, 2, 9);
      expect(nairobiNow(utc), nairobiNow(utc.toLocal()));
    });

    test('days are whole Nairobi calendar days, across midnight', () {
      final now = nairobiTimeOf('2026-11-02T00:30:00.000+03:00')!;
      expect(
        nairobiDaysBefore(nairobiTimeOf('2026-11-01T23:59:00+03:00')!, now),
        1,
      );
      expect(
        nairobiDaysBefore(nairobiTimeOf('2026-11-02T00:01:00+03:00')!, now),
        0,
      );
      expect(
        nairobiDaysBefore(nairobiTimeOf('2026-10-26T12:00:00+03:00')!, now),
        7,
      );
      expect(
        nairobiDaysBefore(nairobiTimeOf('2026-11-03T08:00:00+03:00')!, now),
        -1,
      );
    });

    test(
      'a span over a daylight-saving change elsewhere still counts whole days',
      () {
        // Europe and the US change clocks in late March and early November;
        // UTC-based day arithmetic is immune, local DateTime arithmetic is not.
        final now = nairobiTimeOf('2026-03-30T10:00:00+03:00')!;
        expect(
          nairobiDaysBefore(nairobiTimeOf('2026-03-29T10:00:00+03:00')!, now),
          1,
        );
      },
    );
  });
}
