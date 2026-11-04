import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/reports/presentation/widgets/listen_card.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('ListenCard', () {
    testWidgets('renders labels and toggles play', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        ListenCard(
          title: 'Listen to this summary',
          supporting: 'English · 40 s',
          playing: false,
          playLabel: 'Play summary',
          pauseLabel: 'Pause summary',
          onToggle: () => taps++,
        ),
      );

      expect(find.text('Listen to this summary'), findsOneWidget);
      expect(find.text('English · 40 s'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Play summary'));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('announces play or pause from the caller', (tester) async {
      await tester.pumpApp(
        const ListenCard(
          title: 'Listen to this summary',
          supporting: 'English · 40 s',
          playing: false,
          playLabel: 'Play summary',
          pauseLabel: 'Pause summary',
          onToggle: _noop,
        ),
      );
      expect(find.bySemanticsLabel('Play summary'), findsOneWidget);
      expect(find.bySemanticsLabel('Pause summary'), findsNothing);

      await tester.pumpApp(
        const ListenCard(
          title: 'Listen to this summary',
          supporting: 'English · 40 s',
          playing: true,
          playLabel: 'Play summary',
          pauseLabel: 'Pause summary',
          onToggle: _noop,
        ),
      );
      expect(find.bySemanticsLabel('Pause summary'), findsOneWidget);
      expect(find.bySemanticsLabel('Play summary'), findsNothing);
    });

    testWidgets('renders in light and dark', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(
          const ListenCard(
            title: 'Listen to this summary',
            supporting: 'English · 40 s',
            playing: false,
            playLabel: 'Play',
            pauseLabel: 'Pause',
            onToggle: _noop,
          ),
          themeMode: mode,
        );
        expect(find.byType(ListenCard), findsOneWidget);
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
          child: ListenCard(
            title: 'Listen to this longer summary title',
            supporting: 'English · forty seconds remaining',
            playing: false,
            playLabel: 'Play the spoken summary',
            pauseLabel: 'Pause the spoken summary',
            onToggle: _noop,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}

void _noop() {}
