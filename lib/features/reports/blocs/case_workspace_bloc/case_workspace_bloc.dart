import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/services/internet_service.dart';
import 'package:tabibu/features/cases/data/cache/case_cache_helper.dart';
import 'package:tabibu/features/cases/data/datasources/case_firebase.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/preread/data/models/preread_model.dart';
import 'package:tabibu/features/reports/blocs/case_workspace_bloc/case_workspace_event.dart';
import 'package:tabibu/features/reports/blocs/case_workspace_bloc/case_workspace_state.dart';
import 'package:tabibu/features/reports/data/cache/report_cache_helper.dart';
import 'package:tabibu/features/reports/data/datasources/report_firebase.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/models/preread_score_model.dart';
import 'package:tabibu/features/reports/data/models/report_draft_model.dart';

/// The pathologist's workspace on one case: the draft they edit, the AI
/// pre-read beside it, its score and the signature. Edits save on the phone
/// and send when online; scoring and signing need the server, and signing
/// needs the attestation, a signature, a score where one is due, and every
/// edit already sent (H-3, H-16, H-17).
class CaseWorkspaceBloc extends Bloc<CaseWorkspaceEvent, CaseWorkspaceState> {
  CaseWorkspaceBloc({
    ReportCacheHelper? reports,
    ReportFirebase? remote,
    CaseCacheHelper? cases,
    CaseFirebase? caseRemote,
    InternetService? internet,
    DateTime Function()? now,
  }) : _reports = reports ?? getIt<ReportCacheHelper>(),
       _remote = remote ?? getIt<ReportFirebase>(),
       _cases = cases ?? getIt<CaseCacheHelper>(),
       _caseRemote = caseRemote ?? getIt<CaseFirebase>(),
       _internet = internet ?? getIt<InternetService>(),
       _now = now ?? DateTime.now,
       super(const CaseWorkspaceInitial()) {
    // The last case opened is the one on screen.
    on<CaseWorkspaceOpened>(_onOpened, transformer: restartable());
    // Edits apply in the order they were made.
    on<CaseDraftEdited>(_onEdited, transformer: sequential());
    // Through the same queue as edits, so it never races one.
    on<CaseDraftStartedFromPreread>(
      (_, emit) => _onEdited(_fromPreread(), emit),
      transformer: sequential(),
    );
    // One score and one signature at a time; a double tap must not repeat.
    on<CasePrereadScored>(_onScored, transformer: droppable());
    on<CaseSignRequested>(_onSign, transformer: droppable());
    // One answer to a request; a double tap must not send two.
    on<CaseRequestAccepted>(_onAccepted, transformer: droppable());
    on<CaseRequestDeclined>(_onDeclined, transformer: droppable());
    on<CaseSampleReceived>(_onSampleReceived, transformer: droppable());
    // One revision at a time; a double tap must not open two drafts.
    on<CaseRevisionStarted>(_onRevision, transformer: droppable());
    // One discard; a double tap on the confirm must not repeat it.
    on<CaseRevisionDiscarded>(_onDiscardRevision, transformer: droppable());
    on<CaseWorkspaceReset>((_, emit) => emit(const CaseWorkspaceInitial()));
  }

  final ReportCacheHelper _reports;
  final ReportFirebase _remote;
  final CaseCacheHelper _cases;
  final CaseFirebase _caseRemote;
  final InternetService _internet;
  final DateTime Function() _now;

  /// The server's limit on a decline reason.
  static const _maxDeclineReason = 500;

  /// App cap on an amendment reason (server allows 1,000).
  static const maxAmendmentReason = 500;

  /// App cap on addendum text (server allows 4,000).
  static const maxAddendumText = 2000;

  /// Stages where the signer may start an amendment or addendum.
  static const revisionStages = <CaseStage>{
    .reportSigned,
    .discussionRequested,
    .discussionBooked,
    .resultReleased,
    .completed,
  };

  /// The server's shape for a lab accession number.
  static final _accession = RegExp(r'^[A-Za-z0-9/-]{1,30}$');

  static const Set<AppError> _offline = {
    .noInternet,
    .serviceUnavailable,
    .requestTimeout,
  };

  AppError _toAppError(Object e) => e is AppError ? e : .unknown;

