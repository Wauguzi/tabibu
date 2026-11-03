import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_event.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_state.dart';
import 'package:tabibu/features/facilities/data/models/county_model.dart';
import 'package:tabibu/features/facilities/data/models/sub_county_model.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('AreaScreen', () {
    setUpAll(() {
      registerFallbackValue(
        const PatientAreaChanged(countyId: 0),
      );
      registerFallbackValue(const FacilitiesCountiesRequested());
    });

    // Tall enough that the lazy list builds every row.
    void tallView(WidgetTester tester) {
      tester.view.physicalSize = const Size(1170, 6000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
    }

    // Bottom sheets never settle.
    Future<void> settleSheet(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    List<CountyModel> counties() => const [
      CountyModel(id: 47, name: 'Nairobi'),
      CountyModel(id: 28, name: 'Mombasa'),
    ];

    List<SubCountyModel> subs() => const [
      SubCountyModel(
        id: 1,
        name: 'Embakasi',
        countyId: 47,
        latitude: 0,
        longitude: 0,
        geohash: '',
      ),
      SubCountyModel(
        id: 2,
        name: 'Westlands',
        countyId: 47,
        latitude: 0,
        longitude: 0,
        geohash: '',
      ),
    ];

    FeatureBlocs loadedBlocs() {
      final blocs = FeatureBlocs();
      whenListen(
        blocs.facilities,
        Stream.fromIterable([
          CountiesLoadSuccess(counties()),
          SubCountiesLoadSuccess(subs()),
        ]),
        initialState: const FacilitiesInitial(),
      );
      return blocs;
    }

    testWidgets('prefills the current area', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile/area',
        blocs: loadedBlocs(),
      );
      await tester.pumpAndSettle();

      expect(find.text('My area'), findsOneWidget);
      expect(
        find.text(
          'We use your area to show doctors nearby and health notices. '
          'We never track your location.',
        ),
        findsOneWidget,
      );
      // County value, sheet title excluded: the sheet is shut.
      expect(find.text('Nairobi'), findsOneWidget);
      expect(find.text('Embakasi'), findsOneWidget);
    });

    testWidgets('an unchanged save leaves without writing', (tester) async {
      tallView(tester);
      final bloc = await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile',
        blocs: loadedBlocs(),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('My area'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Your profile'), findsOneWidget);
      verifyNever(() => bloc.add(any()));
    });

    testWidgets('a new county saves its ids', (tester) async {
      tallView(tester);
      final bloc = await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile/area',
        blocs: loadedBlocs(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nairobi'));
      await settleSheet(tester);
      expect(find.text('County'), findsWidgets);
      await tester.tap(find.text('Mombasa'));
      await settleSheet(tester);

      // Mombasa has no bundled sub-counties: the field goes away.
      expect(find.text('Embakasi'), findsNothing);

      await tester.tap(find.text('Save'));
      // No answer: the button spins, so the tree never settles.
      await tester.pump();

      verify(
        () => bloc.add(
          const PatientAreaChanged(countyId: 28),
        ),
      ).called(1);
    });

    testWidgets('Nairobi without a sub-county is refused', (tester) async {
      tallView(tester);
      final bloc = await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile/area',
        blocs: loadedBlocs(),
      );
      await tester.pumpAndSettle();

      // Re-picking the county clears the sub-county.
      await tester.tap(find.text('Nairobi'));
      await settleSheet(tester);
      await tester.tap(find.text('Nairobi').last);
      await settleSheet(tester);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Pick your sub-county.'), findsOneWidget);
      verifyNever(() => bloc.add(any()));
    });

    testWidgets('a picked sub-county saves', (tester) async {
      tallView(tester);
      final bloc = await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile/area',
        blocs: loadedBlocs(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nairobi'));
      await settleSheet(tester);
      await tester.tap(find.text('Nairobi').last);
      await settleSheet(tester);

      await tester.tap(find.text('Sub-county'));
      await settleSheet(tester);
      await tester.tap(find.text('Westlands'));
      await settleSheet(tester);

      await tester.tap(find.text('Save'));
      await tester.pump();

      verify(
        () => bloc.add(const PatientAreaChanged(countyId: 47, subCountyId: 2)),
      ).called(1);
    });

    testWidgets('without a county Save asks for one', (tester) async {
      tallView(tester);
      final bloc = await tester.pumpRoleApp(
        PatientSession(
          patient: RoleSessions.patient.patient.copyWith(
            county: '',
            subCounty: '',
          ),
          roles: RoleSessions.patient.roles,
        ),
        '/patient/profile/area',
        blocs: loadedBlocs(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Pick your county.'), findsOneWidget);
      verifyNever(() => bloc.add(any()));
    });

    testWidgets('failed lists offer a retry', (tester) async {
      tallView(tester);
      final blocs = FeatureBlocs();
      whenListen(
        blocs.facilities,
        Stream.fromIterable([
          const CountiesLoadFailure(error: AppError.dataNotFound),
          const SubCountiesLoadFailure(error: AppError.dataNotFound),
        ]),
        initialState: const FacilitiesInitial(),
      );
      await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile/area',
        blocs: blocs,
      );
      await tester.pumpAndSettle();

      expect(find.text('Try again'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      // The screen's two requests, then the retry's two.
      verify(() => blocs.facilities.add(any())).called(4);
    });

    testWidgets('a saved area returns to the tab', (tester) async {
      tallView(tester);
      final answers = StreamController<AuthState>();
      addTearDown(answers.close);
      await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile',
        blocs: loadedBlocs(),
        answers: answers,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('My area'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nairobi'));
      await settleSheet(tester);
      await tester.tap(find.text('Mombasa'));
      await settleSheet(tester);
      await tester.tap(find.text('Save'));
      await tester.pump();
      answers.add(ProfileSaveSuccess(session: RoleSessions.patient));
      await tester.pumpAndSettle();

      expect(find.text('Your profile'), findsOneWidget);
    });

    testWidgets('a failed save says why and stays', (tester) async {
      tallView(tester);
      final answers = StreamController<AuthState>();
      addTearDown(answers.close);
      await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile/area',
        blocs: loadedBlocs(),
        answers: answers,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nairobi'));
      await settleSheet(tester);
      await tester.tap(find.text('Mombasa'));
      await settleSheet(tester);
      await tester.tap(find.text('Save'));
      await tester.pump();
      answers.add(
        ProfileSaveFailure(
          session: RoleSessions.patient,
          error: AppError.noInternet,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('No internet access.'), findsOneWidget);
      expect(find.text('My area'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('renders in Swahili in dark mode at 1.3x text', (
      tester,
    ) async {
      tallView(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      tester.platformDispatcher.localesTestValue = [const Locale('sw')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile/area',
        blocs: loadedBlocs(),
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      expect(find.text('Eneo langu'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
