import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/services/analytics_service.dart';
import 'package:tabibu/core/services/internet_service.dart';
import 'package:tabibu/features/conversations/blocs/chat_bloc/chat_event.dart';
import 'package:tabibu/features/conversations/blocs/chat_bloc/chat_state.dart';
import 'package:tabibu/features/conversations/data/cache/conversation_cache_helper.dart';
import 'package:tabibu/features/conversations/data/datasources/conversation_firebase.dart';
import 'package:tabibu/features/conversations/data/models/conversation_model.dart';
import 'package:tabibu/features/conversations/data/models/message_model.dart';

typedef _Thread = ({List<MessageModel> messages, bool offline});

/// The direct thread of one appointment. Opening and closing need the
/// network; text messages go through the offline queue. Message text is never
/// logged: every failure collapses to an [AppError] before it is reported.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    ConversationCacheHelper? cache,
    ConversationFirebase? remote,
    InternetService? internet,
    AnalyticsService? analytics,
  }) : _cache = cache ?? getIt<ConversationCacheHelper>(),
       _remote = remote ?? getIt<ConversationFirebase>(),
       _internet = internet ?? getIt<InternetService>(),
       _analytics = analytics ?? getIt<AnalyticsService>(),
       super(const ChatInitial()) {
    // Sequential, so a second open of the same appointment waits for the
    // first and then finds the thread already held.
    on<ChatOpened>(_onOpened, transformer: sequential());
    on<ChatRefreshed>(_onRefreshed, transformer: droppable());
    on<ChatMessageSendRequested>(_onSend, transformer: sequential());
    on<ChatCloseRequested>(_onClose, transformer: sequential());
    on<ChatReset>(_onReset);
  }

  final ConversationCacheHelper _cache;
  final ConversationFirebase _remote;
  final InternetService _internet;
  final AnalyticsService _analytics;

  static const Set<AppError> _offlineErrors = {
    .noInternet,
    .serviceUnavailable,
    .requestTimeout,
  };

  AppError _toAppError(Object e) => e is AppError ? e : .unknown;

  Future<void> _requireOnline() async {
    if (!await _internet.check()) throw AppError.noInternet;
  }

  bool _holds(String appointmentUid) {
    final c = state.conversation;
    return c.uid.isNotEmpty &&
        c.typeValue == ConversationType.direct &&
        c.linkedResourceTypeValue == LinkedResourceType.appointment &&
        c.linkedResourceUid == appointmentUid;
  }

  Future<_Thread> _thread(String uid, String conversationUid) async {
    try {
      final messages = await _cache.syncMessages(uid, conversationUid);
      return (messages: messages, offline: false);
    } on Object catch (e) {
      if (!_offlineErrors.contains(_toAppError(e))) rethrow;
      final messages = await _cache.getMessages(uid, conversationUid);
      return (messages: messages, offline: true);
    }
  }

  Future<void> _onOpened(ChatOpened event, Emitter<ChatState> emit) async {
    if (_holds(event.appointmentUid)) return;
    emit(const ChatLoadInProgress());
    try {
      var offline = !await _internet.check();
      if (!offline) {
        try {
          await _remote.openDirectConversation(
            resourceType: LinkedResourceType.appointment.value,
            resourceUid: event.appointmentUid,
          );
          await _cache.syncConversations(event.uid);
        } on Object catch (e) {
          if (!_offlineErrors.contains(_toAppError(e))) rethrow;
          offline = true;
        }
      }

      final rows = await _cache.getForResource(
        event.uid,
        LinkedResourceType.appointment.value,
        event.appointmentUid,
      );
      ConversationModel? conversation;
      for (final row in rows) {
        if (row.typeValue == ConversationType.direct) {
          conversation = row;
          break;
        }
      }
      if (conversation == null) {
        throw offline ? AppError.noInternet : AppError.dataNotFound;
      }

      final thread = await _thread(event.uid, conversation.uid);
      emit(
        ChatLoadSuccess(
          conversation: conversation,
          messages: thread.messages,
          offline: offline || thread.offline,
        ),
      );
    } on Object catch (e) {
      final err = _toAppError(e);
      emit(ChatLoadFailure(error: err, offline: _offlineErrors.contains(err)));
    }
  }

  Future<void> _onRefreshed(
    ChatRefreshed event,
    Emitter<ChatState> emit,
  ) async {
    emit(
      ChatLoadInProgress(
        conversation: state.conversation,
        messages: state.messages,
        offline: state.offline,
      ),
    );
    try {
      var offline = false;
      try {
        await _cache.syncConversations(event.uid);
      } on Object catch (e) {
        if (!_offlineErrors.contains(_toAppError(e))) rethrow;
        offline = true;
      }
      final row = await _cache.getConversation(
        event.uid,
        event.conversationUid,
      );
      if (row.uid.isEmpty) throw AppError.dataNotFound;

      final thread = await _thread(event.uid, event.conversationUid);
      emit(
        ChatLoadSuccess(
          conversation: row,
          messages: thread.messages,
          offline: offline || thread.offline,
        ),
      );
    } on Object catch (e) {
      final err = _toAppError(e);
      emit(
        ChatLoadFailure(
          error: err,
          conversation: state.conversation,
          messages: state.messages,
          offline: _offlineErrors.contains(err),
        ),
      );
    }
  }

  Future<void> _onSend(
    ChatMessageSendRequested event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final conversation = await _cache.getConversation(
        event.uid,
        event.conversationUid,
      );
      if (conversation.uid.isEmpty) throw AppError.dataNotFound;
      final heldClosed =
          state.conversation.uid == event.conversationUid && state.readOnly;
      if (heldClosed || conversation.statusValue == ConversationStatus.closed) {
        throw AppError.permissionDenied;
      }
      final sent = await _cache.queueTextMessage(
        conversationUid: event.conversationUid,
        senderUid: event.uid,
        text: event.text,
      );
      unawaited(_analytics.logChatMessageSent());
      emit(
        ChatWriteSuccess(
          conversation: state.conversation,
          messages: state.conversation.uid == event.conversationUid
              ? [sent, ...state.messages]
              : state.messages,
          offline: state.offline,
        ),
      );
    } on Object catch (e) {
      emit(
        ChatWriteFailure(
          error: _toAppError(e),
          conversation: state.conversation,
          messages: state.messages,
          offline: state.offline,
        ),
      );
    }
  }

  Future<void> _onClose(
    ChatCloseRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(
      ChatWriteInProgress(
        conversation: state.conversation,
        messages: state.messages,
        offline: state.offline,
      ),
    );
    try {
      await _requireOnline();
      await _remote.closeConversation(conversationUid: event.conversationUid);
      unawaited(_analytics.logChatClosed());

      // The close landed, so a failed re-read keeps what the screen has and
      // still reports the thread closed.
      var row = state.conversation;
      try {
        await _cache.syncConversations(event.uid);
        final fresh = await _cache.getConversation(
          event.uid,
          event.conversationUid,
        );
        if (fresh.uid.isNotEmpty) row = fresh;
      } on Object catch (_) {
        // The next refresh converges.
      }
      emit(
        ChatWriteSuccess(
          conversation: row.uid == event.conversationUid
              ? row.copyWith(status: ConversationStatus.closed.value)
              : row,
          messages: state.messages,
          offline: state.offline,
        ),
      );
    } on Object catch (e) {
      emit(
        ChatWriteFailure(
          error: _toAppError(e),
          conversation: state.conversation,
          messages: state.messages,
          offline: state.offline,
        ),
      );
    }
  }

  void _onReset(ChatReset event, Emitter<ChatState> emit) {
    emit(const ChatInitial());
  }
}
