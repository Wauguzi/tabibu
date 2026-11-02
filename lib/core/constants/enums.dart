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

  /// Nothing saved starts in light, not the device's setting.
  static ThemePreference fromValue(String? value) => switch (value) {
    'dark' => .dark,
    'system' => .system,
    _ => .light,
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

// Case lifecycle wire values.
/// Where a case currently sits. Unknown reads as [doctor].
enum CaseLocation {
  doctor,
  pathologist,
  lab,
  patient;

  String get value => switch (this) {
    .doctor => 'Doctor',
    .pathologist => 'Pathologist',
    .lab => 'Lab',
    .patient => 'Patient',
  };

  static CaseLocation fromValue(String value) => switch (value) {
    'Doctor' => .doctor,
    'Pathologist' => .pathologist,
    'Lab' => .lab,
    'Patient' => .patient,
    _ => .doctor,
  };
}

/// How far a case has progressed. Unknown reads as [orderCreated].
enum CaseStage {
  orderCreated,
  pathologistRequested,
  pathologistRejected,
  pathologistAccepted,
  sampleReceived,
  slidesUploaded,
  prereadQueued,
  prereadReady,
  prereadFailed,
  reportInProgress,
  reportSigned,
  discussionRequested,
  discussionBooked,
  resultReleased,
  completed,
  cancelled;

  String get value => switch (this) {
    .orderCreated => 'OrderCreated',
    .pathologistRequested => 'PathologistRequested',
    .pathologistRejected => 'PathologistRejected',
    .pathologistAccepted => 'PathologistAccepted',
    .sampleReceived => 'SampleReceived',
    .slidesUploaded => 'SlidesUploaded',
    .prereadQueued => 'PrereadQueued',
    .prereadReady => 'PrereadReady',
    .prereadFailed => 'PrereadFailed',
    .reportInProgress => 'ReportInProgress',
    .reportSigned => 'ReportSigned',
    .discussionRequested => 'DiscussionRequested',
    .discussionBooked => 'DiscussionBooked',
    .resultReleased => 'ResultReleased',
    .completed => 'Completed',
    .cancelled => 'Cancelled',
  };

  static CaseStage fromValue(String value) => switch (value) {
    'OrderCreated' => .orderCreated,
    'PathologistRequested' => .pathologistRequested,
    'PathologistRejected' => .pathologistRejected,
    'PathologistAccepted' => .pathologistAccepted,
    'SampleReceived' => .sampleReceived,
    'SlidesUploaded' => .slidesUploaded,
    'PrereadQueued' => .prereadQueued,
    'PrereadReady' => .prereadReady,
    'PrereadFailed' => .prereadFailed,
    'ReportInProgress' => .reportInProgress,
    'ReportSigned' => .reportSigned,
    'DiscussionRequested' => .discussionRequested,
    'DiscussionBooked' => .discussionBooked,
    'ResultReleased' => .resultReleased,
    'Completed' => .completed,
    'Cancelled' => .cancelled,
    _ => .orderCreated,
  };
}

/// The current step within a case. Unknown reads as [none].
enum CaseStep {
  none,
  requestPathologist,
  awaitPathologist,
  receiveSample,
  uploadSlides,
  reviewPreread,
  writeReport,
  readReport,
  bookDiscussion,
  replyToDiscussion,
  markDiscussed,
  complete;

  String get value => switch (this) {
    .none => '',
    .requestPathologist => 'RequestPathologist',
    .awaitPathologist => 'AwaitPathologist',
    .receiveSample => 'ReceiveSample',
    .uploadSlides => 'UploadSlides',
    .reviewPreread => 'ReviewPreread',
    .writeReport => 'WriteReport',
    .readReport => 'ReadReport',
    .bookDiscussion => 'BookDiscussion',
    .replyToDiscussion => 'ReplyToDiscussion',
    .markDiscussed => 'MarkDiscussed',
    .complete => 'Complete',
  };

  static CaseStep fromValue(String value) => switch (value) {
    '' => .none,
    'RequestPathologist' => .requestPathologist,
    'AwaitPathologist' => .awaitPathologist,
    'ReceiveSample' => .receiveSample,
    'UploadSlides' => .uploadSlides,
    'ReviewPreread' => .reviewPreread,
    'WriteReport' => .writeReport,
    'ReadReport' => .readReport,
    'BookDiscussion' => .bookDiscussion,
    'ReplyToDiscussion' => .replyToDiscussion,
    'MarkDiscussed' => .markDiscussed,
    'Complete' => .complete,
    _ => .none,
  };
}

/// Who performed a case action. Unknown reads as [system].
enum ActorRole {
  doctor,
  pathologist,
  patient,
  system;

  String get value => switch (this) {
    .doctor => 'Doctor',
    .pathologist => 'Pathologist',
    .patient => 'Patient',
    .system => 'System',
  };

  static ActorRole fromValue(String value) => switch (value) {
    'Doctor' => .doctor,
    'Pathologist' => .pathologist,
    'Patient' => .patient,
    'System' => .system,
    _ => .system,
  };
}

/// An action taken on a case. Unknown reads as [none].
enum CaseAction {
  none,
  reject,
  expire,
  reassign,
  cancel,
  share,
  removeViewer,
  revise,
  receive,
  addSlides;

  String get value => switch (this) {
    .none => '',
    .reject => 'Reject',
    .expire => 'Expire',
    .reassign => 'Reassign',
    .cancel => 'Cancel',
    .share => 'Share',
    .removeViewer => 'RemoveViewer',
    .revise => 'Revise',
    .receive => 'Receive',
    .addSlides => 'AddSlides',
  };

  static CaseAction fromValue(String value) => switch (value) {
    '' => .none,
    'Reject' => .reject,
    'Expire' => .expire,
    'Reassign' => .reassign,
    'Cancel' => .cancel,
    'Share' => .share,
    'RemoveViewer' => .removeViewer,
    'Revise' => .revise,
    'Receive' => .receive,
    'AddSlides' => .addSlides,
    _ => .none,
  };
}

/// Where a result sits. Unknown reads as [pending].
enum ResultState {
  pending,
  withDoctor,
  released,
  updateWithDoctor;

  String get value => switch (this) {
    .pending => 'Pending',
    .withDoctor => 'WithDoctor',
    .released => 'Released',
    .updateWithDoctor => 'UpdateWithDoctor',
  };

  static ResultState fromValue(String value) => switch (value) {
    'Pending' => .pending,
    'WithDoctor' => .withDoctor,
    'Released' => .released,
    'UpdateWithDoctor' => .updateWithDoctor,
    _ => .pending,
  };
}

/// How a case was paid for. Unknown reads as [cash].
enum PaymentMethod {
  cash,
  insurance;

  String get value => switch (this) {
    .cash => 'Cash',
    .insurance => 'Insurance',
  };

  static PaymentMethod fromValue(String value) => switch (value) {
    'Cash' => .cash,
    'Insurance' => .insurance,
    _ => .cash,
  };
}

/// Why a case link was shared. Unknown reads as [join].
enum SharePurpose {
  join,
  reportUnlock;

  String get value => switch (this) {
    .join => 'Join',
    .reportUnlock => 'ReportUnlock',
  };

  static SharePurpose fromValue(String value) => switch (value) {
    'Join' => .join,
    'ReportUnlock' => .reportUnlock,
    _ => .join,
  };
}

/// The state of a shared case link. Unknown reads as [revoked].
enum ShareStatus {
  pending,
  redeemed,
  expired,
  locked,
  revoked;

  String get value => switch (this) {
    .pending => 'Pending',
    .redeemed => 'Redeemed',
    .expired => 'Expired',
    .locked => 'Locked',
    .revoked => 'Revoked',
  };

  static ShareStatus fromValue(String value) => switch (value) {
    'Pending' => .pending,
    'Redeemed' => .redeemed,
    'Expired' => .expired,
    'Locked' => .locked,
    'Revoked' => .revoked,
    _ => .revoked,
  };
}

/// The state of a background job. Unknown reads as [queued].
enum JobStatus {
  queued,
  running,
  ready,
  failed;

  String get value => switch (this) {
    .queued => 'Queued',
    .running => 'Running',
    .ready => 'Ready',
    .failed => 'Failed',
  };

  static JobStatus fromValue(String value) => switch (value) {
    'Queued' => .queued,
    'Running' => .running,
    'Ready' => .ready,
    'Failed' => .failed,
    _ => .queued,
  };
}

/// How urgently a case needs attention. Unknown reads as [routine].
enum Urgency {
  routine,
  priority,
  urgent;

  String get value => switch (this) {
    .routine => 'Routine',
    .priority => 'Priority',
    .urgent => 'Urgent',
  };

  static Urgency fromValue(String value) => switch (value) {
    'Routine' => .routine,
    'Priority' => .priority,
    'Urgent' => .urgent,
    _ => .routine,
  };
}

/// The AI's confidence in a preread. Unknown reads as [low].
enum ConfidenceBand {
  high,
  moderate,
  low;

  String get value => switch (this) {
    .high => 'High',
    .moderate => 'Moderate',
    .low => 'Low',
  };

  static ConfidenceBand fromValue(String value) => switch (value) {
    'High' => .high,
    'Moderate' => .moderate,
    'Low' => .low,
    _ => .low,
  };
}

/// Which preread pipeline ran. Unknown reads as [noProfile].
enum PrereadProfile {
  cancer,
  malaria,
  noProfile;

  String get value => switch (this) {
    .cancer => 'Cancer',
    .malaria => 'Malaria',
    .noProfile => 'None',
  };

  static PrereadProfile fromValue(String value) => switch (value) {
    'Cancer' => .cancer,
    'Malaria' => .malaria,
    'None' => .noProfile,
    _ => .noProfile,
  };
}

// Report wire values.
/// Whether a report stands alone or has follow-ons. Unknown reads as [initial].
enum ReportStage {
  initial,
  addended,
  amended;

  String get value => switch (this) {
    .initial => 'Initial',
    .addended => 'Addended',
    .amended => 'Amended',
  };

  static ReportStage fromValue(String value) => switch (value) {
    'Initial' => .initial,
    'Addended' => .addended,
    'Amended' => .amended,
    _ => .initial,
  };
}

/// Whether a signed report is current. Unknown reads as [superseded].
enum ReportStatus {
  signed,
  superseded;

  String get value => switch (this) {
    .signed => 'Signed',
    .superseded => 'Superseded',
  };

  static ReportStatus fromValue(String value) => switch (value) {
    'Signed' => .signed,
    'Superseded' => .superseded,
    _ => .superseded,
  };
}

/// How definitive a diagnosis is. Unknown reads as [provisional].
enum DiagnosisType {
  finalDiagnosis,
  provisional,
  inconclusive;

  String get value => switch (this) {
    .finalDiagnosis => 'Final',
    .provisional => 'Provisional',
    .inconclusive => 'Inconclusive',
  };

  static DiagnosisType fromValue(String value) => switch (value) {
    'Final' => .finalDiagnosis,
    'Provisional' => .provisional,
    'Inconclusive' => .inconclusive,
    _ => .provisional,
  };
}

/// Which template shaped a report. Unknown reads as [general].
enum ReportTemplate {
  cancer,
  malaria,
  general;

  String get value => switch (this) {
    .cancer => 'Cancer',
    .malaria => 'Malaria',
    .general => 'General',
  };

  static ReportTemplate fromValue(String value) => switch (value) {
    'Cancer' => .cancer,
    'Malaria' => .malaria,
    'General' => .general,
    _ => .general,
  };
}

/// The language a report is written in. Unknown reads as [en].
enum ReportLanguage {
  en,
  sw;

  String get value => switch (this) {
    .en => 'en',
    .sw => 'sw',
  };

  static ReportLanguage fromValue(String value) => switch (value) {
    'en' => .en,
    'sw' => .sw,
    _ => .en,
  };
}

/// What kind of draft this is. Unknown reads as [initial].
enum DraftKind {
  initial,
  addendum,
  amendment;

  String get value => switch (this) {
    .initial => 'Initial',
    .addendum => 'Addendum',
    .amendment => 'Amendment',
  };

  static DraftKind fromValue(String value) => switch (value) {
    'Initial' => .initial,
    'Addendum' => .addendum,
    'Amendment' => .amendment,
    _ => .initial,
  };
}

/// The state of a report draft. Unknown reads as [closed].
enum DraftStatus {
  editing,
  signed,
  closed;

  String get value => switch (this) {
    .editing => 'Editing',
    .signed => 'Signed',
    .closed => 'Closed',
  };

  static DraftStatus fromValue(String value) => switch (value) {
    'Editing' => .editing,
    'Signed' => .signed,
    'Closed' => .closed,
    _ => .closed,
  };
}

/// The pathologist's verdict on the AI score. Unknown reads as [disagree].
enum ScoreVerdict {
  agree,
  partlyAgree,
  disagree;

  String get value => switch (this) {
    .agree => 'Agree',
    .partlyAgree => 'PartlyAgree',
    .disagree => 'Disagree',
  };

  static ScoreVerdict fromValue(String value) => switch (value) {
    'Agree' => .agree,
    'PartlyAgree' => .partlyAgree,
    'Disagree' => .disagree,
    _ => .disagree,
  };
}

/// Verdict on the AI measurements. Unknown reads as [notApplicable].
enum MeasurementsVerdict {
  accepted,
  corrected,
  notApplicable;

  String get value => switch (this) {
    .accepted => 'Accepted',
    .corrected => 'Corrected',
    .notApplicable => 'NotApplicable',
  };

  static MeasurementsVerdict fromValue(String value) => switch (value) {
    'Accepted' => .accepted,
    'Corrected' => .corrected,
    'NotApplicable' => .notApplicable,
    _ => .notApplicable,
  };
}

/// Verdict on the AI segmentation. Unknown reads as [notApplicable].
enum SegmentationVerdict {
  good,
  acceptable,
  poor,
  notApplicable;

  String get value => switch (this) {
    .good => 'Good',
    .acceptable => 'Acceptable',
    .poor => 'Poor',
    .notApplicable => 'NotApplicable',
  };

  static SegmentationVerdict fromValue(String value) => switch (value) {
    'Good' => .good,
    'Acceptable' => .acceptable,
    'Poor' => .poor,
    'NotApplicable' => .notApplicable,
    _ => .notApplicable,
  };
}

/// Where a worklist item sits. Unknown reads as [closed].
enum WorklistStatus {
  open,
  inProgress,
  signed,
  closed;

  String get value => switch (this) {
    .open => 'Open',
    .inProgress => 'InProgress',
    .signed => 'Signed',
    .closed => 'Closed',
  };

  static WorklistStatus fromValue(String value) => switch (value) {
    'Open' => .open,
    'InProgress' => .inProgress,
    'Signed' => .signed,
    'Closed' => .closed,
    _ => .closed,
  };
}

/// What a draft diff is measured against. Unknown reads as [noBase].
enum DiffBase {
  aiDraft,
  previousVersion,
  noBase;

  String get value => switch (this) {
    .aiDraft => 'AiDraft',
    .previousVersion => 'PreviousVersion',
    .noBase => 'None',
  };

  static DiffBase fromValue(String value) => switch (value) {
    'AiDraft' => .aiDraft,
    'PreviousVersion' => .previousVersion,
    'None' => .noBase,
    _ => .noBase,
  };
}

/// How a report field changed. Unknown reads as [edited].
enum FieldChange {
  unchanged,
  edited,
  added,
  removed;

  String get value => switch (this) {
    .unchanged => 'Unchanged',
    .edited => 'Edited',
    .added => 'Added',
    .removed => 'Removed',
  };

  static FieldChange fromValue(String value) => switch (value) {
    'Unchanged' => .unchanged,
    'Edited' => .edited,
    'Added' => .added,
    'Removed' => .removed,
    _ => .edited,
  };
}

/// What kind of generated report text this is. Unknown reads as [translation].
enum ReportTextKind {
  translation,
  explanation;

  String get value => switch (this) {
    .translation => 'Translation',
    .explanation => 'Explanation',
  };

  static ReportTextKind fromValue(String value) => switch (value) {
    'Translation' => .translation,
    'Explanation' => .explanation,
    _ => .translation,
  };
}

/// The state of generated report text. Unknown reads as [queued].
enum ReportTextStatus {
  queued,
  running,
  ready,
  failed,
  approved,
  rejected;

  String get value => switch (this) {
    .queued => 'Queued',
    .running => 'Running',
    .ready => 'Ready',
    .failed => 'Failed',
    .approved => 'Approved',
    .rejected => 'Rejected',
  };

  static ReportTextStatus fromValue(String value) => switch (value) {
    'Queued' => .queued,
    'Running' => .running,
    'Ready' => .ready,
    'Failed' => .failed,
    'Approved' => .approved,
    'Rejected' => .rejected,
    _ => .queued,
  };
}

/// The decision on generated report text. Unknown reads as [reject].
enum ApprovalDecision {
  approve,
  approveEdited,
  reject;

  String get value => switch (this) {
    .approve => 'Approve',
    .approveEdited => 'ApproveEdited',
    .reject => 'Reject',
  };

  static ApprovalDecision fromValue(String value) => switch (value) {
    'Approve' => .approve,
    'ApproveEdited' => .approveEdited,
    'Reject' => .reject,
    _ => .reject,
  };
}

/// Why a report job failed. Unknown reads as [serviceError].
enum FailureReason {
  none,
  timeout,
  serviceError,
  offSchema,
  numberCheck,
  stale,
  banned,
  disabled;

  String get value => switch (this) {
    .none => '',
    .timeout => 'Timeout',
    .serviceError => 'ServiceError',
    .offSchema => 'OffSchema',
    .numberCheck => 'NumberCheck',
    .stale => 'Stale',
    .banned => 'Banned',
    .disabled => 'Disabled',
  };

  static FailureReason fromValue(String value) => switch (value) {
    '' => .none,
    'Timeout' => .timeout,
    'ServiceError' => .serviceError,
    'OffSchema' => .offSchema,
    'NumberCheck' => .numberCheck,
    'Stale' => .stale,
    'Banned' => .banned,
    'Disabled' => .disabled,
    _ => .serviceError,
  };
}

// Input, appointment and conversation wire values.
/// How input was captured. Unknown reads as [typed].
enum InputMode {
  typed,
  voice;

  String get value => switch (this) {
    .typed => 'Typed',
    .voice => 'Voice',
  };

  static InputMode fromValue(String value) => switch (value) {
    'Typed' => .typed,
    'Voice' => .voice,
    _ => .typed,
  };
}

/// What kind of message content this is. Unknown reads as [text].
enum MessageKind {
  text,
  image,
  voice;

  String get value => switch (this) {
    .text => 'Text',
    .image => 'Image',
    .voice => 'Voice',
  };

  static MessageKind fromValue(String value) => switch (value) {
    'Text' => .text,
    'Image' => .image,
    'Voice' => .voice,
    _ => .text,
  };
}

/// The state of a voice transcript. Unknown reads as [noTranscript].
enum TranscriptStatus {
  noTranscript,
  queued,
  running,
  ready,
  failed;

  String get value => switch (this) {
    .noTranscript => 'None',
    .queued => 'Queued',
    .running => 'Running',
    .ready => 'Ready',
    .failed => 'Failed',
  };

  static TranscriptStatus fromValue(String value) => switch (value) {
    'None' => .noTranscript,
    'Queued' => .queued,
    'Running' => .running,
    'Ready' => .ready,
    'Failed' => .failed,
    _ => .noTranscript,
  };
}

/// What kind of appointment this is. Unknown reads as [consultation].
enum AppointmentType {
  consultation,
  caseDiscussion;

  String get value => switch (this) {
    .consultation => 'Consultation',
    .caseDiscussion => 'CaseDiscussion',
  };

  static AppointmentType fromValue(String value) => switch (value) {
    'Consultation' => .consultation,
    'CaseDiscussion' => .caseDiscussion,
    _ => .consultation,
  };

  String description(AppLocalizations l10n) => switch (this) {
    .consultation => l10n.appointmentsTypeConsultation,
    .caseDiscussion => l10n.appointmentsTypeCaseDiscussion,
  };
}

/// The state of an appointment. Unknown reads as [expired].
enum AppointmentStatus {
  requested,
  accepted,
  declined,
  expired,
  cancelled,
  completed,
  noShow;

  String get value => switch (this) {
    .requested => 'Requested',
    .accepted => 'Accepted',
    .declined => 'Declined',
    .expired => 'Expired',
    .cancelled => 'Cancelled',
    .completed => 'Completed',
    .noShow => 'NoShow',
  };

  static AppointmentStatus fromValue(String value) => switch (value) {
    'Requested' => .requested,
    'Accepted' => .accepted,
    'Declined' => .declined,
    'Expired' => .expired,
    'Cancelled' => .cancelled,
    'Completed' => .completed,
    'NoShow' => .noShow,
    _ => .expired,
  };
}

/// The state of appointment intake. Unknown reads as [noIntake].
enum IntakeStatus {
  noIntake,
  queued,
  ready,
  failed;

  String get value => switch (this) {
    .noIntake => 'None',
    .queued => 'Queued',
    .ready => 'Ready',
    .failed => 'Failed',
  };

  static IntakeStatus fromValue(String value) => switch (value) {
    'None' => .noIntake,
    'Queued' => .queued,
    'Ready' => .ready,
    'Failed' => .failed,
    _ => .noIntake,
  };
}

/// What kind of conversation this is. Unknown reads as [direct].
enum ConversationType {
  groupConsult,
  direct;

  String get value => switch (this) {
    .groupConsult => 'GroupConsult',
    .direct => 'Direct',
  };

  static ConversationType fromValue(String value) => switch (value) {
    'GroupConsult' => .groupConsult,
    'Direct' => .direct,
    _ => .direct,
  };
}

/// Whether a conversation is open. Unknown reads as [closed].
enum ConversationStatus {
  open,
  closed;

  String get value => switch (this) {
    .open => 'Open',
    .closed => 'Closed',
  };

  static ConversationStatus fromValue(String value) => switch (value) {
    'Open' => .open,
    'Closed' => .closed,
    _ => .closed,
  };
}

/// What kind of resource a link points to. Unknown reads as [patientCase].
enum LinkedResourceType {
  appointment,
  patientCase;

  String get value => switch (this) {
    .appointment => 'Appointment',
    .patientCase => 'Case',
  };

  static LinkedResourceType fromValue(String value) => switch (value) {
    'Appointment' => .appointment,
    'Case' => .patientCase,
    _ => .patientCase,
  };
}

/// A member's role in a conversation. Unknown reads as [member].
enum MemberRole {
  owner,
  member;

  String get value => switch (this) {
    .owner => 'Owner',
    .member => 'Member',
  };

  static MemberRole fromValue(String value) => switch (value) {
    'Owner' => .owner,
    'Member' => .member,
    _ => .member,
  };
}

/// A member's state in a conversation. Unknown reads as [removed].
enum MemberStatus {
  invited,
  accepted,
  declined,
  expired,
  left,
  removed;

  String get value => switch (this) {
    .invited => 'Invited',
    .accepted => 'Accepted',
    .declined => 'Declined',
    .expired => 'Expired',
    .left => 'Left',
    .removed => 'Removed',
  };

  static MemberStatus fromValue(String value) => switch (value) {
    'Invited' => .invited,
    'Accepted' => .accepted,
    'Declined' => .declined,
    'Expired' => .expired,
    'Left' => .left,
    'Removed' => .removed,
    _ => .removed,
  };
}

/// The delivery state of a message. Unknown reads as [withheld].
enum MessageStatus {
  pending,
  failed,
  sent,
  delivered,
  withheld;

  String get value => switch (this) {
    .pending => 'Pending',
    .failed => 'Failed',
    .sent => 'Sent',
    .delivered => 'Delivered',
    .withheld => 'Withheld',
  };

  static MessageStatus fromValue(String value) => switch (value) {
    'Pending' => .pending,
    'Failed' => .failed,
    'Sent' => .sent,
    'Delivered' => .delivered,
    'Withheld' => .withheld,
    _ => .withheld,
  };
}

/// The state of a summary report. Unknown reads as [pending].
enum SummaryReportStatus {
  pending,
  signed,
  amended;

  String get value => switch (this) {
    .pending => 'Pending',
    .signed => 'Signed',
    .amended => 'Amended',
  };

  static SummaryReportStatus fromValue(String value) => switch (value) {
    'Pending' => .pending,
    'Signed' => .signed,
    'Amended' => .amended,
    _ => .pending,
  };
}

/// Why an appointment was declined. Unknown reads as [other].
enum DeclineReason {
  slotUnavailable,
  outsidePractice,
  referredElsewhere,
  slotTaken,
  other;

  String get value => switch (this) {
    .slotUnavailable => 'SlotUnavailable',
    .outsidePractice => 'OutsidePractice',
    .referredElsewhere => 'ReferredElsewhere',
    .slotTaken => 'SlotTaken',
    .other => 'Other',
  };

  static DeclineReason fromValue(String value) => switch (value) {
    'SlotUnavailable' => .slotUnavailable,
    'OutsidePractice' => .outsidePractice,
    'ReferredElsewhere' => .referredElsewhere,
    'SlotTaken' => .slotTaken,
    _ => .other,
  };

  String description(AppLocalizations l10n) => switch (this) {
    .slotUnavailable => l10n.declineReasonSlotUnavailable,
    .outsidePractice => l10n.declineReasonOutsidePractice,
    .referredElsewhere => l10n.declineReasonReferredElsewhere,
    .slotTaken => l10n.declineReasonSlotTaken,
    .other => l10n.declineReasonOther,
  };
}

/// Why an order was cancelled. Unknown reads as [other].
enum CancelReason {
  orderedInError,
  duplicate,
  patientDeclined,
  other;

  String get value => switch (this) {
    .orderedInError => 'OrderedInError',
    .duplicate => 'Duplicate',
    .patientDeclined => 'PatientDeclined',
    .other => 'Other',
  };

  static CancelReason fromValue(String value) => switch (value) {
    'OrderedInError' => .orderedInError,
    'Duplicate' => .duplicate,
    'PatientDeclined' => .patientDeclined,
    _ => .other,
  };

  String description(AppLocalizations l10n) => switch (this) {
    .orderedInError => l10n.cancelReasonOrderedInError,
    .duplicate => l10n.cancelReasonDuplicate,
    .patientDeclined => l10n.cancelReasonPatientDeclined,
    .other => l10n.cancelReasonOther,
  };
}

/// A section of a pathology report. Unknown reads as [comments].
enum ReportSection {
  diagnosis,
  comments,
  clinicalNotes,
  macroscopic,
  microscopic,
  ancillary;

  String get value => switch (this) {
    .diagnosis => 'Diagnosis',
    .comments => 'Comments',
    .clinicalNotes => 'ClinicalNotes',
    .macroscopic => 'Macroscopic',
    .microscopic => 'Microscopic',
    .ancillary => 'Ancillary',
  };

  static ReportSection fromValue(String value) => switch (value) {
    'Diagnosis' => .diagnosis,
    'Comments' => .comments,
    'ClinicalNotes' => .clinicalNotes,
    'Macroscopic' => .macroscopic,
    'Microscopic' => .microscopic,
    'Ancillary' => .ancillary,
    _ => .comments,
  };

  String description(AppLocalizations l10n) => switch (this) {
    .diagnosis => l10n.reportSectionDiagnosis,
    .comments => l10n.reportSectionComments,
    .clinicalNotes => l10n.reportSectionClinicalNotes,
    .macroscopic => l10n.reportSectionMacroscopic,
    .microscopic => l10n.reportSectionMicroscopic,
    .ancillary => l10n.reportSectionAncillary,
  };
}

// Notification wire values.
/// What a notification is about. Unknown reads as [patientCase].
enum NotificationCategory {
  patientCase,
  preread,
  report,
  result,
  alert,
  account,
  appointment,
  mdt,
  message;

  String get value => switch (this) {
    .patientCase => 'Case',
    .preread => 'Preread',
    .report => 'Report',
    .result => 'Result',
    .alert => 'Alert',
    .account => 'Account',
    .appointment => 'Appointment',
    .mdt => 'Mdt',
    .message => 'Message',
  };

  static NotificationCategory fromValue(String value) => switch (value) {
    'Case' => .patientCase,
    'Preread' => .preread,
    'Report' => .report,
    'Result' => .result,
    'Alert' => .alert,
    'Account' => .account,
    'Appointment' => .appointment,
    'Mdt' => .mdt,
    'Message' => .message,
    _ => .patientCase,
  };
}

/// A notification's resource type. Unknown reads as [patientCase].
enum NotificationResourceType {
  patientCase,
  alert,
  report,
  appointment,
  conversation;

  String get value => switch (this) {
    .patientCase => 'Case',
    .alert => 'Alert',
    .report => 'Report',
    .appointment => 'Appointment',
    .conversation => 'Conversation',
  };

  static NotificationResourceType fromValue(String value) => switch (value) {
    'Case' => .patientCase,
    'Alert' => .alert,
    'Report' => .report,
    'Appointment' => .appointment,
    'Conversation' => .conversation,
    _ => .patientCase,
  };
}

/// What kind of action a notification carries. Unknown reads as [none].
enum NotificationActionType {
  none,
  approval,
  acknowledge;

  String get value => switch (this) {
    .none => '',
    .approval => 'Approval',
    .acknowledge => 'Acknowledge',
  };

  static NotificationActionType fromValue(String value) => switch (value) {
    '' => .none,
    'Approval' => .approval,
    'Acknowledge' => .acknowledge,
    _ => .none,
  };
}

/// The state of a notification action. Unknown reads as [none].
enum NotificationActionStatus {
  none,
  pending,
  accepted,
  declined,
  expired,
  cancelled,
  acknowledged;

  String get value => switch (this) {
    .none => '',
    .pending => 'Pending',
    .accepted => 'Accepted',
    .declined => 'Declined',
    .expired => 'Expired',
    .cancelled => 'Cancelled',
    .acknowledged => 'Acknowledged',
  };

  static NotificationActionStatus fromValue(String value) => switch (value) {
    '' => .none,
    'Pending' => .pending,
    'Accepted' => .accepted,
    'Declined' => .declined,
    'Expired' => .expired,
    'Cancelled' => .cancelled,
    'Acknowledged' => .acknowledged,
    _ => .none,
  };
}

/// How urgently a notification needs attention. Unknown reads as [normal].
enum NotificationPriority {
  high,
  normal,
  low;

  String get value => switch (this) {
    .high => 'High',
    .normal => 'Normal',
    .low => 'Low',
  };

  static NotificationPriority fromValue(String value) => switch (value) {
    'High' => .high,
    'Normal' => .normal,
    'Low' => .low,
    _ => .normal,
  };
}

/// Where a notification is delivered. Unknown reads as [inApp].
enum NotificationChannel {
  inApp,
  push;

  String get value => switch (this) {
    .inApp => 'InApp',
    .push => 'Push',
  };

  static NotificationChannel fromValue(String value) => switch (value) {
    'InApp' => .inApp,
    'Push' => .push,
    _ => .inApp,
  };
}

/// Where a notification was created. Unknown reads as [cloudFunction].
enum NotificationSource {
  cloudFunction,
  app;

  String get value => switch (this) {
    .cloudFunction => 'Function',
    .app => 'App',
  };

  static NotificationSource fromValue(String value) => switch (value) {
    'Function' => .cloudFunction,
    'App' => .app,
    _ => .cloudFunction,
  };
}

/// Where a notification lives. Unknown reads as [cloud].
enum NotificationScope {
  local,
  cloud;

  String get value => switch (this) {
    .local => 'Local',
    .cloud => 'Cloud',
  };

  static NotificationScope fromValue(String value) => switch (value) {
    'Local' => .local,
    'Cloud' => .cloud,
    _ => .cloud,
  };
}

/// Whether a notification was read. Unknown reads as [unread].
enum NotificationStatus {
  unread,
  read,
  archived;

  String get value => switch (this) {
    .unread => 'Unread',
    .read => 'Read',
    .archived => 'Archived',
  };

  static NotificationStatus fromValue(String value) => switch (value) {
    'Unread' => .unread,
    'Read' => .read,
    'Archived' => .archived,
    _ => .unread,
  };
}

/// A push/inbox template key, shared with the functions copy. Unknown reads as [unknown].
enum NotificationTemplate {
  orderCreated,
  pathologistRequested,
  pathologistAccepted,
  pathologistAcceptedPatient,
  pathologistRejected,
  pathologistRequestExpired,
  caseWithdrawn,
  prereadReady,
  prereadFailed,
  orderCancelled,
  caseShared,
  shareRedeemed,
  reportSigned,
  reportUpdated,
  shareCodeReissued,
  criticalReportUnopened,
  criticalReportUnopenedSigner,
  resultsWithDoctor,
  resultUpdateWithDoctor,
  resultReleased,
  translationReady,
  explanationReady,
  appointmentRequested,
  caseDiscussionRequested,
  appointmentAccepted,
  appointmentDeclined,
  appointmentExpired,
  appointmentCancelledByPatient,
  appointmentCancelledByDoctor,
  mdtInvited,
  mdtInviteAccepted,
  mdtInviteDeclined,
  messageReceived,
  mdtMessageReceived,
  alertDrafted,
  alertDraftReminder,
  alertExpired,
  alertWithdrawn,
  alertEvidenceChanged,
  alertDeliveredClinician,
  alertDeliveredPatient,
  confirmatoryTestRequested,
  alertDeliveryHeld,
  alertDeliveryStopped,
  alertDeliveredClinicianDemo,
  alertDeliveredPatientDemo,
  appointmentRequestSent,
  appointmentCompleted,
  orderSubmitted,
  draftSaved,
  prereadScored,
  reportSignedSelf,
  shareCodeSent,
  mdtOpened,
  messagesQueued,
  queuedMessagesSent,
  notifiableRecorded,
  alertDecisionSaved,
  unknown;

  String get value => this == .unknown ? '' : name;

  static NotificationTemplate fromValue(String value) {
    for (final template in values) {
      if (template.value == value) return template;
    }
    return .unknown;
  }

  String title(AppLocalizations l10n, Map<String, String> args) =>
      switch (this) {
        .appointmentRequested => l10n.notificationAppointmentRequestedTitle,
        .caseDiscussionRequested =>
          l10n.notificationCaseDiscussionRequestedTitle,
        .appointmentAccepted => l10n.notificationAppointmentAcceptedTitle,
        .appointmentDeclined => l10n.notificationAppointmentDeclinedTitle,
        .appointmentExpired => l10n.notificationAppointmentExpiredTitle,
        .appointmentCancelledByPatient =>
          l10n.notificationAppointmentCancelledByPatientTitle,
        .appointmentCancelledByDoctor =>
          l10n.notificationAppointmentCancelledByDoctorTitle,
        _ => '',
      };

  String body(
    AppLocalizations l10n,
    Map<String, String> args,
  ) => switch (this) {
    .orderCreated => l10n.notificationOrderCreatedBody,
    .pathologistRequested => l10n.notificationPathologistRequestedBody,
    .pathologistAccepted => l10n.notificationPathologistAcceptedBody,
    .pathologistAcceptedPatient =>
      l10n.notificationPathologistAcceptedPatientBody,
    .pathologistRejected => l10n.notificationPathologistRejectedBody,
    .pathologistRequestExpired =>
      l10n.notificationPathologistRequestExpiredBody,
    .caseWithdrawn => l10n.notificationCaseWithdrawnBody,
    .prereadReady => l10n.notificationPrereadReadyBody,
    .prereadFailed => l10n.notificationPrereadFailedBody,
    .orderCancelled => l10n.notificationOrderCancelledBody,
    .caseShared => l10n.notificationCaseSharedBody,
    .shareRedeemed => l10n.notificationShareRedeemedBody,
    .reportSigned => l10n.notificationReportSignedBody,
    .reportUpdated => l10n.notificationReportUpdatedBody,
    .shareCodeReissued => l10n.notificationShareCodeReissuedBody,
    .criticalReportUnopened => l10n.notificationCriticalReportUnopenedBody,
    .criticalReportUnopenedSigner =>
      l10n.notificationCriticalReportUnopenedSignerBody,
    .resultsWithDoctor => l10n.notificationResultsWithDoctorBody,
    .resultUpdateWithDoctor => l10n.notificationResultUpdateWithDoctorBody,
    .resultReleased => l10n.notificationResultReleasedBody,
    .translationReady => l10n.notificationTranslationReadyBody,
    .explanationReady => l10n.notificationExplanationReadyBody,
    .appointmentRequested => l10n.notificationAppointmentRequestedBody,
    .caseDiscussionRequested => l10n.notificationCaseDiscussionRequestedBody,
    .appointmentAccepted => l10n.notificationAppointmentAcceptedBody,
    .appointmentDeclined => l10n.notificationAppointmentDeclinedBody,
    .appointmentExpired => l10n.notificationAppointmentExpiredBody,
    .appointmentCancelledByPatient =>
      l10n.notificationAppointmentCancelledByPatientBody,
    .appointmentCancelledByDoctor =>
      l10n.notificationAppointmentCancelledByDoctorBody,
    .mdtInvited => l10n.notificationMdtInvitedBody,
    .mdtInviteAccepted => l10n.notificationMdtInviteAcceptedBody,
    .mdtInviteDeclined => l10n.notificationMdtInviteDeclinedBody,
    .messageReceived => l10n.notificationMessageReceivedBody(_count(args)),
    .mdtMessageReceived => l10n.notificationMdtMessageReceivedBody(
      _count(args),
    ),
    .alertDrafted => l10n.notificationAlertDraftedBody,
    .alertDraftReminder => l10n.notificationAlertDraftReminderBody,
    .alertExpired => l10n.notificationAlertExpiredBody,
    .alertWithdrawn => l10n.notificationAlertWithdrawnBody,
    .alertEvidenceChanged => l10n.notificationAlertEvidenceChangedBody,
    .alertDeliveredClinician => l10n.notificationAlertDeliveredClinicianBody(
      args['disease'] ?? '',
      args['county'] ?? '',
    ),
    .alertDeliveredPatient => l10n.notificationAlertDeliveredPatientBody(
      args['disease'] ?? '',
      args['county'] ?? '',
    ),
    .confirmatoryTestRequested =>
      l10n.notificationConfirmatoryTestRequestedBody,
    .alertDeliveryHeld => l10n.notificationAlertDeliveryHeldBody,
    .alertDeliveryStopped => l10n.notificationAlertDeliveryStoppedBody,
    .alertDeliveredClinicianDemo =>
      l10n.notificationAlertDeliveredClinicianDemoBody(
        args['disease'] ?? '',
        args['county'] ?? '',
      ),
    .alertDeliveredPatientDemo =>
      l10n.notificationAlertDeliveredPatientDemoBody(
        args['disease'] ?? '',
        args['county'] ?? '',
      ),
    .appointmentRequestSent => l10n.notificationAppointmentRequestSentBody,
    .appointmentCompleted => l10n.notificationAppointmentCompletedBody,
    .orderSubmitted => l10n.notificationOrderSubmittedBody,
    .draftSaved => l10n.notificationDraftSavedBody,
    .prereadScored => l10n.notificationPrereadScoredBody,
    .reportSignedSelf => l10n.notificationReportSignedSelfBody,
    .shareCodeSent => l10n.notificationShareCodeSentBody,
    .mdtOpened => l10n.notificationMdtOpenedBody,
    .messagesQueued => l10n.notificationMessagesQueuedBody,
    .queuedMessagesSent => l10n.notificationQueuedMessagesSentBody,
    .notifiableRecorded => l10n.notificationNotifiableRecordedBody,
    .alertDecisionSaved => l10n.notificationAlertDecisionSavedBody,
    .unknown => l10n.notificationUnknownBody,
  };

  /// The plural count for the collapsed message rows; missing or invalid
  /// reads as one, the singular line.
  static int _count(Map<String, String> args) =>
      int.tryParse(args['newCount'] ?? '') ?? 1;
}

// Alerts and the notifiable-disease bundle

/// Kenya's reporting category for a notifiable disease.
/// Unknown reads as [notListed].
enum ReportingCategory {
  immediate,
  weekly,
  monthly,
  notListed;

  String get value => switch (this) {
    .immediate => 'Immediate',
    .weekly => 'Weekly',
    .monthly => 'Monthly',
    .notListed => 'NotListed',
  };

  static ReportingCategory fromValue(String value) => switch (value) {
    'Immediate' => .immediate,
    'Weekly' => .weekly,
    'Monthly' => .monthly,
    'NotListed' => .notListed,
    _ => .notListed,
  };
}

/// A disease's place in the International Health Regulations, Annex 2.
/// Unknown reads as [notListed].
enum IhrStatus {
  alwaysNotifiable,
  alwaysAssessed,
  eventAssessed,
  notListed;

  String get value => switch (this) {
    .alwaysNotifiable => 'AlwaysNotifiable',
    .alwaysAssessed => 'AlwaysAssessed',
    .eventAssessed => 'EventAssessed',
    .notListed => 'None',
  };

  static IhrStatus fromValue(String value) => switch (value) {
    'AlwaysNotifiable' => .alwaysNotifiable,
    'AlwaysAssessed' => .alwaysAssessed,
    'EventAssessed' => .eventAssessed,
    'None' => .notListed,
    _ => .notListed,
  };
}

/// A disease's group in Kenya's surveillance list.
/// Unknown reads as [notListed].
enum KenyaGroup {
  epidemicProne,
  elimination,
  publicHealthImportance,
  notListed;

  String get value => switch (this) {
    .epidemicProne => 'EpidemicProne',
    .elimination => 'Elimination',
    .publicHealthImportance => 'PublicHealthImportance',
    .notListed => 'NotListed',
  };

  static KenyaGroup fromValue(String value) => switch (value) {
    'EpidemicProne' => .epidemicProne,
    'Elimination' => .elimination,
    'PublicHealthImportance' => .publicHealthImportance,
    'NotListed' => .notListed,
    _ => .notListed,
  };
}

/// How strongly a lab test confirms a disease. Unknown reads as [uncertain].
enum TestStrength {
  confirms,
  presumptive,
  supportive,
  uncertain;

  String get value => switch (this) {
    .confirms => 'Confirms',
    .presumptive => 'Presumptive',
    .supportive => 'Supportive',
    .uncertain => 'Uncertain',
  };

  static TestStrength fromValue(String value) => switch (value) {
    'Confirms' => .confirms,
    'Presumptive' => .presumptive,
    'Supportive' => .supportive,
    'Uncertain' => .uncertain,
    _ => .uncertain,
  };
}

/// Who a guidance bullet is written for. Unknown reads as [patient].
enum GuidanceAudience {
  patient,
  clinician;

  String get value => switch (this) {
    .patient => 'Patient',
    .clinician => 'Clinician',
  };

  static GuidanceAudience fromValue(String value) => switch (value) {
    'Patient' => .patient,
    'Clinician' => .clinician,
    _ => .patient,
  };
}

/// The detector rule that raised an alert signal. Unknown reads as [manual].
enum AlertRule {
  immediate,
  baseline,
  manual;

  String get value => switch (this) {
    .immediate => 'Immediate',
    .baseline => 'Baseline',
    .manual => 'Manual',
  };

  static AlertRule fromValue(String value) => switch (value) {
    'Immediate' => .immediate,
    'Baseline' => .baseline,
    'Manual' => .manual,
    _ => .manual,
  };
}

/// Where an alert is in its approval and delivery.
/// Unknown reads as [withdrawn].
enum AlertStatus {
  drafting,
  draft,
  approved,
  delivered,
  rejected,
  expired,
  withdrawn;

  String get value => switch (this) {
    .drafting => 'Drafting',
    .draft => 'Draft',
    .approved => 'Approved',
    .delivered => 'Delivered',
    .rejected => 'Rejected',
    .expired => 'Expired',
    .withdrawn => 'Withdrawn',
  };

  static AlertStatus fromValue(String value) => switch (value) {
    'Drafting' => .drafting,
    'Draft' => .draft,
    'Approved' => .approved,
    'Delivered' => .delivered,
    'Rejected' => .rejected,
    'Expired' => .expired,
    'Withdrawn' => .withdrawn,
    _ => .withdrawn,
  };
}

/// Whether an alert's draft text came from the model or the template.
/// Unknown reads as [template].
enum AlertDraftSource {
  model,
  template;

  String get value => switch (this) {
    .model => 'Model',
    .template => 'Template',
  };

  static AlertDraftSource fromValue(String value) => switch (value) {
    'Model' => .model,
    'Template' => .template,
    _ => .template,
  };
}

/// Who an approved alert reaches. Unknown reads as [cliniciansOnly].
enum AlertAudience {
  cliniciansThenPatients,
  cliniciansOnly;

  String get value => switch (this) {
    .cliniciansThenPatients => 'CliniciansThenPatients',
    .cliniciansOnly => 'CliniciansOnly',
  };

  static AlertAudience fromValue(String value) => switch (value) {
    'CliniciansThenPatients' => .cliniciansThenPatients,
    'CliniciansOnly' => .cliniciansOnly,
    _ => .cliniciansOnly,
  };
}
