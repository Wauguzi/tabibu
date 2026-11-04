import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/section_header.dart';
import 'package:tabibu/core/widgets/tabibu_button.dart';

import '../../helpers/helpers.dart';

void main() {
  group('SectionHeader', () {
    testWidgets('renders the title and a teal action', (tester) async {
      await tester.pumpApp(
        SectionHeader(
          title: 'Your day',
          actionLabel: 'Calendar',
          onAction: () {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your day'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);

      final context = tester.element(find.byType(SectionHeader));
      final scheme = Theme.of(context).colorScheme;
      final title = tester.widget<Text>(find.text('Your day'));
      expect(title.style?.fontSize, 22);
      final action = tester.widget<Text>(find.text('Calendar'));
      expect(action.style?.color, scheme.primary);
      expect(action.style?.fontSize, 16);
      expect(action.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('the action ends on the content edge', (tester) async {
      await tester.pumpApp(
        SectionHeader(
          title: 'Your day',
          actionLabel: 'Calendar',
          onAction: () {},
        ),
      );
      await tester.pumpAndSettle();

      final header = tester.getRect(find.byType(SectionHeader));
      final label = tester.getRect(find.text('Calendar'));
      expect(header.right - label.right, lessThan(1));
    });

    testWidgets('fires the action', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        SectionHeader(
          title: 'Your day',
          actionLabel: 'Calendar',
          onAction: () => taps++,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('announces the action as a button', (tester) async {
      await tester.pumpApp(
        SectionHeader(
          title: 'Your day',
          actionLabel: 'Calendar',
          onAction: () {},
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(TabibuButton)),
        matchesSemantics(
          label: 'Calendar',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
    });

    testWidgets('meets the 48dp action floor', (tester) async {
      await tester.pumpApp(
        Column(
          children: [
            SectionHeader(
              title: 'Your day',
              actionLabel: 'Calendar',
              onAction: () {},
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(TabibuButton)).height, 48);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    });

    testWidgets('renders without an action', (tester) async {
      await tester.pumpApp(const SectionHeader(title: 'Your day'));
      await tester.pumpAndSettle();

      expect(find.text('Your day'), findsOneWidget);
      expect(find.byType(TabibuButton), findsNothing);
    });

    testWidgets('renders in dark', (tester) async {
      await tester.pumpApp(
        SectionHeader(
          title: 'Your day',
          actionLabel: 'Calendar',
          onAction: () {},
        ),
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      expect(find.text('Your day'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
    });

    testWidgets('renders in Swahili', (tester) async {
      await tester.pumpApp(
        SectionHeader(
          title: 'Matokeo yako',
          actionLabel: 'Chagua',
          onAction: () {},
        ),
        locale: const Locale('sw'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Matokeo yako'), findsOneWidget);
      expect(find.text('Chagua'), findsOneWidget);
    });

    testWidgets('grows at 1.3x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        SectionHeader(
          title: 'Doctors near you',
          actionLabel: 'See all',
          onAction: () {},
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
