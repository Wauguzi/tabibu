import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/theme_builder.dart';
import 'package:tabibu/l10n/l10n.dart';

/// Localization delegates for the app.
///
/// Deliberately not [AppLocalizations.localizationsDelegates]: the generated
/// list wires up flutter_localizations' GlobalMaterialLocalizations, which
/// satisfies the framework's MaterialLocalizations type, not material_ui's
/// own forked type. English hides the mismatch; every other locale throws on
/// the first TextField, AppBar or dialog. Guarded by
/// test/app/localizations_delegates_test.dart.
const tabibuLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  // material_ui's own — NOT flutter_localizations'.
  GlobalMaterialLocalizations.delegate,
  // cupertino_ui's own — NOT flutter_localizations'.
  GlobalCupertinoLocalizations.delegate,
  // WidgetsLocalizations is NOT forked; the framework delegate is correct.
  GlobalWidgetsLocalizations.delegate,
];

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      localizationsDelegates: tabibuLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // The typed router replaces this placeholder in a later brief.
      home: const _PlaceholderHome(),
    );
  }
}

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(context.l10n.appTitle)));
  }
}
