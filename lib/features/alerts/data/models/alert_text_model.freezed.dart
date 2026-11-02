// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alert_text_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AlertTextModel {

@JsonKey(name: 'headline') String get headline;@JsonKey(name: 'body') String get body;
/// Create a copy of AlertTextModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlertTextModelCopyWith<AlertTextModel> get copyWith => _$AlertTextModelCopyWithImpl<AlertTextModel>(this as AlertTextModel, _$identity);

  /// Serializes this AlertTextModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlertTextModel&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.body, body) || other.body == body));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,headline,body);

@override
String toString() {
  return 'AlertTextModel(headline: $headline, body: $body)';
}


}

/// @nodoc
abstract mixin class $AlertTextModelCopyWith<$Res>  {
  factory $AlertTextModelCopyWith(AlertTextModel value, $Res Function(AlertTextModel) _then) = _$AlertTextModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'headline') String headline,@JsonKey(name: 'body') String body
});




}
/// @nodoc
class _$AlertTextModelCopyWithImpl<$Res>
    implements $AlertTextModelCopyWith<$Res> {
  _$AlertTextModelCopyWithImpl(this._self, this._then);

  final AlertTextModel _self;
  final $Res Function(AlertTextModel) _then;

/// Create a copy of AlertTextModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? headline = null,Object? body = null,}) {
  return _then(_self.copyWith(
headline: null == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AlertTextModel].
extension AlertTextModelPatterns on AlertTextModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlertTextModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlertTextModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlertTextModel value)  $default,){
final _that = this;
switch (_that) {
case _AlertTextModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlertTextModel value)?  $default,){
final _that = this;
switch (_that) {
case _AlertTextModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'headline')  String headline, @JsonKey(name: 'body')  String body)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlertTextModel() when $default != null:
return $default(_that.headline,_that.body);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'headline')  String headline, @JsonKey(name: 'body')  String body)  $default,) {final _that = this;
switch (_that) {
case _AlertTextModel():
return $default(_that.headline,_that.body);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'headline')  String headline, @JsonKey(name: 'body')  String body)?  $default,) {final _that = this;
switch (_that) {
case _AlertTextModel() when $default != null:
return $default(_that.headline,_that.body);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AlertTextModel extends AlertTextModel {
  const _AlertTextModel({@JsonKey(name: 'headline') this.headline = '', @JsonKey(name: 'body') this.body = ''}): super._();
  factory _AlertTextModel.fromJson(Map<String, dynamic> json) => _$AlertTextModelFromJson(json);

@override@JsonKey(name: 'headline') final  String headline;
@override@JsonKey(name: 'body') final  String body;

/// Create a copy of AlertTextModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlertTextModelCopyWith<_AlertTextModel> get copyWith => __$AlertTextModelCopyWithImpl<_AlertTextModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AlertTextModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlertTextModel&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.body, body) || other.body == body));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,headline,body);

@override
String toString() {
  return 'AlertTextModel(headline: $headline, body: $body)';
}


}

/// @nodoc
abstract mixin class _$AlertTextModelCopyWith<$Res> implements $AlertTextModelCopyWith<$Res> {
  factory _$AlertTextModelCopyWith(_AlertTextModel value, $Res Function(_AlertTextModel) _then) = __$AlertTextModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'headline') String headline,@JsonKey(name: 'body') String body
});




}
/// @nodoc
class __$AlertTextModelCopyWithImpl<$Res>
    implements _$AlertTextModelCopyWith<$Res> {
  __$AlertTextModelCopyWithImpl(this._self, this._then);

  final _AlertTextModel _self;
  final $Res Function(_AlertTextModel) _then;

/// Create a copy of AlertTextModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? headline = null,Object? body = null,}) {
  return _then(_AlertTextModel(
headline: null == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
