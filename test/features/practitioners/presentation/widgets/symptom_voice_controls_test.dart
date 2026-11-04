import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/services/audio_service_contract.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/practitioners/presentation/widgets/symptom_voice_controls.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../../helpers/helpers.dart';

class _MockAppointmentsBloc
    extends MockBloc<AppointmentsEvent, AppointmentsState>
    implements AppointmentsBloc {}

void main() {
  late FakeAudioRecorderService recorder;
  late FakeRecordingCueService cues;
  late _MockAppointmentsBloc appointments;
  late TextEditingController symptoms;
  final l10n = lookupAppLocalizations(const Locale('en'));

  setUp(() {
    SharedPreferences.setMockInitialValues({
      SymptomVoiceControls.consentKey: true,
    });
    recorder = FakeAudioRecorderService(recorded: fakeRecordedAudio());
    cues = FakeRecordingCueService();
    appointments = _MockAppointmentsBloc();
    whenListen(
      appointments,
      const Stream<AppointmentsState>.empty(),
      initialState: const AppointmentsInitial(),
    );
    symptoms = TextEditingController();
  });

  setUpAll(() {
    registerFallbackValue(
      SymptomsTranscribeRequested(uid: 'p1', audio: fakeRecordedAudio()),
    );
  });

  tearDown(() {
    symptoms.dispose();
  });

  Future<void> pumpControls(
    WidgetTester tester, {
    bool offline = false,
    bool voiceInputEnabled = true,
    Locale locale = const Locale('en'),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = const Size(1170, 2000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpApp(
      BlocProvider<AppointmentsBloc>.value(
        value: appointments,
        child: SymptomVoiceControls(
          patientUid: 'p1',
          symptoms: symptoms,
          recorder: recorder,
          cues: cues,
          offline: offline,
          voiceInputEnabled: () => voiceInputEnabled,
          preferences: SharedPreferences.getInstance,
          onTranscriptionUid: (_) {},
          showAiNotice: (_) {},
        ),
      ),
      locale: locale,
    );
    await tester.pump();
  }

  testWidgets('unsupported shows the plain line and no mic', (tester) async {
    recorder.supported = false;
    await pumpControls(tester);
    expect(find.text(l10n.symptomVoiceUnsupported), findsOneWidget);
    expect(find.byType(CircleIconButton), findsNothing);
    expect(cues.calls, isEmpty);
  });

  testWidgets('client flag off hides mic before any recording', (tester) async {
    await pumpControls(tester, voiceInputEnabled: false);
    expect(find.text(l10n.symptomVoiceUnavailable), findsOneWidget);
    expect(find.bySemanticsLabel(l10n.symptomVoiceRecordLabel), findsNothing);
    expect(find.text(l10n.symptomVoiceTranscribeLabel), findsNothing);
  });

  testWidgets(
    'voiceUnavailable replaces buttons with the line and drops the clip',
    (tester) async {
      whenListen(
        appointments,
        Stream.fromIterable([
          const SymptomsTranscribeFailure(error: AppError.voiceUnavailable),
        ]),
        initialState: const AppointmentsInitial(),
      );
      await tester.pumpApp(
        BlocProvider<AppointmentsBloc>.value(
          value: appointments,
          child: SymptomVoiceControls(
            patientUid: 'p1',
            symptoms: symptoms,
            recorder: recorder,
            cues: cues,
            voiceInputEnabled: () => true,
            preferences: SharedPreferences.getInstance,
            initialClip: fakeRecordedAudio(),
            onTranscriptionUid: (_) {},
            showAiNotice: (_) {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text(l10n.symptomVoiceUnavailable), findsOneWidget);
      expect(find.bySemanticsLabel(l10n.symptomVoiceRecordLabel), findsNothing);
      expect(find.text(l10n.symptomVoiceTranscribeLabel), findsNothing);
      expect(find.text(l10n.symptomVoiceFailed), findsNothing);
    },
  );

  testWidgets('offline failure keeps the record and transcribe buttons', (
    tester,
  ) async {
    whenListen(
      appointments,
      Stream.fromIterable([
        const SymptomsTranscribeFailure(error: AppError.noInternet),
      ]),
      initialState: const AppointmentsInitial(),
    );
    await tester.pumpApp(
      BlocProvider<AppointmentsBloc>.value(
        value: appointments,
        child: SymptomVoiceControls(
          patientUid: 'p1',
          symptoms: symptoms,
          recorder: recorder,
          cues: cues,
          voiceInputEnabled: () => true,
          preferences: SharedPreferences.getInstance,
          initialClip: fakeRecordedAudio(),
          onTranscriptionUid: (_) {},
          showAiNotice: (_) {},
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text(l10n.symptomVoiceOffline), findsOneWidget);
    expect(find.bySemanticsLabel(l10n.symptomVoiceRecordLabel), findsOneWidget);
    expect(find.text(l10n.symptomVoiceTranscribeLabel), findsOneWidget);
  });

  testWidgets('unavailable still leaves typing working', (tester) async {
    await pumpControls(tester, voiceInputEnabled: false);
    symptoms.text = 'Typed while voice is off';
    expect(symptoms.text, 'Typed while voice is off');
    expect(find.text(l10n.symptomVoiceUnavailable), findsOneWidget);
  });

  testWidgets('started completes before the recorder opens', (tester) async {
    cues.startedDelay = const Duration(milliseconds: 40);
    await pumpControls(tester);
    await tester.tap(find.bySemanticsLabel(l10n.symptomVoiceRecordLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));
    expect(cues.calls, isEmpty);
    expect(recorder.startCount, 0);
    await tester.pump(const Duration(milliseconds: 50));
    expect(cues.calls, ['started']);
    expect(recorder.startCount, 1);
  });

  testWidgets('finished runs after stop returns', (tester) async {
    await pumpControls(tester);
    await tester.tap(find.bySemanticsLabel(l10n.symptomVoiceRecordLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
    await tester.tap(find.bySemanticsLabel(l10n.symptomVoiceStopLabel));
    await tester.pump();
    expect(recorder.stopCount, 1);
    expect(cues.calls, ['started', 'finished']);
  });

  testWidgets('transcribe fires the bloc event for a finished clip', (
    tester,
  ) async {
    await tester.pumpApp(
      BlocProvider<AppointmentsBloc>.value(
        value: appointments,
        child: SymptomVoiceControls(
          patientUid: 'p1',
          symptoms: symptoms,
          recorder: recorder,
          cues: cues,
          voiceInputEnabled: () => true,
          preferences: SharedPreferences.getInstance,
          initialClip: fakeRecordedAudio(),
          onTranscriptionUid: (_) {},
          showAiNotice: (_) {},
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text(l10n.symptomVoiceTranscribeLabel));
    await tester.pump();
    verify(
      () => appointments.add(any(that: isA<SymptomsTranscribeRequested>())),
    ).called(1);
  });

  testWidgets('mic starts the fake recorder as WAV 16 kHz', (tester) async {
    await pumpControls(tester);
    expect(find.text(l10n.symptomVoiceEnglishOnly), findsOneWidget);
    await tester.tap(find.bySemanticsLabel(l10n.symptomVoiceRecordLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(recorder.startCount, 1);
    expect(recorder.lastFormat, AudioFormat.wav16k);
    expect(recorder.isRecording, isTrue);
    await tester.tap(find.bySemanticsLabel(l10n.symptomVoiceStopLabel));
    await tester.pump();
    await tester.tap(find.text(l10n.symptomVoiceTranscribeLabel));
    await tester.pump();
    final captured = verify(
      () => appointments.add(captureAny()),
    ).captured.single;
    expect(captured, isA<SymptomsTranscribeRequested>());
    expect(
      (captured as SymptomsTranscribeRequested).audio.contentType,
      'audio/wav',
    );
  });

  testWidgets('English-only line shows in sw', (tester) async {
    final sw = lookupAppLocalizations(const Locale('sw'));
    await pumpControls(tester, locale: const Locale('sw'));
    expect(find.text(sw.symptomVoiceEnglishOnly), findsOneWidget);
    expect(sw.symptomVoiceEnglishOnly, isNot(contains('Swahili recognition')));
  });

  testWidgets('success fills the field and shows the AI notice path', (
    tester,
  ) async {
    String? uid;
    var notice = false;
    whenListen(
      appointments,
      Stream.fromIterable([
        const SymptomsTranscribeSuccess(
          transcript: 'Headache',
          transcriptionUid: 't9',
          detectedLanguage: 'en',
        ),
      ]),
      initialState: const AppointmentsInitial(),
    );
    await tester.pumpApp(
      BlocProvider<AppointmentsBloc>.value(
        value: appointments,
        child: SymptomVoiceControls(
          patientUid: 'p1',
          symptoms: symptoms,
          recorder: recorder,
          cues: cues,
          voiceInputEnabled: () => true,
          preferences: SharedPreferences.getInstance,
          onTranscriptionUid: (value) => uid = value,
          showAiNotice: (value) => notice = value,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(symptoms.text, 'Headache');
    expect(uid, 't9');
    expect(notice, isTrue);
  });

  testWidgets('typed text plus a transcription keeps the typed text', (
    tester,
  ) async {
    symptoms.text = 'Fever for two days';
    whenListen(
      appointments,
      Stream.fromIterable([
        const SymptomsTranscribeSuccess(
          transcript: 'Also a dry cough',
          transcriptionUid: 't2',
          detectedLanguage: 'en',
        ),
      ]),
      initialState: const AppointmentsInitial(),
    );
    await tester.pumpApp(
      BlocProvider<AppointmentsBloc>.value(
        value: appointments,
        child: SymptomVoiceControls(
          patientUid: 'p1',
          symptoms: symptoms,
          recorder: recorder,
          cues: cues,
          voiceInputEnabled: () => true,
          preferences: SharedPreferences.getInstance,
          onTranscriptionUid: (_) {},
          showAiNotice: (_) {},
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(symptoms.text, contains('Fever for two days'));
    expect(symptoms.text, contains('Also a dry cough'));
  });

  testWidgets('a 600-character transcript is cut at the field limit', (
    tester,
  ) async {
    final long = 'a' * 600;
    whenListen(
      appointments,
      Stream.fromIterable([
        SymptomsTranscribeSuccess(
          transcript: long,
          transcriptionUid: 't3',
          detectedLanguage: 'en',
        ),
      ]),
      initialState: const AppointmentsInitial(),
    );
    await tester.pumpApp(
      BlocProvider<AppointmentsBloc>.value(
        value: appointments,
        child: SymptomVoiceControls(
          patientUid: 'p1',
          symptoms: symptoms,
          recorder: recorder,
          cues: cues,
          voiceInputEnabled: () => true,
          preferences: SharedPreferences.getInstance,
          onTranscriptionUid: (_) {},
          showAiNotice: (_) {},
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(symptoms.text.length, SymptomVoiceControls.symptomsMaxLength);
    expect(
      find.text(l10n.pasteCutAtLimit(SymptomVoiceControls.symptomsMaxLength)),
      findsOneWidget,
    );
  });

  testWidgets('tick and tap at the same second keep the clip', (tester) async {
    recorder.stopDelay = const Duration(milliseconds: 100);
    await pumpControls(tester);
    await tester.tap(find.bySemanticsLabel(l10n.symptomVoiceRecordLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(recorder.startCount, 1);
    // First stop stays open; a second stop races it (cap timer or double tap).
    await tester.tap(find.bySemanticsLabel(l10n.symptomVoiceStopLabel));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel(l10n.symptomVoiceStopLabel));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump();
    expect(find.text(l10n.symptomVoiceTranscribeLabel), findsOneWidget);
    expect(find.text(l10n.symptomVoiceFailed), findsNothing);
    await tester.tap(find.text(l10n.symptomVoiceTranscribeLabel));
    await tester.pump();
    verify(
      () => appointments.add(any(that: isA<SymptomsTranscribeRequested>())),
    ).called(1);
  });

  testWidgets('a failed start is not reported as permission denied', (
    tester,
  ) async {
    recorder.startError = StateError('device busy');
    await pumpControls(tester);
    await tester.tap(find.bySemanticsLabel(l10n.symptomVoiceRecordLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text(l10n.symptomVoicePermissionDenied), findsNothing);
    expect(find.text(l10n.symptomVoiceStartFailed), findsOneWidget);
  });

  testWidgets('1.0x and 2.0x in en and sw without overflow', (tester) async {
    for (final locale in const [Locale('en'), Locale('sw')]) {
      for (final scale in [1.0, 2.0]) {
        await pumpControls(tester, locale: locale, textScale: scale);
        expect(tester.takeException(), isNull);
      }
    }
  });
}
