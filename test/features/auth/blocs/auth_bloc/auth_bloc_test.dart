import 'dart:async';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/auth_helper.dart';
import 'package:tabibu/core/helpers/facilities_helper.dart';
import 'package:tabibu/core/helpers/notifications_helper.dart';
import 'package:tabibu/core/helpers/role_helper.dart';
import 'package:tabibu/core/services/analytics_service.dart';
import 'package:tabibu/core/services/internet_service.dart';
import 'package:tabibu/core/services/notification_service.dart';
import 'package:tabibu/core/services/rasp_service.dart';
import 'package:tabibu/features/alerts/data/datasources/alert_topic_service.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/data/models/sign_up_draft.dart';
import 'package:tabibu/features/auth/data/models/sign_up_requests.dart';
import 'package:tabibu/features/auth/data/models/upload_file.dart';
import 'package:tabibu/features/facilities/data/models/county_model.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';

class _MockAuthHelper extends Mock implements AuthHelper {}

class _MockInternet extends Mock implements InternetService {}

class _MockAnalytics extends Mock implements AnalyticsService {}

class _MockNotices extends Mock implements NotificationsHelper {}

class _MockNotifications extends Mock implements NotificationService {}

class _MockRasp extends Mock implements RaspService {}

class _MockAlertTopics extends Mock implements AlertTopicService {}

