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
import 'package:tabibu/features/onboarding/presentation/language_screen.dart';

import '../../../helpers/helpers.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  group('LanguageScreen', () {
    late MockAuthBloc authBloc;

    setUp(() {
      authBloc = MockAuthBloc();
      when(() => authBloc.state).thenReturn(const AuthInitial());
    });

    Widget screen() => BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: const LanguageScreen(),
    );

    testWidgets('renders in light and dark', (tester) async {
      await tester.pumpApp(screen(), themeMode: ThemeMode.light);
      await tester.pumpAndSettle();
      expect(find.text('Choose your language'), findsOneWidget);

      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text('Choose your language'), findsOneWidget);
    });

    testWidgets('renders in Swahili', (tester) async {
      await tester.pumpApp(screen(), locale: const Locale('sw'));
      await tester.pumpAndSettle();
      expect(find.text('Chagua lugha yako'), findsOneWidget);
    });

    testWidgets('lays out in Swahili at 2.0x', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(screen(), locale: const Locale('sw'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('a card sends the language change', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kiswahili'));
      expect(
        verify(
          () => authBloc.add(
            const LanguageChangeRequested(language: AppLanguage.sw),
          ),
        ).callCount,
        1,
      );
    });

    testWidgets('a failure shows its message', (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          const LanguageChangeFailure(
            session: SignedOutSession(),
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

      // Let the notification's auto-dismiss timer fire before teardown.
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('Continue goes to the intro', (tester) async {
      final router = GoRouter(
        initialLocation: '/language',
        routes: [
          GoRoute(path: '/language', builder: (_, _) => screen()),
          GoRoute(path: '/intro', builder: (_, _) => const Text('intro stub')),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('intro stub'), findsOneWidget);
    });
  });
}
