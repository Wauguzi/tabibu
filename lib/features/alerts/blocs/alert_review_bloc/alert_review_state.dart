import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/alerts/data/models/alert_model.dart';

/// The approver's queue and the alert under review. Every state carries the
/// last good data, so a failed decision never blanks the review.
sealed class AlertReviewState extends Equatable {
  const AlertReviewState({this.queue = const <AlertModel>[], this.current});

  final List<AlertModel> queue;

  /// The alert as the approver last saw it: its revisions are the ones a
  /// decision sends (H-13).
  final AlertModel? current;

  @override
  List<Object?> get props => [queue, current];
}

final class AlertReviewInitial extends AlertReviewState {
  const AlertReviewInitial();
}

final class AlertReviewLoadInProgress extends AlertReviewState {
  const AlertReviewLoadInProgress({super.queue, super.current});
}

final class AlertReviewLoadSuccess extends AlertReviewState {
  const AlertReviewLoadSuccess({super.queue, super.current});
}

final class AlertReviewLoadFailure extends AlertReviewState {
  const AlertReviewLoadFailure({
    required this.error,
    super.queue,
    super.current,
  });

  final AppError error;

  @override
  List<Object?> get props => [...super.props, error];
}

final class AlertDecisionInProgress extends AlertReviewState {
  const AlertDecisionInProgress({super.queue, super.current});
}

final class AlertDecisionSuccess extends AlertReviewState {
  const AlertDecisionSuccess({
    required this.decision,
    super.queue,
    super.current,
  });

  final ApprovalDecision decision;

  @override
  List<Object?> get props => [...super.props, decision];
}

final class AlertDecisionFailure extends AlertReviewState {
  const AlertDecisionFailure({required this.error, super.queue, super.current});

  final AppError error;

  @override
  List<Object?> get props => [...super.props, error];
}
