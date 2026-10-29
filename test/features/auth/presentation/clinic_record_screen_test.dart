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
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/presentation/clinic_record_screen.dart';

import '../../../helpers/helpers.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  group('ClinicRecordScreen', () {
    late MockAuthBloc authBloc;

    setUp(() {
      authBloc = MockAuthBloc();
      when(
        () => authBloc.state,
      ).thenReturn(const SignUpSuccess(session: ClinicRecordExistsSession()));
    });

    Widget screen() => BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: const ClinicRecordScreen(),
    );

    testWidgets('renders in light and dark', (tester) async {
      await tester.pumpApp(screen(), themeMode: ThemeMode.light);
      await tester.pumpAndSettle();
      expect(find.text('A clinic record already exists'), findsOneWidget);

      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text('A clinic record already exists'), findsOneWidget);
    });

    testWidgets('lays out in Swahili at 2.0x with an error', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      whenListen(
        authBloc,
        Stream.fromIterable([
          const SignOutFailure(
            session: ClinicRecordExistsSession(),
            error: AppError.unknown,
          ),
        ]),
      );

      await tester.pumpApp(screen(), locale: const Locale('sw'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('signing out sends the event', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      verify(() => authBloc.add(const SignOutRequested())).called(1);
    });

    testWidgets('a failure shows its message', (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          const SignOutFailure(
            session: ClinicRecordExistsSession(),
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

    testWidgets('a signed-out session goes to B1', (tester) async {
      whenListen(authBloc, Stream.fromIterable([const SignOutSuccess()]));

      final router = GoRouter(
        initialLocation: '/account/clinic-record',
        routes: [
          GoRoute(path: '/account/clinic-record', builder: (_, _) => screen()),
          GoRoute(
            path: '/sign-in',
            builder: (_, _) => const Text('sign-in stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      expect(find.text('sign-in stub'), findsOneWidget);
    });
  });
}
