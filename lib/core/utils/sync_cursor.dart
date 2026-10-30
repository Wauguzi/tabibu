/// Timestamp and delta-cursor primitives for every cache-first feature
/// (architecture §6).
library;

/// The single writer format for `lastUpdatedAt`: UTC, fixed-width and
/// `Z`-suffixed, so stored strings sort as instants. A local offset-less
/// string from two time zones sorts wrongly.
String syncTimestamp([DateTime? at]) =>
    (at ?? DateTime.now()).toUtc().toIso8601String();

DateTime? parseSyncTimestamp(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw)?.toUtc();
}

/// How far behind the newest cached row a delta pull starts. `lastUpdatedAt`
/// is stamped by whichever client wrote the row, so a lagging clock can
/// commit a row below a cursor already past it; re-reading a bounded overlap
/// costs a few documents, and every cache write is an upsert.
const syncCursorOverlap = Duration(hours: 24);

/// The delta cursor for [timestamps], or null when nothing is cached, which
/// callers read as "pull everything". Empty or malformed entries are
/// ignored, so one malformed row cannot force a full download.
String? syncCursorFrom(
  Iterable<String?> timestamps, {
  Duration overlap = syncCursorOverlap,
}) {
  DateTime? newest;
  for (final raw in timestamps) {
    final parsed = parseSyncTimestamp(raw);
    if (parsed == null) continue;
    if (newest == null || parsed.isAfter(newest)) newest = parsed;
  }
  if (newest == null) return null;
  return syncTimestamp(newest.subtract(overlap));
}

/// Whether a row from the cloud may replace the cached one: never over an
/// unsynced local edit, and only when it is at least as new.
bool cloudRowWins({
  required bool cachedSynced,
  required String cachedLastUpdatedAt,
  required String incomingLastUpdatedAt,
}) {
  if (!cachedSynced) return false;
  final cached = parseSyncTimestamp(cachedLastUpdatedAt);
  final incoming = parseSyncTimestamp(incomingLastUpdatedAt);
  if (cached == null || incoming == null) return true;
  return !incoming.isBefore(cached);
}
