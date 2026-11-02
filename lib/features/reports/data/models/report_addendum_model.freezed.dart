// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_addendum_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReportAddendumModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'text') String get text;@JsonKey(name: 'reportVersion') int get reportVersion;@JsonKey(name: 'signedByUid') String get signedByUid;@JsonKey(name: 'signedByName') String get signedByName;@JsonKey(name: 'signedAt') String get signedAt;
/// Create a copy of ReportAddendumModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportAddendumModelCopyWith<ReportAddendumModel> get copyWith => _$ReportAddendumModelCopyWithImpl<ReportAddendumModel>(this as ReportAddendumModel, _$identity);

  /// Serializes this ReportAddendumModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportAddendumModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.text, text) || other.text == text)&&(identical(other.reportVersion, reportVersion) || other.reportVersion == reportVersion)&&(identical(other.signedByUid, signedByUid) || other.signedByUid == signedByUid)&&(identical(other.signedByName, signedByName) || other.signedByName == signedByName)&&(identical(other.signedAt, signedAt) || other.signedAt == signedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,text,reportVersion,signedByUid,signedByName,signedAt);

@override
String toString() {
  return 'ReportAddendumModel(uid: $uid, text: $text, reportVersion: $reportVersion, signedByUid: $signedByUid, signedByName: $signedByName, signedAt: $signedAt)';
}


}

/// @nodoc
abstract mixin class $ReportAddendumModelCopyWith<$Res>  {
  factory $ReportAddendumModelCopyWith(ReportAddendumModel value, $Res Function(ReportAddendumModel) _then) = _$ReportAddendumModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'text') String text,@JsonKey(name: 'reportVersion') int reportVersion,@JsonKey(name: 'signedByUid') String signedByUid,@JsonKey(name: 'signedByName') String signedByName,@JsonKey(name: 'signedAt') String signedAt
});




}
/// @nodoc
class _$ReportAddendumModelCopyWithImpl<$Res>
    implements $ReportAddendumModelCopyWith<$Res> {
  _$ReportAddendumModelCopyWithImpl(this._self, this._then);

  final ReportAddendumModel _self;
  final $Res Function(ReportAddendumModel) _then;

/// Create a copy of ReportAddendumModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? text = null,Object? reportVersion = null,Object? signedByUid = null,Object? signedByName = null,Object? signedAt = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,reportVersion: null == reportVersion ? _self.reportVersion : reportVersion // ignore: cast_nullable_to_non_nullable
as int,signedByUid: null == signedByUid ? _self.signedByUid : signedByUid // ignore: cast_nullable_to_non_nullable
as String,signedByName: null == signedByName ? _self.signedByName : signedByName // ignore: cast_nullable_to_non_nullable
as String,signedAt: null == signedAt ? _self.signedAt : signedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportAddendumModel].
extension ReportAddendumModelPatterns on ReportAddendumModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportAddendumModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportAddendumModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportAddendumModel value)  $default,){
final _that = this;
switch (_that) {
case _ReportAddendumModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportAddendumModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReportAddendumModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'text')  String text, @JsonKey(name: 'reportVersion')  int reportVersion, @JsonKey(name: 'signedByUid')  String signedByUid, @JsonKey(name: 'signedByName')  String signedByName, @JsonKey(name: 'signedAt')  String signedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportAddendumModel() when $default != null:
return $default(_that.uid,_that.text,_that.reportVersion,_that.signedByUid,_that.signedByName,_that.signedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'text')  String text, @JsonKey(name: 'reportVersion')  int reportVersion, @JsonKey(name: 'signedByUid')  String signedByUid, @JsonKey(name: 'signedByName')  String signedByName, @JsonKey(name: 'signedAt')  String signedAt)  $default,) {final _that = this;
switch (_that) {
case _ReportAddendumModel():
return $default(_that.uid,_that.text,_that.reportVersion,_that.signedByUid,_that.signedByName,_that.signedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'text')  String text, @JsonKey(name: 'reportVersion')  int reportVersion, @JsonKey(name: 'signedByUid')  String signedByUid, @JsonKey(name: 'signedByName')  String signedByName, @JsonKey(name: 'signedAt')  String signedAt)?  $default,) {final _that = this;
switch (_that) {
case _ReportAddendumModel() when $default != null:
return $default(_that.uid,_that.text,_that.reportVersion,_that.signedByUid,_that.signedByName,_that.signedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportAddendumModel extends ReportAddendumModel {
  const _ReportAddendumModel({@JsonKey(name: 'uid') this.uid = '', @JsonKey(name: 'text') this.text = '', @JsonKey(name: 'reportVersion') this.reportVersion = 0, @JsonKey(name: 'signedByUid') this.signedByUid = '', @JsonKey(name: 'signedByName') this.signedByName = '', @JsonKey(name: 'signedAt') this.signedAt = ''}): super._();
  factory _ReportAddendumModel.fromJson(Map<String, dynamic> json) => _$ReportAddendumModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'text') final  String text;
@override@JsonKey(name: 'reportVersion') final  int reportVersion;
@override@JsonKey(name: 'signedByUid') final  String signedByUid;
@override@JsonKey(name: 'signedByName') final  String signedByName;
@override@JsonKey(name: 'signedAt') final  String signedAt;

/// Create a copy of ReportAddendumModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportAddendumModelCopyWith<_ReportAddendumModel> get copyWith => __$ReportAddendumModelCopyWithImpl<_ReportAddendumModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportAddendumModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportAddendumModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.text, text) || other.text == text)&&(identical(other.reportVersion, reportVersion) || other.reportVersion == reportVersion)&&(identical(other.signedByUid, signedByUid) || other.signedByUid == signedByUid)&&(identical(other.signedByName, signedByName) || other.signedByName == signedByName)&&(identical(other.signedAt, signedAt) || other.signedAt == signedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,text,reportVersion,signedByUid,signedByName,signedAt);

@override
String toString() {
  return 'ReportAddendumModel(uid: $uid, text: $text, reportVersion: $reportVersion, signedByUid: $signedByUid, signedByName: $signedByName, signedAt: $signedAt)';
}


}

/// @nodoc
abstract mixin class _$ReportAddendumModelCopyWith<$Res> implements $ReportAddendumModelCopyWith<$Res> {
  factory _$ReportAddendumModelCopyWith(_ReportAddendumModel value, $Res Function(_ReportAddendumModel) _then) = __$ReportAddendumModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'text') String text,@JsonKey(name: 'reportVersion') int reportVersion,@JsonKey(name: 'signedByUid') String signedByUid,@JsonKey(name: 'signedByName') String signedByName,@JsonKey(name: 'signedAt') String signedAt
});




}
/// @nodoc
class __$ReportAddendumModelCopyWithImpl<$Res>
    implements _$ReportAddendumModelCopyWith<$Res> {
  __$ReportAddendumModelCopyWithImpl(this._self, this._then);

  final _ReportAddendumModel _self;
  final $Res Function(_ReportAddendumModel) _then;

/// Create a copy of ReportAddendumModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? text = null,Object? reportVersion = null,Object? signedByUid = null,Object? signedByName = null,Object? signedAt = null,}) {
  return _then(_ReportAddendumModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,reportVersion: null == reportVersion ? _self.reportVersion : reportVersion // ignore: cast_nullable_to_non_nullable
as int,signedByUid: null == signedByUid ? _self.signedByUid : signedByUid // ignore: cast_nullable_to_non_nullable
as String,signedByName: null == signedByName ? _self.signedByName : signedByName // ignore: cast_nullable_to_non_nullable
as String,signedAt: null == signedAt ? _self.signedAt : signedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
