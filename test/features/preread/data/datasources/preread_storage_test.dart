import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/features/preread/data/datasources/preread_storage.dart';

class _MockStorage extends Mock implements FirebaseStorage {}

class _MockRef extends Mock implements Reference {}

void main() {
  late _MockStorage firebase;
  late _MockRef ref;
  late PrereadStorage storage;

  setUp(() {
    firebase = _MockStorage();
    ref = _MockRef();
    storage = PrereadStorage(storage: firebase);
    when(() => firebase.ref(any())).thenReturn(ref);
  });

  test('returns the download URL for a path', () async {
    when(() => ref.getDownloadURL()).thenAnswer((_) async => 'https://x/a');
    expect(await storage.downloadUrl('cases/c1/slide.tiff'), 'https://x/a');
    verify(() => firebase.ref('cases/c1/slide.tiff')).called(1);
  });

  test('returns null when Storage fails', () async {
    when(
      () => ref.getDownloadURL(),
    ).thenThrow(FirebaseException(plugin: 'storage', code: 'object-not-found'));
    expect(await storage.downloadUrl('missing'), isNull);
  });
}
