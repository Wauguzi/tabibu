import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/services/analytics_service.dart';
import 'package:tabibu/core/services/internet_service.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_event.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_state.dart';
import 'package:tabibu/features/cases/blocs/share_bloc/share_viewer.dart';
import 'package:tabibu/features/cases/data/cache/case_cache_helper.dart';
import 'package:tabibu/features/cases/data/datasources/case_firebase.dart';
import 'package:tabibu/features/cases/data/datasources/share_code_firebase.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/data/models/share_code_model.dart';
import 'package:tabibu/features/practitioners/data/cache/practitioner_cache_helper.dart';
import 'package:uuid/uuid.dart';

/// Share codes and who-can-see. Writes need the network (rule 5). The raw
/// code lives only in [ShareState.revealedCode] until dismissed (T-18).
class ShareBloc extends Bloc<ShareEvent, ShareState> {
  ShareBloc({
    CaseCacheHelper? cache,
    ShareCodeFirebase? shares,
    CaseFirebase? cases,
    InternetService? internet,
    PractitionerCacheHelper? practitioners,
    AnalyticsService? analytics,
    String Function()? newShareUid,
  }) : _cache = cache ?? getIt<CaseCacheHelper>(),
       _shares = shares ?? getIt<ShareCodeFirebase>(),
       _cases = cases ?? getIt<CaseFirebase>(),
       _internet = internet ?? getIt<InternetService>(),
       _practitioners = practitioners ?? getIt<PractitionerCacheHelper>(),
       _analytics = analytics ?? getIt<AnalyticsService>(),
       _newShareUid = newShareUid ?? const Uuid().v4,
       super(const ShareInitial()) {
    on<ShareRequested>(_onRequested, transformer: droppable());
    on<ShareRefreshed>(_onRefreshed, transformer: droppable());
    on<ShareCreateRequested>(_onCreate, transformer: droppable());
    on<ShareReissueRequested>(_onReissue, transformer: droppable());
    on<ShareRevokeRequested>(_onRevoke, transformer: sequential());
    on<ShareRemoveViewerRequested>(_onRemoveViewer, transformer: sequential());
    on<ShareRedeemRequested>(_onRedeem, transformer: droppable());
    on<ShareCodeDismissed>(_onDismissCode);
    on<ShareReset>(_onReset);
  }

  final CaseCacheHelper _cache;
  final ShareCodeFirebase _shares;
  final CaseFirebase _cases;
  final InternetService _internet;
  final PractitionerCacheHelper _practitioners;
  final AnalyticsService _analytics;
  final String Function() _newShareUid;

  static const Set<AppError> _offline = {
    .noInternet,
    .serviceUnavailable,
    .requestTimeout,
  };

  AppError _toAppError(Object e) => e is AppError ? e : .unknown;

  Future<void> _requireOnline() async {
    if (!await _internet.check()) throw AppError.noInternet;
  }

  /// Care-team names come from the case; extra viewers from the directory
  /// (Join may add a pathologist, so role is not always doctor).
  Future<List<ShareViewer>> _viewersOf(CaseModel c) async {
    final rows = <ShareViewer>[];
    if (c.doctorUid.isNotEmpty) {
      rows.add(
        ShareViewer(
          uid: c.doctorUid,
          displayName: c.doctorName,
          role: .doctor,
          removable: false,
        ),
      );
    }
    if (c.pathologistUid.isNotEmpty) {
      rows.add(
        ShareViewer(
          uid: c.pathologistUid,
          displayName: c.pathologistName,
          role: .pathologist,
          removable: false,
        ),
      );
    }
    for (final uid in c.viewerUids) {
      if (uid.isEmpty || uid == c.doctorUid || uid == c.pathologistUid) {
        continue;
      }
      final practitioner = await _practitioners.getPractitioner(uid);
      rows.add(
        ShareViewer(
          uid: uid,
          displayName: practitioner?.fullName ?? '',
          role: practitioner?.isPathologist == true ? .pathologist : .doctor,
          removable: true,
        ),
      );
    }
    return rows;
  }

