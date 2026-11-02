// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_preview_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessagePreviewModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'senderUid') String get senderUid;@JsonKey(name: 'text') String get text;@JsonKey(name: 'hasAttachment') bool get hasAttachment;@JsonKey(name: 'sentAt') String get sentAt;
/// Create a copy of MessagePreviewModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessagePreviewModelCopyWith<MessagePreviewModel> get copyWith => _$MessagePreviewModelCopyWithImpl<MessagePreviewModel>(this as MessagePreviewModel, _$identity);

  /// Serializes this MessagePreviewModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessagePreviewModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.senderUid, senderUid) || other.senderUid == senderUid)&&(identical(other.text, text) || other.text == text)&&(identical(other.hasAttachment, hasAttachment) || other.hasAttachment == hasAttachment)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,senderUid,text,hasAttachment,sentAt);

@override
String toString() {
  return 'MessagePreviewModel(uid: $uid, senderUid: $senderUid, text: $text, hasAttachment: $hasAttachment, sentAt: $sentAt)';
}


}

/// @nodoc
abstract mixin class $MessagePreviewModelCopyWith<$Res>  {
  factory $MessagePreviewModelCopyWith(MessagePreviewModel value, $Res Function(MessagePreviewModel) _then) = _$MessagePreviewModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'senderUid') String senderUid,@JsonKey(name: 'text') String text,@JsonKey(name: 'hasAttachment') bool hasAttachment,@JsonKey(name: 'sentAt') String sentAt
});




}
/// @nodoc
class _$MessagePreviewModelCopyWithImpl<$Res>
    implements $MessagePreviewModelCopyWith<$Res> {
  _$MessagePreviewModelCopyWithImpl(this._self, this._then);

  final MessagePreviewModel _self;
  final $Res Function(MessagePreviewModel) _then;

/// Create a copy of MessagePreviewModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? senderUid = null,Object? text = null,Object? hasAttachment = null,Object? sentAt = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,senderUid: null == senderUid ? _self.senderUid : senderUid // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,hasAttachment: null == hasAttachment ? _self.hasAttachment : hasAttachment // ignore: cast_nullable_to_non_nullable
as bool,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MessagePreviewModel].
extension MessagePreviewModelPatterns on MessagePreviewModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessagePreviewModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessagePreviewModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessagePreviewModel value)  $default,){
final _that = this;
switch (_that) {
case _MessagePreviewModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessagePreviewModel value)?  $default,){
final _that = this;
switch (_that) {
case _MessagePreviewModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'senderUid')  String senderUid, @JsonKey(name: 'text')  String text, @JsonKey(name: 'hasAttachment')  bool hasAttachment, @JsonKey(name: 'sentAt')  String sentAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessagePreviewModel() when $default != null:
return $default(_that.uid,_that.senderUid,_that.text,_that.hasAttachment,_that.sentAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'senderUid')  String senderUid, @JsonKey(name: 'text')  String text, @JsonKey(name: 'hasAttachment')  bool hasAttachment, @JsonKey(name: 'sentAt')  String sentAt)  $default,) {final _that = this;
switch (_that) {
case _MessagePreviewModel():
return $default(_that.uid,_that.senderUid,_that.text,_that.hasAttachment,_that.sentAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'senderUid')  String senderUid, @JsonKey(name: 'text')  String text, @JsonKey(name: 'hasAttachment')  bool hasAttachment, @JsonKey(name: 'sentAt')  String sentAt)?  $default,) {final _that = this;
switch (_that) {
case _MessagePreviewModel() when $default != null:
return $default(_that.uid,_that.senderUid,_that.text,_that.hasAttachment,_that.sentAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessagePreviewModel implements MessagePreviewModel {
  const _MessagePreviewModel({@JsonKey(name: 'uid') this.uid = '', @JsonKey(name: 'senderUid') this.senderUid = '', @JsonKey(name: 'text') this.text = '', @JsonKey(name: 'hasAttachment') this.hasAttachment = false, @JsonKey(name: 'sentAt') this.sentAt = ''});
  factory _MessagePreviewModel.fromJson(Map<String, dynamic> json) => _$MessagePreviewModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'senderUid') final  String senderUid;
@override@JsonKey(name: 'text') final  String text;
@override@JsonKey(name: 'hasAttachment') final  bool hasAttachment;
@override@JsonKey(name: 'sentAt') final  String sentAt;

/// Create a copy of MessagePreviewModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessagePreviewModelCopyWith<_MessagePreviewModel> get copyWith => __$MessagePreviewModelCopyWithImpl<_MessagePreviewModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessagePreviewModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessagePreviewModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.senderUid, senderUid) || other.senderUid == senderUid)&&(identical(other.text, text) || other.text == text)&&(identical(other.hasAttachment, hasAttachment) || other.hasAttachment == hasAttachment)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,senderUid,text,hasAttachment,sentAt);

@override
String toString() {
  return 'MessagePreviewModel(uid: $uid, senderUid: $senderUid, text: $text, hasAttachment: $hasAttachment, sentAt: $sentAt)';
}


}

/// @nodoc
abstract mixin class _$MessagePreviewModelCopyWith<$Res> implements $MessagePreviewModelCopyWith<$Res> {
  factory _$MessagePreviewModelCopyWith(_MessagePreviewModel value, $Res Function(_MessagePreviewModel) _then) = __$MessagePreviewModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'senderUid') String senderUid,@JsonKey(name: 'text') String text,@JsonKey(name: 'hasAttachment') bool hasAttachment,@JsonKey(name: 'sentAt') String sentAt
});




}
/// @nodoc
class __$MessagePreviewModelCopyWithImpl<$Res>
    implements _$MessagePreviewModelCopyWith<$Res> {
  __$MessagePreviewModelCopyWithImpl(this._self, this._then);

  final _MessagePreviewModel _self;
  final $Res Function(_MessagePreviewModel) _then;

/// Create a copy of MessagePreviewModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? senderUid = null,Object? text = null,Object? hasAttachment = null,Object? sentAt = null,}) {
  return _then(_MessagePreviewModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,senderUid: null == senderUid ? _self.senderUid : senderUid // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,hasAttachment: null == hasAttachment ? _self.hasAttachment : hasAttachment // ignore: cast_nullable_to_non_nullable
as bool,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
