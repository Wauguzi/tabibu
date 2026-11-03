import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/conversations/data/models/conversation_model.dart';
import 'package:tabibu/features/conversations/data/models/message_model.dart';

/// One appointment's direct thread with its messages.
sealed class ChatState extends Equatable {
  const ChatState({
    this.conversation = const ConversationModel(),
    this.messages = const <MessageModel>[],
    this.offline = false,
  });

  /// The open thread; an empty model when none is open.
  final ConversationModel conversation;

  /// The thread, newest first.
  final List<MessageModel> messages;

  final bool offline;

  /// A closed thread can be read but never written to.
  bool get readOnly =>
      conversation.uid.isNotEmpty &&
      conversation.statusValue == ConversationStatus.closed;

  @override
  List<Object?> get props => [conversation, messages, offline];
}

final class ChatInitial extends ChatState {
  const ChatInitial();
}

final class ChatLoadInProgress extends ChatState {
  const ChatLoadInProgress({super.conversation, super.messages, super.offline});
}

final class ChatLoadSuccess extends ChatState {
  const ChatLoadSuccess({super.conversation, super.messages, super.offline});
}

final class ChatLoadFailure extends ChatState {
  const ChatLoadFailure({
    required this.error,
    super.conversation,
    super.messages,
    super.offline,
  });

  final AppError error;

  @override
  List<Object?> get props => [...super.props, error];
}

final class ChatWriteInProgress extends ChatState {
  const ChatWriteInProgress({
    super.conversation,
    super.messages,
    super.offline,
  });
}

final class ChatWriteSuccess extends ChatState {
  const ChatWriteSuccess({super.conversation, super.messages, super.offline});
}

final class ChatWriteFailure extends ChatState {
  const ChatWriteFailure({
    required this.error,
    super.conversation,
    super.messages,
    super.offline,
  });

  final AppError error;

  @override
  List<Object?> get props => [...super.props, error];
}
