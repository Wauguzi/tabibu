import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/auth/data/datasources/profile_storage.dart';
import 'package:tabibu/features/auth/data/models/upload_file.dart';

class _MockStorage extends Mock implements FirebaseStorage {}

UploadFile _file(int bytes, String type) =>
    UploadFile(bytes: Uint8List(bytes), contentType: type);

void main() {
  late _MockStorage firebase;
  late ProfileStorage storage;

  setUp(() {
    firebase = _MockStorage();
    storage = ProfileStorage(storage: firebase);
  });

  test('a photo at the 3 MB rule limit is refused before upload', () {
    expect(
      () => storage.uploadProfilePicture(
        owner: 'u1',
        file: _file(ProfileStorage.maxPictureBytes, 'image/jpeg'),
      ),
      throwsA(AppError.fileTooLarge),
    );
    verifyZeroInteractions(firebase);
  });

  test('a photo must be an image', () {
    expect(
      () => storage.uploadProfilePicture(
        owner: 'u1',
        file: _file(1, 'application/pdf'),
      ),
      throwsA(AppError.invalidPicture),
    );
  });

  test('a license at the 10 MB rule limit is refused before upload', () {
    expect(
      () => storage.uploadLicense(
        uid: 'u1',
        index: 0,
        file: _file(ProfileStorage.maxLicenseBytes, 'application/pdf'),
      ),
      throwsA(AppError.fileTooLarge),
    );
    verifyZeroInteractions(firebase);
  });

  test('a license is an image or a PDF, first or second', () {
    expect(
      () => storage.uploadLicense(
        uid: 'u1',
        index: 0,
        file: _file(1, 'text/plain'),
      ),
      throwsA(AppError.invalidLicense),
    );
    expect(
      () => storage.uploadLicense(
        uid: 'u1',
        index: 2,
        file: _file(1, 'image/png'),
      ),
      throwsA(AppError.invalidLicense),
    );
  });
}
