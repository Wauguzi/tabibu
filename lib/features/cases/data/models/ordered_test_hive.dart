import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/cases/data/models/ordered_test_model.dart';

part 'ordered_test_hive.g.dart';

/// Cached [OrderedTestModel], in the same field order.
@HiveType(typeId: 5)
class OrderedTestHive {
  OrderedTestHive({
    required this.labTestId,
    required this.testTypeId,
    required this.testTypeName,
    required this.name,
    required this.priceKes,
    required this.isPriceEstimate,
  });

  factory OrderedTestHive.fromModel(OrderedTestModel model) {
    return OrderedTestHive(
      labTestId: model.labTestId,
      testTypeId: model.testTypeId,
      testTypeName: model.testTypeName,
      name: model.name,
      priceKes: model.priceKes,
      isPriceEstimate: model.isPriceEstimate,
    );
  }

  OrderedTestModel toModel() {
    return OrderedTestModel(
      labTestId: labTestId,
      testTypeId: testTypeId,
      testTypeName: testTypeName,
      name: name,
      priceKes: priceKes,
      isPriceEstimate: isPriceEstimate,
    );
  }

  @HiveField(0)
  final String labTestId;

  @HiveField(1)
  final String testTypeId;

  @HiveField(2)
  final String testTypeName;

  @HiveField(3)
  final String name;

  @HiveField(4)
  final int priceKes;

  @HiveField(5)
  final bool isPriceEstimate;
}
