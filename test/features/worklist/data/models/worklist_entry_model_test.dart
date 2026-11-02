import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_hive.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_model.dart';

Map<String, dynamic> worklistJson() => {
  'uid': 'case-1',
  'caseUid': 'case-1',
  'pathologistUid': 'path-1',
  'orderNumber': 'ODR-1',
  'testName': 'Histopathology',
  'profile': 'None',
  'status': 'Open',
  'prereadStatus': 'Ready',
  'urgency': 'Routine',
  'confidenceBand': 'Low',
  'confidence': 0.4,
  'riskFlag': false,
  'severity': 'Routine',
  'basePriority': 10,
  'waitingSince': '2026-11-01T08:00:00.000Z',
  'assignedAt': '2026-11-01T08:30:00.000Z',
  'lastUpdatedAt': '2026-11-01T08:30:00.000Z',
};

void main() {
  group('WorklistEntryModel', () {
    test('fromJson round-trips through toJson', () {
      final json = worklistJson();
      expect(WorklistEntryModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = WorklistEntryModel.fromJson({});
      expect(model.status, 'Open');
      expect(model.prereadStatus, '');
      expect(model.urgency, 'Routine');
      expect(model.prereadStatusValue, isNull);
    });

    test('toJson never contains synced', () {
      expect(
        WorklistEntryModel.fromJson(
          worklistJson(),
        ).toJson().containsKey('synced'),
        isFalse,
      );
    });

    test('typed getters and isOpen', () {
      final model = WorklistEntryModel.fromJson(worklistJson());
      expect(model.statusValue, WorklistStatus.open);
      expect(model.prereadStatusValue, JobStatus.ready);
      expect(model.urgencyValue, Urgency.routine);
      expect(model.severityValue, Urgency.routine);
      expect(model.isOpen, isTrue);
      expect(model.copyWith(status: 'Closed').isOpen, isFalse);
    });
  });

  group('WorklistEntryHive', () {
    test('fromModel maps and round-trips unsynced', () {
      final model = WorklistEntryModel.fromJson(
        worklistJson(),
      ).copyWith(synced: false);
      expect(WorklistEntryHive.fromModel(model).toModel(), model);
    });
  });
}