  CaseModel _caseFrom(List<CaseModel> cases, String caseUid) {
    for (final c in cases) {
      if (c.uid == caseUid) return c;
    }
    return const CaseModel();
  }

  ShareCodeModel? _shareInState(String shareUid) {
    for (final s in state.shares) {
      if (s.uid == shareUid) return s;
    }
    return null;
  }

  Future<({CaseModel caseModel, List<ShareCodeModel> shares})> _load({
    required String uid,
    required String caseUid,
    required bool asCreator,
    required bool syncFirst,
  }) async {
    List<CaseModel> cases;
    List<ShareCodeModel> shares;
    if (syncFirst) {
      try {
        cases = await _cache.syncCases(uid);
        shares = await _cache.syncShareCodes(uid: uid, asCreator: asCreator);
      } on Object catch (e) {
        if (!_offline.contains(_toAppError(e))) rethrow;
        cases = await _cache.getCases(uid);
        shares = await _cache.getShareCodes(uid, asCreator: asCreator);
        final c = _caseFrom(cases, caseUid);
        return (
          caseModel: c,
          shares: shares
              .where((s) => s.caseUid == caseUid || caseUid.isEmpty)
              .toList(),
        );
      }
    } else {
      cases = await _cache.getCases(uid);
      shares = await _cache.getShareCodes(uid, asCreator: asCreator);
      try {
        cases = await _cache.syncCases(uid);
        shares = await _cache.syncShareCodes(uid: uid, asCreator: asCreator);
      } on Object catch (e) {
        if (!_offline.contains(_toAppError(e))) rethrow;
      }
    }
    final c = _caseFrom(cases, caseUid);
    final forCase = caseUid.isEmpty
        ? shares
        : shares.where((s) => s.caseUid == caseUid).toList();
    return (caseModel: c, shares: forCase);
  }

  ShareLoadInProgress _inProgress() => ShareLoadInProgress(
    caseModel: state.caseModel,
    shares: state.shares,
    viewers: state.viewers,
    revealedCode: state.revealedCode,
    revealedShareUid: state.revealedShareUid,
    redeemedCaseUid: state.redeemedCaseUid,
    offline: state.offline,
  );

  ShareWriteInProgress _writing() => ShareWriteInProgress(
    caseModel: state.caseModel,
    shares: state.shares,
    viewers: state.viewers,
    revealedCode: state.revealedCode,
    revealedShareUid: state.revealedShareUid,
    redeemedCaseUid: state.redeemedCaseUid,
    offline: state.offline,
  );

  Future<ShareLoadSuccess> _success({
    required CaseModel caseModel,
    required List<ShareCodeModel> shares,
    String revealedCode = '',
    String revealedShareUid = '',
    String redeemedCaseUid = '',
    bool offline = false,
  }) async => ShareLoadSuccess(
    caseModel: caseModel,
    shares: shares,
    viewers: await _viewersOf(caseModel),
    revealedCode: revealedCode,
    revealedShareUid: revealedShareUid,
    redeemedCaseUid: redeemedCaseUid,
    offline: offline,
  );

  Future<void> _onRequested(
    ShareRequested event,
    Emitter<ShareState> emit,
  ) async {
    emit(_inProgress());
    try {
      final loaded = await _load(
        uid: event.uid,
        caseUid: event.caseUid,
        asCreator: event.asCreator,
        syncFirst: false,
      );
      emit(
        await _success(
          caseModel: loaded.caseModel,
          shares: loaded.shares,
          redeemedCaseUid: state.redeemedCaseUid,
        ),
      );
    } on Object catch (e) {
      final err = _toAppError(e);
      final offline = _offline.contains(err);
      emit(
        ShareLoadFailure(
          error: err,
          caseModel: state.caseModel,
          shares: state.shares,
          viewers: state.viewers,
          offline: offline,
        ),
      );
    }
  }

