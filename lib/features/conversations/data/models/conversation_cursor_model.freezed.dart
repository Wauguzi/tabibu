// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_cursor_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConversationCursorModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'conversationUid') String get conversationUid;@JsonKey(name: 'lastReadAt') String get lastReadAt;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;@JsonKey(includeFromJson: false, includeToJson: false) bool get synced;
/// Create a copy of ConversationCursorModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationCursorModelCopyWith<ConversationCursorModel> get copyWith => _$ConversationCursorModelCopyWithImpl<ConversationCursorModel>(this as ConversationCursorModel, _$identity);

  /// Serializes this ConversationCursorModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationCursorModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.conversationUid, conversationUid) || other.conversationUid == conversationUid)&&(identical(other.lastReadAt, lastReadAt) || other.lastReadAt == lastReadAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,conversationUid,lastReadAt,lastUpdatedAt,synced);

@override
String toString() {
  return 'ConversationCursorModel(uid: $uid, conversationUid: $conversationUid, lastReadAt: $lastReadAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class $ConversationCursorModelCopyWith<$Res>  {
  factory $ConversationCursorModelCopyWith(ConversationCursorModel value, $Res Function(ConversationCursorModel) _then) = _$ConversationCursorModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'conversationUid') String conversationUid,@JsonKey(name: 'lastReadAt') String lastReadAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class _$ConversationCursorModelCopyWithImpl<$Res>
    implements $ConversationCursorModelCopyWith<$Res> {
  _$ConversationCursorModelCopyWithImpl(this._self, this._then);

  final ConversationCursorModel _self;
  final $Res Function(ConversationCursorModel) _then;

/// Create a copy of ConversationCursorModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? conversationUid = null,Object? lastReadAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,conversationUid: null == conversationUid ? _self.conversationUid : conversationUid // ignore: cast_nullable_to_non_nullable
as String,lastReadAt: null == lastReadAt ? _self.lastReadAt : lastReadAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ConversationCursorModel].
extension ConversationCursorModelPatterns on ConversationCursorModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConversationCursorModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConversationCursorModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConversationCursorModel value)  $default,){
final _that = this;
switch (_that) {
case _ConversationCursorModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConversationCursorModel value)?  $default,){
final _that = this;
switch (_that) {
case _ConversationCursorModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'conversationUid')  String conversationUid, @JsonKey(name: 'lastReadAt')  String lastReadAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConversationCursorModel() when $default != null:
return $default(_that.uid,_that.conversationUid,_that.lastReadAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'conversationUid')  String conversationUid, @JsonKey(name: 'lastReadAt')  String lastReadAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)  $default,) {final _that = this;
switch (_that) {
case _ConversationCursorModel():
return $default(_that.uid,_that.conversationUid,_that.lastReadAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'conversationUid')  String conversationUid, @JsonKey(name: 'lastReadAt')  String lastReadAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,) {final _that = this;
switch (_that) {
case _ConversationCursorModel() when $default != null:
return $default(_that.uid,_that.conversationUid,_that.lastReadAt,_that.lastUpdatedAt,_that.synced);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConversationCursorModel implements ConversationCursorModel {
  const _ConversationCursorModel({@JsonKey(name: 'uid') this.uid = '', @JsonKey(name: 'conversationUid') this.conversationUid = '', @JsonKey(name: 'lastReadAt') this.lastReadAt = '', @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = '', @JsonKey(includeFromJson: false, includeToJson: false) this.synced = true});
  factory _ConversationCursorModel.fromJson(Map<String, dynamic> json) => _$ConversationCursorModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'conversationUid') final  String conversationUid;
@override@JsonKey(name: 'lastReadAt') final  String lastReadAt;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool synced;

/// Create a copy of ConversationCursorModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationCursorModelCopyWith<_ConversationCursorModel> get copyWith => __$ConversationCursorModelCopyWithImpl<_ConversationCursorModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConversationCursorModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConversationCursorModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.conversationUid, conversationUid) || other.conversationUid == conversationUid)&&(identical(other.lastReadAt, lastReadAt) || other.lastReadAt == lastReadAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,conversationUid,lastReadAt,lastUpdatedAt,synced);

@override
String toString() {
  return 'ConversationCursorModel(uid: $uid, conversationUid: $conversationUid, lastReadAt: $lastReadAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class _$ConversationCursorModelCopyWith<$Res> implements $ConversationCursorModelCopyWith<$Res> {
  factory _$ConversationCursorModelCopyWith(_ConversationCursorModel value, $Res Function(_ConversationCursorModel) _then) = __$ConversationCursorModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'conversationUid') String conversationUid,@JsonKey(name: 'lastReadAt') String lastReadAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class __$ConversationCursorModelCopyWithImpl<$Res>
    implements _$ConversationCursorModelCopyWith<$Res> {
  __$ConversationCursorModelCopyWithImpl(this._self, this._then);

  final _ConversationCursorModel _self;
  final $Res Function(_ConversationCursorModel) _then;

/// Create a copy of ConversationCursorModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? conversationUid = null,Object? lastReadAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_ConversationCursorModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,conversationUid: null == conversationUid ? _self.conversationUid : conversationUid // ignore: cast_nullable_to_non_nullable
as String,lastReadAt: null == lastReadAt ? _self.lastReadAt : lastReadAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
