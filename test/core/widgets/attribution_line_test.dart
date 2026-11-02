import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/attribution_line.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../helpers/helpers.dart';

void main() {
  group('AttributionLine', () {
    testWidgets('renders the shield and muted text', (tester) async {
      const text = 'Shared by Dr. Kamau after your appointment.';
      await tester.pumpApp(const AttributionLine(text: text));
      await tester.pumpAndSettle();

      expect(find.text(text), findsOneWidget);
      final icon = tester.widget<AssetIcon>(find.byType(AssetIcon));
      expect(icon.asset, Assets.icons.shieldIcon);
      expect(icon.size, 18);

      final context = tester.element(find.byType(AttributionLine));
      final scheme = Theme.of(context).colorScheme;
      expect(icon.color, scheme.onSurfaceVariant);
      final label = tester.widget<Text>(find.text(text));
      expect(label.style?.color, scheme.onSurfaceVariant);
      expect(label.style?.fontSize, 13);
    });

    testWidgets('uses a custom icon when given', (tester) async {
      await tester.pumpApp(
        AttributionLine(text: 'Text', icon: Assets.icons.infoIcon),
      );
      await tester.pumpAndSettle();

      final icon = tester.widget<AssetIcon>(find.byType(AssetIcon));
      expect(icon.asset, Assets.icons.infoIcon);
    });

    testWidgets('renders in dark', (tester) async {
      const text = 'Shared by Dr. Kamau after your appointment.';
      await tester.pumpApp(
        const AttributionLine(text: text),
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      expect(find.text(text), findsOneWidget);
    });

    testWidgets('renders in Swahili', (tester) async {
      const text = 'Matokeo ya Dkt. Kamau, miadi yako.';
      await tester.pumpApp(
        const AttributionLine(text: text),
        locale: const Locale('sw'),
      );
      await tester.pumpAndSettle();

      expect(find.text(text), findsOneWidget);
    });

    testWidgets('wraps at 1.3x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        const AttributionLine(
          text:
              'Shared by Dr. Kamau after your appointment, from the report '
              'reviewed by Dr. Achieng Odhiambo, pathologist.',
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
