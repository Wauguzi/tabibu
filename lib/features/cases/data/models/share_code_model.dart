import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';

part 'share_code_model.freezed.dart';
part 'share_code_model.g.dart';

/// A `shareCodes/{uid}` document: one share of a case or report.
@freezed
abstract class ShareCodeModel with _$ShareCodeModel {
  const factory ShareCodeModel({
    @JsonKey(name: 'uid') @Default('') String uid,
    @JsonKey(name: 'caseUid') @Default('') String caseUid,
    @JsonKey(name: 'reportUid') @Default('') String reportUid,
    @JsonKey(name: 'purpose') @Default('Join') String purpose,
    @JsonKey(name: 'createdByUid') @Default('') String createdByUid,
    @JsonKey(name: 'createdByRole') @Default('') String createdByRole,
    @JsonKey(name: 'recipientUid') @Default('') String recipientUid,
    @JsonKey(name: 'status') @Default('Pending') String status,
    @JsonKey(name: 'attempts') @Default(0) int attempts,
    @JsonKey(name: 'reissueCount') @Default(0) int reissueCount,
    @JsonKey(name: 'expiresAt') @Default('') String expiresAt,
    @JsonKey(name: 'redeemedAt') @Default('') String redeemedAt,
    @JsonKey(name: 'notificationUid') @Default('') String notificationUid,
    @JsonKey(name: 'createdAt') @Default('') String createdAt,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(true)
    bool synced,
  }) = _ShareCodeModel;

  const ShareCodeModel._();

  factory ShareCodeModel.fromJson(Map<String, dynamic> json) =>
      _$ShareCodeModelFromJson(json);

  factory ShareCodeModel.empty() => const ShareCodeModel();

  static const maxShareAttempts = 5;

  SharePurpose get purposeValue => SharePurpose.fromValue(purpose);

  ShareStatus get statusValue => ShareStatus.fromValue(status);
}
