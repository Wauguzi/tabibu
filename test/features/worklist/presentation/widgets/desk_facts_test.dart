import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_model.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_facts.dart';
import 'package:tabibu/l10n/l10n.dart';

final _now = DateTime.utc(2026, 11, 2, 12);

WorklistEntryModel _entry({
  String preread = 'Ready',
  String band = 'High',
  double confidence = 0.94,
  String waitingSince = '',
  String profile = 'None',
}) => WorklistEntryModel(
  prereadStatus: preread,
  confidenceBand: band,
  confidence: confidence,
  waitingSince: waitingSince,
  profile: profile,
);

PathologyReportModel _report({
  String uid = 'path-1',
  String status = 'Signed',
  String startedAt = '',
  String signedAt = '',
}) => PathologyReportModel(
  pathologistUid: uid,
  status: status,
  startedAt: startedAt,
  signedAt: signedAt,
);

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('waitedOf', () {
    test('is the difference of two instants', () {
      final entry = _entry(waitingSince: '2026-11-02T10:40:00Z');
      expect(waitedOf(entry, _now), const Duration(hours: 1, minutes: 20));
    });

    test('edge case 4: a Nairobi midnight in between changes nothing', () {
      // 23:30 Nairobi on the 1st is 20:30Z; 00:30 Nairobi on the 2nd is
      // 21:30Z: one hour, though the calendar date changed.
      final entry = _entry(waitingSince: '2026-11-01T23:30:00+03:00');
      final now = DateTime.utc(2026, 11, 1, 21, 30);
      expect(waitedOf(entry, now), const Duration(hours: 1));
    });

    test('edge case 4: a device in another zone reads the same instant', () {
      // The same instant written with a UTC-5 offset, and a local `now`.
      final entry = _entry(waitingSince: '2026-11-02T05:40:00-05:00');
      final localNow = DateTime.utc(2026, 11, 2, 12).toLocal();
      expect(waitedOf(entry, localNow), const Duration(hours: 1, minutes: 20));
    });

    test('an empty or bad waitingSince has no time', () {
      expect(waitedOf(_entry(), _now), isNull);
      expect(waitedOf(_entry(waitingSince: 'soon'), _now), isNull);
    });

    test('a stamp ahead of the clock is zero, never negative', () {
      final entry = _entry(waitingSince: '2026-11-02T12:05:00Z');
      expect(waitedOf(entry, _now), Duration.zero);
    });
  });

  group('aiBandOf', () {
    test('H-18 rule 5: percent is the confidence rounded', () {
      final shown = aiBandOf(_entry())!;
      expect(shown.band, ConfidenceBand.high);
      expect(shown.percent, 94);
      expect(aiBandOf(_entry(confidence: 0.516))!.percent, 52);
    });

    test('H-18 rule 5: confidence outside 0 to 1 shows no band at all', () {
      expect(aiBandOf(_entry(confidence: 1.7)), isNull);
      expect(aiBandOf(_entry(confidence: -0.1)), isNull);
      expect(aiBandOf(_entry(confidence: double.nan)), isNull);
      expect(aiBandOf(_entry(confidence: 0))!.percent, 0);
      expect(aiBandOf(_entry(confidence: 1))!.percent, 100);
    });

    test('H-18 rule 3: only a ready pre-read has a band', () {
      for (final status in ['', 'Queued', 'Running', 'Failed']) {
        expect(aiBandOf(_entry(preread: status)), isNull, reason: status);
      }
      expect(aiBandOf(_entry()), isNotNull);
    });
  });

  group('counts', () {
    test('H-18 rule 3: low confidence counts only a ready pre-read', () {
      expect(isLowConfidence(_entry(band: 'Low', confidence: 0.52)), isTrue);
      expect(
        isLowConfidence(_entry(band: 'Low', confidence: 0.52, preread: '')),
        isFalse,
      );
      expect(isLowConfidence(_entry(band: 'Low', confidence: 1.7)), isFalse);
      expect(isLowConfidence(_entry()), isFalse);
    });

    test('a case waits long only past four hours', () {
      expect(
        isWaitingLong(_entry(waitingSince: '2026-11-02T08:00:00Z'), _now),
        isFalse,
      );
      expect(
        isWaitingLong(_entry(waitingSince: '2026-11-02T07:59:00Z'), _now),
        isTrue,
      );
      expect(isWaitingLong(_entry(), _now), isFalse);
    });

    test('the malaria profile stands in for notifiable', () {
      expect(isNotifiable(_entry(profile: 'Malaria')), isTrue);
      expect(isNotifiable(_entry()), isFalse);
    });

    test('the oldest wait skips unreadable stamps', () {
      final oldest = oldestWait([
        _entry(waitingSince: '2026-11-02T10:00:00Z'),
        _entry(waitingSince: '2026-11-02T06:50:00Z'),
        _entry(),
      ], _now);
      expect(oldest, const Duration(hours: 5, minutes: 10));
      expect(oldestWait([_entry()], _now), isNull);
    });
  });

  group('labels', () {
    test('elapsed reads hours and minutes, or minutes alone', () {
      expect(elapsedLabel(l10n, const Duration(hours: 2, minutes: 5)), '2h 5m');
      expect(elapsedLabel(l10n, const Duration(minutes: 45)), '45m');
      expect(elapsedLabel(l10n, Duration.zero), '0m');
    });

    test('H-18 rule 5: band and percent together', () {
      expect(
        bandLabel(l10n, (band: ConfidenceBand.high, percent: 94)),
        'High 94%',
      );
      expect(
        bandLabel(l10n, (band: ConfidenceBand.moderate, percent: 78)),
        'Moderate 78%',
      );
      expect(
        bandLabel(l10n, (band: ConfidenceBand.low, percent: 52)),
        'Low confidence · 52%',
      );
    });
  });

  group('patientOf', () {
    CaseModel named(String name, [int age = 0]) =>
        CaseModel(patientName: name, patientAgeYears: age);

    test('is the first name and last initial with the age', () {
      expect(patientOf(named('Amina Wambui', 46))!.label, 'Amina W., 46');
      expect(patientOf(named('Mary Achieng Njeri'))!.name, 'Mary N.');
    });

    test('has no age when the case carries none, and no case no patient', () {
      expect(patientOf(named('Amina Wambui'))!.label, 'Amina W.');
      expect(patientOf(named('Amina'))!.label, 'Amina');
      expect(patientOf(named('  ')), isNull);
      expect(patientOf(null), isNull);
    });

    test('joins on the case uid only when there is one', () {
      final cases = [const CaseModel(uid: 'c1', patientName: 'Amina Wambui')];
      expect(caseOf(cases, const WorklistEntryModel(caseUid: 'c1')), cases[0]);
      expect(caseOf(cases, const WorklistEntryModel(caseUid: 'c2')), isNull);
      expect(caseOf(cases, const WorklistEntryModel()), isNull);
    });
  });

  group('signedTodayOf', () {
    test('counts mine since Nairobi midnight with the average minutes', () {
      // 12:00Z is 15:00 in Nairobi on the 2nd; midnight Nairobi was 21:00Z.
      final signed = signedTodayOf(
        [
          _report(
            startedAt: '2026-11-02T08:00:00Z',
            signedAt: '2026-11-02T08:20:00Z',
          ),
          _report(
            startedAt: '2026-11-02T09:00:00Z',
            signedAt: '2026-11-02T09:10:00Z',
          ),
          // Signed at 00:30 Nairobi today (21:30Z yesterday): today.
          _report(signedAt: '2026-11-01T21:30:00Z'),
          // 23:30 Nairobi yesterday: not today.
          _report(signedAt: '2026-11-01T20:30:00Z'),
          _report(uid: 'someone-else', signedAt: '2026-11-02T08:00:00Z'),
          _report(status: 'Superseded', signedAt: '2026-11-02T08:00:00Z'),
        ],
        'path-1',
        _now,
      );
      expect(signed.count, 3);
      expect(signed.averageMinutes, 15);
    });

    test('has no average when none carries both stamps', () {
      final signed = signedTodayOf(
        [_report(signedAt: '2026-11-02T08:00:00Z')],
        'path-1',
        _now,
      );
      expect(signed, (count: 1, averageMinutes: null));
    });

    test('is zero with no uid or nothing signed', () {
      expect(signedTodayOf([_report()], '', _now).count, 0);
      expect(signedTodayOf(const [], 'path-1', _now).count, 0);
    });
  });
}
