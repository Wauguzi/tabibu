import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/services/file_picker_service.dart';
import 'package:tabibu/features/auth/data/datasources/profile_storage.dart';

class _MockImagePicker extends Mock implements ImagePicker {}

void main() {
  late _MockImagePicker images;
  late FilePickerService service;

  setUpAll(() => registerFallbackValue(ImageSource.gallery));

  setUp(() {
    images = _MockImagePicker();
    service = FilePickerService(imagePicker: images);
  });

  void picks(XFile? file) => when(
    () => images.pickImage(
      source: any(named: 'source'),
      maxWidth: any(named: 'maxWidth'),
      maxHeight: any(named: 'maxHeight'),
      imageQuality: any(named: 'imageQuality'),
      requestFullMetadata: any(named: 'requestFullMetadata'),
    ),
  ).thenAnswer((_) async => file);

  group('pickPhoto', () {
    test('is resized on the device and read as bytes', () async {
      picks(XFile.fromData(Uint8List(10), name: 'me.jpg', path: '/tmp/me.jpg'));
      final photo = await service.pickPhoto(fromCamera: true);

      expect(photo!.bytes.length, 10);
      expect(photo.contentType, 'image/jpeg');
      expect(photo.name, 'me.jpg');
      verify(
        () => images.pickImage(
          source: ImageSource.camera,
          maxWidth: FilePickerService.photoMaxSide,
          maxHeight: FilePickerService.photoMaxSide,
          imageQuality: FilePickerService.photoQuality,
          requestFullMetadata: false,
        ),
      ).called(1);
    });

    test('a cancelled pick is null, not an error', () async {
      picks(null);
      expect(await service.pickPhoto(fromCamera: false), isNull);
    });

    test('refused camera or photo access is a permission error', () async {
      when(
        () => images.pickImage(
          source: any(named: 'source'),
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
          requestFullMetadata: any(named: 'requestFullMetadata'),
        ),
      ).thenThrow(PlatformException(code: 'camera_access_denied'));
      await expectLater(
        service.pickPhoto(fromCamera: true),
        throwsA(AppError.permissionDenied),
      );
    });

    test('a photo still over the 3 MB limit is refused', () async {
      picks(
        XFile.fromData(
          Uint8List(ProfileStorage.maxPictureBytes),
          name: 'huge.jpg',
        ),
      );
      await expectLater(
        service.pickPhoto(fromCamera: false),
        throwsA(AppError.fileTooLarge),
      );
    });
  });

  group('licenceFrom', () {
    var reads = 0;
    Future<Uint8List> read() async {
      reads++;
      return Uint8List(3);
    }

    setUp(() => reads = 0);

    test('accepts a PDF or an image, read once', () async {
      for (final (name, type) in [
        ('licence.pdf', 'application/pdf'),
        ('scan.PNG', 'image/png'),
        ('scan.jpeg', 'image/jpeg'),
      ]) {
        final file = await FilePickerService.licenceFrom(
          name: name,
          size: 3,
          readBytes: read,
        );
        expect(file.contentType, type);
        expect(file.name, name);
      }
      expect(reads, 3);
    });

    test('a file at the 10 MB limit is refused before it is read', () async {
      await expectLater(
        FilePickerService.licenceFrom(
          name: 'big.pdf',
          size: ProfileStorage.maxLicenseBytes,
          readBytes: read,
        ),
        throwsA(AppError.fileTooLarge),
      );
      expect(reads, 0);
    });

    test('any other type is refused', () async {
      await expectLater(
        FilePickerService.licenceFrom(
          name: 'notes.docx',
          size: 3,
          readBytes: read,
        ),
        throwsA(AppError.invalidLicense),
      );
    });
  });

  test('sizes read as the document tile shows them', () {
    expect(formatFileSize(900), '900 B');
    expect(formatFileSize(2202010), '2.1 MB');
    expect(formatFileSize(1536), '1.5 KB');
  });
}
