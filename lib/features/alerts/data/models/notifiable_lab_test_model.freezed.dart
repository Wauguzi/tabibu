// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notifiable_lab_test_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotifiableLabTestModel {

@JsonKey(name: 'labTestId') String get labTestId;@JsonKey(name: 'name') String get name;@JsonKey(name: 'strength') String get strength;@JsonKey(name: 'mappingVerified') bool get mappingVerified;
/// Create a copy of NotifiableLabTestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotifiableLabTestModelCopyWith<NotifiableLabTestModel> get copyWith => _$NotifiableLabTestModelCopyWithImpl<NotifiableLabTestModel>(this as NotifiableLabTestModel, _$identity);

  /// Serializes this NotifiableLabTestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotifiableLabTestModel&&(identical(other.labTestId, labTestId) || other.labTestId == labTestId)&&(identical(other.name, name) || other.name == name)&&(identical(other.strength, strength) || other.strength == strength)&&(identical(other.mappingVerified, mappingVerified) || other.mappingVerified == mappingVerified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,labTestId,name,strength,mappingVerified);

@override
String toString() {
  return 'NotifiableLabTestModel(labTestId: $labTestId, name: $name, strength: $strength, mappingVerified: $mappingVerified)';
}


}

/// @nodoc
abstract mixin class $NotifiableLabTestModelCopyWith<$Res>  {
  factory $NotifiableLabTestModelCopyWith(NotifiableLabTestModel value, $Res Function(NotifiableLabTestModel) _then) = _$NotifiableLabTestModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'labTestId') String labTestId,@JsonKey(name: 'name') String name,@JsonKey(name: 'strength') String strength,@JsonKey(name: 'mappingVerified') bool mappingVerified
});




}
/// @nodoc
class _$NotifiableLabTestModelCopyWithImpl<$Res>
    implements $NotifiableLabTestModelCopyWith<$Res> {
  _$NotifiableLabTestModelCopyWithImpl(this._self, this._then);

  final NotifiableLabTestModel _self;
  final $Res Function(NotifiableLabTestModel) _then;

/// Create a copy of NotifiableLabTestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? labTestId = null,Object? name = null,Object? strength = null,Object? mappingVerified = null,}) {
  return _then(_self.copyWith(
labTestId: null == labTestId ? _self.labTestId : labTestId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,strength: null == strength ? _self.strength : strength // ignore: cast_nullable_to_non_nullable
as String,mappingVerified: null == mappingVerified ? _self.mappingVerified : mappingVerified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotifiableLabTestModel].
extension NotifiableLabTestModelPatterns on NotifiableLabTestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotifiableLabTestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotifiableLabTestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotifiableLabTestModel value)  $default,){
final _that = this;
switch (_that) {
case _NotifiableLabTestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotifiableLabTestModel value)?  $default,){
final _that = this;
switch (_that) {
case _NotifiableLabTestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'labTestId')  String labTestId, @JsonKey(name: 'name')  String name, @JsonKey(name: 'strength')  String strength, @JsonKey(name: 'mappingVerified')  bool mappingVerified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotifiableLabTestModel() when $default != null:
return $default(_that.labTestId,_that.name,_that.strength,_that.mappingVerified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'labTestId')  String labTestId, @JsonKey(name: 'name')  String name, @JsonKey(name: 'strength')  String strength, @JsonKey(name: 'mappingVerified')  bool mappingVerified)  $default,) {final _that = this;
switch (_that) {
case _NotifiableLabTestModel():
return $default(_that.labTestId,_that.name,_that.strength,_that.mappingVerified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'labTestId')  String labTestId, @JsonKey(name: 'name')  String name, @JsonKey(name: 'strength')  String strength, @JsonKey(name: 'mappingVerified')  bool mappingVerified)?  $default,) {final _that = this;
switch (_that) {
case _NotifiableLabTestModel() when $default != null:
return $default(_that.labTestId,_that.name,_that.strength,_that.mappingVerified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotifiableLabTestModel extends NotifiableLabTestModel {
  const _NotifiableLabTestModel({@JsonKey(name: 'labTestId') this.labTestId = '', @JsonKey(name: 'name') this.name = '', @JsonKey(name: 'strength') this.strength = 'Uncertain', @JsonKey(name: 'mappingVerified') this.mappingVerified = false}): super._();
  factory _NotifiableLabTestModel.fromJson(Map<String, dynamic> json) => _$NotifiableLabTestModelFromJson(json);

@override@JsonKey(name: 'labTestId') final  String labTestId;
@override@JsonKey(name: 'name') final  String name;
@override@JsonKey(name: 'strength') final  String strength;
@override@JsonKey(name: 'mappingVerified') final  bool mappingVerified;

/// Create a copy of NotifiableLabTestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotifiableLabTestModelCopyWith<_NotifiableLabTestModel> get copyWith => __$NotifiableLabTestModelCopyWithImpl<_NotifiableLabTestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotifiableLabTestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotifiableLabTestModel&&(identical(other.labTestId, labTestId) || other.labTestId == labTestId)&&(identical(other.name, name) || other.name == name)&&(identical(other.strength, strength) || other.strength == strength)&&(identical(other.mappingVerified, mappingVerified) || other.mappingVerified == mappingVerified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,labTestId,name,strength,mappingVerified);

@override
String toString() {
  return 'NotifiableLabTestModel(labTestId: $labTestId, name: $name, strength: $strength, mappingVerified: $mappingVerified)';
}


}

/// @nodoc
abstract mixin class _$NotifiableLabTestModelCopyWith<$Res> implements $NotifiableLabTestModelCopyWith<$Res> {
  factory _$NotifiableLabTestModelCopyWith(_NotifiableLabTestModel value, $Res Function(_NotifiableLabTestModel) _then) = __$NotifiableLabTestModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'labTestId') String labTestId,@JsonKey(name: 'name') String name,@JsonKey(name: 'strength') String strength,@JsonKey(name: 'mappingVerified') bool mappingVerified
});




}
/// @nodoc
class __$NotifiableLabTestModelCopyWithImpl<$Res>
    implements _$NotifiableLabTestModelCopyWith<$Res> {
  __$NotifiableLabTestModelCopyWithImpl(this._self, this._then);

  final _NotifiableLabTestModel _self;
  final $Res Function(_NotifiableLabTestModel) _then;

/// Create a copy of NotifiableLabTestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? labTestId = null,Object? name = null,Object? strength = null,Object? mappingVerified = null,}) {
  return _then(_NotifiableLabTestModel(
labTestId: null == labTestId ? _self.labTestId : labTestId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,strength: null == strength ? _self.strength : strength // ignore: cast_nullable_to_non_nullable
as String,mappingVerified: null == mappingVerified ? _self.mappingVerified : mappingVerified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
