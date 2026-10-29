import 'package:cloud_functions/cloud_functions.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The `role` custom claim. Unknown values resolve to null and therefore to
/// no permissions; RoleHelper never throws on them.
enum Role {
  patient,
  doctor,
  pathologist;

  static Role? fromClaim(String claim) => switch (claim) {
    'patient' => .patient,
    'doctor' => .doctor,
    'pathologist' => .pathologist,
    _ => null,
  };
}

/// Clinical sex, stored as Firestore does. Reference ranges depend on it, so
/// an unknown value is null ("not recorded"), never either variant. It does
/// not throw: a getter that throws in `build()` takes the screen down.
enum Sex {
  male,
  female;

  String get value => switch (this) {
    .male => 'Male',
    .female => 'Female',
  };

  static Sex? fromValue(String value) => switch (value) {
    'Male' => .male,
    'Female' => .female,
    _ => null,
  };

  String description(AppLocalizations l10n) => switch (this) {
    .male => l10n.sexMale,
    .female => l10n.sexFemale,
  };
}

/// A practitioner's verification state, stored as Firestore does. An unknown
/// value reads as [pending], the state with the least access.
enum VerificationStatus {
  pending,
  verified,
  rejected;

  String get value => switch (this) {
    .pending => 'Pending',
    .verified => 'Verified',
    .rejected => 'Rejected',
  };

  static VerificationStatus fromValue(String value) => switch (value) {
    'Pending' => .pending,
    'Verified' => .verified,
    'Rejected' => .rejected,
    _ => .pending,
  };

  String description(AppLocalizations l10n) => switch (this) {
    .pending => l10n.verificationStatusPending,
    .verified => l10n.verificationStatusVerified,
    .rejected => l10n.verificationStatusRejected,
  };
}

/// The app's locales, stored as the language code. An unknown value reads as
/// [en].
enum AppLanguage {
  en,
  sw;

  String get value => switch (this) {
    .en => 'en',
    .sw => 'sw',
  };

  static AppLanguage fromValue(String value) => switch (value) {
    'en' => .en,
    'sw' => .sw,
    _ => .en,
  };

  String description(AppLocalizations l10n) => switch (this) {
    .en => l10n.languageEn,
    .sw => l10n.languageSw,
  };
}

/// Light, dark, or the device's setting, kept on the device across
/// sign-outs. An unknown value reads as [system].
enum ThemePreference {
  light,
  dark,
  system;

  String get value => name;

  static ThemePreference fromValue(String? value) => switch (value) {
    'light' => .light,
    'dark' => .dark,
    _ => .system,
  };

  String description(AppLocalizations l10n) => switch (this) {
    .light => l10n.themeLight,
    .dark => l10n.themeDark,
    .system => l10n.themeSystem,
  };
}

/// A practitioner's title, stored as its display value.
enum PractitionerTitle {
  dr,
  prof,
  mr,
  mrs,
  ms;

  String get value => switch (this) {
    .dr => 'Dr.',
    .prof => 'Prof.',
    .mr => 'Mr.',
    .mrs => 'Mrs.',
    .ms => 'Ms.',
  };
}

/// A practitioner's specialties (CRQ-0026). A pathologist's are the areas
/// they report on, which decide the cases on their desk; a doctor's are what
/// patients search for. Stored as [value], which the callable and the rules
/// check against the same two lists.
enum Specialty {
  histopathology('Histopathology', isPathology: true),
  cytology('Cytology', isPathology: true),
  haematology('Haematology', isPathology: true),
  microbiology('Microbiology', isPathology: true),
  immunohistochemistry('Immunohistochemistry', isPathology: true),
  generalPractice('General practice'),
  familyMedicine('Family medicine'),
  internalMedicine('Internal medicine'),
  generalSurgery('General surgery'),
  breastSurgery('Breast surgery'),
  obstetricsAndGynaecology('Obstetrics and gynaecology'),
  paediatrics('Paediatrics'),
  oncology('Oncology'),
  dermatology('Dermatology'),
  earNoseAndThroat('Ear, nose and throat'),
  urology('Urology'),
  gastroenterology('Gastroenterology'),
  infectiousDiseases('Infectious diseases'),
  cardiology('Cardiology'),
  orthopaedics('Orthopaedics');

