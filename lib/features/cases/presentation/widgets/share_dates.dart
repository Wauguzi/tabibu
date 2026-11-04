import 'package:intl/intl.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';

/// A stored instant as a short Nairobi date, or empty when it has none.
String shareDateLabel(String iso, String language) {
  final time = nairobiTimeOf(iso);
  return time == null ? '' : DateFormat('d MMM', language).format(time);
}

/// Whole Nairobi days from [now] until [iso], or null without a date.
int? shareDaysLeft(String iso, DateTime now) {
  final ends = nairobiTimeOf(iso);
  if (ends == null) return null;
  final left = nairobiDaysBefore(nairobiNow(now), ends);
  return left < 0 ? 0 : left;
}
