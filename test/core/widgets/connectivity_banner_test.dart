import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/connectivity_banner.dart';

import '../../helpers/helpers.dart';

void main() {
  group('ConnectivityBanner', () {
    testWidgets('renders every state', (tester) async {
      await tester.pumpApp(
        SingleChildScrollView(
          child: Column(
            children: [
              for (final state in ConnectivityState.values)
                ConnectivityBanner(
                  state: state,
                  title: 'Title $state',
                  body: 'Body $state',
                  retryLabel: 'Retry',
                  onRetry: () {},
                ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (final state in ConnectivityState.values) {
        expect(find.text('Title $state'), findsOneWidget);
      }
      expect(find.text('Retry'), findsNWidgets(4));
    });

    testWidgets('announces retry as a labelled button', (tester) async {
      await tester.pumpApp(
        ConnectivityBanner(
          state: ConnectivityState.offline,
          title: 'Offline',
          body: 'Saved on this phone',
          retryLabel: 'Retry',
          onRetry: () {},
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.text('Retry')),
        matchesSemantics(
          label: 'Retry',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
    });

    testWidgets('hides retry without a label and fires it', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        Column(
          children: [
            const ConnectivityBanner(
              state: ConnectivityState.backOnline,
              title: 'Online',
              body: 'Up to date',
            ),
            ConnectivityBanner(
              state: ConnectivityState.offline,
              title: 'Offline',
              body: 'Saved on this phone',
              retryLabel: 'Retry',
              onRetry: () => taps++,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(taps, 1);
    });

    testWidgets('grows at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        const SingleChildScrollView(
          child: ConnectivityBanner(
            state: ConnectivityState.slow,
            title: 'A long title that must wrap, not clip',
            body: 'A long body that must also wrap onto more lines',
            retryLabel: 'Retry',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('the retry pill meets the tap target floor', (tester) async {
      await tester.pumpApp(
        ConnectivityBanner(
          state: ConnectivityState.offline,
          title: 'Offline',
          body: 'Saved on this phone',
          retryLabel: 'Retry',
          onRetry: () {},
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    });

    testWidgets('retries with Enter from the keyboard', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        ConnectivityBanner(
          state: ConnectivityState.offline,
          title: 'Offline',
          body: 'Saved on this phone',
          retryLabel: 'Retry',
          onRetry: () => taps++,
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(taps, 1);
    });
  });
}
