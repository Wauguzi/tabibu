import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/alerts/data/models/alert_text_model.dart';
import 'package:tabibu/features/alerts/presentation/widgets/alert_edit_sheet.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

const _segments = {
  'clinician_en': AlertTextModel(
    headline: 'Doctors head',
    body: 'Doctors body',
  ),
  'patient_en': AlertTextModel(
    headline: 'Patients head',
    body: 'Patients body',
  ),
};

void main() {
  group('showAlertEditSheet', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    final results = <Map<String, AlertTextModel>?>[];

    setUp(results.clear);

    Future<void> settleSheet(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    Future<void> open(
      WidgetTester tester, {
      ThemeMode themeMode = ThemeMode.light,
      Locale? locale,
      String language = 'en',
    }) async {
      if (tester.view.physicalSize.height < 2000) {
        tester.view.physicalSize = const Size(1170, 4000);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);
      }
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showAlertEditSheet(
              context,
              language: language,
              area: 'Embakasi',
              segments: _segments,
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

    testWidgets('prefills a headline and a body per audience, in order', (
      tester,
    ) async {
      await open(tester);

      final fields = tester.widgetList<TextField>(find.byType(TextField));
      expect(fields.map((f) => f.controller?.text), [
        'Doctors head',
        'Doctors body',
        'Patients head',
        'Patients body',
      ]);
      expect(find.text(l10n.reviewEdit), findsOneWidget);
      expect(find.text(l10n.languageEn), findsOneWidget);
      expect(
        find.text(l10n.alertReviewForDoctors('Embakasi')),
        findsNWidgets(2),
      );
      expect(
        find.text(l10n.alertReviewForPatients('Embakasi')),
        findsNWidgets(2),
      );
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

    testWidgets('Save and approve returns every key, edited or not', (
      tester,
    ) async {
      await open(tester);

      await tester.enterText(find.byType(TextField).at(3), 'Patients body, v2');
      await tester.pump();
      await tester.tap(find.text(l10n.explanationSaveAndApprove));
      await settleSheet(tester);

      expect(results, [
        {
          'clinician_en': _segments['clinician_en'],
          'patient_en': const AlertTextModel(
            headline: 'Patients head',
            body: 'Patients body, v2',
          ),
        },
      ]);
    });

    testWidgets('an untouched save returns the draft as it was', (
      tester,
    ) async {
      await open(tester);

      await tester.tap(find.text(l10n.explanationSaveAndApprove));
      await settleSheet(tester);

      expect(results, [_segments]);
    });

    testWidgets('a blank headline or body turns Save off', (tester) async {
      await open(tester);

      await tester.enterText(find.byType(TextField).first, '   ');
      await tester.pump();
      await tester.tap(find.text(l10n.explanationSaveAndApprove));
      await settleSheet(tester);
      expect(results, isEmpty);

      await tester.enterText(find.byType(TextField).first, 'Back');
      await tester.enterText(find.byType(TextField).at(1), '');
      await tester.pump();
      await tester.tap(find.text(l10n.explanationSaveAndApprove));
      await settleSheet(tester);
      expect(results, isEmpty);
    });

    testWidgets('stops a headline and a body at the server limits', (
      tester,
    ) async {
      await open(tester);

      await tester.enterText(
        find.byType(TextField).first,
        List.filled(alertHeadlineMaxLength + 20, 'y').join(),
      );
      await tester.enterText(
        find.byType(TextField).at(1),
        List.filled(alertBodyMaxLength + 20, 'z').join(),
      );
      await tester.pump();

      final fields = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      expect(fields[0].controller?.text, hasLength(alertHeadlineMaxLength));
      expect(fields[1].controller?.text, hasLength(alertBodyMaxLength));
    });

    testWidgets('Cancel returns null', (tester) async {
      await open(tester);

      await tester.tap(find.text(l10n.commonCancel));
      await settleSheet(tester);

      expect(results, [null]);
    });

    testWidgets('draws in dark mode', (tester) async {
      await open(tester, themeMode: ThemeMode.dark);

      expect(find.text(l10n.reviewEdit), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Swahili at 1.3x on a 390 dp screen does not overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await open(tester, locale: const Locale('sw'), language: 'sw');
      final sw = lookupAppLocalizations(const Locale('sw'));

      expect(find.text(sw.languageSw), findsOneWidget);
      expect(find.text(sw.explanationSaveAndApprove), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
