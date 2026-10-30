import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/core/services/app_update_service.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/data/models/onboarding_hive.dart';
import 'package:tabibu/features/auth/presentation/decision_screen.dart';

import '../../../helpers/helpers.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockHiveHelper extends Mock implements HiveHelper {}

class MockAppUpdateService extends Mock implements AppUpdateService {}

void main() {
  group('DecisionScreen', () {
    late MockAuthBloc authBloc;

    setUp(() {
      authBloc = MockAuthBloc();
      when(() => authBloc.state).thenReturn(const AuthInitial());
      final updates = MockAppUpdateService();
      when(updates.isUpdateRequired).thenAnswer((_) async => false);
      getIt
        ..registerSingleton<AppUpdateService>(updates)
        ..registerSingleton<HiveHelper>(MockHiveHelper());
    });

    tearDown(getIt.reset);

    Widget screen() => BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: const DecisionScreen(),
    );

    testWidgets('renders in light and dark', (tester) async {
      await tester.pumpApp(screen(), themeMode: ThemeMode.light);
      await tester.pumpAndSettle();
      expect(
        find.text('Trusted care, from your first visit to a signed result'),
        findsOneWidget,
      );

      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(
        find.text('Trusted care, from your first visit to a signed result'),
        findsOneWidget,
      );
    });

    testWidgets('renders in Swahili', (tester) async {
      await tester.pumpApp(screen(), locale: const Locale('sw'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Huduma unayoiamini, kutoka ziara yako ya kwanza '
          'hadi matokeo yaliyosainiwa',
        ),
        findsOneWidget,
      );
    });

    testWidgets('lays out in Swahili at 2.0x', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(screen(), locale: const Locale('sw'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('it asks for the session on launch', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      verify(() => authBloc.add(const SessionRequested())).called(1);
    });

    testWidgets('a signed-out first run lands on A2', (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          const SessionLoadSuccess(session: SignedOutSession()),
        ]),
      );
      when(getIt<HiveHelper>().getCachedOnboarding).thenAnswer(
        (_) async => OnboardingHive(isOnboarded: false, languageString: ''),
      );

      final router = GoRouter(
        initialLocation: '/decision',
        routes: [
          GoRoute(path: '/decision', builder: (_, _) => screen()),
          GoRoute(
            path: '/language',
            builder: (_, _) => const Text('language stub'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      expect(find.text('language stub'), findsOneWidget);
    });
  });
}
