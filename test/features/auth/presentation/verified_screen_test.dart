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
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/presentation/verified_screen.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';

import '../../../helpers/helpers.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

DoctorModel _doctor({bool isPathologist = false, String lastName = 'Kamau'}) =>
    DoctorModel.empty().copyWith(
      title: 'Dr.',
      lastName: lastName,
      isPathologist: isPathologist,
      specialties: ['Histopathology', 'Cytology'],
      kmpdcNumber: 'A 12345',
      facilityName: 'Aga Khan University Hospital',
      createdAt: '',
    );

PractitionerSession _session({
  bool isPathologist = false,
  String lastName = 'Kamau',
}) => PractitionerSession(
  doctor: _doctor(isPathologist: isPathologist, lastName: lastName),
  roles: RoleHelper(
    role: isPathologist ? Role.pathologist : Role.doctor,
    isAdmin: false,
    isAlertApprover: false,
  ),
);

void main() {
  group('VerifiedScreen', () {
    late MockAuthBloc authBloc;

    setUp(() {
      authBloc = MockAuthBloc();
      when(
        () => authBloc.state,
      ).thenReturn(SessionLoadSuccess(session: _session()));
    });

    Widget screen() => BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: const VerifiedScreen(),
    );

    testWidgets('renders in light and dark', (tester) async {
      await tester.pumpApp(screen(), themeMode: ThemeMode.light);
      await tester.pumpAndSettle();
      expect(find.text("You're verified, Dr. Kamau"), findsOneWidget);
      expect(find.text('All 4 steps done'), findsOneWidget);

      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text("You're verified, Dr. Kamau"), findsOneWidget);
    });

    testWidgets('lays out at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('the title uses the last name', (tester) async {
      when(
        () => authBloc.state,
      ).thenReturn(SessionLoadSuccess(session: _session(lastName: 'Otieno')));

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text("You're verified, Dr. Otieno"), findsOneWidget);
      expect(find.text('Finish my profile'), findsOneWidget);
    });

    testWidgets('a doctor goes to their day', (tester) async {
      final router = GoRouter(
        initialLocation: '/account/verified',
        routes: [
          GoRoute(path: '/account/verified', builder: (_, _) => screen()),
          GoRoute(
            path: '/doctor',
            builder: (_, _) => const Text('doctor stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Go to my day'));
      await tester.pumpAndSettle();

      expect(find.text('doctor stub'), findsOneWidget);
    });

    testWidgets('a pathologist sees the F5 copy', (tester) async {
      when(
        () => authBloc.state,
      ).thenReturn(SessionLoadSuccess(session: _session(isPathologist: true)));

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Your desk is open. Cases from Nairobi doctors in your areas '
          'start arriving now.',
        ),
        findsOneWidget,
      );
      expect(find.text('Go to my desk'), findsOneWidget);
    });

    testWidgets('a pathologist goes to their desk', (tester) async {
      when(
        () => authBloc.state,
      ).thenReturn(SessionLoadSuccess(session: _session(isPathologist: true)));

      final router = GoRouter(
        initialLocation: '/account/verified',
        routes: [
          GoRoute(path: '/account/verified', builder: (_, _) => screen()),
          GoRoute(
            path: '/pathologist',
            builder: (_, _) => const Text('pathologist stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      expect(
        find.text('Histopathology and cytology cases now reach your desk.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Go to my desk'));
      await tester.pumpAndSettle();

      expect(find.text('pathologist stub'), findsOneWidget);
    });
  });
}
