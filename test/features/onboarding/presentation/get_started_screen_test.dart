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
import 'package:tabibu/features/onboarding/presentation/get_started_screen.dart';

import '../../../helpers/helpers.dart';

class MockOnboardingBloc extends MockBloc<OnboardingEvent, OnboardingState>
    implements OnboardingBloc {}

void main() {
  group('GetStartedScreen', () {
    late MockOnboardingBloc onboardingBloc;

    setUp(() {
      onboardingBloc = MockOnboardingBloc();
      when(() => onboardingBloc.state).thenReturn(const OnboardingInitial());
    });

    Widget screen() => BlocProvider<OnboardingBloc>.value(
      value: onboardingBloc,
      child: const GetStartedScreen(),
    );

    testWidgets('renders in light and dark', (tester) async {
      await tester.pumpApp(screen(), themeMode: ThemeMode.light);
      await tester.pumpAndSettle();
      expect(find.text('Care that reaches you faster.'), findsOneWidget);

      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text('Care that reaches you faster.'), findsOneWidget);
    });

    testWidgets('renders in Swahili', (tester) async {
      await tester.pumpApp(screen(), locale: const Locale('sw'));
      await tester.pumpAndSettle();
      expect(find.text('Huduma inayokufikia haraka zaidi.'), findsOneWidget);
    });

    testWidgets('lays out at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('each action marks onboarding done first', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create an account'));
      expect(
        verify(() => onboardingBloc.add(const OnboardingCompleted())).callCount,
        1,
      );
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
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('completion navigates to the chosen destination', (
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
        initialLocation: '/get-started',
        routes: [
          GoRoute(path: '/get-started', builder: (_, _) => screen()),
          GoRoute(
            path: '/sign-in',
            builder: (_, _) => const Text('sign-in stub'),
          ),
          GoRoute(
            path: '/sign-up/role',
            builder: (_, _) => const Text('role stub'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign in'));
      states.add(const OnboardingComplete());
      await tester.pumpAndSettle();
      expect(find.text('sign-in stub'), findsOneWidget);
    });
  });
}
