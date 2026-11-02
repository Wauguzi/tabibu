// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_transcript_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessageTranscriptModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'conversationUid') String get conversationUid;@JsonKey(name: 'messageUid') String get messageUid;@JsonKey(name: 'senderUid') String get senderUid;@JsonKey(name: 'text') String get text;@JsonKey(name: 'language') String get language;@JsonKey(name: 'acceptedUnchanged') bool get acceptedUnchanged;@JsonKey(name: 'editDistance') double get editDistance;@JsonKey(name: 'models') Map<String, String> get models;@JsonKey(name: 'sharedAt') String get sharedAt;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;@JsonKey(includeFromJson: false, includeToJson: false) bool get synced;
/// Create a copy of MessageTranscriptModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageTranscriptModelCopyWith<MessageTranscriptModel> get copyWith => _$MessageTranscriptModelCopyWithImpl<MessageTranscriptModel>(this as MessageTranscriptModel, _$identity);

  /// Serializes this MessageTranscriptModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageTranscriptModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.conversationUid, conversationUid) || other.conversationUid == conversationUid)&&(identical(other.messageUid, messageUid) || other.messageUid == messageUid)&&(identical(other.senderUid, senderUid) || other.senderUid == senderUid)&&(identical(other.text, text) || other.text == text)&&(identical(other.language, language) || other.language == language)&&(identical(other.acceptedUnchanged, acceptedUnchanged) || other.acceptedUnchanged == acceptedUnchanged)&&(identical(other.editDistance, editDistance) || other.editDistance == editDistance)&&const DeepCollectionEquality().equals(other.models, models)&&(identical(other.sharedAt, sharedAt) || other.sharedAt == sharedAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,conversationUid,messageUid,senderUid,text,language,acceptedUnchanged,editDistance,const DeepCollectionEquality().hash(models),sharedAt,lastUpdatedAt,synced);

