import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/services/analytics_service.dart';
import 'package:tabibu/core/services/internet_service.dart';
import 'package:tabibu/features/conversations/blocs/mdt_bloc/mdt_event.dart';
import 'package:tabibu/features/conversations/blocs/mdt_bloc/mdt_state.dart';
import 'package:tabibu/features/conversations/data/cache/conversation_cache_helper.dart';
import 'package:tabibu/features/conversations/data/datasources/conversation_firebase.dart';
import 'package:tabibu/features/conversations/data/models/case_summary_model.dart';
import 'package:tabibu/features/conversations/data/models/conversation_model.dart';
import 'package:tabibu/features/conversations/data/models/message_model.dart';
import 'package:tabibu/features/conversations/data/models/message_preview_model.dart';
import 'package:uuid/uuid.dart';

typedef _Listing = ({
  List<ConversationModel> conversations,
  List<ConversationModel> invites,
  bool offline,
});

/// Group consults (MDT). Writes need the network; text messages go through
/// the offline queue. Only an accepted member ever receives the thread or the
/// case summary: an invitee gets the invite alone.
class MdtBloc extends Bloc<MdtEvent, MdtState> {
  MdtBloc({
    ConversationCacheHelper? cache,
    ConversationFirebase? remote,
    InternetService? internet,
    AnalyticsService? analytics,
    String Function()? newConversationUid,
  }) : _cache = cache ?? getIt<ConversationCacheHelper>(),
       _remote = remote ?? getIt<ConversationFirebase>(),
       _internet = internet ?? getIt<InternetService>(),
       _analytics = analytics ?? getIt<AnalyticsService>(),
       _newConversationUid = newConversationUid ?? const Uuid().v4,
       super(const MdtInitial()) {
    on<MdtRequested>(
      (e, emit) => _onLoad(e.uid, emit),
      transformer: droppable(),
    );
    on<MdtRefreshed>(
      (e, emit) => _onLoad(e.uid, emit),
      transformer: droppable(),
    );
    on<MdtOpened>(_onOpened, transformer: restartable());
    on<MdtOpenRequested>(_onOpenRequested, transformer: droppable());
    on<MdtInviteRequested>(_onInvite, transformer: sequential());
    on<MdtRespondRequested>(_onRespond, transformer: sequential());
    on<MdtLeaveRequested>(_onLeave, transformer: sequential());
    on<MdtRemoveRequested>(_onRemove, transformer: sequential());
    on<MdtMessageSendRequested>(_onSend, transformer: sequential());
    on<MdtReset>(_onReset);
  }

  final ConversationCacheHelper _cache;
  final ConversationFirebase _remote;
  final InternetService _internet;
  final AnalyticsService _analytics;
  final String Function() _newConversationUid;

  static const Set<AppError> _offline = {
    .noInternet,
    .serviceUnavailable,
    .requestTimeout,
  };

  AppError _toAppError(Object e) => e is AppError ? e : .unknown;

  Future<void> _requireOnline() async {
    if (!await _internet.check()) throw AppError.noInternet;
  }

  MemberStatus? _statusOf(ConversationModel c, String uid) =>
      c.members[uid]?.statusValue;

  bool _isAccepted(ConversationModel c, String uid) =>
      _statusOf(c, uid) == MemberStatus.accepted;

  /// Strips what a non-member must not see: the case summary and the last
  /// message. The invite keeps its specialty and description.
  ConversationModel _withheld(ConversationModel c) => c.copyWith(
    caseSummary: const CaseSummaryModel(),
    lastMessage: const MessagePreviewModel(),
  );

  ConversationModel _visibleTo(ConversationModel c, String uid) =>
      _isAccepted(c, uid) ? c : _withheld(c);

  Future<_Listing> _listing(String uid) async {
    var offline = false;
    List<ConversationModel> rows;
    try {
      rows = await _cache.syncConversations(uid);
    } on Object catch (e) {
      if (!_offline.contains(_toAppError(e))) rethrow;
      offline = true;
      rows = await _cache.getConversations(
        uid,
        type: ConversationType.groupConsult,
      );
    }
    final consults = [
      for (final c in rows)
        if (c.typeValue == ConversationType.groupConsult) _visibleTo(c, uid),
    ];
    return (
      conversations: consults,
      invites: [
        for (final c in consults)
          if (_statusOf(c, uid) == MemberStatus.invited) c,
      ],
      offline: offline,
    );
  }

