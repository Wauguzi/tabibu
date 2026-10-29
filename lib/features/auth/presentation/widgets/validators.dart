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
