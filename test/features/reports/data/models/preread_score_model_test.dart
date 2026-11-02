import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/reports/data/models/preread_score_hive.dart';
import 'package:tabibu/features/reports/data/models/preread_score_model.dart';

Map<String, dynamic> scoreJson() => {
  'uid': 'score-1',
  'caseUid': 'case-1',
  'runUid': 'run-1',
  'pathologistUid': 'path-1',
  'profile': 'None',
  'confidenceBand': 'Low',
  'urgency': 'Routine',
  'overall': 4,
  'findingsVerdict': 'Agree',
  'impressionVerdict': 'Agree',
  'measurementsVerdict': 'NotApplicable',
  'segmentationVerdict': 'NotApplicable',
  'urgencyVerdict': 'Agree',
  'comment': '',
  'prereadShownAt': '2026-11-01T08:00:00.000Z',
  'acceptedUnchanged': true,
  'scoredAt': '2026-11-01T09:00:00.000Z',
  'createdByUid': 'path-1',
  'lastUpdatedAt': '2026-11-01T09:00:00.000Z',
};

void main() {
  group('PrereadScoreModel', () {
    test('fromJson round-trips through toJson', () {
      final json = scoreJson();
      expect(PrereadScoreModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = PrereadScoreModel.fromJson({});
      expect(model.findingsVerdict, 'Agree');
      expect(model.measurementsVerdict, 'NotApplicable');
      expect(model.acceptedUnchanged, isFalse);
    });

    test('toJson never contains synced', () {
      expect(
        PrereadScoreModel.fromJson(scoreJson()).toJson().containsKey('synced'),
        isFalse,
      );
    });

    test('typed getters and computesAcceptedUnchanged', () {
      final model = PrereadScoreModel.fromJson(scoreJson());
      expect(model.findingsVerdictValue, ScoreVerdict.agree);
      expect(model.computesAcceptedUnchanged, isTrue);
      expect(
        model.copyWith(findingsVerdict: 'Disagree').computesAcceptedUnchanged,
        isFalse,
      );
    });
  });

  group('PrereadScoreHive', () {
    test('fromModel maps and round-trips unsynced', () {
      final model = PrereadScoreModel.fromJson(
        scoreJson(),
      ).copyWith(synced: false);
      expect(PrereadScoreHive.fromModel(model).toModel(), model);
    });
  });
}
