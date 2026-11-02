import 'package:bloc/bloc.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';

/// Cases and their signed reports for any role: a patient's results, a doctor's
/// cases, a pathologist's signed work.
class CasesBloc extends Bloc<CasesEvent, CasesState> {
  CasesBloc() : super(const CasesInitial()) {
    on<CasesReset>((_, emit) => emit(const CasesInitial()));
  }
}
