import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/features/appointments/presentation/widgets/day_timeline.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('DayTimeline', () {
    testWidgets('a finished visit stands out from the light page', (
      tester,
    ) async {
      await tester.pumpApp(
        const SizedBox(
          width: 390,
          child: DayTimeline(
            entries: [
              TimelineEntry(
                time: '9:00 AM',
                title: 'Mary Njeri',
                subtitle: 'Follow-up after biopsy',
                state: .done,
              ),
            ],
          ),
        ),
      );

      final scheme = Theme.of(
        tester.element(find.text('Mary Njeri')),
      ).colorScheme;
      final card = tester.widget<DecoratedBox>(
        find
            .ancestor(
              of: find.text('Mary Njeri'),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final decoration = card.decoration as BoxDecoration;
      // Not the page's own pale tone, and edged.
      expect(decoration.color, isNot(scheme.surfaceContainerLow));
      expect(decoration.border, isNotNull);
    });

    testWidgets('renders each state style', (tester) async {
      var freeTaps = 0;
      var upcomingTaps = 0;
      await tester.pumpApp(
        SizedBox(
          width: 390,
          child: DayTimeline(
            entries: [
              const TimelineEntry(
                time: '9:00 AM',
                title: 'Mary Njeri',
                subtitle: 'Follow-up after biopsy',
                state: .done,
              ),
              const TimelineEntry(
                time: '11:15 AM',
                title: 'Amina Wambui',
                subtitle: 'Results discussion',
                state: .now,
                nowLabel: 'Now',
              ),
              TimelineEntry(
                time: '12:00 PM',
                title: 'Grace Wanjiru',
                subtitle: 'New appointment',
                state: .upcoming,
                onTap: () => upcomingTaps++,
              ),
              TimelineEntry(
                time: '1:00 PM',
                title: 'Free · 45 min',
                subtitle: 'Good time to read reports',
                state: .free,
                onTap: () => freeTaps++,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Mary Njeri'), findsOneWidget);
      expect(find.text('Amina Wambui'), findsOneWidget);
      expect(find.text('Now'), findsOneWidget);
      expect(find.text('Grace Wanjiru'), findsOneWidget);
      expect(find.text('Free · 45 min'), findsOneWidget);

      await tester.tap(find.text('Grace Wanjiru'));
      expect(upcomingTaps, 1);

      await tester.tap(find.text('Free · 45 min'));
      expect(freeTaps, 0);
    });

    testWidgets('now marker uses colorScheme.primary', (tester) async {
      await tester.pumpApp(
        const SizedBox(
          width: 390,
          child: DayTimeline(
            entries: [
              TimelineEntry(
                time: '11:15 AM',
                title: 'Amina Wambui',
                subtitle: 'Results discussion',
                state: .now,
                nowLabel: 'Now',
              ),
            ],
          ),
        ),
      );

      final context = tester.element(find.byType(DayTimeline));
      final primary = Theme.of(context).colorScheme.primary;

      final markers = tester.widgetList<Container>(find.byType(Container));
      expect(
        markers.any(
          (c) =>
              c.decoration is BoxDecoration &&
              (c.decoration! as BoxDecoration).color == primary &&
              (c.decoration! as BoxDecoration).shape == BoxShape.circle,
        ),
        isTrue,
      );

      final chips = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
      expect(
        chips.any(
          (b) =>
              b.decoration is BoxDecoration &&
              (b.decoration as BoxDecoration).color == primary,
        ),
        isTrue,
      );
    });

    testWidgets('renders in light and dark', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(
          const SizedBox(
            width: 390,
            child: DayTimeline(
              entries: [
                TimelineEntry(
                  time: '9:00 AM',
                  title: 'Mary Njeri',
                  subtitle: 'Follow-up',
                  state: .done,
                ),
              ],
            ),
          ),
          themeMode: mode,
        );
        expect(find.byType(DayTimeline), findsOneWidget);
      }
    });

    testWidgets('grows at 1.3x text without overflow at 390 dp', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        const SizedBox(
          width: 390,
          child: DayTimeline(
            entries: [
              TimelineEntry(
                time: '9:00 AM',
                title: 'Mary Njeri',
                subtitle: 'Follow-up after biopsy',
                state: .done,
              ),
              TimelineEntry(
                time: '1:00 PM',
                title: 'Free · 45 min',
                subtitle: 'Good time to read reports',
                state: .free,
              ),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('the now card text stays readable on ink in dark mode', (
      tester,
    ) async {
      await tester.pumpApp(
        const DayTimeline(
          entries: [
            TimelineEntry(
              time: '11:00 AM',
              title: 'Amina Wambui',
              subtitle: 'Results discussion',
              state: .now,
            ),
          ],
        ),
        themeMode: ThemeMode.dark,
      );
      final title = tester.widget<Text>(find.text('Amina Wambui'));
      expect(title.style?.color, AppColors.inkLight);
    });
  });
}