  const Specialty(this.value, {this.isPathology = false});

  final String value;
  final bool isPathology;

  static const maxSelected = 5;

  /// The specialties a role may choose from.
  static List<Specialty> forRole({required bool isPathologist}) => [
    for (final s in values)
      if (s.isPathology == isPathologist) s,
  ];

  /// Null for a value this app version does not know.
  static Specialty? fromValue(String value) {
    for (final s in values) {
      if (s.value == value) return s;
    }
    return null;
  }

  String description(AppLocalizations l10n) => switch (this) {
    histopathology => l10n.specialtyHistopathology,
    cytology => l10n.specialtyCytology,
    haematology => l10n.specialtyHaematology,
    microbiology => l10n.specialtyMicrobiology,
    immunohistochemistry => l10n.specialtyImmunohistochemistry,
    generalPractice => l10n.specialtyGeneralPractice,
    familyMedicine => l10n.specialtyFamilyMedicine,
    internalMedicine => l10n.specialtyInternalMedicine,
    generalSurgery => l10n.specialtyGeneralSurgery,
    breastSurgery => l10n.specialtyBreastSurgery,
    obstetricsAndGynaecology => l10n.specialtyObstetricsAndGynaecology,
    paediatrics => l10n.specialtyPaediatrics,
    oncology => l10n.specialtyOncology,
    dermatology => l10n.specialtyDermatology,
    earNoseAndThroat => l10n.specialtyEarNoseAndThroat,
    urology => l10n.specialtyUrology,
    gastroenterology => l10n.specialtyGastroenterology,
    infectiousDiseases => l10n.specialtyInfectiousDiseases,
    cardiology => l10n.specialtyCardiology,
    orthopaedics => l10n.specialtyOrthopaedics,
  };

  /// What each pathology area covers, as the area picker shows it (F2b).
  String? hint(AppLocalizations l10n) => switch (this) {
    histopathology => l10n.specialtyHistopathologyHint,
    cytology => l10n.specialtyCytologyHint,
    haematology => l10n.specialtyHaematologyHint,
    microbiology => l10n.specialtyMicrobiologyHint,
    immunohistochemistry => l10n.specialtyImmunohistochemistryHint,
    _ => null,
  };
}

/// Every translatable reason a Bloc operation can fail — both app-level
/// guard conditions and Firebase-derived error codes (via [fromFirebaseCode]
/// and [fromFunctionsException]). Implements [Exception] so helpers can throw
/// an [AppError] directly and have it survive intact up to the Bloc's catch
/// block instead of collapsing into a pre-rendered English-only string.
enum AppError implements Exception {
  noInternet,
  // Firebase-derived (see fromFirebaseCode)
  invalidEmail,
  userDisabled,
  userNotFound,
  wrongPassword,
  emailAlreadyInUse,
  weakPassword,
  operationNotAllowed,
  tooManyRequests,
  invalidCredential,
  accountExistsWithDifferentCredential,
  requiresRecentLogin,
  credentialAlreadyInUse,
  expiredActionCode,
  invalidActionCode,
  userTokenExpired,
  permissionDenied,
  dataNotFound,
  serviceUnavailable,
  requestTimeout,
  // Not derived from a Firebase code — thrown directly by the auth flow when
  // a Google sign-in succeeds against an account with no matching profile.
  userNotRegistered,
  // Refusals from the identity callables, read from the callable's `message`
  // (see fromFunctionsException). invalidEmail above serves both Firebase
  // and the functions' invalidEmail key.
  unauthenticated,
  emailRequired,
  emailNotVerified,
  invalidName,
  invalidSex,
  invalidDateOfBirth,
  invalidPhone,
  invalidCounty,
  invalidSubCounty,
  invalidLanguage,
  roleAlreadySet,
  patientAlreadyRegistered,
  patientExists,
  doctorsOnly,
  invalidPatient,
  accountNotFound,
  accountAlreadyHasRole,
  alreadyLinked,
  invalidRole,
  termsRequired,
  invalidKmpdcNumber,
  invalidFacility,
  facilityNotOperational,
  invalidTitle,
  invalidPicture,
  invalidSpecialties,
  invalidAvailability,
  invalidBio,
  invalidLicense,
  kmpdcNumberInUse,
  // Checked on the device before an upload, against the Storage rules' limits.
  fileTooLarge,
  adminOnly,
  invalidPractitioner,
  invalidDecision,
  // Thrown directly by the auth flow, not from a Firebase code.
  practitionerPendingVerification,
  noRoleAssigned,
  unknown;

