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
  String owner = 'Private Practice - General Practitioner',
  bool operational = true,
}) => FacilityModel(
  facilityId: id,
  mflCode: '13013',
  name: name,
  kephLevel: level,
  facilityType: type,
  owner: owner,
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
  type: 'Medical Clinic',
  level: 'Level 3',
);
final FacilityModel _closed = _facility(
  id: 'x1',
  name: 'Closed Clinic',
  type: 'Medical Clinic',
  level: 'Level 2',
  operational: false,
);
final FacilityModel _healthCentre = _facility(
  id: 'h2',
  name: 'Dandora Health Centre',
  type: 'Basic Health Centre',
  level: 'Level 3',
);
final FacilityModel _dispensary = _facility(
  id: 'd1',
  name: 'Kawangware Dispensary',
  type: 'Dispensary',
  level: 'Level 2',
);
final FacilityModel _pharmacy = _facility(
  id: 'p1',
  name: 'Muthurwa Pharmacy',
  type: 'Pharmacy',
  level: 'Level 2',
);
final FacilityModel _lab = _facility(
  id: 'l1',
  name: 'Lancet Pathologists',
  type: 'Laboratory',
  level: 'Level 3',
  owner: 'Ministry of Health',
);
final FacilityModel _labTwo = _facility(
  id: 'l2',
  name: 'Metropolis Lab',
  type: 'Laboratory',
  level: 'Level 5',
);
final FacilityModel _hospitalLow = _facility(
  id: 'h3',
  name: 'Pumwani Hospital',
  type: 'Hospital',
  level: 'Level 4',
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

    Future<void> tapChip(WidgetTester tester, String label) async {
      await tester.ensureVisible(find.text(label));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    // The outer list's Scrollable: the chips and the bio field scroll too.
    Finder listScrollable() => find.ancestor(
      of: find.byType(SliverList),
      matching: find.byType(Scrollable),
    );

    void asPathologist() {
      when(() => signUpBloc.state).thenReturn(
        const SignUpState(draft: SignUpDraft(role: Role.pathologist)),
      );
    }

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

    testWidgets('lays out in Swahili at 2.0x with an error', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(screen(), locale: const Locale('sw'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TabibuButton));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('group chips come from the code, level chips from the data', (
      tester,
    ) async {
      stubResults([_hospital, _clinic, _healthCentre, _dispensary]);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Hospital'), findsOneWidget);
      expect(find.text('Health centre'), findsOneWidget);
      expect(find.text('Clinic'), findsOneWidget);
      expect(find.text('Dispensary'), findsOneWidget);
      expect(find.text('Level 2'), findsOneWidget);
      expect(find.text('Level 3'), findsOneWidget);
      expect(find.text('Level 6'), findsOneWidget);
      expect(find.text('Level 4'), findsNothing);
    });

    testWidgets('chips filter and combine', (tester) async {
      stubResults([_hospital, _clinic, _healthCentre, _dispensary]);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tapChip(tester, 'Clinic');
      expect(find.text('Embakasi Clinic'), findsOneWidget);
      expect(find.text('Aga Khan University Hospital'), findsNothing);

      await tapChip(tester, 'Level 3');
      expect(find.text('Embakasi Clinic'), findsOneWidget);

      await tapChip(tester, 'Level 6');
      expect(find.text('Embakasi Clinic'), findsNothing);
      expect(find.text('No facilities found'), findsOneWidget);

      await tapChip(tester, 'All');
      expect(find.text('Embakasi Clinic'), findsOneWidget);
      expect(find.text('Aga Khan University Hospital'), findsOneWidget);
    });

    testWidgets('with no query the highest level comes first', (tester) async {
      stubResults([_healthCentre, _clinic, _hospital]);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Embakasi Clinic'),
        200,
        scrollable: listScrollable(),
      );
      final rows = [
        'Aga Khan University Hospital',
        'Dandora Health Centre',
        'Embakasi Clinic',
      ].map((name) => tester.getTopLeft(find.text(name)).dy).toList();
      expect(rows, orderedEquals([...rows]..sort()));
    });

    testWidgets('pharmacies and labs are absent', (tester) async {
      stubResults([_hospital, _pharmacy, _lab]);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('Aga Khan University Hospital'), findsOneWidget);
      expect(find.text('Muthurwa Pharmacy'), findsNothing);
      expect(find.text('Lancet Pathologists'), findsNothing);
    });

    testWidgets('a closed facility cannot be chosen', (tester) async {
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Closed Clinic'),
        200,
        scrollable: listScrollable(),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Closed Clinic'), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Select a valid facility.'),
        -200,
        scrollable: listScrollable(),
      );
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
      final bioField = find.descendant(
        of: find.byType(TabibuTextField),
        matching: find.byType(TextField),
      );
      await tester.scrollUntilVisible(
        bioField,
        200,
        scrollable: listScrollable(),
      );
      await tester.enterText(bioField, 'Surgeon');
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
      asPathologist();

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('Which lab do you report from?'), findsOneWidget);
      expect(find.text('Accepting new cases'), findsOneWidget);
      expect(
        find.text(
          'Report from more than one lab? '
          'You can add others later in your profile.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a pathologist sees labs and hospitals only', (tester) async {
      asPathologist();
      stubResults([_lab, _labTwo, _hospital, _hospitalLow, _clinic, _pharmacy]);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Pumwani Hospital'),
        200,
        scrollable: listScrollable(),
      );
      expect(find.text('Lancet Pathologists'), findsOneWidget);
      expect(find.text('Metropolis Lab'), findsOneWidget);
      expect(find.text('Aga Khan University Hospital'), findsOneWidget);
      expect(find.text('Pumwani Hospital'), findsOneWidget);
      expect(find.text('Embakasi Clinic'), findsNothing);
      expect(find.text('Muthurwa Pharmacy'), findsNothing);
    });

    testWidgets('pathologist chips filter and combine', (tester) async {
      asPathologist();
      stubResults([_lab, _labTwo, _hospital, _hospitalLow]);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('Labs'), findsOneWidget);
      expect(find.text('Hospitals'), findsOneWidget);
      expect(find.text('Level 5'), findsOneWidget);

      await tapChip(tester, 'Labs');
      expect(find.text('Metropolis Lab'), findsOneWidget);
      expect(find.text('Aga Khan University Hospital'), findsNothing);

      await tapChip(tester, 'Level 5');
      expect(find.text('Metropolis Lab'), findsOneWidget);
      expect(find.text('Lancet Pathologists'), findsNothing);

      await tapChip(tester, 'All');
      expect(find.text('Lancet Pathologists'), findsOneWidget);
      expect(find.text('Pumwani Hospital'), findsOneWidget);
    });

    testWidgets('pathologist rows show ownership, level and sub-county', (
      tester,
    ) async {
      asPathologist();
      stubResults([_hospital, _lab]);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('Private · Level 6 · Westlands'), findsOneWidget);
      expect(find.text('Public · Level 3 · Westlands'), findsOneWidget);
    });

    testWidgets('pathologist order is labs first, then level, then name', (
      tester,
    ) async {
      asPathologist();
      stubResults([_hospital, _lab, _hospitalLow, _labTwo]);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Pumwani Hospital'),
        200,
        scrollable: listScrollable(),
      );
      final rows = [
        'Metropolis Lab',
        'Lancet Pathologists',
        'Aga Khan University Hospital',
        'Pumwani Hospital',
      ].map((name) => tester.getTopLeft(find.text(name)).dy).toList();
      expect(rows, orderedEquals([...rows]..sort()));
    });

    testWidgets('back keeps the facility in the draft', (tester) async {
      await pumpUnderStub(tester, screen());
      await tester.tap(find.text('Aga Khan University Hospital'));
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Previous step'), findsOneWidget);
      expect(committedDraft(signUpBloc).facilityId, 'h1');
    });

    testWidgets('builds only the facility cards on screen', (tester) async {
      stubResults([
        for (var i = 0; i < 200; i++)
          _facility(
            id: 'f$i',
            name: 'Facility ${i.toString().padLeft(3, '0')}',
            type: 'Hospital',
            level: 'Level 4',
          ),
      ]);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.byType(OptionCard).evaluate().length, lessThan(200));

      await tester.scrollUntilVisible(
        find.text('Facility 199'),
        500,
        scrollable: listScrollable(),
      );
      expect(find.text('Facility 199'), findsOneWidget);
    });
  });
}
