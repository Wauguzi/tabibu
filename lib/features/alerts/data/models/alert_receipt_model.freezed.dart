// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alert_receipt_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AlertReceiptModel {

@JsonKey(name: 'alertUid') String get alertUid;@JsonKey(name: 'readAt') String get readAt;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;@JsonKey(includeFromJson: false, includeToJson: false) bool get synced;
/// Create a copy of AlertReceiptModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlertReceiptModelCopyWith<AlertReceiptModel> get copyWith => _$AlertReceiptModelCopyWithImpl<AlertReceiptModel>(this as AlertReceiptModel, _$identity);

  /// Serializes this AlertReceiptModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlertReceiptModel&&(identical(other.alertUid, alertUid) || other.alertUid == alertUid)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,alertUid,readAt,lastUpdatedAt,synced);

@override
String toString() {
  return 'AlertReceiptModel(alertUid: $alertUid, readAt: $readAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class $AlertReceiptModelCopyWith<$Res>  {
  factory $AlertReceiptModelCopyWith(AlertReceiptModel value, $Res Function(AlertReceiptModel) _then) = _$AlertReceiptModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'alertUid') String alertUid,@JsonKey(name: 'readAt') String readAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class _$AlertReceiptModelCopyWithImpl<$Res>
    implements $AlertReceiptModelCopyWith<$Res> {
  _$AlertReceiptModelCopyWithImpl(this._self, this._then);

  final AlertReceiptModel _self;
  final $Res Function(AlertReceiptModel) _then;

/// Create a copy of AlertReceiptModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? alertUid = null,Object? readAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_self.copyWith(
alertUid: null == alertUid ? _self.alertUid : alertUid // ignore: cast_nullable_to_non_nullable
as String,readAt: null == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AlertReceiptModel].
extension AlertReceiptModelPatterns on AlertReceiptModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlertReceiptModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlertReceiptModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlertReceiptModel value)  $default,){
final _that = this;
switch (_that) {
case _AlertReceiptModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlertReceiptModel value)?  $default,){
final _that = this;
switch (_that) {
case _AlertReceiptModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'alertUid')  String alertUid, @JsonKey(name: 'readAt')  String readAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlertReceiptModel() when $default != null:
return $default(_that.alertUid,_that.readAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'alertUid')  String alertUid, @JsonKey(name: 'readAt')  String readAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)  $default,) {final _that = this;
switch (_that) {
case _AlertReceiptModel():
return $default(_that.alertUid,_that.readAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'alertUid')  String alertUid, @JsonKey(name: 'readAt')  String readAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,) {final _that = this;
switch (_that) {
case _AlertReceiptModel() when $default != null:
return $default(_that.alertUid,_that.readAt,_that.lastUpdatedAt,_that.synced);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AlertReceiptModel extends AlertReceiptModel {
  const _AlertReceiptModel({@JsonKey(name: 'alertUid') this.alertUid = '', @JsonKey(name: 'readAt') this.readAt = '', @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = '', @JsonKey(includeFromJson: false, includeToJson: false) this.synced = true}): super._();
  factory _AlertReceiptModel.fromJson(Map<String, dynamic> json) => _$AlertReceiptModelFromJson(json);

@override@JsonKey(name: 'alertUid') final  String alertUid;
@override@JsonKey(name: 'readAt') final  String readAt;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool synced;

/// Create a copy of AlertReceiptModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlertReceiptModelCopyWith<_AlertReceiptModel> get copyWith => __$AlertReceiptModelCopyWithImpl<_AlertReceiptModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AlertReceiptModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlertReceiptModel&&(identical(other.alertUid, alertUid) || other.alertUid == alertUid)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,alertUid,readAt,lastUpdatedAt,synced);

@override
String toString() {
  return 'AlertReceiptModel(alertUid: $alertUid, readAt: $readAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class _$AlertReceiptModelCopyWith<$Res> implements $AlertReceiptModelCopyWith<$Res> {
  factory _$AlertReceiptModelCopyWith(_AlertReceiptModel value, $Res Function(_AlertReceiptModel) _then) = __$AlertReceiptModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'alertUid') String alertUid,@JsonKey(name: 'readAt') String readAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class __$AlertReceiptModelCopyWithImpl<$Res>
    implements _$AlertReceiptModelCopyWith<$Res> {
  __$AlertReceiptModelCopyWithImpl(this._self, this._then);

  final _AlertReceiptModel _self;
  final $Res Function(_AlertReceiptModel) _then;

/// Create a copy of AlertReceiptModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? alertUid = null,Object? readAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_AlertReceiptModel(
alertUid: null == alertUid ? _self.alertUid : alertUid // ignore: cast_nullable_to_non_nullable
as String,readAt: null == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