  /// Maps a callable's `message` reason key to its [AppError], falling back
  /// to [fromFirebaseCode] when the message names no known key.
  static AppError fromFunctionsException(FirebaseFunctionsException e) {
    final reason = switch (e.message) {
      'unauthenticated' => AppError.unauthenticated,
      'emailRequired' => AppError.emailRequired,
      'emailNotVerified' => AppError.emailNotVerified,
      'invalidName' => AppError.invalidName,
      'invalidSex' => AppError.invalidSex,
      'invalidDateOfBirth' => AppError.invalidDateOfBirth,
      'invalidPhone' => AppError.invalidPhone,
      'invalidEmail' => AppError.invalidEmail,
      'invalidCounty' => AppError.invalidCounty,
      'invalidSubCounty' => AppError.invalidSubCounty,
      'invalidLanguage' => AppError.invalidLanguage,
      'roleAlreadySet' => AppError.roleAlreadySet,
      'patientAlreadyRegistered' => AppError.patientAlreadyRegistered,
      'patientExists' => AppError.patientExists,
      'doctorsOnly' => AppError.doctorsOnly,
      'invalidPatient' => AppError.invalidPatient,
      'accountNotFound' => AppError.accountNotFound,
      'accountAlreadyHasRole' => AppError.accountAlreadyHasRole,
      'alreadyLinked' => AppError.alreadyLinked,
      'invalidRole' => AppError.invalidRole,
      'termsRequired' => AppError.termsRequired,
      'invalidKmpdcNumber' => AppError.invalidKmpdcNumber,
      'invalidFacility' => AppError.invalidFacility,
      'facilityNotOperational' => AppError.facilityNotOperational,
      'invalidTitle' => AppError.invalidTitle,
      'invalidPicture' => AppError.invalidPicture,
      'invalidSpecialties' => AppError.invalidSpecialties,
      'invalidAvailability' => AppError.invalidAvailability,
      'invalidBio' => AppError.invalidBio,
      'invalidLicense' => AppError.invalidLicense,
      'kmpdcNumberInUse' => AppError.kmpdcNumberInUse,
      'adminOnly' => AppError.adminOnly,
      'invalidPractitioner' => AppError.invalidPractitioner,
      'invalidDecision' => AppError.invalidDecision,
      _ => null,
    };
    return reason ?? fromFirebaseCode(e.code);
  }

  /// Maps a Firebase (`FirebaseAuthException`/`FirebaseException`) error
  /// `code` to the matching [AppError] case. Falls back to [unknown] for
  /// any code not explicitly handled.
  static AppError fromFirebaseCode(String code) => switch (code) {
    'invalid-email' => .invalidEmail,
    'user-disabled' => .userDisabled,
    'user-not-found' => .userNotFound,
    'wrong-password' => .wrongPassword,
    'email-already-in-use' => .emailAlreadyInUse,
    'weak-password' => .weakPassword,
    'operation-not-allowed' => .operationNotAllowed,
    'too-many-requests' || 'resource-exhausted' => .tooManyRequests,
    'network-request-failed' => .noInternet,
    'invalid-credential' => .invalidCredential,
    'account-exists-with-different-credential' =>
      .accountExistsWithDifferentCredential,
    'requires-recent-login' => .requiresRecentLogin,
    'credential-already-in-use' => .credentialAlreadyInUse,
    'expired-action-code' => .expiredActionCode,
    'invalid-action-code' => .invalidActionCode,
    'user-token-expired' => .userTokenExpired,
    'permission-denied' || 'unauthorized' => .permissionDenied,
    'not-found' => .dataNotFound,
    'unavailable' => .serviceUnavailable,
    'deadline-exceeded' => .requestTimeout,
    _ => .unknown,
  };

