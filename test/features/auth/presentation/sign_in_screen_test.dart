import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/role_helper.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/presentation/role_screen.dart';
import 'package:tabibu/features/auth/presentation/sign_in_screen.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';

import '../../../helpers/helpers.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockSignUpBloc extends MockBloc<SignUpEvent, SignUpState>
    implements SignUpBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(const GoogleSignInRequested());
  });

  group('SignInScreen', () {
    late MockAuthBloc authBloc;
    late MockSignUpBloc signUpBloc;

    setUp(() {
      authBloc = MockAuthBloc();
      when(() => authBloc.state).thenReturn(const AuthInitial());
      signUpBloc = MockSignUpBloc();
      when(() => signUpBloc.state).thenReturn(const SignUpState());
    });

    Widget screen() => MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<SignUpBloc>.value(value: signUpBloc),
      ],
      child: const SignInScreen(),
    );

    testWidgets('renders in light and dark', (tester) async {
      await tester.pumpApp(screen(), themeMode: ThemeMode.light);
      await tester.pumpAndSettle();
      expect(find.text('Welcome back'), findsOneWidget);

      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('lays out in Swahili at 2.0x with an error', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      whenListen(
        authBloc,
        Stream.fromIterable([
          const SignInFailure(
            session: SignedOutSession(),
            error: AppError.wrongPassword,
          ),
        ]),
      );

      await tester.pumpApp(screen(), locale: const Locale('sw'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('signing in sends the event', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TabibuTextField).first, 'a@b.co');
      await tester.enterText(find.byType(TabibuTextField).last, 'secret1!');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      verify(
        () => authBloc.add(
          const SignInRequested(email: 'a@b.co', password: 'secret1!'),
        ),
      ).called(1);
    });

    testWidgets('Google sends its event', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign in with Google'));
      await tester.pumpAndSettle();

      verify(() => authBloc.add(const GoogleSignInRequested())).called(1);
    });

    testWidgets('a bad email shows its message', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TabibuTextField).first,
        'not-an-email',
      );
      await tester.enterText(find.byType(TabibuTextField).last, 'secret1!');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('The email address is not valid.'), findsOneWidget);
      verifyNever(() => authBloc.add(any()));
    });

    testWidgets('a failure shows its message (B2)', (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          const SignInFailure(
            session: SignedOutSession(),
            error: AppError.wrongPassword,
          ),
        ]),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      // The notice and the password field carry the same message.
      expect(
        find.text('Incorrect password. Please try again.'),
        findsNWidgets(2),
      );
    });

    testWidgets('typing clears a sign-in failure', (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          const SignInFailure(
            session: SignedOutSession(),
            error: AppError.wrongPassword,
          ),
        ]),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      expect(
        find.text('Incorrect password. Please try again.'),
        findsNWidgets(2),
      );

      await tester.enterText(find.byType(TabibuTextField).first, 'a@b.co');
      await tester.pumpAndSettle();

      expect(find.text('Incorrect password. Please try again.'), findsNothing);
    });

    testWidgets('a cancelled Google dialog shows nothing', (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          const SignInCancelled(session: SignedOutSession()),
        ]),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.byType(NoticeCard), findsNothing);
    });

    testWidgets('success leaves through the session', (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          SignInSuccess(
            session: PatientSession(
              patient: PatientModel.empty().copyWith(firstName: 'Amina'),
              roles: const RoleHelper(
                role: Role.patient,
                isAdmin: false,
                isAlertApprover: false,
              ),
            ),
          ),
        ]),
      );

      final router = GoRouter(
        initialLocation: '/sign-in',
        routes: [
          GoRoute(path: '/sign-in', builder: (_, _) => screen()),
          GoRoute(
            path: '/patient',
            builder: (_, _) => const Text('patient stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      expect(find.text('patient stub'), findsOneWidget);
    });

    testWidgets('forgot password goes to reset', (tester) async {
      final router = GoRouter(
        initialLocation: '/sign-in',
        routes: [
          GoRoute(path: '/sign-in', builder: (_, _) => screen()),
          GoRoute(
            path: '/reset-password',
            builder: (_, _) => const Text('reset stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();

      expect(find.text('reset stub'), findsOneWidget);
    });

    testWidgets('the back button shows only when it can pop', (tester) async {
      final router = GoRouter(
        initialLocation: '/get-started',
        routes: [
          GoRoute(
            path: '/get-started',
            builder: (context, _) => TextButton(
              onPressed: () => context.push('/sign-in'),
              child: const Text('to sign-in'),
            ),
          ),
          GoRoute(path: '/sign-in', builder: (_, _) => screen()),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      await tester.tap(find.text('to sign-in'));
      await tester.pumpAndSettle();
      expect(find.byType(CircleIconButton), findsOneWidget);

      await tester.tap(find.byType(CircleIconButton));
      await tester.pumpAndSettle();
      expect(find.text('to sign-in'), findsOneWidget);
    });

    testWidgets('there is no back button at the root', (tester) async {
      final router = GoRouter(
        initialLocation: '/sign-in',
        routes: [GoRoute(path: '/sign-in', builder: (_, _) => screen())],
      );
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      expect(find.byType(CircleIconButton), findsNothing);
    });

    testWidgets('Create an account pushes C1, back returns', (tester) async {
      final roleSignUpBloc = MockSignUpBloc();
      when(() => roleSignUpBloc.state).thenReturn(const SignUpState());
      final router = GoRouter(
        initialLocation: '/sign-in',
        routes: [
          GoRoute(path: '/sign-in', builder: (_, _) => screen()),
          GoRoute(
            path: '/sign-up',
            builder: (_, _) => BlocProvider<SignUpBloc>.value(
              value: roleSignUpBloc,
              child: const RoleScreen(),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Create an account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create an account'));
      await tester.pumpAndSettle();
      expect(find.text("I'm joining Tabibu as…"), findsOneWidget);
      verify(() => signUpBloc.add(const SignUpDraftCleared())).called(1);

      await tester.tap(find.byType(CircleIconButton));
      await tester.pumpAndSettle();
      expect(find.text('Welcome back'), findsOneWidget);
    });
  });
}
