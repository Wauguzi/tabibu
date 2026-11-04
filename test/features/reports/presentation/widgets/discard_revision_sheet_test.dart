import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/reports/presentation/widgets/discard_revision_sheet.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

/// The discard sheet fits a phone at 1.0x and 2.0x text, in English and
/// Swahili, light and dark; confirm returns true, cancel false.
void main() {
  group('DiscardRevisionSheet', () {
    Future<void> open(
      WidgetTester tester, {
      required Locale locale,
      required ThemeMode mode,
      required double scale,
    }) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => DiscardRevisionSheet.show(context),
            child: const Text('Open'),
          ),
        ),
        locale: locale,
        themeMode: mode,
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    testWidgets('fits a phone at 1.0x and 2.0x, both languages, both modes', (
      tester,
    ) async {
      for (final scale in [1.0, 2.0]) {
        for (final locale in [const Locale('en'), const Locale('sw')]) {
          for (final mode in [ThemeMode.light, ThemeMode.dark]) {
            // Unmount first: the sheet stays up between configs.
            await tester.pumpWidget(const SizedBox());
            await open(tester, locale: locale, mode: mode, scale: scale);
            final l10n = lookupAppLocalizations(locale);

            expect(find.text(l10n.workspaceDiscardSheetTitle), findsOneWidget);
            expect(find.text(l10n.workspaceDiscardSheetBody), findsOneWidget);
            expect(
              find.text(l10n.workspaceDiscardSheetConfirm),
              findsOneWidget,
            );
            expect(find.text(l10n.commonCancel), findsOneWidget);
            expect(tester.takeException(), isNull);
          }
        }
      }
    });

    testWidgets('confirm returns true, cancel false', (tester) async {
      final results = <bool>[];
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                DiscardRevisionSheet.show(context).then(results.add),
            child: const Text('Open'),
          ),
        ),
      );
      final l10n = lookupAppLocalizations(const Locale('en'));

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.text(l10n.workspaceDiscardSheetConfirm));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.text(l10n.commonCancel));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(results, [true, false]);
    });
  });
}
