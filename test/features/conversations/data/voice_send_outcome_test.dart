import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/conversations/data/voice_send_outcome.dart';

void main() {
  group('settleVoiceSend', () {
    test('prompt refuse deletes and returns false', () async {
      final result = Completer<VoiceSendOutcome>();
      final deleted = <String>[];
      result.complete(VoiceSendOutcome.refused);

      final ok = await settleVoiceSend(
        result: result,
        path: '/voice_pending/a.m4a',
        delete: (path) async => deleted.add(path),
        timeout: const Duration(milliseconds: 50),
      );

      expect(ok, isFalse);
      expect(deleted, ['/voice_pending/a.m4a']);
    });

    test('prompt sent returns true without deleting', () async {
      final result = Completer<VoiceSendOutcome>();
      final deleted = <String>[];
      result.complete(VoiceSendOutcome.sent);

      final ok = await settleVoiceSend(
        result: result,
        path: '/voice_pending/a.m4a',
        delete: (path) async => deleted.add(path),
        timeout: const Duration(milliseconds: 50),
      );

      expect(ok, isTrue);
      expect(deleted, isEmpty);
    });

    test('timeout returns true as queued, then late refuse deletes', () async {
      final result = Completer<VoiceSendOutcome>();
      final deleted = <String>[];

      final ok = await settleVoiceSend(
        result: result,
        path: '/voice_pending/orphan.m4a',
        delete: (path) async => deleted.add(path),
        timeout: const Duration(milliseconds: 20),
      );

      expect(ok, isTrue);
      expect(deleted, isEmpty);

      result.complete(VoiceSendOutcome.refused);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(deleted, ['/voice_pending/orphan.m4a']);
    });

    test('timeout then late queued keeps the file', () async {
      final result = Completer<VoiceSendOutcome>();
      final deleted = <String>[];

      final ok = await settleVoiceSend(
        result: result,
        path: '/voice_pending/kept.m4a',
        delete: (path) async => deleted.add(path),
        timeout: const Duration(milliseconds: 20),
      );

      expect(ok, isTrue);
      result.complete(VoiceSendOutcome.queued);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(deleted, isEmpty);
    });
  });
}
