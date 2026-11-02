import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/alerts/data/models/alert_text_model.dart';

sealed class AlertReviewEvent extends Equatable {
  const AlertReviewEvent();

  @override
  List<Object?> get props => [];
}

/// The drafts awaiting a decision, live from the server.
final class AlertQueueRequested extends AlertReviewEvent {
  const AlertQueueRequested();
}

/// One alert, fetched fresh for review.
final class AlertReviewOpened extends AlertReviewEvent {
  const AlertReviewOpened({required this.alertUid});

  final String alertUid;

  @override
  List<Object?> get props => [alertUid];
}

/// Approve the draft on screen as is, or with the approver's edits.
final class AlertApproveRequested extends AlertReviewEvent {
  const AlertApproveRequested({
    required this.alertUid,
    this.audience = .cliniciansThenPatients,
    this.editedText,
  });

  final String alertUid;
  final AlertAudience audience;

  /// Every draft key (`patient_en`, `patient_sw`, `clinician_en`,
  /// `clinician_sw`) when the approver edited; null to approve as is.
  final Map<String, AlertTextModel>? editedText;

  @override
  List<Object?> get props => [alertUid, audience, editedText];
}

final class AlertRejectRequested extends AlertReviewEvent {
  const AlertRejectRequested({required this.alertUid, required this.reason});

  final String alertUid;
  final String reason;

  @override
  List<Object?> get props => [alertUid, reason];
}

/// Back to the initial state on sign-out.
final class AlertReviewReset extends AlertReviewEvent {
  const AlertReviewReset();
}
