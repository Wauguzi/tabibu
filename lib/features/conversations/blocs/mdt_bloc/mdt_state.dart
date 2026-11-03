import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/conversations/data/models/conversation_model.dart';
import 'package:tabibu/features/conversations/data/models/message_model.dart';

/// Group consults, the open one with its thread, and my pending invites.
sealed class MdtState extends Equatable {
  const MdtState({
    this.conversations = const <ConversationModel>[],
    this.invites = const <ConversationModel>[],
    this.active = const ConversationModel(),
    this.messages = const <MessageModel>[],
    this.inviteOnly = false,
    this.openedConversationUid = '',
    this.offline = false,
  });

  /// Every group consult I appear in. Rows where I am not an accepted
  /// member carry no case summary and no last message.
  final List<ConversationModel> conversations;

  /// The subset where my own member status is Invited.
  final List<ConversationModel> invites;

  /// The open consult; an empty model when none is open.
  final ConversationModel active;

  /// The open consult's thread, newest first. Always empty while
  /// [inviteOnly].
  final List<MessageModel> messages;

  /// True when I am not an accepted member of [active]: only the invite is
  /// exposed, never the thread or the case summary.
  final bool inviteOnly;

  /// Set after a successful open so the screen can go to the new consult.
  final String openedConversationUid;

  final bool offline;

  /// The case report is not yet signed, so members see "Report in progress"
  /// and never a draft (H-6, H-7). False for a non-member: the summary is
  /// withheld there, so its default status says nothing.
  bool get reportInProgress =>
      active.uid.isNotEmpty &&
      !inviteOnly &&
      active.caseSummary.reportStatusValue == SummaryReportStatus.pending;

  @override
  List<Object?> get props => [
    conversations,
    invites,
    active,
    messages,
    inviteOnly,
    openedConversationUid,
    offline,
  ];
}

final class MdtInitial extends MdtState {
  const MdtInitial();
}

final class MdtLoadInProgress extends MdtState {
  const MdtLoadInProgress({
    super.conversations,
    super.invites,
    super.active,
    super.messages,
    super.inviteOnly,
    super.openedConversationUid,
    super.offline,
  });
}

final class MdtLoadSuccess extends MdtState {
  const MdtLoadSuccess({
    super.conversations,
    super.invites,
    super.active,
    super.messages,
    super.inviteOnly,
    super.openedConversationUid,
    super.offline,
  });
}

final class MdtLoadFailure extends MdtState {
  const MdtLoadFailure({
    required this.error,
    super.conversations,
    super.invites,
    super.active,
    super.messages,
    super.inviteOnly,
    super.openedConversationUid,
    super.offline,
  });

  final AppError error;

  @override
  List<Object?> get props => [...super.props, error];
}

final class MdtWriteInProgress extends MdtState {
  const MdtWriteInProgress({
    super.conversations,
    super.invites,
    super.active,
    super.messages,
    super.inviteOnly,
    super.openedConversationUid,
    super.offline,
  });
}

final class MdtWriteSuccess extends MdtState {
  const MdtWriteSuccess({
    super.conversations,
    super.invites,
    super.active,
    super.messages,
    super.inviteOnly,
    super.openedConversationUid,
    super.offline,
  });
}

final class MdtWriteFailure extends MdtState {
  const MdtWriteFailure({
    required this.error,
    super.conversations,
    super.invites,
    super.active,
    super.messages,
    super.inviteOnly,
    super.openedConversationUid,
    super.offline,
  });

  final AppError error;

  @override
  List<Object?> get props => [...super.props, error];
}
