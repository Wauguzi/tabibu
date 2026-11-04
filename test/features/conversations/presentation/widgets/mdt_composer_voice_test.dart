import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabibu/core/services/audio_service_contract.dart';
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
    recorder = FakeAudioRecorderService(recorded: fakeRecordedAudio());
    player = FakeAudioPlayerService();
    cues = FakeRecordingCueService();
  });

  Future<void> pumpComposer(
    WidgetTester tester, {
    Future<bool> Function(RecordedAudio audio)? onVoiceSend,
  }) async {
    tester.view.physicalSize = const Size(1170, 2000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpApp(
      MdtComposer(
        hint: 'Message',
        sendLabel: 'Send',
        onSend: (_) {},
        onVoiceSend: onVoiceSend ?? ((_) async => true),
        recorder: recorder,
        player: player,
        cues: cues,
      ),
    );
    await tester.pump();
  }

  testWidgets('unsupported shows the plain line and no mic', (tester) async {
    recorder.supported = false;
    await pumpComposer(tester);
    expect(find.text(l10n.chatVoiceUnsupported), findsOneWidget);
    expect(find.bySemanticsLabel(l10n.chatVoiceRecordLabel), findsNothing);
    expect(cues.calls, isEmpty);
  });

  testWidgets('started completes before the recorder opens', (tester) async {
    cues.startedDelay = const Duration(milliseconds: 40);
    await pumpComposer(tester);
    await tester.tap(find.bySemanticsLabel(l10n.chatVoiceRecordLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));
    expect(cues.calls, isEmpty);
    expect(recorder.startCount, 0);
    await tester.pump(const Duration(milliseconds: 50));
    expect(cues.calls, ['started']);
    expect(recorder.startCount, 1);
  });

  testWidgets('finished runs after stop returns', (tester) async {
    await pumpComposer(tester);
    await tester.tap(find.bySemanticsLabel(l10n.chatVoiceRecordLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
    await tester.tap(find.bySemanticsLabel(l10n.chatVoiceStopLabel));
    await tester.pump();
    expect(recorder.stopCount, 1);
    expect(cues.calls, ['started', 'finished']);
  });

  testWidgets('mic starts and stop shows preview then send', (tester) async {
    RecordedAudio? sent;
    await pumpComposer(
      tester,
      onVoiceSend: (audio) async {
        sent = audio;
        return true;
      },
    );
    await tester.tap(find.bySemanticsLabel(l10n.chatVoiceRecordLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(recorder.startCount, 1);
    await tester.tap(find.bySemanticsLabel(l10n.chatVoiceStopLabel));
    await tester.pump();
    expect(find.text(l10n.chatVoiceSendLabel), findsOneWidget);
    await tester.tap(find.text(l10n.chatVoiceSendLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(sent, isNotNull);
    expect(find.text(l10n.chatVoiceSendLabel), findsNothing);
  });

  testWidgets('permission denied shows the plain line', (tester) async {
    recorder.permission = MicPermission.denied;
    await pumpComposer(tester);
    await tester.tap(find.bySemanticsLabel(l10n.chatVoiceRecordLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text(l10n.chatVoicePermissionDenied), findsOneWidget);
  });

  testWidgets(
    'permanent denial shows settings from enum state, not string compare',
    (tester) async {
      recorder.permission = MicPermission.permanentlyDenied;
      await pumpComposer(tester);
      await tester.tap(find.bySemanticsLabel(l10n.chatVoiceRecordLabel));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text(l10n.chatVoicePermissionPermanent), findsOneWidget);
      expect(find.text(l10n.chatVoiceOpenSettings), findsOneWidget);
    },
  );

  testWidgets('1.0x and 2.0x in en and sw without overflow', (tester) async {
    for (final locale in const [Locale('en'), Locale('sw')]) {
      for (final scale in [1.0, 2.0]) {
        tester.view.physicalSize = const Size(1170, 2000);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
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
          locale: locale,
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    }
  });
}
