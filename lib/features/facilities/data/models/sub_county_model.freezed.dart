// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sub_county_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubCountyModel {

@JsonKey(name: 'id') int get id;@JsonKey(name: 'name') String get name;@JsonKey(name: 'countyId') int get countyId;@JsonKey(name: 'latitude') double get latitude;@JsonKey(name: 'longitude') double get longitude;@JsonKey(name: 'geohash') String get geohash;
/// Create a copy of SubCountyModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubCountyModelCopyWith<SubCountyModel> get copyWith => _$SubCountyModelCopyWithImpl<SubCountyModel>(this as SubCountyModel, _$identity);

  /// Serializes this SubCountyModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubCountyModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.countyId, countyId) || other.countyId == countyId)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.geohash, geohash) || other.geohash == geohash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,countyId,latitude,longitude,geohash);

@override
String toString() {
  return 'SubCountyModel(id: $id, name: $name, countyId: $countyId, latitude: $latitude, longitude: $longitude, geohash: $geohash)';
}


}

/// @nodoc
abstract mixin class $SubCountyModelCopyWith<$Res>  {
  factory $SubCountyModelCopyWith(SubCountyModel value, $Res Function(SubCountyModel) _then) = _$SubCountyModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') int id,@JsonKey(name: 'name') String name,@JsonKey(name: 'countyId') int countyId,@JsonKey(name: 'latitude') double latitude,@JsonKey(name: 'longitude') double longitude,@JsonKey(name: 'geohash') String geohash
});




}
/// @nodoc
class _$SubCountyModelCopyWithImpl<$Res>
    implements $SubCountyModelCopyWith<$Res> {
  _$SubCountyModelCopyWithImpl(this._self, this._then);

  final SubCountyModel _self;
  final $Res Function(SubCountyModel) _then;

/// Create a copy of SubCountyModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? countyId = null,Object? latitude = null,Object? longitude = null,Object? geohash = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,countyId: null == countyId ? _self.countyId : countyId // ignore: cast_nullable_to_non_nullable
as int,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,geohash: null == geohash ? _self.geohash : geohash // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SubCountyModel].
extension SubCountyModelPatterns on SubCountyModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubCountyModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubCountyModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubCountyModel value)  $default,){
final _that = this;
switch (_that) {
case _SubCountyModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubCountyModel value)?  $default,){
final _that = this;
switch (_that) {
case _SubCountyModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  int id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'countyId')  int countyId, @JsonKey(name: 'latitude')  double latitude, @JsonKey(name: 'longitude')  double longitude, @JsonKey(name: 'geohash')  String geohash)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubCountyModel() when $default != null:
return $default(_that.id,_that.name,_that.countyId,_that.latitude,_that.longitude,_that.geohash);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  int id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'countyId')  int countyId, @JsonKey(name: 'latitude')  double latitude, @JsonKey(name: 'longitude')  double longitude, @JsonKey(name: 'geohash')  String geohash)  $default,) {final _that = this;
switch (_that) {
case _SubCountyModel():
return $default(_that.id,_that.name,_that.countyId,_that.latitude,_that.longitude,_that.geohash);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  int id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'countyId')  int countyId, @JsonKey(name: 'latitude')  double latitude, @JsonKey(name: 'longitude')  double longitude, @JsonKey(name: 'geohash')  String geohash)?  $default,) {final _that = this;
switch (_that) {
case _SubCountyModel() when $default != null:
return $default(_that.id,_that.name,_that.countyId,_that.latitude,_that.longitude,_that.geohash);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubCountyModel implements SubCountyModel {
  const _SubCountyModel({@JsonKey(name: 'id') required this.id, @JsonKey(name: 'name') required this.name, @JsonKey(name: 'countyId') required this.countyId, @JsonKey(name: 'latitude') required this.latitude, @JsonKey(name: 'longitude') required this.longitude, @JsonKey(name: 'geohash') required this.geohash});
  factory _SubCountyModel.fromJson(Map<String, dynamic> json) => _$SubCountyModelFromJson(json);

@override@JsonKey(name: 'id') final  int id;
@override@JsonKey(name: 'name') final  String name;
@override@JsonKey(name: 'countyId') final  int countyId;
@override@JsonKey(name: 'latitude') final  double latitude;
@override@JsonKey(name: 'longitude') final  double longitude;
@override@JsonKey(name: 'geohash') final  String geohash;

/// Create a copy of SubCountyModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubCountyModelCopyWith<_SubCountyModel> get copyWith => __$SubCountyModelCopyWithImpl<_SubCountyModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubCountyModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubCountyModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.countyId, countyId) || other.countyId == countyId)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.geohash, geohash) || other.geohash == geohash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,countyId,latitude,longitude,geohash);

@override
String toString() {
  return 'SubCountyModel(id: $id, name: $name, countyId: $countyId, latitude: $latitude, longitude: $longitude, geohash: $geohash)';
}


}

/// @nodoc
abstract mixin class _$SubCountyModelCopyWith<$Res> implements $SubCountyModelCopyWith<$Res> {
  factory _$SubCountyModelCopyWith(_SubCountyModel value, $Res Function(_SubCountyModel) _then) = __$SubCountyModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') int id,@JsonKey(name: 'name') String name,@JsonKey(name: 'countyId') int countyId,@JsonKey(name: 'latitude') double latitude,@JsonKey(name: 'longitude') double longitude,@JsonKey(name: 'geohash') String geohash
});




}
/// @nodoc
class __$SubCountyModelCopyWithImpl<$Res>
    implements _$SubCountyModelCopyWith<$Res> {
  __$SubCountyModelCopyWithImpl(this._self, this._then);

  final _SubCountyModel _self;
  final $Res Function(_SubCountyModel) _then;

/// Create a copy of SubCountyModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? countyId = null,Object? latitude = null,Object? longitude = null,Object? geohash = null,}) {
  return _then(_SubCountyModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,countyId: null == countyId ? _self.countyId : countyId // ignore: cast_nullable_to_non_nullable
as int,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,geohash: null == geohash ? _self.geohash : geohash // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
