import 'package:intl/intl.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';

/// A stored instant as Nairobi wall-clock text, or '' when it is empty or
/// unreadable so the caller can leave the row out. [withYear] adds the year.
String reportDateTimeLabel(String iso, String locale, {bool withYear = false}) {
  final at = nairobiTimeOf(iso);
  if (at == null) return '';
  final pattern = withYear ? 'd MMM y, h:mm a' : 'd MMM, h:mm a';
  return DateFormat(pattern, locale).format(at);
}
