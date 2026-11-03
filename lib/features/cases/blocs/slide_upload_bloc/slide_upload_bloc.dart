import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/services/analytics_service.dart';
import 'package:tabibu/core/services/internet_service.dart';
import 'package:tabibu/features/cases/blocs/slide_upload_bloc/slide_item.dart';
import 'package:tabibu/features/cases/blocs/slide_upload_bloc/slide_upload_event.dart';
import 'package:tabibu/features/cases/blocs/slide_upload_bloc/slide_upload_state.dart';
import 'package:tabibu/features/cases/data/cache/case_cache_helper.dart';
import 'package:tabibu/features/cases/data/datasources/case_firebase.dart';
import 'package:tabibu/features/cases/data/datasources/slide_storage.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:uuid/uuid.dart';

/// Puts slide bytes on a case: reserve once, upload each, register only what
/// arrived. It sends bytes and nothing else; it never shows a slide or a
/// pre-read. Every check that can be made on the device is made before the
/// first call, and a slide with no pixel size is never sent.
class SlideUploadBloc extends Bloc<SlideUploadEvent, SlideUploadState> {
  SlideUploadBloc({
    CaseCacheHelper? cache,
    CaseFirebase? cases,
    SlideStorage? storage,
    InternetService? internet,
    AnalyticsService? analytics,
    String Function()? newLocalId,
  }) : _cache = cache ?? getIt<CaseCacheHelper>(),
       _cases = cases ?? getIt<CaseFirebase>(),
       _storage = storage ?? getIt<SlideStorage>(),
       _internet = internet ?? getIt<InternetService>(),
       _analytics = analytics ?? getIt<AnalyticsService>(),
       _newLocalId = newLocalId ?? const Uuid().v4,
       super(const SlideUploadInitial()) {
    on<SlidesPicked>(_onPicked);
    on<SlideRemoved>(_onRemoved);
    on<SlidePixelSizeSet>(_onPixelSizeSet);
    on<SlideUploadRequested>(_onUpload, transformer: droppable());
    on<SlideUploadReset>(_onReset);
  }

  final CaseCacheHelper _cache;
  final CaseFirebase _cases;
  final SlideStorage _storage;
  final InternetService _internet;
  final AnalyticsService _analytics;
  final String Function() _newLocalId;

  /// `MAX_SLIDES` on the server: registered and reserved together.
  static const int maxSlides = 20;

  static const Set<AppError> _offlineErrors = {
    .noInternet,
    .serviceUnavailable,
    .requestTimeout,
  };

  /// Bumped by a reset so an upload that outlives a sign-out stops emitting
  /// the last account's slides.
  int _generation = 0;

  AppError _toAppError(Object e) => e is AppError ? e : .unknown;

  /// By content, never by name: JPEG `FF D8 FF`, PNG `89 50 4E 47`.
  static String? _sniff(Uint8List b) {
    if (b.length >= 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) {
      return SlideStorage.jpeg;
    }
    if (b.length >= 4 &&
        b[0] == 0x89 &&
        b[1] == 0x50 &&
        b[2] == 0x4E &&
        b[3] == 0x47) {
      return SlideStorage.png;
    }
    return null;
  }

  CaseModel? _caseIn(List<CaseModel> cases, String caseUid) {
    for (final c in cases) {
      if (c.uid == caseUid) return c;
    }
    return null;
  }

  SlideItem? _slide(String localId) {
    for (final s in state.slides) {
      if (s.localId == localId) return s;
    }
    return null;
  }

  bool _isRegistered(SlideItem slide, CaseModel? caseModel) {
    final imageUid = slide.reservedImageUid;
    if (imageUid == null || caseModel == null) return false;
    return caseModel.slideImages.any((i) => i.imageUid == imageUid);
  }

  /// What the case would hold if every slide here were registered.
  int _occupied(List<SlideItem> slides, CaseModel? caseModel) =>
      (caseModel?.slideImages.length ?? 0) +
      slides.where((s) => !_isRegistered(s, caseModel)).length;

