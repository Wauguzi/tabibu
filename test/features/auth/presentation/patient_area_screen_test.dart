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
import 'package:tabibu/features/auth/presentation/patient_area_screen.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_bloc.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_event.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_state.dart';
import 'package:tabibu/features/facilities/data/models/county_model.dart';
import 'package:tabibu/features/facilities/data/models/sub_county_model.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';

import '../../../helpers/helpers.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockSignUpBloc extends MockBloc<SignUpEvent, SignUpState>
    implements SignUpBloc {}

class MockFacilitiesBloc extends MockBloc<FacilitiesEvent, FacilitiesState>
    implements FacilitiesBloc {}

const _nairobi = CountyModel(id: 47, name: 'Nairobi');
const _mombasa = CountyModel(id: 1, name: 'Mombasa');
const _embakasi = SubCountyModel(
  id: 10,
  name: 'Embakasi',
  countyId: 47,
  latitude: 0,
  longitude: 0,
  geohash: '',
);
const _westlands = SubCountyModel(
  id: 11,
  name: 'Westlands',
  countyId: 47,
  latitude: 0,
  longitude: 0,
  geohash: '',
);

const _draft = SignUpDraft(
  role: Role.patient,
  firstName: 'Amina',
  lastName: 'Wambui',
  sex: Sex.female,
  dateOfBirth: '1980-03-14',
  phoneNumber: '+254712345678',
);

void main() {
  setUpAll(() {
    registerFallbackValue(const SignUpDraftUpdated(draft: SignUpDraft()));
    registerFallbackValue(const PatientSignUpRequested(draft: SignUpDraft()));
  });

  group('PatientAreaScreen', () {
    late MockAuthBloc authBloc;
    late MockSignUpBloc signUpBloc;
    late MockFacilitiesBloc facilitiesBloc;

    setUp(() {
      authBloc = MockAuthBloc();
      when(() => authBloc.state).thenReturn(
        const SignInSuccess(session: SignUpIncompleteSession(email: 'a@b.co')),
      );
      signUpBloc = MockSignUpBloc();
      when(() => signUpBloc.state).thenReturn(const SignUpState(draft: _draft));
      facilitiesBloc = MockFacilitiesBloc();
      whenListen(
        facilitiesBloc,
        Stream.fromIterable([
          const CountiesLoadSuccess([_nairobi, _mombasa]),
          const SubCountiesLoadSuccess([_embakasi, _westlands]),
        ]),
        initialState: const FacilitiesInitial(),
      );
    });

    Widget screen() => MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<SignUpBloc>.value(value: signUpBloc),
        BlocProvider<FacilitiesBloc>.value(value: facilitiesBloc),
      ],
      child: const PatientAreaScreen(),
    );

    Future<void> pumpUnderStub(WidgetTester tester, Widget step) async {
      final router = GoRouter(
        initialLocation: '/previous/step',
        routes: [
          GoRoute(
            path: '/previous',
            builder: (_, _) => const Text('Previous step'),
            routes: [GoRoute(path: 'step', builder: (_, _) => step)],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();
    }

    SignUpDraft committedDraft(MockSignUpBloc bloc) {
      final captured = verify(() => bloc.add(captureAny())).captured;
      return (captured.last as SignUpDraftUpdated).draft;
    }

    Future<void> chooseCounty(WidgetTester tester, String name) async {
      await tester.tap(find.text('Choose your county'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(name).last);
      await tester.pumpAndSettle();
    }

    testWidgets('renders in light and dark', (tester) async {
      await tester.pumpApp(screen(), themeMode: ThemeMode.light);
      await tester.pumpAndSettle();
      expect(find.text('Where do you live?'), findsOneWidget);

      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text('Where do you live?'), findsOneWidget);
    });

    testWidgets('lays out at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('no county shows its message', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      expect(find.text('Select a valid county.'), findsOneWidget);
    });

    testWidgets('Nairobi offers sub-counties and submits both', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      await chooseCounty(tester, 'Nairobi');

      expect(find.text('Embakasi'), findsOneWidget);
      await tester.tap(find.text('Embakasi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      final submitted =
          verify(() => authBloc.add(captureAny())).captured.single
              as PatientSignUpRequested;
      expect(submitted.draft.countyId, 47);
      expect(submitted.draft.subCountyId, 10);
    });

    testWidgets('outside Nairobi submits the county only', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      await chooseCounty(tester, 'Mombasa');

      expect(find.text('Embakasi'), findsNothing);
      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      final submitted =
          verify(() => authBloc.add(captureAny())).captured.single
              as PatientSignUpRequested;
      expect(submitted.draft.countyId, 1);
      expect(submitted.draft.subCountyId, isNull);
    });

    testWidgets('a sign-up failure shows its message', (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          const SignUpFailure(
            session: SignUpIncompleteSession(email: 'a@b.co'),
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

    testWidgets('a patient goes to D5', (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
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
        ]),
      );

      final router = GoRouter(
        initialLocation: '/sign-up/patient/area',
        routes: [
          GoRoute(path: '/sign-up/patient/area', builder: (_, _) => screen()),
          GoRoute(
            path: '/account/all-set',
            builder: (_, _) => const Text('D5 stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      expect(find.text('D5 stub'), findsOneWidget);
    });

    testWidgets('a clinic record goes to its notice', (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([
          const SignUpSuccess(session: ClinicRecordExistsSession()),
        ]),
      );

      final router = GoRouter(
        initialLocation: '/sign-up/patient/area',
        routes: [
          GoRoute(path: '/sign-up/patient/area', builder: (_, _) => screen()),
          GoRoute(
            path: '/account/clinic-record',
            builder: (_, _) => const Text('clinic stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      expect(find.text('clinic stub'), findsOneWidget);
    });

    testWidgets('back keeps the county in the draft', (tester) async {
      await pumpUnderStub(tester, screen());
      await chooseCounty(tester, 'Mombasa');

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Previous step'), findsOneWidget);
      expect(committedDraft(signUpBloc).countyId, 1);
    });
  });
}
