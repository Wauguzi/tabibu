import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/cases/data/models/ordered_test_hive.dart';
import 'package:tabibu/features/cases/data/models/ordered_test_model.dart';

Map<String, dynamic> orderedTestJson() => {
  'labTestId': 'uid-test-1',
  'testTypeId': 'uid-type-1',
  'testTypeName': 'Test Type',
  'name': 'Test Name',
  'priceKes': 500,
  'isPriceEstimate': true,
};

void main() {
  group('OrderedTestModel', () {
    test('fromJson parses a full row and round-trips through toJson', () {
      final json = orderedTestJson();
      final model = OrderedTestModel.fromJson(json);
      expect(model.labTestId, 'uid-test-1');
      expect(model.name, 'Test Name');
      expect(model.priceKes, 500);
      expect(model.isPriceEstimate, isTrue);
      expect(model.toJson(), json);
    });

    test('a row missing every key reads the defaults', () {
      final model = OrderedTestModel.fromJson({});
      expect(model, OrderedTestModel.empty());
    });
  });

  group('OrderedTestHive', () {
    test('fromModel maps every field', () {
      final hive = OrderedTestHive.fromModel(
        OrderedTestModel.fromJson(orderedTestJson()),
      );
      expect(hive.labTestId, 'uid-test-1');
      expect(hive.testTypeId, 'uid-type-1');
      expect(hive.testTypeName, 'Test Type');
      expect(hive.name, 'Test Name');
      expect(hive.priceKes, 500);
      expect(hive.isPriceEstimate, isTrue);
    });

    test('toModel round-trips', () {
      final model = OrderedTestModel.fromJson(orderedTestJson());
      expect(OrderedTestHive.fromModel(model).toModel(), model);
    });
  });
}
