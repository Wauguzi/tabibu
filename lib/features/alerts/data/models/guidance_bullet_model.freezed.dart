// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'guidance_bullet_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GuidanceBulletModel {

@JsonKey(name: 'bulletId') String get bulletId;@JsonKey(name: 'audience') String get audience;@JsonKey(name: 'textEn') String get textEn;@JsonKey(name: 'textSw') String get textSw;@JsonKey(name: 'swIsOfficial') bool get swIsOfficial;@JsonKey(name: 'sourceId') String get sourceId;
/// Create a copy of GuidanceBulletModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuidanceBulletModelCopyWith<GuidanceBulletModel> get copyWith => _$GuidanceBulletModelCopyWithImpl<GuidanceBulletModel>(this as GuidanceBulletModel, _$identity);

  /// Serializes this GuidanceBulletModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuidanceBulletModel&&(identical(other.bulletId, bulletId) || other.bulletId == bulletId)&&(identical(other.audience, audience) || other.audience == audience)&&(identical(other.textEn, textEn) || other.textEn == textEn)&&(identical(other.textSw, textSw) || other.textSw == textSw)&&(identical(other.swIsOfficial, swIsOfficial) || other.swIsOfficial == swIsOfficial)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bulletId,audience,textEn,textSw,swIsOfficial,sourceId);

@override
String toString() {
  return 'GuidanceBulletModel(bulletId: $bulletId, audience: $audience, textEn: $textEn, textSw: $textSw, swIsOfficial: $swIsOfficial, sourceId: $sourceId)';
}


}

