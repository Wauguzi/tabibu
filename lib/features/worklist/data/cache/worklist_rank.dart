import 'package:tabibu/core/utils/sync_cursor.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_model.dart';

/// Desk rank: stored [WorklistEntryModel.basePriority] plus waiting hours
/// capped at 72 (plan §2.6 / S-6). Pure; safe under any TZ.
abstract final class WorklistRank {
  /// Hours of waiting time that may raise the base priority.
  static const maxWaitingHours = 72;

  /// `basePriority + min(hoursWaiting, 72)`.
  static int score(WorklistEntryModel entry, DateTime now) {
    final since = parseSyncTimestamp(entry.waitingSince);
    if (since == null) return entry.basePriority;
    final hours = now.toUtc().difference(since).inHours;
    final capped = hours < 0
        ? 0
        : hours > maxWaitingHours
        ? maxWaitingHours
        : hours;
    return entry.basePriority + capped;
  }

  /// Desk order: [score] descending, then [WorklistEntryModel.waitingSince]
  /// ascending.
  static List<WorklistEntryModel> sorted(
    Iterable<WorklistEntryModel> entries,
    DateTime now,
  ) {
    final list = entries.toList()
      ..sort((a, b) {
        final byScore = score(b, now).compareTo(score(a, now));
        if (byScore != 0) return byScore;
        return a.waitingSince.compareTo(b.waitingSince);
      });
    return list;
  }
}
