import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/home/presentation/widgets/shell_tab_page.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('ShellTabPage', () {
    testWidgets('99: a drag on the list drops the keyboard', (tester) async {
      // Short viewport so the list must scroll (onDrag only fires on a real
      // drag scroll, not when maxScrollExtent is 0).
      tester.view.physicalSize = const Size(390 * 3, 500 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpApp(
        ShellTabPage(
          role: .patient,
          children: [
            TextField(focusNode: node),
            for (var i = 0; i < 40; i++)
              SizedBox(height: 48, child: Text('Row $i')),
          ],
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(node.hasPrimaryFocus, isTrue);
      expect(tester.testTextInput.isVisible, isTrue);

      // Drag a body row, not the field, so the scroll view owns the gesture.
      await tester.drag(find.text('Row 5'), const Offset(0, -200));
      await tester.pump();
      expect(node.hasPrimaryFocus, isFalse);
      expect(tester.testTextInput.isVisible, isFalse);
    });

    testWidgets('lays out children for every role', (tester) async {
      for (final role in Role.values) {
        await tester.pumpApp(
          ShellTabPage(role: role, children: const [Text('Row')]),
        );
        expect(find.text('Row'), findsOneWidget);
      }
    });

    testWidgets('lays out slivers', (tester) async {
      await tester.pumpApp(
        const ShellTabPage(
          role: .doctor,
          slivers: [SliverToBoxAdapter(child: Text('Sliver'))],
        ),
      );
      expect(find.text('Sliver'), findsOneWidget);
    });

    testWidgets('pulls to refresh, even when the list is short', (
      tester,
    ) async {
      var refreshed = 0;
      await tester.pumpApp(
        ShellTabPage(
          role: .patient,
          onRefresh: () async => refreshed++,
          children: const [Text('Only row')],
        ),
      );
      await tester.fling(find.text('Only row'), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();
      expect(refreshed, 1);
    });

    testWidgets('has no refresh indicator without onRefresh', (tester) async {
      await tester.pumpApp(
        const ShellTabPage(role: .pathologist, children: [Text('Row')]),
      );
      expect(find.byType(RefreshIndicator), findsNothing);
    });
  });
}
