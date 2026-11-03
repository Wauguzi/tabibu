import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/cases/data/datasources/slide_storage.dart';

class _MockStorage extends Mock implements FirebaseStorage {}

class _MockRef extends Mock implements Reference {}

class _MockTaskSnapshot extends Mock implements TaskSnapshot {}

class _FakeUploadTask extends Fake implements UploadTask {
  _FakeUploadTask(this._snap);

  final TaskSnapshot _snap;

  @override
  Future<R> then<R>(
    FutureOr<R> Function(TaskSnapshot value) onValue, {
    Function? onError,
  }) => Future<R>.value(onValue(_snap));
}

void main() {
  late _MockStorage firebase;
  late _MockRef ref;
  late _MockTaskSnapshot snap;
  late SlideStorage storage;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(SettableMetadata(contentType: SlideStorage.jpeg));
  });

  setUp(() {
    firebase = _MockStorage();
    ref = _MockRef();
    snap = _MockTaskSnapshot();
    storage = SlideStorage(storage: firebase);
    when(() => firebase.ref(any())).thenReturn(ref);
    when(
      () => ref.putData(any(), any()),
    ).thenAnswer((_) => _FakeUploadTask(snap));
  });

  test('an unknown content type is refused before upload', () async {
    await expectLater(
      storage.uploadSlide(
        caseUid: 'c1',
        imageUid: 'i1',
        bytes: Uint8List.fromList([1]),
        contentType: 'image/gif',
      ),
      throwsA(AppError.invalidSlides),
    );
    verifyZeroInteractions(firebase);
  });

  test('empty bytes are refused before upload', () async {
    await expectLater(
      storage.uploadSlide(
        caseUid: 'c1',
        imageUid: 'i1',
        bytes: Uint8List(0),
        contentType: SlideStorage.jpeg,
      ),
      throwsA(AppError.invalidSlides),
    );
    verifyZeroInteractions(firebase);
  });

  test('a slide over 20 MB is refused before upload', () async {
    await expectLater(
      storage.uploadSlide(
        caseUid: 'c1',
        imageUid: 'i1',
        bytes: Uint8List(SlideStorage.maxSlideBytes + 1),
        contentType: SlideStorage.png,
      ),
      throwsA(AppError.fileTooLarge),
    );
    verifyZeroInteractions(firebase);
  });

  test('jpeg goes to slides/{case}/{uid}.jpg with image/jpeg', () async {
    final bytes = Uint8List.fromList([1, 2, 3]);
    await storage.uploadSlide(
      caseUid: 'c1',
      imageUid: 'img-a',
      bytes: bytes,
      contentType: SlideStorage.jpeg,
    );
    verify(() => firebase.ref('slides/c1/img-a.jpg')).called(1);
    final captured = verify(() => ref.putData(bytes, captureAny())).captured;
    expect(
      (captured.single as SettableMetadata).contentType,
      SlideStorage.jpeg,
    );
  });

  test('png goes to slides/{case}/{uid}.png with image/png', () async {
    final bytes = Uint8List.fromList([1, 2, 3]);
    await storage.uploadSlide(
      caseUid: 'c1',
      imageUid: 'img-b',
      bytes: bytes,
      contentType: SlideStorage.png,
    );
    verify(() => firebase.ref('slides/c1/img-b.png')).called(1);
    final captured = verify(() => ref.putData(bytes, captureAny())).captured;
    expect((captured.single as SettableMetadata).contentType, SlideStorage.png);
  });
}
