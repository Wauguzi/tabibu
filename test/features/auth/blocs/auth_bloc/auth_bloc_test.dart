import 'dart:async';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/auth_helper.dart';
import 'package:tabibu/core/helpers/notifications_helper.dart';
import 'package:tabibu/core/helpers/role_helper.dart';
import 'package:tabibu/core/services/analytics_service.dart';
import 'package:tabibu/core/services/internet_service.dart';
import 'package:tabibu/core/services/notification_service.dart';
import 'package:tabibu/core/services/rasp_service.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/data/models/sign_up_draft.dart';
import 'package:tabibu/features/auth/data/models/sign_up_requests.dart';
import 'package:tabibu/features/auth/data/models/upload_file.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';

class _MockAuthHelper extends Mock implements AuthHelper {}

class _MockInternet extends Mock implements InternetService {}

class _MockAnalytics extends Mock implements AnalyticsService {}

class _MockNotices extends Mock implements NotificationsHelper {}

class _MockNotifications extends Mock implements NotificationService {}

class _MockRasp extends Mock implements RaspService {}

final _patient = PatientSession(
  patient: PatientModel.empty(),
  roles: RoleHelper.fromClaims(const {'role': 'patient'}),
);
final _pending = PendingVerificationSession(doctor: DoctorModel.empty());
final _photo = UploadFile(bytes: Uint8List(1), contentType: 'image/jpeg');

const _patientDraft = SignUpDraft(
  role: Role.patient,
  firstName: 'Amina',
  lastName: 'Otieno',
  sex: Sex.female,
  dateOfBirth: '1990-05-14',
  phoneNumber: '0712345678',
  countyId: 47,
);

final _doctorDraft = SignUpDraft(
  role: Role.doctor,
  title: PractitionerTitle.dr,
  firstName: 'Juma',
  lastName: 'Mwangi',
  phoneNumber: '0712345678',
  specialties: const [Specialty.oncology],
  kmpdcNumber: 'A1234',
  licenses: [_photo],
  picture: _photo,
  facilityId: 'f1',
  termsAccepted: true,
);

