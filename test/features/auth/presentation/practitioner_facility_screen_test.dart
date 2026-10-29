import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_state.dart';
import 'package:tabibu/features/auth/data/models/sign_up_draft.dart';
import 'package:tabibu/features/auth/presentation/practitioner_facility_screen.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_bloc.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_event.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_state.dart';
import 'package:tabibu/features/facilities/data/models/facility_model.dart';

import '../../../helpers/helpers.dart';

class MockSignUpBloc extends MockBloc<SignUpEvent, SignUpState>
    implements SignUpBloc {}

class MockFacilitiesBloc extends MockBloc<FacilitiesEvent, FacilitiesState>
    implements FacilitiesBloc {}

FacilityModel _facility({
  required String id,
  required String name,
  required String type,
  required String level,
  bool operational = true,
}) => FacilityModel(
  facilityId: id,
  mflCode: '13013',
  name: name,
  kephLevel: level,
  facilityType: type,
  owner: 'Private',
  wardId: 1,
  ward: 'Parklands',
  subCountyId: 2,
  subCounty: 'Westlands',
  countyId: 47,
  county: 'Nairobi',
  latitude: 0,
  longitude: 0,
  geohash: '',
  isLocationApproximate: false,
  isLab: false,
  operationStatus: operational ? 'Operational' : 'Closed',
  isOperational: operational,
);

final FacilityModel _hospital = _facility(
  id: 'h1',
  name: 'Aga Khan University Hospital',
  type: 'Hospital',
  level: 'Level 6',
);
final FacilityModel _clinic = _facility(
  id: 'c1',
  name: 'Embakasi Clinic',
  type: 'Clinic',
  level: 'Level 3',
);
final FacilityModel _closed = _facility(
  id: 'x1',
  name: 'Closed Clinic',
  type: 'Clinic',
  level: 'Level 2',
  operational: false,
);

void main() {
  setUpAll(() {
    registerFallbackValue(const SignUpDraftUpdated(draft: SignUpDraft()));
  });

  group('PractitionerFacilityScreen', () {
    late MockSignUpBloc signUpBloc;
    late MockFacilitiesBloc facilitiesBloc;

    void stubResults(List<FacilityModel> results) {
      whenListen(
        facilitiesBloc,
        Stream.fromIterable([FacilitiesSearchSuccess(results)]),
        initialState: const FacilitiesInitial(),
      );
    }

    setUp(() {
      signUpBloc = MockSignUpBloc();
      when(
        () => signUpBloc.state,
      ).thenReturn(const SignUpState(draft: SignUpDraft(role: Role.doctor)));
      facilitiesBloc = MockFacilitiesBloc();
      stubResults([_hospital, _clinic, _closed]);
    });

    Widget screen() => MultiBlocProvider(
      providers: [
        BlocProvider<SignUpBloc>.value(value: signUpBloc),
        BlocProvider<FacilitiesBloc>.value(value: facilitiesBloc),
      ],
      child: const PractitionerFacilityScreen(),
    );

    testWidgets('renders in light and dark', (tester) async {
      await tester.pumpApp(screen(), themeMode: ThemeMode.light);
      await tester.pumpAndSettle();
      expect(find.text('Where do you practise?'), findsOneWidget);

      // The stream is spent; a fresh stub feeds the second pump.
      stubResults([_hospital, _clinic, _closed]);
      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text('Where do you practise?'), findsOneWidget);
    });

    testWidgets('lays out at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('filters come from the data', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Hospital'), findsOneWidget);
      expect(find.text('Clinic'), findsOneWidget);
      expect(find.text('Level 6'), findsOneWidget);
    });

    testWidgets('a filter narrows the cards', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hospital'));
      await tester.pumpAndSettle();

      expect(find.text('Aga Khan University Hospital'), findsOneWidget);
      expect(find.text('Embakasi Clinic'), findsNothing);
    });

    testWidgets('a closed facility cannot be chosen', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Closed Clinic'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Closed Clinic'), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Select a valid facility.'), findsOneWidget);
    });

    testWidgets('no facility shows its message', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Select a valid facility.'), findsOneWidget);
    });

    testWidgets('a choice commits and goes to E4', (tester) async {
      final router = GoRouter(
        initialLocation: '/sign-up/practitioner/facility',
        routes: [
          GoRoute(
            path: '/sign-up/practitioner/facility',
            builder: (_, _) => screen(),
          ),
          GoRoute(
            path: '/sign-up/practitioner/review',
            builder: (_, _) => const Text('E4 stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Aga Khan University Hospital'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(1), 'Surgeon');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      final updated =
          verify(() => signUpBloc.add(captureAny())).captured.single
              as SignUpDraftUpdated;
      expect(updated.draft.facilityId, 'h1');
      expect(updated.draft.bio, 'Surgeon');
      expect(updated.draft.isAvailable, isTrue);
      expect(find.text('E4 stub'), findsOneWidget);
    });

    testWidgets('empty results explain themselves', (tester) async {
      stubResults([]);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('No facilities found'), findsOneWidget);
    });

    testWidgets('a search failure shows its message', (tester) async {
      whenListen(
        facilitiesBloc,
        Stream.fromIterable([
          const FacilitiesSearchFailure(error: AppError.dataNotFound),
        ]),
        initialState: const FacilitiesInitial(),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('The requested data was not found.'), findsOneWidget);
    });

    testWidgets('a pathologist sees lab copy', (tester) async {
      when(() => signUpBloc.state).thenReturn(
        const SignUpState(draft: SignUpDraft(role: Role.pathologist)),
      );

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('Which lab do you report from?'), findsOneWidget);
      expect(find.text('Accepting new cases'), findsOneWidget);
    });
  });
}
