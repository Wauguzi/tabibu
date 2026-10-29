import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../helpers/helpers.dart';

void main() {
  group('FloatingTabBar', () {
    final tabs = [
      FloatingTab(icon: Assets.icons.homeIcon, label: 'Home'),
      FloatingTab(icon: Assets.icons.appointmentsIcon, label: 'Appointments'),
      FloatingTab(icon: Assets.icons.resultsIcon, label: 'Results'),
      FloatingTab(icon: Assets.icons.personIcon, label: 'Profile'),
    ];

    Future<List<int>> pump(
      WidgetTester tester, {
      int current = 0,
      ThemeMode themeMode = ThemeMode.light,
    }) async {
      final taps = <int>[];
      await tester.pumpApp(
        Align(
          alignment: .bottomCenter,
          child: FloatingTabBar(
            tabs: tabs,
            currentIndex: current,
            onSelected: taps.add,
          ),
        ),
        themeMode: themeMode,
      );
      await tester.pumpAndSettle();
      return taps;
    }

    testWidgets('labels only the selected tab', (tester) async {
      await pump(tester, current: 1);

      expect(find.text('Appointments'), findsOneWidget);
      expect(find.text('Home'), findsNothing);
      expect(find.text('Profile'), findsNothing);
    });

    testWidgets('every tab keeps its label for screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester);

      for (final label in ['Home', 'Appointments', 'Results', 'Profile']) {
        expect(find.bySemanticsLabel(label), findsOneWidget);
      }
      expect(
        tester.getSemantics(find.bySemanticsLabel('Home')),
        matchesSemantics(
          label: 'Home',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          hasTapAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('reports the tapped tab', (tester) async {
      final taps = await pump(tester);

      await tester.tap(find.bySemanticsLabel('Results'));
      await tester.tap(find.text('Home'));

      expect(taps, [2, 0]);
    });

    testWidgets('renders in dark mode', (tester) async {
      await pump(tester, themeMode: ThemeMode.dark);

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('fits a narrow phone at 2.0x text', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pump(tester, current: 1);

      expect(tester.takeException(), isNull);
    });
  });
}
