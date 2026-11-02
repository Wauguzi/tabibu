import 'package:equatable/equatable.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

/// Cache first, then a silent sync.
final class NotificationsRequested extends NotificationsEvent {
  const NotificationsRequested({required this.uid});

  final String uid;

  @override
  List<Object?> get props => [uid];
}

/// Sync first: pull-to-refresh.
final class NotificationsRefreshed extends NotificationsEvent {
  const NotificationsRefreshed({required this.uid});

  final String uid;

  @override
  List<Object?> get props => [uid];
}

final class NotificationReadRequested extends NotificationsEvent {
  const NotificationReadRequested({
    required this.uid,
    required this.notificationUid,
  });

  final String uid;
  final String notificationUid;

  @override
  List<Object?> get props => [uid, notificationUid];
}

final class NotificationsAllReadRequested extends NotificationsEvent {
  const NotificationsAllReadRequested({required this.uid});

  final String uid;

  @override
  List<Object?> get props => [uid];
}

/// Back to the initial state on sign-out.
final class NotificationsReset extends NotificationsEvent {
  const NotificationsReset();
}