class _MockFacilities extends Mock implements FacilitiesHelper {}

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
  late _MockAlertTopics topics;
  late _MockFacilities facilities;
  late StreamController<String> tokenRefreshes;

  AuthBloc build() => AuthBloc(
    authHelper: auth,
    internetService: internet,
    analyticsService: analytics,
    notificationsHelper: notices,
    notificationService: notifications,
    raspService: rasp,
    alertTopicService: topics,
    facilitiesHelper: facilities,
  );

  setUpAll(() {
    registerFallbackValue(const SignedOutSession());
    registerFallbackValue(SignInMethod.email);
    registerFallbackValue(Role.patient);
    registerFallbackValue(AppLanguage.en);
    registerFallbackValue(ProfileSetting.healthNotices);
    registerFallbackValue(_photo);
    registerFallbackValue(<String>[]);
    registerFallbackValue(<int>[]);
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
    topics = _MockAlertTopics();
    facilities = _MockFacilities();
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
    when(
      () =>
          analytics.logProfileSettingChanged(any(), value: any(named: 'value')),
    ).thenAnswer((_) async {});
    when(() => notices.notifyPatientRegistered()).thenAnswer((_) async {});
    when(() => notices.notifyLicenceReceived()).thenAnswer((_) async {});
    when(() => notices.notifyWelcomeBack()).thenAnswer((_) async {});
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
        verify(() => notices.notifyWelcomeBack()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'patient with notices on joins the area topic once on sign-in',
      setUp: () {
        final session = PatientSession(
          patient: PatientModel.empty().copyWith(
            county: 'Nairobi',
            language: 'sw',
            receiveNotifications: true,
          ),
          roles: RoleHelper.fromClaims(const {'role': 'patient'}),
        );
        when(
          () => auth.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => session);
        when(
          () => facilities.counties(),
        ).thenAnswer((_) async => [const CountyModel(id: 47, name: 'Nairobi')]);
        when(
          () => topics.syncSubscription(
            topic: any(named: 'topic'),
            receiveNotifications: any(named: 'receiveNotifications'),
          ),
        ).thenAnswer((_) async {});
      },
      build: build,
      act: (bloc) => bloc.add(
        const SignInRequested(email: 'a@example.com', password: 's'),
      ),
      wait: const Duration(milliseconds: 50),
      verify: (_) => verify(
        () => topics.syncSubscription(
          topic: 'alerts_patient_47_sw',
          receiveNotifications: true,
        ),
      ).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'patient with notices off does not join a topic on sign-in',
      setUp: () {
        when(
          () => auth.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => _patient);
        when(
          () => topics.syncSubscription(
            topic: any(named: 'topic'),
            receiveNotifications: any(named: 'receiveNotifications'),
          ),
        ).thenAnswer((_) async {});
      },
      build: build,
      act: (bloc) => bloc.add(
        const SignInRequested(email: 'a@example.com', password: 's'),
      ),
      wait: const Duration(milliseconds: 50),
      verify: (_) => verifyNever(
        () => topics.syncSubscription(
          topic: any(named: 'topic'),
          receiveNotifications: any(named: 'receiveNotifications'),
        ),
      ),
    );

    blocTest<AuthBloc, AuthState>(
      'a thrown topic subscribe does not fail the sign-in',
      setUp: () {
        final session = PatientSession(
          patient: PatientModel.empty().copyWith(
            county: 'Nairobi',
            language: 'sw',
            receiveNotifications: true,
          ),
          roles: RoleHelper.fromClaims(const {'role': 'patient'}),
        );
        when(
          () => auth.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => session);
        when(
          () => facilities.counties(),
        ).thenAnswer((_) async => [const CountyModel(id: 47, name: 'Nairobi')]);
        when(
          () => topics.syncSubscription(
            topic: any(named: 'topic'),
            receiveNotifications: any(named: 'receiveNotifications'),
          ),
        ).thenThrow(Exception('topic'));
      },
      build: build,
      act: (bloc) => bloc.add(
        const SignInRequested(email: 'a@example.com', password: 's'),
      ),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        const SignInInProgress(session: SignedOutSession()),
        isA<SignInSuccess>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'doctor with notices on joins the area topic on sign-in',
      setUp: () {
        final session = PractitionerSession(
          doctor: DoctorModel.empty().copyWith(
            county: 'Nairobi',
            language: 'en',
            receiveNotifications: true,
          ),
          roles: RoleHelper.fromClaims(const {'role': 'doctor'}),
        );
        when(
          () => auth.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => session);
        when(
          () => facilities.counties(),
        ).thenAnswer((_) async => [const CountyModel(id: 47, name: 'Nairobi')]);
        when(
          () => topics.syncSubscription(
            topic: any(named: 'topic'),
            receiveNotifications: any(named: 'receiveNotifications'),
          ),
        ).thenAnswer((_) async {});
      },
      build: build,
      act: (bloc) => bloc.add(
        const SignInRequested(email: 'a@example.com', password: 's'),
      ),
      wait: const Duration(milliseconds: 50),
      verify: (_) => verify(
        () => topics.syncSubscription(
          topic: 'alerts_patient_47_en',
          receiveNotifications: true,
        ),
      ).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'no welcome back while a licence is pending',
      setUp: () => when(
        () => auth.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => _pending),
      build: build,
      act: (bloc) => bloc.add(
        const SignInRequested(email: 'a@example.com', password: 's'),
      ),
      expect: () => [
        const SignInInProgress(session: SignedOutSession()),
        SignInSuccess(session: _pending),
      ],
      verify: (_) => verifyNever(() => notices.notifyWelcomeBack()),
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

  group('a session read and a sign-out side by side', () {
    late Completer<AuthSession> read;

    blocTest<AuthBloc, AuthState>(
      'a read that answers after the sign-out is dropped',
      setUp: () {
        read = Completer<AuthSession>();
        when(
          () => auth.resolveSession(forceRefresh: any(named: 'forceRefresh')),
        ).thenAnswer((_) => read.future);
        when(
          () => auth.signOut(session: any(named: 'session')),
        ).thenAnswer((_) async {});
      },
      build: build,
      act: (bloc) async {
        bloc.add(const SessionRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const SignOutRequested());
        await Future<void>.delayed(Duration.zero);
        read.complete(_patient);
      },
      wait: const Duration(milliseconds: 50),
      expect: () => [
        const SessionLoadInProgress(session: SignedOutSession()),
        const SignOutInProgress(session: SignedOutSession()),
        const SignOutSuccess(),
      ],
      verify: (_) => verifyNever(() => auth.registerDeviceToken(any())),
    );
  });

  blocTest<AuthBloc, AuthState>(
    'an account created but not read back stays signed in',
    setUp: () {
      when(() => internet.check()).thenAnswer((_) async => true);
      when(() => auth.currentUid).thenReturn('u1');
      when(
        () => auth.createAccount(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(AppError.serviceUnavailable);
    },
    build: build,
    act: (bloc) => bloc.add(
      const CreateAccountRequested(email: ' a@b.co ', password: 'Str0ng!pass'),
    ),
    expect: () => [
      const CreateAccountInProgress(session: SignedOutSession()),
      const CreateAccountFailure(
        session: SignUpIncompleteSession(email: 'a@b.co'),
        error: AppError.serviceUnavailable,
      ),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'a Google sign-in welcomes the person back',
    setUp: () =>
        when(() => auth.signInWithGoogle()).thenAnswer((_) async => _patient),
    build: build,
    act: (bloc) => bloc.add(const GoogleSignInRequested()),
    expect: () => [
      const SignInInProgress(session: SignedOutSession()),
      SignInSuccess(session: _patient),
    ],
    verify: (_) => verify(() => notices.notifyWelcomeBack()).called(1),
  );

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
      'the optional photo is added after the record exists',
      setUp: () {
        when(
          () => auth.completePatientSignUp(any()),
        ).thenAnswer((_) async => _patient);
        when(() => auth.addPatientPicture(_patient, _photo)).thenAnswer(
          (_) async => PatientSession(
            patient: _patient.patient.copyWith(profilePictureUrl: 'photo'),
            roles: _patient.roles,
          ),
        );
      },
      build: build,
      act: (bloc) => bloc.add(
        PatientSignUpRequested(draft: _patientDraft.copyWith(picture: _photo)),
      ),
      expect: () => [
        const SignUpInProgress(session: SignedOutSession()),
        isA<SignUpSuccess>().having(
          (s) => (s.session as PatientSession).patient.profilePictureUrl,
          'photo',
          'photo',
        ),
      ],
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
      when(() => topics.unsubscribeBeforeSignOut()).thenAnswer((_) async {});
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
      verify(() => topics.unsubscribeBeforeSignOut()).called(1);
      verify(() => auth.signOut(session: _patient)).called(1);
      verify(() => analytics.setRole(null)).called(1);
    },
  );

  blocTest<AuthBloc, AuthState>(
    'sign-out still finishes when topic unsubscribe throws',
    setUp: () {
      when(
        () => topics.unsubscribeBeforeSignOut(),
      ).thenThrow(Exception('topic'));
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
      verify(() => topics.unsubscribeBeforeSignOut()).called(1);
      verify(() => auth.signOut(session: _patient)).called(1);
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

  group('email verification', () {
    setUp(
      () => when(() => analytics.logEmailVerified()).thenAnswer((_) async {}),
    );

    const unverified = SignUpIncompleteSession(email: 'a@example.com');
    const verified = SignUpIncompleteSession(
      email: 'a@example.com',
      emailVerified: true,
    );

    blocTest<AuthBloc, AuthState>(
      'a confirmed address resolves the next session',
      setUp: () => when(
        () => auth.checkEmailVerified(),
      ).thenAnswer((_) async => verified),
      build: build,
      seed: () => const CreateAccountSuccess(session: unverified),
      act: (bloc) => bloc.add(const EmailVerificationCheckRequested()),
      expect: () => [
        const EmailVerificationCheckInProgress(session: unverified),
        const EmailVerificationCheckSuccess(
          session: verified,
          isVerified: true,
        ),
      ],
      verify: (_) => verify(() => analytics.logEmailVerified()).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'not yet confirmed is a success that says so, not an error',
      setUp: () => when(
        () => auth.checkEmailVerified(),
      ).thenAnswer((_) async => unverified),
      build: build,
      seed: () => const CreateAccountSuccess(session: unverified),
      act: (bloc) => bloc.add(const EmailVerificationCheckRequested()),
      expect: () => [
        const EmailVerificationCheckInProgress(session: unverified),
        const EmailVerificationCheckSuccess(
          session: unverified,
          isVerified: false,
        ),
      ],
      verify: (_) => verifyNever(() => analytics.logEmailVerified()),
    );

    blocTest<AuthBloc, AuthState>(
      'offline, the check fails fast',
      setUp: () => when(() => internet.check()).thenAnswer((_) async => false),
      build: build,
      seed: () => const CreateAccountSuccess(session: unverified),
      act: (bloc) => bloc.add(const EmailVerificationCheckRequested()),
      expect: () => [
        const EmailVerificationCheckInProgress(session: unverified),
        const EmailVerificationCheckFailure(
          session: unverified,
          error: AppError.noInternet,
        ),
      ],
      verify: (_) => verifyNever(() => auth.checkEmailVerified()),
    );

    blocTest<AuthBloc, AuthState>(
      'a resend reports success, and a refusal as a typed failure',
      setUp: () {
        var calls = 0;
        when(() => auth.resendVerificationEmail()).thenAnswer((_) async {
          if (calls++ > 0) throw AppError.tooManyRequests;
        });
      },
      build: build,
      seed: () => const CreateAccountSuccess(session: unverified),
      act: (bloc) async {
        bloc.add(const VerificationEmailResendRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const VerificationEmailResendRequested());
      },
      expect: () => [
        const VerificationEmailResendInProgress(session: unverified),
        const VerificationEmailResendSuccess(session: unverified),
        const VerificationEmailResendInProgress(session: unverified),
        const VerificationEmailResendFailure(
          session: unverified,
          error: AppError.tooManyRequests,
        ),
      ],
    );
  });

  group('ProfileSettingChanged', () {
    final nairobi = PatientSession(
      patient: PatientModel.empty().copyWith(
        patientId: 'p1',
        county: 'Nairobi',
        language: 'sw',
        firstName: 'Amina',
      ),
      roles: RoleHelper.fromClaims(const {'role': 'patient'}),
    );
    final doctor = PractitionerSession(
      doctor: DoctorModel.empty().copyWith(
        uid: 'd1',
        county: 'Nairobi',
        language: 'en',
        isAvailable: true,
      ),
      roles: RoleHelper.fromClaims(const {'role': 'doctor'}),
    );

    setUp(() {
      when(
        () => auth.updateProfileSetting(
          setting: any(named: 'setting'),
          value: any(named: 'value'),
          session: any(named: 'session'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => facilities.counties(),
      ).thenAnswer((_) async => [const CountyModel(id: 47, name: 'Nairobi')]);
      when(
        () => topics.syncSubscription(
          topic: any(named: 'topic'),
          receiveNotifications: any(named: 'receiveNotifications'),
        ),
      ).thenAnswer((_) async {});
    });

    blocTest<AuthBloc, AuthState>(
      'Health notices flip the session and join the area topic',
      build: build,
      seed: () => SignInSuccess(session: nairobi),
      act: (bloc) => bloc.add(
        const ProfileSettingChanged(
          setting: ProfileSetting.healthNotices,
          value: true,
        ),
      ),
      expect: () => [
        ProfileSettingChangeInProgress(session: nairobi),
        ProfileSettingChangeSuccess(
          session: PatientSession(
            patient: nairobi.patient.copyWith(receiveNotifications: true),
            roles: nairobi.roles,
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => auth.updateProfileSetting(
            setting: ProfileSetting.healthNotices,
            value: true,
            session: nairobi,
          ),
        ).called(1);
        verify(
          () => analytics.logProfileSettingChanged(
            ProfileSetting.healthNotices,
            value: true,
          ),
        ).called(1);
        verify(
          () => topics.syncSubscription(
            topic: 'alerts_patient_47_sw',
            receiveNotifications: true,
          ),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      "a doctor's switch keeps every other session field",
      build: build,
      seed: () => SignInSuccess(session: doctor),
      act: (bloc) => bloc.add(
        const ProfileSettingChanged(
          setting: ProfileSetting.healthNotices,
          value: false,
        ),
      ),
      expect: () => [
        ProfileSettingChangeInProgress(session: doctor),
        ProfileSettingChangeSuccess(
          session: PractitionerSession(
            doctor: doctor.doctor.copyWith(receiveNotifications: false),
            roles: doctor.roles,
          ),
        ),
      ],
      verify: (_) => verify(
        () => topics.syncSubscription(
          topic: 'alerts_patient_47_en',
          receiveNotifications: false,
        ),
      ).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'Accept cases writes but never touches the alert topic',
      build: build,
      seed: () => SignInSuccess(session: doctor),
      act: (bloc) => bloc.add(
        const ProfileSettingChanged(
          setting: ProfileSetting.acceptCases,
          value: false,
        ),
      ),
      expect: () => [
        ProfileSettingChangeInProgress(session: doctor),
        ProfileSettingChangeSuccess(
          session: PractitionerSession(
            doctor: doctor.doctor.copyWith(isAvailable: false),
            roles: doctor.roles,
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => auth.updateProfileSetting(
            setting: ProfileSetting.acceptCases,
            value: false,
            session: doctor,
          ),
        ).called(1);
        verifyNever(
          () => topics.syncSubscription(
            topic: any(named: 'topic'),
            receiveNotifications: any(named: 'receiveNotifications'),
          ),
        );
      },
    );

    blocTest<AuthBloc, AuthState>(
      'offline, the switch stays where it was and nothing is written',
      setUp: () => when(() => internet.check()).thenAnswer((_) async => false),
      build: build,
      seed: () => SignInSuccess(session: nairobi),
      act: (bloc) => bloc.add(
        const ProfileSettingChanged(
          setting: ProfileSetting.healthNotices,
          value: true,
        ),
      ),
      expect: () => [
        ProfileSettingChangeInProgress(session: nairobi),
        ProfileSettingChangeFailure(
          session: nairobi,
          error: AppError.noInternet,
        ),
      ],
      verify: (_) {
        verifyNever(
          () => auth.updateProfileSetting(
            setting: any(named: 'setting'),
            value: any(named: 'value'),
            session: any(named: 'session'),
          ),
        );
        verifyNever(
          () => topics.syncSubscription(
            topic: any(named: 'topic'),
            receiveNotifications: any(named: 'receiveNotifications'),
          ),
        );
      },
    );

    blocTest<AuthBloc, AuthState>(
      'a failed write keeps the old value and skips the topic',
      setUp: () => when(
        () => auth.updateProfileSetting(
          setting: any(named: 'setting'),
          value: any(named: 'value'),
          session: any(named: 'session'),
        ),
      ).thenThrow(AppError.unknown),
      build: build,
      seed: () => SignInSuccess(session: nairobi),
      act: (bloc) => bloc.add(
        const ProfileSettingChanged(
          setting: ProfileSetting.healthNotices,
          value: true,
        ),
      ),
      expect: () => [
        ProfileSettingChangeInProgress(session: nairobi),
        ProfileSettingChangeFailure(session: nairobi, error: AppError.unknown),
      ],
      verify: (_) => verifyNever(
        () => topics.syncSubscription(
          topic: any(named: 'topic'),
          receiveNotifications: any(named: 'receiveNotifications'),
        ),
      ),
    );

    blocTest<AuthBloc, AuthState>(
      'a double tap writes once',
      setUp: () {
        final gate = Completer<void>();
        when(
          () => auth.updateProfileSetting(
            setting: any(named: 'setting'),
            value: any(named: 'value'),
            session: any(named: 'session'),
          ),
        ).thenAnswer((_) => gate.future);
        Future<void>.delayed(const Duration(milliseconds: 20), gate.complete);
      },
      build: build,
      seed: () => SignInSuccess(session: doctor),
      act: (bloc) {
        const flip = ProfileSettingChanged(
          setting: ProfileSetting.acceptCases,
          value: false,
        );
        bloc
          ..add(flip)
          ..add(flip);
      },
      wait: const Duration(milliseconds: 50),
      expect: () => [
        ProfileSettingChangeInProgress(session: doctor),
        ProfileSettingChangeSuccess(
          session: PractitionerSession(
            doctor: doctor.doctor.copyWith(isAvailable: false),
            roles: doctor.roles,
          ),
        ),
      ],
      verify: (_) => verify(
        () => auth.updateProfileSetting(
          setting: any(named: 'setting'),
          value: any(named: 'value'),
          session: any(named: 'session'),
        ),
      ).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'a topic failure still confirms the write that landed',
      setUp: () => when(
        () => topics.syncSubscription(
          topic: any(named: 'topic'),
          receiveNotifications: any(named: 'receiveNotifications'),
        ),
      ).thenThrow(AppError.unknown),
      build: build,
      seed: () => SignInSuccess(session: nairobi),
      act: (bloc) => bloc.add(
        const ProfileSettingChanged(
          setting: ProfileSetting.healthNotices,
          value: true,
        ),
      ),
      expect: () => [
        ProfileSettingChangeInProgress(session: nairobi),
        ProfileSettingChangeSuccess(
          session: PatientSession(
            patient: nairobi.patient.copyWith(receiveNotifications: true),
            roles: nairobi.roles,
          ),
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      "a patient has no practitioner's switch to flip",
      build: build,
      seed: () => SignInSuccess(session: nairobi),
      act: (bloc) => bloc.add(
        const ProfileSettingChanged(
          setting: ProfileSetting.acceptCases,
          value: true,
        ),
      ),
      expect: () => <AuthState>[],
      verify: (_) => verifyNever(
        () => auth.updateProfileSetting(
          setting: any(named: 'setting'),
          value: any(named: 'value'),
          session: any(named: 'session'),
        ),
      ),
    );

    blocTest<AuthBloc, AuthState>(
      'a pending licence owns no switches yet',
      build: build,
      seed: () => SignUpSuccess(session: _pending),
      act: (bloc) => bloc.add(
        const ProfileSettingChanged(
          setting: ProfileSetting.healthNotices,
          value: true,
        ),
      ),
      expect: () => <AuthState>[],
    );
  });

  group('PatientProfileChanged', () {
    final session = PatientSession(
      patient: PatientModel.empty().copyWith(
        patientId: 'p1',
        firstName: 'Amina',
        profilePictureUrl: 'old',
      ),
      roles: RoleHelper.fromClaims(const {'role': 'patient'}),
    );

    blocTest<AuthBloc, AuthState>(
      'a save lands and carries the new values',
      setUp: () =>
          when(
            () => auth.updatePatientProfile(
              firstName: 'Amina',
              middleName: 'Wanjiru',
              lastName: 'Kamau',
              phoneNumber: '+254712345678',
              session: session,
            ),
          ).thenAnswer((_) async {
            return null;
          }),
      build: build,
      seed: () => SignInSuccess(session: session),
      act: (bloc) => bloc.add(
        const PatientProfileChanged(
          firstName: 'Amina',
          middleName: 'Wanjiru',
          lastName: 'Kamau',
          phoneNumber: '+254712345678',
        ),
      ),
      expect: () => [
        ProfileSaveInProgress(session: session),
        ProfileSaveSuccess(
          session: PatientSession(
            patient: session.patient.copyWith(
              firstName: 'Amina',
              middleName: 'Wanjiru',
              lastName: 'Kamau',
              phoneNumber: '+254712345678',
            ),
            roles: session.roles,
          ),
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'a new photo lands in the session',
      setUp: () => when(
        () => auth.updatePatientProfile(
          firstName: any(named: 'firstName'),
          middleName: any(named: 'middleName'),
          lastName: any(named: 'lastName'),
          phoneNumber: any(named: 'phoneNumber'),
          session: any(named: 'session'),
          picture: _photo,
        ),
      ).thenAnswer((_) async => 'new'),
      build: build,
      seed: () => SignInSuccess(session: session),
      act: (bloc) => bloc.add(
        PatientProfileChanged(
          firstName: 'Amina',
          middleName: '',
          lastName: 'Kamau',
          phoneNumber: '+254712345678',
          picture: _photo,
        ),
      ),
      expect: () => [
        ProfileSaveInProgress(session: session),
        ProfileSaveSuccess(
          session: PatientSession(
            patient: session.patient.copyWith(
              firstName: 'Amina',
              middleName: '',
              lastName: 'Kamau',
              phoneNumber: '+254712345678',
              profilePictureUrl: 'new',
            ),
            roles: session.roles,
          ),
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'offline fails with no call',
      setUp: () {
        when(() => internet.check()).thenAnswer((_) async => false);
      },
      build: build,
      seed: () => SignInSuccess(session: session),
      act: (bloc) => bloc.add(
        const PatientProfileChanged(
          firstName: 'Amina',
          middleName: '',
          lastName: 'Kamau',
          phoneNumber: '+254712345678',
        ),
      ),
      expect: () => [
        ProfileSaveInProgress(session: session),
        ProfileSaveFailure(session: session, error: AppError.noInternet),
      ],
      verify: (_) => verifyNever(
        () => auth.updatePatientProfile(
          firstName: any(named: 'firstName'),
          middleName: any(named: 'middleName'),
          lastName: any(named: 'lastName'),
          phoneNumber: any(named: 'phoneNumber'),
          session: any(named: 'session'),
        ),
      ),
    );

    blocTest<AuthBloc, AuthState>(
      'a refused save says why and keeps the session',
      setUp: () => when(
        () => auth.updatePatientProfile(
          firstName: any(named: 'firstName'),
          middleName: any(named: 'middleName'),
          lastName: any(named: 'lastName'),
          phoneNumber: any(named: 'phoneNumber'),
          session: any(named: 'session'),
        ),
      ).thenThrow(AppError.invalidPhone),
      build: build,
      seed: () => SignInSuccess(session: session),
      act: (bloc) => bloc.add(
        const PatientProfileChanged(
          firstName: 'Amina',
          middleName: '',
          lastName: 'Kamau',
          phoneNumber: 'bad',
        ),
      ),
      expect: () => [
        ProfileSaveInProgress(session: session),
        ProfileSaveFailure(session: session, error: AppError.invalidPhone),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'a practitioner owns no patient save',
      build: build,
      seed: () => SignUpSuccess(session: _pending),
      act: (bloc) => bloc.add(
        const PatientProfileChanged(
          firstName: 'Amina',
          middleName: '',
          lastName: 'Kamau',
          phoneNumber: '+254712345678',
        ),
      ),
      expect: () => <AuthState>[],
    );
  });

  group('PractitionerProfileChanged', () {
    final session = PractitionerSession(
      doctor: DoctorModel.empty().copyWith(uid: 'd1'),
      roles: RoleHelper.fromClaims(const {'role': 'doctor'}),
    );

    blocTest<AuthBloc, AuthState>(
      'a save lands and carries the new values',
      setUp: () =>
          when(
            () => auth.updatePractitionerProfile(
              specialties: const ['Breast surgery'],
              bio: 'Kind surgeon.',
              phoneNumber: '+254712345678',
              session: session,
            ),
          ).thenAnswer((_) async {
            return null;
          }),
      build: build,
      seed: () => SignInSuccess(session: session),
      act: (bloc) => bloc.add(
        const PractitionerProfileChanged(
          specialties: ['Breast surgery'],
          bio: 'Kind surgeon.',
          phoneNumber: '+254712345678',
        ),
      ),
      expect: () => [
        ProfileSaveInProgress(session: session),
        ProfileSaveSuccess(
          session: PractitionerSession(
            doctor: session.doctor.copyWith(
              specialties: const ['Breast surgery'],
              bio: 'Kind surgeon.',
              phoneNumber: '+254712345678',
            ),
            roles: session.roles,
          ),
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'offline fails with no call',
      setUp: () {
        when(() => internet.check()).thenAnswer((_) async => false);
      },
      build: build,
      seed: () => SignInSuccess(session: session),
      act: (bloc) => bloc.add(
        const PractitionerProfileChanged(
          specialties: ['Breast surgery'],
          bio: '',
          phoneNumber: '+254712345678',
        ),
      ),
      expect: () => [
        ProfileSaveInProgress(session: session),
        ProfileSaveFailure(session: session, error: AppError.noInternet),
      ],
      verify: (_) => verifyNever(
        () => auth.updatePractitionerProfile(
          specialties: any(named: 'specialties'),
          bio: any(named: 'bio'),
          phoneNumber: any(named: 'phoneNumber'),
          session: any(named: 'session'),
        ),
      ),
    );

    blocTest<AuthBloc, AuthState>(
      'a patient owns no practitioner save',
      build: build,
      seed: () => SignInSuccess(session: _patient),
      act: (bloc) => bloc.add(
        const PractitionerProfileChanged(
          specialties: ['Breast surgery'],
          bio: '',
          phoneNumber: '+254712345678',
        ),
      ),
      expect: () => <AuthState>[],
    );
  });

  group('PatientAreaChanged', () {
    final session = PatientSession(
      patient: PatientModel.empty().copyWith(
        patientId: 'p1',
        county: 'Nairobi',
        subCounty: 'Embakasi',
        language: 'sw',
        receiveNotifications: true,
      ),
      roles: RoleHelper.fromClaims(const {'role': 'patient'}),
    );

    setUp(() {
      when(
        () => auth.updatePatientArea(
          countyId: any(named: 'countyId'),
          session: any(named: 'session'),
          subCountyId: any(named: 'subCountyId'),
        ),
      ).thenAnswer((_) async => (county: 'Mombasa', subCounty: ''));
      when(() => facilities.counties()).thenAnswer(
        (_) async => [
          const CountyModel(id: 47, name: 'Nairobi'),
          const CountyModel(id: 1, name: 'Mombasa'),
        ],
      );
      when(
        () => topics.syncSubscription(
          topic: any(named: 'topic'),
          receiveNotifications: any(named: 'receiveNotifications'),
        ),
      ).thenAnswer((_) async {});
    });

    blocTest<AuthBloc, AuthState>(
      'a moved patient rejoins under the new county',
      build: build,
      seed: () => SignInSuccess(session: session),
      act: (bloc) => bloc.add(const PatientAreaChanged(countyId: 1)),
      expect: () => [
        ProfileSaveInProgress(session: session),
        ProfileSaveSuccess(
          session: PatientSession(
            patient: session.patient.copyWith(county: 'Mombasa', subCounty: ''),
            roles: session.roles,
          ),
        ),
      ],
      verify: (_) => verify(
        () => topics.syncSubscription(
          topic: AlertTopicService.topicName(countyId: 1, language: 'sw'),
          receiveNotifications: true,
        ),
      ).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'with notices off the topic is left alone',
      build: build,
      seed: () => SignInSuccess(
        session: PatientSession(
          patient: session.patient.copyWith(receiveNotifications: false),
          roles: session.roles,
        ),
      ),
      act: (bloc) => bloc.add(const PatientAreaChanged(countyId: 1)),
      expect: () => [isA<ProfileSaveInProgress>(), isA<ProfileSaveSuccess>()],
      verify: (_) => verifyNever(
        () => topics.syncSubscription(
          topic: any(named: 'topic'),
          receiveNotifications: any(named: 'receiveNotifications'),
        ),
      ),
    );

    blocTest<AuthBloc, AuthState>(
      'an unknown county refuses with the server reason',
      setUp: () => when(
        () => auth.updatePatientArea(
          countyId: any(named: 'countyId'),
          session: any(named: 'session'),
          subCountyId: any(named: 'subCountyId'),
        ),
      ).thenThrow(AppError.invalidCounty),
      build: build,
      seed: () => SignInSuccess(session: session),
      act: (bloc) => bloc.add(const PatientAreaChanged(countyId: 999)),
      expect: () => [
        ProfileSaveInProgress(session: session),
        ProfileSaveFailure(session: session, error: AppError.invalidCounty),
      ],
    );
  });

  group('ClinicHoursChanged', () {
    final session = PractitionerSession(
      doctor: DoctorModel.empty().copyWith(uid: 'd1'),
      roles: RoleHelper.fromClaims(const {'role': 'doctor'}),
    );

    blocTest<AuthBloc, AuthState>(
      'a save lands and carries the new hours',
      setUp: () => when(
        () => auth.updateClinicHours(
          workingDays: const [1, 2, 3, 4, 5],
          dayStartMinute: 540,
          dayEndMinute: 960,
          session: session,
        ),
      ).thenAnswer((_) async {}),
      build: build,
      seed: () => SignInSuccess(session: session),
      act: (bloc) => bloc.add(
        const ClinicHoursChanged(
          workingDays: [1, 2, 3, 4, 5],
          dayStartMinute: 540,
          dayEndMinute: 960,
        ),
      ),
      expect: () => [
        ProfileSaveInProgress(session: session),
        ProfileSaveSuccess(
          session: PractitionerSession(
            doctor: session.doctor.copyWith(
              workingDays: const [1, 2, 3, 4, 5],
              dayStartMinute: 540,
              dayEndMinute: 960,
            ),
            roles: session.roles,
          ),
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'offline fails with no call',
      setUp: () {
        when(() => internet.check()).thenAnswer((_) async => false);
      },
      build: build,
      seed: () => SignInSuccess(session: session),
      act: (bloc) => bloc.add(
        const ClinicHoursChanged(
          workingDays: [1, 2, 3, 4, 5],
          dayStartMinute: 540,
          dayEndMinute: 960,
        ),
      ),
      expect: () => [
        ProfileSaveInProgress(session: session),
        ProfileSaveFailure(session: session, error: AppError.noInternet),
      ],
      verify: (_) => verifyNever(
        () => auth.updateClinicHours(
          workingDays: any(named: 'workingDays'),
          dayStartMinute: any(named: 'dayStartMinute'),
          dayEndMinute: any(named: 'dayEndMinute'),
          session: any(named: 'session'),
        ),
      ),
    );

    blocTest<AuthBloc, AuthState>(
      'a patient owns no clinic hours',
      build: build,
      seed: () => SignInSuccess(session: _patient),
      act: (bloc) => bloc.add(
        const ClinicHoursChanged(
          workingDays: [1, 2, 3, 4, 5],
          dayStartMinute: 540,
          dayEndMinute: 960,
        ),
      ),
      expect: () => <AuthState>[],
    );
  });
}
