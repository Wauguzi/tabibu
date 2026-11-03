import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/services/internet_service.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_event.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_state.dart';
import 'package:tabibu/features/reports/data/cache/report_cache_helper.dart';
import 'package:tabibu/features/reports/data/datasources/report_firebase.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/models/report_text_approved_model.dart';
import 'package:tabibu/features/reports/data/models/report_text_model.dart';
import 'package:tabibu/features/reports/data/report_text_id.dart';

/// A case's signed report for its reader (H-8, H-9). The doctor marks it
/// discussed, which releases it to the patient and queues the AI
/// explanations, then approves, edits or rejects each draft. The patient
/// reads only what the doctor approved. Every write needs the server; the
/// drafts are read live and never cached.
class ReportReaderBloc extends Bloc<ReportReaderEvent, ReportReaderState> {
  ReportReaderBloc({
    ReportCacheHelper? reports,
    ReportFirebase? remote,
    InternetService? internet,
  }) : _reports = reports ?? getIt<ReportCacheHelper>(),
       _remote = remote ?? getIt<ReportFirebase>(),
       _internet = internet ?? getIt<InternetService>(),
       super(const ReportReaderInitial()) {
    // The last report opened is the one on screen.
    on<ReportReaderOpened>(_onOpened, transformer: restartable());
    // One decision at a time; a double tap must not repeat a release.
    on<ReportDiscussedRequested>(_onDiscussed, transformer: droppable());
    on<ExplanationDecisionRequested>(_onDecision, transformer: droppable());
    on<ReportReaderReset>((_, emit) => emit(const ReportReaderInitial()));
  }

  final ReportCacheHelper _reports;
  final ReportFirebase _remote;
  final InternetService _internet;

  static const _languages = ['en', 'sw'];
  static const _offline = <AppError>{
    .noInternet,
    .serviceUnavailable,
    .requestTimeout,
  };

  AppError _toAppError(Object e) => e is AppError ? e : .unknown;

  Future<void> _onOpened(
    ReportReaderOpened event,
    Emitter<ReportReaderState> emit,
  ) async {
    // Never show another case's report while this one loads.
    final same = state.caseUid == event.caseUid;
    emit(
      ReportReaderLoadInProgress(
        uid: event.uid,
        role: event.role,
        caseUid: event.caseUid,
        report: same ? state.report : null,
        explanations: same ? state.explanations : const {},
        approved: same ? state.approved : const {},
      ),
    );
    try {
      var offline = false;
      List<PathologyReportModel> all;
      try {
        all = await _reports.syncReports(event.uid, role: event.role);
      } on AppError catch (e) {
        if (!_offline.contains(e)) rethrow;
        offline = true;
        all = await _reports.getReports(event.uid, role: event.role);
      }
      final report = all
          .where((r) => r.caseUid == event.caseUid && r.isCurrent)
          .sortedBy<num>((r) => r.version)
          .lastOrNull;

      final explanations = <String, ReportTextModel>{};
      final approved = <String, ReportTextApprovedModel>{};
      if (report != null && report.releasedToPatient) {
        for (final language in _languages) {
          final id = reportTextId(report.uid, .explanation, language);
          if (event.role == .doctor && !offline) {
            final draft = await _remote.fetchReportText(
              caseUid: event.caseUid,
              textUid: id,
            );
            if (draft != null) explanations[language] = draft;
          }
          final text = offline
              ? await _reports.getApprovedText(event.caseUid, id)
              : await _reports.syncApprovedText(
                  caseUid: event.caseUid,
                  textUid: id,
                );
          if (text != null) approved[language] = text;
        }
      }

      emit(
        ReportReaderLoadSuccess(
          uid: event.uid,
          role: event.role,
          caseUid: event.caseUid,
          report: report,
          explanations: explanations,
          approved: approved,
          offline: offline,
        ),
      );
    } on Object catch (e) {
      emit(_failure(e, load: true));
    }
  }

  Future<void> _onDiscussed(
    ReportDiscussedRequested event,
    Emitter<ReportReaderState> emit,
  ) async {
    final report = state.report;
    // In progress first, so a repeated failure is a new state and shows.
    emit(_copy(ReportReaderWriteInProgress.new));
    if (state.role != .doctor || report == null) {
      emit(_failure(AppError.dataNotFound));
      return;
    }
    if (!await _internet.check()) {
      emit(_failure(AppError.noInternet));
      return;
    }
    try {
      await _remote.markDiscussed(
        caseUid: state.caseUid,
        reportUid: report.uid,
      );
      emit(
        _copy(
          ReportDiscussedSuccess.new,
          report: report.copyWith(releasedToPatient: true),
        ),
      );
    } on Object catch (e) {
      emit(_failure(e));
    }
  }

  Future<void> _onDecision(
    ExplanationDecisionRequested event,
    Emitter<ReportReaderState> emit,
  ) async {
    final draft = state.explanations[event.language];
    emit(_copy(ReportReaderWriteInProgress.new));
    if (state.role != .doctor || draft == null) {
      emit(_failure(AppError.dataNotFound));
      return;
    }
    if (!await _internet.check()) {
      emit(_failure(AppError.noInternet));
      return;
    }
    // An "edit" identical to the draft is an approval as is, so the
    // accepted-unchanged metric stays honest.
    final edited = event.editedText;
    final unchanged =
        edited == null ||
        const MapEquality<String, String>().equals(edited, draft.machineText);
    final decision = event.reject
        ? 'Reject'
        : unchanged
        ? 'Approve'
        : 'ApproveEdited';
    try {
      await _remote.approveReportText(
        caseUid: state.caseUid,
        textUid: draft.uid,
        decision: decision,
        approvedText: decision == 'ApproveEdited' ? edited : null,
      );
      final approved = Map.of(state.approved);
      final explanations = Map.of(state.explanations)..remove(event.language);
      if (!event.reject) {
        final text = await _reports.syncApprovedText(
          caseUid: state.caseUid,
          textUid: draft.uid,
        );
        if (text != null) approved[event.language] = text;
      }
      emit(
        _copy(
          ExplanationDecisionSuccess.new,
          explanations: explanations,
          approved: approved,
        ),
      );
    } on Object catch (e) {
      emit(_failure(e));
    }
  }

  ReportReaderState _copy(
    ReportReaderState Function({
      String uid,
      Role? role,
      String caseUid,
      PathologyReportModel? report,
      Map<String, ReportTextModel> explanations,
      Map<String, ReportTextApprovedModel> approved,
      bool offline,
    })
    build, {
    PathologyReportModel? report,
    Map<String, ReportTextModel>? explanations,
    Map<String, ReportTextApprovedModel>? approved,
  }) => build(
    uid: state.uid,
    role: state.role,
    caseUid: state.caseUid,
    report: report ?? state.report,
    explanations: explanations ?? state.explanations,
    approved: approved ?? state.approved,
    offline: state.offline,
  );

  ReportReaderState _failure(Object e, {bool load = false}) {
    final error = _toAppError(e);
    return load
        ? ReportReaderLoadFailure(
            error: error,
            uid: state.uid,
            role: state.role,
            caseUid: state.caseUid,
            report: state.report,
            explanations: state.explanations,
            approved: state.approved,
            offline: state.offline,
          )
        : ReportReaderWriteFailure(
            error: error,
            uid: state.uid,
            role: state.role,
            caseUid: state.caseUid,
            report: state.report,
            explanations: state.explanations,
            approved: state.approved,
            offline: state.offline,
          );
  }
}
