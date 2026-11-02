import 'package:bloc/bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';

/// The signed-in patient's or doctor's appointments, and the writes on them.
class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  AppointmentsBloc() : super(const AppointmentsInitial()) {
    on<AppointmentsReset>((_, emit) => emit(const AppointmentsInitial()));
  }
}