/// @nodoc
abstract mixin class $GuidanceBulletModelCopyWith<$Res>  {
  factory $GuidanceBulletModelCopyWith(GuidanceBulletModel value, $Res Function(GuidanceBulletModel) _then) = _$GuidanceBulletModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'bulletId') String bulletId,@JsonKey(name: 'audience') String audience,@JsonKey(name: 'textEn') String textEn,@JsonKey(name: 'textSw') String textSw,@JsonKey(name: 'swIsOfficial') bool swIsOfficial,@JsonKey(name: 'sourceId') String sourceId
});




}
/// @nodoc
class _$GuidanceBulletModelCopyWithImpl<$Res>
    implements $GuidanceBulletModelCopyWith<$Res> {
  _$GuidanceBulletModelCopyWithImpl(this._self, this._then);

  final GuidanceBulletModel _self;
  final $Res Function(GuidanceBulletModel) _then;

/// Create a copy of GuidanceBulletModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bulletId = null,Object? audience = null,Object? textEn = null,Object? textSw = null,Object? swIsOfficial = null,Object? sourceId = null,}) {
  return _then(_self.copyWith(
bulletId: null == bulletId ? _self.bulletId : bulletId // ignore: cast_nullable_to_non_nullable
as String,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as String,textEn: null == textEn ? _self.textEn : textEn // ignore: cast_nullable_to_non_nullable
as String,textSw: null == textSw ? _self.textSw : textSw // ignore: cast_nullable_to_non_nullable
as String,swIsOfficial: null == swIsOfficial ? _self.swIsOfficial : swIsOfficial // ignore: cast_nullable_to_non_nullable
as bool,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GuidanceBulletModel].
extension GuidanceBulletModelPatterns on GuidanceBulletModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuidanceBulletModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuidanceBulletModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuidanceBulletModel value)  $default,){
final _that = this;
switch (_that) {
case _GuidanceBulletModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuidanceBulletModel value)?  $default,){
final _that = this;
switch (_that) {
case _GuidanceBulletModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'bulletId')  String bulletId, @JsonKey(name: 'audience')  String audience, @JsonKey(name: 'textEn')  String textEn, @JsonKey(name: 'textSw')  String textSw, @JsonKey(name: 'swIsOfficial')  bool swIsOfficial, @JsonKey(name: 'sourceId')  String sourceId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuidanceBulletModel() when $default != null:
return $default(_that.bulletId,_that.audience,_that.textEn,_that.textSw,_that.swIsOfficial,_that.sourceId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'bulletId')  String bulletId, @JsonKey(name: 'audience')  String audience, @JsonKey(name: 'textEn')  String textEn, @JsonKey(name: 'textSw')  String textSw, @JsonKey(name: 'swIsOfficial')  bool swIsOfficial, @JsonKey(name: 'sourceId')  String sourceId)  $default,) {final _that = this;
switch (_that) {
case _GuidanceBulletModel():
return $default(_that.bulletId,_that.audience,_that.textEn,_that.textSw,_that.swIsOfficial,_that.sourceId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'bulletId')  String bulletId, @JsonKey(name: 'audience')  String audience, @JsonKey(name: 'textEn')  String textEn, @JsonKey(name: 'textSw')  String textSw, @JsonKey(name: 'swIsOfficial')  bool swIsOfficial, @JsonKey(name: 'sourceId')  String sourceId)?  $default,) {final _that = this;
switch (_that) {
case _GuidanceBulletModel() when $default != null:
return $default(_that.bulletId,_that.audience,_that.textEn,_that.textSw,_that.swIsOfficial,_that.sourceId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GuidanceBulletModel extends GuidanceBulletModel {
  const _GuidanceBulletModel({@JsonKey(name: 'bulletId') this.bulletId = '', @JsonKey(name: 'audience') this.audience = 'Patient', @JsonKey(name: 'textEn') this.textEn = '', @JsonKey(name: 'textSw') this.textSw = '', @JsonKey(name: 'swIsOfficial') this.swIsOfficial = false, @JsonKey(name: 'sourceId') this.sourceId = ''}): super._();
  factory _GuidanceBulletModel.fromJson(Map<String, dynamic> json) => _$GuidanceBulletModelFromJson(json);

@override@JsonKey(name: 'bulletId') final  String bulletId;
@override@JsonKey(name: 'audience') final  String audience;
@override@JsonKey(name: 'textEn') final  String textEn;
@override@JsonKey(name: 'textSw') final  String textSw;
@override@JsonKey(name: 'swIsOfficial') final  bool swIsOfficial;
@override@JsonKey(name: 'sourceId') final  String sourceId;

/// Create a copy of GuidanceBulletModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuidanceBulletModelCopyWith<_GuidanceBulletModel> get copyWith => __$GuidanceBulletModelCopyWithImpl<_GuidanceBulletModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuidanceBulletModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuidanceBulletModel&&(identical(other.bulletId, bulletId) || other.bulletId == bulletId)&&(identical(other.audience, audience) || other.audience == audience)&&(identical(other.textEn, textEn) || other.textEn == textEn)&&(identical(other.textSw, textSw) || other.textSw == textSw)&&(identical(other.swIsOfficial, swIsOfficial) || other.swIsOfficial == swIsOfficial)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bulletId,audience,textEn,textSw,swIsOfficial,sourceId);

@override
String toString() {
  return 'GuidanceBulletModel(bulletId: $bulletId, audience: $audience, textEn: $textEn, textSw: $textSw, swIsOfficial: $swIsOfficial, sourceId: $sourceId)';
}


}

/// @nodoc
abstract mixin class _$GuidanceBulletModelCopyWith<$Res> implements $GuidanceBulletModelCopyWith<$Res> {
  factory _$GuidanceBulletModelCopyWith(_GuidanceBulletModel value, $Res Function(_GuidanceBulletModel) _then) = __$GuidanceBulletModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'bulletId') String bulletId,@JsonKey(name: 'audience') String audience,@JsonKey(name: 'textEn') String textEn,@JsonKey(name: 'textSw') String textSw,@JsonKey(name: 'swIsOfficial') bool swIsOfficial,@JsonKey(name: 'sourceId') String sourceId
});




}
/// @nodoc
class __$GuidanceBulletModelCopyWithImpl<$Res>
    implements _$GuidanceBulletModelCopyWith<$Res> {
  __$GuidanceBulletModelCopyWithImpl(this._self, this._then);

  final _GuidanceBulletModel _self;
  final $Res Function(_GuidanceBulletModel) _then;

/// Create a copy of GuidanceBulletModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bulletId = null,Object? audience = null,Object? textEn = null,Object? textSw = null,Object? swIsOfficial = null,Object? sourceId = null,}) {
  return _then(_GuidanceBulletModel(
bulletId: null == bulletId ? _self.bulletId : bulletId // ignore: cast_nullable_to_non_nullable
as String,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as String,textEn: null == textEn ? _self.textEn : textEn // ignore: cast_nullable_to_non_nullable
as String,textSw: null == textSw ? _self.textSw : textSw // ignore: cast_nullable_to_non_nullable
as String,swIsOfficial: null == swIsOfficial ? _self.swIsOfficial : swIsOfficial // ignore: cast_nullable_to_non_nullable
as bool,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