  Future<void> _onOpened(
    CaseWorkspaceOpened event,
    Emitter<CaseWorkspaceState> emit,
  ) async {
    // Never show another case's draft while this one loads.
    final same = state.caseUid == event.caseUid;
    emit(
      CaseWorkspaceLoadInProgress(
        caseUid: event.caseUid,
        pathologistUid: event.pathologistUid,
        caseModel: same ? state.caseModel : null,
        draft: same ? state.draft : null,
        preread: same ? state.preread : null,
        score: same ? state.score : null,
        prereadShownAt: same ? state.prereadShownAt : '',
      ),
    );
    try {
      final online = await _internet.check();
      var caseModel = (await _cases.getCases(
        event.pathologistUid,
      )).firstWhereOrNull((c) => c.uid == event.caseUid);
      // A case opened from a notification may not be on the phone yet.
      if (caseModel == null && online) {
        try {
          caseModel = (await _cases.syncCases(
            event.pathologistUid,
          )).firstWhereOrNull((c) => c.uid == event.caseUid);
        } on Object catch (_) {
          // The read below fails the same way and says why.
        }
      }

      // Asked, not yet accepted: the server holds back the draft and the
      // pre-read and refuses to start a report, so the screen shows the
      // request and nothing else is read.
      if (caseModel != null &&
          caseModel.currentStageValue == .pathologistRequested &&
          caseModel.requestedPathologistUid == event.pathologistUid) {
        emit(
          CaseWorkspaceLoadSuccess(
            caseUid: event.caseUid,
            pathologistUid: event.pathologistUid,
            caseModel: caseModel,
            offline: !online,
          ),
        );
        return;
      }

      // Taken but the sample not recorded: the server refuses to start a
      // report until it is, so the screen asks for the accession number.
      if (caseModel != null &&
          caseModel.pathologistUid == event.pathologistUid &&
          caseModel.awaitsSample) {
        emit(
          CaseWorkspaceLoadSuccess(
            caseUid: event.caseUid,
            pathologistUid: event.pathologistUid,
            caseModel: caseModel,
            offline: !online,
          ),
        );
        return;
      }

      final signedUid = caseModel?.currentReportUid ?? '';
      var draft = await _draftFor(event, online: online);
      if (draft == null && online && signedUid.isEmpty) {
        // Opening an assigned case starts its report; the server copies a
        // ready pre-read into it (and records when work began).
        await _remote.startReport(caseUid: event.caseUid, kind: 'Initial');
        draft = await _draftFor(event, online: online);
      }

      final runUid = draft?.prereadRunUid.isNotEmpty == true
          ? draft!.prereadRunUid
          : caseModel?.prereadRunUid ?? '';
      PrereadModel? preread;
      PrereadScoreModel? score;
      if (runUid.isNotEmpty) {
        // The pre-read is read live: it is never cached on the phone.
        preread = online
            ? await _remote.fetchPreread(caseUid: event.caseUid, runUid: runUid)
            : (same ? state.preread : null);
        score = online
            ? await _scoreOf(
                caseUid: event.caseUid,
                runUid: runUid,
                pathologistUid: event.pathologistUid,
              )
            : await _reports.getPrereadScore(
                event.caseUid,
                runUid,
                event.pathologistUid,
              );
      }
      PathologyReportModel? signed;
      if (signedUid.isNotEmpty) {
        final reports = online
            ? await _reports.syncReports(
                event.pathologistUid,
                role: .pathologist,
              )
            : await _reports.getReports(
                event.pathologistUid,
                role: .pathologist,
              );
        signed = reports.firstWhereOrNull(
          (r) => r.caseUid == event.caseUid && r.uid == signedUid,
        );
      }
      final shownAt = state.prereadShownAt.isNotEmpty
          ? state.prereadShownAt
          : (preread != null ? _now().toUtc().toIso8601String() : '');

      emit(
        CaseWorkspaceLoadSuccess(
          caseUid: event.caseUid,
          pathologistUid: event.pathologistUid,
          caseModel: caseModel,
          draft: draft,
          preread: preread,
          score: score,
          signed: signed,
          prereadShownAt: shownAt,
          offline: !online,
        ),
      );
    } on Object catch (e) {
      emit(
        CaseWorkspaceLoadFailure(
          error: _toAppError(e),
          caseUid: state.caseUid,
          pathologistUid: state.pathologistUid,
          caseModel: state.caseModel,
          draft: state.draft,
          preread: state.preread,
          score: state.score,
          prereadShownAt: state.prereadShownAt,
          offline: state.offline,
        ),
      );
    }
  }

