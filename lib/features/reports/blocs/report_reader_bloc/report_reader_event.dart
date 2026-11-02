import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';

sealed class ReportReaderEvent extends Equatable {
  const ReportReaderEvent();

  @override
  List<Object?> get props => [];
}

/// Open a case's signed report for its reader: the doctor (with the AI
/// explanations awaiting their approval) or the patient (with the approved
/// ones only).
final class ReportReaderOpened extends ReportReaderEvent {
  const ReportReaderOpened({
    required this.uid,
    required this.role,
    required this.caseUid,
  });

  final String uid;
  final Role role;
  final String caseUid;

  @override
  List<Object?> get props => [uid, role, caseUid];
}

/// The doctor has discussed the result with the patient: release it.
final class ReportDiscussedRequested extends ReportReaderEvent {
  const ReportDiscussedRequested();
}

/// The doctor's decision on one language's AI explanation: approve as is
/// (no [editedText]), approve their edits, or reject.
final class ExplanationDecisionRequested extends ReportReaderEvent {
  const ExplanationDecisionRequested({
    required this.language,
    this.reject = false,
    this.editedText,
  });

  /// `en` or `sw`.
  final String language;
  final bool reject;

  /// The segments as the doctor left them, when they edited.
  final Map<String, String>? editedText;

  @override
  List<Object?> get props => [language, reject, editedText];
}

/// Back to the initial state on sign-out.
final class ReportReaderReset extends ReportReaderEvent {
  const ReportReaderReset();
}
