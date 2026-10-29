import 'package:bloc_test/bloc_test.dart';
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
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/presentation/patient_account_screen.dart';

import '../../../helpers/helpers.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(const GoogleSignInRequested());
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
            path: '/sign-up/patient/phone',
            builder: (_, _) => const Text('D3 stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      expect(find.text('D3 stub'), findsOneWidget);
    });
  });
}
