import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/models/report_text_approved_model.dart';
import 'package:tabibu/features/reports/data/models/report_text_model.dart';

/// Why a released report has no explanation draft to review. Only read when
/// there is nothing to review or approved; [none] reads as still waiting.
enum ExplanationDraftPhase { none, pending, failed, rejected }

/// A case's signed report for its reader. [explanations] are the AI drafts
/// awaiting the doctor's approval, by language (doctor only); [approved] the
/// explanations the doctor approved (what a patient may read);
/// [explanationPhase] why there is no draft when there is none. Every state
/// carries the last good data.
sealed class ReportReaderState extends Equatable {
  const ReportReaderState({
    this.uid = '',
    this.role,
    this.caseUid = '',
    this.report,
    this.explanations = const <String, ReportTextModel>{},
    this.approved = const <String, ReportTextApprovedModel>{},
    this.offline = false,
    this.explanationPhase = .none,
  });

  final String uid;
  final Role? role;
  final String caseUid;
  final PathologyReportModel? report;
  final Map<String, ReportTextModel> explanations;
  final Map<String, ReportTextApprovedModel> approved;
  final bool offline;
  final ExplanationDraftPhase explanationPhase;

  @override
  List<Object?> get props => [
    uid,
    role,
    caseUid,
    report,
    explanations,
    approved,
    offline,
    explanationPhase,
  ];
}

final class ReportReaderInitial extends ReportReaderState {
  const ReportReaderInitial();
}

final class ReportReaderLoadInProgress extends ReportReaderState {
  const ReportReaderLoadInProgress({
    super.uid,
    super.role,
    super.caseUid,
    super.report,
    super.explanations,
    super.approved,
    super.offline,
    super.explanationPhase,
  });
}

final class ReportReaderLoadSuccess extends ReportReaderState {
  const ReportReaderLoadSuccess({
    super.uid,
    super.role,
    super.caseUid,
    super.report,
    super.explanations,
    super.approved,
    super.offline,
    super.explanationPhase,
  });
}

final class ReportReaderWriteInProgress extends ReportReaderState {
  const ReportReaderWriteInProgress({
    super.uid,
    super.role,
    super.caseUid,
    super.report,
    super.explanations,
    super.approved,
    super.offline,
    super.explanationPhase,
  });
}

final class ReportDiscussedSuccess extends ReportReaderState {
  const ReportDiscussedSuccess({
    super.uid,
    super.role,
    super.caseUid,
    super.report,
    super.explanations,
    super.approved,
    super.offline,
    super.explanationPhase,
  });
}

final class ExplanationDecisionSuccess extends ReportReaderState {
  const ExplanationDecisionSuccess({
    super.uid,
    super.role,
    super.caseUid,
    super.report,
    super.explanations,
    super.approved,
    super.offline,
    super.explanationPhase,
  });
}

final class ReportReaderLoadFailure extends ReportReaderState {
  const ReportReaderLoadFailure({
    required this.error,
    super.uid,
    super.role,
    super.caseUid,
    super.report,
    super.explanations,
    super.approved,
    super.offline,
    super.explanationPhase,
  });

  final AppError error;

  @override
  List<Object?> get props => [...super.props, error];
}

final class ReportReaderWriteFailure extends ReportReaderState {
  const ReportReaderWriteFailure({
    required this.error,
    super.uid,
    super.role,
    super.caseUid,
    super.report,
    super.explanations,
    super.approved,
    super.offline,
    super.explanationPhase,
  });

  final AppError error;

  @override
  List<Object?> get props => [...super.props, error];
}
