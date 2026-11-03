import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/features/alerts/presentation/widgets/alert_demo_banner.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('AlertDemoBanner', () {
    testWidgets('says the alert is a demonstration, in both languages', (
      tester,
    ) async {
      await tester.pumpApp(const AlertDemoBanner());
      expect(
        find.text(
          lookupAppLocalizations(const Locale('en')).alertReviewDemoBanner,
        ),
        findsOneWidget,
      );

      await tester.pumpApp(const AlertDemoBanner(), locale: const Locale('sw'));
      expect(
        find.text(
          lookupAppLocalizations(const Locale('sw')).alertReviewDemoBanner,
        ),
        findsOneWidget,
      );
    });

    testWidgets('uses the alert notice tone in dark mode', (tester) async {
      await tester.pumpApp(const AlertDemoBanner(), themeMode: ThemeMode.dark);

      final status = Theme.of(
        tester.element(find.byType(AlertDemoBanner)),
      ).extension<AppStatusColors>()!;
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style?.color, status.alertNotice);
    });
  });
}
