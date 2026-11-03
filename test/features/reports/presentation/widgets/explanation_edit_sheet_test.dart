import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/reports/presentation/widgets/explanation_edit_sheet.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('showExplanationEditSheet', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    final results = <Map<String, String>?>[];

    setUp(results.clear);

    Future<void> settleSheet(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    Future<void> open(
      WidgetTester tester, {
      Map<String, String> segments = const {'a': 'First', 'b': 'Second'},
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
            onPressed: () => showExplanationEditSheet(
              context,
              language: 'English',
              segments: segments,
            ).then(results.add),
            child: const Text('Open'),
          ),
        ),
        themeMode: themeMode,
        locale: locale,
      );
      await tester.tap(find.text('Open'));
      await settleSheet(tester);
    }

    testWidgets('prefills one field per segment, keeping order and text', (
      tester,
    ) async {
      await open(tester);

      expect(find.text(l10n.explanationEditTitle), findsOneWidget);
      final fields = tester.widgetList<TextField>(find.byType(TextField));
      expect(fields.map((f) => f.controller?.text), ['First', 'Second']);
      expect(find.text('English'), findsNWidgets(2));
    });

    testWidgets('does not open the keyboard on arrival', (tester) async {
      await open(tester);

      expect(
        tester
            .widgetList<TextField>(find.byType(TextField))
            .any((f) => f.autofocus),
        isFalse,
      );
    });

    testWidgets('Save and approve returns every segment as edited, by key', (
      tester,
    ) async {
      await open(tester);

      await tester.enterText(find.byType(TextField).last, 'Second, edited');
      await tester.pump();
      await tester.tap(find.text(l10n.explanationSaveAndApprove));
      await settleSheet(tester);

      expect(results, [
        {'a': 'First', 'b': 'Second, edited'},
      ]);
    });

    testWidgets('a blank segment turns Save and approve off; refilling it '
        'turns it back on', (tester) async {
      await open(tester);

      await tester.enterText(find.byType(TextField).first, '  \n ');
      await tester.pump();
      await tester.tap(find.text(l10n.explanationSaveAndApprove));
      await settleSheet(tester);
      expect(results, isEmpty);
      expect(find.text(l10n.explanationEditTitle), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Back');
      await tester.pump();
      await tester.tap(find.text(l10n.explanationSaveAndApprove));
      await settleSheet(tester);
      expect(results, [
        {'a': 'Back', 'b': 'Second'},
      ]);
    });

    testWidgets('stops a segment at the server limit', (tester) async {
      await open(tester, segments: const {'a': 'x'});

      await tester.enterText(
        find.byType(TextField),
        List.filled(explanationSegmentMaxLength + 50, 'y').join(),
      );
      await tester.pump();

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        hasLength(explanationSegmentMaxLength),
      );
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

      await tester.tap(find.text(l10n.explanationSaveAndApprove));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(results, isEmpty);

      await settleSheet(tester);
      expect(results, hasLength(1));
    });

    testWidgets('draws in dark mode', (tester) async {
      await open(tester, themeMode: ThemeMode.dark);

      expect(find.text(l10n.explanationEditTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final scale in const [1.3, 2.0]) {
      testWidgets('Swahili at ${scale}x on a 390 dp screen does not overflow', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(390 * 3, 2400);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await open(tester, locale: const Locale('sw'));
        final sw = lookupAppLocalizations(const Locale('sw'));

        expect(find.text(sw.explanationEditTitle), findsOneWidget);
        expect(find.text(sw.explanationSaveAndApprove), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
