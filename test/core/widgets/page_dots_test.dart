import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/page_dots.dart';

import '../../helpers/helpers.dart';

void main() {
  group('PageDots', () {
    testWidgets('renders one dot per page with the active stretched', (
      tester,
    ) async {
      await tester.pumpApp(const PageDots(count: 3, index: 1));

      final dots = find.byType(AnimatedContainer);
      expect(dots, findsNWidgets(3));
      expect(tester.getSize(dots.at(0)).width, 8);
      expect(tester.getSize(dots.at(1)).width, 24);
      expect(tester.getSize(dots.at(2)).width, 8);
    });

    testWidgets('grows at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(const PageDots(count: 3, index: 0));

      expect(tester.takeException(), isNull);
    });
  });
}
