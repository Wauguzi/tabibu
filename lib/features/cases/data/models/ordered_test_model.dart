import 'package:freezed_annotation/freezed_annotation.dart';

part 'ordered_test_model.freezed.dart';
part 'ordered_test_model.g.dart';

/// One ordered test line on a case, priced by the server.
@freezed
abstract class OrderedTestModel with _$OrderedTestModel {
  const factory OrderedTestModel({
    @JsonKey(name: 'labTestId') @Default('') String labTestId,
    @JsonKey(name: 'testTypeId') @Default('') String testTypeId,
    @JsonKey(name: 'testTypeName') @Default('') String testTypeName,
    @JsonKey(name: 'name') @Default('') String name,
    @JsonKey(name: 'priceKes') @Default(0) int priceKes,
    @JsonKey(name: 'isPriceEstimate') @Default(false) bool isPriceEstimate,
  }) = _OrderedTestModel;

  factory OrderedTestModel.fromJson(Map<String, dynamic> json) =>
      _$OrderedTestModelFromJson(json);

  factory OrderedTestModel.empty() => const OrderedTestModel();
}