void main() {
  late _MockAuthHelper auth;
  late _MockInternet internet;
  late _MockAnalytics analytics;
  late _MockNotices notices;
  late _MockNotifications notifications;
  late _MockRasp rasp;
  late StreamController<String> tokenRefreshes;

  AuthBloc build() => AuthBloc(
    authHelper: auth,
    internetService: internet,
    analyticsService: analytics,
    notificationsHelper: notices,
    notificationService: notifications,
    raspService: rasp,
  );

  setUpAll(() {
    registerFallbackValue(const SignedOutSession());
    registerFallbackValue(SignInMethod.email);
    registerFallbackValue(Role.patient);
    registerFallbackValue(AppLanguage.en);
    registerFallbackValue(_photo);
    registerFallbackValue(_patientDraft.toPatientRequest());
    registerFallbackValue(
      _doctorDraft.toPractitionerRequest(pictureUrl: 'p', licenseUrls: ['l']),
    );
  });

  setUp(() {
    auth = _MockAuthHelper();
    internet = _MockInternet();
    analytics = _MockAnalytics();
    notices = _MockNotices();
    notifications = _MockNotifications();
    rasp = _MockRasp();
    tokenRefreshes = StreamController<String>.broadcast();

    when(
      () => notifications.tokenRefreshes,
    ).thenAnswer((_) => tokenRefreshes.stream);
    when(() => internet.check()).thenAnswer((_) async => true);
    when(() => auth.currentUid).thenReturn('u1');
    when(() => auth.registerDeviceToken(any())).thenAnswer((_) async {});
    when(() => rasp.bindUser(any())).thenAnswer((_) async {});
    when(() => analytics.setRole(any())).thenAnswer((_) async {});
    when(() => analytics.logLogin(any())).thenAnswer((_) async {});
    when(() => analytics.logSignUp(any())).thenAnswer((_) async {});
    when(() => analytics.logSignOut()).thenAnswer((_) async {});
    when(() => analytics.logCompleteSignUp(any())).thenAnswer((_) async {});
    when(() => analytics.logPasswordResetRequested()).thenAnswer((_) async {});
    when(() => analytics.logLanguageChanged(any())).thenAnswer((_) async {});
    when(() => notices.notifyPatientRegistered()).thenAnswer((_) async {});
    when(() => notices.notifyLicenceReceived()).thenAnswer((_) async {});
  });

  tearDown(() => tokenRefreshes.close());

  group('SessionRequested', () {
    blocTest<AuthBloc, AuthState>(
      'resolves the session and ties the device to the user',
      setUp: () => when(
        () => auth.resolveSession(forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer((_) async => _patient),
      build: build,
      act: (bloc) => bloc.add(const SessionRequested()),
      expect: () => [
        const SessionLoadInProgress(session: SignedOutSession()),
        SessionLoadSuccess(session: _patient),
      ],
      verify: (_) {
        verify(() => rasp.bindUser('u1')).called(1);
        verify(() => analytics.setRole(Role.patient)).called(1);
        verify(() => auth.registerDeviceToken(_patient)).called(1);
        verifyNever(() => internet.check());
      },
    );

    blocTest<AuthBloc, AuthState>(
      'an Error, not only an Exception, still ends in a failure',
      setUp: () => when(
        () => auth.resolveSession(forceRefresh: any(named: 'forceRefresh')),
      ).thenThrow(StateError('boom')),
      build: build,
      act: (bloc) => bloc.add(const SessionRequested()),
      expect: () => [
        const SessionLoadInProgress(session: SignedOutSession()),
        const SessionLoadFailure(
          session: SignedOutSession(),
          error: AppError.unknown,
        ),
      ],
    );
  });

  group('SignInRequested', () {
    blocTest<AuthBloc, AuthState>(
      'offline fails fast without calling Firebase',
      setUp: () => when(() => internet.check()).thenAnswer((_) async => false),
      build: build,
      act: (bloc) => bloc.add(
        const SignInRequested(email: 'a@example.com', password: 'secret'),
      ),
      expect: () => [
        const SignInInProgress(session: SignedOutSession()),
        const SignInFailure(
          session: SignedOutSession(),
          error: AppError.noInternet,
        ),
      ],
      verify: (_) => verifyNever(
        () => auth.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ),
    );

    blocTest<AuthBloc, AuthState>(
      'signs in once however often it is tapped',
      setUp: () => when(
        () => auth.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => _patient),
      build: build,
      act: (bloc) => bloc
        ..add(const SignInRequested(email: 'a@example.com', password: 's'))
        ..add(const SignInRequested(email: 'a@example.com', password: 's')),
      expect: () => [
        const SignInInProgress(session: SignedOutSession()),
        SignInSuccess(session: _patient),
      ],
      verify: (_) {
        verify(
          () => auth.signInWithEmail(email: 'a@example.com', password: 's'),
        ).called(1);
        verify(() => analytics.logLogin(SignInMethod.email)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'a wrong password is a typed failure',
      setUp: () => when(
        () => auth.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(AppError.invalidCredential),
      build: build,
      act: (bloc) => bloc.add(
        const SignInRequested(email: 'a@example.com', password: 'x'),
      ),
      expect: () => [
        const SignInInProgress(session: SignedOutSession()),
        const SignInFailure(
          session: SignedOutSession(),
          error: AppError.invalidCredential,
        ),
      ],
    );

    test('never prints the password', () {
      expect(
        const SignInRequested(
          email: 'a@example.com',
          password: 'secret',
        ).toString(),
        isNot(contains('secret')),
      );
      expect(
        const CreateAccountRequested(
          email: 'a@example.com',
          password: 'secret',
        ).toString(),
        isNot(contains('secret')),
      );
    });
  });

  blocTest<AuthBloc, AuthState>(
    'a dismissed Google dialog is cancelled, not failed',
    setUp: () =>
        when(() => auth.signInWithGoogle()).thenAnswer((_) async => null),
    build: build,
    act: (bloc) => bloc.add(const GoogleSignInRequested()),
    expect: () => [
      const SignInInProgress(session: SignedOutSession()),
      const SignInCancelled(session: SignedOutSession()),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'a reset for an unknown address looks like any other',
    setUp: () => when(
      () => auth.sendPasswordReset(email: any(named: 'email')),
    ).thenThrow(AppError.userNotFound),
    build: build,
    act: (bloc) =>
        bloc.add(const PasswordResetRequested(email: 'x@example.com')),
    expect: () => [
      const PasswordResetInProgress(session: SignedOutSession()),
      const PasswordResetSuccess(session: SignedOutSession()),
    ],
  );

  group('PatientSignUpRequested', () {
    blocTest<AuthBloc, AuthState>(
      'an incomplete draft fails before any network call',
      build: build,
      act: (bloc) => bloc.add(
        PatientSignUpRequested(draft: _patientDraft.copyWith(countyId: null)),
      ),
      expect: () => [
        const SignUpInProgress(session: SignedOutSession()),
        const SignUpFailure(
          session: SignedOutSession(),
          error: AppError.invalidCounty,
        ),
      ],
      verify: (_) => verifyNever(() => internet.check()),
    );

    blocTest<AuthBloc, AuthState>(
      'a registered patient is welcomed',
      setUp: () => when(
        () => auth.completePatientSignUp(any()),
      ).thenAnswer((_) async => _patient),
      build: build,
      act: (bloc) =>
          bloc.add(const PatientSignUpRequested(draft: _patientDraft)),
      expect: () => [
        const SignUpInProgress(session: SignedOutSession()),
        SignUpSuccess(session: _patient),
      ],
      verify: (_) {
        verify(() => notices.notifyPatientRegistered()).called(1);
        verify(() => analytics.logCompleteSignUp(Role.patient)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'a clinic-record match is not welcomed (T-15)',
      setUp: () => when(
        () => auth.completePatientSignUp(any()),
      ).thenAnswer((_) async => const ClinicRecordExistsSession()),
      build: build,
      act: (bloc) =>
          bloc.add(const PatientSignUpRequested(draft: _patientDraft)),
      expect: () => [
        const SignUpInProgress(session: SignedOutSession()),
        const SignUpSuccess(session: ClinicRecordExistsSession()),
      ],
      verify: (_) => verifyNever(() => notices.notifyPatientRegistered()),
    );
  });

  blocTest<AuthBloc, AuthState>(
    'a practitioner uploads, then submits the URLs',
    setUp: () {
      when(
        () => auth.uploadSignUpFiles(
          picture: any(named: 'picture'),
          licenses: any(named: 'licenses'),
        ),
      ).thenAnswer((_) async => (pictureUrl: 'photo', licenseUrls: ['scan']));
      when(
        () => auth.completePractitionerSignUp(any()),
      ).thenAnswer((_) async => _pending);
    },
    build: build,
    act: (bloc) => bloc.add(PractitionerSignUpRequested(draft: _doctorDraft)),
    expect: () => [
      const SignUpInProgress(session: SignedOutSession()),
      SignUpSuccess(session: _pending),
    ],
    verify: (_) {
      final request =
          verify(
                () => auth.completePractitionerSignUp(captureAny()),
              ).captured.single
              as PractitionerSignUpRequest;
      expect(request.profilePictureUrl, 'photo');
      expect(request.licenseUrls, ['scan']);
      verify(() => notices.notifyLicenceReceived()).called(1);
      verify(() => analytics.logCompleteSignUp(Role.doctor)).called(1);
    },
  );

  blocTest<AuthBloc, AuthState>(
    'signs out offline, handing the session over for its token',
    setUp: () {
      when(() => internet.check()).thenAnswer((_) async => false);
      when(
        () => auth.signOut(session: any(named: 'session')),
      ).thenAnswer((_) async {});
    },
    build: build,
    seed: () => SignInSuccess(session: _patient),
    act: (bloc) => bloc.add(const SignOutRequested()),
    expect: () => [
      SignOutInProgress(session: _patient),
      const SignOutSuccess(),
    ],
    verify: (_) {
      verify(() => auth.signOut(session: _patient)).called(1);
      verify(() => analytics.setRole(null)).called(1);
    },
  );

  blocTest<AuthBloc, AuthState>(
    'a rotated push token reaches the current profile',
    build: build,
    seed: () => SignInSuccess(session: _patient),
    act: (_) => tokenRefreshes.add('rotated'),
    verify: (_) => verify(() => auth.registerDeviceToken(_patient)).called(1),
  );

  blocTest<AuthBloc, AuthState>(
    'a language change switches the app even offline',
    setUp: () {
      when(() => internet.check()).thenAnswer((_) async => false);
      when(
        () => auth.changeLanguage(any(), session: any(named: 'session')),
      ).thenAnswer((_) async {});
    },
    build: build,
    seed: () => SignInSuccess(session: _patient),
    act: (bloc) =>
        bloc.add(const LanguageChangeRequested(language: AppLanguage.sw)),
    expect: () => [
      LanguageChangeSuccess(session: _patient, language: AppLanguage.sw),
    ],
    verify: (_) => verify(
      () => auth.changeLanguage(AppLanguage.sw, session: _patient),
    ).called(1),
  );
}
