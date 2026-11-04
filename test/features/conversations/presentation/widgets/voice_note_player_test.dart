import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabibu/features/conversations/data/models/message_model.dart';
import 'package:tabibu/features/conversations/presentation/widgets/voice_note_player.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late FakeAudioPlayerService player;
  final l10n = lookupAppLocalizations(const Locale('en'));

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    player = FakeAudioPlayerService();
  });

  tearDown(() async {
    await player.dispose();
  });

  const message = MessageModel(
    uid: 'voice-1',
    kind: 'Voice',
    voiceDurationMs: 1000,
    voicePeaks: [10, 40, 70],
  );

  Future<void> pumpPlayer(
    WidgetTester tester, {
    required Future<Uint8List> Function(MessageModel) loadBytes,
  }) async {
    tester.view.physicalSize = const Size(1170, 2000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpApp(
      VoiceNotePlayer(
        message: message,
        foreground: const Color(0xFF111111),
        loadBytes: loadBytes,
        player: player,
      ),
    );
    await tester.pump();
  }

  testWidgets('replays use the cached bytes without a second fetch', (
    tester,
  ) async {
    var loads = 0;
    final bytes = Uint8List.fromList([1, 2, 3, 4]);
    await pumpPlayer(
      tester,
      loadBytes: (_) async {
        loads += 1;
        return bytes;
      },
    );

    await tester.tap(find.bySemanticsLabel(l10n.chatVoicePlayLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
    expect(loads, 1);
    expect(player.playBytesCalls, hasLength(1));

    await tester.tap(find.bySemanticsLabel(l10n.chatVoicePauseLabel));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel(l10n.chatVoicePlayLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    expect(loads, 1);
    expect(player.playBytesCalls, hasLength(2));
    expect(player.playBytesCalls.last, same(bytes));
  });
}
