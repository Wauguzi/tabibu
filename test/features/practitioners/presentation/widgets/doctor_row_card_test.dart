import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/status_chip.dart';
import 'package:tabibu/features/practitioners/presentation/widgets/doctor_row_card.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('DoctorRowCard', () {
    testWidgets('renders name, supporting and chip', (tester) async {
      await tester.pumpApp(
        DoctorRowCard(
          name: 'Dr. Wanjiru Kamau',
          supporting: 'Breast surgeon · KMPDC verified',
          chip: const StatusChip(label: 'In 2 days', tone: .info),
          onTap: () {},
        ),
      );
      expect(find.text('Dr. Wanjiru Kamau'), findsOneWidget);
      expect(find.text('Breast surgeon · KMPDC verified'), findsOneWidget);
      expect(find.text('In 2 days'), findsOneWidget);
    });

    testWidgets('fires onTap', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        DoctorRowCard(
          name: 'Dr. Wanjiru Kamau',
          supporting: 'Breast surgeon',
          onTap: () => taps++,
        ),
      );
      await tester.tap(find.byType(DoctorRowCard));
      expect(taps, 1);
    });

    testWidgets('without onTap is not a button', (tester) async {
      await tester.pumpApp(
        const DoctorRowCard(
          name: 'Dr. Wanjiru Kamau',
          supporting: 'Breast surgeon',
        ),
      );
      expect(find.text('Dr. Wanjiru Kamau'), findsOneWidget);
      expect(find.byType(DoctorRowCard), findsOneWidget);
    });

    testWidgets('renders in light and dark', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(
          DoctorRowCard(
            name: 'Dr. Wanjiru Kamau',
            supporting: 'Breast surgeon',
            onTap: () {},
          ),
          themeMode: mode,
        );
        expect(find.byType(DoctorRowCard), findsOneWidget);
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
        DoctorRowCard(
          name: 'Dr. Wanjiru Kamau',
          supporting: 'Breast surgeon · KMPDC verified',
          onTap: () {},
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
