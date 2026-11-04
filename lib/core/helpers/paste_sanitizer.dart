import 'package:flutter/services.dart';

/// Hard ceiling on one paste so a stray dump cannot freeze the field.
const int pasteHardCeiling = 50000;

/// How far back from the field limit to look for a whitespace cut point.
const int pasteCutWindow = 80;

/// Invisible / bidi / zero-width characters removed on paste. A **superset**
/// of the server's `INVISIBLE` set in `functions/src/sanitize.ts`, plus LRM /
/// RLM and the word joiner the brief names.
final RegExp _invisible = RegExp(
  '['
  r'\u0000-\u0008\u000B\u000C\u000E-\u001F' // C0 except TAB/LF
  r'\u007F-\u009F' // C1
  r'\u200B-\u200F' // zero-width + LRM/RLM
  r'\u202A-\u202E' // bidi embeddings
  r'\u2060' // word joiner
  r'\u2066-\u2069' // bidi isolates
  '${String.fromCharCode(0xFEFF)}' // byte-order mark
  r'\u2028\u2029' // line/paragraph separators
  ']',
  unicode: true,
);

/// Cleans free text that arrived as a paste (or other multi-character insert).
/// Typing and single-character edits are left alone by
/// [PasteSanitizeFormatter].
String sanitizePaste(String raw) {
  if (raw.isEmpty) return raw;
  var text = raw
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .replaceAll('\t', ' ')
      .replaceAll('\u00A0', ' ')
      .replaceAll('\u202F', ' ');
  text = text.replaceAll(_invisible, '');
  // Spaces before a line break only: a pasted piece may end on the space that
  // separates it from the word typed next, and the server trims the ends.
  text = text.replaceAll(RegExp(r' +\n'), '\n');
  text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return text;
}

/// Keeps up to [limit] UTF-16 units, preferring a cut on whitespace in the
/// last [pasteCutWindow] characters.
String fitPasteToLimit(String text, int limit) {
  if (limit <= 0) return '';
  if (text.length <= limit) return text;
  final window = _withoutSplitPair(text.substring(0, limit));
  final searchFrom = limit > pasteCutWindow ? limit - pasteCutWindow : 0;
  for (var i = window.length - 1; i >= searchFrom; i--) {
    final c = window.codeUnitAt(i);
    if (c == 0x20 || c == 0x0A) {
      return window.substring(0, i);
    }
  }
  return window;
}

/// A cut must not leave half of an emoji (a lone high surrogate) at the end.
String _withoutSplitPair(String text) {
  if (text.isEmpty) return text;
  final last = text.codeUnitAt(text.length - 1);
  return last >= 0xD800 && last <= 0xDBFF
      ? text.substring(0, text.length - 1)
      : text;
}

/// Formats only multi-character insertions (paste / replace-with-many).
/// Single-character typing, backspace and deletion pass through unchanged.
class PasteSanitizeFormatter extends TextInputFormatter {
  PasteSanitizeFormatter({
    this.maxLength,
    this.onPasteCut,
    this.ceiling = pasteHardCeiling,
  });

  /// Field limit (diagnosis 2,000, etc.). Null means no field cut / notice.
  final int? maxLength;

  /// Called when a paste was shortened to [maxLength].
  final ValueChanged<int>? onPasteCut;

  /// Cap on characters accepted from one paste before the field limit.
  final int ceiling;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final oldText = oldValue.text;
    final newText = newValue.text;

    final sel = oldValue.selection;
    final replaceStart = sel.isValid
        ? sel.start.clamp(0, oldText.length)
        : oldText.length;
    final replaceEnd = sel.isValid
        ? sel.end.clamp(0, oldText.length)
        : oldText.length;
    final replaced = replaceEnd - replaceStart;
    // Counted against the selection, so a short paste over a long selection
    // is still a paste.
    final insertedLength = newText.length - (oldText.length - replaced);
    if (insertedLength <= 1) return newValue;

    final prefix = oldText.substring(0, replaceStart);
    final suffix = oldText.substring(replaceEnd);
    final String inserted;
    final String basePrefix;
    final String baseSuffix;
    final bool located;
    if (newText.startsWith(prefix) &&
        newText.length >= prefix.length + suffix.length &&
        (suffix.isEmpty || newText.endsWith(suffix))) {
      inserted = newText.substring(
        prefix.length,
        newText.length - suffix.length,
      );
      basePrefix = prefix;
      baseSuffix = suffix;
      located = true;
    } else {
      // An input method rewrote text before the cursor: clean the whole value
      // and leave the caret where the keyboard put it.
      inserted = newText;
      basePrefix = '';
      baseSuffix = '';
      located = false;
    }

    var cleaned = sanitizePaste(inserted);
    if (cleaned.length > ceiling) {
      cleaned = _withoutSplitPair(cleaned.substring(0, ceiling));
    }
    final limit = maxLength;
    var cut = false;
    if (limit != null &&
        basePrefix.length + cleaned.length + baseSuffix.length > limit) {
      // Cut the pasted part, never the text already there.
      final room = limit - basePrefix.length - baseSuffix.length;
      cleaned = fitPasteToLimit(cleaned, room);
      cut = true;
    }
    final merged = '$basePrefix$cleaned$baseSuffix';
    if (cut) onPasteCut?.call(limit!);
    if (merged == newText) return newValue;
    final caret = located
        ? basePrefix.length + cleaned.length
        : newValue.selection.isValid
        ? newValue.selection.extentOffset
        : merged.length;
    return TextEditingValue(
      text: merged,
      selection: TextSelection.collapsed(offset: caret.clamp(0, merged.length)),
    );
  }
}
