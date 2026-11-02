import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/notifications/data/models/notification_model.dart';

/// The signed-in user's inbox, newest first. Every state carries the last good
/// data, so a refresh or a failure never blanks the screen.
sealed class NotificationsState extends Equatable {
  const NotificationsState({
    this.items = const <NotificationModel>[],
    this.unread = 0,
    this.offline = false,
  });

  final List<NotificationModel> items;
  final int unread;
  final bool offline;

  @override
  List<Object?> get props => [items, unread, offline];
}

final class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

final class NotificationsLoadInProgress extends NotificationsState {
  const NotificationsLoadInProgress({super.items, super.unread, super.offline});
}

final class NotificationsLoadSuccess extends NotificationsState {
  const NotificationsLoadSuccess({super.items, super.unread, super.offline});
}

final class NotificationsLoadFailure extends NotificationsState {
  const NotificationsLoadFailure({
    required this.error,
    super.items,
    super.unread,
    super.offline,
  });

  final AppError error;

  @override
  List<Object?> get props => [...super.props, error];
}
