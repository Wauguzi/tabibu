// Guards the localization-delegate wiring in app.dart.
//
// material_ui and cupertino_ui each declare their OWN MaterialLocalizations /
// CupertinoLocalizations type, which flutter_localizations' delegates cannot
// satisfy. The failure is a type mismatch, not a missing translation, so a
// test that only checks isSupported would NOT catch it — these tests resolve
// the types and mount real widgets instead.
import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/app/view/app.dart' show tabibuLocalizationsDelegates;
import 'package:tabibu/l10n/l10n.dart';

void main() {
  group('tabibuLocalizationsDelegates', () {
    for (final locale in AppLocalizations.supportedLocales) {
      testWidgets('material_ui + cupertino_ui localizations resolve for '
          '${locale.languageCode}', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: tabibuLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                // These resolve material_ui's / cupertino_ui's types, since
                // that is what this file imports. With the generated
                // delegates these throw for every non-English locale.
                MaterialLocalizations.of(context);
                CupertinoLocalizations.of(context);
                AppLocalizations.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(tester.takeException(), isNull);
      });

      testWidgets(
        'a TextField, AppBar and dialog mount for ${locale.languageCode}',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              localizationsDelegates: tabibuLocalizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                appBar: AppBar(title: const Text('Title')),
                body: Column(
                  children: [
                    const TextField(),
                    Builder(
                      builder: (context) => TextButton(
                        onPressed: () => showDialog<void>(
                          context: context,
                          builder: (context) =>
                              const AlertDialog(content: Text('Dialog')),
                        ),
                        child: const Text('Open'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

          expect(tester.takeException(), isNull);

          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();

          expect(find.text('Dialog'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }

    test('every supported locale is covered by every delegate', () {
      for (final locale in AppLocalizations.supportedLocales) {
        for (final delegate in tabibuLocalizationsDelegates) {
          expect(
            delegate.isSupported(locale),
            isTrue,
            reason: '$delegate does not support $locale.',
          );
        }
      }
    });
  });
}
