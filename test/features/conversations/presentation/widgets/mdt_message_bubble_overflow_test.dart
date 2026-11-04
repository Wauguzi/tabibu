import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabibu/features/conversations/data/models/conversation_member_model.dart';
import 'package:tabibu/features/conversations/data/models/message_model.dart';
import 'package:tabibu/features/conversations/presentation/widgets/mdt_message_bubble.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late FakeAudioPlayerService player;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    player = FakeAudioPlayerService();
  });

  tearDown(() async {
    await player.dispose();
  });

  const voice = MessageModel(
    uid: 'v1',
    kind: 'Voice',
    voiceDurationMs: 61000,
    voicePeaks: [10, 40, 70, 40, 10],
    sentAt: '2026-11-04T10:00:00Z',
  );

  Future<void> pumpBubble(
    WidgetTester tester, {
    required double width,
    double textScale = 1,
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = Size(width * 3, 2000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpApp(
      SizedBox(
        width: width,
        child: MdtMessageBubble(
          message: voice,
          mine: true,
          sender: const ConversationMemberModel(),
          loadVoiceBytes: (_) async => Uint8List.fromList([1, 2, 3]),
          player: player,
        ),
      ),
      locale: locale,
    );
    await tester.pump();
  }

  for (final width in [320.0, 390.0]) {
    for (final scale in [1.0, 2.0]) {
      for (final locale in [const Locale('en'), const Locale('sw')]) {
        testWidgets('voice bubble fits at '
            '${width.toInt()}px ${scale}x ${locale.languageCode}', (
          tester,
        ) async {
          await pumpBubble(
            tester,
            width: width,
            textScale: scale,
            locale: locale,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
