// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notifiable_finding_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotifiableFindingModel {

@JsonKey(name: 'diseaseId') String get diseaseId;@JsonKey(name: 'alertRequested') bool get alertRequested;
/// Create a copy of NotifiableFindingModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotifiableFindingModelCopyWith<NotifiableFindingModel> get copyWith => _$NotifiableFindingModelCopyWithImpl<NotifiableFindingModel>(this as NotifiableFindingModel, _$identity);

  /// Serializes this NotifiableFindingModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotifiableFindingModel&&(identical(other.diseaseId, diseaseId) || other.diseaseId == diseaseId)&&(identical(other.alertRequested, alertRequested) || other.alertRequested == alertRequested));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,diseaseId,alertRequested);

@override
String toString() {
  return 'NotifiableFindingModel(diseaseId: $diseaseId, alertRequested: $alertRequested)';
}


}

/// @nodoc
abstract mixin class $NotifiableFindingModelCopyWith<$Res>  {
  factory $NotifiableFindingModelCopyWith(NotifiableFindingModel value, $Res Function(NotifiableFindingModel) _then) = _$NotifiableFindingModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'diseaseId') String diseaseId,@JsonKey(name: 'alertRequested') bool alertRequested
});




}
/// @nodoc
class _$NotifiableFindingModelCopyWithImpl<$Res>
    implements $NotifiableFindingModelCopyWith<$Res> {
  _$NotifiableFindingModelCopyWithImpl(this._self, this._then);

  final NotifiableFindingModel _self;
  final $Res Function(NotifiableFindingModel) _then;

/// Create a copy of NotifiableFindingModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? diseaseId = null,Object? alertRequested = null,}) {
  return _then(_self.copyWith(
diseaseId: null == diseaseId ? _self.diseaseId : diseaseId // ignore: cast_nullable_to_non_nullable
as String,alertRequested: null == alertRequested ? _self.alertRequested : alertRequested // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotifiableFindingModel].
extension NotifiableFindingModelPatterns on NotifiableFindingModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotifiableFindingModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotifiableFindingModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotifiableFindingModel value)  $default,){
final _that = this;
switch (_that) {
case _NotifiableFindingModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotifiableFindingModel value)?  $default,){
final _that = this;
switch (_that) {
case _NotifiableFindingModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'diseaseId')  String diseaseId, @JsonKey(name: 'alertRequested')  bool alertRequested)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotifiableFindingModel() when $default != null:
return $default(_that.diseaseId,_that.alertRequested);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'diseaseId')  String diseaseId, @JsonKey(name: 'alertRequested')  bool alertRequested)  $default,) {final _that = this;
switch (_that) {
case _NotifiableFindingModel():
return $default(_that.diseaseId,_that.alertRequested);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'diseaseId')  String diseaseId, @JsonKey(name: 'alertRequested')  bool alertRequested)?  $default,) {final _that = this;
switch (_that) {
case _NotifiableFindingModel() when $default != null:
return $default(_that.diseaseId,_that.alertRequested);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotifiableFindingModel extends NotifiableFindingModel {
  const _NotifiableFindingModel({@JsonKey(name: 'diseaseId') this.diseaseId = '', @JsonKey(name: 'alertRequested') this.alertRequested = false}): super._();
  factory _NotifiableFindingModel.fromJson(Map<String, dynamic> json) => _$NotifiableFindingModelFromJson(json);

@override@JsonKey(name: 'diseaseId') final  String diseaseId;
@override@JsonKey(name: 'alertRequested') final  bool alertRequested;

/// Create a copy of NotifiableFindingModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotifiableFindingModelCopyWith<_NotifiableFindingModel> get copyWith => __$NotifiableFindingModelCopyWithImpl<_NotifiableFindingModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotifiableFindingModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotifiableFindingModel&&(identical(other.diseaseId, diseaseId) || other.diseaseId == diseaseId)&&(identical(other.alertRequested, alertRequested) || other.alertRequested == alertRequested));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,diseaseId,alertRequested);

@override
String toString() {
  return 'NotifiableFindingModel(diseaseId: $diseaseId, alertRequested: $alertRequested)';
}


}

/// @nodoc
abstract mixin class _$NotifiableFindingModelCopyWith<$Res> implements $NotifiableFindingModelCopyWith<$Res> {
  factory _$NotifiableFindingModelCopyWith(_NotifiableFindingModel value, $Res Function(_NotifiableFindingModel) _then) = __$NotifiableFindingModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'diseaseId') String diseaseId,@JsonKey(name: 'alertRequested') bool alertRequested
});




}
/// @nodoc
class __$NotifiableFindingModelCopyWithImpl<$Res>
    implements _$NotifiableFindingModelCopyWith<$Res> {
  __$NotifiableFindingModelCopyWithImpl(this._self, this._then);

  final _NotifiableFindingModel _self;
  final $Res Function(_NotifiableFindingModel) _then;

/// Create a copy of NotifiableFindingModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? diseaseId = null,Object? alertRequested = null,}) {
  return _then(_NotifiableFindingModel(
diseaseId: null == diseaseId ? _self.diseaseId : diseaseId // ignore: cast_nullable_to_non_nullable
as String,alertRequested: null == alertRequested ? _self.alertRequested : alertRequested // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
