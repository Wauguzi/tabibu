import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/themes/blocs/theme_bloc/theme_event.dart';

import '../../../helpers/helpers.dart';

void main() {
  setUpAll(
    () => registerFallbackValue(
      const ThemeChangeRequested(preference: ThemePreference.system),
    ),
  );

  group('ThemeScreen', () {
    // Tall enough that the lazy list builds every row.
    void tallView(WidgetTester tester) {
      tester.view.physicalSize = const Size(1170, 6000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
    }

    bool selected(WidgetTester tester, String title) => tester
        .widgetList<OptionCard>(find.byType(OptionCard))
        .firstWhere((card) => card.title == title)
        .selected;

    testWidgets('a patient reads their bodies and picks dark', (tester) async {
      tallView(tester);
      final blocs = FeatureBlocs();
      await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile',
        blocs: blocs,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      expect(find.text('Best in bright places'), findsOneWidget);
      expect(
        find.text('Easier on the eyes at night, saves battery'),
        findsOneWidget,
      );
      expect(find.text('Same as my phone'), findsOneWidget);
      expect(selected(tester, 'Light'), isTrue);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(selected(tester, 'Dark'), isTrue);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      verify(
        () => blocs.theme.add(
          const ThemeChangeRequested(preference: ThemePreference.dark),
        ),
      ).called(1);
      expect(find.text('Your profile'), findsOneWidget);
    });

    testWidgets('a doctor reads the clinician bodies', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(RoleSessions.doctor(), '/doctor/profile/theme');
      await tester.pumpAndSettle();

      expect(find.text('Best in bright clinics and wards'), findsOneWidget);
      expect(find.text('Easier on the eyes on night shifts'), findsOneWidget);
      expect(find.text('Best in bright places'), findsNothing);
    });

    testWidgets('Save leaves after the theme frame, not before', (
      tester,
    ) async {
      tallView(tester);
      final blocs = FeatureBlocs();
      await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile',
        blocs: blocs,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      // The change is sent, the screen is still here: the pop waits a frame.
      verify(() => blocs.theme.add(any())).called(1);
      expect(find.text('Save'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('Your profile'), findsOneWidget);
    });

    testWidgets('Save leaves at once', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(RoleSessions.patient, '/patient/profile');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Your profile'), findsOneWidget);
    });

    testWidgets('renders in Swahili in dark mode at 1.3x text', (tester) async {
      tallView(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      tester.platformDispatcher.localesTestValue = [const Locale('sw')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile/theme',
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      expect(find.text('Mandhari'), findsOneWidget);
      expect(find.text('Kama simu yangu'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
