import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/onboarding/blocs/onboarding_bloc/onboarding_bloc.dart';
import 'package:tabibu/features/onboarding/blocs/onboarding_bloc/onboarding_event.dart';
import 'package:tabibu/features/onboarding/blocs/onboarding_bloc/onboarding_state.dart';
import 'package:tabibu/features/onboarding/presentation/intro_screen.dart';

import '../../../helpers/helpers.dart';

class MockOnboardingBloc extends MockBloc<OnboardingEvent, OnboardingState>
    implements OnboardingBloc {}

void main() {
  group('IntroScreen', () {
    late MockOnboardingBloc onboardingBloc;

    setUp(() {
      onboardingBloc = MockOnboardingBloc();
      when(() => onboardingBloc.state).thenReturn(const OnboardingInitial());
    });

    Widget screen() => BlocProvider<OnboardingBloc>.value(
      value: onboardingBloc,
      child: const IntroScreen(),
    );

    testWidgets('renders in light and dark', (tester) async {
      await tester.pumpApp(screen(), themeMode: ThemeMode.light);
      await tester.pumpAndSettle();
      expect(find.text('Only verified'), findsOneWidget);
      expect(find.text('clinicians'), findsOneWidget);

      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text('Only verified'), findsOneWidget);
      expect(find.text('clinicians'), findsOneWidget);
    });

    testWidgets('renders in Swahili', (tester) async {
      await tester.pumpApp(screen(), locale: const Locale('sw'));
      await tester.pumpAndSettle();
      expect(find.text('Wahudumu walioidhinishwa'), findsOneWidget);
      expect(find.text('pekee'), findsOneWidget);
    });

    testWidgets('each slide lays out at 2.0x text without overflow', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.textContaining('One case.'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Checked by experts'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Skip is not teal', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      final context = tester.element(find.text('Skip'));
      final scheme = Theme.of(context).colorScheme;
      final skip = tester.widget<Text>(find.text('Skip'));
      expect(skip.style?.color, scheme.onSurface);
    });

    testWidgets('Next advances and Back returns', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.textContaining('One case.'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Checked by experts'), findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.textContaining('One case.'), findsOneWidget);
    });

    testWidgets('Skip marks onboarding done before going to A6', (
      tester,
    ) async {
      final states = StreamController<OnboardingState>();
      addTearDown(states.close);
      whenListen(
        onboardingBloc,
        states.stream,
        initialState: const OnboardingInitial(),
      );
      final router = GoRouter(
        initialLocation: '/intro',
        routes: [
          GoRoute(path: '/intro', builder: (_, _) => screen()),
          GoRoute(
            path: '/get-started',
            builder: (_, _) => const Text('get-started stub'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip'));
      verify(() => onboardingBloc.add(const OnboardingCompleted())).called(1);
      expect(find.text('get-started stub'), findsNothing);

      states.add(const OnboardingComplete());
      await tester.pumpAndSettle();
      expect(find.text('get-started stub'), findsOneWidget);
    });

    testWidgets('Get started marks onboarding done before going to A6', (
      tester,
    ) async {
      final states = StreamController<OnboardingState>();
      addTearDown(states.close);
      whenListen(
        onboardingBloc,
        states.stream,
        initialState: const OnboardingInitial(),
      );
      final router = GoRouter(
        initialLocation: '/intro',
        routes: [
          GoRoute(path: '/intro', builder: (_, _) => screen()),
          GoRoute(
            path: '/get-started',
            builder: (_, _) => const Text('get-started stub'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get started'));
      verify(() => onboardingBloc.add(const OnboardingCompleted())).called(1);
      expect(find.text('get-started stub'), findsNothing);

      states.add(const OnboardingComplete());
      await tester.pumpAndSettle();
      expect(find.text('get-started stub'), findsOneWidget);
    });

    testWidgets('a failure shows its message', (tester) async {
      whenListen(
        onboardingBloc,
        Stream.fromIterable([const OnboardingFailure(error: AppError.unknown)]),
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
  });
}
