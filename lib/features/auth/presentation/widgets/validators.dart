import 'package:flutter/services.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The server accepts Kenyan mobile numbers only, stored E.164. Accepts the
/// national digits (D3), a 0-prefixed number, or a +254 number (E1/F1), and
/// returns `+254…`, or null when the digits are not a Kenyan mobile.
String? normalizeKePhone(String raw) {
  var digits = raw.replaceAll(RegExp(r'[\s\-()]'), '');
  if (digits.startsWith('+')) digits = digits.substring(1);
  if (digits.startsWith('254')) {
    digits = digits.substring(3);
  } else if (digits.startsWith('0')) {
    digits = digits.substring(1);
  }
  if (!RegExp(r'^[17]\d{8}$').hasMatch(digits)) return null;
  return '+254$digits';
}

/// Groups national digits 3-3-3 for display ("712 345 678"), dropping a
/// pasted 0 or 254 prefix and anything past nine digits. Storage stays
/// E.164 through [normalizeKePhone].
String formatKePhone(String value) {
  var digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length > 9 && digits.startsWith('254')) {
    digits = digits.substring(3);
  }
  digits = digits.replaceFirst(RegExp('^0+'), '');
  if (digits.length > 9) digits = digits.substring(0, 9);
  if (digits.length <= 3) return digits;
  if (digits.length <= 6) {
    return '${digits.substring(0, 3)} ${digits.substring(3)}';
  }
  return '${digits.substring(0, 3)} ${digits.substring(3, 6)} '
      '${digits.substring(6)}';
}

/// Groups typed digits as [formatKePhone]; the caret rests at the end.
class KePhoneFormatter extends TextInputFormatter {
  const KePhoneFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = formatKePhone(newValue.text);
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
      composing: TextRange.empty,
    );
  }
}

/// The meter's three rules, mirrored so Continue enables exactly when the
/// meter fills.
bool isPasswordStrong(String password) =>
    password.length >= 8 &&
    RegExp('[0-9]').hasMatch(password) &&
    RegExp('[^A-Za-z0-9]').hasMatch(password);

/// Weak below two rules, good at two, strong at three (D2's design).
String passwordStrengthWord(String password, AppLocalizations l10n) {
  final met = [
    password.length >= 8,
    RegExp('[0-9]').hasMatch(password),
    RegExp('[^A-Za-z0-9]').hasMatch(password),
  ].where((m) => m).length;
  if (met >= 3) return l10n.passwordStrengthStrong;
  if (met == 2) return l10n.passwordStrengthGood;
  return l10n.passwordStrengthWeak;
}
