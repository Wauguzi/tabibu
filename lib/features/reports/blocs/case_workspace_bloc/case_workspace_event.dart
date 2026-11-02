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

/// Back to the initial state on sign-out.
final class CaseWorkspaceReset extends CaseWorkspaceEvent {
  const CaseWorkspaceReset();
}
