import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/app/view/app.dart' show tabibuLocalizationsDelegates;
import 'package:tabibu/core/constants/theme_builder.dart';
import 'package:tabibu/l10n/l10n.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    ThemeMode themeMode = ThemeMode.system,
  }) {
    return pumpWidget(
      MaterialApp(
        // A mode change must remount: the app widget does not pick up a new
        // themeMode on update, so without this a re-pump stays on the old
        // theme and dark assertions silently test light.
        key: ValueKey(themeMode),
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: themeMode,
        // The app's own delegates, NOT the generated list — see app.dart.
        // Tests must mirror what ships, or a non-English pump throws
        // exactly as the real app did.
        localizationsDelegates: tabibuLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: widget),
      ),
    );
  }
}
