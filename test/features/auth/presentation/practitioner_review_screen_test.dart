import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/data/models/sign_up_draft.dart';
import 'package:tabibu/features/auth/data/models/upload_file.dart';
import 'package:tabibu/features/auth/presentation/practitioner_review_screen.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_bloc.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_event.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_state.dart';
import 'package:tabibu/features/facilities/data/models/facility_model.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';

import '../../../helpers/helpers.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockSignUpBloc extends MockBloc<SignUpEvent, SignUpState>
    implements SignUpBloc {}

class MockFacilitiesBloc extends MockBloc<FacilitiesEvent, FacilitiesState>
    implements FacilitiesBloc {}

const _facility = FacilityModel(
  facilityId: 'h1',
  mflCode: '13013',
  name: 'Aga Khan University Hospital',
  kephLevel: 'Level 6',
  facilityType: 'Hospital',
  owner: 'Private',
  wardId: 1,
  ward: 'Parklands',
  subCountyId: 2,
  subCounty: 'Westlands',
  countyId: 47,
  county: 'Nairobi',
  latitude: 0,
  longitude: 0,
  geohash: '',
  isLocationApproximate: false,
  isLab: false,
  operationStatus: 'Operational',
  isOperational: true,
);

final _draft = SignUpDraft(
  role: Role.doctor,
  title: PractitionerTitle.dr,
  firstName: 'Wanjiru',
  lastName: 'Kamau',
  phoneNumber: '+254722118450',
  specialties: const [Specialty.generalSurgery],
  kmpdcNumber: 'A 12345',
  licenses: [
    UploadFile(
      bytes: Uint8List.fromList(List.filled(2048, 0)),
      contentType: 'application/pdf',
      name: 'licence.pdf',
    ),
  ],
  picture: UploadFile(
    bytes: Uint8List.fromList(List.filled(128, 0)),
    contentType: 'image/jpeg',
    name: 'photo.jpg',
  ),
  facilityId: 'h1',
);

const _doctorTerms =
    'I confirm these details are true and that I hold a current practising '
    'licence.';
const _pathologistTerms =
    'I confirm these details are true. I understand AI drafts are a starting '
    'point and I am responsible for every report I sign.';