  MdtLoadInProgress _loading() => MdtLoadInProgress(
    conversations: state.conversations,
    invites: state.invites,
    active: state.active,
    messages: state.messages,
    inviteOnly: state.inviteOnly,
    openedConversationUid: state.openedConversationUid,
    offline: state.offline,
  );

  MdtWriteInProgress _writing() => MdtWriteInProgress(
    conversations: state.conversations,
    invites: state.invites,
    active: state.active,
    messages: state.messages,
    inviteOnly: state.inviteOnly,
    offline: state.offline,
  );

  MdtWriteFailure _writeFailure(Object e) => MdtWriteFailure(
    error: _toAppError(e),
    conversations: state.conversations,
    invites: state.invites,
    active: state.active,
    messages: state.messages,
    inviteOnly: state.inviteOnly,
    offline: state.offline,
  );

  Future<void> _onLoad(String uid, Emitter<MdtState> emit) async {
    emit(_loading());
    try {
      final listing = await _listing(uid);
      emit(
        MdtLoadSuccess(
          conversations: listing.conversations,
          invites: listing.invites,
          active: state.active,
          messages: state.messages,
          inviteOnly: state.inviteOnly,
          offline: listing.offline,
        ),
      );
    } on Object catch (e) {
      final err = _toAppError(e);
      emit(
        MdtLoadFailure(
          error: err,
          conversations: state.conversations,
          invites: state.invites,
          active: state.active,
          messages: state.messages,
          inviteOnly: state.inviteOnly,
          offline: _offline.contains(err),
        ),
      );
    }
  }

  Future<void> _onOpened(MdtOpened event, Emitter<MdtState> emit) async {
    emit(_loading());
    try {
      var offline = false;
      var consult = await _cache.getConversation(
        event.uid,
        event.conversationUid,
      );
      if (consult.uid.isEmpty) {
        try {
          await _cache.syncConversations(event.uid);
        } on Object catch (e) {
          if (!_offline.contains(_toAppError(e))) rethrow;
          offline = true;
        }
        consult = await _cache.getConversation(
          event.uid,
          event.conversationUid,
        );
      }
      if (consult.uid.isEmpty) throw AppError.dataNotFound;

      if (!_isAccepted(consult, event.uid)) {
        // No thread read at all: the invite is the whole view.
        emit(
          MdtLoadSuccess(
            conversations: state.conversations,
            invites: state.invites,
            active: _withheld(consult),
            inviteOnly: true,
            offline: offline,
          ),
        );
        return;
      }

      List<MessageModel> messages;
      try {
        messages = await _cache.syncMessages(event.uid, event.conversationUid);
      } on Object catch (e) {
        if (!_offline.contains(_toAppError(e))) rethrow;
        offline = true;
        messages = await _cache.getMessages(event.uid, event.conversationUid);
      }
      emit(
        MdtLoadSuccess(
          conversations: state.conversations,
          invites: state.invites,
          active: consult,
          messages: messages,
          offline: offline,
        ),
      );
    } on Object catch (e) {
      final err = _toAppError(e);
      emit(
        MdtLoadFailure(
          error: err,
          conversations: state.conversations,
          invites: state.invites,
          offline: _offline.contains(err),
        ),
      );
    }
  }

  /// After a successful write: re-list so the screen shows the server's
  /// answer. The write already landed, so a failed re-list keeps the lists
  /// the screen has rather than reporting a failure.
  Future<MdtWriteSuccess> _written(
    String uid, {
    String openedConversationUid = '',
  }) async {
    var conversations = state.conversations;
    var invites = state.invites;
    try {
      final listing = await _listing(uid);
      conversations = listing.conversations;
      invites = listing.invites;
    } on Object catch (_) {
      // Stale list is fine; the next refresh converges.
    }

    var active = state.active;
    var messages = state.messages;
    var inviteOnly = state.inviteOnly;
    if (active.uid.isNotEmpty) {
      ConversationModel? row;
      for (final c in conversations) {
        if (c.uid == active.uid) row = c;
      }
      if (row == null) {
        active = const ConversationModel();
        messages = const <MessageModel>[];
        inviteOnly = false;
      } else {
        active = row;
        inviteOnly = !_isAccepted(row, uid);
        if (inviteOnly) messages = const <MessageModel>[];
      }
    }
    return MdtWriteSuccess(
      conversations: conversations,
      invites: invites,
      active: active,
      messages: messages,
      inviteOnly: inviteOnly,
      openedConversationUid: openedConversationUid,
    );
  }

