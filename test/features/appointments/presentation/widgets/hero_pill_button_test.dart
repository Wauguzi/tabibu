import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/appointments/presentation/widgets/hero_pill_button.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('HeroPillButton', () {
    testWidgets('shows its label and taps', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        HeroPillButton(label: 'Details', onTap: () => taps++),
      );
      await tester.tap(find.text('Details'));
      expect(taps, 1);
      expect(
        tester.getSize(find.byType(HeroPillButton)).height,
        greaterThanOrEqualTo(56),
      );
    });

    testWidgets('is announced as a disabled button without onTap', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpApp(const HeroPillButton(label: 'Details', onTap: null));
      expect(
        tester.getSemantics(find.byType(HeroPillButton)),
        matchesSemantics(
          label: 'Details',
          isButton: true,
          hasEnabledState: true,
        ),
      );
      semantics.dispose();
    });
  });
}
