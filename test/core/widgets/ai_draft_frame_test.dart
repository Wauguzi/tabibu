import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/ai_draft_frame.dart';
import 'package:tabibu/core/widgets/dashed_border.dart';

import '../../helpers/helpers.dart';

void main() {
  group('AiDraftFrame', () {
    testWidgets('labels its content and wears the dashed draft border', (
      tester,
    ) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(
          const AiDraftFrame(
            label: 'AI draft — not signed',
            child: Text('Sentinel lymph node with metastatic carcinoma.'),
          ),
          themeMode: mode,
        );
        await tester.pumpAndSettle();

        expect(find.text('AI draft — not signed'), findsOneWidget);
        expect(
          find.text('Sentinel lymph node with metastatic carcinoma.'),
          findsOneWidget,
        );
        final context = tester.element(find.byType(AiDraftFrame));
        final status = Theme.of(context).extension<AppStatusColors>()!;
        final border = tester.widget<DashedBorder>(find.byType(DashedBorder));
        expect(border.color, status.draftBorder);
      }
    });

    testWidgets('announces the label with the content', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpApp(
        const AiDraftFrame(label: 'AI draft — not signed', child: Text('x')),
      );
      expect(
        find.bySemanticsLabel(RegExp('AI draft — not signed')),
        findsOneWidget,
      );
      semantics.dispose();
    });

    testWidgets('shows the model names only when expanded', (tester) async {
      await tester.pumpApp(
        const AiDraftFrame(
          label: 'AI draft — not signed',
          detail: 'Model: pre-read v1',
          footer: Text('Footer'),
          child: Text('Body'),
        ),
      );
      expect(find.text('Model: pre-read v1'), findsNothing);
      expect(find.text('Footer'), findsOneWidget);

      await tester.tap(find.text('AI draft — not signed'));
      await tester.pumpAndSettle();
      expect(find.text('Model: pre-read v1'), findsOneWidget);

      await tester.tap(find.text('AI draft — not signed'));
      await tester.pumpAndSettle();
      expect(find.text('Model: pre-read v1'), findsNothing);
    });
  });
}
