import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/status_mark.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../helpers/helpers.dart';

void main() {
  group('StatusMark', () {
    testWidgets('renders every state', (tester) async {
      await tester.pumpApp(
        Row(
          children: [
            const StatusMark.done(label: 'Done'),
            StatusMark.current(
              icon: Assets.icons.inProgressIcon,
              label: 'Current',
            ),
            StatusMark.pending(
              icon: Assets.icons.facilityIcon,
              label: 'Pending',
            ),
            const StatusMark.selection(selected: true, label: 'Selected'),
            const StatusMark.selection(selected: false, label: 'Unselected'),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StatusMark), findsNWidgets(5));
    });

    testWidgets('announces each state label', (tester) async {
      await tester.pumpApp(
        Row(
          children: [
            const StatusMark.done(label: 'Done'),
            StatusMark.current(
              icon: Assets.icons.inProgressIcon,
              label: 'Current',
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(StatusMark).first),
        matchesSemantics(label: 'Done', isImage: true),
      );
      expect(
        tester.getSemantics(find.byType(StatusMark).last),
        matchesSemantics(label: 'Current', isImage: true),
      );
    });

    testWidgets('grows at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(const StatusMark.done(label: 'Done'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
