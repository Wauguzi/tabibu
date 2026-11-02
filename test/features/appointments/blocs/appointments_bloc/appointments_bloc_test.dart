import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';

void main() {
  group('AppointmentsBloc', () {
    test('starts empty', () {
      expect(AppointmentsBloc().state, const AppointmentsInitial());
    });

    blocTest<AppointmentsBloc, AppointmentsState>(
      'drops its data on reset',
      build: AppointmentsBloc.new,
      seed: () => const AppointmentsLoadSuccess(offline: true),
      act: (bloc) => bloc.add(const AppointmentsReset()),
      expect: () => [const AppointmentsInitial()],
    );
  });
}
