import 'dart:async';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/services/analytics_service.dart';
import 'package:tabibu/core/services/internet_service.dart';
import 'package:tabibu/features/cases/blocs/slide_upload_bloc/slide_item.dart';
import 'package:tabibu/features/cases/blocs/slide_upload_bloc/slide_upload_bloc.dart';
import 'package:tabibu/features/cases/blocs/slide_upload_bloc/slide_upload_event.dart';
import 'package:tabibu/features/cases/blocs/slide_upload_bloc/slide_upload_state.dart';
import 'package:tabibu/features/cases/data/cache/case_cache_helper.dart';
import 'package:tabibu/features/cases/data/datasources/case_firebase.dart';
import 'package:tabibu/features/cases/data/datasources/slide_storage.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/data/models/slide_image_model.dart';

class _MockCache extends Mock implements CaseCacheHelper {}

class _MockCases extends Mock implements CaseFirebase {}

class _MockStorage extends Mock implements SlideStorage {}

class _MockInternet extends Mock implements InternetService {}

class _MockAnalytics extends Mock implements AnalyticsService {}

/// JPEG SOI + a few payload bytes. Content sniff, not the file name.
Uint8List _jpeg([int length = 8]) {
  final bytes = Uint8List(length);
  bytes[0] = 0xFF;
  bytes[1] = 0xD8;
  bytes[2] = 0xFF;
  return bytes;
}

Uint8List _png([int length = 8]) {
  final bytes = Uint8List(length);
  bytes[0] = 0x89;
  bytes[1] = 0x50;
  bytes[2] = 0x4E;
  bytes[3] = 0x47;
  return bytes;
}

