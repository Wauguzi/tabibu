import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Open the direct thread of one appointment. Opening the thread the state
/// already holds does nothing.
final class ChatOpened extends ChatEvent {
  const ChatOpened({
    required this.uid,
    required this.role,
    required this.appointmentUid,
  });

  final String uid;
  final Role role;
  final String appointmentUid;

  @override
  List<Object?> get props => [uid, role, appointmentUid];
}

/// Pull-to-refresh: sync the thread again.
final class ChatRefreshed extends ChatEvent {
  const ChatRefreshed({required this.uid, required this.conversationUid});

  final String uid;
  final String conversationUid;

  @override
  List<Object?> get props => [uid, conversationUid];
}

/// Send a text message. Queued, so it works offline.
final class ChatMessageSendRequested extends ChatEvent {
  const ChatMessageSendRequested({
    required this.uid,
    required this.conversationUid,
    required this.text,
  });

  final String uid;
  final String conversationUid;
  final String text;

  @override
  List<Object?> get props => [uid, conversationUid, text];
}

/// Close the thread. Needs the network.
final class ChatCloseRequested extends ChatEvent {
  const ChatCloseRequested({required this.uid, required this.conversationUid});

  final String uid;
  final String conversationUid;

  @override
  List<Object?> get props => [uid, conversationUid];
}

final class ChatReset extends ChatEvent {
  const ChatReset();
}
