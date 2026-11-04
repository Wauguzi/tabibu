import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/services/analytics_service.dart';
import 'package:tabibu/core/services/internet_service.dart';
import 'package:tabibu/features/conversations/blocs/mdt_bloc/mdt_bloc.dart';
import 'package:tabibu/features/conversations/blocs/mdt_bloc/mdt_event.dart';
import 'package:tabibu/features/conversations/blocs/mdt_bloc/mdt_state.dart';
import 'package:tabibu/features/conversations/data/cache/conversation_cache_helper.dart';
import 'package:tabibu/features/conversations/data/datasources/conversation_firebase.dart';
import 'package:tabibu/features/conversations/data/models/case_summary_model.dart';
import 'package:tabibu/features/conversations/data/models/conversation_member_model.dart';
import 'package:tabibu/features/conversations/data/models/conversation_model.dart';
import 'package:tabibu/features/conversations/data/models/message_model.dart';
import 'package:tabibu/features/conversations/data/models/message_preview_model.dart';

class _MockCache extends Mock implements ConversationCacheHelper {}

class _MockRemote extends Mock implements ConversationFirebase {}

class _MockInternet extends Mock implements InternetService {}

class _MockAnalytics extends Mock implements AnalyticsService {}

void main() {
  late _MockCache cache;
  late _MockRemote remote;
  late _MockInternet internet;
  late _MockAnalytics analytics;

  MdtBloc build() => MdtBloc(
    cache: cache,
    remote: remote,
    internet: internet,
    analytics: analytics,
    newConversationUid: () => 'mdt-fixed',
  );

  // `reportStatus` defaults to Pending: the unsigned case.
  const pendingSummary = CaseSummaryModel(caseRef: 'C-1', ageBand: '30-39');

  const signedSummary = CaseSummaryModel(
    caseRef: 'C-1',
    reportStatus: 'Signed',
    signedDiagnosisExcerpt: 'Benign',
    signedByName: 'Dr Path',
  );

  ConversationModel consult({
    required String myStatus,
    CaseSummaryModel summary = pendingSummary,
    String uid = 'mdt-1',
    String type = 'GroupConsult',
  }) => ConversationModel(
    uid: uid,
    type: type,
    specialty: 'Haematology',
    description: 'Second opinion',
    participantUids: const ['me', 'lead'],
    members: {
      'lead': const ConversationMemberModel(uid: 'lead', status: 'Accepted'),
      'me': ConversationMemberModel(uid: 'me', status: myStatus),
    },
    lastMessage: const MessagePreviewModel(text: 'secret'),
    caseSummary: summary,
  );

  const message = MessageModel(
    uid: 'm1',
    conversationUid: 'mdt-1',
    senderUid: 'lead',
    text: 'Please review',
  );

  setUp(() {
    cache = _MockCache();
    remote = _MockRemote();
    internet = _MockInternet();
    analytics = _MockAnalytics();
    when(() => analytics.logMdtOpened()).thenAnswer((_) async {});
    when(
      () => analytics.logMdtInvited(count: any(named: 'count')),
    ).thenAnswer((_) async {});
    when(
      () => analytics.logMdtResponded(accepted: any(named: 'accepted')),
    ).thenAnswer((_) async {});
    when(() => analytics.logMdtLeft()).thenAnswer((_) async {});
    when(() => analytics.logMdtMemberRemoved()).thenAnswer((_) async {});
    when(() => analytics.logMdtMessageSent()).thenAnswer((_) async {});
    when(() => internet.check()).thenAnswer((_) async => true);
    when(() => cache.syncConversations(any())).thenAnswer((_) async => []);
    when(
      () => cache.getConversations(any(), type: any(named: 'type')),
    ).thenAnswer((_) async => []);
    when(() => cache.syncMessages(any(), any())).thenAnswer((_) async => []);
    when(() => cache.getMessages(any(), any())).thenAnswer((_) async => []);
  });

  group('MdtBloc', () {
    test('starts empty', () {
      expect(build().state, const MdtInitial());
    });

    blocTest<MdtBloc, MdtState>(
      'lists group consults only and separates my invites, withholding the '
      'summary and last message from anything I have not accepted',
      build: build,
      setUp: () {
        when(() => cache.syncConversations('me')).thenAnswer(
          (_) async => [
            consult(myStatus: 'Accepted'),
            consult(myStatus: 'Invited', uid: 'mdt-2'),
            consult(myStatus: 'Accepted', uid: 'dm-1', type: 'Direct'),
          ],
        );
      },
      act: (bloc) => bloc.add(const MdtRequested(uid: 'me', role: .doctor)),
      verify: (bloc) {
        final state = bloc.state;
        expect(state, isA<MdtLoadSuccess>());
        expect(state.conversations.map((c) => c.uid), ['mdt-1', 'mdt-2']);
        expect(state.invites.map((c) => c.uid), ['mdt-2']);
        expect(state.conversations.first.caseSummary, pendingSummary);
        expect(state.invites.single.caseSummary, const CaseSummaryModel());
        expect(state.invites.single.lastMessage, const MessagePreviewModel());
        expect(state.invites.single.specialty, 'Haematology');
      },
    );

    blocTest<MdtBloc, MdtState>(
      'refresh falls back to the cache offline and says so',
      build: build,
      setUp: () {
        when(
          () => cache.syncConversations('me'),
        ).thenThrow(AppError.noInternet);
        when(
          () =>
              cache.getConversations('me', type: ConversationType.groupConsult),
        ).thenAnswer((_) async => [consult(myStatus: 'Accepted')]);
      },
      act: (bloc) => bloc.add(const MdtRefreshed(uid: 'me', role: .doctor)),
      verify: (bloc) {
        expect(bloc.state, isA<MdtLoadSuccess>());
        expect(bloc.state.offline, isTrue);
        expect(bloc.state.conversations, hasLength(1));
      },
    );

    group('opening a consult', () {
      blocTest<MdtBloc, MdtState>(
        'an invitee sees the invite only: no messages, no case summary',
        build: build,
        setUp: () {
          when(() => cache.getConversation('me', 'mdt-1')).thenAnswer(
            (_) async => consult(myStatus: 'Invited', summary: signedSummary),
          );
        },
        act: (bloc) =>
            bloc.add(const MdtOpened(uid: 'me', conversationUid: 'mdt-1')),
        verify: (bloc) {
          final state = bloc.state;
          expect(state, isA<MdtLoadSuccess>());
          expect(state.inviteOnly, isTrue);
          expect(state.messages, isEmpty);
          expect(state.active.uid, 'mdt-1');
          expect(state.active.specialty, 'Haematology');
          expect(state.active.caseSummary, const CaseSummaryModel());
          expect(state.active.lastMessage, const MessagePreviewModel());
          expect(state.reportInProgress, isFalse);
          verifyNever(() => cache.syncMessages(any(), any()));
          verifyNever(() => cache.getMessages(any(), any()));
        },
      );

      blocTest<MdtBloc, MdtState>(
        'an accepted member sees messages and the summary; an unsigned '
        'report surfaces as in progress with no draft fields',
        build: build,
        setUp: () {
          when(
            () => cache.getConversation('me', 'mdt-1'),
          ).thenAnswer((_) async => consult(myStatus: 'Accepted'));
          when(
            () => cache.syncMessages('me', 'mdt-1'),
          ).thenAnswer((_) async => [message]);
        },
        act: (bloc) =>
            bloc.add(const MdtOpened(uid: 'me', conversationUid: 'mdt-1')),
        verify: (bloc) {
          final state = bloc.state;
          expect(state.inviteOnly, isFalse);
          expect(state.messages, [message]);
          expect(state.active.caseSummary, pendingSummary);
          expect(state.reportInProgress, isTrue);
          final summary = state.active.caseSummary;
          expect(summary.signedDiagnosisExcerpt, isEmpty);
          expect(summary.signedByName, isEmpty);
          expect(summary.signedAt, isEmpty);
        },
      );

      blocTest<MdtBloc, MdtState>(
        'a signed report is not in progress',
        build: build,
        setUp: () {
          when(() => cache.getConversation('me', 'mdt-1')).thenAnswer(
            (_) async => consult(myStatus: 'Accepted', summary: signedSummary),
          );
        },
        act: (bloc) =>
            bloc.add(const MdtOpened(uid: 'me', conversationUid: 'mdt-1')),
        verify: (bloc) {
          expect(bloc.state.reportInProgress, isFalse);
          expect(bloc.state.active.caseSummary, signedSummary);
        },
      );

      blocTest<MdtBloc, MdtState>(
        'reads the cached thread when the cloud cannot be reached',
        build: build,
        setUp: () {
          when(
            () => cache.getConversation('me', 'mdt-1'),
          ).thenAnswer((_) async => consult(myStatus: 'Accepted'));
          when(
            () => cache.syncMessages('me', 'mdt-1'),
          ).thenThrow(AppError.noInternet);
          when(
            () => cache.getMessages('me', 'mdt-1'),
          ).thenAnswer((_) async => [message]);
        },
        act: (bloc) =>
            bloc.add(const MdtOpened(uid: 'me', conversationUid: 'mdt-1')),
        verify: (bloc) {
          expect(bloc.state.messages, [message]);
          expect(bloc.state.offline, isTrue);
        },
      );

      blocTest<MdtBloc, MdtState>(
        'fails with dataNotFound when the consult is not cached or synced',
        build: build,
        setUp: () {
          when(
            () => cache.getConversation('me', 'gone'),
          ).thenAnswer((_) async => ConversationModel.empty());
        },
        act: (bloc) =>
            bloc.add(const MdtOpened(uid: 'me', conversationUid: 'gone')),
        verify: (bloc) {
          expect(bloc.state, isA<MdtLoadFailure>());
          expect((bloc.state as MdtLoadFailure).error, AppError.dataNotFound);
        },
      );
    });

    group('writes without a network', () {
      setUp(() {
        when(() => internet.check()).thenAnswer((_) async => false);
      });

      blocTest<MdtBloc, MdtState>(
        'open fails fast and never calls the server',
        build: build,
        act: (bloc) => bloc.add(
          const MdtOpenRequested(
            uid: 'me',
            caseUid: 'c1',
            specialty: 'Haematology',
            description: 'Second opinion',
            inviteeUids: ['d2'],
          ),
        ),
        expect: () => [
          isA<MdtWriteInProgress>(),
          isA<MdtWriteFailure>().having(
            (s) => s.error,
            'error',
            AppError.noInternet,
          ),
        ],
        verify: (_) {
          verifyNever(
            () => remote.openMdt(
              conversationUid: any(named: 'conversationUid'),
              caseUid: any(named: 'caseUid'),
              specialty: any(named: 'specialty'),
              description: any(named: 'description'),
              inviteeUids: any(named: 'inviteeUids'),
            ),
          );
        },
      );

      blocTest<MdtBloc, MdtState>(
        'invite fails fast and never calls the server',
        build: build,
        act: (bloc) => bloc.add(
          const MdtInviteRequested(
            uid: 'me',
            conversationUid: 'mdt-1',
            inviteeUids: ['d2'],
          ),
        ),
        expect: () => [
          isA<MdtWriteInProgress>(),
          isA<MdtWriteFailure>().having(
            (s) => s.error,
            'error',
            AppError.noInternet,
          ),
        ],
        verify: (_) {
          verifyNever(
            () => remote.inviteToMdt(
              conversationUid: any(named: 'conversationUid'),
              inviteeUids: any(named: 'inviteeUids'),
            ),
          );
        },
      );

      for (final event in <MdtEvent>[
        const MdtRespondRequested(
          uid: 'me',
          conversationUid: 'mdt-1',
          accept: true,
        ),
        const MdtLeaveRequested(uid: 'me', conversationUid: 'mdt-1'),
        const MdtRemoveRequested(
          uid: 'me',
          conversationUid: 'mdt-1',
          memberUid: 'd2',
        ),
      ]) {
        blocTest<MdtBloc, MdtState>(
          '${event.runtimeType} fails with noInternet',
          build: build,
          act: (bloc) => bloc.add(event),
          verify: (bloc) {
            expect(bloc.state, isA<MdtWriteFailure>());
            expect((bloc.state as MdtWriteFailure).error, AppError.noInternet);
          },
        );
      }
    });

    group('writes with a network', () {
      setUp(() {
        when(
          () => cache.syncConversations('me'),
        ).thenAnswer((_) async => [consult(myStatus: 'Accepted')]);
      });

      blocTest<MdtBloc, MdtState>(
        'open sends a fresh conversation uid and reports it',
        build: build,
        setUp: () {
          when(
            () => remote.openMdt(
              conversationUid: any(named: 'conversationUid'),
              caseUid: any(named: 'caseUid'),
              specialty: any(named: 'specialty'),
              description: any(named: 'description'),
              inviteeUids: any(named: 'inviteeUids'),
            ),
          ).thenAnswer((_) async => {});
        },
        act: (bloc) => bloc.add(
          const MdtOpenRequested(
            uid: 'me',
            caseUid: 'c1',
            specialty: 'Haematology',
            description: 'Second opinion',
            inviteeUids: ['d2'],
          ),
        ),
        verify: (bloc) {
          verify(
            () => remote.openMdt(
              conversationUid: 'mdt-fixed',
              caseUid: 'c1',
              specialty: 'Haematology',
              description: 'Second opinion',
              inviteeUids: const ['d2'],
            ),
          ).called(1);
          expect(bloc.state, isA<MdtWriteSuccess>());
          expect(bloc.state.openedConversationUid, 'mdt-fixed');
          expect(bloc.state.conversations, hasLength(1));
        },
      );

      blocTest<MdtBloc, MdtState>(
        'leaving drops the thread and withholds the summary',
        build: build,
        seed: () => MdtLoadSuccess(
          active: consult(myStatus: 'Accepted'),
          messages: const [message],
        ),
        setUp: () {
          when(
            () => remote.leaveMdt(conversationUid: 'mdt-1'),
          ).thenAnswer((_) async => {});
          when(
            () => cache.syncConversations('me'),
          ).thenAnswer((_) async => [consult(myStatus: 'Left')]);
        },
        act: (bloc) => bloc.add(
          const MdtLeaveRequested(uid: 'me', conversationUid: 'mdt-1'),
        ),
        verify: (bloc) {
          expect(bloc.state, isA<MdtWriteSuccess>());
          expect(bloc.state.messages, isEmpty);
          expect(bloc.state.inviteOnly, isTrue);
          expect(bloc.state.active.caseSummary, const CaseSummaryModel());
        },
      );

      blocTest<MdtBloc, MdtState>(
        'a server refusal surfaces as a write failure',
        build: build,
        setUp: () {
          when(
            () => remote.respondToMdtInvite(
              conversationUid: any(named: 'conversationUid'),
              accept: any(named: 'accept'),
            ),
          ).thenThrow(AppError.permissionDenied);
        },
        act: (bloc) => bloc.add(
          const MdtRespondRequested(
            uid: 'me',
            conversationUid: 'mdt-1',
            accept: true,
          ),
        ),
        verify: (bloc) {
          expect(
            (bloc.state as MdtWriteFailure).error,
            AppError.permissionDenied,
          );
        },
      );
    });

    group('sending messages', () {
      blocTest<MdtBloc, MdtState>(
        'queues the text exactly once and shows it, even offline',
        build: build,
        seed: () => MdtLoadSuccess(
          active: consult(myStatus: 'Accepted'),
          messages: const [message],
        ),
        setUp: () {
          when(() => internet.check()).thenAnswer((_) async => false);
          when(
            () => cache.getConversation('me', 'mdt-1'),
          ).thenAnswer((_) async => consult(myStatus: 'Accepted'));
          when(
            () => cache.queueTextMessage(
              conversationUid: any(named: 'conversationUid'),
              senderUid: any(named: 'senderUid'),
              text: any(named: 'text'),
            ),
          ).thenAnswer(
            (_) async => const MessageModel(
              uid: 'm2',
              conversationUid: 'mdt-1',
              senderUid: 'me',
              text: 'On it',
              synced: false,
            ),
          );
        },
        act: (bloc) => bloc.add(
          const MdtMessageSendRequested(
            uid: 'me',
            conversationUid: 'mdt-1',
            text: 'On it',
          ),
        ),
        verify: (bloc) {
          verify(
            () => cache.queueTextMessage(
              conversationUid: 'mdt-1',
              senderUid: 'me',
              text: 'On it',
            ),
          ).called(1);
          expect(bloc.state, isA<MdtWriteSuccess>());
          expect(bloc.state.messages.map((m) => m.uid), ['m2', 'm1']);
        },
      );

      blocTest<MdtBloc, MdtState>(
        'an invitee cannot send',
        build: build,
        setUp: () {
          when(
            () => cache.getConversation('me', 'mdt-1'),
          ).thenAnswer((_) async => consult(myStatus: 'Invited'));
        },
        act: (bloc) => bloc.add(
          const MdtMessageSendRequested(
            uid: 'me',
            conversationUid: 'mdt-1',
            text: 'hello',
          ),
        ),
        verify: (bloc) {
          expect(
            (bloc.state as MdtWriteFailure).error,
            AppError.permissionDenied,
          );
          verifyNever(
            () => cache.queueTextMessage(
              conversationUid: any(named: 'conversationUid'),
              senderUid: any(named: 'senderUid'),
              text: any(named: 'text'),
            ),
          );
        },
      );
    });

    blocTest<MdtBloc, MdtState>(
      'drops its data on reset',
      build: build,
      seed: () => MdtLoadSuccess(
        conversations: [consult(myStatus: 'Accepted')],
        invites: [consult(myStatus: 'Invited', uid: 'mdt-2')],
        active: consult(myStatus: 'Accepted'),
        messages: const [message],
        offline: true,
      ),
      act: (bloc) => bloc.add(const MdtReset()),
      expect: () => [const MdtInitial()],
      verify: (bloc) {
        expect(bloc.state.conversations, isEmpty);
        expect(bloc.state.invites, isEmpty);
        expect(bloc.state.messages, isEmpty);
        expect(bloc.state.active, const ConversationModel());
        expect(bloc.state.reportInProgress, isFalse);
      },
    );
  });
}
