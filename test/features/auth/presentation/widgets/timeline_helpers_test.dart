import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/auth/presentation/widgets/timeline_helpers.dart';
import 'package:tabibu/l10n/l10n.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('sw');
  });

  group('submittedStamp', () {
    test('today reads through the today string', () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      final sw = await AppLocalizations.delegate.load(const Locale('sw'));
      final createdAt = DateTime.now().toIso8601String();

      expect(submittedStamp(createdAt, en), startsWith('Today, '));
      expect(submittedStamp(createdAt, sw), startsWith('Leo, '));
    });

    test('a dated stamp reads in the reader language', () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      final sw = await AppLocalizations.delegate.load(const Locale('sw'));
      final year = DateTime.now().year - 1;
      final createdAt = DateTime(year, 10, 29, 9, 12).toIso8601String();

      expect(submittedStamp(createdAt, en), '29 Oct $year, 09:12');
      expect(submittedStamp(createdAt, sw), '29 Okt $year, 09:12');
    });

    test('an invalid stamp reads as nothing', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      expect(submittedStamp('not-a-date', l10n), isNull);
    });
  });
}
