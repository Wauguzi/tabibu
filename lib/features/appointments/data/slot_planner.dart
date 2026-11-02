import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';

/// SLOT_MINUTES — every bookable start sits on this grid.
const slotMinutes = 30;

/// HORIZON_DAYS — bookable window length from `now`.
const horizonDays = 31;

/// MIN_LEAD_MS — a start earlier than this after `now` is taken.
const int minLeadMs = 60 * 60 * 1000;

/// Nairobi is UTC+3 with no daylight saving (NAIROBI_OFFSET_MS).
const int nairobiOffsetMs = 3 * 60 * 60 * 1000;

/// DEFAULT_DAY_START_MINUTE / DEFAULT_DAY_END_MINUTE (identity.ts).
const _defaultDayStartMinute = 480;
const _defaultDayEndMinute = 1020;
const int _slotMs = slotMinutes * 60 * 1000;
const int _dayMs = 24 * 60 * 60 * 1000;

/// One Nairobi calendar day of planned slots for the booking sheet.
class PlannedDay {
  const PlannedDay({required this.date, required this.slots});

  /// Nairobi calendar date, time 00:00 (UTC Y-M-D of that civil date).
  final DateTime date;
  final List<PlannedSlot> slots;

  bool get available => slots.any((s) => !s.taken);
}

/// One 30-minute start on the booking grid.
class PlannedSlot {
  const PlannedSlot({required this.start, required this.taken});

  /// UTC instant on the 30-minute grid.
  final DateTime start;

  /// Overlaps a busy slot, or inside the lead time / past the horizon.
  final bool taken;
}

/// Turns a doctor's public profile into the days and slots the booking sheet
/// shows. Must match `functions/src/appointments.ts` exactly.
class SlotPlanner {
  const SlotPlanner();

  /// Every bookable day from [now] (inclusive) to the horizon, in Nairobi time.
  List<PlannedDay> days(PractitionerModel doctor, DateTime now) {
    final instant = now.toUtc();
    final availability = _availabilityOf(doctor);
    final busy = _liveBusy(doctor.busySlots, instant);
    final nairobi = instant.add(const Duration(milliseconds: nairobiOffsetMs));
    final today = DateTime.utc(nairobi.year, nairobi.month, nairobi.day);
    final leadCutoff = instant.millisecondsSinceEpoch + minLeadMs;
    final horizonCutoff = instant.millisecondsSinceEpoch + horizonDays * _dayMs;

    return [
      for (var i = 0; i <= horizonDays; i++)
        _day(
          date: today.add(Duration(days: i)),
          availability: availability,
          busy: busy,
          leadCutoff: leadCutoff,
          horizonCutoff: horizonCutoff,
        ),
    ];
  }

  PlannedDay _day({
    required DateTime date,
    required ({List<int> workingDays, int dayStartMinute, int dayEndMinute})
    availability,
    required List<DateTime> busy,
    required int leadCutoff,
    required int horizonCutoff,
  }) {
    // availabilityOf — a day outside workingDays has no slots.
    if (!availability.workingDays.contains(date.weekday)) {
      return PlannedDay(date: date, slots: const []);
    }

    final slots = <PlannedSlot>[];
    // Slots on the :00/:30 grid from dayStartMinute; withinHours requires
    // start + SLOT_MINUTES <= dayEndMinute.
    for (
      var minute = availability.dayStartMinute;
      minute + slotMinutes <= availability.dayEndMinute;
      minute += slotMinutes
    ) {
      final start = _nairobiMinuteToUtc(date, minute);
      final startMs = start.millisecondsSinceEpoch;
      final taken =
          startMs < leadCutoff ||
          startMs > horizonCutoff ||
          _overlaps(busy, start);
      slots.add(PlannedSlot(start: start, taken: taken));
    }
    return PlannedDay(date: date, slots: slots);
  }

  /// availabilityOf — a malformed dayStart/dayEnd pair takes the defaults.
  ({List<int> workingDays, int dayStartMinute, int dayEndMinute})
  _availabilityOf(PractitionerModel doctor) {
    final days = {
      for (final d in doctor.workingDays)
        if (d >= 1 && d <= 7) d,
    }.toList()..sort();
    final start = doctor.dayStartMinute;
    final end = doctor.dayEndMinute;
    final valid = start >= 0 && end <= 1440 && start < end;
    return (
      workingDays: days,
      dayStartMinute: valid ? start : _defaultDayStartMinute,
      dayEndMinute: valid ? end : _defaultDayEndMinute,
    );
  }

  /// overlaps — `aStart < bEnd && bStart < aEnd` on one 30-minute grid.
  bool _overlaps(List<DateTime> busy, DateTime start) {
    final end = start.millisecondsSinceEpoch + _slotMs;
    final startMs = start.millisecondsSinceEpoch;
    for (final other in busy) {
      final otherMs = other.millisecondsSinceEpoch;
      if (otherMs < end && startMs < otherMs + _slotMs) return true;
    }
    return false;
  }

  /// liveSlots — past and unparsable busy entries are ignored.
  List<DateTime> _liveBusy(List<String> raw, DateTime now) {
    final cutoff = now.millisecondsSinceEpoch;
    return [
      for (final entry in raw)
        if (DateTime.tryParse(entry) case final parsed?)
          if (parsed.toUtc().millisecondsSinceEpoch >= cutoff) parsed.toUtc(),
    ];
  }

  DateTime _nairobiMinuteToUtc(DateTime nairobiDate, int minute) {
    final midnightUtc = DateTime.utc(
      nairobiDate.year,
      nairobiDate.month,
      nairobiDate.day,
    ).subtract(const Duration(milliseconds: nairobiOffsetMs));
    return midnightUtc.add(Duration(minutes: minute));
  }
}
