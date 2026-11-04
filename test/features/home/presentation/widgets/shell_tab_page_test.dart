import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/home/presentation/widgets/shell_tab_page.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('ShellTabPage', () {
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