void main() {
  late _MockCache cache;
  late _MockCases cases;
  late _MockStorage storage;
  late _MockInternet internet;
  late _MockAnalytics analytics;
  var nextId = 0;

  SlideUploadBloc build() => SlideUploadBloc(
    cache: cache,
    cases: cases,
    storage: storage,
    internet: internet,
    analytics: analytics,
    newLocalId: () => 'local-${nextId++}',
  );

  const emptyCase = CaseModel(uid: 'c1', requiresSlides: true);

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    cache = _MockCache();
    cases = _MockCases();
    storage = _MockStorage();
    internet = _MockInternet();
    analytics = _MockAnalytics();
    nextId = 0;
    when(() => internet.check()).thenAnswer((_) async => true);
    when(() => cache.getCases(any())).thenAnswer((_) async => [emptyCase]);
    when(() => cache.syncCases(any())).thenAnswer((_) async => [emptyCase]);
    when(
      () => cases.reserveSlideUploads(
        caseUid: any(named: 'caseUid'),
        count: any(named: 'count'),
      ),
    ).thenAnswer(
      (inv) async => {
        'imageUids': [
          for (var i = 0; i < (inv.namedArguments[#count]! as int); i++)
            'img-$i',
        ],
      },
    );
    when(
      () => cases.registerSlides(
        caseUid: any(named: 'caseUid'),
        images: any(named: 'images'),
      ),
    ).thenAnswer((_) async => <String, dynamic>{});
    when(
      () => storage.uploadSlide(
        caseUid: any(named: 'caseUid'),
        imageUid: any(named: 'imageUid'),
        bytes: any(named: 'bytes'),
        contentType: any(named: 'contentType'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => analytics.logSlidesUploaded(count: any(named: 'count')),
    ).thenAnswer((_) async {});
  });

  group('rule 1: device checks before any call', () {
    blocTest<SlideUploadBloc, SlideUploadState>(
      'rejects non-JPG/PNG by content, not the name',
      build: build,
      act: (bloc) => bloc.add(
        SlidesPicked(
          picks: [
            SlidePick(
              bytes: Uint8List.fromList([0, 1, 2, 3, 4]),
              fileName: 'slide.jpg',
              contentType: 'image/jpeg',
            ),
          ],
        ),
      ),
      expect: () => [
        isA<SlideUploadFailure>()
            .having((s) => s.error, 'error', AppError.invalidSlides)
            .having((s) => s.slides, 'slides', isEmpty),
      ],
      verify: (_) {
        verifyNever(
          () => cases.reserveSlideUploads(
            caseUid: any(named: 'caseUid'),
            count: any(named: 'count'),
          ),
        );
      },
    );

    blocTest<SlideUploadBloc, SlideUploadState>(
      'rejects a file over 20 MB on pick',
      build: build,
      act: (bloc) {
        final bytes = _jpeg(SlideStorage.maxSlideBytes + 1);
        bloc.add(
          SlidesPicked(
            picks: [
              SlidePick(
                bytes: bytes,
                fileName: 'big.jpg',
                contentType: 'image/jpeg',
              ),
            ],
          ),
        );
      },
      expect: () => [
        isA<SlideUploadFailure>()
            .having((s) => s.error, 'error', AppError.fileTooLarge)
            .having((s) => s.slides, 'slides', isEmpty),
      ],
    );

    blocTest<SlideUploadBloc, SlideUploadState>(
      'never uploads a slide without a pixel size, and invents no default',
      build: build,
      act: (bloc) async {
        bloc.add(
          SlidesPicked(
            picks: [
              SlidePick(
                bytes: _jpeg(),
                fileName: 'a.jpg',
                contentType: 'image/jpeg',
              ),
            ],
          ),
        );
        await bloc.stream.first;
        bloc.add(const SlideUploadRequested(uid: 'u1', caseUid: 'c1'));
      },
      expect: () => [
        isA<SlideUploadEditing>().having((s) => s.slides.length, 'n', 1),
        isA<SlideUploadInProgress>(),
        isA<SlideUploadInProgress>().having(
          (s) => s.slides.single.status,
          'status',
          SlideUploadStatus.failed,
        ),
        isA<SlideUploadFailure>().having(
          (s) => s.error,
          'error',
          AppError.invalidSlides,
        ),
      ],
      verify: (_) {
        verifyNever(
          () => cases.reserveSlideUploads(
            caseUid: any(named: 'caseUid'),
            count: any(named: 'count'),
          ),
        );
        verifyNever(
          () => storage.uploadSlide(
            caseUid: any(named: 'caseUid'),
            imageUid: any(named: 'imageUid'),
            bytes: any(named: 'bytes'),
            contentType: any(named: 'contentType'),
          ),
        );
      },
    );

    blocTest<SlideUploadBloc, SlideUploadState>(
      'refuses a pixel size outside (0, 100]',
      build: build,
      seed: () => SlideUploadEditing(
        caseUid: 'c1',
        slides: [
          SlideItem(
            localId: 'local-0',
            fileName: 'a.jpg',
            bytes: _jpeg(),
            contentType: SlideStorage.jpeg,
          ),
        ],
      ),
      act: (bloc) => bloc.add(
        const SlidePixelSizeSet(localId: 'local-0', micronsPerPixel: 0),
      ),
      expect: () => [
        isA<SlideUploadFailure>().having(
          (s) => s.error,
          'error',
          AppError.invalidSlides,
        ),
      ],
    );

    blocTest<SlideUploadBloc, SlideUploadState>(
      'refuses a 21st slide when the case already holds 19',
      build: build,
      seed: () {
        final existing = [
          for (var i = 0; i < 19; i++) SlideImageModel(imageUid: 'existing-$i'),
        ];
        return SlideUploadEditing(
          caseUid: 'c1',
          caseModel: CaseModel(
            uid: 'c1',
            requiresSlides: true,
            slideImages: existing,
          ),
          slides: [
            SlideItem(
              localId: 'local-0',
              fileName: 'a.jpg',
              bytes: _jpeg(),
              contentType: SlideStorage.jpeg,
            ),
          ],
        );
      },
      act: (bloc) => bloc.add(
        SlidesPicked(
          picks: [
            SlidePick(
              bytes: _png(),
              fileName: 'b.png',
              contentType: 'image/png',
            ),
          ],
        ),
      ),
      expect: () => [
        isA<SlideUploadFailure>()
            .having((s) => s.error, 'error', AppError.tooManySlides)
            .having((s) => s.slides.length, 'n', 1),
      ],
    );
  });

  group(
    'rule 2: reserve once, upload each, register uploaded; retry reuses',
    () {
      blocTest<SlideUploadBloc, SlideUploadState>(
        'reserves once for the batch, uploads each, registers only uploaded',
        build: build,
        act: (bloc) async {
          bloc.add(
            SlidesPicked(
              picks: [
                SlidePick(
                  bytes: _jpeg(),
                  fileName: 'a.jpg',
                  contentType: 'image/jpeg',
                ),
                SlidePick(
                  bytes: _png(),
                  fileName: 'b.png',
                  contentType: 'image/png',
                ),
              ],
            ),
          );
          await bloc.stream.first;
          bloc
            ..add(
              const SlidePixelSizeSet(localId: 'local-0', micronsPerPixel: 0.5),
            )
            ..add(
              const SlidePixelSizeSet(localId: 'local-1', micronsPerPixel: 1),
            )
            ..add(const SlideUploadRequested(uid: 'u1', caseUid: 'c1'));
        },
        wait: const Duration(milliseconds: 50),
        verify: (bloc) {
          verify(
            () => cases.reserveSlideUploads(caseUid: 'c1', count: 2),
          ).called(1);
          verify(
            () => storage.uploadSlide(
              caseUid: 'c1',
              imageUid: 'img-0',
              bytes: any(named: 'bytes'),
              contentType: SlideStorage.jpeg,
            ),
          ).called(1);
          verify(
            () => storage.uploadSlide(
              caseUid: 'c1',
              imageUid: 'img-1',
              bytes: any(named: 'bytes'),
              contentType: SlideStorage.png,
            ),
          ).called(1);
          final captured =
              verify(
                    () => cases.registerSlides(
                      caseUid: 'c1',
                      images: captureAny(named: 'images'),
                    ),
                  ).captured.single
                  as List<Object?>;
          final images = [
            for (final row in captured) Map<String, Object?>.from(row! as Map),
          ];
          expect(images, hasLength(2));
          expect(bloc.state, isA<SlideUploadSuccess>());
        },
      );

      blocTest<SlideUploadBloc, SlideUploadState>(
        'a failed upload keeps its reserved name; retry never reserves again',
        build: build,
        setUp: () {
          var uploads = 0;
          when(
            () => storage.uploadSlide(
              caseUid: any(named: 'caseUid'),
              imageUid: any(named: 'imageUid'),
              bytes: any(named: 'bytes'),
              contentType: any(named: 'contentType'),
            ),
          ).thenAnswer((_) async {
            uploads++;
            if (uploads == 1) throw AppError.serviceUnavailable;
          });
          when(
            () => cache.getCases(any()),
          ).thenAnswer((_) async => [emptyCase]);
          when(() => cache.syncCases(any())).thenAnswer(
            (_) async => [
              const CaseModel(
                uid: 'c1',
                requiresSlides: true,
                slideImages: [SlideImageModel(imageUid: 'img-0')],
              ),
            ],
          );
        },
        seed: () => SlideUploadEditing(
          caseUid: 'c1',
          caseModel: emptyCase,
          slides: [
            SlideItem(
              localId: 'local-0',
              fileName: 'a.jpg',
              bytes: _jpeg(),
              contentType: SlideStorage.jpeg,
              micronsPerPixel: 0.5,
            ),
          ],
        ),
        act: (bloc) async {
          bloc.add(const SlideUploadRequested(uid: 'u1', caseUid: 'c1'));
          await bloc.stream.firstWhere((s) => s is SlideUploadFailure);
          bloc.add(const SlideUploadRequested(uid: 'u1', caseUid: 'c1'));
        },
        wait: const Duration(milliseconds: 50),
        verify: (bloc) {
          verify(
            () => cases.reserveSlideUploads(caseUid: 'c1', count: 1),
          ).called(1);
          verify(
            () => storage.uploadSlide(
              caseUid: 'c1',
              imageUid: 'img-0',
              bytes: any(named: 'bytes'),
              contentType: any(named: 'contentType'),
            ),
          ).called(2);
          expect(bloc.state.slides.single.reservedImageUid, 'img-0');
          expect(bloc.state, isA<SlideUploadSuccess>());
        },
      );

      blocTest<SlideUploadBloc, SlideUploadState>(
        'registers only slides that reached Storage when one fails',
        build: build,
        setUp: () {
          when(
            () => storage.uploadSlide(
              caseUid: any(named: 'caseUid'),
              imageUid: any(named: 'imageUid'),
              bytes: any(named: 'bytes'),
              contentType: any(named: 'contentType'),
            ),
          ).thenAnswer((inv) async {
            final uid = inv.namedArguments[#imageUid] as String;
            if (uid == 'img-1') throw AppError.serviceUnavailable;
          });
        },
        seed: () => SlideUploadEditing(
          caseUid: 'c1',
          caseModel: emptyCase,
          slides: [
            SlideItem(
              localId: 'local-0',
              fileName: 'a.jpg',
              bytes: _jpeg(),
              contentType: SlideStorage.jpeg,
              micronsPerPixel: 0.5,
            ),
            SlideItem(
              localId: 'local-1',
              fileName: 'b.png',
              bytes: _png(),
              contentType: SlideStorage.png,
              micronsPerPixel: 1,
            ),
          ],
        ),
        act: (bloc) =>
            bloc.add(const SlideUploadRequested(uid: 'u1', caseUid: 'c1')),
        wait: const Duration(milliseconds: 50),
        verify: (_) {
          final captured =
              verify(
                    () => cases.registerSlides(
                      caseUid: 'c1',
                      images: captureAny(named: 'images'),
                    ),
                  ).captured.single
                  as List<Object?>;
          final images = [
            for (final row in captured) Map<String, Object?>.from(row! as Map),
          ];
          expect(images, hasLength(1));
          expect(images.single['imageUid'], 'img-0');
        },
      );
    },
  );

  group('rule 3: offline fails fast', () {
    blocTest<SlideUploadBloc, SlideUploadState>(
      'offline fails before any call; nothing is queued',
      build: build,
      setUp: () {
        when(() => internet.check()).thenAnswer((_) async => false);
      },
      seed: () => SlideUploadEditing(
        caseUid: 'c1',
        slides: [
          SlideItem(
            localId: 'local-0',
            fileName: 'a.jpg',
            bytes: _jpeg(),
            contentType: SlideStorage.jpeg,
            micronsPerPixel: 0.5,
          ),
        ],
      ),
      act: (bloc) =>
          bloc.add(const SlideUploadRequested(uid: 'u1', caseUid: 'c1')),
      expect: () => [
        isA<SlideUploadFailure>()
            .having((s) => s.error, 'error', AppError.noInternet)
            .having((s) => s.offline, 'offline', isTrue),
      ],
      verify: (_) {
        verifyNever(
          () => cases.reserveSlideUploads(
            caseUid: any(named: 'caseUid'),
            count: any(named: 'count'),
          ),
        );
        verifyNever(
          () => storage.uploadSlide(
            caseUid: any(named: 'caseUid'),
            imageUid: any(named: 'imageUid'),
            bytes: any(named: 'bytes'),
            contentType: any(named: 'contentType'),
          ),
        );
        verifyNever(
          () => cases.registerSlides(
            caseUid: any(named: 'caseUid'),
            images: any(named: 'images'),
          ),
        );
      },
    );
  });

  group('rule 4: droppable upload; settled slides cannot be removed', () {
    test('a second upload request while one runs is dropped', () async {
      final gate = Completer<void>();
      when(
        () => cases.reserveSlideUploads(
          caseUid: any(named: 'caseUid'),
          count: any(named: 'count'),
        ),
      ).thenAnswer((_) async {
        await gate.future;
        return {
          'imageUids': ['img-0'],
        };
      });
      final bloc = build();
      addTearDown(() async {
        if (!gate.isCompleted) gate.complete();
        await bloc.close();
      });
      bloc.add(
        SlidesPicked(
          picks: [
            SlidePick(
              bytes: _jpeg(),
              fileName: 'a.jpg',
              contentType: 'image/jpeg',
            ),
          ],
        ),
      );
      await bloc.stream.first;
      bloc
        ..add(const SlidePixelSizeSet(localId: 'local-0', micronsPerPixel: 0.5))
        ..add(const SlideUploadRequested(uid: 'u1', caseUid: 'c1'))
        ..add(const SlideUploadRequested(uid: 'u1', caseUid: 'c1'));
      await untilCalled(
        () => cases.reserveSlideUploads(caseUid: 'c1', count: 1),
      );
      // Still hung on the gate: a second request must not have reserved again.
      verify(
        () => cases.reserveSlideUploads(caseUid: 'c1', count: 1),
      ).called(1);
      gate.complete();
      await pumpEventQueue();
    });

    blocTest<SlideUploadBloc, SlideUploadState>(
      'removing an uploading slide is refused',
      build: build,
      seed: () => SlideUploadEditing(
        caseUid: 'c1',
        slides: [
          SlideItem(
            localId: 'uploading',
            fileName: 'a.jpg',
            bytes: _jpeg(),
            contentType: SlideStorage.jpeg,
            micronsPerPixel: 0.5,
            status: .uploading,
          ),
        ],
      ),
      act: (bloc) => bloc.add(const SlideRemoved(localId: 'uploading')),
      expect: () => [
        isA<SlideUploadFailure>()
            .having((s) => s.error, 'error', AppError.invalidSlides)
            .having((s) => s.slides.length, 'n', 1),
      ],
    );

    blocTest<SlideUploadBloc, SlideUploadState>(
      'removing an uploaded slide is refused',
      build: build,
      seed: () => SlideUploadEditing(
        caseUid: 'c1',
        slides: [
          SlideItem(
            localId: 'uploaded',
            fileName: 'b.jpg',
            bytes: _jpeg(),
            contentType: SlideStorage.jpeg,
            micronsPerPixel: 0.5,
            status: .uploaded,
            reservedImageUid: 'img-x',
          ),
        ],
      ),
      act: (bloc) => bloc.add(const SlideRemoved(localId: 'uploaded')),
      expect: () => [
        isA<SlideUploadFailure>()
            .having((s) => s.error, 'error', AppError.invalidSlides)
            .having((s) => s.slides.length, 'n', 1),
      ],
    );
  });

  group('rule 5: server refusals map to distinct AppErrors', () {
    for (final entry in {
      'slidesNotRequired': AppError.slidesNotRequired,
      'invalidStage': AppError.invalidStage,
      'notOnCase': AppError.notOnCase,
      'tooManySlides': AppError.tooManySlides,
      'slideNotUploaded': AppError.slideNotUploaded,
      'slideNotReserved': AppError.slideNotReserved,
      'invalidSlides': AppError.invalidSlides,
      'invalidCount': AppError.invalidSlides,
    }.entries) {
      blocTest<SlideUploadBloc, SlideUploadState>(
        'maps ${entry.key} without showing the raw server text',
        build: build,
        setUp: () {
          when(
            () => cases.reserveSlideUploads(
              caseUid: any(named: 'caseUid'),
              count: any(named: 'count'),
            ),
          ).thenThrow(
            AppError.fromFunctionsException(
              FirebaseFunctionsException(
                code: 'failed-precondition',
                message: entry.key,
              ),
            ),
          );
        },
        seed: () => SlideUploadEditing(
          caseUid: 'c1',
          caseModel: emptyCase,
          slides: [
            SlideItem(
              localId: 'local-0',
              fileName: 'a.jpg',
              bytes: _jpeg(),
              contentType: SlideStorage.jpeg,
              micronsPerPixel: 0.5,
            ),
          ],
        ),
        act: (bloc) =>
            bloc.add(const SlideUploadRequested(uid: 'u1', caseUid: 'c1')),
        expect: () => [
          isA<SlideUploadInProgress>(),
          isA<SlideUploadFailure>().having(
            (s) => s.error,
            'error',
            entry.value,
          ),
        ],
      );
    }
  });

  group('rule 6: case is re-read after success', () {
    blocTest<SlideUploadBloc, SlideUploadState>(
      'syncCases runs after register so slideImages reflect the server',
      build: build,
      setUp: () {
        when(() => cache.syncCases(any())).thenAnswer(
          (_) async => [
            const CaseModel(
              uid: 'c1',
              requiresSlides: true,
              slideImages: [
                SlideImageModel(imageUid: 'img-0', micronsPerPixel: 0.5),
              ],
            ),
          ],
        );
      },
      seed: () => SlideUploadEditing(
        caseUid: 'c1',
        caseModel: emptyCase,
        slides: [
          SlideItem(
            localId: 'local-0',
            fileName: 'a.jpg',
            bytes: _jpeg(),
            contentType: SlideStorage.jpeg,
            micronsPerPixel: 0.5,
          ),
        ],
      ),
      act: (bloc) =>
          bloc.add(const SlideUploadRequested(uid: 'u1', caseUid: 'c1')),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        verify(() => cache.syncCases('u1')).called(1);
        final success = bloc.state as SlideUploadSuccess;
        expect(success.caseModel?.slideImages.single.imageUid, 'img-0');
      },
    );
  });

  group('rule 7: analytics count only', () {
    blocTest<SlideUploadBloc, SlideUploadState>(
      'one slides_uploaded event per request with the count only',
      build: build,
      seed: () => SlideUploadEditing(
        caseUid: 'c1',
        caseModel: emptyCase,
        slides: [
          SlideItem(
            localId: 'local-0',
            fileName: 'a.jpg',
            bytes: _jpeg(),
            contentType: SlideStorage.jpeg,
            micronsPerPixel: 0.5,
          ),
          SlideItem(
            localId: 'local-1',
            fileName: 'b.png',
            bytes: _png(),
            contentType: SlideStorage.png,
            micronsPerPixel: 1,
          ),
        ],
      ),
      act: (bloc) =>
          bloc.add(const SlideUploadRequested(uid: 'u1', caseUid: 'c1')),
      wait: const Duration(milliseconds: 50),
      verify: (_) {
        verify(() => analytics.logSlidesUploaded(count: 2)).called(1);
      },
    );
  });

  group('rule 8 / reset', () {
    blocTest<SlideUploadBloc, SlideUploadState>(
      'reset clears slides so the next account never sees the last ones',
      build: build,
      seed: () => SlideUploadEditing(
        caseUid: 'c1',
        slides: [
          SlideItem(
            localId: 'local-0',
            fileName: 'a.jpg',
            bytes: _jpeg(),
            contentType: SlideStorage.jpeg,
            micronsPerPixel: 0.5,
          ),
        ],
      ),
      act: (bloc) => bloc.add(const SlideUploadReset()),
      expect: () => [const SlideUploadInitial()],
    );
  });
}
