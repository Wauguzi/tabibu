// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'insurer_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InsurerModel {

@JsonKey(name: 'insurerId') String get insurerId;@JsonKey(name: 'name') String get name;@JsonKey(name: 'type') String get type;
/// Create a copy of InsurerModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InsurerModelCopyWith<InsurerModel> get copyWith => _$InsurerModelCopyWithImpl<InsurerModel>(this as InsurerModel, _$identity);

  /// Serializes this InsurerModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InsurerModel&&(identical(other.insurerId, insurerId) || other.insurerId == insurerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,insurerId,name,type);

@override
String toString() {
  return 'InsurerModel(insurerId: $insurerId, name: $name, type: $type)';
}


}

/// @nodoc
abstract mixin class $InsurerModelCopyWith<$Res>  {
  factory $InsurerModelCopyWith(InsurerModel value, $Res Function(InsurerModel) _then) = _$InsurerModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'insurerId') String insurerId,@JsonKey(name: 'name') String name,@JsonKey(name: 'type') String type
});




}
/// @nodoc
class _$InsurerModelCopyWithImpl<$Res>
    implements $InsurerModelCopyWith<$Res> {
  _$InsurerModelCopyWithImpl(this._self, this._then);

  final InsurerModel _self;
  final $Res Function(InsurerModel) _then;

/// Create a copy of InsurerModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? insurerId = null,Object? name = null,Object? type = null,}) {
  return _then(_self.copyWith(
insurerId: null == insurerId ? _self.insurerId : insurerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [InsurerModel].
extension InsurerModelPatterns on InsurerModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InsurerModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InsurerModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InsurerModel value)  $default,){
final _that = this;
switch (_that) {
case _InsurerModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InsurerModel value)?  $default,){
final _that = this;
switch (_that) {
case _InsurerModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'insurerId')  String insurerId, @JsonKey(name: 'name')  String name, @JsonKey(name: 'type')  String type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InsurerModel() when $default != null:
return $default(_that.insurerId,_that.name,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'insurerId')  String insurerId, @JsonKey(name: 'name')  String name, @JsonKey(name: 'type')  String type)  $default,) {final _that = this;
switch (_that) {
case _InsurerModel():
return $default(_that.insurerId,_that.name,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'insurerId')  String insurerId, @JsonKey(name: 'name')  String name, @JsonKey(name: 'type')  String type)?  $default,) {final _that = this;
switch (_that) {
case _InsurerModel() when $default != null:
return $default(_that.insurerId,_that.name,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InsurerModel implements InsurerModel {
  const _InsurerModel({@JsonKey(name: 'insurerId') required this.insurerId, @JsonKey(name: 'name') required this.name, @JsonKey(name: 'type') required this.type});
  factory _InsurerModel.fromJson(Map<String, dynamic> json) => _$InsurerModelFromJson(json);

@override@JsonKey(name: 'insurerId') final  String insurerId;
@override@JsonKey(name: 'name') final  String name;
@override@JsonKey(name: 'type') final  String type;

/// Create a copy of InsurerModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InsurerModelCopyWith<_InsurerModel> get copyWith => __$InsurerModelCopyWithImpl<_InsurerModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InsurerModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InsurerModel&&(identical(other.insurerId, insurerId) || other.insurerId == insurerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,insurerId,name,type);

@override
String toString() {
  return 'InsurerModel(insurerId: $insurerId, name: $name, type: $type)';
}


}

/// @nodoc
abstract mixin class _$InsurerModelCopyWith<$Res> implements $InsurerModelCopyWith<$Res> {
  factory _$InsurerModelCopyWith(_InsurerModel value, $Res Function(_InsurerModel) _then) = __$InsurerModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'insurerId') String insurerId,@JsonKey(name: 'name') String name,@JsonKey(name: 'type') String type
});




}
/// @nodoc
class __$InsurerModelCopyWithImpl<$Res>
    implements _$InsurerModelCopyWith<$Res> {
  __$InsurerModelCopyWithImpl(this._self, this._then);

  final _InsurerModel _self;
  final $Res Function(_InsurerModel) _then;

/// Create a copy of InsurerModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? insurerId = null,Object? name = null,Object? type = null,}) {
  return _then(_InsurerModel(
insurerId: null == insurerId ? _self.insurerId : insurerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
