import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/alerts/data/models/notifiable_lab_test_model.dart';

part 'notifiable_disease_model.freezed.dart';
part 'notifiable_disease_model.g.dart';

/// One row of the bundled `notifiable_diseases.json` register.
@freezed
abstract class NotifiableDiseaseModel with _$NotifiableDiseaseModel {
  // Nested lab tests must call toJson(); freezed puts this on the factory.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory NotifiableDiseaseModel({
    @JsonKey(name: 'diseaseId') @Default('') String diseaseId,
    @JsonKey(name: 'nameEn') @Default('') String nameEn,
    @JsonKey(name: 'nameSw') @Default('') String nameSw,
    @JsonKey(name: 'ihrStatus') @Default('None') String ihrStatus,
    @JsonKey(name: 'reportingCategory')
    @Default('NotListed')
    String reportingCategory,
    @JsonKey(name: 'kenyaGroup') @Default('NotListed') String kenyaGroup,
    @JsonKey(name: 'categorySourceId') @Default('') String categorySourceId,
    @JsonKey(name: 'categoryVerified') @Default(false) bool categoryVerified,
    @JsonKey(name: 'caseDefinitionEn') @Default('') String caseDefinitionEn,
    @JsonKey(name: 'caseDefinitionSw') @Default('') String caseDefinitionSw,
    @JsonKey(name: 'labTests')
    @Default(<NotifiableLabTestModel>[])
    List<NotifiableLabTestModel> labTests,
    @JsonKey(name: 'publicAlertEligible')
    @Default(false)
    bool publicAlertEligible,
    @JsonKey(name: 'allowManualAlert') @Default(false) bool allowManualAlert,
    @JsonKey(name: 'preReadHint') @Default('') String preReadHint,
    @JsonKey(name: 'sourceIds') @Default(<String>[]) List<String> sourceIds,
  }) = _NotifiableDiseaseModel;

  const NotifiableDiseaseModel._();

  factory NotifiableDiseaseModel.fromJson(Map<String, dynamic> json) =>
      _$NotifiableDiseaseModelFromJson(json);

  factory NotifiableDiseaseModel.empty() => const NotifiableDiseaseModel();

  IhrStatus get ihrStatusValue => IhrStatus.fromValue(ihrStatus);

  ReportingCategory get reportingCategoryValue =>
      ReportingCategory.fromValue(reportingCategory);

  KenyaGroup get kenyaGroupValue => KenyaGroup.fromValue(kenyaGroup);

  /// True when at least one lab test confirms the disease.
  bool get hasConfirmingTest =>
      labTests.any((t) => t.strengthValue == TestStrength.confirms);
}
