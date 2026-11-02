// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_field_diff_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReportFieldDiffModel {

@JsonKey(name: 'field') String get field;@JsonKey(name: 'change') String get change;@JsonKey(name: 'baseValue') String get baseValue;@JsonKey(name: 'finalValue') String get finalValue;@JsonKey(name: 'similarity') double get similarity;
/// Create a copy of ReportFieldDiffModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportFieldDiffModelCopyWith<ReportFieldDiffModel> get copyWith => _$ReportFieldDiffModelCopyWithImpl<ReportFieldDiffModel>(this as ReportFieldDiffModel, _$identity);

  /// Serializes this ReportFieldDiffModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportFieldDiffModel&&(identical(other.field, field) || other.field == field)&&(identical(other.change, change) || other.change == change)&&(identical(other.baseValue, baseValue) || other.baseValue == baseValue)&&(identical(other.finalValue, finalValue) || other.finalValue == finalValue)&&(identical(other.similarity, similarity) || other.similarity == similarity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,field,change,baseValue,finalValue,similarity);

@override
String toString() {
  return 'ReportFieldDiffModel(field: $field, change: $change, baseValue: $baseValue, finalValue: $finalValue, similarity: $similarity)';
}


}

/// @nodoc
abstract mixin class $ReportFieldDiffModelCopyWith<$Res>  {
  factory $ReportFieldDiffModelCopyWith(ReportFieldDiffModel value, $Res Function(ReportFieldDiffModel) _then) = _$ReportFieldDiffModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'field') String field,@JsonKey(name: 'change') String change,@JsonKey(name: 'baseValue') String baseValue,@JsonKey(name: 'finalValue') String finalValue,@JsonKey(name: 'similarity') double similarity
});




}
/// @nodoc
class _$ReportFieldDiffModelCopyWithImpl<$Res>
    implements $ReportFieldDiffModelCopyWith<$Res> {
  _$ReportFieldDiffModelCopyWithImpl(this._self, this._then);

  final ReportFieldDiffModel _self;
  final $Res Function(ReportFieldDiffModel) _then;

/// Create a copy of ReportFieldDiffModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? field = null,Object? change = null,Object? baseValue = null,Object? finalValue = null,Object? similarity = null,}) {
  return _then(_self.copyWith(
field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String,change: null == change ? _self.change : change // ignore: cast_nullable_to_non_nullable
as String,baseValue: null == baseValue ? _self.baseValue : baseValue // ignore: cast_nullable_to_non_nullable
as String,finalValue: null == finalValue ? _self.finalValue : finalValue // ignore: cast_nullable_to_non_nullable
as String,similarity: null == similarity ? _self.similarity : similarity // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportFieldDiffModel].
extension ReportFieldDiffModelPatterns on ReportFieldDiffModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportFieldDiffModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportFieldDiffModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportFieldDiffModel value)  $default,){
final _that = this;
switch (_that) {
case _ReportFieldDiffModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportFieldDiffModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReportFieldDiffModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'field')  String field, @JsonKey(name: 'change')  String change, @JsonKey(name: 'baseValue')  String baseValue, @JsonKey(name: 'finalValue')  String finalValue, @JsonKey(name: 'similarity')  double similarity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportFieldDiffModel() when $default != null:
return $default(_that.field,_that.change,_that.baseValue,_that.finalValue,_that.similarity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'field')  String field, @JsonKey(name: 'change')  String change, @JsonKey(name: 'baseValue')  String baseValue, @JsonKey(name: 'finalValue')  String finalValue, @JsonKey(name: 'similarity')  double similarity)  $default,) {final _that = this;
switch (_that) {
case _ReportFieldDiffModel():
return $default(_that.field,_that.change,_that.baseValue,_that.finalValue,_that.similarity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'field')  String field, @JsonKey(name: 'change')  String change, @JsonKey(name: 'baseValue')  String baseValue, @JsonKey(name: 'finalValue')  String finalValue, @JsonKey(name: 'similarity')  double similarity)?  $default,) {final _that = this;
switch (_that) {
case _ReportFieldDiffModel() when $default != null:
return $default(_that.field,_that.change,_that.baseValue,_that.finalValue,_that.similarity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportFieldDiffModel extends ReportFieldDiffModel {
  const _ReportFieldDiffModel({@JsonKey(name: 'field') this.field = '', @JsonKey(name: 'change') this.change = '', @JsonKey(name: 'baseValue') this.baseValue = '', @JsonKey(name: 'finalValue') this.finalValue = '', @JsonKey(name: 'similarity') this.similarity = 0}): super._();
  factory _ReportFieldDiffModel.fromJson(Map<String, dynamic> json) => _$ReportFieldDiffModelFromJson(json);

@override@JsonKey(name: 'field') final  String field;
@override@JsonKey(name: 'change') final  String change;
@override@JsonKey(name: 'baseValue') final  String baseValue;
@override@JsonKey(name: 'finalValue') final  String finalValue;
@override@JsonKey(name: 'similarity') final  double similarity;

/// Create a copy of ReportFieldDiffModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportFieldDiffModelCopyWith<_ReportFieldDiffModel> get copyWith => __$ReportFieldDiffModelCopyWithImpl<_ReportFieldDiffModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportFieldDiffModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportFieldDiffModel&&(identical(other.field, field) || other.field == field)&&(identical(other.change, change) || other.change == change)&&(identical(other.baseValue, baseValue) || other.baseValue == baseValue)&&(identical(other.finalValue, finalValue) || other.finalValue == finalValue)&&(identical(other.similarity, similarity) || other.similarity == similarity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,field,change,baseValue,finalValue,similarity);

@override
String toString() {
  return 'ReportFieldDiffModel(field: $field, change: $change, baseValue: $baseValue, finalValue: $finalValue, similarity: $similarity)';
}


}

/// @nodoc
abstract mixin class _$ReportFieldDiffModelCopyWith<$Res> implements $ReportFieldDiffModelCopyWith<$Res> {
  factory _$ReportFieldDiffModelCopyWith(_ReportFieldDiffModel value, $Res Function(_ReportFieldDiffModel) _then) = __$ReportFieldDiffModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'field') String field,@JsonKey(name: 'change') String change,@JsonKey(name: 'baseValue') String baseValue,@JsonKey(name: 'finalValue') String finalValue,@JsonKey(name: 'similarity') double similarity
});




}
/// @nodoc
class __$ReportFieldDiffModelCopyWithImpl<$Res>
    implements _$ReportFieldDiffModelCopyWith<$Res> {
  __$ReportFieldDiffModelCopyWithImpl(this._self, this._then);

  final _ReportFieldDiffModel _self;
  final $Res Function(_ReportFieldDiffModel) _then;

/// Create a copy of ReportFieldDiffModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field = null,Object? change = null,Object? baseValue = null,Object? finalValue = null,Object? similarity = null,}) {
  return _then(_ReportFieldDiffModel(
field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String,change: null == change ? _self.change : change // ignore: cast_nullable_to_non_nullable
as String,baseValue: null == baseValue ? _self.baseValue : baseValue // ignore: cast_nullable_to_non_nullable
as String,finalValue: null == finalValue ? _self.finalValue : finalValue // ignore: cast_nullable_to_non_nullable
as String,similarity: null == similarity ? _self.similarity : similarity // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
