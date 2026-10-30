import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/facilities_helper.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_bloc.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_event.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_state.dart';
import 'package:tabibu/features/facilities/data/models/county_model.dart';
import 'package:tabibu/features/facilities/data/models/facility_model.dart';
import 'package:tabibu/features/facilities/data/models/sub_county_model.dart';

class MockFacilitiesHelper extends Mock implements FacilitiesHelper {}

const _county = CountyModel(id: 47, name: 'Nairobi');

const _subCounty = SubCountyModel(
  id: 1,
  name: 'Dagoretti',
  countyId: 47,
  latitude: -1.29,
  longitude: 36.75,
  geohash: 'ky9',
);

FacilityModel _facility(String id, String name) => FacilityModel(
  facilityId: id,
  mflCode: 'mfl-$id',
  name: name,
  kephLevel: 'Level 3',
  facilityType: 'Dispensary',
  owner: 'County',
  wardId: 1,
  ward: 'Mutuini',
  subCountyId: 1,
  subCounty: 'Dagoretti',
  countyId: 47,
  county: 'Nairobi',
  latitude: -1.29,
  longitude: 36.75,
  geohash: 'ky9',
  isLocationApproximate: false,
  isLab: false,
  operationStatus: 'Operational',
  isOperational: true,
);

void main() {
  group('FacilitiesBloc', () {
    late MockFacilitiesHelper facilitiesHelper;

    setUp(() {
      facilitiesHelper = MockFacilitiesHelper();
    });

    blocTest<FacilitiesBloc, FacilitiesState>(
      'loads counties',
      build: () {
        when(facilitiesHelper.counties).thenAnswer((_) async => [_county]);
        return FacilitiesBloc(facilitiesHelper: facilitiesHelper);
      },
      act: (bloc) => bloc.add(const FacilitiesCountiesRequested()),
      expect: () => const [
        CountiesLoadInProgress(),
        CountiesLoadSuccess([_county]),
      ],
    );

    blocTest<FacilitiesBloc, FacilitiesState>(
      'maps a counties failure to data-not-found',
      build: () {
        when(facilitiesHelper.counties).thenThrow(Exception('no asset'));
        return FacilitiesBloc(facilitiesHelper: facilitiesHelper);
      },
      act: (bloc) => bloc.add(const FacilitiesCountiesRequested()),
      expect: () => const [
        CountiesLoadInProgress(),
        CountiesLoadFailure(error: AppError.dataNotFound),
      ],
    );

    blocTest<FacilitiesBloc, FacilitiesState>(
      'loads Nairobi sub-counties',
      build: () {
        when(
          facilitiesHelper.nairobiSubCounties,
        ).thenAnswer((_) async => [_subCounty]);
        return FacilitiesBloc(facilitiesHelper: facilitiesHelper);
      },
      act: (bloc) => bloc.add(const FacilitiesSubCountiesRequested()),
      expect: () => const [
        SubCountiesLoadInProgress(),
        SubCountiesLoadSuccess([_subCounty]),
      ],
    );

    blocTest<FacilitiesBloc, FacilitiesState>(
      'searches facilities through the helper',
      build: () {
        when(
          () => facilitiesHelper.searchFacilities(
            'aga',
            nearGeohash: any(named: 'nearGeohash'),
          ),
        ).thenAnswer((_) async => [_facility('1', 'Aga Khan')]);
        return FacilitiesBloc(facilitiesHelper: facilitiesHelper);
      },
      act: (bloc) => bloc.add(const FacilitiesSearchRequested('aga')),
      expect: () => [
        const FacilitiesSearchInProgress(),
        FacilitiesSearchSuccess([_facility('1', 'Aga Khan')]),
      ],
      verify: (_) {
        verify(
          () => facilitiesHelper.searchFacilities(
            'aga',
            nearGeohash: any(named: 'nearGeohash'),
          ),
        ).called(1);
      },
    );

    blocTest<FacilitiesBloc, FacilitiesState>(
      'maps a search failure to data-not-found',
      build: () {
        when(
          () => facilitiesHelper.searchFacilities(
            any(),
            nearGeohash: any(named: 'nearGeohash'),
          ),
        ).thenThrow(Exception('no asset'));
        return FacilitiesBloc(facilitiesHelper: facilitiesHelper);
      },
      act: (bloc) => bloc.add(const FacilitiesSearchRequested('aga')),
      expect: () => const [
        FacilitiesSearchInProgress(),
        FacilitiesSearchFailure(error: AppError.dataNotFound),
      ],
    );

    blocTest<FacilitiesBloc, FacilitiesState>(
      'looks a facility up by id',
      build: () {
        when(
          () => facilitiesHelper.facilityById('1'),
        ).thenAnswer((_) async => _facility('1', 'Aga Khan'));
        return FacilitiesBloc(facilitiesHelper: facilitiesHelper);
      },
      act: (bloc) => bloc.add(const FacilitiesFacilityRequested('1')),
      expect: () => [FacilityLoadSuccess(_facility('1', 'Aga Khan'))],
    );
  });
}
