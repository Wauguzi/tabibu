// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'facility_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FacilityModel {

@JsonKey(name: 'facilityId') String get facilityId;@JsonKey(name: 'mflCode') String get mflCode;@JsonKey(name: 'name') String get name;@JsonKey(name: 'kephLevel') String get kephLevel;@JsonKey(name: 'facilityType') String get facilityType;@JsonKey(name: 'owner') String get owner;@JsonKey(name: 'wardId') int get wardId;@JsonKey(name: 'ward') String get ward;@JsonKey(name: 'subCountyId') int get subCountyId;@JsonKey(name: 'subCounty') String get subCounty;@JsonKey(name: 'countyId') int get countyId;@JsonKey(name: 'county') String get county;@JsonKey(name: 'latitude') double get latitude;@JsonKey(name: 'longitude') double get longitude;@JsonKey(name: 'geohash') String get geohash;@JsonKey(name: 'isLocationApproximate') bool get isLocationApproximate;@JsonKey(name: 'isLab') bool get isLab;@JsonKey(name: 'operationStatus') String get operationStatus;@JsonKey(name: 'isOperational') bool get isOperational;
/// Create a copy of FacilityModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FacilityModelCopyWith<FacilityModel> get copyWith => _$FacilityModelCopyWithImpl<FacilityModel>(this as FacilityModel, _$identity);

  /// Serializes this FacilityModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FacilityModel&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.mflCode, mflCode) || other.mflCode == mflCode)&&(identical(other.name, name) || other.name == name)&&(identical(other.kephLevel, kephLevel) || other.kephLevel == kephLevel)&&(identical(other.facilityType, facilityType) || other.facilityType == facilityType)&&(identical(other.owner, owner) || other.owner == owner)&&(identical(other.wardId, wardId) || other.wardId == wardId)&&(identical(other.ward, ward) || other.ward == ward)&&(identical(other.subCountyId, subCountyId) || other.subCountyId == subCountyId)&&(identical(other.subCounty, subCounty) || other.subCounty == subCounty)&&(identical(other.countyId, countyId) || other.countyId == countyId)&&(identical(other.county, county) || other.county == county)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.geohash, geohash) || other.geohash == geohash)&&(identical(other.isLocationApproximate, isLocationApproximate) || other.isLocationApproximate == isLocationApproximate)&&(identical(other.isLab, isLab) || other.isLab == isLab)&&(identical(other.operationStatus, operationStatus) || other.operationStatus == operationStatus)&&(identical(other.isOperational, isOperational) || other.isOperational == isOperational));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,facilityId,mflCode,name,kephLevel,facilityType,owner,wardId,ward,subCountyId,subCounty,countyId,county,latitude,longitude,geohash,isLocationApproximate,isLab,operationStatus,isOperational]);

@override
String toString() {
  return 'FacilityModel(facilityId: $facilityId, mflCode: $mflCode, name: $name, kephLevel: $kephLevel, facilityType: $facilityType, owner: $owner, wardId: $wardId, ward: $ward, subCountyId: $subCountyId, subCounty: $subCounty, countyId: $countyId, county: $county, latitude: $latitude, longitude: $longitude, geohash: $geohash, isLocationApproximate: $isLocationApproximate, isLab: $isLab, operationStatus: $operationStatus, isOperational: $isOperational)';
}


}

