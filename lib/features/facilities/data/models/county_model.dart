import 'package:freezed_annotation/freezed_annotation.dart';

part 'county_model.freezed.dart';
part 'county_model.g.dart';

/// One row of `assets/data/counties.json`, in file order.
@freezed
abstract class CountyModel with _$CountyModel {
  const factory CountyModel({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'name') required String name,
  }) = _CountyModel;

  factory CountyModel.fromJson(Map<String, dynamic> json) =>
      _$CountyModelFromJson(json);
}
