import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/services/audio_service_contract.dart';

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
    this.inputMode = 'Typed',
    this.transcriptionUid = '',
  });

  /// The patient booking, whose appointments are synced after the request.
  final String uid;
  final String doctorUid;
  final String type;
  final DateTime start;
  final String symptomText;

  /// `Typed` or `Voice`. Voice only when [transcriptionUid] is set and the
  /// sent text came from a transcript the patient checked.
  final String inputMode;
  final String transcriptionUid;

  @override
  List<Object?> get props => [
    uid,
    doctorUid,
    type,
    start,
    symptomText,
    inputMode,
    transcriptionUid,
  ];
}

/// Upload symptom audio and run `transcribeSymptoms` (droppable).
final class SymptomsTranscribeRequested extends AppointmentsEvent {
  const SymptomsTranscribeRequested({required this.uid, required this.audio});

  final String uid;
  final RecordedAudio audio;

  @override
  List<Object?> get props => [uid, audio];
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

/// The server's note limit on a cancel (`sanitize(..., 300)` refuses past
/// it, counting code points). The sheets cap the typed note so the composed
/// reason-plus-note fits; the bloc cuts any remainder.
const cancelNoteMaxLength = 300;

/// The server takes one free-text note: [reason] is the sheet's quick pick
/// and joins [note] into it. A doctor must send something; a patient may
/// send nothing at all.
final class AppointmentCancelRequested extends AppointmentsEvent {
  const AppointmentCancelRequested({
    required this.appointmentUid,
    required this.cancelledByUid,
    this.reason = '',
    this.note = '',
  });

  final String appointmentUid;
  final String cancelledByUid;
  final String reason;
  final String note;

  @override
  List<Object?> get props => [appointmentUid, cancelledByUid, reason, note];
}

/// A move is a booking first and a cancel second: if the booking fails the
/// original stays untouched. Patient-only, like every booking.
final class AppointmentRescheduleRequested extends AppointmentsEvent {
  const AppointmentRescheduleRequested({
    required this.appointmentUid,
    required this.patientUid,
    required this.doctorUid,
    required this.type,
    required this.start,
    required this.cancelledByUid,
    this.caseUid = '',
    this.symptomText = '',
    this.reason = '',
    this.note = '',
  });

  final String appointmentUid;
  final String patientUid;
  final String doctorUid;
  final String type;
  final DateTime start;
  final String cancelledByUid;
  final String caseUid;
  final String symptomText;
  final String reason;
  final String note;

  @override
  List<Object?> get props => [
    appointmentUid,
    patientUid,
    doctorUid,
    type,
    start,
    cancelledByUid,
    caseUid,
    symptomText,
    reason,
    note,
  ];
}

/// Back to the initial state on sign-out.
final class AppointmentsReset extends AppointmentsEvent {
  const AppointmentsReset();
}
