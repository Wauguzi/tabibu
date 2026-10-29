import 'package:equatable/equatable.dart';

sealed class FacilitiesEvent extends Equatable {
  const FacilitiesEvent();

  @override
  List<Object?> get props => [];
}

/// D4's county sheet.
final class FacilitiesCountiesRequested extends FacilitiesEvent {
  const FacilitiesCountiesRequested();
}

/// D4's sub-county sheet, Nairobi only.
final class FacilitiesSubCountiesRequested extends FacilitiesEvent {
  const FacilitiesSubCountiesRequested();
}

/// E3/F3's facility search. Only the latest query matters.
final class FacilitiesSearchRequested extends FacilitiesEvent {
  const FacilitiesSearchRequested(this.query, {this.nearGeohash = ''});

  final String query;
  final String nearGeohash;

  @override
  List<Object?> get props => [query, nearGeohash];
}

/// E4/F4's review: the chosen facility's name.
final class FacilitiesFacilityRequested extends FacilitiesEvent {
  const FacilitiesFacilityRequested(this.facilityId);

  final String facilityId;

  @override
  List<Object?> get props => [facilityId];
}
