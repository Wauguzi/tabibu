import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/auth/data/models/sign_up_requests.dart';
import 'package:tabibu/features/auth/data/models/upload_file.dart';

part 'sign_up_draft.freezed.dart';

/// What the sign-up screens have collected so far (C1 to F4). Held in
/// memory only; the password never enters it, because the account is created
/// on the screen that asks for it.
///
/// The `to…Request` methods throw the [AppError] the server would, so a
/// screen can show the same message before the round trip.
@freezed
abstract class SignUpDraft with _$SignUpDraft {
  const factory SignUpDraft({
    Role? role,
    @Default('') String email,
    @Default('') String firstName,
    @Default('') String middleName,
    @Default('') String lastName,
    Sex? sex,

    /// `YYYY-MM-DD`.
    @Default('') String dateOfBirth,
    @Default('') String phoneNumber,
    int? countyId,
    int? subCountyId,
    @Default(AppLanguage.en) AppLanguage language,
    PractitionerTitle? title,
    @Default(<Specialty>[]) List<Specialty> specialties,
    @Default('') String bio,
    @Default('') String kmpdcNumber,
    @Default(<UploadFile>[]) List<UploadFile> licenses,
    UploadFile? picture,
    @Default('') String facilityId,
    @Default(true) bool isAvailable,
    @Default(false) bool termsAccepted,
  }) = _SignUpDraft;

  const SignUpDraft._();

  bool get isPractitioner => role == Role.doctor || role == Role.pathologist;

  PatientSignUpRequest toPatientRequest() {
    if (role != Role.patient) throw AppError.invalidRole;
    _requireNames();
    final sex = this.sex;
    if (sex == null) throw AppError.invalidSex;
    if (dateOfBirth.isEmpty) throw AppError.invalidDateOfBirth;
    _requirePhone();
    final countyId = this.countyId;
    if (countyId == null) throw AppError.invalidCounty;
    return PatientSignUpRequest(
      firstName: firstName.trim(),
      middleName: middleName.trim(),
      lastName: lastName.trim(),
      sex: sex,
      dateOfBirth: dateOfBirth,
      phoneNumber: phoneNumber.trim(),
      countyId: countyId,
      subCountyId: subCountyId,
      language: language,
    );
  }

  /// Checks everything but the uploads, which happen between this check and
  /// [toPractitionerRequest].
  void checkPractitioner() {
    if (!isPractitioner) throw AppError.invalidRole;
    if (title == null) throw AppError.invalidTitle;
    _requireNames();
    _requirePhone();
    final allowed = Specialty.forRole(isPathologist: role == Role.pathologist);
    if (specialties.isEmpty ||
        specialties.length > Specialty.maxSelected ||
        !specialties.every(allowed.contains)) {
      throw AppError.invalidSpecialties;
    }
    if (kmpdcNumber.trim().isEmpty) throw AppError.invalidKmpdcNumber;
    if (licenses.isEmpty || licenses.length > 2) throw AppError.invalidLicense;
    if (picture == null) throw AppError.invalidPicture;
    if (facilityId.isEmpty) throw AppError.invalidFacility;
    if (!termsAccepted) throw AppError.termsRequired;
  }

  PractitionerSignUpRequest toPractitionerRequest({
    required String pictureUrl,
    required List<String> licenseUrls,
  }) {
    checkPractitioner();
    return PractitionerSignUpRequest(
      title: title!,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      phoneNumber: phoneNumber.trim(),
      isPathologist: role == Role.pathologist,
      specialties: specialties,
      bio: bio.trim(),
      kmpdcNumber: kmpdcNumber.trim().toUpperCase(),
      licenseUrls: licenseUrls,
      profilePictureUrl: pictureUrl,
      facilityId: facilityId,
      termsAccepted: termsAccepted,
      isAvailable: isAvailable,
      language: language,
    );
  }

  void _requireNames() {
    if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
      throw AppError.invalidName;
    }
  }

  void _requirePhone() {
    if (phoneNumber.trim().isEmpty) throw AppError.invalidPhone;
  }
}
