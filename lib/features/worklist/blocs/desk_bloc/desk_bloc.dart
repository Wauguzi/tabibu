import 'package:bloc/bloc.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_event.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_state.dart';

/// The pathologist's ranked desk, with its filter and search.
class DeskBloc extends Bloc<DeskEvent, DeskState> {
  DeskBloc() : super(const DeskInitial()) {
    on<DeskReset>((_, emit) => emit(const DeskInitial()));
  }
}
