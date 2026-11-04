import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/two_tone_headline.dart';

import '../../helpers/helpers.dart';

void main() {
  group('TwoToneHeadline', () {
    testWidgets('renders both lines with the second in teal', (tester) async {
      await tester.pumpApp(
        const TwoToneHeadline(
          first: '6 appointments today.',
          second: '2 reports ready.',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('6 appointments today.'), findsOneWidget);
      expect(find.text('2 reports ready.'), findsOneWidget);

      final context = tester.element(find.byType(TwoToneHeadline));
      final scheme = Theme.of(context).colorScheme;
      final first = tester.widget<Text>(find.text('6 appointments today.'));
      final second = tester.widget<Text>(find.text('2 reports ready.'));
      expect(first.style?.color, scheme.onSurface);
      expect(first.style?.fontSize, 34);
      expect(first.style?.fontWeight, FontWeight.w700);
      expect(second.style?.color, scheme.primary);
    });

    testWidgets('renders the second line in ink when tealSecond is false', (
      tester,
    ) async {
      await tester.pumpApp(
        const TwoToneHeadline(
          first: 'Your care,',
          second: 'close to home.',
          tealSecond: false,
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(TwoToneHeadline));
      final status = Theme.of(context).extension<AppStatusColors>()!;
      final second = tester.widget<Text>(find.text('close to home.'));
      expect(second.style?.color, status.ink);
    });

    testWidgets('renders a single line without a second', (tester) async {
      await tester.pumpApp(const TwoToneHeadline(first: '6 appointments.'));
      await tester.pumpAndSettle();

      expect(find.text('6 appointments.'), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('reads as one header', (tester) async {
      await tester.pumpApp(
        const TwoToneHeadline(first: '6 appointments.', second: '2 ready.'),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(TwoToneHeadline)),
        matchesSemantics(isHeader: true),
      );
    });

    testWidgets('renders in dark', (tester) async {
      await tester.pumpApp(
        const TwoToneHeadline(first: '6 appointments.', second: '2 ready.'),
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      expect(find.text('6 appointments.'), findsOneWidget);
      expect(find.text('2 ready.'), findsOneWidget);
    });

    testWidgets('renders in Swahili', (tester) async {
      await tester.pumpApp(
        const TwoToneHeadline(
          first: 'Miadi 6 leo.',
          second: 'Ripoti 2 tayari.',
        ),
        locale: const Locale('sw'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Miadi 6 leo.'), findsOneWidget);
      expect(find.text('Ripoti 2 tayari.'), findsOneWidget);
    });

    testWidgets('grows at 1.3x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        const TwoToneHeadline(
          first: '6 appointments today.',
          second: '2 reports ready.',
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