  Future<void> _onRefreshed(
    ShareRefreshed event,
    Emitter<ShareState> emit,
  ) async {
    emit(_inProgress());
    try {
      final loaded = await _load(
        uid: event.uid,
        caseUid: event.caseUid,
        asCreator: event.asCreator,
        syncFirst: true,
      );
      emit(
        await _success(
          caseModel: loaded.caseModel,
          shares: loaded.shares,
          redeemedCaseUid: state.redeemedCaseUid,
        ),
      );
    } on Object catch (e) {
      emit(
        ShareLoadFailure(
          error: _toAppError(e),
          caseModel: state.caseModel,
          shares: state.shares,
          viewers: state.viewers,
          offline: _offline.contains(_toAppError(e)),
        ),
      );
    }
  }

  /// Pulls a code out of a callable map without ever writing it to the cache.
  String _codeOf(Map<String, dynamic> raw) {
    final value = raw['code'];
    return value is String ? value : '';
  }

  Future<void> _onCreate(
    ShareCreateRequested event,
    Emitter<ShareState> emit,
  ) async {
    emit(_writing());
    try {
      await _requireOnline();
      final shareUid = _newShareUid();
      final raw = await _shares.createShareCode(
        shareUid: shareUid,
        caseUid: event.caseUid,
        recipientUid: event.recipientUid,
      );
      // Strip before any cache write (T-18).
      await _cache.cacheShareCodeMaps([
        CaseCacheHelper.stripShareSecret({
          'uid': shareUid,
          'caseUid': event.caseUid,
          'createdByUid': event.uid,
          'createdByRole': event.role.name,
          'recipientUid': event.recipientUid,
          'status': 'Pending',
          ...raw,
        }),
      ], fromCloud: true);
      final shares = await _cache.getShareCodes(event.uid, asCreator: true);
      final forCase = shares.where((s) => s.caseUid == event.caseUid).toList();
      final code = _codeOf(raw);
      final purpose = SharePurpose.join.value;
      unawaited(_analytics.logShareCreated(purpose: purpose));
      emit(
        ShareCreateSuccess(
          caseModel: state.caseModel,
          shares: forCase,
          viewers: state.viewers,
          revealedCode: code,
          revealedShareUid: code.isEmpty ? '' : shareUid,
          redeemedCaseUid: state.redeemedCaseUid,
        ),
      );
    } on Object catch (e) {
      emit(
        ShareWriteFailure(
          error: _toAppError(e),
          caseModel: state.caseModel,
          shares: state.shares,
          viewers: state.viewers,
          revealedCode: state.revealedCode,
          revealedShareUid: state.revealedShareUid,
          redeemedCaseUid: state.redeemedCaseUid,
        ),
      );
    }
  }

  Future<void> _onReissue(
    ShareReissueRequested event,
    Emitter<ShareState> emit,
  ) async {
    emit(_writing());
    try {
      await _requireOnline();
      final purpose =
          _shareInState(event.shareUid)?.purpose ?? SharePurpose.join.value;
      final raw = await _shares.reissueShareCode(shareUid: event.shareUid);
      await _cache.cacheShareCodeMaps([
        CaseCacheHelper.stripShareSecret({'uid': event.shareUid, ...raw}),
      ], fromCloud: true);
      final shares = await _cache.getShareCodes(event.uid, asCreator: true);
      final code = _codeOf(raw);
      unawaited(_analytics.logShareReissued(purpose: purpose));
      emit(
        ShareCreateSuccess(
          caseModel: state.caseModel,
          shares: shares
              .where(
                (s) =>
                    state.caseModel.uid.isEmpty ||
                    s.caseUid == state.caseModel.uid,
              )
              .toList(),
          viewers: state.viewers,
          // A reissue replaces any prior revealed code.
          revealedCode: code,
          revealedShareUid: code.isEmpty ? '' : event.shareUid,
          redeemedCaseUid: state.redeemedCaseUid,
        ),
      );
    } on Object catch (e) {
      emit(
        ShareWriteFailure(
          error: _toAppError(e),
          caseModel: state.caseModel,
          shares: state.shares,
          viewers: state.viewers,
          redeemedCaseUid: state.redeemedCaseUid,
        ),
      );
    }
  }

