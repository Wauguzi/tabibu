import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabibu/features/conversations/presentation/widgets/mdt_composer.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late FakeAudioRecorderService recorder;
  late FakeAudioPlayerService player;
  late FakeRecordingCueService cues;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    recorder = FakeAudioRecorderService(recorded: fakeRecordedAudio());
    player = FakeAudioPlayerService();
    cues = FakeRecordingCueService();
  });

  testWidgets('94: a tap outside the composer box dismisses the keyboard', (
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
    final box = find.byType(TextField);
    await tester.tap(box);
    await tester.pump();
    final node = tester.binding.focusManager.primaryFocus!;
    expect(tester.testTextInput.isVisible, isTrue);

    await tester.tapAt(const Offset(195, 660));
    await tester.pump();
    expect(tester.testTextInput.isVisible, isFalse);
    expect(tester.binding.focusManager.primaryFocus, isNot(node));
  });
}
