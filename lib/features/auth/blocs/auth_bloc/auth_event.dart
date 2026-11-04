import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/auth/data/models/sign_up_draft.dart';
import 'package:tabibu/features/auth/data/models/upload_file.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Cold start, and the pending screen's "check again". [forceRefresh] fetches
/// a new ID token, for a role granted since the last one.
final class SessionRequested extends AuthEvent {
  const SessionRequested({this.forceRefresh = false});

  final bool forceRefresh;

  @override
  List<Object?> get props => [forceRefresh];
}

final class SignInRequested extends AuthEvent {
  const SignInRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];

  /// Never printed: a logged event would carry the password.
  @override
  bool get stringify => false;
}

final class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

/// D2 and E1: the Auth account, before any profile exists.
final class CreateAccountRequested extends AuthEvent {
  const CreateAccountRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];

  /// Never printed: a logged event would carry the password.
  @override
  bool get stringify => false;
}

final class PasswordResetRequested extends AuthEvent {
  const PasswordResetRequested({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

final class PatientSignUpRequested extends AuthEvent {
  const PatientSignUpRequested({required this.draft});

  final SignUpDraft draft;

  @override
  List<Object?> get props => [draft];
}

/// Uploads the photo and license files, then submits.
final class PractitionerSignUpRequested extends AuthEvent {
  const PractitionerSignUpRequested({required this.draft});

  final SignUpDraft draft;

  @override
  List<Object?> get props => [draft];
}

final class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

/// A2 and the profile's language setting; the app switches at once.
final class LanguageChangeRequested extends AuthEvent {
  const LanguageChangeRequested({required this.language});

  final AppLanguage language;

  @override
  List<Object?> get props => [language];
}

/// "I've verified" on the verification screen, and the silent check when the
/// app resumes from the mail app.
final class EmailVerificationCheckRequested extends AuthEvent {
  const EmailVerificationCheckRequested();
}

final class VerificationEmailResendRequested extends AuthEvent {
  const VerificationEmailResendRequested();
}

/// The profile tab's switches: no optimistic flip, the session carries the
/// new value once the write lands.
final class ProfileSettingChanged extends AuthEvent {
  const ProfileSettingChanged({required this.setting, required this.value});

  final ProfileSetting setting;
  final bool value;

  @override
  List<Object?> get props => [setting, value];
}

/// The edit-profile Save: names, phone, and a picked photo held until the
/// write uploads it. The screen validates first; the rules check again.
final class PatientProfileChanged extends AuthEvent {
  const PatientProfileChanged({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.phoneNumber,
    this.picture,
  });

  final String firstName;
  final String middleName;
  final String lastName;
  final String phoneNumber;
  final UploadFile? picture;

  @override
  List<Object?> get props => [
    firstName,
    middleName,
    lastName,
    phoneNumber,
    picture,
  ];
}

/// The practitioner details Save: specialties, bio, phone, and a picked
/// photo. Names stay locked once verified.
final class PractitionerProfileChanged extends AuthEvent {
  const PractitionerProfileChanged({
    required this.specialties,
    required this.bio,
    required this.phoneNumber,
    this.picture,
  });

  final List<String> specialties;
  final String bio;
  final String phoneNumber;
  final UploadFile? picture;

  @override
  List<Object?> get props => [specialties, bio, phoneNumber, picture];
}

/// The area Save: county and sub-county ids, resolved to names by the
/// server. Nairobi alone needs a sub-county.
final class PatientAreaChanged extends AuthEvent {
  const PatientAreaChanged({required this.countyId, this.subCountyId});

  final int countyId;
  final int? subCountyId;

  @override
  List<Object?> get props => [countyId, subCountyId];
}

/// The clinic-hours Save: working days plus the one range all days share.
final class ClinicHoursChanged extends AuthEvent {
  const ClinicHoursChanged({
    required this.workingDays,
    required this.dayStartMinute,
    required this.dayEndMinute,
  });

  final List<int> workingDays;
  final int dayStartMinute;
  final int dayEndMinute;

  @override
  List<Object?> get props => [workingDays, dayStartMinute, dayEndMinute];
}
