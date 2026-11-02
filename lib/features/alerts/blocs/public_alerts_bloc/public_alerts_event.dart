import 'package:equatable/equatable.dart';

sealed class PublicAlertsEvent extends Equatable {
  const PublicAlertsEvent();

  @override
  List<Object?> get props => [];
}

final class PublicAlertsRequested extends PublicAlertsEvent {
  const PublicAlertsRequested({
    required this.countyId,
    required this.demo,
    required this.clinician,
  });

  final int countyId;
  final bool demo;
  final bool clinician;

  @override
  List<Object?> get props => [countyId, demo, clinician];
}

final class PublicAlertReadRequested extends PublicAlertsEvent {
  const PublicAlertReadRequested({required this.alertUid});

  final String alertUid;

  @override
  List<Object?> get props => [alertUid];
}

/// Back to the initial state on sign-out.
final class PublicAlertsReset extends PublicAlertsEvent {
  const PublicAlertsReset();
}
