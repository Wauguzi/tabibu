// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lab_test_type_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LabTestTypeModel {

@JsonKey(name: 'testTypeId') String get testTypeId;@JsonKey(name: 'name') String get name;@JsonKey(name: 'testCount') int get testCount;
/// Create a copy of LabTestTypeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LabTestTypeModelCopyWith<LabTestTypeModel> get copyWith => _$LabTestTypeModelCopyWithImpl<LabTestTypeModel>(this as LabTestTypeModel, _$identity);

  /// Serializes this LabTestTypeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabTestTypeModel&&(identical(other.testTypeId, testTypeId) || other.testTypeId == testTypeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.testCount, testCount) || other.testCount == testCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,testTypeId,name,testCount);

@override
String toString() {
  return 'LabTestTypeModel(testTypeId: $testTypeId, name: $name, testCount: $testCount)';
}


}

/// @nodoc
abstract mixin class $LabTestTypeModelCopyWith<$Res>  {
  factory $LabTestTypeModelCopyWith(LabTestTypeModel value, $Res Function(LabTestTypeModel) _then) = _$LabTestTypeModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'testTypeId') String testTypeId,@JsonKey(name: 'name') String name,@JsonKey(name: 'testCount') int testCount
});




}
/// @nodoc
class _$LabTestTypeModelCopyWithImpl<$Res>
    implements $LabTestTypeModelCopyWith<$Res> {
  _$LabTestTypeModelCopyWithImpl(this._self, this._then);

  final LabTestTypeModel _self;
  final $Res Function(LabTestTypeModel) _then;

/// Create a copy of LabTestTypeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? testTypeId = null,Object? name = null,Object? testCount = null,}) {
  return _then(_self.copyWith(
testTypeId: null == testTypeId ? _self.testTypeId : testTypeId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,testCount: null == testCount ? _self.testCount : testCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LabTestTypeModel].
extension LabTestTypeModelPatterns on LabTestTypeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LabTestTypeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LabTestTypeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LabTestTypeModel value)  $default,){
final _that = this;
switch (_that) {
case _LabTestTypeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LabTestTypeModel value)?  $default,){
final _that = this;
switch (_that) {
case _LabTestTypeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'testTypeId')  String testTypeId, @JsonKey(name: 'name')  String name, @JsonKey(name: 'testCount')  int testCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LabTestTypeModel() when $default != null:
return $default(_that.testTypeId,_that.name,_that.testCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'testTypeId')  String testTypeId, @JsonKey(name: 'name')  String name, @JsonKey(name: 'testCount')  int testCount)  $default,) {final _that = this;
switch (_that) {
case _LabTestTypeModel():
return $default(_that.testTypeId,_that.name,_that.testCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'testTypeId')  String testTypeId, @JsonKey(name: 'name')  String name, @JsonKey(name: 'testCount')  int testCount)?  $default,) {final _that = this;
switch (_that) {
case _LabTestTypeModel() when $default != null:
return $default(_that.testTypeId,_that.name,_that.testCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LabTestTypeModel implements LabTestTypeModel {
  const _LabTestTypeModel({@JsonKey(name: 'testTypeId') required this.testTypeId, @JsonKey(name: 'name') required this.name, @JsonKey(name: 'testCount') required this.testCount});
  factory _LabTestTypeModel.fromJson(Map<String, dynamic> json) => _$LabTestTypeModelFromJson(json);

@override@JsonKey(name: 'testTypeId') final  String testTypeId;
@override@JsonKey(name: 'name') final  String name;
@override@JsonKey(name: 'testCount') final  int testCount;

/// Create a copy of LabTestTypeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LabTestTypeModelCopyWith<_LabTestTypeModel> get copyWith => __$LabTestTypeModelCopyWithImpl<_LabTestTypeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LabTestTypeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LabTestTypeModel&&(identical(other.testTypeId, testTypeId) || other.testTypeId == testTypeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.testCount, testCount) || other.testCount == testCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,testTypeId,name,testCount);

@override
String toString() {
  return 'LabTestTypeModel(testTypeId: $testTypeId, name: $name, testCount: $testCount)';
}


}

/// @nodoc
abstract mixin class _$LabTestTypeModelCopyWith<$Res> implements $LabTestTypeModelCopyWith<$Res> {
  factory _$LabTestTypeModelCopyWith(_LabTestTypeModel value, $Res Function(_LabTestTypeModel) _then) = __$LabTestTypeModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'testTypeId') String testTypeId,@JsonKey(name: 'name') String name,@JsonKey(name: 'testCount') int testCount
});




}
/// @nodoc
class __$LabTestTypeModelCopyWithImpl<$Res>
    implements _$LabTestTypeModelCopyWith<$Res> {
  __$LabTestTypeModelCopyWithImpl(this._self, this._then);

  final _LabTestTypeModel _self;
  final $Res Function(_LabTestTypeModel) _then;

/// Create a copy of LabTestTypeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? testTypeId = null,Object? name = null,Object? testCount = null,}) {
  return _then(_LabTestTypeModel(
testTypeId: null == testTypeId ? _self.testTypeId : testTypeId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,testCount: null == testCount ? _self.testCount : testCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
