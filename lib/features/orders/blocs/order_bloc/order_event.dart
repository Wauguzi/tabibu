import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';

sealed class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

/// The wizard opens for an appointment. The same appointment resumes its
/// draft (a failed or offline create keeps it); another one starts afresh.
/// [testIds] preselects tests. A [caseUid] reopens an order already created:
/// the wizard goes to the risk check and the pathologist.
final class OrderStarted extends OrderEvent {
  const OrderStarted({
    required this.appointmentUid,
    required this.patientId,
    required this.patientName,
    required this.doctorUid,
    this.testIds = const [],
    this.caseUid = '',
    this.declinedPathologistUids = const [],
  });

  final String appointmentUid;
  final String patientId;
  final String patientName;
  final String doctorUid;
  final List<String> testIds;
  final String caseUid;

  /// Pathologists who already refused this case, never offered again.
  final List<String> declinedPathologistUids;

  @override
  List<Object?> get props => [
    appointmentUid,
    patientId,
    patientName,
    doctorUid,
    testIds,
    caseUid,
    declinedPathologistUids,
  ];
}

final class OrderTestToggled extends OrderEvent {
  const OrderTestToggled({required this.labTestId});

  final String labTestId;

  @override
  List<Object?> get props => [labTestId];
}

/// Any of the details step's fields; null leaves a field as it is.
final class OrderDetailsChanged extends OrderEvent {
  const OrderDetailsChanged({
    this.priority,
    this.collectedAt,
    this.specimen,
    this.clinicalNotes,
  });

  final Urgency? priority;
  final DateTime? collectedAt;
  final String? specimen;
  final String? clinicalNotes;

  @override
  List<Object?> get props => [priority, collectedAt, specimen, clinicalNotes];
}

final class OrderPaymentChanged extends OrderEvent {
  const OrderPaymentChanged({
    this.insured,
    this.insurerId,
    this.insurerName,
    this.policyNumber,
  });

  final bool? insured;
  final String? insurerId;
  final String? insurerName;
  final String? policyNumber;

  @override
  List<Object?> get props => [insured, insurerId, insurerName, policyNumber];
}

/// Create the case (`createOrder`), then watch its risk check.
final class OrderCreateRequested extends OrderEvent {
  const OrderCreateRequested();
}

final class OrderPathologistSelected extends OrderEvent {
  const OrderPathologistSelected({required this.pathologistUid});

  final String pathologistUid;

  @override
  List<Object?> get props => [pathologistUid];
}

/// The doctor's "The protocol is in place" for a flagged order.
final class OrderProtocolConfirmed extends OrderEvent {
  const OrderProtocolConfirmed({required this.confirmed});

  final bool confirmed;

  @override
  List<Object?> get props => [confirmed];
}

/// Send the created case to the chosen pathologist (`requestPathologist`).
final class OrderSendRequested extends OrderEvent {
  const OrderSendRequested();
}

final class OrderReset extends OrderEvent {
  const OrderReset();
}
