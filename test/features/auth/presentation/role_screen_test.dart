import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_state.dart';
import 'package:tabibu/features/auth/data/models/sign_up_draft.dart';
import 'package:tabibu/features/auth/presentation/role_screen.dart';

import '../../../helpers/helpers.dart';

class MockSignUpBloc extends MockBloc<SignUpEvent, SignUpState>
    implements SignUpBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const SignUpRoleChosen(role: Role.patient, language: AppLanguage.en),
    );
  });

  group('RoleScreen', () {
    late MockSignUpBloc signUpBloc;

    setUp(() {
      signUpBloc = MockSignUpBloc();
      when(() => signUpBloc.state).thenReturn(const SignUpState());
    });

    Widget screen() => BlocProvider<SignUpBloc>.value(
      value: signUpBloc,
      child: const RoleScreen(),
    );

    testWidgets('renders in light and dark', (tester) async {
      await tester.pumpApp(screen(), themeMode: ThemeMode.light);
      await tester.pumpAndSettle();
      expect(find.text("I'm joining Tabibu as…"), findsOneWidget);

      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text("I'm joining Tabibu as…"), findsOneWidget);
    });

    testWidgets('lays out in Swahili at 2.0x', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(screen(), locale: const Locale('sw'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('a patient goes to D1', (tester) async {
      final router = GoRouter(
        initialLocation: '/sign-up',
        routes: [
          GoRoute(path: '/sign-up', builder: (_, _) => screen()),
          GoRoute(
            path: '/sign-up/patient/name',
            builder: (_, _) => const Text('D1 stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      verify(
        () => signUpBloc.add(
          const SignUpRoleChosen(role: Role.patient, language: AppLanguage.en),
        ),
      ).called(1);
      expect(find.text('D1 stub'), findsOneWidget);
    });

    testWidgets('a doctor goes to E1', (tester) async {
      final router = GoRouter(
        initialLocation: '/sign-up',
        routes: [
          GoRoute(path: '/sign-up', builder: (_, _) => screen()),
          GoRoute(
            path: '/sign-up/practitioner/details',
            builder: (_, _) => const Text('E1 stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      await tester.tap(find.text('A doctor'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      verify(
        () => signUpBloc.add(
          const SignUpRoleChosen(role: Role.doctor, language: AppLanguage.en),
        ),
      ).called(1);
      expect(find.text('E1 stub'), findsOneWidget);
    });

    testWidgets('a pathologist goes to F1', (tester) async {
      final router = GoRouter(
        initialLocation: '/sign-up',
        routes: [
          GoRoute(path: '/sign-up', builder: (_, _) => screen()),
          GoRoute(
            path: '/sign-up/practitioner/details',
            builder: (_, _) => const Text('F1 stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      await tester.tap(find.text('A pathologist'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      verify(
        () => signUpBloc.add(
          const SignUpRoleChosen(
            role: Role.pathologist,
            language: AppLanguage.en,
          ),
        ),
      ).called(1);
      expect(find.text('F1 stub'), findsOneWidget);
    });

    testWidgets('keeping the same role sends no fresh event', (tester) async {
      when(
        () => signUpBloc.state,
      ).thenReturn(const SignUpState(draft: SignUpDraft(role: Role.patient)));
      final router = GoRouter(
        initialLocation: '/sign-up',
        routes: [
          GoRoute(path: '/sign-up', builder: (_, _) => screen()),
          GoRoute(
            path: '/sign-up/patient/name',
            builder: (_, _) => const Text('D1 stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      verifyNever(() => signUpBloc.add(any()));
      expect(find.text('D1 stub'), findsOneWidget);
    });

    testWidgets('back pops to A6', (tester) async {
      final router = GoRouter(
        initialLocation: '/get-started',
        routes: [
          GoRoute(
            path: '/get-started',
            builder: (context, _) => TextButton(
              onPressed: () => context.push('/sign-up'),
              child: const Text('to role'),
            ),
          ),
          GoRoute(path: '/sign-up', builder: (_, _) => screen()),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      await tester.tap(find.text('to role'));
      await tester.pumpAndSettle();
      expect(find.text("I'm joining Tabibu as…"), findsOneWidget);

      await tester.tap(find.byType(CircleIconButton));
      await tester.pumpAndSettle();
      expect(find.text('to role'), findsOneWidget);
    });

    testWidgets('as the root, it has no back button', (tester) async {
      final router = GoRouter(
        initialLocation: '/sign-up',
        routes: [GoRoute(path: '/sign-up', builder: (_, _) => screen())],
      );
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      expect(find.byType(CircleIconButton), findsNothing);
    });
  });
}
