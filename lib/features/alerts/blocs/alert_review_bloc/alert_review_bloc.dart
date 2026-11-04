import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/services/internet_service.dart';
import 'package:tabibu/features/alerts/blocs/alert_review_bloc/alert_review_event.dart';
import 'package:tabibu/features/alerts/blocs/alert_review_bloc/alert_review_state.dart';
import 'package:tabibu/features/alerts/data/datasources/alert_firebase.dart';
import 'package:tabibu/features/alerts/data/models/alert_model.dart';
import 'package:tabibu/features/alerts/data/models/alert_text_model.dart';

/// The approver's queue and their decisions on AI-drafted area alerts. The
/// queue is live only (F-39), and a decision is never queued offline: an
/// alert reaches people only through an approval the server accepted.
class AlertReviewBloc extends Bloc<AlertReviewEvent, AlertReviewState> {
  AlertReviewBloc({AlertFirebase? alerts, InternetService? internet})
    : _alerts = alerts ?? getIt<AlertFirebase>(),
      _internet = internet ?? getIt<InternetService>(),
      super(const AlertReviewInitial()) {
    // Reads are idempotent; a second open while loading is pointless.
    on<AlertQueueRequested>(_onQueue, transformer: droppable());
    // The last alert opened is the one under review.
    on<AlertReviewOpened>(_onOpened, transformer: restartable());
    // One decision at a time; a double tap must not decide twice.
    on<AlertApproveRequested>(_onApprove, transformer: droppable());
    on<AlertRejectRequested>(_onReject, transformer: droppable());
    on<AlertReviewReset>((_, emit) => emit(const AlertReviewInitial()));
  }

  final AlertFirebase _alerts;
  final InternetService _internet;

  static const _textEquality = MapEquality<String, AlertTextModel>();

  AppError _toAppError(Object e) => e is AppError ? e : .unknown;

  Future<void> _onQueue(
    AlertQueueRequested event,
    Emitter<AlertReviewState> emit,
  ) async {
    emit(AlertReviewLoadInProgress(queue: state.queue, current: state.current));
    try {
      final queue = await _alerts.fetchAwaitingDecision();
      emit(AlertReviewLoadSuccess(queue: queue, current: state.current));
    } on Object catch (e) {
      emit(
        AlertReviewLoadFailure(
          error: _toAppError(e),
          queue: state.queue,
          current: state.current,
        ),
      );
    }
  }

  Future<void> _onOpened(
    AlertReviewOpened event,
    Emitter<AlertReviewState> emit,
  ) async {
    // Never show another alert's draft while this one loads.
    final shown = state.current?.uid == event.alertUid ? state.current : null;
    emit(AlertReviewLoadInProgress(queue: state.queue, current: shown));
    try {
      final alert = await _alerts.fetchAlert(event.alertUid);
      if (alert == null) {
        emit(AlertReviewLoadFailure(error: .dataNotFound, queue: state.queue));
        return;
      }
      emit(AlertReviewLoadSuccess(queue: state.queue, current: alert));
    } on Object catch (e) {
      emit(
        AlertReviewLoadFailure(
          error: _toAppError(e),
          queue: state.queue,
          current: shown,
        ),
      );
    }
  }

  Future<void> _onApprove(
    AlertApproveRequested event,
    Emitter<AlertReviewState> emit,
  ) async {
    final seen = _reviewed(event.alertUid);
    if (seen == null) {
      emit(_decisionFailure(.dataNotFound));
      return;
    }
    // An "edit" identical to the draft is an approval as is, so the
    // accepted-unchanged metric stays honest.
    final edited = event.editedText;
    final unchanged =
        edited == null || _textEquality.equals(edited, seen.machineText);
    await _decide(
      emit,
      seen: seen,
      decision: unchanged ? .approve : .approveEdited,
      audience: event.audience,
      editedText: unchanged ? null : edited,
    );
  }

  Future<void> _onReject(
    AlertRejectRequested event,
    Emitter<AlertReviewState> emit,
  ) async {
    final seen = _reviewed(event.alertUid);
    final reason = event.reason.trim();
    if (seen == null || reason.isEmpty) {
      emit(_decisionFailure(seen == null ? .dataNotFound : .invalidDecision));
      return;
    }
    await _decide(emit, seen: seen, decision: .reject, reason: reason);
  }

  /// The alert under review, only if it is the one the decision names.
  AlertModel? _reviewed(String alertUid) {
    final current = state.current;
    return current != null && current.uid == alertUid ? current : null;
  }

  Future<void> _decide(
    Emitter<AlertReviewState> emit, {
    required AlertModel seen,
    required ApprovalDecision decision,
    AlertAudience audience = .cliniciansThenPatients,
    Map<String, AlertTextModel>? editedText,
    String? reason,
  }) async {
    if (!await _internet.check()) {
      emit(_decisionFailure(.noInternet));
      return;
    }
    emit(AlertDecisionInProgress(queue: state.queue, current: seen));
    try {
      await _alerts.approveAlert(
        alertUid: seen.uid,
        decision: decision.value,
        // The revisions the approver saw: a draft or evidence that changed
        // since is refused by the server, never approved blind (H-13).
        draftRevision: seen.draftRevision,
        evidenceRevision: seen.evidenceRevision,
        audience: audience.value,
        editedText: editedText?.map(
          (key, text) => MapEntry(key, text.toJson()),
        ),
        reason: reason,
      );
    } on Object catch (e) {
      emit(_decisionFailure(_toAppError(e)));
      return;
    }
    // Approval already landed: a re-fetch fault must not look like failure.
    final queue = [
      for (final alert in state.queue)
        if (alert.uid != seen.uid) alert,
    ];
    try {
      final decided = await _alerts.fetchAlert(seen.uid) ?? seen;
      emit(
        AlertDecisionSuccess(
          decision: decision,
          queue: queue,
          current: decided,
        ),
      );
    } on Object catch (_) {
      emit(
        AlertDecisionSuccess(
          decision: decision,
          queue: queue,
          current: seen.copyWith(
            status: switch (decision) {
              .approve || .approveEdited => AlertStatus.approved.value,
              .reject => AlertStatus.rejected.value,
            },
            decision: decision.value,
          ),
        ),
      );
    }
  }

  AlertDecisionFailure _decisionFailure(AppError error) => AlertDecisionFailure(
    error: error,
    queue: state.queue,
    current: state.current,
  );
}
