import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';

part 'case_payment_model.freezed.dart';
part 'case_payment_model.g.dart';

/// A `cases/{caseUid}/private/payment` document: how the case was paid for.
@freezed
abstract class CasePaymentModel with _$CasePaymentModel {
  const factory CasePaymentModel({
    @JsonKey(name: 'caseUid') @Default('') String caseUid,
    @JsonKey(name: 'method') @Default('Cash') String method,
    @JsonKey(name: 'insurerId') @Default('') String insurerId,
    @JsonKey(name: 'insurerName') @Default('') String insurerName,
    @JsonKey(name: 'policyNumber') @Default('') String policyNumber,
    @JsonKey(name: 'createdByUid') @Default('') String createdByUid,
    @JsonKey(name: 'createdAt') @Default('') String createdAt,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(true)
    bool synced,
  }) = _CasePaymentModel;

  const CasePaymentModel._();

  factory CasePaymentModel.fromJson(Map<String, dynamic> json) =>
      _$CasePaymentModelFromJson(json);

  factory CasePaymentModel.empty() => const CasePaymentModel();

  PaymentMethod get methodValue => PaymentMethod.fromValue(method);
}
