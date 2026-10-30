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
import 'package:tabibu/features/auth/presentation/reset_password_screen.dart';

import '../../../helpers/helpers.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  group('ResetPasswordScreen', () {
    late MockAuthBloc authBloc;

    setUp(() {
      authBloc = MockAuthBloc();
      when(() => authBloc.state).thenReturn(const AuthInitial());
    });

    Widget screen() => BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: const ResetPasswordScreen(),
    );

    testWidgets('renders in light and dark', (tester) async {
      await tester.pumpApp(screen(), themeMode: ThemeMode.light);
      await tester.pumpAndSettle();
      expect(find.text('Reset your password'), findsOneWidget);

      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text('Reset your password'), findsOneWidget);
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

    testWidgets('sending requests the reset', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TabibuTextField), 'a@b.co');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send reset link'));
      await tester.pumpAndSettle();

      verify(
        () => authBloc.add(const PasswordResetRequested(email: 'a@b.co')),
      ).called(1);
    });

    testWidgets('a bad email shows its message', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TabibuTextField), 'not-an-email');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send reset link'));
      await tester.pumpAndSettle();

      expect(find.text('The email address is not valid.'), findsOneWidget);
    });

    testWidgets('a failure shows its message', (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          const PasswordResetFailure(
            session: SignedOutSession(),
            error: AppError.tooManyRequests,
          ),
        ]),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(
        find.text('Too many attempts. Please try again later.'),
        findsOneWidget,
      );
    });

    testWidgets('a reopened screen shows no stale failure', (tester) async {
      when(() => authBloc.state).thenReturn(
        const PasswordResetFailure(
          session: SignedOutSession(),
          error: AppError.tooManyRequests,
        ),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.byType(NoticeCard), findsNothing);
    });

    testWidgets('success goes to B5', (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          const PasswordResetSuccess(session: SignedOutSession()),
        ]),
      );

      final router = GoRouter(
        initialLocation: '/reset-password',
        routes: [
          GoRoute(path: '/reset-password', builder: (_, _) => screen()),
          GoRoute(
            path: '/reset-password/sent',
            builder: (_, _) => const Text('sent stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      expect(find.text('sent stub'), findsOneWidget);
    });
  });
}
