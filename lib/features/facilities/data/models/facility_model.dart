import 'package:freezed_annotation/freezed_annotation.dart';

part 'facility_model.freezed.dart';
part 'facility_model.g.dart';

/// One row of `assets/data/facilities_nairobi.json`, in file order.
/// Bundled reference data: read from the bundle, never written.
@freezed
abstract class FacilityModel with _$FacilityModel {
  const factory FacilityModel({
    @JsonKey(name: 'facilityId') required String facilityId,
    @JsonKey(name: 'mflCode') required String mflCode,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'kephLevel') required String kephLevel,
    @JsonKey(name: 'facilityType') required String facilityType,
    @JsonKey(name: 'owner') required String owner,
    @JsonKey(name: 'wardId') required int wardId,
    @JsonKey(name: 'ward') required String ward,
    @JsonKey(name: 'subCountyId') required int subCountyId,
    @JsonKey(name: 'subCounty') required String subCounty,
    @JsonKey(name: 'countyId') required int countyId,
    @JsonKey(name: 'county') required String county,
    @JsonKey(name: 'latitude') required double latitude,
    @JsonKey(name: 'longitude') required double longitude,
    @JsonKey(name: 'geohash') required String geohash,
    @JsonKey(name: 'isLocationApproximate') required bool isLocationApproximate,
    @JsonKey(name: 'isLab') required bool isLab,
    @JsonKey(name: 'operationStatus') required String operationStatus,
    @JsonKey(name: 'isOperational') required bool isOperational,
  }) = _FacilityModel;

  factory FacilityModel.fromJson(Map<String, dynamic> json) =>
      _$FacilityModelFromJson(json);
}
