import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/data/models/ordered_test_model.dart';
import 'package:tabibu/features/reports/presentation/widgets/case_request_view.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

CaseModel _case({required String expires}) => CaseModel(
  uid: 'c1',
  orderNumber: 'TB-0231',
  currentStage: 'PathologistRequested',
  pathologistRequestExpiresAt: expires,
  priority: 'Urgent',
  tests: const [OrderedTestModel(name: 'Histopathology examination')],
);

void _useTextScale(WidgetTester tester, double scale) {
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

String _replyBy(AppLocalizations l10n, String language, String expires) =>
    l10n.workspaceRequestReplyBy(
      DateFormat('EEE d MMM, h:mm a', language).format(nairobiTimeOf(expires)!),
    );

void main() {
  // Unambiguous either side of any clock the test runs under: no pin needed.
  const lapsed = '2020-06-01T09:00:00Z';
  const pending = '2030-06-01T09:00:00Z';

  Future<void> pump(
    WidgetTester tester, {
    required String expires,
    required Locale locale,
    required VoidCallback onAccept,
    ThemeMode mode = ThemeMode.light,
  }) async {
    tester.view.physicalSize = const Size(1170, 6000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpApp(
      CaseRequestView(
        caseModel: _case(expires: expires),
        busy: false,
        onAccept: onAccept,
        onDecline: (_) {},
      ),
      locale: locale,
      themeMode: mode,
    );
    await tester.pump();
  }

  group('CaseRequestView', () {
    testWidgets('a lapsed request says so instead of the reply-by', (
      tester,
    ) async {
      for (final scale in [1.0, 2.0]) {
        for (final locale in [const Locale('en'), const Locale('sw')]) {
          _useTextScale(tester, scale);
          final l10n = lookupAppLocalizations(locale);
          await pump(tester, expires: lapsed, locale: locale, onAccept: () {});

          expect(find.text(l10n.workspaceRequestLapsed), findsOneWidget);
          expect(
            find.text(_replyBy(l10n, locale.languageCode, lapsed)),
            findsNothing,
          );
        }
      }
    });

    testWidgets('a pending request still shows the reply-by', (tester) async {
      for (final scale in [1.0, 2.0]) {
        for (final locale in [const Locale('en'), const Locale('sw')]) {
          _useTextScale(tester, scale);
          final l10n = lookupAppLocalizations(locale);
          await pump(tester, expires: pending, locale: locale, onAccept: () {});

          expect(
            find.text(_replyBy(l10n, locale.languageCode, pending)),
            findsOneWidget,
          );
          expect(find.text(l10n.workspaceRequestLapsed), findsNothing);
        }
      }
    });

    testWidgets('accept still sends a lapsed request', (tester) async {
      for (final scale in [1.0, 2.0]) {
        for (final locale in [const Locale('en'), const Locale('sw')]) {
          _useTextScale(tester, scale);
          final l10n = lookupAppLocalizations(locale);
          var accepted = 0;
          await pump(
            tester,
            expires: lapsed,
            locale: locale,
            onAccept: () => accepted++,
          );

          await tester.tap(find.text(l10n.workspaceRequestAccept));
          await tester.pump();

          expect(accepted, 1);
        }
      }
    });

    testWidgets('the lapsed view fits a phone, both modes included', (
      tester,
    ) async {
      for (final scale in [1.0, 2.0]) {
        for (final locale in [const Locale('en'), const Locale('sw')]) {
          for (final mode in [ThemeMode.light, ThemeMode.dark]) {
            _useTextScale(tester, scale);
            final l10n = lookupAppLocalizations(locale);
            await pump(
              tester,
              expires: lapsed,
              locale: locale,
              onAccept: () {},
              mode: mode,
            );

            expect(find.text(l10n.workspaceRequestLapsed), findsOneWidget);
            expect(find.text(l10n.workspaceRequestAccept), findsOneWidget);
            expect(tester.takeException(), isNull);
          }
        }
      }
    });
  });
}
