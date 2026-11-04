import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/reports/presentation/widgets/report_file_card.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('ReportFileCard', () {
    testWidgets('renders labels and fires Download and Share', (tester) async {
      var downloads = 0;
      var shares = 0;
      await tester.pumpApp(
        ReportFileCard(
          title: 'Full report',
          fileName: 'Full blood count · 12 Sep.pdf',
          meta: 'PDF · 120 KB · from Mama Lucy Hospital',
          downloadLabel: 'Download',
          shareLabel: 'Share',
          onDownload: () => downloads++,
          onShare: () => shares++,
        ),
      );

      expect(find.text('Full report'), findsOneWidget);
      expect(find.text('Full blood count · 12 Sep.pdf'), findsOneWidget);
      expect(
        find.text('PDF · 120 KB · from Mama Lucy Hospital'),
        findsOneWidget,
      );

      await tester.tap(find.text('Download'));
      await tester.pump();
      expect(downloads, 1);

      await tester.tap(find.text('Share'));
      await tester.pump();
      expect(shares, 1);
    });

    testWidgets('null onDownload disables Download', (tester) async {
      await tester.pumpApp(
        ReportFileCard(
          title: 'Full report',
          fileName: 'report.pdf',
          meta: 'PDF · 120 KB',
          downloadLabel: 'Download',
          shareLabel: 'Share',
          onDownload: null,
          onShare: () {},
        ),
      );

      await tester.tap(find.text('Download'));
      await tester.pump();
      // Disabled primary keeps the label and absorbs the tap.
      expect(find.text('Download'), findsOneWidget);
    });

    testWidgets('null onShare hides Share', (tester) async {
      await tester.pumpApp(
        const ReportFileCard(
          title: 'Full report',
          fileName: 'report.pdf',
          meta: 'PDF · 120 KB',
          downloadLabel: 'Download',
          shareLabel: 'Share',
          onDownload: _noop,
        ),
      );

      expect(find.text('Download'), findsOneWidget);
      expect(find.text('Share'), findsNothing);
    });

    testWidgets('renders in light and dark', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(
          const ReportFileCard(
            title: 'Full report',
            fileName: 'report.pdf',
            meta: 'PDF · 120 KB',
            downloadLabel: 'Download',
            shareLabel: 'Share',
            onDownload: _noop,
            onShare: _noop,
          ),
          themeMode: mode,
        );
        expect(find.byType(ReportFileCard), findsOneWidget);
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
        const SizedBox(
          width: 390,
          child: ReportFileCard(
            title: 'Full pathology report',
            fileName: 'Full blood count · 12 September.pdf',
            meta: 'PDF · 120 KB · from Mama Lucy Hospital campus',
            downloadLabel: 'Download report',
            shareLabel: 'Share report',
            onDownload: _noop,
            onShare: _noop,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}

void _noop() {}
