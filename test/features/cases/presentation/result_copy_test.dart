import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/cases/presentation/result_copy.dart';
import 'package:tabibu/l10n/l10n.dart';

void main() {
  late AppLocalizations l10n;

  setUp(() {
    l10n = lookupAppLocalizations(const Locale('en'));
  });

  group('ResultCopy', () {
    test('waiting body omits an empty date without leaving "on ."', () {
      final text = l10n.resultsWaitingBodyFor('Dr Wanjiku', '');
      expect(text, l10n.resultsWaitingBodyNoDate('Dr Wanjiku'));
      expect(text, isNot(contains('on .')));
    });

    test('waiting body omits an empty doctor without a dangling name', () {
      final text = l10n.resultsWaitingBodyFor('', 'Mon 3 Nov');
      expect(text, l10n.resultsWaitingBodyNoDoctor('Mon 3 Nov'));
      expect(text.startsWith(' has '), isFalse);
    });

    test('waiting body has a bare variant when both are empty', () {
      expect(l10n.resultsWaitingBodyFor('', ''), l10n.resultsWaitingBodyBare);
    });

    test('reviewed step omits an empty lab without a trailing separator', () {
      final text = l10n.resultsStepReviewedDetailFor(
        'Mon 3 Nov',
        'Dr Otieno',
        '',
      );
      expect(
        text,
        l10n.resultsStepReviewedDetailNoLab('Mon 3 Nov', 'Dr Otieno'),
      );
      expect(text, isNot(contains(', ')));
      expect(text.endsWith('·'), isFalse);
    });

    test('reviewed step omits an empty doctor', () {
      expect(
        l10n.resultsStepReviewedDetailFor('Mon 3 Nov', '', 'Nairobi Lab'),
        l10n.resultsStepReviewedDetailNoDoctor('Mon 3 Nov', 'Nairobi Lab'),
      );
    });

    test('shared row omits empty doctor or date', () {
      expect(
        l10n.resultsRowSharedByFor('', 'Mon 3 Nov'),
        l10n.resultsRowSharedByNoDoctor('Mon 3 Nov'),
      );
      expect(
        l10n.resultsRowSharedByFor('Dr Wanjiku', ''),
        l10n.resultsRowSharedByNoDate('Dr Wanjiku'),
      );
    });
  });
}
