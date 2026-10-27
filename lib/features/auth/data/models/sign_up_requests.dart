import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';

/// What `completePatientSignUp` takes (CRQ-0016). The server validates every
/// field again; this only shapes the call.
class PatientSignUpRequest extends Equatable {
  const PatientSignUpRequest({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.sex,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.countyId,
    required this.subCountyId,
    required this.language,
  });

  final String firstName;
  final String middleName;
  final String lastName;
  final Sex sex;

  /// `YYYY-MM-DD`.
  final String dateOfBirth;
  final String phoneNumber;
  final int countyId;

  /// Null outside Nairobi, where there is no sub-county list yet (§6.2).
  final int? subCountyId;
  final AppLanguage language;

  Map<String, Object?> toCallableData() => {
    'firstName': firstName,
    'middleName': middleName,
    'lastName': lastName,
    'sex': sex.value,
    'dateOfBirth': dateOfBirth,
    'phoneNumber': phoneNumber,
    'countyId': countyId,
    'subCountyId': ?subCountyId,
    'language': language.value,
  };

  @override
  List<Object?> get props => [
    firstName,
    middleName,
    lastName,
    sex,
    dateOfBirth,
    phoneNumber,
    countyId,
    subCountyId,
    language,
  ];
}

/// What `completePractitionerSignUp` takes. The license (and any picture) is
/// uploaded first, into the caller's own Storage folder (§6.1).
class PractitionerSignUpRequest extends Equatable {
  const PractitionerSignUpRequest({
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.isPathologist,
    required this.specialties,
    required this.bio,
    required this.kmpdcNumber,
    required this.licenseUrls,
    required this.profilePictureUrl,
    required this.facilityId,
    required this.termsAccepted,
    required this.isAvailable,
    required this.language,
  });

  final PractitionerTitle title;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final bool isPathologist;

  /// One to five, from [Specialty.forRole] of the chosen role.
  final List<Specialty> specialties;
  final String bio;
  final String kmpdcNumber;

  /// One or two files, uploaded first to the caller's own licences folder.
  final List<String> licenseUrls;

  /// Required: patients choose a practitioner partly by face.
  final String profilePictureUrl;
  final String facilityId;
  final bool termsAccepted;

  /// The sign-up switch: accepting new patients, or new cases.
  final bool isAvailable;
  final AppLanguage language;

  Map<String, Object?> toCallableData() => {
    'title': title.value,
    'firstName': firstName,
    'lastName': lastName,
    'phoneNumber': phoneNumber,
    'isPathologist': isPathologist,
    'specialties': [for (final s in specialties) s.value],
    'bio': bio,
    'kmpdcNumber': kmpdcNumber,
    'licenseUrls': licenseUrls,
    'profilePictureUrl': profilePictureUrl,
    'facilityId': facilityId,
    'termsAccepted': termsAccepted,
    'isAvailable': isAvailable,
    'language': language.value,
  };

  @override
  List<Object?> get props => [
    title,
    firstName,
    lastName,
    phoneNumber,
    isPathologist,
    specialties,
    bio,
    kmpdcNumber,
    licenseUrls,
    profilePictureUrl,
    facilityId,
    termsAccepted,
    isAvailable,
    language,
  ];
}
