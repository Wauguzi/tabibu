import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/reports/presentation/widgets/revision_sheet.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

/// The Amend and Addendum sheets fit a phone at 1.0x and 2.0x text, in
/// English and Swahili, light and dark, including the required line.
void main() {
  Future<void> open(
    WidgetTester tester,
    Future<String?> Function(BuildContext context) show, {
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
          onPressed: () => show(context),
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

  Future<void> eachConfig(
    WidgetTester tester,
    Future<String?> Function(BuildContext context) show,
    void Function(AppLocalizations l10n) check,
  ) async {
    for (final scale in [1.0, 2.0]) {
      for (final locale in [const Locale('en'), const Locale('sw')]) {
        for (final mode in [ThemeMode.light, ThemeMode.dark]) {
          // Unmount first: the sheet stays up between configs.
          await tester.pumpWidget(const SizedBox());
          await open(tester, show, locale: locale, mode: mode, scale: scale);
          check(lookupAppLocalizations(locale));
          expect(tester.takeException(), isNull);
        }
      }
    }
  }

  group('AmendSheet', () {
    testWidgets('fits a phone at 1.0x and 2.0x, both languages, both modes', (
      tester,
    ) async {
      await eachConfig(tester, AmendSheet.show, (l10n) {
        expect(find.text(l10n.signedCaseAmendTitle), findsOneWidget);
        expect(find.text(l10n.signedCaseAmendContinue), findsOneWidget);
      });
    });

    testWidgets('the required line fits too', (tester) async {
      for (final scale in [1.0, 2.0]) {
        for (final locale in [const Locale('en'), const Locale('sw')]) {
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final l10n = lookupAppLocalizations(locale);
          await tester.pumpWidget(const SizedBox());
          await open(
            tester,
            AmendSheet.show,
            locale: locale,
            mode: .light,
            scale: scale,
          );

          await tester.ensureVisible(find.text(l10n.signedCaseAmendContinue));
          await tester.tap(find.text(l10n.signedCaseAmendContinue));
          await tester.pump();

          expect(find.text(l10n.signedCaseAmendReasonRequired), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      }
    });
  });

  group('AddendumSheet', () {
    testWidgets('fits a phone at 1.0x and 2.0x, both languages, both modes', (
      tester,
    ) async {
      await eachConfig(tester, AddendumSheet.show, (l10n) {
        expect(find.text(l10n.signedCaseAddendumTitle), findsOneWidget);
        expect(find.text(l10n.signedCaseAddendumContinue), findsOneWidget);
      });
    });

    testWidgets('the required line fits too', (tester) async {
      for (final scale in [1.0, 2.0]) {
        for (final locale in [const Locale('en'), const Locale('sw')]) {
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final l10n = lookupAppLocalizations(locale);
          await tester.pumpWidget(const SizedBox());
          await open(
            tester,
            AddendumSheet.show,
            locale: locale,
            mode: .light,
            scale: scale,
          );

          await tester.ensureVisible(
            find.text(l10n.signedCaseAddendumContinue),
          );
          await tester.tap(find.text(l10n.signedCaseAddendumContinue));
          await tester.pump();

          expect(
            find.text(l10n.signedCaseAddendumTextRequired),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        }
      }
    });
  });
}