  String description(AppLocalizations l10n) => switch (this) {
    .noInternet => l10n.errorNoInternet,
    .invalidEmail => l10n.errorInvalidEmail,
    .userDisabled => l10n.errorUserDisabled,
    .userNotFound => l10n.errorUserNotFound,
    .wrongPassword => l10n.errorWrongPassword,
    .emailAlreadyInUse => l10n.errorEmailAlreadyInUse,
    .weakPassword => l10n.errorWeakPassword,
    .operationNotAllowed => l10n.errorOperationNotAllowed,
    .tooManyRequests => l10n.errorTooManyRequests,
    .invalidCredential => l10n.errorInvalidCredential,
    .accountExistsWithDifferentCredential =>
      l10n.errorAccountExistsWithDifferentCredential,
    .requiresRecentLogin => l10n.errorRequiresRecentLogin,
    .credentialAlreadyInUse => l10n.errorCredentialAlreadyInUse,
    .expiredActionCode => l10n.errorExpiredActionCode,
    .invalidActionCode => l10n.errorInvalidActionCode,
    .userTokenExpired => l10n.errorUserTokenExpired,
    .permissionDenied => l10n.errorPermissionDenied,
    .dataNotFound => l10n.errorDataNotFound,
    .serviceUnavailable => l10n.errorServiceUnavailable,
    .requestTimeout => l10n.errorRequestTimeout,
    .userNotRegistered => l10n.errorUserNotRegistered,
    .unauthenticated => l10n.errorUnauthenticated,
    .emailRequired => l10n.errorEmailRequired,
    .emailNotVerified => l10n.errorEmailNotVerified,
    .invalidName => l10n.errorInvalidName,
    .invalidSex => l10n.errorInvalidSex,
    .invalidDateOfBirth => l10n.errorInvalidDateOfBirth,
    .invalidPhone => l10n.errorInvalidPhone,
    .invalidCounty => l10n.errorInvalidCounty,
    .invalidSubCounty => l10n.errorInvalidSubCounty,
    .invalidLanguage => l10n.errorInvalidLanguage,
    .roleAlreadySet => l10n.errorRoleAlreadySet,
    .patientAlreadyRegistered => l10n.errorPatientAlreadyRegistered,
    .patientExists => l10n.errorPatientExists,
    .doctorsOnly => l10n.errorDoctorsOnly,
    .invalidPatient => l10n.errorInvalidPatient,
    .accountNotFound => l10n.errorAccountNotFound,
    .accountAlreadyHasRole => l10n.errorAccountAlreadyHasRole,
    .alreadyLinked => l10n.errorAlreadyLinked,
    .invalidRole => l10n.errorInvalidRole,
    .termsRequired => l10n.errorTermsRequired,
    .invalidKmpdcNumber => l10n.errorInvalidKmpdcNumber,
    .invalidFacility => l10n.errorInvalidFacility,
    .facilityNotOperational => l10n.errorFacilityNotOperational,
    .invalidTitle => l10n.errorInvalidTitle,
    .invalidPicture => l10n.errorInvalidPicture,
    .invalidSpecialties => l10n.errorInvalidSpecialties,
    .invalidAvailability => l10n.errorInvalidAvailability,
    .invalidBio => l10n.errorInvalidBio,
    .invalidLicense => l10n.errorInvalidLicense,
    .kmpdcNumberInUse => l10n.errorKmpdcNumberInUse,
    .fileTooLarge => l10n.errorFileTooLarge,
    .adminOnly => l10n.errorAdminOnly,
    .invalidPractitioner => l10n.errorInvalidPractitioner,
    .invalidDecision => l10n.errorInvalidDecision,
    .practitionerPendingVerification =>
      l10n.errorPractitionerPendingVerification,
    .noRoleAssigned => l10n.errorNoRoleAssigned,
    .unknown => l10n.errorUnknown,
  };
}
