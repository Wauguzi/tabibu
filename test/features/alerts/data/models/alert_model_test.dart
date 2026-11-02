import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/alerts/data/models/alert_model.dart';

Map<String, dynamic> emptyEvidence() => {
  'confirmedCount': 0,
  'baselineMean': 0.0,
  'baselineSd': 0.0,
  'threshold': 0.0,
  'floor': 0,
  'windowWeeks': 0,
  'multiplier': 0.0,
  'ageBandCounts': <String, int>{},
  'manualRequests': 0,
  'categoryVerified': false,
  'mappingVerified': false,
  'categorySourceId': '',
  'weekStart': '',
};

Map<String, dynamic> alertJson() => {
  'uid': 'alert-1',
  'signalUid': 'sig-1',
  'diseaseId': 'cholera',
  'countyId': 1,
  'countyName': 'Nairobi',
  'epiWeek': '2026-W44',
  'category': 'Immediate',
  'rule': 'Immediate',
  'status': 'Draft',
  'draftRevision': 1,
  'requestCount': 1,
  'evidenceRevision': 2,
  'draftSource': 'Model',
  'machineText': {
    'patient_en': {'headline': 'Cholera alert', 'body': 'Seek care.'},
    'patient_sw': {'headline': 'Cholera alert', 'body': 'Seek care.'},
    'clinician_en': {'headline': 'Cholera', 'body': 'Three cases.'},
    'clinician_sw': {'headline': 'Cholera', 'body': 'Three cases.'},
  },
  'models': {'draft': 'v1'},
  'failureReason': '',
  'evidence': {
    ...emptyEvidence(),
    'confirmedCount': 3,
    'weekStart': '2026-10-26',
  },
  'audience': 'CliniciansThenPatients',
  'decision': '',
  'decidedByUid': '',
  'decidedByName': '',
  'decidedAt': '',
  'rejectReason': '',
  'approvedText': <String, Object>{},
  'approvedEvidence': emptyEvidence(),
  'acceptedUnchanged': false,
  'editedKeys': <String>[],
  'editDistance': 0.0,
  'evidenceRetracted': false,
  'deliveredTo': '',
  'deliveredAt': '',
  'requestedAt': '2026-11-01T08:00:00.000Z',
  'draftedAt': '2026-11-01T08:05:00.000Z',
  'expiresAt': '2026-11-01T20:00:00.000Z',
  'reminderSentAt': '',
  'synthetic': false,
  'createdAt': '2026-11-01T08:00:00.000Z',
  'lastUpdatedAt': '2026-11-01T08:05:00.000Z',
};

void main() {
  group('AlertModel', () {
    test('fromJson round-trips through toJson', () {
      final json = alertJson();
      expect(AlertModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = AlertModel.fromJson({});
      expect(model.status, 'Drafting');
      expect(model.draftSource, 'Template');
      expect(model.audience, 'CliniciansThenPatients');
      expect(model.evidenceRevision, 0);
      expect(model.machineText, isEmpty);
    });

    test('typed getters and helpers', () {
      final draft = AlertModel.fromJson(alertJson());
      expect(draft.statusValue, AlertStatus.draft);
      expect(draft.draftSourceValue, AlertDraftSource.model);
      expect(draft.ruleValue, AlertRule.immediate);
      expect(draft.audienceValue, AlertAudience.cliniciansThenPatients);
      expect(draft.decisionValue, isNull);
      expect(draft.isAwaitingDecision, isTrue);
      expect(draft.isApprovedOrDelivered, isFalse);

      final approved = draft.copyWith(status: 'Approved', decision: 'Approve');
      expect(approved.decisionValue, ApprovalDecision.approve);
      expect(approved.isAwaitingDecision, isFalse);
      expect(approved.isApprovedOrDelivered, isTrue);
      expect(draft.copyWith(status: 'Delivered').isApprovedOrDelivered, isTrue);
    });
  });
}
