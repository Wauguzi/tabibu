import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/helpers/paste_sanitizer.dart';

void main() {
  group('sanitizePaste', () {
    test('CRLF and CR become LF', () {
      expect(sanitizePaste('a\r\nb\rc'), 'a\nb\nc');
    });

    test('control and zero-width characters are removed', () {
      expect(
        sanitizePaste('a\u0000b\u0007c\u200Bd\u200Ce\u200Df\u2060g\uFEFFh'),
        'abcdefgh',
      );
    });

    test('bidi overrides are removed', () {
      expect(
        sanitizePaste('a\u202Ab\u202Ec\u200Ed\u200Fe\u2066f\u2069g'),
        'abcdefg',
      );
    });

    test('NBSP and narrow NBSP become spaces', () {
      expect(sanitizePaste('a\u00A0b\u202Fc'), 'a b c');
    });

    test('tabs become spaces', () {
      expect(sanitizePaste('a\tb'), 'a b');
    });

    test('three or more newlines collapse to two', () {
      expect(sanitizePaste('a\n\n\n\nb'), 'a\n\nb');
    });

    test('spaces before a line break are removed, a final space is kept', () {
      expect(sanitizePaste('a   \nb  '), 'a\nb  ');
    });

    test('Swahili, units, emoji and digits stay byte-identical', () {
      // u+0169 on "u" is a real Swahili vowel mark; built so spell-check
      // does not flag the source line.
      final kept =
          'Habari ${String.fromCharCode(0x0169)}kwa m'
          '${String.fromCharCode(0x0169)}\nm ± °C 42 🩺 µm ×';
      final out = sanitizePaste(kept);
      expect(out, kept);
      expect(out.codeUnits, kept.codeUnits);
    });

    test('empty string stays empty', () {
      expect(sanitizePaste(''), '');
    });
  });

  group('fitPasteToLimit', () {
    test('cuts on whitespace in the last 80 characters', () {
      final body = '${'a' * 1920} word ${'b' * 100}';
      final fitted = fitPasteToLimit(body, 2000);
      expect(fitted.length, lessThanOrEqualTo(2000));
      expect(fitted.endsWith('word'), isTrue);
    });

    test('cuts hard when no whitespace is near the limit', () {
      final body = 'a' * 2500;
      expect(fitPasteToLimit(body, 2000), 'a' * 2000);
    });
  });

  group('PasteSanitizeFormatter', () {
    test(
      'one-character insertion passes through even with invisibles present',
      () {
        const dirty = 'a\u200Bb';
        final formatter = PasteSanitizeFormatter();
        final next = formatter.formatEditUpdate(
          const TextEditingValue(
            text: dirty,
            selection: TextSelection.collapsed(offset: 3),
          ),
          const TextEditingValue(
            text: 'a\u200Bbc',
            selection: TextSelection.collapsed(offset: 4),
          ),
        );
        expect(next.text, 'a\u200Bbc');
      },
    );

    test('deletion passes through unchanged', () {
      final formatter = PasteSanitizeFormatter();
      final next = formatter.formatEditUpdate(
        const TextEditingValue(
          text: 'a\u200Bb',
          selection: TextSelection.collapsed(offset: 3),
        ),
        const TextEditingValue(
          text: 'a\u200B',
          selection: TextSelection.collapsed(offset: 2),
        ),
      );
      expect(next.text, 'a\u200B');
    });

    test('multi-character insertion is sanitised', () {
      final formatter = PasteSanitizeFormatter();
      final next = formatter.formatEditUpdate(
        const TextEditingValue(
          text: 'Hi',
          selection: TextSelection.collapsed(offset: 2),
        ),
        const TextEditingValue(
          text: 'Hi\u200B there\u00A0x',
          selection: TextSelection.collapsed(offset: 12),
        ),
      );
      expect(next.text, 'Hi there x');
      expect(next.text.contains('\u200B'), isFalse);
    });

    test('a paste in the middle leaves the caret after the pasted text', () {
      final formatter = PasteSanitizeFormatter();
      final next = formatter.formatEditUpdate(
        const TextEditingValue(
          text: 'AB',
          selection: TextSelection.collapsed(offset: 1),
        ),
        const TextEditingValue(
          text: 'A\u200B xyz \u200BB',
          selection: TextSelection.collapsed(offset: 9),
        ),
      );
      expect(next.text, 'A xyz B');
      expect(next.selection.extentOffset, 6);
    });

    test('a short paste over a long selection is still cleaned', () {
      final formatter = PasteSanitizeFormatter();
      final next = formatter.formatEditUpdate(
        const TextEditingValue(
          text: 'a long sentence to replace',
          selection: TextSelection(baseOffset: 0, extentOffset: 26),
        ),
        const TextEditingValue(
          text: 'ok\u200B now',
          selection: TextSelection.collapsed(offset: 8),
        ),
      );
      expect(next.text, 'ok now');
    });

    test('over the limit, the pasted part is cut and the text kept', () {
      var cutAt = 0;
      final formatter = PasteSanitizeFormatter(
        maxLength: 20,
        onPasteCut: (limit) => cutAt = limit,
      );
      final next = formatter.formatEditUpdate(
        const TextEditingValue(
          text: 'START END',
          selection: TextSelection.collapsed(offset: 5),
        ),
        const TextEditingValue(
          text: 'START one two three four five END',
          selection: TextSelection.collapsed(offset: 29),
        ),
      );
      expect(next.text.length, lessThanOrEqualTo(20));
      expect(next.text.startsWith('START '), isTrue);
      expect(next.text.endsWith('END'), isTrue);
      expect(cutAt, 20);
    });

    test('a cut never leaves half of an emoji', () {
      final formatter = PasteSanitizeFormatter(maxLength: 5);
      final next = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: 'abcd\u{1F600}efg',
          selection: TextSelection.collapsed(offset: 9),
        ),
      );
      for (final unit in next.text.codeUnits) {
        expect(unit >= 0xD800 && unit <= 0xDFFF, isFalse);
      }
    });

    test('a keyboard rewrite with nothing to clean keeps its own caret', () {
      final formatter = PasteSanitizeFormatter();
      const next = TextEditingValue(
        text: 'hello world today',
        selection: TextSelection.collapsed(offset: 5),
      );
      final out = formatter.formatEditUpdate(
        const TextEditingValue(
          text: 'hallo world today',
          selection: TextSelection.collapsed(offset: 4),
        ),
        next,
      );
      expect(out, next);
    });

    test(
      'a 60,000-character paste is capped at 50,000 then the field limit',
      () {
        final huge = 'x' * 60000;
        final ceilingOnly = PasteSanitizeFormatter();
        final capped = ceilingOnly.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
            text: huge,
            selection: TextSelection.collapsed(offset: huge.length),
          ),
        );
        expect(capped.text.length, pasteHardCeiling);

        var cutAt = 0;
        final formatter = PasteSanitizeFormatter(
          maxLength: 2000,
          onPasteCut: (limit) => cutAt = limit,
        );
        final next = formatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
            text: huge,
            selection: TextSelection.collapsed(offset: huge.length),
          ),
        );
        expect(next.text.length, lessThanOrEqualTo(2000));
        expect(cutAt, 2000);
      },
    );
  });
}
