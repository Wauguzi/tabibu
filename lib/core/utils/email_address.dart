/// One local part, one `@`, a dotted domain and a top-level domain of two or
/// more letters, with no spaces. Firebase still judges the address; this
/// catches the typing mistakes before a round trip.
final RegExp _emailPattern = RegExp(
  r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+"
  '@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?'
  r'(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)*'
  r'\.[A-Za-z]{2,}$',
);

bool isValidEmail(String value) {
  final email = value.trim();
  return email.length <= 254 &&
      !email.contains('..') &&
      _emailPattern.hasMatch(email);
}

/// `amina.wambui@gmail.com` → `a•••@gmail.com`, so a screen can say where a
/// link went without showing the whole address.
String maskEmail(String email) {
  final at = email.indexOf('@');
  if (at < 1) return email;
  return '${email[0]}•••${email.substring(at)}';
}
