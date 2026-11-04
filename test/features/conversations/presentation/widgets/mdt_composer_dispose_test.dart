import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabibu/features/conversations/presentation/widgets/mdt_composer.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late FakeAudioRecorderService recorder;
  late FakeAudioPlayerService player;
  late FakeRecordingCueService cues;
  final l10n = lookupAppLocalizations(const Locale('en'));

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    recorder = FakeAudioRecorderService(
      recorded: fakeRecordedAudio(),
      startDelay: const Duration(milliseconds: 80),
    );
    player = FakeAudioPlayerService();
    cues = FakeRecordingCueService();
  });

  testWidgets('dispose during a pending start cancels the recorder', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpApp(
      MdtComposer(
        hint: 'Message',
        sendLabel: 'Send',
        onSend: (_) {},
        onVoiceSend: (_) async => true,
        recorder: recorder,
        player: player,
        cues: cues,
      ),
    );
    await tester.pump();
    await tester.tap(find.bySemanticsLabel(l10n.chatVoiceRecordLabel));
    await tester.pump();
    // Start is still in flight (startDelay).
    expect(recorder.isRecording, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(recorder.cancelCount, greaterThan(0));
    expect(recorder.isRecording, isFalse);
  });
}
