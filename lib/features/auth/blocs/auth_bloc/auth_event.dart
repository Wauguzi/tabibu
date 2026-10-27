import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/auth/data/models/sign_up_draft.dart';

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
