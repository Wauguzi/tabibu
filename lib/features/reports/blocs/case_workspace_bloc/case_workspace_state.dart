import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/preread/data/models/preread_model.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/models/preread_score_model.dart';
import 'package:tabibu/features/reports/data/models/report_draft_model.dart';

/// The pathologist's workspace on one case. Every state carries the last
/// good data, so a failed save or sign never blanks the draft.
sealed class CaseWorkspaceState extends Equatable {
  const CaseWorkspaceState({
    this.caseUid = '',
    this.pathologistUid = '',
    this.caseModel,
    this.draft,
    this.preread,
    this.score,
    this.signed,
    this.prereadShownAt = '',
    this.offline = false,
  });

  final String caseUid;
  final String pathologistUid;
  final CaseModel? caseModel;
  final ReportDraftModel? draft;

  /// The AI pre-read; null when the case has none or it could not be read.
  final PrereadModel? preread;
  final PrereadScoreModel? score;

  /// The signed report, once signed.
  final PathologyReportModel? signed;

  /// When the pre-read was first shown, sent with the score.
  final String prereadShownAt;
  final bool offline;

  /// A report started from a ready pre-read can be signed only once scored.
  bool get needsScore =>
      draft?.prereadRunUid.isNotEmpty == true &&
      preread?.statusValue == JobStatus.ready &&
      score == null;

  @override
  List<Object?> get props => [
    caseUid,
    pathologistUid,
    caseModel,
    draft,
    preread,
    score,
    signed,
    prereadShownAt,
    offline,
  ];
}

final class CaseWorkspaceInitial extends CaseWorkspaceState {
  const CaseWorkspaceInitial();
}

final class CaseWorkspaceLoadInProgress extends CaseWorkspaceState {
  const CaseWorkspaceLoadInProgress({
    super.caseUid,
    super.pathologistUid,
    super.caseModel,
    super.draft,
    super.preread,
    super.score,
    super.signed,
    super.prereadShownAt,
    super.offline,
  });
}

final class CaseWorkspaceLoadSuccess extends CaseWorkspaceState {
  const CaseWorkspaceLoadSuccess({
    super.caseUid,
    super.pathologistUid,
    super.caseModel,
    super.draft,
    super.preread,
    super.score,
    super.signed,
    super.prereadShownAt,
    super.offline,
  });
}

final class CaseWorkspaceLoadFailure extends CaseWorkspaceState {
  const CaseWorkspaceLoadFailure({
    required this.error,
    super.caseUid,
    super.pathologistUid,
    super.caseModel,
    super.draft,
    super.preread,
    super.score,
    super.signed,
    super.prereadShownAt,
    super.offline,
  });

  final AppError error;

  @override
  List<Object?> get props => [...super.props, error];
}

final class CaseWorkspaceWriteInProgress extends CaseWorkspaceState {
  const CaseWorkspaceWriteInProgress({
    super.caseUid,
    super.pathologistUid,
    super.caseModel,
    super.draft,
    super.preread,
    super.score,
    super.signed,
    super.prereadShownAt,
    super.offline,
  });
}

final class CaseDraftSaveSuccess extends CaseWorkspaceState {
  const CaseDraftSaveSuccess({
    super.caseUid,
    super.pathologistUid,
    super.caseModel,
    super.draft,
    super.preread,
    super.score,
    super.signed,
    super.prereadShownAt,
    super.offline,
  });
}

final class CaseScoreSuccess extends CaseWorkspaceState {
  const CaseScoreSuccess({
    super.caseUid,
    super.pathologistUid,
    super.caseModel,
    super.draft,
    super.preread,
    super.score,
    super.signed,
    super.prereadShownAt,
    super.offline,
  });
}

final class CaseSignSuccess extends CaseWorkspaceState {
  const CaseSignSuccess({
    super.caseUid,
    super.pathologistUid,
    super.caseModel,
    super.draft,
    super.preread,
    super.score,
    super.signed,
    super.prereadShownAt,
    super.offline,
  });
}

final class CaseWorkspaceWriteFailure extends CaseWorkspaceState {
  const CaseWorkspaceWriteFailure({
    required this.error,
    super.caseUid,
    super.pathologistUid,
    super.caseModel,
    super.draft,
    super.preread,
    super.score,
    super.signed,
    super.prereadShownAt,
    super.offline,
  });

  final AppError error;

  @override
  List<Object?> get props => [...super.props, error];
}
