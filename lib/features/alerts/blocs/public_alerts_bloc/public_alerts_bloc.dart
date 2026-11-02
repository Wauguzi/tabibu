import 'package:bloc/bloc.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_event.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_state.dart';

/// Released area alerts for the reader's county, and the clinician brief for
/// clinicians.
class PublicAlertsBloc extends Bloc<PublicAlertsEvent, PublicAlertsState> {
  PublicAlertsBloc() : super(const PublicAlertsInitial()) {
    on<PublicAlertsReset>((_, emit) => emit(const PublicAlertsInitial()));
  }
}
