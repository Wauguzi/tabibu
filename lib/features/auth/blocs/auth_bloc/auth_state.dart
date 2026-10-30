import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';

/// Every state carries the session as it stands, so the router and any
/// screen read it from whichever state is current (architecture §5 rule 5).
sealed class AuthState extends Equatable {
  const AuthState({required this.session});

  final AuthSession session;

  @override
  List<Object?> get props => [session];
}

final class AuthInitial extends AuthState {
  const AuthInitial() : super(session: const SignedOutSession());
}

/// The base every failure shares. Listeners match the concrete failure,
/// never this (rule 4).
sealed class AuthOperationFailure extends AuthState {
  const AuthOperationFailure({required super.session, required this.error});

  final AppError error;

  @override
  List<Object?> get props => [session, error];
}

final class SessionLoadInProgress extends AuthState {
  const SessionLoadInProgress({required super.session});
}

final class SessionLoadSuccess extends AuthState {
  const SessionLoadSuccess({required super.session});
}

final class SessionLoadFailure extends AuthOperationFailure {
  const SessionLoadFailure({required super.session, required super.error});
}

final class SignInInProgress extends AuthState {
  const SignInInProgress({required super.session});
}

final class SignInSuccess extends AuthState {
  const SignInSuccess({required super.session});
}

/// The Google dialog was dismissed: not an error, so nothing is shown.
final class SignInCancelled extends AuthState {
  const SignInCancelled({required super.session});
}

final class SignInFailure extends AuthOperationFailure {
  const SignInFailure({required super.session, required super.error});
}

final class CreateAccountInProgress extends AuthState {
  const CreateAccountInProgress({required super.session});
}

final class CreateAccountSuccess extends AuthState {
  const CreateAccountSuccess({required super.session});
}

final class CreateAccountFailure extends AuthOperationFailure {
  const CreateAccountFailure({required super.session, required super.error});
}

final class PasswordResetInProgress extends AuthState {
  const PasswordResetInProgress({required super.session});
}

/// Also emitted for an address with no account: the screen must not reveal
/// which addresses are registered.
final class PasswordResetSuccess extends AuthState {
  const PasswordResetSuccess({required super.session});
}

final class PasswordResetFailure extends AuthOperationFailure {
  const PasswordResetFailure({required super.session, required super.error});
}

final class SignUpInProgress extends AuthState {
  const SignUpInProgress({required super.session});
}

/// The session says where to go: a patient's home, the clinic-record notice,
/// or the pending screen.
final class SignUpSuccess extends AuthState {
  const SignUpSuccess({required super.session});
}

final class SignUpFailure extends AuthOperationFailure {
  const SignUpFailure({required super.session, required super.error});
}

final class SignOutInProgress extends AuthState {
  const SignOutInProgress({required super.session});
}

final class SignOutSuccess extends AuthState {
  const SignOutSuccess() : super(session: const SignedOutSession());
}

final class SignOutFailure extends AuthOperationFailure {
  const SignOutFailure({required super.session, required super.error});
}

/// `App` switches its locale on this.
final class LanguageChangeSuccess extends AuthState {
  const LanguageChangeSuccess({required super.session, required this.language});

  final AppLanguage language;

  @override
  List<Object?> get props => [session, language];
}

final class LanguageChangeFailure extends AuthOperationFailure {
  const LanguageChangeFailure({required super.session, required super.error});
}

final class EmailVerificationCheckInProgress extends AuthState {
  const EmailVerificationCheckInProgress({required super.session});
}

/// [session] is resolved again: once verified, it says where to go next.
final class EmailVerificationCheckSuccess extends AuthState {
  const EmailVerificationCheckSuccess({
    required super.session,
    required this.isVerified,
  });

  final bool isVerified;

  @override
  List<Object?> get props => [session, isVerified];
}

final class EmailVerificationCheckFailure extends AuthOperationFailure {
  const EmailVerificationCheckFailure({
    required super.session,
    required super.error,
  });
}

final class VerificationEmailResendInProgress extends AuthState {
  const VerificationEmailResendInProgress({required super.session});
}

final class VerificationEmailResendSuccess extends AuthState {
  const VerificationEmailResendSuccess({required super.session});
}

final class VerificationEmailResendFailure extends AuthOperationFailure {
  const VerificationEmailResendFailure({
    required super.session,
    required super.error,
  });
}
