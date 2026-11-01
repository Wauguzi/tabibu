import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/appointments/data/models/intake_draft_model.dart';

part 'appointment_intake_model.freezed.dart';
part 'appointment_intake_model.g.dart';

/// AI symptom intake under `appointments/{a}/intake/summary`.
@freezed
abstract class AppointmentIntakeModel with _$AppointmentIntakeModel {
  // Nested drafts must call toJson(); freezed puts this on the factory.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory AppointmentIntakeModel({
    @JsonKey(name: 'uid') @Default('summary') String uid,
    @JsonKey(name: 'appointmentUid') @Default('') String appointmentUid,
    @JsonKey(name: 'doctorUid') @Default('') String doctorUid,
    @JsonKey(name: 'status') @Default('Queued') String status,
    @JsonKey(name: 'inputText') @Default('') String inputText,
    @JsonKey(name: 'inputMode') @Default('Typed') String inputMode,
    @JsonKey(name: 'inputLanguage') @Default('') String inputLanguage,
    @JsonKey(name: 'transcriptLanguage') @Default('') String transcriptLanguage,
    @JsonKey(name: 'transcriptAcceptedUnchanged')
    @Default(false)
    bool transcriptAcceptedUnchanged,
    @JsonKey(name: 'transcriptEditDistance')
    @Default(0)
    double transcriptEditDistance,
    @JsonKey(name: 'drafts')
    @Default(<String, IntakeDraftModel>{})
    Map<String, IntakeDraftModel> drafts,
    @JsonKey(name: 'modelVersion') @Default('') String modelVersion,
    @JsonKey(name: 'promptVersion') @Default('') String promptVersion,
    @JsonKey(name: 'failureReason') @Default('') String failureReason,
    @JsonKey(name: 'requestedAt') @Default('') String requestedAt,
    @JsonKey(name: 'readyAt') @Default('') String readyAt,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(true)
    bool synced,
  }) = _AppointmentIntakeModel;

  const AppointmentIntakeModel._();

  factory AppointmentIntakeModel.fromJson(Map<String, dynamic> json) =>
      _$AppointmentIntakeModelFromJson(json);

  /// Empty intake with both `en` and `sw` draft slots.
  factory AppointmentIntakeModel.empty() => const AppointmentIntakeModel(
    drafts: {'en': IntakeDraftModel(), 'sw': IntakeDraftModel()},
  );

  IntakeStatus get statusValue => IntakeStatus.fromValue(status);

  InputMode get inputModeValue => InputMode.fromValue(inputMode);

  FailureReason get failureReasonValue =>
      FailureReason.fromValue(failureReason);

  /// True when the intake draft is ready for the doctor.
  bool get isReady => statusValue == IntakeStatus.ready;
}