  Future<void> _onOpenRequested(
    MdtOpenRequested event,
    Emitter<MdtState> emit,
  ) async {
    emit(_writing());
    try {
      await _requireOnline();
      final conversationUid = _newConversationUid();
      await _remote.openMdt(
        conversationUid: conversationUid,
        caseUid: event.caseUid,
        specialty: event.specialty,
        description: event.description,
        inviteeUids: event.inviteeUids,
      );
      unawaited(_analytics.logMdtOpened());
      emit(await _written(event.uid, openedConversationUid: conversationUid));
    } on Object catch (e) {
      emit(_writeFailure(e));
    }
  }

  Future<void> _onInvite(
    MdtInviteRequested event,
    Emitter<MdtState> emit,
  ) async {
    emit(_writing());
    try {
      await _requireOnline();
      await _remote.inviteToMdt(
        conversationUid: event.conversationUid,
        inviteeUids: event.inviteeUids,
      );
      unawaited(_analytics.logMdtInvited(count: event.inviteeUids.length));
      emit(await _written(event.uid));
    } on Object catch (e) {
      emit(_writeFailure(e));
    }
  }

  Future<void> _onRespond(
    MdtRespondRequested event,
    Emitter<MdtState> emit,
  ) async {
    emit(_writing());
    try {
      await _requireOnline();
      await _remote.respondToMdtInvite(
        conversationUid: event.conversationUid,
        accept: event.accept,
      );
      unawaited(_analytics.logMdtResponded(accepted: event.accept));
      emit(await _written(event.uid));
    } on Object catch (e) {
      emit(_writeFailure(e));
    }
  }

  Future<void> _onLeave(MdtLeaveRequested event, Emitter<MdtState> emit) async {
    emit(_writing());
    try {
      await _requireOnline();
      await _remote.leaveMdt(conversationUid: event.conversationUid);
      unawaited(_analytics.logMdtLeft());
      emit(await _written(event.uid));
    } on Object catch (e) {
      emit(_writeFailure(e));
    }
  }

  Future<void> _onRemove(
    MdtRemoveRequested event,
    Emitter<MdtState> emit,
  ) async {
    emit(_writing());
    try {
      await _requireOnline();
      await _remote.removeFromMdt(
        conversationUid: event.conversationUid,
        memberUid: event.memberUid,
      );
      unawaited(_analytics.logMdtMemberRemoved());
      emit(await _written(event.uid));
    } on Object catch (e) {
      emit(_writeFailure(e));
    }
  }

  Future<void> _onSend(
    MdtMessageSendRequested event,
    Emitter<MdtState> emit,
  ) async {
    try {
      // The cache lets an invitee through (they are a participant), so the
      // member check is ours.
      final consult = await _cache.getConversation(
        event.uid,
        event.conversationUid,
      );
      if (consult.uid.isEmpty) throw AppError.dataNotFound;
      if (!_isAccepted(consult, event.uid) ||
          consult.statusValue == ConversationStatus.closed) {
        throw AppError.permissionDenied;
      }
      final sent = await _cache.queueTextMessage(
        conversationUid: event.conversationUid,
        senderUid: event.uid,
        text: event.text,
      );
      unawaited(_analytics.logMdtMessageSent());
      emit(
        MdtWriteSuccess(
          conversations: state.conversations,
          invites: state.invites,
          active: state.active,
          messages: state.active.uid == event.conversationUid
              ? [sent, ...state.messages]
              : state.messages,
          inviteOnly: state.inviteOnly,
          offline: state.offline,
        ),
      );
    } on Object catch (e) {
      emit(_writeFailure(e));
    }
  }

  void _onReset(MdtReset event, Emitter<MdtState> emit) {
    emit(const MdtInitial());
  }
}