/// @nodoc
abstract mixin class $FacilityModelCopyWith<$Res>  {
  factory $FacilityModelCopyWith(FacilityModel value, $Res Function(FacilityModel) _then) = _$FacilityModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'facilityId') String facilityId,@JsonKey(name: 'mflCode') String mflCode,@JsonKey(name: 'name') String name,@JsonKey(name: 'kephLevel') String kephLevel,@JsonKey(name: 'facilityType') String facilityType,@JsonKey(name: 'owner') String owner,@JsonKey(name: 'wardId') int wardId,@JsonKey(name: 'ward') String ward,@JsonKey(name: 'subCountyId') int subCountyId,@JsonKey(name: 'subCounty') String subCounty,@JsonKey(name: 'countyId') int countyId,@JsonKey(name: 'county') String county,@JsonKey(name: 'latitude') double latitude,@JsonKey(name: 'longitude') double longitude,@JsonKey(name: 'geohash') String geohash,@JsonKey(name: 'isLocationApproximate') bool isLocationApproximate,@JsonKey(name: 'isLab') bool isLab,@JsonKey(name: 'operationStatus') String operationStatus,@JsonKey(name: 'isOperational') bool isOperational
});




}
/// @nodoc
class _$FacilityModelCopyWithImpl<$Res>
    implements $FacilityModelCopyWith<$Res> {
  _$FacilityModelCopyWithImpl(this._self, this._then);

  final FacilityModel _self;
  final $Res Function(FacilityModel) _then;

/// Create a copy of FacilityModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? facilityId = null,Object? mflCode = null,Object? name = null,Object? kephLevel = null,Object? facilityType = null,Object? owner = null,Object? wardId = null,Object? ward = null,Object? subCountyId = null,Object? subCounty = null,Object? countyId = null,Object? county = null,Object? latitude = null,Object? longitude = null,Object? geohash = null,Object? isLocationApproximate = null,Object? isLab = null,Object? operationStatus = null,Object? isOperational = null,}) {
  return _then(_self.copyWith(
facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as String,mflCode: null == mflCode ? _self.mflCode : mflCode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kephLevel: null == kephLevel ? _self.kephLevel : kephLevel // ignore: cast_nullable_to_non_nullable
as String,facilityType: null == facilityType ? _self.facilityType : facilityType // ignore: cast_nullable_to_non_nullable
as String,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as String,wardId: null == wardId ? _self.wardId : wardId // ignore: cast_nullable_to_non_nullable
as int,ward: null == ward ? _self.ward : ward // ignore: cast_nullable_to_non_nullable
as String,subCountyId: null == subCountyId ? _self.subCountyId : subCountyId // ignore: cast_nullable_to_non_nullable
as int,subCounty: null == subCounty ? _self.subCounty : subCounty // ignore: cast_nullable_to_non_nullable
as String,countyId: null == countyId ? _self.countyId : countyId // ignore: cast_nullable_to_non_nullable
as int,county: null == county ? _self.county : county // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,geohash: null == geohash ? _self.geohash : geohash // ignore: cast_nullable_to_non_nullable
as String,isLocationApproximate: null == isLocationApproximate ? _self.isLocationApproximate : isLocationApproximate // ignore: cast_nullable_to_non_nullable
as bool,isLab: null == isLab ? _self.isLab : isLab // ignore: cast_nullable_to_non_nullable
as bool,operationStatus: null == operationStatus ? _self.operationStatus : operationStatus // ignore: cast_nullable_to_non_nullable
as String,isOperational: null == isOperational ? _self.isOperational : isOperational // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FacilityModel].
extension FacilityModelPatterns on FacilityModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FacilityModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FacilityModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FacilityModel value)  $default,){
final _that = this;
switch (_that) {
case _FacilityModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FacilityModel value)?  $default,){
final _that = this;
switch (_that) {
case _FacilityModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'facilityId')  String facilityId, @JsonKey(name: 'mflCode')  String mflCode, @JsonKey(name: 'name')  String name, @JsonKey(name: 'kephLevel')  String kephLevel, @JsonKey(name: 'facilityType')  String facilityType, @JsonKey(name: 'owner')  String owner, @JsonKey(name: 'wardId')  int wardId, @JsonKey(name: 'ward')  String ward, @JsonKey(name: 'subCountyId')  int subCountyId, @JsonKey(name: 'subCounty')  String subCounty, @JsonKey(name: 'countyId')  int countyId, @JsonKey(name: 'county')  String county, @JsonKey(name: 'latitude')  double latitude, @JsonKey(name: 'longitude')  double longitude, @JsonKey(name: 'geohash')  String geohash, @JsonKey(name: 'isLocationApproximate')  bool isLocationApproximate, @JsonKey(name: 'isLab')  bool isLab, @JsonKey(name: 'operationStatus')  String operationStatus, @JsonKey(name: 'isOperational')  bool isOperational)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FacilityModel() when $default != null:
return $default(_that.facilityId,_that.mflCode,_that.name,_that.kephLevel,_that.facilityType,_that.owner,_that.wardId,_that.ward,_that.subCountyId,_that.subCounty,_that.countyId,_that.county,_that.latitude,_that.longitude,_that.geohash,_that.isLocationApproximate,_that.isLab,_that.operationStatus,_that.isOperational);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'facilityId')  String facilityId, @JsonKey(name: 'mflCode')  String mflCode, @JsonKey(name: 'name')  String name, @JsonKey(name: 'kephLevel')  String kephLevel, @JsonKey(name: 'facilityType')  String facilityType, @JsonKey(name: 'owner')  String owner, @JsonKey(name: 'wardId')  int wardId, @JsonKey(name: 'ward')  String ward, @JsonKey(name: 'subCountyId')  int subCountyId, @JsonKey(name: 'subCounty')  String subCounty, @JsonKey(name: 'countyId')  int countyId, @JsonKey(name: 'county')  String county, @JsonKey(name: 'latitude')  double latitude, @JsonKey(name: 'longitude')  double longitude, @JsonKey(name: 'geohash')  String geohash, @JsonKey(name: 'isLocationApproximate')  bool isLocationApproximate, @JsonKey(name: 'isLab')  bool isLab, @JsonKey(name: 'operationStatus')  String operationStatus, @JsonKey(name: 'isOperational')  bool isOperational)  $default,) {final _that = this;
switch (_that) {
case _FacilityModel():
return $default(_that.facilityId,_that.mflCode,_that.name,_that.kephLevel,_that.facilityType,_that.owner,_that.wardId,_that.ward,_that.subCountyId,_that.subCounty,_that.countyId,_that.county,_that.latitude,_that.longitude,_that.geohash,_that.isLocationApproximate,_that.isLab,_that.operationStatus,_that.isOperational);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'facilityId')  String facilityId, @JsonKey(name: 'mflCode')  String mflCode, @JsonKey(name: 'name')  String name, @JsonKey(name: 'kephLevel')  String kephLevel, @JsonKey(name: 'facilityType')  String facilityType, @JsonKey(name: 'owner')  String owner, @JsonKey(name: 'wardId')  int wardId, @JsonKey(name: 'ward')  String ward, @JsonKey(name: 'subCountyId')  int subCountyId, @JsonKey(name: 'subCounty')  String subCounty, @JsonKey(name: 'countyId')  int countyId, @JsonKey(name: 'county')  String county, @JsonKey(name: 'latitude')  double latitude, @JsonKey(name: 'longitude')  double longitude, @JsonKey(name: 'geohash')  String geohash, @JsonKey(name: 'isLocationApproximate')  bool isLocationApproximate, @JsonKey(name: 'isLab')  bool isLab, @JsonKey(name: 'operationStatus')  String operationStatus, @JsonKey(name: 'isOperational')  bool isOperational)?  $default,) {final _that = this;
switch (_that) {
case _FacilityModel() when $default != null:
return $default(_that.facilityId,_that.mflCode,_that.name,_that.kephLevel,_that.facilityType,_that.owner,_that.wardId,_that.ward,_that.subCountyId,_that.subCounty,_that.countyId,_that.county,_that.latitude,_that.longitude,_that.geohash,_that.isLocationApproximate,_that.isLab,_that.operationStatus,_that.isOperational);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FacilityModel implements FacilityModel {
  const _FacilityModel({@JsonKey(name: 'facilityId') required this.facilityId, @JsonKey(name: 'mflCode') required this.mflCode, @JsonKey(name: 'name') required this.name, @JsonKey(name: 'kephLevel') required this.kephLevel, @JsonKey(name: 'facilityType') required this.facilityType, @JsonKey(name: 'owner') required this.owner, @JsonKey(name: 'wardId') required this.wardId, @JsonKey(name: 'ward') required this.ward, @JsonKey(name: 'subCountyId') required this.subCountyId, @JsonKey(name: 'subCounty') required this.subCounty, @JsonKey(name: 'countyId') required this.countyId, @JsonKey(name: 'county') required this.county, @JsonKey(name: 'latitude') required this.latitude, @JsonKey(name: 'longitude') required this.longitude, @JsonKey(name: 'geohash') required this.geohash, @JsonKey(name: 'isLocationApproximate') required this.isLocationApproximate, @JsonKey(name: 'isLab') required this.isLab, @JsonKey(name: 'operationStatus') required this.operationStatus, @JsonKey(name: 'isOperational') required this.isOperational});
  factory _FacilityModel.fromJson(Map<String, dynamic> json) => _$FacilityModelFromJson(json);

@override@JsonKey(name: 'facilityId') final  String facilityId;
@override@JsonKey(name: 'mflCode') final  String mflCode;
@override@JsonKey(name: 'name') final  String name;
@override@JsonKey(name: 'kephLevel') final  String kephLevel;
@override@JsonKey(name: 'facilityType') final  String facilityType;
@override@JsonKey(name: 'owner') final  String owner;
@override@JsonKey(name: 'wardId') final  int wardId;
@override@JsonKey(name: 'ward') final  String ward;
@override@JsonKey(name: 'subCountyId') final  int subCountyId;
@override@JsonKey(name: 'subCounty') final  String subCounty;
@override@JsonKey(name: 'countyId') final  int countyId;
@override@JsonKey(name: 'county') final  String county;
@override@JsonKey(name: 'latitude') final  double latitude;
@override@JsonKey(name: 'longitude') final  double longitude;
@override@JsonKey(name: 'geohash') final  String geohash;
@override@JsonKey(name: 'isLocationApproximate') final  bool isLocationApproximate;
@override@JsonKey(name: 'isLab') final  bool isLab;
@override@JsonKey(name: 'operationStatus') final  String operationStatus;
@override@JsonKey(name: 'isOperational') final  bool isOperational;

/// Create a copy of FacilityModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FacilityModelCopyWith<_FacilityModel> get copyWith => __$FacilityModelCopyWithImpl<_FacilityModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FacilityModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FacilityModel&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.mflCode, mflCode) || other.mflCode == mflCode)&&(identical(other.name, name) || other.name == name)&&(identical(other.kephLevel, kephLevel) || other.kephLevel == kephLevel)&&(identical(other.facilityType, facilityType) || other.facilityType == facilityType)&&(identical(other.owner, owner) || other.owner == owner)&&(identical(other.wardId, wardId) || other.wardId == wardId)&&(identical(other.ward, ward) || other.ward == ward)&&(identical(other.subCountyId, subCountyId) || other.subCountyId == subCountyId)&&(identical(other.subCounty, subCounty) || other.subCounty == subCounty)&&(identical(other.countyId, countyId) || other.countyId == countyId)&&(identical(other.county, county) || other.county == county)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.geohash, geohash) || other.geohash == geohash)&&(identical(other.isLocationApproximate, isLocationApproximate) || other.isLocationApproximate == isLocationApproximate)&&(identical(other.isLab, isLab) || other.isLab == isLab)&&(identical(other.operationStatus, operationStatus) || other.operationStatus == operationStatus)&&(identical(other.isOperational, isOperational) || other.isOperational == isOperational));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,facilityId,mflCode,name,kephLevel,facilityType,owner,wardId,ward,subCountyId,subCounty,countyId,county,latitude,longitude,geohash,isLocationApproximate,isLab,operationStatus,isOperational]);

@override
String toString() {
  return 'FacilityModel(facilityId: $facilityId, mflCode: $mflCode, name: $name, kephLevel: $kephLevel, facilityType: $facilityType, owner: $owner, wardId: $wardId, ward: $ward, subCountyId: $subCountyId, subCounty: $subCounty, countyId: $countyId, county: $county, latitude: $latitude, longitude: $longitude, geohash: $geohash, isLocationApproximate: $isLocationApproximate, isLab: $isLab, operationStatus: $operationStatus, isOperational: $isOperational)';
}


}

/// @nodoc
abstract mixin class _$FacilityModelCopyWith<$Res> implements $FacilityModelCopyWith<$Res> {
  factory _$FacilityModelCopyWith(_FacilityModel value, $Res Function(_FacilityModel) _then) = __$FacilityModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'facilityId') String facilityId,@JsonKey(name: 'mflCode') String mflCode,@JsonKey(name: 'name') String name,@JsonKey(name: 'kephLevel') String kephLevel,@JsonKey(name: 'facilityType') String facilityType,@JsonKey(name: 'owner') String owner,@JsonKey(name: 'wardId') int wardId,@JsonKey(name: 'ward') String ward,@JsonKey(name: 'subCountyId') int subCountyId,@JsonKey(name: 'subCounty') String subCounty,@JsonKey(name: 'countyId') int countyId,@JsonKey(name: 'county') String county,@JsonKey(name: 'latitude') double latitude,@JsonKey(name: 'longitude') double longitude,@JsonKey(name: 'geohash') String geohash,@JsonKey(name: 'isLocationApproximate') bool isLocationApproximate,@JsonKey(name: 'isLab') bool isLab,@JsonKey(name: 'operationStatus') String operationStatus,@JsonKey(name: 'isOperational') bool isOperational
});




}
/// @nodoc
class __$FacilityModelCopyWithImpl<$Res>
    implements _$FacilityModelCopyWith<$Res> {
  __$FacilityModelCopyWithImpl(this._self, this._then);

  final _FacilityModel _self;
  final $Res Function(_FacilityModel) _then;

/// Create a copy of FacilityModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? facilityId = null,Object? mflCode = null,Object? name = null,Object? kephLevel = null,Object? facilityType = null,Object? owner = null,Object? wardId = null,Object? ward = null,Object? subCountyId = null,Object? subCounty = null,Object? countyId = null,Object? county = null,Object? latitude = null,Object? longitude = null,Object? geohash = null,Object? isLocationApproximate = null,Object? isLab = null,Object? operationStatus = null,Object? isOperational = null,}) {
  return _then(_FacilityModel(
facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as String,mflCode: null == mflCode ? _self.mflCode : mflCode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kephLevel: null == kephLevel ? _self.kephLevel : kephLevel // ignore: cast_nullable_to_non_nullable
as String,facilityType: null == facilityType ? _self.facilityType : facilityType // ignore: cast_nullable_to_non_nullable
as String,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as String,wardId: null == wardId ? _self.wardId : wardId // ignore: cast_nullable_to_non_nullable
as int,ward: null == ward ? _self.ward : ward // ignore: cast_nullable_to_non_nullable
as String,subCountyId: null == subCountyId ? _self.subCountyId : subCountyId // ignore: cast_nullable_to_non_nullable
as int,subCounty: null == subCounty ? _self.subCounty : subCounty // ignore: cast_nullable_to_non_nullable
as String,countyId: null == countyId ? _self.countyId : countyId // ignore: cast_nullable_to_non_nullable
as int,county: null == county ? _self.county : county // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,geohash: null == geohash ? _self.geohash : geohash // ignore: cast_nullable_to_non_nullable
as String,isLocationApproximate: null == isLocationApproximate ? _self.isLocationApproximate : isLocationApproximate // ignore: cast_nullable_to_non_nullable
as bool,isLab: null == isLab ? _self.isLab : isLab // ignore: cast_nullable_to_non_nullable
as bool,operationStatus: null == operationStatus ? _self.operationStatus : operationStatus // ignore: cast_nullable_to_non_nullable
as String,isOperational: null == isOperational ? _self.isOperational : isOperational // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
