import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/role_helper.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/presentation/pending_verification_screen.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';

import '../../../helpers/helpers.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

DoctorModel _doctor({
  bool isPathologist = false,
  String verificationStatus = 'Pending',
  List<String> specialties = const ['Histopathology', 'Cytology'],
}) => DoctorModel.empty().copyWith(
  firstName: 'Wanjiru',
  lastName: 'Kamau',
  isPathologist: isPathologist,
  specialties: specialties,
  kmpdcNumber: 'A 12345',
  verificationStatus: verificationStatus,
  facilityName: 'Aga Khan University Hospital',
  subCounty: 'Westlands',
  createdAt: '',
);

void main() {
  group('PendingVerificationScreen', () {
    late MockAuthBloc authBloc;

    setUp(() {
      authBloc = MockAuthBloc();
      when(() => authBloc.state).thenReturn(
        SignInSuccess(session: PendingVerificationSession(doctor: _doctor())),
      );
    });

    Widget screen() => BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: const PendingVerificationScreen(),
    );

    testWidgets('renders in light and dark', (tester) async {
      await tester.pumpApp(screen(), themeMode: ThemeMode.light);
      await tester.pumpAndSettle();
      expect(find.text("We're checking your details"), findsOneWidget);
      expect(find.text('Details submitted'), findsOneWidget);
      expect(find.text('Licence check with KMPDC'), findsOneWidget);
      expect(find.text('Step 2 of 4'), findsOneWidget);

      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text("We're checking your details"), findsOneWidget);
    });

    testWidgets('lays out in Swahili at 2.0x with an error', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final session = PendingVerificationSession(doctor: _doctor());
      whenListen(
        authBloc,
        Stream.fromIterable([
          SignOutFailure(session: session, error: AppError.noInternet),
        ]),
        initialState: SignInSuccess(session: session),
      );

      await tester.pumpApp(screen(), locale: const Locale('sw'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('the timeline chips read Done, In progress, Up next', (
      tester,
    ) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('Done'), findsOneWidget);
      expect(find.text('In progress'), findsOneWidget);
      expect(find.text('Up next'), findsNWidgets(2));
    });

    testWidgets('Check again sits above Sign out, the way out', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(find.text('Check again')).dy,
        lessThan(tester.getTopLeft(find.text('Sign out')).dy),
      );
      expect(find.text('Explore Tabibu'), findsNothing);
      expect(find.text('Contact support'), findsNothing);
    });

    // Cupertino sheet routes never settle.
    Future<void> settleSheet(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    testWidgets('Sign out asks first, then signs out', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign out'));
      await settleSheet(tester);
      expect(find.text('Sign out of Tabibu?'), findsOneWidget);
      verifyNever(() => authBloc.add(const SignOutRequested()));

      await tester.tap(
        find.descendant(
          of: find.byType(TabibuBottomSheet),
          matching: find.text('Sign out'),
        ),
      );
      await settleSheet(tester);

      verify(() => authBloc.add(const SignOutRequested())).called(1);
    });

    testWidgets('a check that finds no change says so', (tester) async {
      final session = PendingVerificationSession(doctor: _doctor());
      whenListen(
        authBloc,
        Stream.fromIterable([
          SessionLoadInProgress(session: session),
          SessionLoadSuccess(session: session),
        ]),
        initialState: SignInSuccess(session: session),
      );

      await tester.pumpApp(screen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text("Not verified yet. We'll let you know the moment it's done."),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('a check that finds a rejection does not say "not yet"', (
      tester,
    ) async {
      final session = PendingVerificationSession(
        doctor: _doctor(verificationStatus: 'Rejected'),
      );
      whenListen(
        authBloc,
        Stream.fromIterable([
          SessionLoadInProgress(session: session),
          SessionLoadSuccess(session: session),
        ]),
        initialState: SignInSuccess(session: session),
      );

      await tester.pumpApp(screen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text("Not verified yet. We'll let you know the moment it's done."),
        findsNothing,
      );
      expect(find.text("Verification didn't pass"), findsOneWidget);
    });

    testWidgets('a failed sign-out says why', (tester) async {
      final session = PendingVerificationSession(doctor: _doctor());
      whenListen(
        authBloc,
        Stream.fromIterable([
          SignOutFailure(session: session, error: AppError.noInternet),
        ]),
        initialState: SignInSuccess(session: session),
      );

      await tester.pumpApp(screen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('No internet access.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('check again refreshes the session', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Check again'));
      await tester.pumpAndSettle();

      verify(
        () => authBloc.add(const SessionRequested(forceRefresh: true)),
      ).called(1);
    });

    testWidgets('a verified session goes to E6', (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          SignUpSuccess(
            session: PractitionerSession(
              doctor: _doctor(),
              roles: const RoleHelper(
                role: Role.doctor,
                isAdmin: false,
                isAlertApprover: false,
              ),
            ),
          ),
          SessionLoadSuccess(
            session: PractitionerSession(
              doctor: _doctor(),
              roles: const RoleHelper(
                role: Role.doctor,
                isAdmin: false,
                isAlertApprover: false,
              ),
            ),
          ),
        ]),
      );

      final router = GoRouter(
        initialLocation: '/account/pending',
        routes: [
          GoRoute(path: '/account/pending', builder: (_, _) => screen()),
          GoRoute(
            path: '/account/verified',
            builder: (_, _) => const Text('verified stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      expect(find.text('verified stub'), findsOneWidget);
    });

    testWidgets('a rejected profile shows its state', (tester) async {
      when(() => authBloc.state).thenReturn(
        SignInSuccess(
          session: PendingVerificationSession(
            doctor: _doctor(verificationStatus: 'Rejected'),
          ),
        ),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text("Verification didn't pass"), findsOneWidget);
      expect(find.text("We're checking your details"), findsNothing);
    });

    testWidgets('a pathologist sees lab rows', (tester) async {
      when(() => authBloc.state).thenReturn(
        SignInSuccess(
          session: PendingVerificationSession(
            doctor: _doctor(isPathologist: true),
          ),
        ),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('Lab confirmed'), findsOneWidget);
      expect(
        find.text(
          'Cases in histopathology and cytology start reaching your desk.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('one area reads as a single-item sentence', (tester) async {
      when(() => authBloc.state).thenReturn(
        SignInSuccess(
          session: PendingVerificationSession(
            doctor: _doctor(
              isPathologist: true,
              specialties: const ['Histopathology'],
            ),
          ),
        ),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(
        find.text('Cases in histopathology start reaching your desk.'),
        findsOneWidget,
      );
    });

    testWidgets('three areas join with commas and and', (tester) async {
      when(() => authBloc.state).thenReturn(
        SignInSuccess(
          session: PendingVerificationSession(
            doctor: _doctor(
              isPathologist: true,
              specialties: const ['Histopathology', 'Cytology', 'Haematology'],
            ),
          ),
        ),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Cases in histopathology, cytology and haematology start '
          'reaching your desk.',
        ),
        findsOneWidget,
      );
    });
  });
}
