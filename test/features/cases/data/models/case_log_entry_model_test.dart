import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/cases/data/models/case_log_entry_hive.dart';
import 'package:tabibu/features/cases/data/models/case_log_entry_model.dart';

Map<String, dynamic> caseLogEntryJson() => {
  'uid': 'uid-log-1',
  'caseUid': 'uid-case-1',
  'seq': 3,
  'fromLocation': 'Doctor',
  'fromStage': 'OrderCreated',
  'fromStep': 'RequestPathologist',
  'toLocation': 'Pathologist',
  'toStage': 'PathologistAccepted',
  'toStep': 'AwaitPathologist',
  'createdByUid': 'uid-pathologist-1',
  'actorRole': 'Pathologist',
  'actionType': '',
  'actionReason': '',
  'patientVisible': true,
  'createdAt': '2030-05-02T10:00:00.000Z',
  'lastUpdatedAt': '2030-05-02T10:00:00.000Z',
};

void main() {
  group('CaseLogEntryModel', () {
    test('fromJson parses a full row and round-trips through toJson', () {
      final json = caseLogEntryJson();
      final model = CaseLogEntryModel.fromJson(json);
      expect(model.seq, 3);
      expect(model.toStage, 'PathologistAccepted');
      expect(model.patientVisible, isTrue);
      expect(model.toJson(), json);
    });

    test('a row missing every key reads the defaults', () {
      final model = CaseLogEntryModel.fromJson({});
      expect(model, CaseLogEntryModel.empty());
      expect(model.actorRole, 'System');
    });

    test('toJson never contains synced', () {
      final model = CaseLogEntryModel.fromJson(caseLogEntryJson());
      expect(model.toJson().containsKey('synced'), isFalse);
    });

    test('typed getters read their values and fall back', () {
      final model = CaseLogEntryModel.fromJson(caseLogEntryJson());
      expect(model.fromLocationValue, CaseLocation.doctor);
      expect(model.fromStageValue, CaseStage.orderCreated);
      expect(model.fromStepValue, CaseStep.requestPathologist);
      expect(model.toLocationValue, CaseLocation.pathologist);
      expect(model.toStageValue, CaseStage.pathologistAccepted);
      expect(model.toStepValue, CaseStep.awaitPathologist);
      expect(model.actorRoleValue, ActorRole.pathologist);
      expect(model.actionTypeValue, CaseAction.none);

      final unknown = CaseLogEntryModel.fromJson({
        'fromLocation': 'Bogus',
        'fromStage': 'Bogus',
        'fromStep': 'Bogus',
        'toLocation': 'Bogus',
        'toStage': 'Bogus',
        'toStep': 'Bogus',
        'actorRole': 'Bogus',
        'actionType': 'Bogus',
      });
      expect(unknown.fromLocationValue, CaseLocation.doctor);
      expect(unknown.fromStageValue, CaseStage.orderCreated);
      expect(unknown.fromStepValue, CaseStep.none);
      expect(unknown.toLocationValue, CaseLocation.doctor);
      expect(unknown.toStageValue, CaseStage.orderCreated);
      expect(unknown.toStepValue, CaseStep.none);
      expect(unknown.actorRoleValue, ActorRole.system);
      expect(unknown.actionTypeValue, CaseAction.none);
    });
  });

  group('CaseLogEntryHive', () {
    test('fromModel maps every field', () {
      final hive = CaseLogEntryHive.fromModel(
        CaseLogEntryModel.fromJson(caseLogEntryJson()),
      );
      expect(hive.uid, 'uid-log-1');
      expect(hive.caseUid, 'uid-case-1');
      expect(hive.seq, 3);
      expect(hive.fromLocation, 'Doctor');
      expect(hive.fromStage, 'OrderCreated');
      expect(hive.fromStep, 'RequestPathologist');
      expect(hive.toLocation, 'Pathologist');
      expect(hive.toStage, 'PathologistAccepted');
      expect(hive.toStep, 'AwaitPathologist');
      expect(hive.createdByUid, 'uid-pathologist-1');
      expect(hive.actorRole, 'Pathologist');
      expect(hive.actionType, '');
      expect(hive.actionReason, '');
      expect(hive.patientVisible, isTrue);
      expect(hive.createdAt, '2030-05-02T10:00:00.000Z');
      expect(hive.lastUpdatedAt, '2030-05-02T10:00:00.000Z');
      expect(hive.synced, isTrue);
    });

    test('toModel round-trips', () {
      final model = CaseLogEntryModel.fromJson(caseLogEntryJson());
      expect(CaseLogEntryHive.fromModel(model).toModel(), model);
    });

    test('an unsynced row stays unsynced', () {
      final model = CaseLogEntryModel.fromJson(
        caseLogEntryJson(),
      ).copyWith(synced: false);
      expect(CaseLogEntryHive.fromModel(model).toModel().synced, isFalse);
    });
  });
}
