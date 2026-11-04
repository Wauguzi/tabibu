import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/services/analytics_service.dart';
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

class _MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late FakeAudioRecorderService recorder;
  late FakeRecordingCueService cues;
  late _MockAppointmentsBloc appointments;
  late _MockAnalyticsService analytics;
  late TextEditingController symptoms;
  final l10n = lookupAppLocalizations(const Locale('en'));

  setUp(() {
    SharedPreferences.setMockInitialValues({
      SymptomVoiceControls.consentKey: true,
    });
    recorder = FakeAudioRecorderService(recorded: fakeRecordedAudio());
    cues = FakeRecordingCueService();
    appointments = _MockAppointmentsBloc();
    analytics = _MockAnalyticsService();
    when(
      () => analytics.logVoiceRecordingStarted(surface: any(named: 'surface')),
    ).thenAnswer((_) async {});
    when(
      () =>
          analytics.logVoiceRecordingDiscarded(surface: any(named: 'surface')),
    ).thenAnswer((_) async {});
    whenListen(
      appointments,
      const Stream<AppointmentsState>.empty(),
      initialState: const AppointmentsInitial(),
    );
    symptoms = TextEditingController();
  });

  setUpAll(() {
    registerFallbackValue(
      SymptomsTranscribeRequested(
        uid: 'p1',
        audio: fakeRecordedAudio(),
        requestId: 'r1',
      ),
    );
  });

  /// The mock bloc only records the event; the id comes back out for the
  /// test to emit the matching result with.
  Future<String> transcribeAndCaptureId(WidgetTester tester) async {
    await tester.tap(find.text(l10n.symptomVoiceTranscribeLabel));
    await tester.pump();
    final event =
        verify(() => appointments.add(captureAny())).captured.last
            as SymptomsTranscribeRequested;
    return event.requestId;
  }

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
          analytics: analytics,
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
      final states = StreamController<AppointmentsState>();
      addTearDown(states.close);
      whenListen(
        appointments,
        states.stream,
        initialState: const AppointmentsInitial(),
      );
      await tester.pumpApp(
        BlocProvider<AppointmentsBloc>.value(
          value: appointments,
          child: SymptomVoiceControls(
            patientUid: 'p1',
            symptoms: symptoms,
            recorder: recorder,
            analytics: analytics,
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
      final requestId = await transcribeAndCaptureId(tester);
      states.add(
        SymptomsTranscribeFailure(
          requestId: requestId,
          error: AppError.voiceUnavailable,
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
    final states = StreamController<AppointmentsState>();
    addTearDown(states.close);
    whenListen(
      appointments,
      states.stream,
      initialState: const AppointmentsInitial(),
    );
    await tester.pumpApp(
      BlocProvider<AppointmentsBloc>.value(
        value: appointments,
        child: SymptomVoiceControls(
          patientUid: 'p1',
          symptoms: symptoms,
          recorder: recorder,
          analytics: analytics,
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
    final requestId = await transcribeAndCaptureId(tester);
    states.add(
      SymptomsTranscribeFailure(
        requestId: requestId,
        error: AppError.noInternet,
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
          analytics: analytics,
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
    final states = StreamController<AppointmentsState>();
    addTearDown(states.close);
    whenListen(
      appointments,
      states.stream,
      initialState: const AppointmentsInitial(),
    );
    await tester.pumpApp(
      BlocProvider<AppointmentsBloc>.value(
        value: appointments,
        child: SymptomVoiceControls(
          patientUid: 'p1',
          symptoms: symptoms,
          recorder: recorder,
          analytics: analytics,
          cues: cues,
          voiceInputEnabled: () => true,
          preferences: SharedPreferences.getInstance,
          initialClip: fakeRecordedAudio(),
          onTranscriptionUid: (value) => uid = value,
          showAiNotice: (value) => notice = value,
        ),
      ),
    );
    await tester.pump();
    final requestId = await transcribeAndCaptureId(tester);
    states.add(
      SymptomsTranscribeSuccess(
        requestId: requestId,
        transcript: 'Headache',
        transcriptionUid: 't9',
        detectedLanguage: 'en',
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
    final states = StreamController<AppointmentsState>();
    addTearDown(states.close);
    whenListen(
      appointments,
      states.stream,
      initialState: const AppointmentsInitial(),
    );
    await tester.pumpApp(
      BlocProvider<AppointmentsBloc>.value(
        value: appointments,
        child: SymptomVoiceControls(
          patientUid: 'p1',
          symptoms: symptoms,
          recorder: recorder,
          analytics: analytics,
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
    final requestId = await transcribeAndCaptureId(tester);
    states.add(
      SymptomsTranscribeSuccess(
        requestId: requestId,
        transcript: 'Also a dry cough',
        transcriptionUid: 't2',
        detectedLanguage: 'en',
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
    final states = StreamController<AppointmentsState>();
    addTearDown(states.close);
    whenListen(
      appointments,
      states.stream,
      initialState: const AppointmentsInitial(),
    );
    await tester.pumpApp(
      BlocProvider<AppointmentsBloc>.value(
        value: appointments,
        child: SymptomVoiceControls(
          patientUid: 'p1',
          symptoms: symptoms,
          recorder: recorder,
          analytics: analytics,
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
    final requestId = await transcribeAndCaptureId(tester);
    states.add(
      SymptomsTranscribeSuccess(
        requestId: requestId,
        transcript: long,
        transcriptionUid: 't3',
        detectedLanguage: 'en',
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

  testWidgets('a started take logs its surface', (tester) async {
    await pumpControls(tester);
    await tester.tap(find.bySemanticsLabel(l10n.symptomVoiceRecordLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    verify(
      () => analytics.logVoiceRecordingStarted(surface: 'symptom'),
    ).called(1);
    verifyNever(
      () =>
          analytics.logVoiceRecordingDiscarded(surface: any(named: 'surface')),
    );
  });

  testWidgets('re-recording a pending take logs its discard', (tester) async {
    await tester.pumpApp(
      BlocProvider<AppointmentsBloc>.value(
        value: appointments,
        child: SymptomVoiceControls(
          patientUid: 'p1',
          symptoms: symptoms,
          recorder: recorder,
          analytics: analytics,
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
    await tester.tap(find.bySemanticsLabel(l10n.symptomVoiceRecordLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    verify(
      () => analytics.logVoiceRecordingDiscarded(surface: 'symptom'),
    ).called(1);
    verify(
      () => analytics.logVoiceRecordingStarted(surface: 'symptom'),
    ).called(1);
  });

  testWidgets('a result fills only the form that issued its request', (
    tester,
  ) async {
    final states = StreamController<AppointmentsState>();
    addTearDown(states.close);
    whenListen(
      appointments,
      states.stream,
      initialState: const AppointmentsInitial(),
    );
    final otherSymptoms = TextEditingController();
    addTearDown(otherSymptoms.dispose);
    Widget form(TextEditingController controller) => SymptomVoiceControls(
      patientUid: 'p1',
      symptoms: controller,
      recorder: recorder,
      analytics: analytics,
      cues: cues,
      voiceInputEnabled: () => true,
      preferences: SharedPreferences.getInstance,
      initialClip: fakeRecordedAudio(),
      onTranscriptionUid: (_) {},
      showAiNotice: (_) {},
    );
    await tester.pumpApp(
      BlocProvider<AppointmentsBloc>.value(
        value: appointments,
        child: Column(children: [form(symptoms), form(otherSymptoms)]),
      ),
    );
    await tester.pump();

    // The first form transcribes; the second never presses.
    await tester.tap(find.text(l10n.symptomVoiceTranscribeLabel).first);
    await tester.pump();
    final request =
        verify(() => appointments.add(captureAny())).captured.single
            as SymptomsTranscribeRequested;

    // A foreign failure touches neither form.
    states.add(
      const SymptomsTranscribeFailure(
        requestId: 'someone-else',
        error: AppError.unknown,
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text(l10n.symptomVoiceFailed), findsNothing);

    // The first form's result fills only its field.
    states.add(
      SymptomsTranscribeSuccess(
        requestId: request.requestId,
        transcript: 'Headache',
        transcriptionUid: 't9',
        detectedLanguage: 'en',
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(symptoms.text, 'Headache');
    expect(otherSymptoms.text, isEmpty);
  });

  testWidgets('a replayed result applies once', (tester) async {
    final states = StreamController<AppointmentsState>();
    addTearDown(states.close);
    whenListen(
      appointments,
      states.stream,
      initialState: const AppointmentsInitial(),
    );
    await tester.pumpApp(
      BlocProvider<AppointmentsBloc>.value(
        value: appointments,
        child: SymptomVoiceControls(
          patientUid: 'p1',
          symptoms: symptoms,
          recorder: recorder,
          analytics: analytics,
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
    final requestId = await transcribeAndCaptureId(tester);
    final result = SymptomsTranscribeSuccess(
      requestId: requestId,
      transcript: 'Headache',
      transcriptionUid: 't9',
      detectedLanguage: 'en',
    );
    states.add(result);
    await tester.pump();
    await tester.pump();
    states.add(result);
    await tester.pump();
    await tester.pump();
    expect(symptoms.text, 'Headache');
  });

  testWidgets('a second tap while one runs sends nothing', (tester) async {
    final states = StreamController<AppointmentsState>();
    addTearDown(states.close);
    whenListen(
      appointments,
      states.stream,
      initialState: const AppointmentsInitial(),
    );
    await tester.pumpApp(
      BlocProvider<AppointmentsBloc>.value(
        value: appointments,
        child: SymptomVoiceControls(
          patientUid: 'p1',
          symptoms: symptoms,
          recorder: recorder,
          analytics: analytics,
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
    // Two taps with no frame between: the sync guard blocks the second.
    await tester.tap(find.text(l10n.symptomVoiceTranscribeLabel));
    await tester.tap(find.text(l10n.symptomVoiceTranscribeLabel));
    await tester.pump();
    // And once rebuilt, the button itself is disabled. By type: while
    // loading, the spinner replaces the label text.
    expect(
      tester.widget<TabibuButton>(find.byType(TabibuButton)).onTap,
      isNull,
    );
    await tester.tap(find.byType(TabibuButton));
    await tester.pump();
    final captured = verify(() => appointments.add(captureAny())).captured;
    expect(captured, hasLength(1));
    final request = captured.single as SymptomsTranscribeRequested;
    states.add(
      SymptomsTranscribeSuccess(
        requestId: request.requestId,
        transcript: 'Headache',
        transcriptionUid: 't9',
        detectedLanguage: 'en',
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(symptoms.text, 'Headache');
  });

  testWidgets('the mic waits while a request runs, then works again', (
    tester,
  ) async {
    CircleIconButton mic() =>
        tester.widget<CircleIconButton>(find.byType(CircleIconButton));
    final states = StreamController<AppointmentsState>();
    addTearDown(states.close);
    whenListen(
      appointments,
      states.stream,
      initialState: const AppointmentsInitial(),
    );
    await tester.pumpApp(
      BlocProvider<AppointmentsBloc>.value(
        value: appointments,
        child: SymptomVoiceControls(
          patientUid: 'p1',
          symptoms: symptoms,
          recorder: recorder,
          analytics: analytics,
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
    expect(mic().onTap, isNotNull);
    final requestId = await transcribeAndCaptureId(tester);
    expect(mic().onTap, isNull);
    states.add(
      SymptomsTranscribeSuccess(
        requestId: requestId,
        transcript: 'Headache',
        transcriptionUid: 't9',
        detectedLanguage: 'en',
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(mic().onTap, isNotNull);
    await tester.tap(find.bySemanticsLabel(l10n.symptomVoiceRecordLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(recorder.startCount, 1);
  });

  testWidgets('tapping the mic during a pending request does nothing', (
    tester,
  ) async {
    final states = StreamController<AppointmentsState>();
    addTearDown(states.close);
    whenListen(
      appointments,
      states.stream,
      initialState: const AppointmentsInitial(),
    );
    await tester.pumpApp(
      BlocProvider<AppointmentsBloc>.value(
        value: appointments,
        child: SymptomVoiceControls(
          patientUid: 'p1',
          symptoms: symptoms,
          recorder: recorder,
          analytics: analytics,
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
    await transcribeAndCaptureId(tester);
    await tester.tap(find.bySemanticsLabel(l10n.symptomVoiceRecordLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(recorder.startCount, 0);
    expect(recorder.isRecording, isFalse);
  });

  testWidgets('a failure releases the button for another try', (tester) async {
    final states = StreamController<AppointmentsState>();
    addTearDown(states.close);
    whenListen(
      appointments,
      states.stream,
      initialState: const AppointmentsInitial(),
    );
    await tester.pumpApp(
      BlocProvider<AppointmentsBloc>.value(
        value: appointments,
        child: SymptomVoiceControls(
          patientUid: 'p1',
          symptoms: symptoms,
          recorder: recorder,
          analytics: analytics,
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
    final firstId = await transcribeAndCaptureId(tester);
    states.add(
      SymptomsTranscribeFailure(requestId: firstId, error: AppError.unknown),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text(l10n.symptomVoiceFailed), findsOneWidget);
    // The retry dispatches: the helper's capture would throw otherwise.
    final secondId = await transcribeAndCaptureId(tester);
    expect(secondId, isNot(firstId));
  });

  testWidgets('a result after dispose is ignored', (tester) async {
    final states = StreamController<AppointmentsState>();
    addTearDown(states.close);
    whenListen(
      appointments,
      states.stream,
      initialState: const AppointmentsInitial(),
    );
    await tester.pumpApp(
      BlocProvider<AppointmentsBloc>.value(
        value: appointments,
        child: SymptomVoiceControls(
          patientUid: 'p1',
          symptoms: symptoms,
          recorder: recorder,
          analytics: analytics,
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
    final requestId = await transcribeAndCaptureId(tester);
    await tester.pumpWidget(const SizedBox());
    states.add(
      SymptomsTranscribeSuccess(
        requestId: requestId,
        transcript: 'Headache',
        transcriptionUid: 't9',
        detectedLanguage: 'en',
      ),
    );
    await tester.pump();
    expect(symptoms.text, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('two running forms are each answered with their own text', (
    tester,
  ) async {
    final states = StreamController<AppointmentsState>();
    addTearDown(states.close);
    whenListen(
      appointments,
      states.stream,
      initialState: const AppointmentsInitial(),
    );
    final otherSymptoms = TextEditingController();
    addTearDown(otherSymptoms.dispose);
    Widget form(TextEditingController controller) => SymptomVoiceControls(
      patientUid: 'p1',
      symptoms: controller,
      recorder: recorder,
      analytics: analytics,
      cues: cues,
      voiceInputEnabled: () => true,
      preferences: SharedPreferences.getInstance,
      initialClip: fakeRecordedAudio(),
      onTranscriptionUid: (_) {},
      showAiNotice: (_) {},
    );
    await tester.pumpApp(
      BlocProvider<AppointmentsBloc>.value(
        value: appointments,
        child: Column(children: [form(symptoms), form(otherSymptoms)]),
      ),
    );
    await tester.pump();

    // Both forms send while the first call still runs.
    await tester.tap(find.text(l10n.symptomVoiceTranscribeLabel).first);
    await tester.pump();
    await tester.tap(find.text(l10n.symptomVoiceTranscribeLabel).last);
    await tester.pump();
    final requests = verify(
      () => appointments.add(captureAny()),
    ).captured.cast<SymptomsTranscribeRequested>();
    final first = requests[0];
    final second = requests[1];

    // Answers arrive in order; each fills only its own field.
    states.add(
      SymptomsTranscribeSuccess(
        requestId: first.requestId,
        transcript: 'Headache',
        transcriptionUid: 't1',
        detectedLanguage: 'en',
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(symptoms.text, 'Headache');
    expect(otherSymptoms.text, isEmpty);
    states.add(
      SymptomsTranscribeSuccess(
        requestId: second.requestId,
        transcript: 'Dry cough',
        transcriptionUid: 't2',
        detectedLanguage: 'en',
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(symptoms.text, 'Headache');
    expect(otherSymptoms.text, 'Dry cough');
  });

  testWidgets('a refresh mid-flight leaves the new form answerable', (
    tester,
  ) async {
    final states = StreamController<AppointmentsState>();
    addTearDown(states.close);
    whenListen(
      appointments,
      states.stream,
      initialState: const AppointmentsInitial(),
    );
    await tester.pumpApp(
      BlocProvider<AppointmentsBloc>.value(
        value: appointments,
        child: SymptomVoiceControls(
          patientUid: 'p1',
          symptoms: symptoms,
          recorder: recorder,
          analytics: analytics,
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
    // Another form's call is in flight, then a refresh replaces the
    // in-progress state before this form transcribes.
    states.add(const SymptomsTranscribeInProgress(requestId: 'someone-else'));
    await tester.pump();
    await tester.pump();
    states.add(const AppointmentsLoadSuccess());
    await tester.pump();
    await tester.pump();
    final requestId = await transcribeAndCaptureId(tester);
    // The first call's answer is not this form's; its own answer lands
    // and the buttons come back.
    states.add(
      const SymptomsTranscribeSuccess(
        requestId: 'someone-else',
        transcript: 'Foreign',
        transcriptionUid: 'tx',
        detectedLanguage: 'en',
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(symptoms.text, isEmpty);
    states.add(
      SymptomsTranscribeSuccess(
        requestId: requestId,
        transcript: 'Headache',
        transcriptionUid: 't9',
        detectedLanguage: 'en',
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(symptoms.text, 'Headache');
    expect(
      tester.widget<CircleIconButton>(find.byType(CircleIconButton)).onTap,
      isNotNull,
    );
  });

  testWidgets("voice buttons follow only the form's own pending id", (
    tester,
  ) async {
    // By type: while loading, the spinner replaces the label text.
    TabibuButton transcribeButton() =>
        tester.widget<TabibuButton>(find.byType(TabibuButton));
    CircleIconButton mic() =>
        tester.widget<CircleIconButton>(find.byType(CircleIconButton));
    final states = StreamController<AppointmentsState>();
    addTearDown(states.close);
    whenListen(
      appointments,
      states.stream,
      initialState: const AppointmentsInitial(),
    );
    await tester.pumpApp(
      BlocProvider<AppointmentsBloc>.value(
        value: appointments,
        child: SymptomVoiceControls(
          patientUid: 'p1',
          symptoms: symptoms,
          recorder: recorder,
          analytics: analytics,
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
    // Another form's in-flight request touches neither button here.
    states.add(const SymptomsTranscribeInProgress(requestId: 'someone-else'));
    await tester.pump();
    await tester.pump();
    expect(mic().onTap, isNotNull);
    expect(transcribeButton().onTap, isNotNull);
    expect(transcribeButton().isLoading, isFalse);
    // This form's own request disables the mic, the button, and spins it.
    await transcribeAndCaptureId(tester);
    expect(mic().onTap, isNull);
    expect(transcribeButton().onTap, isNull);
    expect(transcribeButton().isLoading, isTrue);
  });

  testWidgets('dispose during an unfinished start cancels the recorder', (
    tester,
  ) async {
    recorder.startDelay = const Duration(milliseconds: 100);
    await pumpControls(tester);
    await tester.tap(find.bySemanticsLabel(l10n.symptomVoiceRecordLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));
    expect(recorder.startCount, 0);
    // Leaving while the mic is still opening must close it.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 150));
    expect(recorder.cancelCount, 1);
    expect(recorder.isRecording, isFalse);
  });
}
