import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/cases/data/models/case_payment_hive.dart';
import 'package:tabibu/features/cases/data/models/case_payment_model.dart';

Map<String, dynamic> casePaymentJson() => {
  'caseUid': 'uid-case-1',
  'method': 'Insurance',
  'insurerId': 'uid-insurer-1',
  'insurerName': 'Test Insurer',
  'policyNumber': 'POL-001',
  'createdByUid': 'uid-doctor-1',
  'createdAt': '2030-05-01T10:00:00.000Z',
  'lastUpdatedAt': '2030-05-01T10:00:00.000Z',
};

void main() {
  group('CasePaymentModel', () {
    test('fromJson parses a full row and round-trips through toJson', () {
      final json = casePaymentJson();
      final model = CasePaymentModel.fromJson(json);
      expect(model.method, 'Insurance');
      expect(model.policyNumber, 'POL-001');
      expect(model.toJson(), json);
    });

    test('a row missing every key reads the defaults', () {
      final model = CasePaymentModel.fromJson({});
      expect(model, CasePaymentModel.empty());
      expect(model.method, 'Cash');
    });

    test('toJson never contains synced', () {
      final model = CasePaymentModel.fromJson(casePaymentJson());
      expect(model.toJson().containsKey('synced'), isFalse);
    });

    test('methodValue reads the method and falls back to cash', () {
      expect(
        CasePaymentModel.fromJson(casePaymentJson()).methodValue,
        PaymentMethod.insurance,
      );
      expect(CasePaymentModel.fromJson({}).methodValue, PaymentMethod.cash);
      expect(
        CasePaymentModel.fromJson({'method': 'Bogus'}).methodValue,
        PaymentMethod.cash,
      );
    });
  });

  group('CasePaymentHive', () {
    test('fromModel maps every field', () {
      final hive = CasePaymentHive.fromModel(
        CasePaymentModel.fromJson(casePaymentJson()),
      );
      expect(hive.caseUid, 'uid-case-1');
      expect(hive.method, 'Insurance');
      expect(hive.insurerId, 'uid-insurer-1');
      expect(hive.insurerName, 'Test Insurer');
      expect(hive.policyNumber, 'POL-001');
      expect(hive.createdByUid, 'uid-doctor-1');
      expect(hive.createdAt, '2030-05-01T10:00:00.000Z');
      expect(hive.lastUpdatedAt, '2030-05-01T10:00:00.000Z');
      expect(hive.synced, isTrue);
    });

    test('toModel round-trips', () {
      final model = CasePaymentModel.fromJson(casePaymentJson());
      expect(CasePaymentHive.fromModel(model).toModel(), model);
    });

    test('an unsynced row stays unsynced', () {
      final model = CasePaymentModel.fromJson(
        casePaymentJson(),
      ).copyWith(synced: false);
      expect(CasePaymentHive.fromModel(model).toModel().synced, isFalse);
    });
  });
}
