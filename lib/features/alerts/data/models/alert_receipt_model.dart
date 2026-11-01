import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert_receipt_model.freezed.dart';
part 'alert_receipt_model.g.dart';

/// Local-only read receipt for a public alert (`alertReceipts`).
@freezed
abstract class AlertReceiptModel with _$AlertReceiptModel {
  const factory AlertReceiptModel({
    @JsonKey(name: 'alertUid') @Default('') String alertUid,
    @JsonKey(name: 'readAt') @Default('') String readAt,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(true)
    bool synced,
  }) = _AlertReceiptModel;

  const AlertReceiptModel._();

  factory AlertReceiptModel.fromJson(Map<String, dynamic> json) =>
      _$AlertReceiptModelFromJson(json);

  factory AlertReceiptModel.empty() => const AlertReceiptModel();

  /// True when the alert has a non-empty [readAt].
  bool get isRead => readAt.isNotEmpty;
}
