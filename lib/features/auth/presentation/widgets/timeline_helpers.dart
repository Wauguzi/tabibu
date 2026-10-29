import 'package:intl/intl.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/l10n/l10n.dart';

/// "Today, 09:12" when the account started today, else dated; null when the
/// stored value does not parse.
String? submittedStamp(String createdAt, AppLocalizations l10n) {
  final parsed = DateTime.tryParse(createdAt)?.toLocal();
  if (parsed == null) return null;
  final time = DateFormat('HH:mm').format(parsed);
  final now = DateTime.now();
  if (parsed.year == now.year &&
      parsed.month == now.month &&
      parsed.day == now.day) {
    return l10n.pendingToday(time);
  }
  return '${DateFormat('d MMM y').format(parsed)}, $time';
}

/// "histopathology and cytology", lowercased into the sentence; capitalised
/// first when it opens one.
String areaSentence(
  List<String> specialties,
  AppLocalizations l10n, {
  bool capitalizeFirst = false,
}) {
  final areas = [
    for (final value in specialties)
      Specialty.fromValue(value)?.description(l10n).toLowerCase(),
  ].whereType<String>().toList();
  if (areas.isEmpty) return '…';
  final joined = areas.length == 1
      ? areas.single
      : '${areas.sublist(0, areas.length - 1).join(', ')} '
            '${l10n.listAnd} ${areas.last}';
  if (!capitalizeFirst) return joined;
  return joined[0].toUpperCase() + joined.substring(1);
}