  /// The rules refuse a read of a score that does not exist yet, so a pre-read
  /// nobody has scored comes back "denied": that is simply no score, and the
  /// report stays locked until one is given (H-20).
  Future<PrereadScoreModel?> _scoreOf({
    required String caseUid,
    required String runUid,
    required String pathologistUid,
  }) async {
    try {
      return await _reports.syncPrereadScore(
        caseUid: caseUid,
        runUid: runUid,
        pathologistUid: pathologistUid,
      );
    } on AppError catch (e) {
      if (e == AppError.permissionDenied) return null;
      rethrow;
    }
  }

  Future<ReportDraftModel?> _draftFor(
    CaseWorkspaceOpened event, {
    required bool online,
  }) async {
    if (!online) {
      return await _reports.getDraft(event.caseUid, event.pathologistUid);
    }
    try {
      return await _reports.syncDraft(
        caseUid: event.caseUid,
        pathologistUid: event.pathologistUid,
      );
    } on AppError catch (e) {
      if (!_offline.contains(e)) rethrow;
      return await _reports.getDraft(event.caseUid, event.pathologistUid);
    }
  }

  Future<void> _onEdited(
    CaseDraftEdited event,
    Emitter<CaseWorkspaceState> emit,
  ) async {
    final current = state.draft;
    if (current == null || event.fields.isEmpty) return;
    // The rules let a diagnosis start only once a ready pre-read is scored
    // (H-20); refused here, nothing reaches the server.
    final fields = Map<String, dynamic>.of(event.fields);
    final diagnosis = fields['diagnosis'];
    if (state.needsScore &&
        (fields.containsKey('startedFromPreread') ||
            (diagnosis is String && diagnosis.trim().isNotEmpty))) {
      emit(_failure(AppError.invalidDecision));
      return;
    }
    if (diagnosis is String &&
        diagnosis.trim().isNotEmpty &&
        current.diagnosisStartedAt.isEmpty) {
      fields['diagnosisStartedAt'] = _now().toUtc().toIso8601String();
    }
    try {
      final draft = await _reports.saveDraftFields(
        caseUid: state.caseUid,
        pathologistUid: state.pathologistUid,
        fields: fields,
      );
      emit(_with(CaseDraftSaveSuccess.new, draft: draft));
    } on Object catch (e) {
      emit(_failure(e));
    }
  }

  /// The AI draft as the server compares it at signing: the impression
  /// as the diagnosis, the findings' texts as the comments (H-20). An
  /// empty event when there is nothing to adopt.
  CaseDraftEdited _fromPreread() {
    final preread = state.preread;
    final draft = state.draft;
    if (preread == null ||
        !preread.isReady ||
        draft == null ||
        draft.startedFromPreread ||
        draft.diagnosis.isNotEmpty) {
      return const CaseDraftEdited(fields: {});
    }
    return CaseDraftEdited(
      fields: {
        'diagnosis': preread.draft.impression,
        'comments': preread.draft.findings.map((f) => f.text).join('\n'),
        'startedFromPreread': true,
      },
    );
  }

  Future<void> _onScored(
    CasePrereadScored event,
    Emitter<CaseWorkspaceState> emit,
  ) async {
    final runUid = state.draft?.prereadRunUid ?? '';
    if (runUid.isEmpty || state.preread == null) {
      emit(_failure(AppError.dataNotFound));
      return;
    }
    if (event.overall < 1 || event.overall > 5) {
      emit(_failure(AppError.invalidDecision));
      return;
    }
    if (!await _internet.check()) {
      emit(_failure(AppError.noInternet));
      return;
    }
    emit(_with(CaseWorkspaceWriteInProgress.new));
    try {
      await _remote.scorePreread(
        caseUid: state.caseUid,
        runUid: runUid,
        overall: event.overall,
        findingsVerdict: event.findingsVerdict,
        impressionVerdict: event.impressionVerdict,
        measurementsVerdict: event.measurementsVerdict,
        segmentationVerdict: event.segmentationVerdict,
        urgencyVerdict: event.urgencyVerdict,
        prereadShownAt: state.prereadShownAt,
        comment: event.comment.trim(),
      );
      final score = await _reports.syncPrereadScore(
        caseUid: state.caseUid,
        runUid: runUid,
        pathologistUid: state.pathologistUid,
      );
      emit(_with(CaseScoreSuccess.new, score: score));
    } on Object catch (e) {
      emit(_failure(e));
    }
  }

