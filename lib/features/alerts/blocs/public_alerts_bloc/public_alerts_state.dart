import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/alerts/data/models/alert_clinician_brief_model.dart';
import 'package:tabibu/features/alerts/data/models/public_alert_model.dart';

/// Released area alerts for the reader's county, and the clinician brief for
/// clinicians. Every state carries the last good data, so a refresh or a
/// failure never blanks the screen.
sealed class PublicAlertsState extends Equatable {
  const PublicAlertsState({
    this.alerts = const <PublicAlertModel>[],
    this.briefs = const <String, AlertClinicianBriefModel>{},
    this.offline = false,
  });

  final List<PublicAlertModel> alerts;
  final Map<String, AlertClinicianBriefModel> briefs;
  final bool offline;

  @override
  List<Object?> get props => [alerts, briefs, offline];
}

final class PublicAlertsInitial extends PublicAlertsState {
  const PublicAlertsInitial();
}

final class PublicAlertsLoadInProgress extends PublicAlertsState {
  const PublicAlertsLoadInProgress({super.alerts, super.briefs, super.offline});
}

final class PublicAlertsLoadSuccess extends PublicAlertsState {
  const PublicAlertsLoadSuccess({super.alerts, super.briefs, super.offline});
}

final class PublicAlertsLoadFailure extends PublicAlertsState {
  const PublicAlertsLoadFailure({
    required this.error,
    super.alerts,
    super.briefs,
    super.offline,
  });

  final AppError error;

  @override
  List<Object?> get props => [...super.props, error];
}
