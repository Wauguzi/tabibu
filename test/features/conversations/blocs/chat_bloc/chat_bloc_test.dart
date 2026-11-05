import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/services/analytics_service.dart';
import 'package:tabibu/core/services/internet_service.dart';
import 'package:tabibu/features/conversations/blocs/chat_bloc/chat_bloc.dart';
import 'package:tabibu/features/conversations/blocs/chat_bloc/chat_event.dart';
import 'package:tabibu/features/conversations/blocs/chat_bloc/chat_state.dart';
import 'package:tabibu/features/conversations/data/cache/conversation_cache_helper.dart';
import 'package:tabibu/features/conversations/data/datasources/conversation_firebase.dart';
import 'package:tabibu/features/conversations/data/models/conversation_model.dart';
import 'package:tabibu/features/conversations/data/models/message_model.dart';
import 'package:tabibu/features/conversations/data/voice_send_outcome.dart';

class _MockCache extends Mock implements ConversationCacheHelper {}

class _MockRemote extends Mock implements ConversationFirebase {}

class _MockInternet extends Mock implements InternetService {}

class _MockAnalytics extends Mock implements AnalyticsService {}

void main() {
  late _MockCache cache;
  late _MockRemote remote;
  late _MockInternet internet;
  late _MockAnalytics analytics;

  ChatBloc build() => ChatBloc(
    cache: cache,
    remote: remote,
    internet: internet,
    analytics: analytics,
  );

  ConversationModel thread({String status = 'Open'}) => ConversationModel(
    uid: 'appt_a1',
    type: 'Direct',
    status: status,
    linkedResourceType: 'Appointment',
    linkedResourceUid: 'a1',
    participantUids: const ['me', 'doc'],
  );

  const history = MessageModel(
    uid: 'm1',
    conversationUid: 'appt_a1',
    senderUid: 'doc',
    text: 'How are you feeling?',
  );

  const secret = 'my result is 4.2 and my phone is 0700 000 000';

  const queued = MessageModel(
    uid: 'q1',
    conversationUid: 'appt_a1',
    senderUid: 'me',
    text: secret,
    status: 'Pending',
    synced: false,
  );

  const voiceQueued = MessageModel(
    uid: 'v1',
    conversationUid: 'appt_a1',
    senderUid: 'me',
    kind: 'Voice',
    voiceDurationMs: 2500,
    voicePeaks: [10, 40, 70],
    status: 'Pending',
    synced: false,
  );

  const open = ChatOpened(uid: 'me', role: .patient, appointmentUid: 'a1');

  setUpAll(() {
    registerFallbackValue(const ChatReset());
  });

  setUp(() {
    cache = _MockCache();
    remote = _MockRemote();
    internet = _MockInternet();
    analytics = _MockAnalytics();
    when(() => analytics.logChatMessageSent()).thenAnswer((_) async {});
    when(
      () => analytics.logChatVoiceNoteSent(
        durationBucket: any(named: 'durationBucket'),
      ),
    ).thenAnswer((_) async {});
    when(() => analytics.logChatClosed()).thenAnswer((_) async {});
    when(() => internet.check()).thenAnswer((_) async => true);
    when(
      () => remote.openDirectConversation(
        resourceType: any(named: 'resourceType'),
        resourceUid: any(named: 'resourceUid'),
      ),
    ).thenAnswer((_) async => {'conversationUid': 'appt_a1'});
    when(
      () => remote.closeConversation(
        conversationUid: any(named: 'conversationUid'),
      ),
    ).thenAnswer((_) async => {'status': 'Closed'});
    when(() => cache.syncConversations(any())).thenAnswer((_) async => []);
    when(
      () => cache.getForResource(any(), any(), any()),
    ).thenAnswer((_) async => [thread()]);
    when(
      () => cache.getConversation(any(), any()),
    ).thenAnswer((_) async => thread());
    when(
      () => cache.syncMessages(any(), any()),
    ).thenAnswer((_) async => [history]);
    when(
      () => cache.getMessages(any(), any()),
    ).thenAnswer((_) async => [history]);
    when(
      () => cache.queueTextMessage(
        conversationUid: any(named: 'conversationUid'),
        senderUid: any(named: 'senderUid'),
        text: any(named: 'text'),
      ),
    ).thenAnswer((_) async => queued);
    when(
      () => cache.queueVoiceMessage(
        conversationUid: any(named: 'conversationUid'),
        senderUid: any(named: 'senderUid'),
        localPath: any(named: 'localPath'),
        durationMs: any(named: 'durationMs'),
        voicePeaks: any(named: 'voicePeaks'),
        contentType: any(named: 'contentType'),
      ),
    ).thenAnswer((_) async => voiceQueued);
    when(() => cache.replayPendingMessages(any())).thenAnswer((_) async {});
  });

  group('ChatBloc', () {
    test('starts empty and writable', () {
      final state = build().state;
      expect(state, const ChatInitial());
      expect(state.readOnly, isFalse);
    });

    group('opening', () {
      blocTest<ChatBloc, ChatState>(
        'opens the appointment thread online, then syncs its messages',
        build: build,
        act: (bloc) => bloc.add(open),
        expect: () => [
          const ChatLoadInProgress(),
          ChatLoadSuccess(conversation: thread(), messages: const [history]),
        ],
        verify: (bloc) {
          verify(() => cache.replayPendingMessages('me')).called(1);
          verify(
            () => remote.openDirectConversation(
              resourceType: 'Appointment',
              resourceUid: 'a1',
            ),
          ).called(1);
          verify(() => cache.syncMessages('me', 'appt_a1')).called(1);
          expect(bloc.state.readOnly, isFalse);
        },
      );

      blocTest<ChatBloc, ChatState>(
        'opening the same appointment again does not open it again',
        build: build,
        act: (bloc) async {
          bloc.add(open);
          await bloc.stream.firstWhere((s) => s is ChatLoadSuccess);
          bloc.add(open);
        },
        expect: () => [
          const ChatLoadInProgress(),
          ChatLoadSuccess(conversation: thread(), messages: const [history]),
        ],
        verify: (_) {
          verify(
            () => remote.openDirectConversation(
              resourceType: any(named: 'resourceType'),
              resourceUid: any(named: 'resourceUid'),
            ),
          ).called(1);
          verify(() => cache.syncMessages(any(), any())).called(1);
        },
      );

      blocTest<ChatBloc, ChatState>(
        'two opens fired at once still open the appointment once',
        build: build,
        act: (bloc) => bloc
          ..add(open)
          ..add(open),
        expect: () => [
          const ChatLoadInProgress(),
          ChatLoadSuccess(conversation: thread(), messages: const [history]),
        ],
        verify: (_) {
          verify(
            () => remote.openDirectConversation(
              resourceType: any(named: 'resourceType'),
              resourceUid: any(named: 'resourceUid'),
            ),
          ).called(1);
        },
      );

      blocTest<ChatBloc, ChatState>(
        'another appointment is opened in its own right',
        build: build,
        seed: () => ChatLoadSuccess(conversation: thread()),
        setUp: () {
          when(
            () => cache.getForResource('me', 'Appointment', 'a2'),
          ).thenAnswer(
            (_) async => [
              thread().copyWith(uid: 'appt_a2', linkedResourceUid: 'a2'),
            ],
          );
        },
        act: (bloc) => bloc.add(
          const ChatOpened(uid: 'me', role: .patient, appointmentUid: 'a2'),
        ),
        verify: (bloc) {
          verify(
            () => remote.openDirectConversation(
              resourceType: 'Appointment',
              resourceUid: 'a2',
            ),
          ).called(1);
          expect(bloc.state.conversation.uid, 'appt_a2');
        },
      );

      blocTest<ChatBloc, ChatState>(
        'offline it reads the cached thread and never calls the server',
        build: build,
        setUp: () {
          when(() => internet.check()).thenAnswer((_) async => false);
          when(
            () => cache.syncMessages(any(), any()),
          ).thenThrow(AppError.noInternet);
        },
        act: (bloc) => bloc.add(open),
        expect: () => [
          const ChatLoadInProgress(),
          ChatLoadSuccess(
            conversation: thread(),
            messages: const [history],
            offline: true,
          ),
        ],
        verify: (_) {
          verifyNever(
            () => remote.openDirectConversation(
              resourceType: any(named: 'resourceType'),
              resourceUid: any(named: 'resourceUid'),
            ),
          );
        },
      );

      blocTest<ChatBloc, ChatState>(
        'a server that cannot be reached falls back to the cached thread',
        build: build,
        setUp: () {
          when(
            () => remote.openDirectConversation(
              resourceType: any(named: 'resourceType'),
              resourceUid: any(named: 'resourceUid'),
            ),
          ).thenThrow(AppError.serviceUnavailable);
        },
        act: (bloc) => bloc.add(open),
        verify: (bloc) {
          expect(bloc.state, isA<ChatLoadSuccess>());
          expect(bloc.state.offline, isTrue);
          expect(bloc.state.conversation.uid, 'appt_a1');
        },
      );

      blocTest<ChatBloc, ChatState>(
        'offline with nothing cached reports noInternet',
        build: build,
        setUp: () {
          when(() => internet.check()).thenAnswer((_) async => false);
          when(
            () => cache.getForResource(any(), any(), any()),
          ).thenAnswer((_) async => []);
        },
        act: (bloc) => bloc.add(open),
        expect: () => [
          const ChatLoadInProgress(),
          const ChatLoadFailure(error: .noInternet, offline: true),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'a refused open is a failure, and the same appointment can be retried',
        build: build,
        setUp: () {
          when(
            () => remote.openDirectConversation(
              resourceType: any(named: 'resourceType'),
              resourceUid: any(named: 'resourceUid'),
            ),
          ).thenThrow(AppError.permissionDenied);
        },
        act: (bloc) async {
          bloc.add(open);
          await bloc.stream.firstWhere((s) => s is ChatLoadFailure);
          bloc.add(open);
        },
        expect: () => [
          const ChatLoadInProgress(),
          const ChatLoadFailure(error: .permissionDenied),
          const ChatLoadInProgress(),
          const ChatLoadFailure(error: .permissionDenied),
        ],
      );

      blocTest<ChatBloc, ChatState>(
        'a closed thread opens read-only',
        build: build,
        setUp: () {
          when(
            () => cache.getForResource(any(), any(), any()),
          ).thenAnswer((_) async => [thread(status: 'Closed')]);
        },
        act: (bloc) => bloc.add(open),
        verify: (bloc) {
          expect(bloc.state, isA<ChatLoadSuccess>());
          expect(bloc.state.readOnly, isTrue);
        },
      );
    });

    blocTest<ChatBloc, ChatState>(
      'refresh syncs the thread again',
      build: build,
      seed: () => ChatLoadSuccess(conversation: thread()),
      act: (bloc) =>
          bloc.add(const ChatRefreshed(uid: 'me', conversationUid: 'appt_a1')),
      expect: () => [
        ChatLoadInProgress(conversation: thread()),
        ChatLoadSuccess(conversation: thread(), messages: const [history]),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'refresh offline keeps the cached thread and says so',
      build: build,
      seed: () => ChatLoadSuccess(conversation: thread()),
      setUp: () {
        when(
          () => cache.syncConversations(any()),
        ).thenThrow(AppError.noInternet);
        when(
          () => cache.syncMessages(any(), any()),
        ).thenThrow(AppError.noInternet);
      },
      act: (bloc) =>
          bloc.add(const ChatRefreshed(uid: 'me', conversationUid: 'appt_a1')),
      verify: (bloc) {
        expect(bloc.state, isA<ChatLoadSuccess>());
        expect(bloc.state.offline, isTrue);
        expect(bloc.state.messages, const [history]);
      },
    );

    group('sending', () {
      blocTest<ChatBloc, ChatState>(
        'queues the message once, newest first',
        build: build,
        seed: () =>
            ChatLoadSuccess(conversation: thread(), messages: const [history]),
        act: (bloc) => bloc.add(
          const ChatMessageSendRequested(
            uid: 'me',
            conversationUid: 'appt_a1',
            text: secret,
          ),
        ),
        expect: () => [
          ChatWriteSuccess(
            conversation: thread(),
            messages: const [queued, history],
          ),
        ],
        verify: (_) {
          verify(
            () => cache.queueTextMessage(
              conversationUid: 'appt_a1',
              senderUid: 'me',
              text: secret,
            ),
          ).called(1);
        },
      );

      blocTest<ChatBloc, ChatState>(
        'offline it queues once and leaves the send to the replay path',
        build: build,
        seed: () => ChatLoadSuccess(
          conversation: thread(),
          messages: const [history],
          offline: true,
        ),
        setUp: () {
          when(() => internet.check()).thenAnswer((_) async => false);
        },
        act: (bloc) => bloc.add(
          const ChatMessageSendRequested(
            uid: 'me',
            conversationUid: 'appt_a1',
            text: secret,
          ),
        ),
        expect: () => [
          ChatWriteSuccess(
            conversation: thread(),
            messages: const [queued, history],
            offline: true,
          ),
        ],
        verify: (bloc) {
          verify(
            () => cache.queueTextMessage(
              conversationUid: 'appt_a1',
              senderUid: 'me',
              text: secret,
            ),
          ).called(1);
          verifyNever(
            () => remote.createTextMessage(
              conversationUid: any(named: 'conversationUid'),
              messageUid: any(named: 'messageUid'),
              senderUid: any(named: 'senderUid'),
              text: any(named: 'text'),
              sentAt: any(named: 'sentAt'),
            ),
          );
          expect(bloc.state.messages.first.synced, isFalse);
        },
      );

      blocTest<ChatBloc, ChatState>(
        'a closed thread refuses the send with permissionDenied',
        build: build,
        seed: () => ChatLoadSuccess(conversation: thread(status: 'Closed')),
        setUp: () {
          when(
            () => cache.getConversation(any(), any()),
          ).thenAnswer((_) async => thread(status: 'Closed'));
        },
        act: (bloc) => bloc.add(
          const ChatMessageSendRequested(
            uid: 'me',
            conversationUid: 'appt_a1',
            text: secret,
          ),
        ),
        expect: () => [
          ChatWriteFailure(
            error: .permissionDenied,
            conversation: thread(status: 'Closed'),
          ),
        ],
        verify: (bloc) {
          expect(bloc.state.readOnly, isTrue);
          verifyNever(
            () => cache.queueTextMessage(
              conversationUid: any(named: 'conversationUid'),
              senderUid: any(named: 'senderUid'),
              text: any(named: 'text'),
            ),
          );
        },
      );

      blocTest<ChatBloc, ChatState>(
        'a thread the cache knows as closed refuses even a stale open state',
        build: build,
        seed: () => ChatLoadSuccess(conversation: thread()),
        setUp: () {
          when(
            () => cache.getConversation(any(), any()),
          ).thenAnswer((_) async => thread(status: 'Closed'));
        },
        act: (bloc) => bloc.add(
          const ChatMessageSendRequested(
            uid: 'me',
            conversationUid: 'appt_a1',
            text: secret,
          ),
        ),
        verify: (bloc) {
          expect(bloc.state, isA<ChatWriteFailure>());
          verifyNever(
            () => cache.queueTextMessage(
              conversationUid: any(named: 'conversationUid'),
              senderUid: any(named: 'senderUid'),
              text: any(named: 'text'),
            ),
          );
        },
      );

      blocTest<ChatBloc, ChatState>(
        'a thread outside my cache is not found and nothing is queued',
        build: build,
        seed: () => ChatLoadSuccess(conversation: thread()),
        setUp: () {
          when(
            () => cache.getConversation(any(), any()),
          ).thenAnswer((_) async => ConversationModel.empty());
        },
        act: (bloc) => bloc.add(
          const ChatMessageSendRequested(
            uid: 'me',
            conversationUid: 'appt_a1',
            text: secret,
          ),
        ),
        verify: (bloc) {
          expect((bloc.state as ChatWriteFailure).error, AppError.dataNotFound);
          verifyNever(
            () => cache.queueTextMessage(
              conversationUid: any(named: 'conversationUid'),
              senderUid: any(named: 'senderUid'),
              text: any(named: 'text'),
            ),
          );
        },
      );

      blocTest<ChatBloc, ChatState>(
        'voice note queues once with a duration bucket only',
        build: build,
        seed: () =>
            ChatLoadSuccess(conversation: thread(), messages: const [history]),
        act: (bloc) => bloc.add(
          ChatVoiceNoteSendRequested(
            uid: 'me',
            conversationUid: 'appt_a1',
            localPath: '/tmp/v.m4a',
            durationMs: 2500,
            voicePeaks: const [10, 40, 70],
          ),
        ),
        expect: () => [
          ChatWriteSuccess(
            conversation: thread(),
            messages: const [voiceQueued, history],
            offline: true,
          ),
        ],
        verify: (_) {
          verify(
            () => cache.queueVoiceMessage(
              conversationUid: 'appt_a1',
              senderUid: 'me',
              localPath: '/tmp/v.m4a',
              durationMs: 2500,
              voicePeaks: const [10, 40, 70],
            ),
          ).called(1);
          verify(
            () => analytics.logChatVoiceNoteSent(durationBucket: '0_15'),
          ).called(1);
        },
      );

      blocTest<ChatBloc, ChatState>(
        'voice send completes its own result, not any WriteSuccess',
        build: build,
        seed: () =>
            ChatLoadSuccess(conversation: thread(), messages: const [history]),
        act: (bloc) async {
          final event = ChatVoiceNoteSendRequested(
            uid: 'me',
            conversationUid: 'appt_a1',
            localPath: '/tmp/v.m4a',
            durationMs: 2500,
            voicePeaks: const [10, 40, 70],
          );
          bloc.add(event);
          await expectLater(
            event.result.future,
            completion(VoiceSendOutcome.queued),
          );
        },
      );

      blocTest<ChatBloc, ChatState>(
        'sequential voice sends each mint once, in order',
        build: build,
        seed: () =>
            ChatLoadSuccess(conversation: thread(), messages: const [history]),
        act: (bloc) async {
          bloc
            ..add(
              ChatVoiceNoteSendRequested(
                uid: 'me',
                conversationUid: 'appt_a1',
                localPath: '/tmp/v.m4a',
                durationMs: 2500,
                voicePeaks: const [10, 40, 70],
              ),
            )
            ..add(
              ChatVoiceNoteSendRequested(
                uid: 'me',
                conversationUid: 'appt_a1',
                localPath: '/tmp/v2.m4a',
                durationMs: 2500,
                voicePeaks: const [10, 40, 70],
              ),
            );
        },
        verify: (_) {
          verify(
            () => cache.queueVoiceMessage(
              conversationUid: any(named: 'conversationUid'),
              senderUid: any(named: 'senderUid'),
              localPath: any(named: 'localPath'),
              durationMs: any(named: 'durationMs'),
              voicePeaks: any(named: 'voicePeaks'),
              contentType: any(named: 'contentType'),
            ),
          ).called(2);
        },
      );

      blocTest<ChatBloc, ChatState>(
        'a failed voice send leaves the thread unchanged',
        build: build,
        seed: () =>
            ChatLoadSuccess(conversation: thread(), messages: const [history]),
        setUp: () {
          when(
            () => cache.queueVoiceMessage(
              conversationUid: any(named: 'conversationUid'),
              senderUid: any(named: 'senderUid'),
              localPath: any(named: 'localPath'),
              durationMs: any(named: 'durationMs'),
              voicePeaks: any(named: 'voicePeaks'),
              contentType: any(named: 'contentType'),
            ),
          ).thenThrow(AppError.noInternet);
        },
        act: (bloc) async {
          final event = ChatVoiceNoteSendRequested(
            uid: 'me',
            conversationUid: 'appt_a1',
            localPath: '/tmp/v.m4a',
            durationMs: 2500,
            voicePeaks: const [10, 40, 70],
          );
          bloc.add(event);
          await expectLater(
            event.result.future,
            completion(VoiceSendOutcome.refused),
          );
        },
        expect: () => [
          ChatWriteFailure(
            error: .noInternet,
            conversation: thread(),
            messages: const [history],
          ),
        ],
      );
    });

    group('closing', () {
      blocTest<ChatBloc, ChatState>(
        'closes online and the thread turns read-only',
        build: build,
        seed: () =>
            ChatLoadSuccess(conversation: thread(), messages: const [history]),
        act: (bloc) => bloc.add(
          const ChatCloseRequested(uid: 'me', conversationUid: 'appt_a1'),
        ),
        expect: () => [
          ChatWriteInProgress(
            conversation: thread(),
            messages: const [history],
          ),
          ChatWriteSuccess(
            conversation: thread(status: 'Closed'),
            messages: const [history],
          ),
        ],
        verify: (bloc) {
          verify(
            () => remote.closeConversation(conversationUid: 'appt_a1'),
          ).called(1);
          expect(bloc.state.readOnly, isTrue);
        },
      );

      blocTest<ChatBloc, ChatState>(
        'closes even when the re-read afterwards fails',
        build: build,
        seed: () => ChatLoadSuccess(conversation: thread()),
        setUp: () {
          when(
            () => cache.syncConversations(any()),
          ).thenThrow(AppError.unknown);
        },
        act: (bloc) => bloc.add(
          const ChatCloseRequested(uid: 'me', conversationUid: 'appt_a1'),
        ),
        verify: (bloc) {
          expect(bloc.state, isA<ChatWriteSuccess>());
          expect(bloc.state.readOnly, isTrue);
        },
      );

      blocTest<ChatBloc, ChatState>(
        'offline it does not close and the thread stays writable',
        build: build,
        seed: () => ChatLoadSuccess(conversation: thread()),
        setUp: () {
          when(() => internet.check()).thenAnswer((_) async => false);
        },
        act: (bloc) => bloc.add(
          const ChatCloseRequested(uid: 'me', conversationUid: 'appt_a1'),
        ),
        verify: (bloc) {
          expect((bloc.state as ChatWriteFailure).error, AppError.noInternet);
          expect(bloc.state.readOnly, isFalse);
          verifyNever(
            () => remote.closeConversation(
              conversationUid: any(named: 'conversationUid'),
            ),
          );
        },
      );

      blocTest<ChatBloc, ChatState>(
        'a refused close is a failure and the thread stays writable',
        build: build,
        seed: () => ChatLoadSuccess(conversation: thread()),
        setUp: () {
          when(
            () => remote.closeConversation(
              conversationUid: any(named: 'conversationUid'),
            ),
          ).thenThrow(AppError.permissionDenied);
        },
        act: (bloc) => bloc.add(
          const ChatCloseRequested(uid: 'me', conversationUid: 'appt_a1'),
        ),
        verify: (bloc) {
          expect(
            (bloc.state as ChatWriteFailure).error,
            AppError.permissionDenied,
          );
          expect(bloc.state.readOnly, isFalse);
        },
      );
    });

    blocTest<ChatBloc, ChatState>(
      'reset returns to the initial state and drops the thread',
      build: build,
      seed: () => ChatLoadSuccess(
        conversation: thread(status: 'Closed'),
        messages: const [history],
      ),
      act: (bloc) => bloc.add(const ChatReset()),
      expect: () => [const ChatInitial()],
      verify: (bloc) {
        expect(bloc.state.conversation.uid, isEmpty);
        expect(bloc.state.messages, isEmpty);
        expect(bloc.state.readOnly, isFalse);
      },
    );

    group('privacy', () {
      late List<String> logged;
      late DebugPrintCallback originalDebugPrint;

      setUp(() {
        logged = [];
        originalDebugPrint = debugPrint;
        debugPrint = (message, {wrapWidth}) => logged.add(message ?? '');
        Logger.addOutputListener((event) => logged.addAll(event.lines));
      });

      tearDown(() {
        debugPrint = originalDebugPrint;
      });

      test('no log line carries the message text, sent or refused', () async {
        final bloc = build();
        addTearDown(bloc.close);

        await runZoned(
          () async {
            bloc.add(open);
            await bloc.stream.firstWhere((s) => s is ChatLoadSuccess);
            bloc.add(
              const ChatMessageSendRequested(
                uid: 'me',
                conversationUid: 'appt_a1',
                text: secret,
              ),
            );
            await bloc.stream.firstWhere((s) => s is ChatWriteSuccess);

            when(
              () => cache.queueTextMessage(
                conversationUid: any(named: 'conversationUid'),
                senderUid: any(named: 'senderUid'),
                text: any(named: 'text'),
              ),
            ).thenThrow(ArgumentError('Text messages must be 1-2000 chars.'));
            bloc.add(
              const ChatMessageSendRequested(
                uid: 'me',
                conversationUid: 'appt_a1',
                text: secret,
              ),
            );
            await bloc.stream.firstWhere((s) => s is ChatWriteFailure);
          },
          zoneSpecification: ZoneSpecification(
            print: (_, _, _, line) => logged.add(line),
          ),
        );

        expect(logged.where((line) => line.contains(secret)), isEmpty);
        final error = (bloc.state as ChatWriteFailure).error;
        expect(error, AppError.unknown);
        expect(error.toString(), isNot(contains(secret)));
      });
    });
  });
}
