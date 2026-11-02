import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';

sealed class AppointmentsEvent extends Equatable {
  const AppointmentsEvent();

  @override
  List<Object?> get props => [];
}

/// Cache first, then a silent sync.
final class AppointmentsRequested extends AppointmentsEvent {
  const AppointmentsRequested({required this.uid, required this.role});

  final String uid;
  final Role role;

  @override
  List<Object?> get props => [uid, role];
}

/// Sync first: pull-to-refresh.
final class AppointmentsRefreshed extends AppointmentsEvent {
  const AppointmentsRefreshed({required this.uid, required this.role});

  final String uid;
  final Role role;

  @override
  List<Object?> get props => [uid, role];
}

final class AppointmentBookRequested extends AppointmentsEvent {
  const AppointmentBookRequested({
    required this.uid,
    required this.doctorUid,
    required this.type,
    required this.start,
    required this.symptomText,
  });

  /// The patient booking, whose appointments are synced after the request.
  final String uid;
  final String doctorUid;
  final String type;
  final DateTime start;
  final String symptomText;

  @override
  List<Object?> get props => [uid, doctorUid, type, start, symptomText];
}

final class AppointmentDecisionRequested extends AppointmentsEvent {
  const AppointmentDecisionRequested({
    required this.appointmentUid,
    required this.accept,
    this.reason,
    this.note = '',
  });

  final String appointmentUid;
  final bool accept;
  final DeclineReason? reason;
  final String note;

  @override
  List<Object?> get props => [appointmentUid, accept, reason, note];
}

final class AppointmentCompleteRequested extends AppointmentsEvent {
  const AppointmentCompleteRequested({
    required this.appointmentUid,
    required this.outcome,
  });

  final String appointmentUid;
  final String outcome;

  @override
  List<Object?> get props => [appointmentUid, outcome];
}

/// Back to the initial state on sign-out.
final class AppointmentsReset extends AppointmentsEvent {
  const AppointmentsReset();
}
