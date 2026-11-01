import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/cases/data/models/risk_check_hive.dart';
import 'package:tabibu/features/cases/data/models/risk_check_model.dart';

Map<String, dynamic> riskCheckJson() => {
  'uid': 'current',
  'caseUid': 'uid-case-1',
  'status': 'Ready',
  'inputLanguage': 'en',
  'suggestedLabTestIds': ['uid-test-1', 'uid-test-2'],
  'advisoryKey': 'advisory.test',
  'advisoryEn': 'Test advisory',
  'advisorySw': 'Ushauri wa mtihani',
  'models': {'screen': 'test-model-1'},
  'failureReason': '',
  'requestedAt': '2030-05-01T10:00:00.000Z',
  'readyAt': '2030-05-01T10:01:00.000Z',
  'lastUpdatedAt': '2030-05-01T10:01:00.000Z',
};

void main() {
  group('RiskCheckModel', () {
    test('fromJson parses a full row and round-trips through toJson', () {
      final json = riskCheckJson();
      final model = RiskCheckModel.fromJson(json);
      expect(model.status, 'Ready');
      expect(model.suggestedLabTestIds, ['uid-test-1', 'uid-test-2']);
      expect(model.toJson(), json);
    });

    test('a row missing every key reads the defaults', () {
      final model = RiskCheckModel.fromJson({});
      expect(model, RiskCheckModel.empty());
      expect(model.uid, 'current');
      expect(model.status, 'Queued');
    });

    test('toJson never contains synced', () {
      final model = RiskCheckModel.fromJson(riskCheckJson());
      expect(model.toJson().containsKey('synced'), isFalse);
    });

    test('typed getters read their values and fall back', () {
      final model = RiskCheckModel.fromJson(riskCheckJson());
      expect(model.statusValue, JobStatus.ready);
      expect(model.failureReasonValue, FailureReason.none);
      expect(
        RiskCheckModel.fromJson({'status': 'Bogus'}).statusValue,
        JobStatus.queued,
      );
      expect(
        RiskCheckModel.fromJson({'failureReason': 'Bogus'}).failureReasonValue,
        FailureReason.serviceError,
      );
    });
  });

  group('RiskCheckHive', () {
    test('fromModel maps every field', () {
      final hive = RiskCheckHive.fromModel(
        RiskCheckModel.fromJson(riskCheckJson()),
      );
      expect(hive.uid, 'current');
      expect(hive.caseUid, 'uid-case-1');
      expect(hive.status, 'Ready');
      expect(hive.inputLanguage, 'en');
      expect(hive.suggestedLabTestIds, ['uid-test-1', 'uid-test-2']);
      expect(hive.advisoryKey, 'advisory.test');
      expect(hive.advisoryEn, 'Test advisory');
      expect(hive.advisorySw, 'Ushauri wa mtihani');
      expect(hive.models, {'screen': 'test-model-1'});
      expect(hive.failureReason, '');
      expect(hive.requestedAt, '2030-05-01T10:00:00.000Z');
      expect(hive.readyAt, '2030-05-01T10:01:00.000Z');
      expect(hive.lastUpdatedAt, '2030-05-01T10:01:00.000Z');
      expect(hive.synced, isTrue);
    });

    test('toModel round-trips', () {
      final model = RiskCheckModel.fromJson(riskCheckJson());
      expect(RiskCheckHive.fromModel(model).toModel(), model);
    });

    test('an unsynced row stays unsynced', () {
      final model = RiskCheckModel.fromJson(
        riskCheckJson(),
      ).copyWith(synced: false);
      expect(RiskCheckHive.fromModel(model).toModel().synced, isFalse);
    });
  });
}
