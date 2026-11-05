import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/services/audio_player_service.dart';

void main() {
  test('web byte source is a data URI, not a file path', () {
    final bytes = Uint8List.fromList([1, 2, 3, 4]);
    final uri = JustAudioPlayerPlatform.webByteUri(bytes);
    expect(uri.scheme, 'data');
    expect(uri.toString(), contains('audio/mp4'));
    expect(uri.toString(), isNot(contains('/tmp/')));
    expect(uri.toString(), isNot(contains(r'\')));
  });
}
