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

    setUp(() {
      authBloc = MockAuthBloc();
      when(() => authBloc.state).thenReturn(const AuthInitial());
    });

    Widget screen() => BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: const PatientAccountScreen(),
    );

    testWidgets('renders in light and dark', (tester) async {
      await tester.pumpApp(screen(), themeMode: ThemeMode.light);
      await tester.pumpAndSettle();
      expect(find.text('Your email and a password'), findsOneWidget);

      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text('Your email and a password'), findsOneWidget);
    });

    testWidgets('lays out at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(screen());
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

    testWidgets('a bad email shows its message', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'not-an-email');
      await tester.enterText(find.byType(TextField).at(1), 'Strong1!');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('The email address is not valid.'), findsNWidgets(2));
    });

    testWidgets('a failure shows its message', (tester) async {
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

      expect(find.byType(NoticeCard), findsOneWidget);
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
  });
}
