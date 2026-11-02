import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/orders/data/models/lab_test_type_model.dart';

void main() {
  group('LabTestTypeModel', () {
    test('fromJson parses a row and round-trips through toJson', () {
      final json = <String, dynamic>{
        'testTypeId': '9f7bb987-be79-4777-98c1-ff63ca416596',
        'name': 'Haematology',
        'testCount': 28,
      };
      final model = LabTestTypeModel.fromJson(json);
      expect(model.testTypeId, '9f7bb987-be79-4777-98c1-ff63ca416596');
      expect(model.name, 'Haematology');
      expect(model.testCount, 28);
      expect(model.toJson(), json);
    });

    test('every row in the asset parses', () {
      final rows =
          jsonDecode(File('assets/data/lab_test_types.json').readAsStringSync())
              as List;
      final models = [
        for (final row in rows)
          LabTestTypeModel.fromJson(row as Map<String, dynamic>),
      ];
      expect(models, hasLength(11));
    });
  });
}
