import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/appointments/data/slot_planner.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';

PractitionerModel _doctor({
  List<int>? workingDays,
  int? dayStartMinute,
  int? dayEndMinute,
  List<String> busySlots = const [],
}) => PractitionerModel.empty().copyWith(
  uid: 'd1',
  firstName: 'Wanjiru',
  lastName: 'Kamau',
  isAvailable: true,
  workingDays: workingDays ?? const [1, 2, 3, 4, 5],
  dayStartMinute: dayStartMinute ?? 480,
  dayEndMinute: dayEndMinute ?? 1020,
  busySlots: busySlots,
);

void main() {
  const planner = SlotPlanner();

  // Monday 2026-11-02 07:00Z = 10:00 Nairobi, inside default hours.
  final mondayMorning = DateTime.utc(2026, 11, 2, 7);

  group('SlotPlanner', () {
    test('availabilityOf defaults: Mon–Fri 08:00–17:00 Nairobi', () {
      final days = planner.days(PractitionerModel.empty(), mondayMorning);
      expect(days, hasLength(horizonDays + 1));
      // Monday has slots from 08:00 (still in lead) through 16:30.
      final monday = days.first;
      expect(monday.date, DateTime.utc(2026, 11, 2));
      expect(
        monday.slots.first.start,
        DateTime.utc(2026, 11, 2, 5),
      ); // 08:00 EAT
      expect(
        monday.slots.last.start,
        DateTime.utc(2026, 11, 2, 13, 30),
      ); // 16:30
      // Sunday (index 6) is outside DEFAULT_WORKING_DAYS.
      expect(days[6].slots, isEmpty);
      expect(days[6].available, isFalse);
    });

    test('availabilityOf custom dayStartMinute and dayEndMinute', () {
      // 09:00–16:00 Nairobi (540–960).
      final days = planner.days(
        _doctor(dayStartMinute: 540, dayEndMinute: 960),
        mondayMorning,
      );
      expect(days.first.slots.first.start, DateTime.utc(2026, 11, 2, 6));
      expect(days.first.slots.last.start, DateTime.utc(2026, 11, 2, 12, 30));
    });

    test('withinHours: last slot fits exactly at dayEndMinute', () {
      // dayEnd 17:00 → last start 16:30; 17:00 itself is excluded.
      final slots = planner.days(_doctor(), mondayMorning).first.slots;
      expect(slots.last.start, DateTime.utc(2026, 11, 2, 13, 30));
      expect(
        slots.any((s) => s.start == DateTime.utc(2026, 11, 2, 14)),
        isFalse,
      );
    });

    test('overlaps: a busy slot is taken; its neighbours are free', () {
      // 12:00 Nairobi = 09:00Z — past the 60-minute lead from 07:00Z, so
      // neighbours are only free if overlaps (not MIN_LEAD_MS) decides.
      final days = planner.days(
        _doctor(busySlots: ['2026-11-02T09:00:00.000Z']),
        mondayMorning,
      );
      PlannedSlot slotAt(DateTime start) =>
          days.first.slots.singleWhere((s) => s.start == start);

      expect(slotAt(DateTime.utc(2026, 11, 2, 9)).taken, isTrue);
      expect(slotAt(DateTime.utc(2026, 11, 2, 8, 30)).taken, isFalse);
      expect(slotAt(DateTime.utc(2026, 11, 2, 9, 30)).taken, isFalse);
    });

    test('MIN_LEAD_MS: 59 minutes is taken, 60 minutes is free', () {
      // now = 07:01Z → 08:00Z is 59 minutes later (taken).
      final at59 = planner.days(_doctor(), DateTime.utc(2026, 11, 2, 7, 1));
      expect(
        at59.first.slots
            .singleWhere((s) => s.start == DateTime.utc(2026, 11, 2, 8))
            .taken,
        isTrue,
      );

      // now = 07:00Z → 08:00Z is exactly 60 minutes later (free).
      final at60 = planner.days(_doctor(), DateTime.utc(2026, 11, 2, 7));
      expect(
        at60.first.slots
            .singleWhere((s) => s.start == DateTime.utc(2026, 11, 2, 8))
            .taken,
        isFalse,
      );
    });

    test('availabilityOf: Sunday outside workingDays 1–5 has no slots', () {
      // 2026-11-01 is Sunday.
      final sunday = DateTime.utc(2026, 11, 1, 7);
      final days = planner.days(_doctor(), sunday);
      expect(days.first.date.weekday, DateTime.sunday);
      expect(days.first.slots, isEmpty);
      expect(days.first.available, isFalse);
    });

    test('HORIZON_DAYS: the last day is today + 31', () {
      final days = planner.days(_doctor(), mondayMorning);
      expect(days.last.date, DateTime.utc(2026, 12, 3));
      expect(days, hasLength(32));
    });

    test('Nairobi offset: device zone does not change the answer', () {
      final utcNow = DateTime.utc(2026, 11, 2, 7);
      final localNow = utcNow.toLocal();
      expect(localNow.isUtc, isFalse);

      final fromUtc = planner.days(_doctor(), utcNow);
      final fromLocal = planner.days(_doctor(), localNow);

      expect(fromLocal.map((d) => d.date), fromUtc.map((d) => d.date));
      expect(
        fromLocal.first.slots.map((s) => (s.start, s.taken)),
        fromUtc.first.slots.map((s) => (s.start, s.taken)),
      );
    });

    test('liveSlots: an unparsable busy entry is ignored', () {
      final days = planner.days(
        _doctor(busySlots: ['not-a-date', '2026-11-02T08:00:00.000Z']),
        mondayMorning,
      );
      expect(
        days.first.slots
            .singleWhere((s) => s.start == DateTime.utc(2026, 11, 2, 8))
            .taken,
        isTrue,
      );
      expect(
        days.first.slots
            .singleWhere((s) => s.start == DateTime.utc(2026, 11, 2, 8, 30))
            .taken,
        isFalse,
      );
    });
  });
}
