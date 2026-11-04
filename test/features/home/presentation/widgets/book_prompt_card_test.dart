import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/home/presentation/widgets/book_prompt_card.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('BookPromptCard', () {
    const card = BookPromptCard(
      title: 'No appointments coming up',
      body: 'Book a verified doctor near you, in English or Kiswahili.',
      actionLabel: 'Book now',
      onBook: null,
    );

    testWidgets('shows its copy and books on tap', (tester) async {
      var booked = false;
      await tester.pumpApp(
        BookPromptCard(
          title: 'No appointments coming up',
          body: 'Book a verified doctor near you, in English or Kiswahili.',
          actionLabel: 'Book now',
          onBook: () => booked = true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No appointments coming up'), findsOneWidget);
      expect(
        find.text('Book a verified doctor near you, in English or Kiswahili.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TabibuButton, 'Book now'), findsOneWidget);

      await tester.tap(find.text('Book now'));
      expect(booked, isTrue);
    });

    testWidgets('announces the action as a button', (tester) async {
      await tester.pumpApp(card);
      await tester.pumpAndSettle();

      final button = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Book now',
      );
      expect(button, findsOneWidget);
      expect(tester.widget<Semantics>(button).properties.button, isTrue);
    });

    testWidgets('renders in dark mode', (tester) async {
      await tester.pumpApp(card, themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();

      expect(find.text('No appointments coming up'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays out at 1.3x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(card);
      await tester.pumpAndSettle();

      expect(find.text('No appointments coming up'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in Swahili', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => BookPromptCard(
            title: context.l10n.patientHomeNoAppointments,
            body: context.l10n.patientHomeBookPromptBody,
            actionLabel: context.l10n.patientHomeBookNow,
            onBook: () {},
          ),
        ),
        locale: const Locale('sw'),
      );
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(BookPromptCard)),
      );
      expect(find.text(l10n.patientHomeNoAppointments), findsOneWidget);
      expect(find.text(l10n.patientHomeBookNow), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
