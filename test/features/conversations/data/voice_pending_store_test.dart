import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/conversations/data/voice_pending_store.dart';

void main() {
  late Directory root;
  late VoicePendingStore store;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('voice_pending_');
    store = VoicePendingStore(supportRoot: () => root);
  });

  tearDown(() async {
    if (root.existsSync()) await root.delete(recursive: true);
  });

  test('write lands under the injected support root, not temp', () async {
    final path = await store.write(Uint8List.fromList([1, 2, 3]));
    expect(path, startsWith('${root.path}/voice_pending/'));
    expect(File(path).existsSync(), isTrue);
    // Production uses getApplicationSupportDirectory; the injected root stands
    // in for that here (itself under systemTemp only for the test harness).
    expect(store.supportRoot, isNotNull);
  });

  test('delete removes a queued file after a successful upload', () async {
    final path = await store.write(Uint8List.fromList([9, 9]));
    expect(File(path).existsSync(), isTrue);
    await store.delete(path);
    expect(File(path).existsSync(), isFalse);
  });

  test('delete is a no-op when the file is already gone', () async {
    await expectLater(store.delete('${root.path}/missing.m4a'), completes);
  });
}
