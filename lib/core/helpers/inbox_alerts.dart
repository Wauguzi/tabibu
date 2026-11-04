import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/notifications/data/models/notification_model.dart';

/// Picks the inbox rows that arrived while the app was open and are news: the
/// notification service shows each one as it lands. Rows already there when the
/// inbox first loaded, or older than [freshFor], are history and are never
/// announced.
class InboxAlerts {
  InboxAlerts({
    this.freshFor = const Duration(minutes: 2),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final Duration freshFor;
  final DateTime Function() _now;
  final _seen = <String>{};
  var _seeded = false;

  /// A new sign-in starts from nothing.
  void reset() {
    _seen.clear();
    _seeded = false;
  }

  /// The rows in [items] not seen before that are unread cloud notifications
  /// from the last [freshFor]. The first call only records what is there.
  List<NotificationModel> arrivals(List<NotificationModel> items) {
    final fresh = [
      for (final row in items)
        if (!_seen.contains(row.uid)) row,
    ];
    _seen.addAll(items.map((row) => row.uid));
    if (!_seeded) {
      _seeded = true;
      return const [];
    }
    final cutoff = _now().toUtc().subtract(freshFor);
    return [
      for (final row in fresh)
        if (row.scopeValue == NotificationScope.cloud &&
            !row.isRead &&
            (DateTime.tryParse(row.creationDate)?.isAfter(cutoff) ?? false))
          row,
    ];
  }
}