  Future<void> _onAccepted(
    CaseRequestAccepted event,
    Emitter<CaseWorkspaceState> emit,
  ) async {
    if (state.caseUid.isEmpty) return;
    if (!await _internet.check()) {
      emit(_failure(AppError.noInternet));
      return;
    }
    final caseUid = state.caseUid;
    final pathologistUid = state.pathologistUid;
    emit(_with(CaseWorkspaceWriteInProgress.new));
    try {
      await _caseRemote.acceptCase(caseUid: caseUid);
      await _cases.syncCases(pathologistUid);
    } on Object catch (e) {
      emit(_failure(e));
      return;
    }
    // Now theirs: the workspace opens on the case as it always does.
    add(CaseWorkspaceOpened(caseUid: caseUid, pathologistUid: pathologistUid));
  }

  Future<void> _onSampleReceived(
    CaseSampleReceived event,
    Emitter<CaseWorkspaceState> emit,
  ) async {
    final accession = event.labAccessionNo.trim();
    if (state.caseUid.isEmpty || !_accession.hasMatch(accession)) {
      emit(_failure(AppError.invalidDecision));
      return;
    }
    if (!await _internet.check()) {
      emit(_failure(AppError.noInternet));
      return;
    }
    final caseUid = state.caseUid;
    final pathologistUid = state.pathologistUid;
    emit(_with(CaseWorkspaceWriteInProgress.new));
    try {
      await _caseRemote.recordSampleReceived(
        caseUid: caseUid,
        labAccessionNo: accession,
      );
      await _cases.syncCases(pathologistUid);
    } on Object catch (e) {
      emit(_failure(e));
      return;
    }
    add(CaseWorkspaceOpened(caseUid: caseUid, pathologistUid: pathologistUid));
  }

  Future<void> _onDeclined(
    CaseRequestDeclined event,
    Emitter<CaseWorkspaceState> emit,
  ) async {
    final reason = event.reason.trim();
    if (state.caseUid.isEmpty ||
        reason.isEmpty ||
        reason.length > _maxDeclineReason) {
      emit(_failure(AppError.invalidDecision));
      return;
    }
    if (!await _internet.check()) {
      emit(_failure(AppError.noInternet));
      return;
    }
    emit(_with(CaseWorkspaceWriteInProgress.new));
    try {
      await _caseRemote.rejectCase(caseUid: state.caseUid, reason: reason);
      await _cases.syncCases(state.pathologistUid);
      emit(_with(CaseRequestDeclineSuccess.new));
    } on Object catch (e) {
      emit(_failure(e));
    }
  }

  Future<void> _onRevision(
    CaseRevisionStarted event,
    Emitter<CaseWorkspaceState> emit,
  ) async {
    final kind = DraftKind.fromValue(event.kind);
    if (kind != .amendment && kind != .addendum) {
      emit(_failure(AppError.invalidDecision));
      return;
    }
    final text = event.text.trim();
    final max = kind == .amendment ? maxAmendmentReason : maxAddendumText;
    if (text.isEmpty || text.length > max) {
      emit(_failure(AppError.invalidDecision));
      return;
    }
    final caseModel = state.caseModel;
    final signed = state.signed;
    if (caseModel == null || signed == null || state.caseUid.isEmpty) {
      emit(_failure(AppError.dataNotFound));
      return;
    }
    // Only the signer, and only while the case is in a revision stage.
    if (signed.pathologistUid != state.pathologistUid) {
      emit(_failure(AppError.permissionDenied));
      return;
    }
    if (!revisionStages.contains(caseModel.currentStageValue)) {
      emit(_failure(AppError.invalidDecision));
      return;
    }
    if (!await _internet.check()) {
      emit(_failure(AppError.noInternet));
      return;
    }
    final caseUid = state.caseUid;
    final pathologistUid = state.pathologistUid;
    emit(_with(CaseWorkspaceWriteInProgress.new));
    try {
      await _remote.startReport(caseUid: caseUid, kind: kind.value);
      final field = kind == .amendment ? 'amendmentReason' : 'addendumText';
      await _reports.saveDraftFields(
        caseUid: caseUid,
        pathologistUid: pathologistUid,
        fields: {field: text},
      );
    } on Object catch (e) {
      // The signed version stays on screen; nothing was overwritten.
      emit(_failure(e));
      return;
    }
    add(CaseWorkspaceOpened(caseUid: caseUid, pathologistUid: pathologistUid));
  }