void main() {
  setUpAll(() {
    registerFallbackValue(const GoogleSignInRequested());
    registerFallbackValue(const SignUpDraftUpdated(draft: SignUpDraft()));
  });

  group('PractitionerReviewScreen', () {
    late MockAuthBloc authBloc;
    late MockSignUpBloc signUpBloc;
    late MockFacilitiesBloc facilitiesBloc;

    setUp(() {
      authBloc = MockAuthBloc();
      when(() => authBloc.state).thenReturn(
        const SignInSuccess(
          session: SignUpIncompleteSession(email: 'w.kamau@akuh.example'),
        ),
      );
      signUpBloc = MockSignUpBloc();
      when(() => signUpBloc.state).thenReturn(SignUpState(draft: _draft));
      facilitiesBloc = MockFacilitiesBloc();
      whenListen(
        facilitiesBloc,
        Stream.fromIterable([const FacilityLoadSuccess(_facility)]),
        initialState: const FacilitiesInitial(),
      );
    });

    Widget screen() => MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<SignUpBloc>.value(value: signUpBloc),
        BlocProvider<FacilitiesBloc>.value(value: facilitiesBloc),
      ],
      child: const PractitionerReviewScreen(),
    );

    testWidgets('renders in light and dark', (tester) async {
      await tester.pumpApp(screen(), themeMode: ThemeMode.light);
      await tester.pumpAndSettle();
      expect(find.text('Check and submit'), findsOneWidget);
      expect(find.text('Dr. Wanjiru Kamau'), findsOneWidget);
      expect(find.text('w.kamau@akuh.example'), findsOneWidget);
      expect(find.text('Aga Khan University Hospital'), findsOneWidget);

      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text('Check and submit'), findsOneWidget);
    });

    testWidgets('lays out in Swahili at 2.0x with an error', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(screen(), locale: const Locale('sw'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TabibuButton));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('rows read from the draft and session', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('w.kamau@akuh.example'), findsOneWidget);
      expect(find.text('+254 722 118 450'), findsOneWidget);
      expect(find.text('Parklands, Westlands'), findsOneWidget);
      expect(find.text('A 12345'), findsOneWidget);
      expect(find.text('General surgery'), findsOneWidget);
      expect(find.text('1 document'), findsOneWidget);
      expect(find.text('Accepting new patients'), findsOneWidget);
    });

    testWidgets('at 2.0x text the checkbox is hit-testable', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text(_doctorTerms));
      await tester.pumpAndSettle();
      await tester.tap(find.text(_doctorTerms));
      await tester.pumpAndSettle();

      final updated =
          verify(() => signUpBloc.add(captureAny())).captured.single
              as SignUpDraftUpdated;
      expect(updated.draft.termsAccepted, isTrue);
    });

    testWidgets('submit waits for the terms', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit for verification'));
      await tester.pumpAndSettle();
      verifyNever(() => authBloc.add(any()));

      await tester.ensureVisible(find.text(_doctorTerms));
      await tester.pumpAndSettle();
      await tester.tap(find.text(_doctorTerms));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Submit for verification'));
      await tester.pumpAndSettle();

      final submitted =
          verify(() => authBloc.add(captureAny())).captured.single
              as PractitionerSignUpRequested;
      expect(submitted.draft.termsAccepted, isTrue);
    });

    testWidgets('a failure shows its message', (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          const SignUpFailure(
            session: SignUpIncompleteSession(email: 'w.kamau@akuh.example'),
            error: AppError.unknown,
          ),
        ]),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
    });

    testWidgets('a fresh review shows no stale failure', (tester) async {
      when(() => authBloc.state).thenReturn(
        const SignUpFailure(
          session: SignUpIncompleteSession(email: 'w.kamau@akuh.example'),
          error: AppError.unknown,
        ),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(
        find.text('Something went wrong. Please try again.'),
        findsNothing,
      );
    });

    testWidgets('a cached facility shows its name with no new emission', (
      tester,
    ) async {
      whenListen(
        facilitiesBloc,
        const Stream<FacilitiesState>.empty(),
        initialState: const FacilityLoadSuccess(_facility),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('Aga Khan University Hospital'), findsOneWidget);
      expect(find.text('h1'), findsNothing);
    });

    testWidgets('success goes to the pending screen', (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          SignUpSuccess(
            session: PendingVerificationSession(doctor: DoctorModel.empty()),
          ),
        ]),
      );

      final router = GoRouter(
        initialLocation: '/sign-up/practitioner/review',
        routes: [
          GoRoute(
            path: '/sign-up/practitioner/review',
            builder: (_, _) => screen(),
          ),
          GoRoute(
            path: '/account/pending',
            builder: (_, _) => const Text('pending stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      expect(find.text('pending stub'), findsOneWidget);
    });

    testWidgets('edit pops back to its step', (tester) async {
      final router = GoRouter(
        initialLocation: '/e1',
        routes: [
          for (final (path, next) in [
            ('/e1', '/e2'),
            ('/e2', '/e3'),
            ('/e3', '/review'),
          ])
            GoRoute(
              path: path,
              builder: (context, _) => TextButton(
                onPressed: () => context.push(next),
                child: Text('$path stub'),
              ),
            ),
          GoRoute(path: '/review', builder: (_, _) => screen()),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();
      for (final path in ['/e1', '/e2', '/e3']) {
        await tester.tap(find.text('$path stub'));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('Edit').first);
      await tester.pumpAndSettle();

      expect(find.text('/e1 stub'), findsOneWidget);
      expect(router.canPop(), isFalse);
    });

    testWidgets('a doctor sees the exact E4 terms', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text(_doctorTerms), findsOneWidget);
      expect(find.text(_pathologistTerms), findsNothing);
    });

    testWidgets('a pathologist sees the exact F4 terms', (tester) async {
      when(
        () => signUpBloc.state,
      ).thenReturn(SignUpState(draft: _draft.copyWith(role: Role.pathologist)));

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text(_pathologistTerms), findsOneWidget);
      expect(find.text(_doctorTerms), findsNothing);
    });

    testWidgets('a pathologist sees lab rows', (tester) async {
      when(() => signUpBloc.state).thenReturn(
        SignUpState(
          draft: _draft.copyWith(
            role: Role.pathologist,
            specialties: const [Specialty.histopathology, Specialty.cytology],
          ),
        ),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('Licence and areas'), findsOneWidget);
      expect(find.text('Histopathology, Cytology'), findsOneWidget);
      expect(find.text('Area'), findsNothing);
    });

    testWidgets('system back waits while the sign-up is sent', (tester) async {
      when(() => authBloc.state).thenReturn(
        const SignUpInProgress(
          session: SignUpIncompleteSession(email: 'w.kamau@akuh.example'),
        ),
      );
      final router = GoRouter(
        initialLocation: '/previous/step',
        routes: [
          GoRoute(
            path: '/previous',
            builder: (_, _) => const Text('Previous step'),
            routes: [GoRoute(path: 'step', builder: (_, _) => screen())],
          ),
        ],
      );
      addTearDown(router.dispose);
      // The spinner never settles.
      await tester.pumpRouterApp(router);
      await tester.pump();

      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Check and submit'), findsOneWidget);
      expect(find.text('Previous step'), findsNothing);
    });

    testWidgets('Space checks the terms, and Tab leaves the row', (
      tester,
    ) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text(_doctorTerms));
      await tester.pumpAndSettle();
      await tester.tabTo(find.text(_doctorTerms));

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      final updated =
          verify(() => signUpBloc.add(captureAny())).captured.single
              as SignUpDraftUpdated;
      expect(updated.draft.termsAccepted, isTrue);

      // One stop on the row: the next Tab reaches Submit, not the Checkbox.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        Focus.of(tester.element(find.text(_doctorTerms))).hasFocus,
        isFalse,
      );
      expect(
        Focus.of(tester.element(find.text('Submit for verification'))).hasFocus,
        isTrue,
      );
    });
  });
}