  Future<void> _onRevoke(
    ShareRevokeRequested event,
    Emitter<ShareState> emit,
  ) async {
    emit(_writing());
    try {
      await _requireOnline();
      final purpose =
          _shareInState(event.shareUid)?.purpose ?? SharePurpose.join.value;
      await _shares.revokeShareCode(shareUid: event.shareUid);
      await _cache.evictShareCode(event.shareUid);
      final shares = state.shares
          .where((s) => s.uid != event.shareUid)
          .toList();
      unawaited(_analytics.logShareRevoked(purpose: purpose));
      emit(
        ShareRevokeSuccess(
          caseModel: state.caseModel,
          shares: shares,
          viewers: state.viewers,
          revealedCode: state.revealedShareUid == event.shareUid
              ? ''
              : state.revealedCode,
          revealedShareUid: state.revealedShareUid == event.shareUid
              ? ''
              : state.revealedShareUid,
          redeemedCaseUid: state.redeemedCaseUid,
        ),
      );
    } on Object catch (e) {
      emit(
        ShareWriteFailure(
          error: _toAppError(e),
          caseModel: state.caseModel,
          shares: state.shares,
          viewers: state.viewers,
          revealedCode: state.revealedCode,
          revealedShareUid: state.revealedShareUid,
          redeemedCaseUid: state.redeemedCaseUid,
        ),
      );
    }
  }

  Future<void> _onRemoveViewer(
    ShareRemoveViewerRequested event,
    Emitter<ShareState> emit,
  ) async {
    emit(_writing());
    try {
      await _requireOnline();
      final c = state.caseModel;
      if (event.viewerUid == c.doctorUid ||
          event.viewerUid == c.pathologistUid) {
        throw AppError.permissionDenied;
      }
      await _cases.removeCaseViewer(
        caseUid: event.caseUid,
        viewerUid: event.viewerUid,
      );
      final next = c.copyWith(
        viewerUids: [
          for (final uid in c.viewerUids)
            if (uid != event.viewerUid) uid,
        ],
      );
      unawaited(_analytics.logShareViewerRemoved());
      emit(
        ShareRemoveViewerSuccess(
          caseModel: next,
          shares: state.shares,
          viewers: await _viewersOf(next),
          revealedCode: state.revealedCode,
          revealedShareUid: state.revealedShareUid,
          redeemedCaseUid: state.redeemedCaseUid,
        ),
      );
    } on Object catch (e) {
      emit(
        ShareWriteFailure(
          error: _toAppError(e),
          caseModel: state.caseModel,
          shares: state.shares,
          viewers: state.viewers,
          revealedCode: state.revealedCode,
          revealedShareUid: state.revealedShareUid,
          redeemedCaseUid: state.redeemedCaseUid,
        ),
      );
    }
  }

  Future<void> _onRedeem(
    ShareRedeemRequested event,
    Emitter<ShareState> emit,
  ) async {
    emit(_writing());
    try {
      await _requireOnline();
      // Screen must load recipient shares first so we know which case to open.
      final share = _shareInState(event.shareUid);
      if (share == null || share.caseUid.isEmpty) {
        throw AppError.dataNotFound;
      }
      await _shares.redeemShareCode(shareUid: event.shareUid, code: event.code);
      unawaited(_analytics.logShareRedeemed(purpose: share.purpose));
      emit(
        ShareRedeemSuccess(
          caseModel: state.caseModel,
          shares: state.shares,
          viewers: state.viewers,
          redeemedCaseUid: share.caseUid,
        ),
      );
    } on Object catch (e) {
      emit(
        ShareWriteFailure(
          error: _toAppError(e),
          caseModel: state.caseModel,
          shares: state.shares,
          viewers: state.viewers,
        ),
      );
    }
  }

  void _onDismissCode(ShareCodeDismissed event, Emitter<ShareState> emit) {
    if (state.revealedCode.isEmpty && state.revealedShareUid.isEmpty) return;
    emit(
      ShareLoadSuccess(
        caseModel: state.caseModel,
        shares: state.shares,
        viewers: state.viewers,
        redeemedCaseUid: state.redeemedCaseUid,
        offline: state.offline,
      ),
    );
  }

  void _onReset(ShareReset event, Emitter<ShareState> emit) {
    emit(const ShareInitial());
  }
}
