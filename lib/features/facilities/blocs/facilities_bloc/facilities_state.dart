import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/facilities/data/models/county_model.dart';
import 'package:tabibu/features/facilities/data/models/facility_model.dart';
import 'package:tabibu/features/facilities/data/models/sub_county_model.dart';

sealed class FacilitiesState extends Equatable {
  const FacilitiesState();

  @override
  List<Object?> get props => [];
}

final class FacilitiesInitial extends FacilitiesState {
  const FacilitiesInitial();
}

final class CountiesLoadInProgress extends FacilitiesState {
  const CountiesLoadInProgress();
}

final class CountiesLoadSuccess extends FacilitiesState {
  const CountiesLoadSuccess(this.counties);

  final List<CountyModel> counties;

  @override
  List<Object?> get props => [counties];
}

final class CountiesLoadFailure extends FacilitiesState {
  const CountiesLoadFailure({required this.error});

  final AppError error;

  @override
  List<Object?> get props => [error];
}

final class SubCountiesLoadInProgress extends FacilitiesState {
  const SubCountiesLoadInProgress();
}

final class SubCountiesLoadSuccess extends FacilitiesState {
  const SubCountiesLoadSuccess(this.subCounties);

  final List<SubCountyModel> subCounties;

  @override
  List<Object?> get props => [subCounties];
}

final class SubCountiesLoadFailure extends FacilitiesState {
  const SubCountiesLoadFailure({required this.error});

  final AppError error;

  @override
  List<Object?> get props => [error];
}

final class FacilitiesSearchInProgress extends FacilitiesState {
  const FacilitiesSearchInProgress();
}

final class FacilitiesSearchSuccess extends FacilitiesState {
  const FacilitiesSearchSuccess(this.results);

  final List<FacilityModel> results;

  @override
  List<Object?> get props => [results];
}

final class FacilitiesSearchFailure extends FacilitiesState {
  const FacilitiesSearchFailure({required this.error});

  final AppError error;

  @override
  List<Object?> get props => [error];
}

final class FacilityLoadSuccess extends FacilitiesState {
  const FacilityLoadSuccess(this.facility);

  final FacilityModel? facility;

  @override
  List<Object?> get props => [facility];
}

final class FacilityLoadFailure extends FacilitiesState {
  const FacilityLoadFailure({required this.error});

  final AppError error;

  @override
  List<Object?> get props => [error];
}
