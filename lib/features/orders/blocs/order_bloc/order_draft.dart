import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';

/// Why a draft can't be created yet, in the order the details step shows
/// them. Each mirrors a `createOrder` refusal (F-12).
enum OrderDraftIssue {
  noTests,
  tooManyTests,
  collectedAtMissing,
  collectedAtInFuture,
  collectedAtTooOld,
  specimenTooLong,
  notesTooLong,
  insurerMissing,
  insurerNameInvalid,
  policyInvalid,
}

/// The order a doctor is putting together, from the test list to the
/// pathologist. [caseUid] is made once when the wizard opens, so every
/// retry of `createOrder` names the same case and can't make a second one.
class OrderDraft extends Equatable {
  const OrderDraft({
    this.appointmentUid = '',
    this.patientId = '',
    this.patientName = '',
    this.doctorUid = '',
    this.caseUid = '',
    this.testIds = const [],
    this.priority = Urgency.routine,
    this.collectedAt,
    this.specimen = '',
    this.clinicalNotes = '',
    this.insured = false,
    this.insurerId = '',
    this.insurerName = '',
    this.policyNumber = '',
    this.created = false,
    this.pathologistUid = '',
    this.protocolConfirmed = false,
  });

  // The server's limits (functions/src/cases.ts).
  static const maxTests = 10;
  static const maxSpecimen = 1000;
  static const maxNotes = 2000;
  static const collectionWindow = Duration(days: 7);
  static const otherInsurer = 'other';
  static final RegExp _policy = RegExp(r'^[A-Za-z0-9/ -]{3,30}$');

  final String appointmentUid;
  final String patientId;
  final String patientName;
  final String doctorUid;
  final String caseUid;
  final List<String> testIds;
  final Urgency priority;
  final DateTime? collectedAt;
  final String specimen;
  final String clinicalNotes;
  final bool insured;
  final String insurerId;
  final String insurerName;
  final String policyNumber;

  /// `createOrder` has succeeded: the case exists and only the pathologist
  /// is left to send.
  final bool created;
  final String pathologistUid;

  /// The doctor ticked "The protocol is in place" for a flagged order.
  final bool protocolConfirmed;

  /// Everything that stops `createOrder`, judged against [now].
  List<OrderDraftIssue> issues(DateTime now) {
    final collectedAt = this.collectedAt;
    final insurerName = this.insurerName.trim();
    return [
      if (testIds.isEmpty) OrderDraftIssue.noTests,
      if (testIds.length > maxTests) OrderDraftIssue.tooManyTests,
      if (collectedAt == null)
        OrderDraftIssue.collectedAtMissing
      else if (collectedAt.isAfter(now))
        OrderDraftIssue.collectedAtInFuture
      else if (collectedAt.isBefore(now.subtract(collectionWindow)))
        OrderDraftIssue.collectedAtTooOld,
      if (specimen.trim().length > maxSpecimen) OrderDraftIssue.specimenTooLong,
      if (clinicalNotes.trim().length > maxNotes) OrderDraftIssue.notesTooLong,
      if (insured && insurerId.isEmpty) OrderDraftIssue.insurerMissing,
      if (insured &&
          insurerId == otherInsurer &&
          (insurerName.length < 2 || insurerName.length > 80))
        OrderDraftIssue.insurerNameInvalid,
      if (insured && !_policy.hasMatch(policyNumber.trim()))
        OrderDraftIssue.policyInvalid,
    ];
  }

  /// The `payment` map `createOrder` takes.
  Map<String, dynamic> get payment => insured
      ? {
          'method': 'Insurance',
          'insurerId': insurerId,
          if (insurerId == otherInsurer) 'insurerName': insurerName.trim(),
          'policyNumber': policyNumber.trim(),
        }
      : {'method': 'Cash'};

  OrderDraft copyWith({
    List<String>? testIds,
    Urgency? priority,
    DateTime? collectedAt,
    String? specimen,
    String? clinicalNotes,
    bool? insured,
    String? insurerId,
    String? insurerName,
    String? policyNumber,
    bool? created,
    String? pathologistUid,
    bool? protocolConfirmed,
  }) => OrderDraft(
    appointmentUid: appointmentUid,
    patientId: patientId,
    patientName: patientName,
    doctorUid: doctorUid,
    caseUid: caseUid,
    testIds: testIds ?? this.testIds,
    priority: priority ?? this.priority,
    collectedAt: collectedAt ?? this.collectedAt,
    specimen: specimen ?? this.specimen,
    clinicalNotes: clinicalNotes ?? this.clinicalNotes,
    insured: insured ?? this.insured,
    insurerId: insurerId ?? this.insurerId,
    insurerName: insurerName ?? this.insurerName,
    policyNumber: policyNumber ?? this.policyNumber,
    created: created ?? this.created,
    pathologistUid: pathologistUid ?? this.pathologistUid,
    protocolConfirmed: protocolConfirmed ?? this.protocolConfirmed,
  );

  @override
  List<Object?> get props => [
    appointmentUid,
    patientId,
    patientName,
    doctorUid,
    caseUid,
    testIds,
    priority,
    collectedAt,
    specimen,
    clinicalNotes,
    insured,
    insurerId,
    insurerName,
    policyNumber,
    created,
    pathologistUid,
    protocolConfirmed,
  ];
}
