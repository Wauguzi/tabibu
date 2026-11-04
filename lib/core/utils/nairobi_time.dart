/// Kenya keeps one offset all year (no daylight saving), and every date the
/// app shows is in Nairobi time, whatever zone the device is set to.
const nairobiOffset = Duration(hours: 3);

/// Now, as a Nairobi wall-clock time (a UTC `DateTime` carrying Nairobi's
/// fields, so its arithmetic never meets a device-zone clock change).
DateTime nairobiNow([DateTime? now]) =>
    (now ?? DateTime.now()).toUtc().add(nairobiOffset);

/// A stored ISO-8601 instant as a Nairobi wall-clock time, or null.
DateTime? nairobiTimeOf(String iso) =>
    DateTime.tryParse(iso)?.toUtc().add(nairobiOffset);

/// Whole Nairobi calendar days from [time] to [now]: 0 today, 1 yesterday,
/// negative in the future. Both are Nairobi wall-clock times.
int nairobiDaysBefore(DateTime time, DateTime now) => DateTime.utc(
  now.year,
  now.month,
  now.day,
).difference(DateTime.utc(time.year, time.month, time.day)).inDays;
