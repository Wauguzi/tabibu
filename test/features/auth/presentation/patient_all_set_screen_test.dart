import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/role_helper.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/data/models/sign_up_draft.dart';
import 'package:tabibu/features/auth/presentation/patient_all_set_screen.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';

import '../../../helpers/helpers.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockSignUpBloc extends MockBloc<SignUpEvent, SignUpState>
    implements SignUpBloc {}

void main() {
  group('PatientAllSetScreen', () {
    late MockAuthBloc authBloc;
    late MockSignUpBloc signUpBloc;

    setUp(() {
      authBloc = MockAuthBloc();
      when(() => authBloc.state).thenReturn(
        SignUpSuccess(
          session: PatientSession(
            patient: PatientModel.empty().copyWith(firstName: 'Amina'),
            roles: const RoleHelper(
              role: Role.patient,
              isAdmin: false,
              isAlertApprover: false,
            ),
          ),
        ),
      );
      signUpBloc = MockSignUpBloc();
      when(
        () => signUpBloc.state,
      ).thenReturn(const SignUpState(draft: SignUpDraft(role: Role.patient)));
    });

    Widget screen() => MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<SignUpBloc>.value(value: signUpBloc),
      ],
      child: const PatientAllSetScreen(),
    );

    testWidgets('renders in light and dark', (tester) async {
      await tester.pumpApp(screen(), themeMode: ThemeMode.light);
      await tester.pumpAndSettle();
      expect(find.text('Karibu, Amina!'), findsOneWidget);

      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text('Karibu, Amina!'), findsOneWidget);
    });

    testWidgets('lays out at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('its button goes home', (tester) async {
      final router = GoRouter(
        initialLocation: '/account/all-set',
        routes: [
          GoRoute(path: '/account/all-set', builder: (_, _) => screen()),
          GoRoute(
            path: '/patient',
            builder: (_, _) => const Text('patient stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Go to my home'));
      await tester.pumpAndSettle();

      expect(find.text('patient stub'), findsOneWidget);
    });
  });
}
