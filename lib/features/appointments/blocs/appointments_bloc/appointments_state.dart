import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';

/// The signed-in patient's or doctor's appointments, and the writes on them.
/// Every state carries the last good data, so a refresh or a failure never
/// blanks the screen.
sealed class AppointmentsState extends Equatable {
  const AppointmentsState({
    this.appointments = const <AppointmentModel>[],
    this.offline = false,
  });

  final List<AppointmentModel> appointments;
  final bool offline;

  @override
  List<Object?> get props => [appointments, offline];
}

final class AppointmentsInitial extends AppointmentsState {
  const AppointmentsInitial();
}

final class AppointmentsLoadInProgress extends AppointmentsState {
  const AppointmentsLoadInProgress({super.appointments, super.offline});
}

final class AppointmentsLoadSuccess extends AppointmentsState {
  const AppointmentsLoadSuccess({super.appointments, super.offline});
}

final class AppointmentsLoadFailure extends AppointmentsState {
  const AppointmentsLoadFailure({
    required this.error,
    super.appointments,
    super.offline,
  });

  final AppError error;

  @override
  List<Object?> get props => [...super.props, error];
}

final class AppointmentWriteInProgress extends AppointmentsState {
  const AppointmentWriteInProgress({super.appointments, super.offline});
}

final class AppointmentBookSuccess extends AppointmentsState {
  const AppointmentBookSuccess({
    required this.appointment,
    super.appointments,
    super.offline,
  });

  final AppointmentModel appointment;

  @override
  List<Object?> get props => [...super.props, appointment];
}

final class AppointmentDecisionSuccess extends AppointmentsState {
  const AppointmentDecisionSuccess({
    required this.appointment,
    super.appointments,
    super.offline,
  });

  final AppointmentModel appointment;

  @override
  List<Object?> get props => [...super.props, appointment];
}

final class AppointmentCompleteSuccess extends AppointmentsState {
  const AppointmentCompleteSuccess({
    required this.appointment,
    super.appointments,
    super.offline,
  });

  final AppointmentModel appointment;

  @override
  List<Object?> get props => [...super.props, appointment];
}

final class AppointmentCancelSuccess extends AppointmentsState {
  const AppointmentCancelSuccess({
    required this.appointment,
    super.appointments,
    super.offline,
  });

  final AppointmentModel appointment;

  @override
  List<Object?> get props => [...super.props, appointment];
}

/// [appointment] is the new booking; the old one sits cancelled in
/// [appointments].
final class AppointmentRescheduleSuccess extends AppointmentsState {
  const AppointmentRescheduleSuccess({
    required this.appointment,
    super.appointments,
    super.offline,
  });

  final AppointmentModel appointment;

  @override
  List<Object?> get props => [...super.props, appointment];
}

final class AppointmentWriteFailure extends AppointmentsState {
  const AppointmentWriteFailure({
    required this.error,
    super.appointments,
    super.offline,
  });

  final AppError error;

  @override
  List<Object?> get props => [...super.props, error];
}

final class SymptomsTranscribeInProgress extends AppointmentsState {
  const SymptomsTranscribeInProgress({
    required this.requestId,
    super.appointments,
    super.offline,
  });

  final String requestId;

  @override
  List<Object?> get props => [...super.props, requestId];
}

final class SymptomsTranscribeSuccess extends AppointmentsState {
  const SymptomsTranscribeSuccess({
    required this.requestId,
    required this.transcript,
    required this.transcriptionUid,
    required this.detectedLanguage,
    super.appointments,
    super.offline,
  });

  final String requestId;
  final String transcript;
  final String transcriptionUid;
  final String detectedLanguage;

  @override
  List<Object?> get props => [
    ...super.props,
    requestId,
    transcript,
    transcriptionUid,
    detectedLanguage,
  ];
}

final class SymptomsTranscribeFailure extends AppointmentsState {
  const SymptomsTranscribeFailure({
    required this.requestId,
    required this.error,
    super.appointments,
    super.offline,
  });

  final String requestId;
  final AppError error;

  @override
  List<Object?> get props => [...super.props, requestId, error];
}
