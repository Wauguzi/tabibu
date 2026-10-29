import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/document_tile.dart';

import '../../helpers/helpers.dart';

void main() {
  group('DocumentTile', () {
    testWidgets('renders name, meta and delete', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        DocumentTile(
          fileName: 'practising_licence_2026.jpg',
          meta: '2.1 MB · photo',
          deleteLabel: 'Delete document',
          onDelete: () => taps++,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('practising_licence_2026.jpg'), findsOneWidget);
      expect(find.text('2.1 MB · photo'), findsOneWidget);

      await tester.tap(find.byType(AssetIcon).last);
      expect(taps, 1);
    });

    testWidgets('announces the delete button', (tester) async {
      await tester.pumpApp(
        DocumentTile(
          fileName: 'licence.jpg',
          meta: '2.1 MB · photo',
          deleteLabel: 'Delete document',
          onDelete: () {},
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(AssetIcon).last),
        matchesSemantics(
          label: 'Delete document',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
    });

    testWidgets('grows at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        SingleChildScrollView(
          child: DocumentTile(
            fileName: 'a_very_long_file_name_that_must_truncate.jpg',
            meta: '2.1 MB · photo',
            deleteLabel: 'Delete document',
            onDelete: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('raises by tone in dark mode', (tester) async {
      await tester.pumpApp(
        DocumentTile(
          fileName: 'licence.jpg',
          meta: '2.1 MB · photo',
          deleteLabel: 'Delete document',
          onDelete: () {},
        ),
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(DocumentTile));
      final scheme = Theme.of(context).colorScheme;
      final card = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(DocumentTile),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(
        (card.decoration! as BoxDecoration).color,
        scheme.surfaceContainerHigh,
      );
    });
  });
}
