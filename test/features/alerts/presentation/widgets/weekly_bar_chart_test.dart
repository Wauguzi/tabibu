import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/constants/theme_builder.dart';
import 'package:tabibu/features/alerts/presentation/widgets/weekly_bar_chart.dart';

import '../../../../helpers/helpers.dart';

void main() {
  const counts = [3, 4, 2, 5, 4, 6, 9, 14];
  const baseline = 5.0;
  const summary =
      'Malaria cases, 8 weeks: 3, 4, 2, 5, 4, 6, 9, 14. Baseline 5.';

  Widget chart({List<int> series = counts}) {
    return WeeklyBarChart(
      counts: series,
      baseline: baseline,
      labels: const ['8 weeks ago', 'This week'],
      baselineLabel: 'Usual level',
      semanticSummary: summary,
    );
  }

  WeeklyBarChartPainter painterOf(WidgetTester tester) {
    return tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((paint) => paint.painter)
        .whereType<WeeklyBarChartPainter>()
        .single;
  }

  group('WeeklyBarChart', () {
    testWidgets('bars above baseline use alertNotice; others outlineVariant', (
      tester,
    ) async {
      await tester.pumpApp(chart());
      final painter = painterOf(tester);
      final status = buildTheme(Brightness.light).extension<AppStatusColors>()!;
      final outline = buildTheme(Brightness.light).colorScheme.outlineVariant;

      expect(painter.colorFor(0), outline); // 3 ≤ 5
      expect(painter.colorFor(3), outline); // 5 = baseline → below/equal
      expect(painter.colorFor(5), status.alertNotice); // 6 > 5
      expect(painter.colorFor(6), status.alertNotice); // 9
      expect(
        painter.colorFor(7),
        Color.alphaBlend(
          Colors.black.withValues(alpha: 0.2),
          status.alertNotice,
        ),
      );

      final rects = painter.barRects(const Size(390, 180));
      expect(rects, hasLength(8));
      expect(rects.last.top, lessThan(rects.first.top)); // taller last bar
      expect(painter.baselineY(const Size(390, 180)), isPositive);
    });

    testWidgets('all-zero series draws flat bars and never divides by zero', (
      tester,
    ) async {
      await tester.pumpApp(
        WeeklyBarChart(
          counts: const [0, 0, 0, 0, 0, 0, 0, 0],
          baseline: 0,
          labels: const ['8 weeks ago', 'This week'],
          baselineLabel: 'Usual level',
          semanticSummary: 'All zero. Baseline 0.',
        ),
      );
      final painter = painterOf(tester);
      expect(painter.yMax, 1);
      final rects = painter.barRects(const Size(390, 180));
      for (final r in rects) {
        expect(r.height, 0);
      }
    });

    testWidgets('one semantics node reads the summary', (tester) async {
      await tester.pumpApp(chart());
      expect(
        tester.getSemantics(find.byType(WeeklyBarChart)),
        matchesSemantics(label: summary),
      );
    });

    testWidgets('renders in light and dark', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(chart(), themeMode: mode);
        expect(find.byType(WeeklyBarChart), findsOneWidget);
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

      await tester.pumpApp(SizedBox(width: 390, child: chart()));
      expect(tester.takeException(), isNull);
    });
  });
}
