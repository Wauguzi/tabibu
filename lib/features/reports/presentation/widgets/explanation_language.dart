import 'package:tabibu/l10n/l10n.dart';

/// The name of an explanation's language, from its `en` or `sw` code.
String explanationLanguageName(AppLocalizations l10n, String code) =>
    switch (code) {
      'en' => l10n.languageEn,
      'sw' => l10n.languageSw,
      _ => code,
    };
