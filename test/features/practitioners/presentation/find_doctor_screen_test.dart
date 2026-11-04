import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_bloc.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_state.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/features/practitioners/presentation/find_doctor_screen.dart';
import 'package:tabibu/features/practitioners/presentation/widgets/doctor_grid_card.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

/// Phone-width, very tall surface so the sliver list mounts every row.
void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 6000);
  tester.view.devicePixelRatio = 3;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

PractitionerModel _doctor({
  required String uid,
  required String firstName,
  required String lastName,
  required String specialty,
}) => PractitionerModel(
  uid: uid,
  title: 'Dr.',
  firstName: firstName,
  lastName: lastName,
  profilePictureUrl: '',
  isPathologist: false,
  specialties: [specialty],
  bio: '',
  facilityId: '',
  facilityMflCode: '',
  facilityName: 'Aga Khan',
  county: 'Nairobi',
  subCounty: 'Embakasi',
  geohash: '',
  isAvailable: true,
  appointmentsHandled: 0,
  ordersCreated: 0,
  reportsSigned: 0,
  lastUpdatedAt: '',
);

void main() {
  group('FindDoctorScreen', () {
    late MockDirectoryBloc directory;
    late MockAuthBloc authBloc;

    final doctors = [
      _doctor(
        uid: 'd1',
        firstName: 'Wanjiru',
        lastName: 'Kamau',
        specialty: 'General surgery',
      ),
      _doctor(
        uid: 'd2',
        firstName: 'James',
        lastName: 'Otieno',
        specialty: 'General practice',
      ),
      _doctor(
        uid: 'd3',
        firstName: 'Achieng',
        lastName: 'Odhiambo',
        specialty: 'Paediatrics',
      ),
      _doctor(
        uid: 'd4',
        firstName: 'Grace',
        lastName: 'Wambui',
        specialty: 'Obstetrics and gynaecology',
      ),
      _doctor(
        uid: 'd5',
        firstName: 'Amina',
        lastName: 'Kamau',
        specialty: 'Unknown specialty',
      ),
    ];

    setUp(() {
      directory = MockDirectoryBloc();
      when(
        () => directory.state,
      ).thenReturn(DirectoryLoadSuccess(all: doctors, visible: doctors));
      authBloc = MockAuthBloc();
      when(() => authBloc.state).thenReturn(
        SignInSuccess(
          session: PatientSession(
            patient: RoleSessions.patient.patient.copyWith(uid: 'patient-1'),
            roles: RoleSessions.patient.roles,
          ),
        ),
      );
    });

    Widget screen() => MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<DirectoryBloc>.value(value: directory),
      ],
      child: const FindDoctorScreen(),
    );

    GoRouter router() {
      final routes = GoRouter(
        initialLocation: '/find',
        routes: [
          GoRoute(path: '/find', builder: (_, _) => screen()),
          GoRoute(
            path: '/patient/doctors/:doctorUid',
            builder: (_, state) =>
                Text('stub profile ${state.pathParameters['doctorUid']}'),
          ),
        ],
      );
      addTearDown(routes.dispose);
      return routes;
    }

    testWidgets('dispatches the directory request on open', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      verify(() => directory.add(const DirectoryRequested())).called(1);
    });

    testWidgets('leaves the keyboard down on open', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.focusNode.hasFocus, isFalse);
    });

    testWidgets('94: a tap outside the search field dismisses the keyboard', (
      tester,
    ) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      final search = find.byType(TextField);
      await tester.tap(search);
      await tester.pump();
      final node = tester.widget<TextField>(search).focusNode!;
      expect(node.hasPrimaryFocus, isTrue);
      expect(tester.testTextInput.isVisible, isTrue);

      await tester.tap(find.text('KMPDC verified doctors near Embakasi'));
      await tester.pump();
      expect(node.hasPrimaryFocus, isFalse);
      expect(tester.testTextInput.isVisible, isFalse);
    });

    testWidgets('shows title, chips and the grid', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('Find a doctor'), findsNWidgets(2));
      expect(find.text('KMPDC verified doctors near Embakasi'), findsOneWidget);
      expect(find.byType(SearchField), findsOneWidget);
      for (final chip in [
        'All',
        'General practice',
        'General surgery',
        'Obstetrics and gynaecology',
        'Paediatrics',
      ]) {
        expect(find.widgetWithText(TabibuFilterChip, chip), findsOneWidget);
      }
      expect(find.byType(TabibuFilterChip), findsNWidgets(5));
      expect(find.byType(DoctorGridCard), findsNWidgets(5));
      expect(find.text('Dr. Wanjiru Kamau'), findsOneWidget);
      expect(find.text('Dr. Amina Kamau'), findsOneWidget);
      expect(find.text('Unknown specialty'), findsOneWidget);
    });

    testWidgets('typing dispatches the query', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EditableText), 'Kamau');
      await tester.pump();

      verify(
        () => directory.add(const DirectoryQueryChanged(query: 'Kamau')),
      ).called(1);
    });

    testWidgets('a chip filters by specialty', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      final chip = find.widgetWithText(TabibuFilterChip, 'Paediatrics');
      await tester.scrollUntilVisible(
        chip,
        200,
        scrollable: find.descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.tap(chip);
      await tester.pump();

      verify(
        () => directory.add(
          const DirectoryQueryChanged(
            query: '',
            specialty: Specialty.paediatrics,
          ),
        ),
      ).called(1);
    });

    testWidgets('All clears the chip', (tester) async {
      _useTallSurface(tester);
      when(() => directory.state).thenReturn(
        DirectoryLoadSuccess(
          all: doctors,
          visible: doctors,
          specialty: Specialty.paediatrics,
        ),
      );
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('All'));
      await tester.pump();

      verify(
        () => directory.add(const DirectoryQueryChanged(query: '')),
      ).called(1);
    });

    testWidgets('a card pushes the profile route', (tester) async {
      _useTallSurface(tester);
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dr. Achieng Odhiambo'));
      await tester.pumpAndSettle();

      expect(find.text('stub profile d3'), findsOneWidget);
    });

    testWidgets('no results shows the empty state and clears', (tester) async {
      _useTallSurface(tester);
      when(
        () => directory.state,
      ).thenReturn(DirectoryLoadSuccess(all: doctors, query: 'thyroid'));
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), 'thyroid');
      await tester.pump();

      expect(find.text('No doctors match "thyroid"'), findsOneWidget);
      expect(
        find.text('Check the spelling, or search by hospital or town.'),
        findsOneWidget,
      );
      expect(find.text('Try this'), findsOneWidget);
      expect(
        find.text('Try a specialty, like "breast surgeon"'),
        findsOneWidget,
      );
      expect(find.text('Search a hospital: Aga Khan, KNH'), findsOneWidget);
      expect(find.text('Or browse doctors near Embakasi'), findsOneWidget);
      expect(find.byType(TabibuFilterChip), findsNothing);
      // Nothing near enough to suggest.
      expect(find.byType(SuggestionPill), findsOneWidget);

      await tester.tap(find.text('Clear search'));
      await tester.pump();

      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        isEmpty,
      );
      verify(
        () => directory.add(const DirectoryQueryChanged(query: '')),
      ).called(1);
    });

    testWidgets('a near miss offers its suggestion', (tester) async {
      _useTallSurface(tester);
      when(
        () => directory.state,
        // cspell:disable-next-line -- the test needs a misspelled query.
      ).thenReturn(DirectoryLoadSuccess(all: doctors, query: 'Wanjiruu'));
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('Dr. Wanjiru Kamau'), findsOneWidget);

      await tester.tap(find.text('Dr. Wanjiru Kamau'));
      await tester.pump();

      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        'Dr. Wanjiru Kamau',
      );
      verify(
        () => directory.add(
          const DirectoryQueryChanged(query: 'Dr. Wanjiru Kamau'),
        ),
      ).called(1);
    });

    testWidgets('offline shows the banner above the cached grid', (
      tester,
    ) async {
      _useTallSurface(tester);
      when(() => directory.state).thenReturn(
        DirectoryLoadSuccess(all: doctors, visible: doctors, offline: true),
      );
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text("You're offline"), findsOneWidget);
      expect(find.text('Showing your saved doctors.'), findsOneWidget);
      expect(find.byType(DoctorGridCard), findsNWidgets(5));

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => directory.add(const DirectoryRefreshed())).called(1);
    });

    testWidgets('loading with nothing cached shows the spinner', (
      tester,
    ) async {
      _useTallSurface(tester);
      when(() => directory.state).thenReturn(const DirectoryLoadInProgress());
      await tester.pumpApp(screen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Find a doctor'), findsNWidgets(2));
      expect(find.byType(LoadingView), findsOneWidget);
      expect(find.byType(DoctorGridCard), findsNothing);
    });

    testWidgets('renders in dark mode', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();

      expect(find.text('Find a doctor'), findsNWidgets(2));
      expect(find.byType(DoctorGridCard), findsNWidgets(5));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in Swahili', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen(), locale: const Locale('sw'));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(FindDoctorScreen)),
      );
      expect(find.text(l10n.findDoctorTitle), findsNWidgets(2));
      expect(find.text(l10n.findDoctorSubtitle('Embakasi')), findsOneWidget);
      expect(find.text('Zote'), findsOneWidget);
      expect(find.text(Specialty.paediatrics.description(l10n)), findsWidgets);
      expect(find.text('Dr. Wanjiru Kamau'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays out at 1.3x text without overflow', (tester) async {
      _useTallSurface(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('Find a doctor'), findsNWidgets(2));
      expect(find.byType(DoctorGridCard), findsNWidgets(5));
      expect(tester.takeException(), isNull);
    });
  });
}
