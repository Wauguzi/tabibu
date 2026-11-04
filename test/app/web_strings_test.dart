// cspell:ignore kivinjari
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/l10n/l10n.dart';

// The web degrade lines exist in both languages and say the browser, never
// the phone: the screens that show them cannot run under kIsWeb in a widget
// test, so this guards the keys instead.
void main() {
  group('web degrade lines', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final sw = lookupAppLocalizations(const Locale('sw'));

    test('en + sw parity, none empty', () {
      for (final line in [
        (en.notificationSettingsWebLine, sw.notificationSettingsWebLine),
        (en.appLockWebBiometrics, sw.appLockWebBiometrics),
        (en.resultDetailWebDownload, sw.resultDetailWebDownload),
      ]) {
        expect(line.$1, isNotEmpty);
        expect(line.$2, isNotEmpty);
        expect(line.$1, isNot(line.$2));
      }
    });

    test('each line names the browser as the limit', () {
      for (final line in [
        en.notificationSettingsWebLine,
        en.appLockWebBiometrics,
        en.resultDetailWebDownload,
      ]) {
        expect(line.toLowerCase(), contains('browser'));
      }
      for (final line in [
        sw.notificationSettingsWebLine,
        sw.appLockWebBiometrics,
        sw.resultDetailWebDownload,
      ]) {
        expect(line.toLowerCase(), contains('kivinjari'));
      }
    });
  });
}
