import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert_text_model.freezed.dart';
part 'alert_text_model.g.dart';

/// Approved or draft alert copy (headline + body).
@freezed
abstract class AlertTextModel with _$AlertTextModel {
  const factory AlertTextModel({
    @JsonKey(name: 'headline') @Default('') String headline,
    @JsonKey(name: 'body') @Default('') String body,
  }) = _AlertTextModel;

  const AlertTextModel._();

  factory AlertTextModel.fromJson(Map<String, dynamic> json) =>
      _$AlertTextModelFromJson(json);

  factory AlertTextModel.empty() => const AlertTextModel();
}
