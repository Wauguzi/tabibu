import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/preread/data/models/preread_label_model.dart';
import 'package:tabibu/features/preread/data/models/preread_model.dart';

Map<String, dynamic> prereadJson() => {
  'uid': 'run-1',
  'caseUid': 'case-1',
  'profile': 'Cancer',
  'status': 'Ready',
  'imagePaths': ['slides/a.png'],
  'micronsPerPixel': 0.25,
  'segmentationPath': 'seg.json',
  'labelsPath': 'labels.json',
  'labelCounts': {'tumor': 2},
  'measurements': {'size': 1.5},
  'draft': {
    'findings': [
      {
        'text': 'Focus',
        'evidenceIds': ['e1'],
      },
    ],
    'impression': 'Likely benign',
    'confidence': 0.8,
    'confidenceBand': 'High',
    'urgency': 'Routine',
    'nextSteps': ['Correlate clinically'],
  },
  'models': {'spark': '1.3'},
  'inputLanguage': 'en',
  'failureReason': '',
  'requestedAt': '2026-11-01T07:00:00.000Z',
  'startedAt': '2026-11-01T07:01:00.000Z',
  'readyAt': '2026-11-01T07:05:00.000Z',
  'lastUpdatedAt': '2026-11-01T07:05:00.000Z',
};

void main() {
  group('PrereadModel', () {
    test('fromJson round-trips through toJson', () {
      final json = prereadJson();
      expect(PrereadModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = PrereadModel.fromJson({});
      expect(model.status, 'Queued');
      expect(model.draft.findings, isEmpty);
      expect(model.isReady, isFalse);
    });

    test('typed getters and isReady', () {
      final model = PrereadModel.fromJson(prereadJson());
      expect(model.profileValue, PrereadProfile.cancer);
      expect(model.statusValue, JobStatus.ready);
      expect(model.isReady, isTrue);
      expect(model.draft.confidenceBandValue, ConfidenceBand.high);
      expect(model.draft.urgencyValue, Urgency.routine);
    });
  });

  group('PrereadLabelModel', () {
    test('fromJson round-trips and defaults', () {
      final json = {
        'id': 'l1',
        'imageUid': 'img-1',
        'label': 'tumor',
        'probability': 0.9,
      };
      expect(PrereadLabelModel.fromJson(json).toJson(), json);
      expect(PrereadLabelModel.fromJson({}).probability, 0);
    });
  });
}
