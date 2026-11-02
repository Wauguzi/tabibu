import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_bloc.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_event.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_state.dart';

void main() {
  group('NotificationsBloc', () {
    test('starts empty', () {
      expect(NotificationsBloc().state, const NotificationsInitial());
    });

    blocTest<NotificationsBloc, NotificationsState>(
      'drops its data on reset',
      build: NotificationsBloc.new,
      seed: () => const NotificationsLoadSuccess(unread: 3),
      act: (bloc) => bloc.add(const NotificationsReset()),
      expect: () => [const NotificationsInitial()],
    );
  });
}
