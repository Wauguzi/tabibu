import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  late _MockAppointmentsBloc appointments;
  late TextEditingController symptoms;
  final l10n = lookupAppLocalizations(const Locale('en'));

  setUp(() {
    SharedPreferences.setMockInitialValues({
      SymptomVoiceControls.consentKey: true,
    });
    recorder = FakeAudioRecorderService(recorded: fakeRecordedAudio());
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
          offline: offline,
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

  testWidgets('mic starts the fake recorder', (tester) async {
    await pumpControls(tester);
    await tester.tap(find.bySemanticsLabel(l10n.symptomVoiceRecordLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(recorder.startCount, 1);
    expect(recorder.isRecording, isTrue);
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

  testWidgets('1.0x and 2.0x in en and sw without overflow', (tester) async {
    for (final locale in const [Locale('en'), Locale('sw')]) {
      for (final scale in [1.0, 2.0]) {
        await pumpControls(tester, locale: locale, textScale: scale);
        expect(tester.takeException(), isNull);
      }
    }
  });
}
