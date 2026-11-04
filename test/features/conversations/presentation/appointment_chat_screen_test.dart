import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/conversations/blocs/chat_bloc/chat_event.dart';
import 'package:tabibu/features/conversations/blocs/chat_bloc/chat_state.dart';
import 'package:tabibu/features/conversations/data/models/conversation_member_model.dart';
import 'package:tabibu/features/conversations/data/models/conversation_model.dart';
import 'package:tabibu/features/conversations/data/models/message_model.dart';
import 'package:tabibu/features/conversations/presentation/appointment_chat_screen.dart';
import 'package:tabibu/features/conversations/presentation/widgets/mdt_composer.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

PractitionerSession _doctorSession({String uid = 'doc'}) {
  final base = RoleSessions.doctor();
  return PractitionerSession(
    doctor: base.doctor.copyWith(uid: uid),
    roles: base.roles,
  );
}

PatientSession _patientSession({String uid = 'me'}) => PatientSession(
  patient: RoleSessions.patient.patient.copyWith(uid: uid),
  roles: RoleSessions.patient.roles,
);

ConversationModel _thread({String status = 'Open'}) => ConversationModel(
  uid: 'appt_a1',
  type: 'Direct',
  status: status,
  linkedResourceType: 'Appointment',
  linkedResourceUid: 'a1',
  participantUids: const ['me', 'doc'],
  members: const {
    'me': ConversationMemberModel(
      uid: 'me',
      firstName: 'Amina',
      lastName: 'Wambui',
      status: 'Accepted',
    ),
    'doc': ConversationMemberModel(
      uid: 'doc',
      title: 'Dr.',
      firstName: 'Wanjiru',
      lastName: 'Kamau',
      status: 'Accepted',
    ),
  },
);

const _history = MessageModel(
  uid: 'm1',
  conversationUid: 'appt_a1',
  senderUid: 'doc',
  text: 'How are you feeling?',
);

AppointmentModel _appointment() => AppointmentModel(
  uid: 'a1',
  status: 'Accepted',
  patientUid: 'me',
  patientName: 'Amina Wambui',
  doctorUid: 'doc',
  doctorName: 'Dr. Wanjiru Kamau',
  scheduledStart: DateTime.now().toUtc().toIso8601String(),
);

void main() {
  late FeatureBlocs blocs;
  late MockAuthBloc authBloc;
  final l10n = lookupAppLocalizations(const Locale('en'));

  setUpAll(() {
    registerFallbackValue(const ChatReset());
  });

  setUp(() {
    blocs = FeatureBlocs();
    authBloc = MockAuthBloc();
    when(
      () => authBloc.state,
    ).thenReturn(SignInSuccess(session: _patientSession()));
    when(
      () => blocs.appointments.state,
    ).thenReturn(AppointmentsLoadSuccess(appointments: [_appointment()]));
  });

  Future<void> pumpChat(
    WidgetTester tester, {
    required ChatState state,
    Role role = .patient,
    ThemeMode themeMode = .light,
    Locale? locale,
    double textScale = 1,
  }) async {
    when(() => blocs.chat.state).thenReturn(state);
    whenListen(
      blocs.chat,
      const Stream<ChatState>.empty(),
      initialState: state,
    );
    if (role != .patient) {
      when(
        () => authBloc.state,
      ).thenReturn(SignInSuccess(session: _doctorSession()));
    }
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpApp(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<AppointmentsBloc>.value(value: blocs.appointments),
            ...blocs.providers,
          ],
          child: AppointmentChatScreen(role: role, appointmentUid: 'a1'),
        ),
      ),
      themeMode: themeMode,
      locale: locale,
    );
    await tester.pump();
  }

  group('AppointmentChatScreen', () {
    testWidgets('opens the appointment thread on mount', (tester) async {
      await pumpChat(
        tester,
        state: ChatLoadSuccess(
          conversation: _thread(),
          messages: const [_history],
        ),
      );

      verify(
        () => blocs.chat.add(
          any(
            that: isA<ChatOpened>()
                .having((e) => e.appointmentUid, 'appointment', 'a1')
                .having((e) => e.role, 'role', Role.patient),
          ),
        ),
      ).called(1);
      expect(find.text('How are you feeling?'), findsOneWidget);
      expect(find.text('Dr. Wanjiru Kamau'), findsOneWidget);
      expect(find.byType(MdtComposer), findsOneWidget);
    });

    testWidgets('a closed thread is read-only: no composer, follow-up for '
        'the patient', (tester) async {
      await pumpChat(
        tester,
        state: ChatLoadSuccess(
          conversation: _thread(status: 'Closed'),
          messages: const [_history],
        ),
      );

      expect(find.byType(MdtComposer), findsNothing);
      expect(find.text(l10n.chatBookFollowUp), findsOneWidget);
      expect(find.text(l10n.chatClosesWhen), findsWidgets);
    });

    testWidgets('a doctor on a closed thread sees no follow-up booking', (
      tester,
    ) async {
      await pumpChat(
        tester,
        role: .doctor,
        state: ChatLoadSuccess(
          conversation: _thread(status: 'Closed'),
          messages: const [_history],
        ),
      );

      expect(find.byType(MdtComposer), findsNothing);
      expect(find.text(l10n.chatBookFollowUp), findsNothing);
      expect(find.text('Amina Wambui'), findsOneWidget);
    });

    testWidgets('sending clears into ChatMessageSendRequested once', (
      tester,
    ) async {
      await pumpChat(
        tester,
        state: ChatLoadSuccess(
          conversation: _thread(),
          messages: const [_history],
        ),
      );
      clearInteractions(blocs.chat);

      await tester.enterText(find.byType(TextField), 'Feeling better');
      await tester.pump();
      await tester.tap(
        find.descendant(
          of: find.byType(MdtComposer),
          matching: find.byType(CircleIconButton),
        ),
      );
      await tester.pump();

      verify(
        () => blocs.chat.add(
          any(
            that: isA<ChatMessageSendRequested>()
                .having((e) => e.text, 'text', 'Feeling better')
                .having((e) => e.conversationUid, 'uid', 'appt_a1'),
          ),
        ),
      ).called(1);
    });

    testWidgets('Muse 46: no Last seen line', (tester) async {
      await pumpChat(
        tester,
        state: ChatLoadSuccess(
          conversation: _thread(),
          messages: const [_history],
        ),
      );

      expect(find.textContaining('Last seen'), findsNothing);
      expect(find.textContaining('last seen'), findsNothing);
    });

    testWidgets('dark mode draws the open thread', (tester) async {
      await pumpChat(
        tester,
        themeMode: .dark,
        state: ChatLoadSuccess(
          conversation: _thread(),
          messages: const [_history],
        ),
      );

      expect(find.text('How are you feeling?'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Swahili at 1.3x does not overflow', (tester) async {
      await pumpChat(
        tester,
        locale: const Locale('sw'),
        textScale: 1.3,
        state: ChatLoadSuccess(
          conversation: _thread(),
          messages: const [_history],
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
