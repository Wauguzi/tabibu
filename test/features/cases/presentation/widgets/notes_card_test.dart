import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/circle_icon_button.dart';
import 'package:tabibu/features/cases/presentation/widgets/notes_card.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('NotesCard', () {
    testWidgets('shows title and body text', (tester) async {
      await tester.pumpApp(
        const NotesCard(
          title: 'Your notes',
          text: 'Suspect TB. Order GeneXpert.',
          placeholder: 'Add notes during the appointment.',
          editLabel: 'Edit notes',
        ),
      );

      expect(find.text('Your notes'), findsOneWidget);
      expect(find.text('Suspect TB. Order GeneXpert.'), findsOneWidget);
      expect(find.text('Add notes during the appointment.'), findsNothing);
    });

    testWidgets('shows placeholder when text is empty', (tester) async {
      await tester.pumpApp(
        const NotesCard(
          title: 'Your notes',
          text: '',
          placeholder: 'Add notes during the appointment. Only you and …',
          editLabel: 'Edit notes',
        ),
      );

      expect(
        find.text('Add notes during the appointment. Only you and …'),
        findsOneWidget,
      );
    });

    testWidgets('shows the pencil only when onEdit is set', (tester) async {
      var edits = 0;
      await tester.pumpApp(
        const NotesCard(
          title: 'Your notes',
          text: 'Suspect TB.',
          placeholder: 'Add notes',
          editLabel: 'Edit notes',
        ),
      );
      expect(find.byType(CircleIconButton), findsNothing);

      await tester.pumpApp(
        NotesCard(
          title: 'Your notes',
          text: 'Suspect TB.',
          placeholder: 'Add notes',
          editLabel: 'Edit notes',
          onEdit: () => edits++,
        ),
      );

      expect(find.byType(CircleIconButton), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(CircleIconButton)),
        matchesSemantics(
          label: 'Edit notes',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );

      await tester.tap(find.byType(CircleIconButton));
      await tester.pump();
      expect(edits, 1);
    });

    testWidgets('renders in light and dark', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(
          NotesCard(
            title: 'Your notes',
            text: 'Suspect TB.',
            placeholder: 'Add notes',
            editLabel: 'Edit notes',
            onEdit: () {},
          ),
          themeMode: mode,
        );
        expect(find.byType(NotesCard), findsOneWidget);
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
        NotesCard(
          title: 'Your notes',
          text:
              'Patient reports night sweats for two weeks. No prior TB '
              'treatment. Request GeneXpert and chest X-ray.',
          placeholder: 'Add notes during the appointment. Only you and …',
          editLabel: 'Edit notes',
          onEdit: () {},
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
