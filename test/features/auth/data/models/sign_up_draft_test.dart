import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/auth/data/models/sign_up_draft.dart';
import 'package:tabibu/features/auth/data/models/upload_file.dart';

final _scan = UploadFile(bytes: Uint8List(1), contentType: 'application/pdf');
final _photo = UploadFile(bytes: Uint8List(1), contentType: 'image/jpeg');

const _patient = SignUpDraft(
  role: Role.patient,
  firstName: ' Amina ',
  lastName: 'Otieno',
  sex: Sex.female,
  dateOfBirth: '1990-05-14',
  phoneNumber: '0712345678',
  countyId: 47,
  subCountyId: 30,
  language: AppLanguage.sw,
);

final _pathologist = SignUpDraft(
  role: Role.pathologist,
  title: PractitionerTitle.dr,
  firstName: 'Wanjiru',
  lastName: 'Kamau',
  phoneNumber: '0712345678',
  specialties: const [Specialty.cytology, Specialty.histopathology],
  kmpdcNumber: ' a1234 ',
  licenses: [_scan],
  picture: _photo,
  facilityId: 'f1',
  termsAccepted: true,
);

void main() {
  group('patient', () {
    test('a complete draft becomes the request, trimmed', () {
      final request = _patient.toPatientRequest();
      expect(request.firstName, 'Amina');
      expect(request.sex, Sex.female);
      expect(request.subCountyId, 30);
      expect(request.language, AppLanguage.sw);
    });

    test('each missing field is refused with the server reason', () {
      final cases = {
        _patient.copyWith(role: Role.doctor): AppError.invalidRole,
        _patient.copyWith(lastName: ' '): AppError.invalidName,
        _patient.copyWith(sex: null): AppError.invalidSex,
        _patient.copyWith(dateOfBirth: ''): AppError.invalidDateOfBirth,
        _patient.copyWith(phoneNumber: ''): AppError.invalidPhone,
        _patient.copyWith(countyId: null): AppError.invalidCounty,
      };
      for (final MapEntry(key: draft, value: error) in cases.entries) {
        expect(draft.toPatientRequest, throwsA(error));
      }
    });
  });

  group('practitioner', () {
    test('a complete draft becomes the request with the uploaded URLs', () {
      final request = _pathologist.toPractitionerRequest(
        pictureUrl: 'photo',
        licenseUrls: ['scan'],
      );
      expect(request.isPathologist, isTrue);
      expect(request.kmpdcNumber, 'A1234');
      expect(request.licenseUrls, ['scan']);
      expect(request.profilePictureUrl, 'photo');
      expect(request.isAvailable, isTrue);
    });

    test('specialties come from the role list, one to five', () {
      expect(
        _pathologist
            .copyWith(specialties: [Specialty.oncology])
            .checkPractitioner,
        throwsA(AppError.invalidSpecialties),
      );
      expect(
        _pathologist.copyWith(specialties: []).checkPractitioner,
        throwsA(AppError.invalidSpecialties),
      );
      expect(
        _pathologist
            .copyWith(
              role: Role.doctor,
              specialties: Specialty.forRole(
                isPathologist: false,
              ).take(6).toList(),
            )
            .checkPractitioner,
        throwsA(AppError.invalidSpecialties),
      );
    });

    test('each missing requirement is refused before any upload', () {
      final cases = {
        _pathologist.copyWith(role: Role.patient): AppError.invalidRole,
        _pathologist.copyWith(title: null): AppError.invalidTitle,
        _pathologist.copyWith(kmpdcNumber: ''): AppError.invalidKmpdcNumber,
        _pathologist.copyWith(licenses: []): AppError.invalidLicense,
        _pathologist.copyWith(licenses: [_scan, _scan, _scan]):
            AppError.invalidLicense,
        _pathologist.copyWith(picture: null): AppError.invalidPicture,
        _pathologist.copyWith(facilityId: ''): AppError.invalidFacility,
        _pathologist.copyWith(termsAccepted: false): AppError.termsRequired,
      };
      for (final MapEntry(key: draft, value: error) in cases.entries) {
        expect(draft.checkPractitioner, throwsA(error));
      }
    });
  });
}
