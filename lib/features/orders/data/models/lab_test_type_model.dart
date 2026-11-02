import 'package:freezed_annotation/freezed_annotation.dart';

part 'lab_test_type_model.freezed.dart';
part 'lab_test_type_model.g.dart';

/// One row of `assets/data/lab_test_types.json`, in file order.
@freezed
abstract class LabTestTypeModel with _$LabTestTypeModel {
  const factory LabTestTypeModel({
    @JsonKey(name: 'testTypeId') required String testTypeId,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'testCount') required int testCount,
  }) = _LabTestTypeModel;

  factory LabTestTypeModel.empty() =>
      const LabTestTypeModel(testTypeId: '', name: '', testCount: 0);

  factory LabTestTypeModel.fromJson(Map<String, dynamic> json) =>
      _$LabTestTypeModelFromJson(json);
}
