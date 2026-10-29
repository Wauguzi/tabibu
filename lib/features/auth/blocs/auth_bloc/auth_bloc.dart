import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/auth_helper.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/helpers/notifications_helper.dart';
import 'package:tabibu/core/services/analytics_service.dart';
import 'package:tabibu/core/services/internet_service.dart';
import 'package:tabibu/core/services/notification_service.dart';
import 'package:tabibu/core/services/rasp_service.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';

/// The signed-in session and every action that changes it. Provided above
/// the router, which reads [AuthState.session] (architecture §5, §8).
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    AuthHelper? authHelper,
    InternetService? internetService,
    AnalyticsService? analyticsService,
    NotificationsHelper? notificationsHelper,
    NotificationService? notificationService,
    RaspService? raspService,
  }) : _auth = authHelper ?? getIt<AuthHelper>(),
       _internet = internetService ?? getIt<InternetService>(),
       _analytics = analyticsService ?? getIt<AnalyticsService>(),
       _notices = notificationsHelper ?? getIt<NotificationsHelper>(),
       _rasp = raspService ?? getIt<RaspService>(),
       super(const AuthInitial()) {
    // A cold start and a "check again" tap must not resolve twice at once.
    on<SessionRequested>(_onSessionRequested, transformer: droppable());
    // Every action below is one a double tap must not send twice.
    on<SignInRequested>(_onSignInRequested, transformer: droppable());
    on<GoogleSignInRequested>(
      _onGoogleSignInRequested,
      transformer: droppable(),
    );
    on<CreateAccountRequested>(
      _onCreateAccountRequested,
      transformer: droppable(),
    );
    on<PasswordResetRequested>(
      _onPasswordResetRequested,
      transformer: droppable(),
    );
    on<PatientSignUpRequested>(
      _onPatientSignUpRequested,
      transformer: droppable(),
    );
    on<PractitionerSignUpRequested>(
      _onPractitionerSignUpRequested,
      transformer: droppable(),
    );
    on<SignOutRequested>(_onSignOutRequested, transformer: droppable());
    // A repeated tap, or a resume while a check runs, must not check twice.
    on<EmailVerificationCheckRequested>(
      _onEmailVerificationCheckRequested,
      transformer: droppable(),
    );
    // One email per tap; the screen's cooldown limits taps.
    on<VerificationEmailResendRequested>(
      _onVerificationEmailResendRequested,
      transformer: droppable(),
    );
    // Tapping through the languages: only the last choice matters.
    on<LanguageChangeRequested>(
      _onLanguageChangeRequested,
      transformer: restartable(),
    );

    _tokenRefreshes = (notificationService ?? getIt<NotificationService>())
        .tokenRefreshes
        .listen((_) => unawaited(_registerDevice(state.session)));
  }

  final AuthHelper _auth;
  final InternetService _internet;
  final AnalyticsService _analytics;
  final NotificationsHelper _notices;
  final RaspService _rasp;
  late final StreamSubscription<String> _tokenRefreshes;

  // Each sign-out moves this on, so a session read that started before it
  // and answers after it is dropped instead of signing the person back in.
  int _signOuts = 0;

  /// No connectivity check: offline, the cached profile answers.
  Future<void> _onSessionRequested(
    SessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    final signOuts = _signOuts;
    emit(SessionLoadInProgress(session: state.session));
    try {
      final session = await _auth.resolveSession(
        forceRefresh: event.forceRefresh,
      );
      if (signOuts != _signOuts) return;
      _afterSignIn(session);
      emit(SessionLoadSuccess(session: session));
    } on Object catch (e) {
      if (signOuts != _signOuts) return;
      // Object, not Exception: an Error would otherwise leave the decision
      // route spinning with no terminal state.
      emit(SessionLoadFailure(session: state.session, error: _appErrorOf(e)));
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(SignInInProgress(session: state.session));
    try {
      await _requireInternet();
      final session = await _auth.signInWithEmail(
        email: event.email,
        password: event.password,
      );
      _afterSignIn(session);
      unawaited(_analytics.logLogin(SignInMethod.email));
      emit(SignInSuccess(session: session));
    } on Object catch (e) {
      emit(SignInFailure(session: state.session, error: _appErrorOf(e)));
    }
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(SignInInProgress(session: state.session));
    try {
      await _requireInternet();
      final session = await _auth.signInWithGoogle();
      if (session == null) {
        emit(SignInCancelled(session: state.session));
        return;
      }
      _afterSignIn(session);
      unawaited(_analytics.logLogin(SignInMethod.google));
      emit(SignInSuccess(session: session));
    } on Object catch (e) {
      emit(SignInFailure(session: state.session, error: _appErrorOf(e)));
    }
  }

  Future<void> _onCreateAccountRequested(
    CreateAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(CreateAccountInProgress(session: state.session));
    try {
      await _requireInternet();
      final session = await _auth.createAccount(
        email: event.email,
        password: event.password,
      );
      _afterSignIn(session);
      unawaited(_analytics.logSignUp(SignInMethod.email));
      emit(CreateAccountSuccess(session: session));
    } on Object catch (e) {
      // The account may exist although reading it back failed; a retry
      // would then meet emailAlreadyInUse, so the screen moves on as signed
      // in instead.
      final created = _auth.currentUid != null;
      emit(
        CreateAccountFailure(
          session: created
              ? SignUpIncompleteSession(email: event.email.trim())
              : state.session,
          error: _appErrorOf(e),
        ),
      );
    }
  }

  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(PasswordResetInProgress(session: state.session));
    try {
      await _requireInternet();
      await _auth.sendPasswordReset(email: event.email);
      unawaited(_analytics.logPasswordResetRequested());
      emit(PasswordResetSuccess(session: state.session));
    } on AppError catch (e) {
      // Reporting an unknown address would reveal which ones are registered.
      if (e == AppError.userNotFound) {
        emit(PasswordResetSuccess(session: state.session));
      } else {
        emit(PasswordResetFailure(session: state.session, error: e));
      }
    } on Object catch (e) {
      emit(PasswordResetFailure(session: state.session, error: _appErrorOf(e)));
    }
  }

  Future<void> _onPatientSignUpRequested(
    PatientSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(SignUpInProgress(session: state.session));
    try {
      final request = event.draft.toPatientRequest();
      await _requireInternet();
      var session = await _auth.completePatientSignUp(request);
      final picture = event.draft.picture;
      if (session is PatientSession && picture != null) {
        session = await _auth.addPatientPicture(session, picture);
      }
      _afterSignIn(session);
      unawaited(_analytics.logCompleteSignUp(Role.patient));
      if (session is PatientSession) {
        unawaited(_notices.notifyPatientRegistered());
      }
      emit(SignUpSuccess(session: session));
    } on Object catch (e) {
      emit(SignUpFailure(session: state.session, error: _appErrorOf(e)));
    }
  }

  Future<void> _onPractitionerSignUpRequested(
    PractitionerSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(SignUpInProgress(session: state.session));
    try {
      final draft = event.draft..checkPractitioner();
      await _requireInternet();
      final files = await _auth.uploadSignUpFiles(
        picture: draft.picture!,
        licenses: draft.licenses,
      );
      final session = await _auth.completePractitionerSignUp(
        draft.toPractitionerRequest(
          pictureUrl: files.pictureUrl,
          licenseUrls: files.licenseUrls,
        ),
      );
      _afterSignIn(session);
      unawaited(_analytics.logCompleteSignUp(draft.role!));
      unawaited(_notices.notifyLicenceReceived());
      emit(SignUpSuccess(session: session));
    } on Object catch (e) {
      emit(SignUpFailure(session: state.session, error: _appErrorOf(e)));
    }
  }

  /// No connectivity check: signing out must work offline. Only the token
  /// removal needs the network, and it never blocks.
  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    _signOuts++;
    emit(SignOutInProgress(session: state.session));
    try {
      await _auth.signOut(session: state.session);
      unawaited(_analytics.logSignOut());
      unawaited(_analytics.setRole(null));
      emit(const SignOutSuccess());
    } on Object catch (e) {
      emit(SignOutFailure(session: state.session, error: _appErrorOf(e)));
    }
  }

  Future<void> _onEmailVerificationCheckRequested(
    EmailVerificationCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(EmailVerificationCheckInProgress(session: state.session));
    try {
      await _requireInternet();
      final session = await _auth.checkEmailVerified();
      final isVerified = switch (session) {
        SignUpIncompleteSession(:final emailVerified) => emailVerified,
        SignedOutSession() => false,
        // A profile exists, so the address was confirmed before it.
        _ => true,
      };
      if (isVerified) unawaited(_analytics.logEmailVerified());
      emit(
        EmailVerificationCheckSuccess(session: session, isVerified: isVerified),
      );
    } on Object catch (e) {
      emit(
        EmailVerificationCheckFailure(
          session: state.session,
          error: _appErrorOf(e),
        ),
      );
    }
  }

  Future<void> _onVerificationEmailResendRequested(
    VerificationEmailResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(VerificationEmailResendInProgress(session: state.session));
    try {
      await _requireInternet();
      await _auth.resendVerificationEmail();
      emit(VerificationEmailResendSuccess(session: state.session));
    } on Object catch (e) {
      emit(
        VerificationEmailResendFailure(
          session: state.session,
          error: _appErrorOf(e),
        ),
      );
    }
  }

  /// No connectivity check: the device copy is what switches the app.
  Future<void> _onLanguageChangeRequested(
    LanguageChangeRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _auth.changeLanguage(event.language, session: state.session);
      unawaited(_analytics.logLanguageChanged(event.language));
      emit(
        LanguageChangeSuccess(session: state.session, language: event.language),
      );
    } on Object catch (e) {
      emit(
        LanguageChangeFailure(session: state.session, error: _appErrorOf(e)),
      );
    }
  }

  Future<void> _requireInternet() async {
    if (!await _internet.check()) throw AppError.noInternet;
  }

  /// Side effects of having a user: none of them may fail the sign-in.
  void _afterSignIn(AuthSession session) {
    final uid = _auth.currentUid;
    if (uid == null) return;
    unawaited(_rasp.bindUser(uid));
    unawaited(_analytics.setRole(_roleOf(session)));
    unawaited(_registerDevice(session));
  }

  Future<void> _registerDevice(AuthSession session) async {
    try {
      await _auth.registerDeviceToken(session);
    } on Object catch (_) {
      // Retried on the next sign-in or token refresh.
    }
  }

  static Role? _roleOf(AuthSession session) => switch (session) {
    PatientSession(:final roles) ||
    PractitionerSession(:final roles) => roles.role,
    _ => null,
  };

  /// The data layer throws [AppError]; anything else is unexpected and shows
  /// the generic message.
  static AppError _appErrorOf(Object e) => e is AppError ? e : AppError.unknown;

  @override
  Future<void> close() async {
    await _tokenRefreshes.cancel();
    await super.close();
  }
}
