import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/tabibu_filter_chip.dart';
import 'package:tabibu/features/reports/presentation/widgets/verdict_selector.dart';

import '../../../../helpers/helpers.dart';

enum _Verdict { agree, partly, disagree }

void main() {
  const options = <(_Verdict, String)>[
    (_Verdict.agree, 'Agree'),
    (_Verdict.partly, 'Partly agree'),
    (_Verdict.disagree, 'Disagree'),
  ];

  group('VerdictSelector', () {
    testWidgets('starts with nothing selected', (tester) async {
      await tester.pumpApp(
        VerdictSelector<_Verdict>(
          label: 'Findings',
          options: options,
          selected: null,
          onSelected: (_) {},
        ),
      );

      final chips = tester.widgetList<TabibuFilterChip>(
        find.byType(TabibuFilterChip),
      );
      expect(chips.every((c) => !c.selected), isTrue);
    });

    testWidgets(
      'a tap reports its value; re-tapping selected reports nothing',
      (tester) async {
        _Verdict? selected;
        final reported = <_Verdict>[];

        await tester.pumpApp(
          StatefulBuilder(
            builder: (context, setState) {
              return VerdictSelector<_Verdict>(
                label: 'Findings',
                options: options,
                selected: selected,
                onSelected: (v) {
                  reported.add(v);
                  setState(() => selected = v);
                },
              );
            },
          ),
        );

        await tester.tap(find.text('Partly agree'));
        await tester.pump();
        expect(reported, [_Verdict.partly]);

        await tester.tap(find.text('Partly agree'));
        await tester.pump();
        expect(reported, [_Verdict.partly]);
      },
    );
  });

  group('OverallScore', () {
    testWidgets('circles fill to the value and announce labels', (
      tester,
    ) async {
      final picked = <int>[];
      await tester.pumpApp(
        OverallScore(
          value: 3,
          onChanged: picked.add,
          label: 'Overall',
          semanticLabelFor: (i) => '$i of 5',
        ),
      );

      expect(find.text('Overall'), findsOneWidget);
      for (var i = 1; i <= 5; i++) {
        expect(
          tester.getSemantics(find.bySemanticsLabel('$i of 5')),
          matchesSemantics(
            label: '$i of 5',
            isButton: true,
            hasTapAction: true,
          ),
        );
      }

      await tester.tap(find.bySemanticsLabel('5 of 5'));
      expect(picked, [5]);
    });

    testWidgets('nothing is filled when value is null', (tester) async {
      await tester.pumpApp(
        OverallScore(
          value: null,
          onChanged: (_) {},
          label: 'Overall',
          semanticLabelFor: (i) => '$i of 5',
        ),
      );
      expect(find.text('Overall'), findsOneWidget);
    });
  });

  group('light, dark, text scale', () {
    testWidgets('renders in light and dark', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(
          Column(
            children: [
              VerdictSelector<_Verdict>(
                label: 'Findings',
                options: options,
                selected: null,
                onSelected: (_) {},
              ),
              OverallScore(
                value: 2,
                onChanged: (_) {},
                label: 'Overall',
                semanticLabelFor: (i) => '$i of 5',
              ),
            ],
          ),
          themeMode: mode,
        );
        expect(find.byType(VerdictSelector<_Verdict>), findsOneWidget);
        expect(find.byType(OverallScore), findsOneWidget);
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
        SizedBox(
          width: 390,
          child: Column(
            children: [
              VerdictSelector<_Verdict>(
                label: 'Findings',
                options: options,
                selected: _Verdict.agree,
                onSelected: (_) {},
              ),
              OverallScore(
                value: 4,
                onChanged: (_) {},
                label: 'Overall',
                semanticLabelFor: (i) => '$i of 5',
              ),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
