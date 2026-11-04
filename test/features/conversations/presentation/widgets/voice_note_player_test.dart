import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabibu/core/services/analytics_service.dart';
import 'package:tabibu/features/conversations/data/models/message_model.dart';
import 'package:tabibu/features/conversations/presentation/widgets/voice_note_player.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

class _MockAnalytics extends Mock implements AnalyticsService {}

void main() {
  late FakeAudioPlayerService player;
  late _MockAnalytics analytics;
  final l10n = lookupAppLocalizations(const Locale('en'));

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    player = FakeAudioPlayerService();
    analytics = _MockAnalytics();
    when(() => analytics.logVoicePlaybackStarted()).thenAnswer((_) async {});
    when(() => analytics.logVoicePlaybackPaused()).thenAnswer((_) async {});
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
    AnalyticsService? analyticsService,
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
        analytics: analyticsService,
      ),
    );
    await tester.pump();
  }

  testWidgets('play and pause log Muse analytics', (tester) async {
    final bytes = Uint8List.fromList([1, 2, 3]);
    await pumpPlayer(
      tester,
      loadBytes: (_) async => bytes,
      analyticsService: analytics,
    );

    await tester.tap(find.bySemanticsLabel(l10n.chatVoicePlayLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
    verify(() => analytics.logVoicePlaybackStarted()).called(1);

    await tester.tap(find.bySemanticsLabel(l10n.chatVoicePauseLabel));
    await tester.pump();
    verify(() => analytics.logVoicePlaybackPaused()).called(1);
  });

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
    expect(player.playBytesCalls, hasLength(1));
    expect(player.resumeCount, 1);
  });

  testWidgets('pause then resume keeps position without a second load', (
    tester,
  ) async {
    final bytes = Uint8List.fromList([9, 9, 9]);
    await pumpPlayer(tester, loadBytes: (_) async => bytes);

    await tester.tap(find.bySemanticsLabel(l10n.chatVoicePlayLabel));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel(l10n.chatVoicePauseLabel));
    await tester.pump();
    player.seekTo(const Duration(seconds: 3));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel(l10n.chatVoicePlayLabel));
    await tester.pump();

    expect(player.playBytesCalls, hasLength(1));
    expect(player.resumeCount, 1);
    expect(player.position, const Duration(seconds: 3));
  });

  testWidgets(
    'after the preview takes the player, bubble play reloads its bytes',
    (tester) async {
      final bubbleBytes = Uint8List.fromList([1, 2, 3]);
      await pumpPlayer(tester, loadBytes: (_) async => bubbleBytes);

      await tester.tap(find.bySemanticsLabel(l10n.chatVoicePlayLabel));
      await tester.pump();
      await tester.tap(find.bySemanticsLabel(l10n.chatVoicePauseLabel));
      await tester.pump();
      expect(player.playBytesCalls, hasLength(1));
      expect(player.resumeCount, 0);

      await player.playBytes(
        Uint8List.fromList([9, 9]),
        id: 'composer-preview',
      );
      await player.pause();

      await tester.tap(find.bySemanticsLabel(l10n.chatVoicePlayLabel));
      await tester.pump();

      // Bubble → preview → bubble reload (failed resume does not count).
      expect(player.resumeCount, 0);
      expect(player.playBytesCalls, hasLength(3));
      expect(player.playBytesCalls.last, same(bubbleBytes));
      expect(player.playedIds.last, message.uid);
    },
  );

  testWidgets(
    'after an older message leaves the list, play uses the survivor bytes',
    (tester) async {
      tester.view.physicalSize = const Size(1170, 2000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      const older = MessageModel(
        uid: 'voice-old',
        kind: 'Voice',
        voiceDurationMs: 1000,
        voicePeaks: [10, 20],
      );
      const survivor = MessageModel(
        uid: 'voice-new',
        kind: 'Voice',
        voiceDurationMs: 2000,
        voicePeaks: [80, 90],
      );
      final olderBytes = Uint8List.fromList([1, 1, 1]);
      final survivorBytes = Uint8List.fromList([2, 2, 2]);

      Future<Uint8List> load(MessageModel m) async =>
          m.uid == older.uid ? olderBytes : survivorBytes;

      await tester.pumpApp(
        VoiceNotePlayer(
          key: const ValueKey('voice-old'),
          message: older,
          foreground: const Color(0xFF111111),
          loadBytes: load,
          player: player,
        ),
      );
      await tester.pump();
      await tester.tap(find.bySemanticsLabel(l10n.chatVoicePlayLabel));
      await tester.pump();
      expect(player.playBytesCalls.last, same(olderBytes));

      // Same State key path as a list rebuild that reuses the element with a
      // new message: update the widget in place with the survivor.
      await tester.pumpApp(
        VoiceNotePlayer(
          key: const ValueKey('voice-old'),
          message: survivor,
          foreground: const Color(0xFF111111),
          loadBytes: load,
          player: player,
        ),
      );
      await tester.pump();
      await tester.tap(find.bySemanticsLabel(l10n.chatVoicePlayLabel));
      await tester.pump();
      expect(player.playBytesCalls.last, same(survivorBytes));
      expect(player.playedIds.last, survivor.uid);
    },
  );
}
