// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_measurement_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReportMeasurementModel {

@JsonKey(name: 'key') String get key;@JsonKey(name: 'unit') String get unit;@JsonKey(name: 'value') double get value;@JsonKey(name: 'precision') int get precision;
/// Create a copy of ReportMeasurementModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportMeasurementModelCopyWith<ReportMeasurementModel> get copyWith => _$ReportMeasurementModelCopyWithImpl<ReportMeasurementModel>(this as ReportMeasurementModel, _$identity);

  /// Serializes this ReportMeasurementModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportMeasurementModel&&(identical(other.key, key) || other.key == key)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.value, value) || other.value == value)&&(identical(other.precision, precision) || other.precision == precision));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,unit,value,precision);

@override
String toString() {
  return 'ReportMeasurementModel(key: $key, unit: $unit, value: $value, precision: $precision)';
}


}

/// @nodoc
abstract mixin class $ReportMeasurementModelCopyWith<$Res>  {
  factory $ReportMeasurementModelCopyWith(ReportMeasurementModel value, $Res Function(ReportMeasurementModel) _then) = _$ReportMeasurementModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'key') String key,@JsonKey(name: 'unit') String unit,@JsonKey(name: 'value') double value,@JsonKey(name: 'precision') int precision
});




}
/// @nodoc
class _$ReportMeasurementModelCopyWithImpl<$Res>
    implements $ReportMeasurementModelCopyWith<$Res> {
  _$ReportMeasurementModelCopyWithImpl(this._self, this._then);

  final ReportMeasurementModel _self;
  final $Res Function(ReportMeasurementModel) _then;

/// Create a copy of ReportMeasurementModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? unit = null,Object? value = null,Object? precision = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,precision: null == precision ? _self.precision : precision // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportMeasurementModel].
extension ReportMeasurementModelPatterns on ReportMeasurementModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportMeasurementModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportMeasurementModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportMeasurementModel value)  $default,){
final _that = this;
switch (_that) {
case _ReportMeasurementModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportMeasurementModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReportMeasurementModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'key')  String key, @JsonKey(name: 'unit')  String unit, @JsonKey(name: 'value')  double value, @JsonKey(name: 'precision')  int precision)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportMeasurementModel() when $default != null:
return $default(_that.key,_that.unit,_that.value,_that.precision);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'key')  String key, @JsonKey(name: 'unit')  String unit, @JsonKey(name: 'value')  double value, @JsonKey(name: 'precision')  int precision)  $default,) {final _that = this;
switch (_that) {
case _ReportMeasurementModel():
return $default(_that.key,_that.unit,_that.value,_that.precision);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'key')  String key, @JsonKey(name: 'unit')  String unit, @JsonKey(name: 'value')  double value, @JsonKey(name: 'precision')  int precision)?  $default,) {final _that = this;
switch (_that) {
case _ReportMeasurementModel() when $default != null:
return $default(_that.key,_that.unit,_that.value,_that.precision);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportMeasurementModel extends ReportMeasurementModel {
  const _ReportMeasurementModel({@JsonKey(name: 'key') this.key = '', @JsonKey(name: 'unit') this.unit = '', @JsonKey(name: 'value') this.value = 0, @JsonKey(name: 'precision') this.precision = 0}): super._();
  factory _ReportMeasurementModel.fromJson(Map<String, dynamic> json) => _$ReportMeasurementModelFromJson(json);

@override@JsonKey(name: 'key') final  String key;
@override@JsonKey(name: 'unit') final  String unit;
@override@JsonKey(name: 'value') final  double value;
@override@JsonKey(name: 'precision') final  int precision;

/// Create a copy of ReportMeasurementModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportMeasurementModelCopyWith<_ReportMeasurementModel> get copyWith => __$ReportMeasurementModelCopyWithImpl<_ReportMeasurementModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportMeasurementModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportMeasurementModel&&(identical(other.key, key) || other.key == key)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.value, value) || other.value == value)&&(identical(other.precision, precision) || other.precision == precision));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,unit,value,precision);

@override
String toString() {
  return 'ReportMeasurementModel(key: $key, unit: $unit, value: $value, precision: $precision)';
}


}

/// @nodoc
abstract mixin class _$ReportMeasurementModelCopyWith<$Res> implements $ReportMeasurementModelCopyWith<$Res> {
  factory _$ReportMeasurementModelCopyWith(_ReportMeasurementModel value, $Res Function(_ReportMeasurementModel) _then) = __$ReportMeasurementModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'key') String key,@JsonKey(name: 'unit') String unit,@JsonKey(name: 'value') double value,@JsonKey(name: 'precision') int precision
});




}
/// @nodoc
class __$ReportMeasurementModelCopyWithImpl<$Res>
    implements _$ReportMeasurementModelCopyWith<$Res> {
  __$ReportMeasurementModelCopyWithImpl(this._self, this._then);

  final _ReportMeasurementModel _self;
  final $Res Function(_ReportMeasurementModel) _then;

/// Create a copy of ReportMeasurementModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? unit = null,Object? value = null,Object? precision = null,}) {
  return _then(_ReportMeasurementModel(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,precision: null == precision ? _self.precision : precision // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
