import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_search_entry.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('DeskSearchEntry', () {
    testWidgets('edge case 11: a tap opens the search and never takes focus', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpApp(
        DeskSearchEntry(hint: 'Search case ID or patient', onTap: () => taps++),
      );
      await tester.tap(find.byType(DeskSearchEntry));
      await tester.pump();

      expect(taps, 1);
      expect(
        tester.widget<TextField>(find.byType(TextField)).autofocus,
        isFalse,
      );
      expect(find.byType(EditableText), findsOneWidget);
      expect(
        tester
            .state<EditableTextState>(find.byType(EditableText))
            .widget
            .focusNode
            .hasFocus,
        isFalse,
      );
    });

    testWidgets('reads as one button with the hint', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(
        DeskSearchEntry(hint: 'Search case ID or patient', onTap: () {}),
      );
      final node = tester.getSemantics(find.byType(DeskSearchEntry));
      expect(node.label, 'Search case ID or patient');
      expect(node.flagsCollection.isButton, isTrue);
      handle.dispose();
    });
  });
}
