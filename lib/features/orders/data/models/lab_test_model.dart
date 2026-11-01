import 'package:freezed_annotation/freezed_annotation.dart';

part 'lab_test_model.freezed.dart';
part 'lab_test_model.g.dart';

/// One row of `assets/data/lab_tests.json`, in file order.
@freezed
abstract class LabTestModel with _$LabTestModel {
  const factory LabTestModel({
    @JsonKey(name: 'labTestId') required String labTestId,
    @JsonKey(name: 'testTypeId') required String testTypeId,
    @JsonKey(name: 'testTypeName') required String testTypeName,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'isActive') required bool isActive,
    @JsonKey(name: 'testPriceKes') required int testPriceKes,
    @JsonKey(name: 'isPriceEstimate') required bool isPriceEstimate,
    @JsonKey(name: 'tatCollectionToDelivery')
    required int tatCollectionToDelivery,
    @JsonKey(name: 'tatDeliveryToResults') required int tatDeliveryToResults,
    @JsonKey(name: 'totalTurnaroundTime') required int totalTurnaroundTime,
  }) = _LabTestModel;

  factory LabTestModel.empty() => const LabTestModel(
    labTestId: '',
    testTypeId: '',
    testTypeName: '',
    name: '',
    isActive: false,
    testPriceKes: 0,
    isPriceEstimate: false,
    tatCollectionToDelivery: 0,
    tatDeliveryToResults: 0,
    totalTurnaroundTime: 0,
  );

  factory LabTestModel.fromJson(Map<String, dynamic> json) =>
      _$LabTestModelFromJson(json);
}
