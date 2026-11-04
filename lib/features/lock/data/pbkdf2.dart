import 'dart:typed_data';

// Transitive only; the brief adds no dependency. Resolved by pubspec.lock.
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';

/// PBKDF2 (RFC 8018) over HMAC-SHA256, one 32-byte block: the length of the
/// digest, which is all a PIN hash needs. Written here because the app has
/// no direct dependency that offers it, and a bare SHA-256 of a four-digit
/// PIN falls to a ten-thousand-guess table.
Uint8List pbkdf2HmacSha256({
  required List<int> password,
  required List<int> salt,
  required int iterations,
}) {
  if (iterations < 1) throw ArgumentError.value(iterations, 'iterations');
  final hmac = Hmac(sha256, password);
  // U1 = HMAC(password, salt || INT_32_BE(1)).
  var u = hmac.convert([...salt, 0, 0, 0, 1]).bytes;
  final t = Uint8List.fromList(u);
  for (var i = 1; i < iterations; i++) {
    u = hmac.convert(u).bytes;
    for (var j = 0; j < t.length; j++) {
      t[j] ^= u[j];
    }
  }
  return t;
}
