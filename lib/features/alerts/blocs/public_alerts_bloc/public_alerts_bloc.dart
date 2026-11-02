import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_event.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_state.dart';
import 'package:tabibu/features/alerts/data/cache/alert_cache_helper.dart';
import 'package:tabibu/features/alerts/data/models/alert_clinician_brief_model.dart';
import 'package:tabibu/features/alerts/data/models/public_alert_model.dart';

/// Released area alerts for the reader's county, and the clinician brief for
/// clinicians.
class PublicAlertsBloc extends Bloc<PublicAlertsEvent, PublicAlertsState> {
  PublicAlertsBloc({AlertCacheHelper? cache})
    : _cache = cache ?? getIt<AlertCacheHelper>(),
      super(const PublicAlertsInitial()) {
    // A county change supersedes the in-flight load.
    on<PublicAlertsRequested>(_onRequested, transformer: restartable());
    // Receipts are local; order them so taps never race.
    on<PublicAlertReadRequested>(_onRead, transformer: sequential());
    on<PublicAlertsReset>((_, emit) => emit(const PublicAlertsInitial()));
  }

  final AlertCacheHelper _cache;

  static const Set<AppError> _offline = {
    .noInternet,
    .serviceUnavailable,
    .requestTimeout,
  };

  AppError _toAppError(Object e) => e is AppError ? e : .unknown;

  PublicAlertsLoadInProgress _inProgress() => PublicAlertsLoadInProgress(
    alerts: state.alerts,
    briefs: state.briefs,
    offline: state.offline,
  );

  PublicAlertsLoadFailure _failure(Object e) => PublicAlertsLoadFailure(
    error: _toAppError(e),
    alerts: state.alerts,
    briefs: state.briefs,
    offline: state.offline,
  );

  PublicAlertsLoadSuccess _success(
    List<PublicAlertModel> alerts,
    Map<String, AlertClinicianBriefModel> briefs, {
    bool offline = false,
  }) =>
      PublicAlertsLoadSuccess(alerts: alerts, briefs: briefs, offline: offline);

  Future<void> _onRequested(
    PublicAlertsRequested event,
    Emitter<PublicAlertsState> emit,
  ) async {
    emit(_inProgress());
    try {
      final alerts = event.clinician
          ? await _cache.publicAlertsForClinician(
              countyId: event.countyId,
              demo: event.demo,
            )
          : await _cache.publicAlertsForCounty(
              countyId: event.countyId,
              demo: event.demo,
            );
      final briefs = <String, AlertClinicianBriefModel>{};
      if (event.clinician) {
        for (final alert in alerts) {
          final brief = await _cache.briefFor(alertUid: alert.uid);
          if (brief != null) briefs[alert.uid] = brief;
        }
      }
      emit(_success(alerts, briefs));
    } on Object catch (e) {
      final error = _toAppError(e);
      if (_offline.contains(error) && state.alerts.isNotEmpty) {
        emit(_success(state.alerts, state.briefs, offline: true));
        return;
      }
      emit(_failure(error));
    }
  }

  Future<void> _onRead(
    PublicAlertReadRequested event,
    Emitter<PublicAlertsState> emit,
  ) async {
    try {
      await _cache.markRead(alertUid: event.alertUid);
    } on Object {
      // A receipt is local; a failure must not blank the list.
    }
  }
}
