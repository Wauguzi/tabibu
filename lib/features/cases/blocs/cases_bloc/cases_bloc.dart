import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/services/analytics_service.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/data/cache/case_cache_helper.dart';
import 'package:tabibu/features/cases/data/models/case_log_entry_model.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/reports/data/cache/report_cache_helper.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';

/// Cases and their signed reports for any role: a patient's results, a doctor's
/// cases, a pathologist's signed work.
class CasesBloc extends Bloc<CasesEvent, CasesState> {
  CasesBloc({
    CaseCacheHelper? cases,
    ReportCacheHelper? reports,
    AnalyticsService? analytics,
  }) : _cases = cases ?? getIt<CaseCacheHelper>(),
       _reports = reports ?? getIt<ReportCacheHelper>(),
       _analytics = analytics ?? getIt<AnalyticsService>(),
       super(const CasesInitial()) {
    // Cache first, then a silent sync; a second open while loading is
    // pointless.
    on<CasesRequested>(_onRequested, transformer: droppable());
    // Sync first: pull-to-refresh.
    on<CasesRefreshed>(_onRefreshed, transformer: droppable());
    // Log pulls must not race each other.
    on<CaseLogRequested>(_onLog, transformer: sequential());
    // Two note saves in a row both land, in order.
    on<CaseNotesSaveRequested>(_onNotesSave, transformer: sequential());
    on<CasesReset>((_, emit) => emit(const CasesInitial()));
  }

  final CaseCacheHelper _cases;
  final ReportCacheHelper _reports;
  final AnalyticsService _analytics;

  static const Set<AppError> _offline = {
    .noInternet,
    .serviceUnavailable,
    .requestTimeout,
  };

  AppError _toAppError(Object e) => e is AppError ? e : .unknown;

  CasesLoadInProgress _inProgress() => CasesLoadInProgress(
    cases: state.cases,
    reports: state.reports,
    logs: state.logs,
    offline: state.offline,
  );

  CasesLoadFailure _failure(
    Object e, {
    List<CaseModel>? cases,
    List<PathologyReportModel>? reports,
  }) => CasesLoadFailure(
    error: _toAppError(e),
    cases: cases ?? state.cases,
    reports: reports ?? state.reports,
    logs: state.logs,
    offline: state.offline,
  );

  CasesLoadSuccess _success(
    List<CaseModel> cases,
    List<PathologyReportModel> reports, {
    Map<String, List<CaseLogEntryModel>>? logs,
    bool offline = false,
  }) => CasesLoadSuccess(
    cases: cases,
    reports: reports,
    logs: logs ?? state.logs,
    offline: offline,
  );

  Future<void> _onRequested(
    CasesRequested event,
    Emitter<CasesState> emit,
  ) async {
    emit(_inProgress());
    try {
      final cachedCases = await _cases.getCases(event.uid);
      final cachedReports = await _reports.getReports(
        event.uid,
        role: event.role,
      );
      if (cachedCases.isNotEmpty || cachedReports.isNotEmpty) {
        emit(_success(cachedCases, cachedReports));
      }
      await _emitSynced(
        emit,
        uid: event.uid,
        role: event.role,
        fallbackCases: cachedCases,
        fallbackReports: cachedReports,
      );
    } on Object catch (e) {
      emit(_failure(e));
    }
  }

  Future<void> _onRefreshed(
    CasesRefreshed event,
    Emitter<CasesState> emit,
  ) async {
    emit(_inProgress());
    await _emitSynced(
      emit,
      uid: event.uid,
      role: event.role,
      fallbackCases: state.cases,
      fallbackReports: state.reports,
    );
  }

  /// Runs both syncs in parallel and resolves offline / partial failures.
  Future<void> _emitSynced(
    Emitter<CasesState> emit, {
    required String uid,
    required Role role,
    required List<CaseModel> fallbackCases,
    required List<PathologyReportModel> fallbackReports,
  }) async {
    List<CaseModel>? syncedCases;
    List<PathologyReportModel>? syncedReports;
    Object? casesError;
    Object? reportsError;

    await Future.wait<void>([
      () async {
        try {
          syncedCases = await _cases.syncCases(uid);
        } on Object catch (e) {
          casesError = e;
        }
      }(),
      () async {
        try {
          syncedReports = await _reports.syncReports(uid, role: role);
        } on Object catch (e) {
          reportsError = e;
        }
      }(),
    ]);

    final cases = syncedCases ?? fallbackCases;
    final reports = syncedReports ?? fallbackReports;
    final casesErr = casesError;
    final reportsErr = reportsError;

    if (casesErr == null && reportsErr == null) {
      emit(_success(cases, reports));
      return;
    }

    final offlineCases =
        casesErr != null && _offline.contains(_toAppError(casesErr));
    final offlineReports =
        reportsErr != null && _offline.contains(_toAppError(reportsErr));
    final onlyOffline =
        (casesErr == null || offlineCases) &&
        (reportsErr == null || offlineReports);

    if (onlyOffline) {
      if (cases.isEmpty && reports.isEmpty) {
        emit(_failure(casesErr ?? reportsErr!, cases: cases, reports: reports));
        return;
      }
      emit(_success(cases, reports, offline: true));
      return;
    }

    // Non-offline error: keep whatever synced, fail with the first hard error.
    emit(
      _failure(
        (!offlineCases && casesErr != null) ? casesErr : reportsErr!,
        cases: cases,
        reports: reports,
      ),
    );
  }

  Future<void> _onLog(CaseLogRequested event, Emitter<CasesState> emit) async {
    try {
      final entries = await _cases.syncLog(
        caseUid: event.caseUid,
        role: event.role,
      );
      emit(
        _success(
          state.cases,
          state.reports,
          logs: {...state.logs, event.caseUid: entries},
          offline: state.offline,
        ),
      );
    } on Object catch (e) {
      emit(_failure(e));
    }
  }

  Future<void> _onNotesSave(
    CaseNotesSaveRequested event,
    Emitter<CasesState> emit,
  ) async {
    final trimmed = event.clinicalNotes.trim();
    CaseModel? current;
    for (final c in state.cases) {
      if (c.uid == event.caseUid) {
        current = c;
        break;
      }
    }
    if (current != null && current.clinicalNotes == trimmed) {
      return;
    }

    emit(
      CaseWriteInProgress(
        cases: state.cases,
        reports: state.reports,
        logs: state.logs,
        offline: state.offline,
      ),
    );
    try {
      final edited = await _cases.saveDoctorNotes(
        caseUid: event.caseUid,
        clinicalNotes: trimmed,
      );
      final next = [
        for (final c in state.cases)
          if (c.uid == event.caseUid) edited else c,
      ];
      // If the case was missing from state, still surface the saved model.
      final cases = next.any((c) => c.uid == event.caseUid)
          ? next
          : [...next, edited];
      unawaited(_analytics.logCaseNotesSaved());
      emit(
        CaseNotesSaveSuccess(
          cases: cases,
          reports: state.reports,
          logs: state.logs,
          offline: state.offline,
        ),
      );
    } on Object catch (e) {
      emit(
        CaseWriteFailure(
          error: _toAppError(e),
          cases: state.cases,
          reports: state.reports,
          logs: state.logs,
          offline: state.offline,
        ),
      );
    }
  }
}
