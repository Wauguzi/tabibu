import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_state.dart';
import 'package:tabibu/features/onboarding/presentation/get_started_screen.dart';

import '../../../helpers/helpers.dart';

class MockSignUpBloc extends MockBloc<SignUpEvent, SignUpState>
    implements SignUpBloc {}

void main() {
  group('GetStartedScreen', () {
    testWidgets('renders in light and dark', (tester) async {
      await tester.pumpApp(
        const GetStartedScreen(),
        themeMode: ThemeMode.light,
      );
      await tester.pumpAndSettle();
      expect(find.text('Care that reaches you faster.'), findsOneWidget);

      await tester.pumpApp(const GetStartedScreen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text('Care that reaches you faster.'), findsOneWidget);
    });

    testWidgets('renders in Swahili', (tester) async {
      await tester.pumpApp(
        const GetStartedScreen(),
        locale: const Locale('sw'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Huduma inayokufikia haraka zaidi.'), findsOneWidget);
    });

    testWidgets('lays out at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(const GetStartedScreen());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Create an account pushes C1', (tester) async {
      final signUpBloc = MockSignUpBloc();
      when(() => signUpBloc.state).thenReturn(const SignUpState());
      final router = GoRouter(
        initialLocation: '/get-started',
        routes: [
          GoRoute(
            path: '/get-started',
            builder: (_, _) => BlocProvider<SignUpBloc>.value(
              value: signUpBloc,
              child: const GetStartedScreen(),
            ),
          ),
          GoRoute(path: '/sign-up', builder: (_, _) => const Text('role stub')),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Create an account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create an account'));
      await tester.pumpAndSettle();
      expect(find.text('role stub'), findsOneWidget);
      verify(() => signUpBloc.add(const SignUpDraftCleared())).called(1);
    });

    testWidgets('Sign in pushes B1', (tester) async {
      final router = GoRouter(
        initialLocation: '/get-started',
        routes: [
          GoRoute(
            path: '/get-started',
            builder: (_, _) => const GetStartedScreen(),
          ),
          GoRoute(
            path: '/sign-in',
            builder: (_, _) => const Text('sign-in stub'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Sign in'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('sign-in stub'), findsOneWidget);
    });

    testWidgets('cannot be popped back into the intro', (tester) async {
      await tester.pumpApp(const GetStartedScreen());
      await tester.pumpAndSettle();

      final scope = tester.widget<PopScope>(find.byType(PopScope));
      expect(scope.canPop, isFalse);
    });
  });
}
