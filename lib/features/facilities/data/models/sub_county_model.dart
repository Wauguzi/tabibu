import 'package:freezed_annotation/freezed_annotation.dart';

part 'sub_county_model.freezed.dart';
part 'sub_county_model.g.dart';

/// One row of `assets/data/sub_counties_nairobi.json`, in file order.
@freezed
abstract class SubCountyModel with _$SubCountyModel {
  const factory SubCountyModel({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'countyId') required int countyId,
    @JsonKey(name: 'latitude') required double latitude,
    @JsonKey(name: 'longitude') required double longitude,
    @JsonKey(name: 'geohash') required String geohash,
  }) = _SubCountyModel;

  factory SubCountyModel.fromJson(Map<String, dynamic> json) =>
      _$SubCountyModelFromJson(json);
}
