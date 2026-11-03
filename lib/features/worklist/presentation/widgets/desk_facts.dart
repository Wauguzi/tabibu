import 'package:collection/collection.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/utils/sync_cursor.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_model.dart';
import 'package:tabibu/l10n/l10n.dart';

/// A case waits "long" once it is past this, as the desk's filter counts it.
const deskLongWait = Duration(hours: 4);

/// The AI's confidence band with the percentage it is always shown with.
typedef AiBand = ({ConfidenceBand band, int percent});

/// How long [entry] has waited: the difference of two instants, so the
/// device's zone and a Nairobi midnight change nothing. Null when
/// `waitingSince` is empty or unreadable; a stamp slightly ahead of the
/// clock reads as no time yet, never negative.
Duration? waitedOf(WorklistEntryModel entry, DateTime now) {
  final since = parseSyncTimestamp(entry.waitingSince);
  if (since == null) return null;
  final waited = now.toUtc().difference(since);
  return waited.isNegative ? Duration.zero : waited;
}

/// Whether [entry] has waited longer than [deskLongWait].
bool isWaitingLong(WorklistEntryModel entry, DateTime now) {
  final waited = waitedOf(entry, now);
  return waited != null && waited > deskLongWait;
}

/// The band to show for [entry], or null. Only a ready pre-read speaks for the
/// AI, and a band is never shown without its percentage: a confidence outside
/// 0 to 1 (or not a number) hides both.
AiBand? aiBandOf(WorklistEntryModel entry) {
  if (entry.prereadStatusValue != .ready) return null;
  final confidence = entry.confidence;
  if (!(confidence >= 0 && confidence <= 1)) return null;
  return (band: entry.confidenceBandValue, percent: (confidence * 100).round());
}

/// Whether the desk counts [entry] as low confidence: a ready pre-read whose
/// shown band is Low.
bool isLowConfidence(WorklistEntryModel entry) => aiBandOf(entry)?.band == .low;

/// Whether the desk calls [entry] a notifiable case. The worklist carries no
/// flag, so the malaria profile stands in, as the desk's filter does.
bool isNotifiable(WorklistEntryModel entry) =>
    entry.profileValue == PrereadProfile.malaria;

/// The longest wait among [entries], or null when none can be read.
Duration? oldestWait(Iterable<WorklistEntryModel> entries, DateTime now) {
  Duration? oldest;
  for (final entry in entries) {
    final waited = waitedOf(entry, now);
    if (waited != null && (oldest == null || waited > oldest)) oldest = waited;
  }
  return oldest;
}

/// "1h 20m" or "45m".
String elapsedLabel(AppLocalizations l10n, Duration waited) =>
    waited.inHours > 0
    ? l10n.deskElapsedHours(waited.inHours, waited.inMinutes % 60)
    : l10n.deskElapsedMinutes(waited.inMinutes);

/// "High 94%" or "Low confidence · 52%".
String bandLabel(AppLocalizations l10n, AiBand shown) {
  final percent = '${shown.percent}%';
  return switch (shown.band) {
    .low => l10n.deskLowConfidenceRow(percent),
    .moderate => l10n.deskBandRow(l10n.deskBandModerate, percent),
    .high => l10n.deskBandRow(l10n.deskBandHigh, percent),
  };
}

/// A patient as the desk names them: first name and last initial, with age.
class DeskPatient {
  const DeskPatient({required this.name, required this.age});

  final String name;

  /// 0 when the case carries none.
  final int age;

  /// "Amina W., 46", or the name alone without an age.
  String get label => age > 0 ? '$name, $age' : name;
}

/// The patient behind [caseModel], or null when there is no case or no name.
DeskPatient? patientOf(CaseModel? caseModel) {
  if (caseModel == null) return null;
  final parts = caseModel.patientName
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return null;
  final name = parts.length == 1
      ? parts.first
      : '${parts.first} ${String.fromCharCode(parts.last.runes.first)}.';
  return DeskPatient(name: name, age: caseModel.patientAgeYears);
}

/// The case [entry] sits on, joined on `caseUid`.
CaseModel? caseOf(List<CaseModel> cases, WorklistEntryModel entry) =>
    entry.caseUid.isEmpty
    ? null
    : cases.firstWhereOrNull((c) => c.uid == entry.caseUid);

/// Reports [uid] signed since Nairobi midnight, with the average minutes from
/// `startedAt` to `signedAt` over those that carry both (null when none do).
({int count, int? averageMinutes}) signedTodayOf(
  List<PathologyReportModel> reports,
  String uid,
  DateTime now,
) {
  if (uid.isEmpty) return (count: 0, averageMinutes: null);
  final today = nairobiNow(now);
  var count = 0;
  final minutes = <int>[];
  for (final report in reports) {
    if (!report.isCurrent || report.pathologistUid != uid) continue;
    final signed = nairobiTimeOf(report.signedAt);
    if (signed == null || nairobiDaysBefore(signed, today) != 0) continue;
    count++;
    final started = nairobiTimeOf(report.startedAt);
    if (started == null) continue;
    final taken = signed.difference(started);
    if (!taken.isNegative) minutes.add(taken.inMinutes);
  }
  final average = minutes.isEmpty
      ? null
      : (minutes.reduce((a, b) => a + b) / minutes.length).round();
  return (count: count, averageMinutes: average);
}
