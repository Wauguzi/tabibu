// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_metadata_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationMetadataModel {

@JsonKey(name: 'actionType') String get actionType;@JsonKey(name: 'actionStatus') String get actionStatus;@JsonKey(name: 'actionedByUid') String get actionedByUid;@JsonKey(name: 'actionedAt') String get actionedAt;@JsonKey(name: 'expiresAt') String get expiresAt;@JsonKey(name: 'deepLink') String get deepLink;@JsonKey(name: 'shareCode') String get shareCode;@JsonKey(name: 'extras') Map<String, String> get extras;
/// Create a copy of NotificationMetadataModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationMetadataModelCopyWith<NotificationMetadataModel> get copyWith => _$NotificationMetadataModelCopyWithImpl<NotificationMetadataModel>(this as NotificationMetadataModel, _$identity);

  /// Serializes this NotificationMetadataModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationMetadataModel&&(identical(other.actionType, actionType) || other.actionType == actionType)&&(identical(other.actionStatus, actionStatus) || other.actionStatus == actionStatus)&&(identical(other.actionedByUid, actionedByUid) || other.actionedByUid == actionedByUid)&&(identical(other.actionedAt, actionedAt) || other.actionedAt == actionedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.deepLink, deepLink) || other.deepLink == deepLink)&&(identical(other.shareCode, shareCode) || other.shareCode == shareCode)&&const DeepCollectionEquality().equals(other.extras, extras));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,actionType,actionStatus,actionedByUid,actionedAt,expiresAt,deepLink,shareCode,const DeepCollectionEquality().hash(extras));



}

