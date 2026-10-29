import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/data/models/sign_up_draft.dart';
import 'package:tabibu/features/auth/presentation/verify_email_screen.dart';

import '../../../helpers/helpers.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockSignUpBloc extends MockBloc<SignUpEvent, SignUpState>
    implements SignUpBloc {}

const _unverified = SignUpIncompleteSession(email: 'amina@gmail.com');
const _verified = SignUpIncompleteSession(
  email: 'amina@gmail.com',
  emailVerified: true,
);

void main() {
  setUpAll(() {
    registerFallbackValue(const SignOutRequested());
  });

  group('VerifyEmailScreen', () {
    late MockAuthBloc authBloc;
    late MockSignUpBloc signUpBloc;

    setUp(() {
      authBloc = MockAuthBloc();
      signUpBloc = MockSignUpBloc();
      when(
        () => authBloc.state,
      ).thenReturn(const SessionLoadSuccess(session: _unverified));
      when(() => signUpBloc.state).thenReturn(const SignUpState());
    });

    Widget screen() => MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<SignUpBloc>.value(value: signUpBloc),
      ],
      child: const VerifyEmailScreen(),
    );

    GoRouter router() => GoRouter(
      initialLocation: '/account/verify-email',
      routes: [
        GoRoute(path: '/account/verify-email', builder: (_, _) => screen()),
        GoRoute(path: '/sign-up', builder: (_, _) => const Text('C1 stub')),
        GoRoute(
          path: '/sign-up/patient/phone',
          builder: (_, _) => const Text('D3 stub'),
        ),
        GoRoute(path: '/sign-in', builder: (_, _) => const Text('B1 stub')),
      ],
    );

    testWidgets('renders in light and dark, with the address masked', (
      tester,
    ) async {
      await tester.pumpApp(screen(), themeMode: ThemeMode.light);
      await tester.pumpAndSettle();
      expect(find.text('Check your email'), findsOneWidget);
      expect(find.textContaining('a•••@gmail.com'), findsOneWidget);

      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text('Verified'), findsOneWidget);
    });

    testWidgets('lays out at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Verified asks the server', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Verified'));
      verify(
        () => authBloc.add(const EmailVerificationCheckRequested()),
      ).called(1);
    });

    testWidgets('an unconfirmed address says so and stays', (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          const EmailVerificationCheckSuccess(
            session: _unverified,
            isVerified: false,
          ),
        ]),
        initialState: const SessionLoadSuccess(session: _unverified),
      );
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      expect(find.textContaining('Not verified yet'), findsOneWidget);
      expect(find.text('C1 stub'), findsNothing);
      // The notification dismisses itself.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('confirmed with no sign-up in progress goes to C1', (
      tester,
    ) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          const EmailVerificationCheckSuccess(
            session: _verified,
            isVerified: true,
          ),
        ]),
        initialState: const SessionLoadSuccess(session: _unverified),
      );
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      expect(find.text('C1 stub'), findsOneWidget);
    });

    testWidgets('confirmed mid sign-up moves to the next step', (tester) async {
      when(
        () => signUpBloc.state,
      ).thenReturn(const SignUpState(draft: SignUpDraft(role: Role.patient)));
      whenListen(
        authBloc,
        Stream.fromIterable([
          const EmailVerificationCheckSuccess(
            session: _verified,
            isVerified: true,
          ),
        ]),
        initialState: const SessionLoadSuccess(session: _unverified),
      );
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      expect(find.text('D3 stub'), findsOneWidget);
    });

    testWidgets('the link in the notice resends, then counts down', (
      tester,
    ) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resend the link'));
      verify(
        () => authBloc.add(const VerificationEmailResendRequested()),
      ).called(1);
    });

    testWidgets('the resend link meets the tap target floor', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    });

    testWidgets('a resent link starts the cooldown', (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          const VerificationEmailResendSuccess(session: _unverified),
        ]),
        initialState: const SessionLoadSuccess(session: _unverified),
      );
      await tester.pumpApp(screen());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Resend in 59s'), findsOneWidget);
      await tester.tap(find.text('Resend in 59s'));
      verifyNever(() => authBloc.add(const VerificationEmailResendRequested()));

      await tester.pump(const Duration(seconds: 60));
      expect(find.text('Resend the link'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('Back to sign in signs out, then shows B1', (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([const SignOutSuccess()]),
        initialState: const SessionLoadSuccess(session: _unverified),
      );
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      expect(find.text('B1 stub'), findsOneWidget);
    });

    testWidgets('Back to sign in asks to sign out', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Back to sign in'));
      verify(() => authBloc.add(const SignOutRequested())).called(1);
    });
  });
}
