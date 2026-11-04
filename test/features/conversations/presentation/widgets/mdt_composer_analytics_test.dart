import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabibu/core/services/analytics_service.dart';
import 'package:tabibu/features/conversations/presentation/widgets/mdt_composer.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

class _MockAnalytics extends Mock implements AnalyticsService {}

void main() {
  late FakeAudioRecorderService recorder;
  late FakeAudioPlayerService player;
  late FakeRecordingCueService cues;
  late _MockAnalytics analytics;
  final l10n = lookupAppLocalizations(const Locale('en'));

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    recorder = FakeAudioRecorderService(recorded: fakeRecordedAudio());
    player = FakeAudioPlayerService();
    cues = FakeRecordingCueService();
    analytics = _MockAnalytics();
    when(
      () => analytics.logVoiceRecordingStarted(surface: any(named: 'surface')),
    ).thenAnswer((_) async {});
    when(
      () =>
          analytics.logVoiceRecordingDiscarded(surface: any(named: 'surface')),
    ).thenAnswer((_) async {});
    when(() => analytics.logVoicePlaybackStarted()).thenAnswer((_) async {});
    when(() => analytics.logVoicePlaybackPaused()).thenAnswer((_) async {});
  });

  Future<void> pumpComposer(WidgetTester tester) async {
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
        analytics: analytics,
        voiceSurface: 'chat',
      ),
    );
    await tester.pump();
  }

  testWidgets('record start and discard log Muse analytics', (tester) async {
    await pumpComposer(tester);
    await tester.tap(find.bySemanticsLabel(l10n.chatVoiceRecordLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
    verify(() => analytics.logVoiceRecordingStarted(surface: 'chat')).called(1);

    await tester.tap(find.bySemanticsLabel(l10n.chatVoiceStopLabel));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel(l10n.chatVoiceDiscardLabel));
    await tester.pump();
    verify(
      () => analytics.logVoiceRecordingDiscarded(surface: 'chat'),
    ).called(1);
  });

  testWidgets('preview play and pause log Muse analytics', (tester) async {
    await pumpComposer(tester);
    await tester.tap(find.bySemanticsLabel(l10n.chatVoiceRecordLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
    await tester.tap(find.bySemanticsLabel(l10n.chatVoiceStopLabel));
    await tester.pump();

    await tester.tap(find.bySemanticsLabel(l10n.chatVoicePlayLabel));
    await tester.pump();
    verify(() => analytics.logVoicePlaybackStarted()).called(1);

    await tester.tap(find.bySemanticsLabel(l10n.chatVoicePauseLabel));
    await tester.pump();
    verify(() => analytics.logVoicePlaybackPaused()).called(1);
  });
}
