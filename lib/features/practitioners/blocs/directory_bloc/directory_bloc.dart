import 'package:bloc/bloc.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_state.dart';

/// The public directory of practitioners, filtered for the patient's search.
class DirectoryBloc extends Bloc<DirectoryEvent, DirectoryState> {
  DirectoryBloc() : super(const DirectoryInitial()) {
    on<DirectoryReset>((_, emit) => emit(const DirectoryInitial()));
  }
}