  /// The state for an edit. While an upload runs it stays in progress, so a
  /// late edit never reads as the end of the upload.
  SlideUploadState _edited(List<SlideItem> slides, {AppError? error}) {
    if (state is SlideUploadInProgress) {
      return SlideUploadInProgress(
        caseUid: state.caseUid,
        slides: slides,
        caseModel: state.caseModel,
      );
    }
    if (error != null) {
      return SlideUploadFailure(
        error: error,
        caseUid: state.caseUid,
        slides: slides,
        caseModel: state.caseModel,
      );
    }
    return SlideUploadEditing(
      caseUid: state.caseUid,
      slides: slides,
      caseModel: state.caseModel,
    );
  }

  void _onPicked(SlidesPicked event, Emitter<SlideUploadState> emit) {
    final slides = [...state.slides];
    AppError? refused;
    for (final pick in event.picks) {
      final contentType = _sniff(pick.bytes);
      if (contentType == null) {
        refused ??= .invalidSlides;
        continue;
      }
      if (pick.bytes.length > SlideStorage.maxSlideBytes) {
        refused ??= .fileTooLarge;
        continue;
      }
      if (_occupied(slides, state.caseModel) >= maxSlides) {
        refused ??= .tooManySlides;
        continue;
      }
      slides.add(
        SlideItem(
          localId: _newLocalId(),
          fileName: pick.fileName,
          bytes: pick.bytes,
          contentType: contentType,
        ),
      );
    }
    emit(_edited(slides, error: refused));
  }

  void _onRemoved(SlideRemoved event, Emitter<SlideUploadState> emit) {
    final slide = _slide(event.localId);
    if (slide == null) return;
    if (slide.isSettled) {
      emit(_edited(state.slides, error: .invalidSlides));
      return;
    }
    emit(
      _edited([
        for (final s in state.slides)
          if (s.localId != event.localId) s,
      ]),
    );
  }

  void _onPixelSizeSet(
    SlidePixelSizeSet event,
    Emitter<SlideUploadState> emit,
  ) {
    final slide = _slide(event.localId);
    if (slide == null) return;
    final value = event.micronsPerPixel;
    final valid = value.isFinite && value > 0 && value <= 100;
    if (slide.isSettled || !valid) {
      emit(_edited(state.slides, error: .invalidSlides));
      return;
    }
    emit(
      _edited([
        for (final s in state.slides)
          if (s.localId == event.localId)
            s.copyWith(
              micronsPerPixel: value,
              clearError: s.error == AppError.invalidSlides,
            )
          else
            s,
      ]),
    );
  }

