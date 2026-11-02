import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';

part 'notifiable_lab_test_model.freezed.dart';
part 'notifiable_lab_test_model.g.dart';

/// One lab-test mapping on a notifiable disease (bundled reference).
@freezed
abstract class NotifiableLabTestModel with _$NotifiableLabTestModel {
  const factory NotifiableLabTestModel({
    @JsonKey(name: 'labTestId') @Default('') String labTestId,
    @JsonKey(name: 'name') @Default('') String name,
    @JsonKey(name: 'strength') @Default('Uncertain') String strength,
    @JsonKey(name: 'mappingVerified') @Default(false) bool mappingVerified,
  }) = _NotifiableLabTestModel;

  const NotifiableLabTestModel._();

  factory NotifiableLabTestModel.fromJson(Map<String, dynamic> json) =>
      _$NotifiableLabTestModelFromJson(json);

  factory NotifiableLabTestModel.empty() => const NotifiableLabTestModel();

  TestStrength get strengthValue => TestStrength.fromValue(strength);
}
