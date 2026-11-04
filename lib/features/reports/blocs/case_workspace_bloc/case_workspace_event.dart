import 'package:equatable/equatable.dart';

sealed class CaseWorkspaceEvent extends Equatable {
  const CaseWorkspaceEvent();

  @override
  List<Object?> get props => [];
}

/// Open the pathologist's workspace on one case: the draft (started from
/// the pre-read when there is none yet), the pre-read and its score.
final class CaseWorkspaceOpened extends CaseWorkspaceEvent {
  const CaseWorkspaceOpened({
    required this.caseUid,
    required this.pathologistUid,
  });

  final String caseUid;
  final String pathologistUid;

  @override
  List<Object?> get props => [caseUid, pathologistUid];
}

/// The pathologist's own edits to the draft (sections, relabels). Saved on
/// this phone at once and sent when online.
final class CaseDraftEdited extends CaseWorkspaceEvent {
  const CaseDraftEdited({required this.fields});

  final Map<String, dynamic> fields;

  @override
  List<Object?> get props => [fields];
}

/// Start the report from the AI pre-read's draft (H-20). Allowed once the
/// pre-read is scored and the diagnosis is still empty.
final class CaseDraftStartedFromPreread extends CaseWorkspaceEvent {
  const CaseDraftStartedFromPreread();
}

/// The pathologist's honest score of the AI pre-read, required before a
/// report started from a pre-read can be signed.
final class CasePrereadScored extends CaseWorkspaceEvent {
  const CasePrereadScored({
    required this.overall,
    required this.findingsVerdict,
    required this.impressionVerdict,
    required this.urgencyVerdict,
    required this.measurementsVerdict,
    required this.segmentationVerdict,
    this.comment = '',
  });

  /// 1 to 5.
  final int overall;

  /// `Agree`, `PartlyAgree` or `Disagree`.
  final String findingsVerdict;
  final String impressionVerdict;
  final String urgencyVerdict;

  /// `Accepted`, `Corrected` or `NotApplicable`.
  final String measurementsVerdict;

  /// `Good`, `Acceptable`, `Poor` or `NotApplicable`.
  final String segmentationVerdict;
  final String comment;

  @override
  List<Object?> get props => [
    overall,
    findingsVerdict,
    impressionVerdict,
    urgencyVerdict,
    measurementsVerdict,
    segmentationVerdict,
    comment,
  ];
}

/// Sign and send. [attested] is the "I have reviewed this report and take
/// responsibility for it." tick (H-3); [signaturePng] the drawn signature,
/// base64.
final class CaseSignRequested extends CaseWorkspaceEvent {
  const CaseSignRequested({required this.signaturePng, required this.attested});

  final String signaturePng;
  final bool attested;

  @override
  List<Object?> get props => [signaturePng, attested];
}

/// The requested pathologist takes the case; the workspace then opens on it.
final class CaseRequestAccepted extends CaseWorkspaceEvent {
  const CaseRequestAccepted();
}

/// The requested pathologist turns the case down, with a reason the doctor
/// reads.
final class CaseRequestDeclined extends CaseWorkspaceEvent {
  const CaseRequestDeclined({required this.reason});

  final String reason;

  @override
  List<Object?> get props => [reason];
}

/// The accepting pathologist records the lab's accession number for the
/// sample, which opens the report.
final class CaseSampleReceived extends CaseWorkspaceEvent {
  const CaseSampleReceived({required this.labAccessionNo});

  final String labAccessionNo;

  @override
  List<Object?> get props => [labAccessionNo];
}

/// Start an amendment or addendum on a signed report. [kind] is `Amendment`
/// or `Addendum`; [text] is the reason or the addendum body (H-3, H-4).
final class CaseRevisionStarted extends CaseWorkspaceEvent {
  const CaseRevisionStarted({required this.kind, required this.text});

  /// `Amendment` or `Addendum`.
  final String kind;

  /// Amendment reason (≤ 500) or addendum text (≤ 2,000).
  final String text;

  @override
  List<Object?> get props => [kind, text];
}

/// Leave an open Amendment or Addendum draft unsigned. The signed version
/// is untouched; Amend and Addendum can start again after.
final class CaseRevisionDiscarded extends CaseWorkspaceEvent {
  const CaseRevisionDiscarded();
}

/// Back to the initial state on sign-out.
final class CaseWorkspaceReset extends CaseWorkspaceEvent {
  const CaseWorkspaceReset();
}