  Future<void> _onDiscardRevision(
    CaseRevisionDiscarded event,
    Emitter<CaseWorkspaceState> emit,
  ) async {
    final draft = state.draft;
    final kind = draft?.kindValue;
    // Only an open Amendment or Addendum leaves this way; an Initial draft
    // is the case's report, and the server refuses it too.
    if (draft == null ||
        (kind != .amendment && kind != .addendum) ||
        draft.statusValue != .editing ||
        state.caseUid.isEmpty) {
      emit(_failure(AppError.invalidDecision));
      return;
    }
    if (!await _internet.check()) {
      emit(_failure(AppError.noInternet));
      return;
    }
    final caseUid = state.caseUid;
    final pathologistUid = state.pathologistUid;
    emit(_with(CaseWorkspaceWriteInProgress.new));
    try {
      await _remote.discardDraft(
        caseUid: caseUid,
        draftLastUpdatedAt: draft.lastUpdatedAt,
      );
    } on Object catch (e) {
      // The draft stays open; the signed version was never touched.
      emit(_failure(e));
      return;
    }
    add(CaseWorkspaceOpened(caseUid: caseUid, pathologistUid: pathologistUid));
  }

  Future<void> _onSign(
    CaseSignRequested event,
    Emitter<CaseWorkspaceState> emit,
  ) async {
    // Each refusal names nothing new on the server: nothing is sent.
    if (!event.attested || event.signaturePng.isEmpty) {
      emit(_failure(AppError.invalidDecision));
      return;
    }
    if (state.draft == null) {
      emit(_failure(AppError.dataNotFound));
      return;
    }
    if (state.needsScore) {
      emit(_failure(AppError.invalidDecision));
      return;
    }
    if (!await _internet.check()) {
      emit(_failure(AppError.noInternet));
      return;
    }
    emit(_with(CaseWorkspaceWriteInProgress.new));
    try {
      // The server signs the draft it holds, matched by its stamp, so every
      // edit made on this phone must reach it first.
      await _reports.replayPendingDraftEdits(state.pathologistUid);
      if (await _reports.hasUnsyncedDraftEdits(state.caseUid)) {
        emit(_failure(AppError.noInternet));
        return;
      }
      final draft = await _reports.syncDraft(
        caseUid: state.caseUid,
        pathologistUid: state.pathologistUid,
      );
      if (draft == null) {
        emit(_failure(AppError.dataNotFound));
        return;
      }
      await _remote.signReport(
        caseUid: state.caseUid,
        signaturePng: event.signaturePng,
        draftLastUpdatedAt: draft.lastUpdatedAt,
      );
      final reports = await _reports.syncReports(
        state.pathologistUid,
        role: .pathologist,
      );
      final signed = reports
          .where((r) => r.caseUid == state.caseUid)
          .sortedBy((r) => r.signedAt)
          .lastOrNull;
      emit(_with(CaseSignSuccess.new, draft: draft, signed: signed));
    } on Object catch (e) {
      emit(_failure(e));
    }
  }

  CaseWorkspaceState _with(
    CaseWorkspaceState Function({
      String caseUid,
      String pathologistUid,
      CaseModel? caseModel,
      ReportDraftModel? draft,
      PrereadModel? preread,
      PrereadScoreModel? score,
      PathologyReportModel? signed,
      String prereadShownAt,
      bool offline,
    })
    build, {
    ReportDraftModel? draft,
    PrereadScoreModel? score,
    PathologyReportModel? signed,
  }) => build(
    caseUid: state.caseUid,
    pathologistUid: state.pathologistUid,
    caseModel: state.caseModel,
    draft: draft ?? state.draft,
    preread: state.preread,
    score: score ?? state.score,
    signed: signed ?? state.signed,
    prereadShownAt: state.prereadShownAt,
    offline: state.offline,
  );

  CaseWorkspaceWriteFailure _failure(Object e) => CaseWorkspaceWriteFailure(
    error: _toAppError(e),
    caseUid: state.caseUid,
    pathologistUid: state.pathologistUid,
    caseModel: state.caseModel,
    draft: state.draft,
    preread: state.preread,
    score: state.score,
    signed: state.signed,
    prereadShownAt: state.prereadShownAt,
    offline: state.offline,
  );
}
