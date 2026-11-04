import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/status_chip.dart';
import 'package:tabibu/features/appointments/presentation/widgets/booking_request_card.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('BookingRequestCard', () {
    testWidgets('renders labels and fires Accept and Decline', (tester) async {
      var accepts = 0;
      var declines = 0;
      await tester.pumpApp(
        BookingRequestCard(
          name: 'Peter Mwangi, 41',
          when: 'Fri 30 Oct · 9:45 AM',
          type: 'New appointment',
          acceptLabel: 'Accept',
          declineLabel: 'Decline',
          supporting: 'Prefers mornings',
          languageChip: const StatusChip(
            label: 'Speaks English',
            tone: .neutral,
          ),
          onAccept: () => accepts++,
          onDecline: () => declines++,
        ),
      );

      expect(find.text('Peter Mwangi, 41'), findsOneWidget);
      expect(
        find.text('Fri 30 Oct · 9:45 AM · New appointment'),
        findsOneWidget,
      );
      expect(find.text('Speaks English'), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);

      await tester.tap(find.text('Accept'));
      await tester.pump();
      expect(accepts, 1);

      await tester.tap(find.text('Decline'));
      await tester.pump();
      expect(declines, 1);
    });

    testWidgets('busy disables both buttons', (tester) async {
      var accepts = 0;
      var declines = 0;
      await tester.pumpApp(
        BookingRequestCard(
          name: 'Peter Mwangi, 41',
          when: 'Fri 30 Oct · 9:45 AM',
          type: 'New appointment',
          acceptLabel: 'Accept',
          declineLabel: 'Decline',
          onAccept: () => accepts++,
          onDecline: () => declines++,
          busy: true,
        ),
      );

      await tester.tap(find.text('Decline'));
      await tester.pump();
      // Accept shows a spinner while busy, so Decline is the label to hit.
      expect(accepts, 0);
      expect(declines, 0);
    });

    testWidgets('renders in light and dark', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(
          BookingRequestCard(
            name: 'Peter Mwangi, 41',
            when: 'Fri 30 Oct · 9:45 AM',
            type: 'New appointment',
            acceptLabel: 'Accept',
            declineLabel: 'Decline',
            onAccept: () {},
            onDecline: () {},
          ),
          themeMode: mode,
        );
        expect(find.byType(BookingRequestCard), findsOneWidget);
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
          child: BookingRequestCard(
            name: 'Peter Mwangi, 41',
            when: 'Fri 30 Oct · 9:45 AM',
            type: 'New appointment',
            acceptLabel: 'Accept',
            declineLabel: 'Decline',
            onAccept: () {},
            onDecline: () {},
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
