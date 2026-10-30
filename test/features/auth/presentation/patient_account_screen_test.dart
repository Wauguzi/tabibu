import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/services/file_picker_service.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/data/models/sign_up_draft.dart';
import 'package:tabibu/features/auth/presentation/patient_account_screen.dart';
import 'package:tabibu/features/auth/presentation/patient_name_screen.dart';

import '../../../helpers/helpers.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockSignUpBloc extends MockBloc<SignUpEvent, SignUpState>
    implements SignUpBloc {}

class MockFilePickerService extends Mock implements FilePickerService {}

void main() {
  setUpAll(() {
    registerFallbackValue(const GoogleSignInRequested());
    registerFallbackValue(const SignUpDraftUpdated(draft: SignUpDraft()));
  });

  group('PatientAccountScreen', () {
    late MockAuthBloc authBloc;
    late MockSignUpBloc draftBloc;

    setUp(() {
      authBloc = MockAuthBloc();
      when(() => authBloc.state).thenReturn(const AuthInitial());
      draftBloc = MockSignUpBloc();
      when(
        () => draftBloc.state,
      ).thenReturn(const SignUpState(draft: SignUpDraft(role: Role.patient)));
    });

    Widget screen() => MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<SignUpBloc>.value(value: draftBloc),
      ],
      child: const PatientAccountScreen(),
    );

    Future<void> pumpUnderStub(WidgetTester tester, Widget step) async {
      final router = GoRouter(
        initialLocation: '/previous/step',
        routes: [
          GoRoute(
            path: '/previous',
            builder: (_, _) => const Text('Previous step'),
            routes: [GoRoute(path: 'step', builder: (_, _) => step)],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();
    }

    SignUpDraft committedDraft(MockSignUpBloc bloc) {
      final captured = verify(() => bloc.add(captureAny())).captured;
      return (captured.last as SignUpDraftUpdated).draft;
    }

    testWidgets('renders in light and dark', (tester) async {
      await tester.pumpApp(screen(), themeMode: ThemeMode.light);
      await tester.pumpAndSettle();
      expect(find.text('Your email and a password'), findsOneWidget);

      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text('Your email and a password'), findsOneWidget);
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

    testWidgets('a weak password keeps Continue off', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'a@b.co');
      await tester.enterText(find.byType(TextField).at(1), 'weak');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'), warnIfMissed: false);
      await tester.pumpAndSettle();

      verifyNever(() => authBloc.add(any()));
    });

    testWidgets('complete details create the account', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'a@b.co');
      await tester.enterText(find.byType(TextField).at(1), 'Strong1!');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      verify(
        () => authBloc.add(
          const CreateAccountRequested(email: 'a@b.co', password: 'Strong1!'),
        ),
      ).called(1);
    });

    testWidgets('a bad email shows its message under the field, once', (
      tester,
    ) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'not-an-email');
      await tester.enterText(find.byType(TextField).at(1), 'Strong1!');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(
        find.text("That doesn't look like an email address"),
        findsOneWidget,
      );
      expect(find.byType(NoticeCard), findsNothing);
    });

    testWidgets('the email is checked when the field loses focus', (
      tester,
    ) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'not-an-email');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextField).at(1));
      await tester.pumpAndSettle();

      expect(
        find.text("That doesn't look like an email address"),
        findsOneWidget,
      );
      expect(find.byType(NoticeCard), findsNothing);
    });

    testWidgets('emailAlreadyInUse from the bloc shows under the email field', (
      tester,
    ) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          const CreateAccountFailure(
            session: SignedOutSession(),
            error: AppError.emailAlreadyInUse,
          ),
        ]),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(
        find.text('An account already uses this email. Sign in instead.'),
        findsOneWidget,
      );
      expect(find.byType(NoticeCard), findsNothing);
    });

    testWidgets('typing a password keeps the email message', (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          const CreateAccountFailure(
            session: SignedOutSession(),
            error: AppError.emailAlreadyInUse,
          ),
        ]),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(1), 'Str0ng!pass');
      await tester.pumpAndSettle();

      expect(
        find.text('An account already uses this email. Sign in instead.'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField).at(0), 'a@b.co');
      await tester.pumpAndSettle();

      expect(
        find.text('An account already uses this email. Sign in instead.'),
        findsNothing,
      );
    });

    testWidgets('leaving an empty email shows no message', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextField).at(0));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextField).at(1));
      await tester.pumpAndSettle();

      expect(
        find.text("That doesn't look like an email address"),
        findsNothing,
      );
    });

    testWidgets('no connection shows in the notice', (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          const CreateAccountFailure(
            session: SignedOutSession(),
            error: AppError.noInternet,
          ),
        ]),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.byType(NoticeCard), findsOneWidget);
      expect(find.text('No internet access.'), findsOneWidget);
    });

    testWidgets('an old failure does not reappear on revisit', (tester) async {
      when(() => authBloc.state).thenReturn(
        const CreateAccountFailure(
          session: SignedOutSession(),
          error: AppError.emailAlreadyInUse,
        ),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(
        find.text('An account already uses this email. Sign in instead.'),
        findsNothing,
      );
      expect(find.byType(NoticeCard), findsNothing);
    });

    testWidgets('once the account exists, D2 is read-only and moves on', (
      tester,
    ) async {
      when(() => authBloc.state).thenReturn(
        const SignInSuccess(
          session: SignUpIncompleteSession(
            email: 'a@b.co',
            emailVerified: true,
          ),
        ),
      );
      final router = GoRouter(
        initialLocation: '/sign-up/patient/account',
        routes: [
          GoRoute(
            path: '/sign-up/patient/account',
            builder: (_, _) => screen(),
          ),
          GoRoute(
            path: '/sign-up/patient/phone',
            builder: (_, _) => const Text('D3 stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      expect(find.text('a@b.co'), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isTrue);
      expect(find.byType(PasswordField), findsNothing);
      expect(
        find.text(
          'Your account is set up with this email. Continue to the next step.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('D3 stub'), findsOneWidget);
      verifyNever(() => authBloc.add(any()));
    });

    testWidgets('success goes to D3', (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          const CreateAccountSuccess(
            session: SignUpIncompleteSession(
              email: 'a@b.co',
              emailVerified: true,
            ),
          ),
        ]),
      );

      final router = GoRouter(
        initialLocation: '/sign-up/patient/account',
        routes: [
          GoRoute(
            path: '/sign-up/patient/account',
            builder: (_, _) => screen(),
          ),
          GoRoute(
            path: '/sign-up/patient/phone',
            builder: (_, _) => const Text('D3 stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      expect(find.text('D3 stub'), findsOneWidget);
    });

    testWidgets('an unconfirmed address goes to verification', (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          const CreateAccountSuccess(
            session: SignUpIncompleteSession(email: 'a@b.co'),
          ),
        ]),
      );

      final router = GoRouter(
        initialLocation: '/sign-up/patient/account',
        routes: [
          GoRoute(
            path: '/sign-up/patient/account',
            builder: (_, _) => screen(),
          ),
          GoRoute(
            path: '/account/verify-email',
            builder: (_, _) => const Text('verify stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      expect(find.text('verify stub'), findsOneWidget);
    });

    testWidgets('back from D2 shows D1 with the draft intact', (tester) async {
      final signUpBloc = MockSignUpBloc();
      when(() => signUpBloc.state).thenReturn(
        const SignUpState(
          draft: SignUpDraft(role: Role.patient, dateOfBirth: '1980-03-14'),
        ),
      );
      getIt.registerSingleton<FilePickerService>(MockFilePickerService());
      addTearDown(getIt.reset);

      Widget d1() => MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<SignUpBloc>.value(value: signUpBloc),
        ],
        child: const PatientNameScreen(),
      );
      // Nested like the app's router: the steps sit under /sign-up.
      final router = GoRouter(
        initialLocation: '/sign-up/patient/name',
        routes: [
          GoRoute(
            path: '/sign-up',
            builder: (_, _) => const Text('C1 stub'),
            routes: [
              GoRoute(path: 'patient/name', builder: (_, _) => d1()),
              GoRoute(path: 'patient/account', builder: (_, _) => screen()),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'Amina');
      await tester.enterText(find.byType(TextField).at(2), 'Wambui');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Female'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Female'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Your email and a password'), findsOneWidget);

      await tester.tap(find.byType(CircleIconButton));
      await tester.pumpAndSettle();

      expect(find.text('Tell us about you'), findsOneWidget);
      expect(find.text('Amina'), findsOneWidget);
      expect(find.text('Wambui'), findsOneWidget);
      final captured =
          verify(() => signUpBloc.add(captureAny())).captured.single
              as SignUpDraftUpdated;
      expect(captured.draft.firstName, 'Amina');
      expect(captured.draft.lastName, 'Wambui');
    });

    testWidgets('back keeps the email in the draft', (tester) async {
      await pumpUnderStub(tester, screen());
      await tester.enterText(find.byType(TextField).at(0), ' a@b.co ');
      await tester.enterText(find.byType(TextField).at(1), 'Str0ng!pass');
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Previous step'), findsOneWidget);
      expect(committedDraft(draftBloc).email, 'a@b.co');
    });

    testWidgets('a fresh D2 shows the email from the draft', (tester) async {
      when(() => draftBloc.state).thenReturn(
        const SignUpState(
          draft: SignUpDraft(role: Role.patient, email: 'a@b.co'),
        ),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('a@b.co'), findsOneWidget);
    });
  });
}
