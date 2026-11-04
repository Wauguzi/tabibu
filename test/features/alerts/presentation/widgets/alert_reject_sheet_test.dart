import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/alerts/presentation/widgets/alert_reject_sheet.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('showAlertRejectSheet', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    final results = <String?>[];

    setUp(results.clear);

    Future<void> settleSheet(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    Future<void> open(
      WidgetTester tester, {
      ThemeMode themeMode = ThemeMode.light,
      Locale? locale,
    }) async {
      if (tester.view.physicalSize.height < 2000) {
        tester.view.physicalSize = const Size(1170, 4000);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);
      }
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showAlertRejectSheet(context).then(results.add),
            child: const Text('Open'),
          ),
        ),
        themeMode: themeMode,
        locale: locale,
      );
      await tester.tap(find.text('Open'));
      await settleSheet(tester);
    }

    TabibuButton rejectButton(WidgetTester tester) => tester.widget(
      find.widgetWithText(TabibuButton, l10n.alertReviewRejectAlert),
    );

    testWidgets('lists the four reasons, none chosen, Reject off', (
      tester,
    ) async {
      await open(tester);

      expect(find.text(l10n.alertReviewRejectTitle), findsOneWidget);
      expect(find.text(l10n.alertReviewRejectBody), findsOneWidget);
      for (final reason in [
        l10n.alertReviewReasonNotEnough,
        l10n.alertReviewReasonOneHousehold,
        l10n.alertReviewReasonWrongArea,
        l10n.alertReviewReasonOther,
      ]) {
        expect(find.text(reason), findsOneWidget);
      }
      expect(find.text(l10n.alertReviewReasonOtherSub), findsOneWidget);
      expect(
        tester
            .widgetList<OptionCard>(find.byType(OptionCard))
            .any((c) => c.selected),
        isFalse,
      );
      expect(rejectButton(tester).onTap, isNull);
    });

    testWidgets('a choice turns Reject on and returns the reason', (
      tester,
    ) async {
      await open(tester);

      await tester.tap(find.text(l10n.alertReviewReasonWrongArea));
      await tester.pump();
      expect(rejectButton(tester).onTap, isNotNull);
      await tester.tap(find.text(l10n.alertReviewRejectAlert));
      await settleSheet(tester);

      expect(results, [l10n.alertReviewReasonWrongArea]);
    });

    testWidgets('a note follows the reason', (tester) async {
      await open(tester);

      await tester.tap(find.text(l10n.alertReviewReasonOther));
      await tester.enterText(find.byType(TextField), '  Duplicate report  ');
      await tester.pump();
      await tester.tap(find.text(l10n.alertReviewRejectAlert));
      await settleSheet(tester);

      expect(results, ['${l10n.alertReviewReasonOther}: Duplicate report']);
    });

    testWidgets('a note without a choice rejects nothing', (tester) async {
      await open(tester);

      await tester.enterText(find.byType(TextField), 'Just a note');
      await tester.pump();
      await tester.tap(find.text(l10n.alertReviewRejectAlert));
      await settleSheet(tester);

      expect(results, isEmpty);
    });

    testWidgets('Cancel returns null', (tester) async {
      await open(tester);

      await tester.tap(find.text(l10n.commonCancel));
      await settleSheet(tester);

      expect(results, [null]);
    });

    testWidgets('the result arrives only after the sheet has slid away', (
      tester,
    ) async {
      await open(tester);

      await tester.tap(find.text(l10n.alertReviewReasonNotEnough));
      await tester.pump();
      await tester.tap(find.text(l10n.alertReviewRejectAlert));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(results, isEmpty);

      await settleSheet(tester);
      expect(results, hasLength(1));
    });

    testWidgets('does not open the keyboard on arrival', (tester) async {
      await open(tester);

      expect(tester.widget<TextField>(find.byType(TextField)).autofocus, false);
    });

    testWidgets('draws in dark mode', (tester) async {
      await open(tester, themeMode: ThemeMode.dark);

      expect(find.text(l10n.alertReviewRejectTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Swahili at 1.3x on a 390 dp screen does not overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 2800);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await open(tester, locale: const Locale('sw'));
      final sw = lookupAppLocalizations(const Locale('sw'));

      expect(find.text(sw.alertReviewRejectTitle), findsOneWidget);
      expect(find.text(sw.alertReviewRejectAlert), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
