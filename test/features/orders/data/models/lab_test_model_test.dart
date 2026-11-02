import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/orders/data/models/lab_test_model.dart';
import 'package:tabibu/features/orders/data/models/lab_test_type_model.dart';

void main() {
  group('LabTestModel', () {
    test('fromJson parses a row and round-trips through toJson', () {
      final json = <String, dynamic>{
        'labTestId': '9f7bb987-d194-4935-8c52-713da8b21f10',
        'testTypeId': '9f7bb987-be79-4777-98c1-ff63ca416596',
        'testTypeName': 'Haematology',
        'name': 'ABO and Rh D grouping',
        'isActive': true,
        'testPriceKes': 500,
        'isPriceEstimate': true,
        'tatCollectionToDelivery': 284,
        'tatDeliveryToResults': 4,
        'totalTurnaroundTime': 288,
      };
      final model = LabTestModel.fromJson(json);
      expect(model.labTestId, '9f7bb987-d194-4935-8c52-713da8b21f10');
      expect(model.name, 'ABO and Rh D grouping');
      expect(model.testPriceKes, 500);
      expect(model.totalTurnaroundTime, 288);
      expect(model.toJson(), json);
    });

    test('every row in the asset parses against a known type', () {
      final testRows =
          jsonDecode(File('assets/data/lab_tests.json').readAsStringSync())
              as List;
      final typeRows =
          jsonDecode(File('assets/data/lab_test_types.json').readAsStringSync())
              as List;
      final typeIds = {
        for (final row in typeRows)
          LabTestTypeModel.fromJson(row as Map<String, dynamic>).testTypeId,
      };
      final models = [
        for (final row in testRows)
          LabTestModel.fromJson(row as Map<String, dynamic>),
      ];
      expect(models, hasLength(247));
      for (final model in models) {
        expect(typeIds, contains(model.testTypeId), reason: model.name);
      }
    });
  });
}