  Future<void> _onUpload(
    SlideUploadRequested event,
    Emitter<SlideUploadState> emit,
  ) async {
    final generation = _generation;
    bool live() => generation == _generation;

    SlideUploadFailure failure(AppError error) => SlideUploadFailure(
      error: error,
      caseUid: event.caseUid,
      slides: state.slides,
      caseModel: state.caseModel,
      offline: _offlineErrors.contains(error),
    );

    // Patches one slide in the state as it now stands, so a pick made while
    // the upload runs is never overwritten.
    void patch(String localId, SlideItem Function(SlideItem) change) {
      if (!live() || _slide(localId) == null) return;
      emit(
        SlideUploadInProgress(
          caseUid: event.caseUid,
          slides: [
            for (final s in state.slides)
              if (s.localId == localId) change(s) else s,
          ],
          caseModel: state.caseModel,
        ),
      );
    }

    if (!await _internet.check()) {
      if (live()) emit(failure(.noInternet));
      return;
    }
    if (!live()) return;

    emit(
      SlideUploadInProgress(
        caseUid: event.caseUid,
        slides: state.slides,
        caseModel: state.caseModel,
      ),
    );

    try {
      final current =
          _caseIn(await _cache.getCases(event.uid), event.caseUid) ??
          const CaseModel();
      if (!live()) return;

      // Uploaded but not registered: an earlier register failed. They go in
      // this request's register call without being sent again.
      final awaiting = [
        for (final s in state.slides)
          if (s.status == .uploaded && !_isRegistered(s, current)) s.localId,
      ];
      final candidates = [
        for (final s in state.slides)
          if (s.status == .picked || s.status == .failed) s,
      ];
      // No pixel size, no upload; the bloc never supplies one.
      for (final unsized in candidates.where((s) => !s.hasValidPixelSize)) {
        patch(
          unsized.localId,
          (s) => s.copyWith(status: .failed, error: .invalidSlides),
        );
      }
      final ready = [
        for (final s in candidates)
          if (s.hasValidPixelSize) s.localId,
      ];
      if (ready.isEmpty && awaiting.isEmpty) {
        emit(failure(.invalidSlides));
        return;
      }

      final registered = current.slideImages.length;
      final needNew = [
        for (final id in ready)
          if (_slide(id)?.reservedImageUid == null) id,
      ];
      if (registered + ready.length + awaiting.length > maxSlides ||
          (needNew.isNotEmpty &&
              registered + current.slideUploadUids.length + needNew.length >
                  maxSlides)) {
        emit(failure(.tooManySlides));
        return;
      }

      // One reservation for the whole batch. A retry reuses what it holds.
      if (needNew.isNotEmpty) {
        final reply = await _cases.reserveSlideUploads(
          caseUid: event.caseUid,
          count: needNew.length,
        );
        if (!live()) return;
        if (reply['full'] == true) throw AppError.tooManySlides;
        final raw = reply['imageUids'];
        final imageUids = raw is List
            ? raw.whereType<String>().toList()
            : <String>[];
        if (imageUids.length != needNew.length) throw AppError.unknown;
        for (var i = 0; i < needNew.length; i++) {
          patch(needNew[i], (s) => s.copyWith(reservedImageUid: imageUids[i]));
        }
      }

      for (final id in ready) {
        final slide = _slide(id);
        final imageUid = slide?.reservedImageUid;
        if (slide == null) continue;
        if (imageUid == null) {
          patch(id, (s) => s.copyWith(status: .failed, error: .unknown));
          continue;
        }
        patch(id, (s) => s.copyWith(status: .uploading, clearError: true));
        try {
          await _storage.uploadSlide(
            caseUid: event.caseUid,
            imageUid: imageUid,
            bytes: slide.bytes,
            contentType: slide.contentType,
          );
          patch(id, (s) => s.copyWith(status: .uploaded));
        } on Object catch (e) {
          // The reserved name stays on the slide for the retry.
          patch(id, (s) => s.copyWith(status: .failed, error: _toAppError(e)));
        }
        if (!live()) return;
      }

      // Only what reached Storage is registered.
      final images = [
        for (final s in state.slides)
          if (s.status == .uploaded &&
              !_isRegistered(s, current) &&
              s.reservedImageUid != null)
            {
              'imageUid': s.reservedImageUid,
              'contentType': s.contentType,
              'micronsPerPixel': s.micronsPerPixel,
            },
      ];
      if (images.isEmpty) {
        final first = state.slides
            .map((s) => s.error)
            .whereType<AppError>()
            .firstOrNull;
        emit(failure(first ?? .unknown));
        return;
      }

      await _cases.registerSlides(caseUid: event.caseUid, images: images);
      if (!live()) return;
      unawaited(_analytics.logSlidesUploaded(count: images.length));

      // The registration is done; a failed re-read must not undo it.
      CaseModel? synced;
      try {
        synced = _caseIn(await _cache.syncCases(event.uid), event.caseUid);
      } on Object catch (_) {
        // The next read of the case catches up.
      }
      if (!live()) return;
      emit(
        SlideUploadSuccess(
          caseUid: event.caseUid,
          slides: state.slides,
          caseModel: synced ?? state.caseModel,
        ),
      );
    } on Object catch (e) {
      if (live()) emit(failure(_toAppError(e)));
    }
  }

  void _onReset(SlideUploadReset event, Emitter<SlideUploadState> emit) {
    _generation++;
    emit(const SlideUploadInitial());
  }
}