@override
String toString() {
  return 'MessageTranscriptModel(uid: $uid, conversationUid: $conversationUid, messageUid: $messageUid, senderUid: $senderUid, text: $text, language: $language, acceptedUnchanged: $acceptedUnchanged, editDistance: $editDistance, models: $models, sharedAt: $sharedAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class $MessageTranscriptModelCopyWith<$Res>  {
  factory $MessageTranscriptModelCopyWith(MessageTranscriptModel value, $Res Function(MessageTranscriptModel) _then) = _$MessageTranscriptModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'conversationUid') String conversationUid,@JsonKey(name: 'messageUid') String messageUid,@JsonKey(name: 'senderUid') String senderUid,@JsonKey(name: 'text') String text,@JsonKey(name: 'language') String language,@JsonKey(name: 'acceptedUnchanged') bool acceptedUnchanged,@JsonKey(name: 'editDistance') double editDistance,@JsonKey(name: 'models') Map<String, String> models,@JsonKey(name: 'sharedAt') String sharedAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class _$MessageTranscriptModelCopyWithImpl<$Res>
    implements $MessageTranscriptModelCopyWith<$Res> {
  _$MessageTranscriptModelCopyWithImpl(this._self, this._then);

  final MessageTranscriptModel _self;
  final $Res Function(MessageTranscriptModel) _then;

/// Create a copy of MessageTranscriptModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? conversationUid = null,Object? messageUid = null,Object? senderUid = null,Object? text = null,Object? language = null,Object? acceptedUnchanged = null,Object? editDistance = null,Object? models = null,Object? sharedAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,conversationUid: null == conversationUid ? _self.conversationUid : conversationUid // ignore: cast_nullable_to_non_nullable
as String,messageUid: null == messageUid ? _self.messageUid : messageUid // ignore: cast_nullable_to_non_nullable
as String,senderUid: null == senderUid ? _self.senderUid : senderUid // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,acceptedUnchanged: null == acceptedUnchanged ? _self.acceptedUnchanged : acceptedUnchanged // ignore: cast_nullable_to_non_nullable
as bool,editDistance: null == editDistance ? _self.editDistance : editDistance // ignore: cast_nullable_to_non_nullable
as double,models: null == models ? _self.models : models // ignore: cast_nullable_to_non_nullable
as Map<String, String>,sharedAt: null == sharedAt ? _self.sharedAt : sharedAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageTranscriptModel].
extension MessageTranscriptModelPatterns on MessageTranscriptModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageTranscriptModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageTranscriptModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageTranscriptModel value)  $default,){
final _that = this;
switch (_that) {
case _MessageTranscriptModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageTranscriptModel value)?  $default,){
final _that = this;
switch (_that) {
case _MessageTranscriptModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'conversationUid')  String conversationUid, @JsonKey(name: 'messageUid')  String messageUid, @JsonKey(name: 'senderUid')  String senderUid, @JsonKey(name: 'text')  String text, @JsonKey(name: 'language')  String language, @JsonKey(name: 'acceptedUnchanged')  bool acceptedUnchanged, @JsonKey(name: 'editDistance')  double editDistance, @JsonKey(name: 'models')  Map<String, String> models, @JsonKey(name: 'sharedAt')  String sharedAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageTranscriptModel() when $default != null:
return $default(_that.uid,_that.conversationUid,_that.messageUid,_that.senderUid,_that.text,_that.language,_that.acceptedUnchanged,_that.editDistance,_that.models,_that.sharedAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'conversationUid')  String conversationUid, @JsonKey(name: 'messageUid')  String messageUid, @JsonKey(name: 'senderUid')  String senderUid, @JsonKey(name: 'text')  String text, @JsonKey(name: 'language')  String language, @JsonKey(name: 'acceptedUnchanged')  bool acceptedUnchanged, @JsonKey(name: 'editDistance')  double editDistance, @JsonKey(name: 'models')  Map<String, String> models, @JsonKey(name: 'sharedAt')  String sharedAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)  $default,) {final _that = this;
switch (_that) {
case _MessageTranscriptModel():
return $default(_that.uid,_that.conversationUid,_that.messageUid,_that.senderUid,_that.text,_that.language,_that.acceptedUnchanged,_that.editDistance,_that.models,_that.sharedAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'conversationUid')  String conversationUid, @JsonKey(name: 'messageUid')  String messageUid, @JsonKey(name: 'senderUid')  String senderUid, @JsonKey(name: 'text')  String text, @JsonKey(name: 'language')  String language, @JsonKey(name: 'acceptedUnchanged')  bool acceptedUnchanged, @JsonKey(name: 'editDistance')  double editDistance, @JsonKey(name: 'models')  Map<String, String> models, @JsonKey(name: 'sharedAt')  String sharedAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,) {final _that = this;
switch (_that) {
case _MessageTranscriptModel() when $default != null:
return $default(_that.uid,_that.conversationUid,_that.messageUid,_that.senderUid,_that.text,_that.language,_that.acceptedUnchanged,_that.editDistance,_that.models,_that.sharedAt,_that.lastUpdatedAt,_that.synced);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageTranscriptModel implements MessageTranscriptModel {
  const _MessageTranscriptModel({@JsonKey(name: 'uid') this.uid = '', @JsonKey(name: 'conversationUid') this.conversationUid = '', @JsonKey(name: 'messageUid') this.messageUid = '', @JsonKey(name: 'senderUid') this.senderUid = '', @JsonKey(name: 'text') this.text = '', @JsonKey(name: 'language') this.language = '', @JsonKey(name: 'acceptedUnchanged') this.acceptedUnchanged = false, @JsonKey(name: 'editDistance') this.editDistance = 0.0, @JsonKey(name: 'models') final  Map<String, String> models = const <String, String>{}, @JsonKey(name: 'sharedAt') this.sharedAt = '', @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = '', @JsonKey(includeFromJson: false, includeToJson: false) this.synced = true}): _models = models;
  factory _MessageTranscriptModel.fromJson(Map<String, dynamic> json) => _$MessageTranscriptModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'conversationUid') final  String conversationUid;
@override@JsonKey(name: 'messageUid') final  String messageUid;
@override@JsonKey(name: 'senderUid') final  String senderUid;
@override@JsonKey(name: 'text') final  String text;
@override@JsonKey(name: 'language') final  String language;
@override@JsonKey(name: 'acceptedUnchanged') final  bool acceptedUnchanged;
@override@JsonKey(name: 'editDistance') final  double editDistance;
 final  Map<String, String> _models;
@override@JsonKey(name: 'models') Map<String, String> get models {
  if (_models is EqualUnmodifiableMapView) return _models;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_models);
}

@override@JsonKey(name: 'sharedAt') final  String sharedAt;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool synced;

/// Create a copy of MessageTranscriptModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageTranscriptModelCopyWith<_MessageTranscriptModel> get copyWith => __$MessageTranscriptModelCopyWithImpl<_MessageTranscriptModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageTranscriptModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageTranscriptModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.conversationUid, conversationUid) || other.conversationUid == conversationUid)&&(identical(other.messageUid, messageUid) || other.messageUid == messageUid)&&(identical(other.senderUid, senderUid) || other.senderUid == senderUid)&&(identical(other.text, text) || other.text == text)&&(identical(other.language, language) || other.language == language)&&(identical(other.acceptedUnchanged, acceptedUnchanged) || other.acceptedUnchanged == acceptedUnchanged)&&(identical(other.editDistance, editDistance) || other.editDistance == editDistance)&&const DeepCollectionEquality().equals(other._models, _models)&&(identical(other.sharedAt, sharedAt) || other.sharedAt == sharedAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,conversationUid,messageUid,senderUid,text,language,acceptedUnchanged,editDistance,const DeepCollectionEquality().hash(_models),sharedAt,lastUpdatedAt,synced);

@override
String toString() {
  return 'MessageTranscriptModel(uid: $uid, conversationUid: $conversationUid, messageUid: $messageUid, senderUid: $senderUid, text: $text, language: $language, acceptedUnchanged: $acceptedUnchanged, editDistance: $editDistance, models: $models, sharedAt: $sharedAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class _$MessageTranscriptModelCopyWith<$Res> implements $MessageTranscriptModelCopyWith<$Res> {
  factory _$MessageTranscriptModelCopyWith(_MessageTranscriptModel value, $Res Function(_MessageTranscriptModel) _then) = __$MessageTranscriptModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'conversationUid') String conversationUid,@JsonKey(name: 'messageUid') String messageUid,@JsonKey(name: 'senderUid') String senderUid,@JsonKey(name: 'text') String text,@JsonKey(name: 'language') String language,@JsonKey(name: 'acceptedUnchanged') bool acceptedUnchanged,@JsonKey(name: 'editDistance') double editDistance,@JsonKey(name: 'models') Map<String, String> models,@JsonKey(name: 'sharedAt') String sharedAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class __$MessageTranscriptModelCopyWithImpl<$Res>
    implements _$MessageTranscriptModelCopyWith<$Res> {
  __$MessageTranscriptModelCopyWithImpl(this._self, this._then);

  final _MessageTranscriptModel _self;
  final $Res Function(_MessageTranscriptModel) _then;

/// Create a copy of MessageTranscriptModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? conversationUid = null,Object? messageUid = null,Object? senderUid = null,Object? text = null,Object? language = null,Object? acceptedUnchanged = null,Object? editDistance = null,Object? models = null,Object? sharedAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_MessageTranscriptModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,conversationUid: null == conversationUid ? _self.conversationUid : conversationUid // ignore: cast_nullable_to_non_nullable
as String,messageUid: null == messageUid ? _self.messageUid : messageUid // ignore: cast_nullable_to_non_nullable
as String,senderUid: null == senderUid ? _self.senderUid : senderUid // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,acceptedUnchanged: null == acceptedUnchanged ? _self.acceptedUnchanged : acceptedUnchanged // ignore: cast_nullable_to_non_nullable
as bool,editDistance: null == editDistance ? _self.editDistance : editDistance // ignore: cast_nullable_to_non_nullable
as double,models: null == models ? _self._models : models // ignore: cast_nullable_to_non_nullable
as Map<String, String>,sharedAt: null == sharedAt ? _self.sharedAt : sharedAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