/// @nodoc
abstract mixin class $NotificationMetadataModelCopyWith<$Res>  {
  factory $NotificationMetadataModelCopyWith(NotificationMetadataModel value, $Res Function(NotificationMetadataModel) _then) = _$NotificationMetadataModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'actionType') String actionType,@JsonKey(name: 'actionStatus') String actionStatus,@JsonKey(name: 'actionedByUid') String actionedByUid,@JsonKey(name: 'actionedAt') String actionedAt,@JsonKey(name: 'expiresAt') String expiresAt,@JsonKey(name: 'deepLink') String deepLink,@JsonKey(name: 'shareCode') String shareCode,@JsonKey(name: 'extras') Map<String, String> extras
});




}
/// @nodoc
class _$NotificationMetadataModelCopyWithImpl<$Res>
    implements $NotificationMetadataModelCopyWith<$Res> {
  _$NotificationMetadataModelCopyWithImpl(this._self, this._then);

  final NotificationMetadataModel _self;
  final $Res Function(NotificationMetadataModel) _then;

/// Create a copy of NotificationMetadataModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? actionType = null,Object? actionStatus = null,Object? actionedByUid = null,Object? actionedAt = null,Object? expiresAt = null,Object? deepLink = null,Object? shareCode = null,Object? extras = null,}) {
  return _then(_self.copyWith(
actionType: null == actionType ? _self.actionType : actionType // ignore: cast_nullable_to_non_nullable
as String,actionStatus: null == actionStatus ? _self.actionStatus : actionStatus // ignore: cast_nullable_to_non_nullable
as String,actionedByUid: null == actionedByUid ? _self.actionedByUid : actionedByUid // ignore: cast_nullable_to_non_nullable
as String,actionedAt: null == actionedAt ? _self.actionedAt : actionedAt // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String,deepLink: null == deepLink ? _self.deepLink : deepLink // ignore: cast_nullable_to_non_nullable
as String,shareCode: null == shareCode ? _self.shareCode : shareCode // ignore: cast_nullable_to_non_nullable
as String,extras: null == extras ? _self.extras : extras // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationMetadataModel].
extension NotificationMetadataModelPatterns on NotificationMetadataModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationMetadataModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationMetadataModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationMetadataModel value)  $default,){
final _that = this;
switch (_that) {
case _NotificationMetadataModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationMetadataModel value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationMetadataModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'actionType')  String actionType, @JsonKey(name: 'actionStatus')  String actionStatus, @JsonKey(name: 'actionedByUid')  String actionedByUid, @JsonKey(name: 'actionedAt')  String actionedAt, @JsonKey(name: 'expiresAt')  String expiresAt, @JsonKey(name: 'deepLink')  String deepLink, @JsonKey(name: 'shareCode')  String shareCode, @JsonKey(name: 'extras')  Map<String, String> extras)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationMetadataModel() when $default != null:
return $default(_that.actionType,_that.actionStatus,_that.actionedByUid,_that.actionedAt,_that.expiresAt,_that.deepLink,_that.shareCode,_that.extras);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'actionType')  String actionType, @JsonKey(name: 'actionStatus')  String actionStatus, @JsonKey(name: 'actionedByUid')  String actionedByUid, @JsonKey(name: 'actionedAt')  String actionedAt, @JsonKey(name: 'expiresAt')  String expiresAt, @JsonKey(name: 'deepLink')  String deepLink, @JsonKey(name: 'shareCode')  String shareCode, @JsonKey(name: 'extras')  Map<String, String> extras)  $default,) {final _that = this;
switch (_that) {
case _NotificationMetadataModel():
return $default(_that.actionType,_that.actionStatus,_that.actionedByUid,_that.actionedAt,_that.expiresAt,_that.deepLink,_that.shareCode,_that.extras);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'actionType')  String actionType, @JsonKey(name: 'actionStatus')  String actionStatus, @JsonKey(name: 'actionedByUid')  String actionedByUid, @JsonKey(name: 'actionedAt')  String actionedAt, @JsonKey(name: 'expiresAt')  String expiresAt, @JsonKey(name: 'deepLink')  String deepLink, @JsonKey(name: 'shareCode')  String shareCode, @JsonKey(name: 'extras')  Map<String, String> extras)?  $default,) {final _that = this;
switch (_that) {
case _NotificationMetadataModel() when $default != null:
return $default(_that.actionType,_that.actionStatus,_that.actionedByUid,_that.actionedAt,_that.expiresAt,_that.deepLink,_that.shareCode,_that.extras);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationMetadataModel extends NotificationMetadataModel {
  const _NotificationMetadataModel({@JsonKey(name: 'actionType') this.actionType = '', @JsonKey(name: 'actionStatus') this.actionStatus = '', @JsonKey(name: 'actionedByUid') this.actionedByUid = '', @JsonKey(name: 'actionedAt') this.actionedAt = '', @JsonKey(name: 'expiresAt') this.expiresAt = '', @JsonKey(name: 'deepLink') this.deepLink = '', @JsonKey(name: 'shareCode') this.shareCode = '', @JsonKey(name: 'extras') final  Map<String, String> extras = const <String, String>{}}): _extras = extras,super._();
  factory _NotificationMetadataModel.fromJson(Map<String, dynamic> json) => _$NotificationMetadataModelFromJson(json);

@override@JsonKey(name: 'actionType') final  String actionType;
@override@JsonKey(name: 'actionStatus') final  String actionStatus;
@override@JsonKey(name: 'actionedByUid') final  String actionedByUid;
@override@JsonKey(name: 'actionedAt') final  String actionedAt;
@override@JsonKey(name: 'expiresAt') final  String expiresAt;
@override@JsonKey(name: 'deepLink') final  String deepLink;
@override@JsonKey(name: 'shareCode') final  String shareCode;
 final  Map<String, String> _extras;
@override@JsonKey(name: 'extras') Map<String, String> get extras {
  if (_extras is EqualUnmodifiableMapView) return _extras;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_extras);
}


/// Create a copy of NotificationMetadataModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationMetadataModelCopyWith<_NotificationMetadataModel> get copyWith => __$NotificationMetadataModelCopyWithImpl<_NotificationMetadataModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationMetadataModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationMetadataModel&&(identical(other.actionType, actionType) || other.actionType == actionType)&&(identical(other.actionStatus, actionStatus) || other.actionStatus == actionStatus)&&(identical(other.actionedByUid, actionedByUid) || other.actionedByUid == actionedByUid)&&(identical(other.actionedAt, actionedAt) || other.actionedAt == actionedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.deepLink, deepLink) || other.deepLink == deepLink)&&(identical(other.shareCode, shareCode) || other.shareCode == shareCode)&&const DeepCollectionEquality().equals(other._extras, _extras));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,actionType,actionStatus,actionedByUid,actionedAt,expiresAt,deepLink,shareCode,const DeepCollectionEquality().hash(_extras));



}

/// @nodoc
abstract mixin class _$NotificationMetadataModelCopyWith<$Res> implements $NotificationMetadataModelCopyWith<$Res> {
  factory _$NotificationMetadataModelCopyWith(_NotificationMetadataModel value, $Res Function(_NotificationMetadataModel) _then) = __$NotificationMetadataModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'actionType') String actionType,@JsonKey(name: 'actionStatus') String actionStatus,@JsonKey(name: 'actionedByUid') String actionedByUid,@JsonKey(name: 'actionedAt') String actionedAt,@JsonKey(name: 'expiresAt') String expiresAt,@JsonKey(name: 'deepLink') String deepLink,@JsonKey(name: 'shareCode') String shareCode,@JsonKey(name: 'extras') Map<String, String> extras
});




}
/// @nodoc
class __$NotificationMetadataModelCopyWithImpl<$Res>
    implements _$NotificationMetadataModelCopyWith<$Res> {
  __$NotificationMetadataModelCopyWithImpl(this._self, this._then);

  final _NotificationMetadataModel _self;
  final $Res Function(_NotificationMetadataModel) _then;

/// Create a copy of NotificationMetadataModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? actionType = null,Object? actionStatus = null,Object? actionedByUid = null,Object? actionedAt = null,Object? expiresAt = null,Object? deepLink = null,Object? shareCode = null,Object? extras = null,}) {
  return _then(_NotificationMetadataModel(
actionType: null == actionType ? _self.actionType : actionType // ignore: cast_nullable_to_non_nullable
as String,actionStatus: null == actionStatus ? _self.actionStatus : actionStatus // ignore: cast_nullable_to_non_nullable
as String,actionedByUid: null == actionedByUid ? _self.actionedByUid : actionedByUid // ignore: cast_nullable_to_non_nullable
as String,actionedAt: null == actionedAt ? _self.actionedAt : actionedAt // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String,deepLink: null == deepLink ? _self.deepLink : deepLink // ignore: cast_nullable_to_non_nullable
as String,shareCode: null == shareCode ? _self.shareCode : shareCode // ignore: cast_nullable_to_non_nullable
as String,extras: null == extras ? _self._extras : extras // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
