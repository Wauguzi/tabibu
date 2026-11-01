// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notes_translation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotesTranslationModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'caseUid') String get caseUid;@JsonKey(name: 'status') String get status;@JsonKey(name: 'sourceLanguage') String get sourceLanguage;@JsonKey(name: 'language') String get language;@JsonKey(name: 'sourceSha256') String get sourceSha256;@JsonKey(name: 'text') String get text;@JsonKey(name: 'models') Map<String, String> get models;@JsonKey(name: 'failureReason') String get failureReason;@JsonKey(name: 'requestedAt') String get requestedAt;@JsonKey(name: 'readyAt') String get readyAt;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;@JsonKey(includeFromJson: false, includeToJson: false) bool get synced;
/// Create a copy of NotesTranslationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotesTranslationModelCopyWith<NotesTranslationModel> get copyWith => _$NotesTranslationModelCopyWithImpl<NotesTranslationModel>(this as NotesTranslationModel, _$identity);

  /// Serializes this NotesTranslationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotesTranslationModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.status, status) || other.status == status)&&(identical(other.sourceLanguage, sourceLanguage) || other.sourceLanguage == sourceLanguage)&&(identical(other.language, language) || other.language == language)&&(identical(other.sourceSha256, sourceSha256) || other.sourceSha256 == sourceSha256)&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.models, models)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.readyAt, readyAt) || other.readyAt == readyAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,caseUid,status,sourceLanguage,language,sourceSha256,text,const DeepCollectionEquality().hash(models),failureReason,requestedAt,readyAt,lastUpdatedAt,synced);

@override
String toString() {
  return 'NotesTranslationModel(uid: $uid, caseUid: $caseUid, status: $status, sourceLanguage: $sourceLanguage, language: $language, sourceSha256: $sourceSha256, text: $text, models: $models, failureReason: $failureReason, requestedAt: $requestedAt, readyAt: $readyAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class $NotesTranslationModelCopyWith<$Res>  {
  factory $NotesTranslationModelCopyWith(NotesTranslationModel value, $Res Function(NotesTranslationModel) _then) = _$NotesTranslationModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'status') String status,@JsonKey(name: 'sourceLanguage') String sourceLanguage,@JsonKey(name: 'language') String language,@JsonKey(name: 'sourceSha256') String sourceSha256,@JsonKey(name: 'text') String text,@JsonKey(name: 'models') Map<String, String> models,@JsonKey(name: 'failureReason') String failureReason,@JsonKey(name: 'requestedAt') String requestedAt,@JsonKey(name: 'readyAt') String readyAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class _$NotesTranslationModelCopyWithImpl<$Res>
    implements $NotesTranslationModelCopyWith<$Res> {
  _$NotesTranslationModelCopyWithImpl(this._self, this._then);

  final NotesTranslationModel _self;
  final $Res Function(NotesTranslationModel) _then;

/// Create a copy of NotesTranslationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? caseUid = null,Object? status = null,Object? sourceLanguage = null,Object? language = null,Object? sourceSha256 = null,Object? text = null,Object? models = null,Object? failureReason = null,Object? requestedAt = null,Object? readyAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,sourceLanguage: null == sourceLanguage ? _self.sourceLanguage : sourceLanguage // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,sourceSha256: null == sourceSha256 ? _self.sourceSha256 : sourceSha256 // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,models: null == models ? _self.models : models // ignore: cast_nullable_to_non_nullable
as Map<String, String>,failureReason: null == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as String,readyAt: null == readyAt ? _self.readyAt : readyAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotesTranslationModel].
extension NotesTranslationModelPatterns on NotesTranslationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotesTranslationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotesTranslationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotesTranslationModel value)  $default,){
final _that = this;
switch (_that) {
case _NotesTranslationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotesTranslationModel value)?  $default,){
final _that = this;
switch (_that) {
case _NotesTranslationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'status')  String status, @JsonKey(name: 'sourceLanguage')  String sourceLanguage, @JsonKey(name: 'language')  String language, @JsonKey(name: 'sourceSha256')  String sourceSha256, @JsonKey(name: 'text')  String text, @JsonKey(name: 'models')  Map<String, String> models, @JsonKey(name: 'failureReason')  String failureReason, @JsonKey(name: 'requestedAt')  String requestedAt, @JsonKey(name: 'readyAt')  String readyAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotesTranslationModel() when $default != null:
return $default(_that.uid,_that.caseUid,_that.status,_that.sourceLanguage,_that.language,_that.sourceSha256,_that.text,_that.models,_that.failureReason,_that.requestedAt,_that.readyAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'status')  String status, @JsonKey(name: 'sourceLanguage')  String sourceLanguage, @JsonKey(name: 'language')  String language, @JsonKey(name: 'sourceSha256')  String sourceSha256, @JsonKey(name: 'text')  String text, @JsonKey(name: 'models')  Map<String, String> models, @JsonKey(name: 'failureReason')  String failureReason, @JsonKey(name: 'requestedAt')  String requestedAt, @JsonKey(name: 'readyAt')  String readyAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)  $default,) {final _that = this;
switch (_that) {
case _NotesTranslationModel():
return $default(_that.uid,_that.caseUid,_that.status,_that.sourceLanguage,_that.language,_that.sourceSha256,_that.text,_that.models,_that.failureReason,_that.requestedAt,_that.readyAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'status')  String status, @JsonKey(name: 'sourceLanguage')  String sourceLanguage, @JsonKey(name: 'language')  String language, @JsonKey(name: 'sourceSha256')  String sourceSha256, @JsonKey(name: 'text')  String text, @JsonKey(name: 'models')  Map<String, String> models, @JsonKey(name: 'failureReason')  String failureReason, @JsonKey(name: 'requestedAt')  String requestedAt, @JsonKey(name: 'readyAt')  String readyAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,) {final _that = this;
switch (_that) {
case _NotesTranslationModel() when $default != null:
return $default(_that.uid,_that.caseUid,_that.status,_that.sourceLanguage,_that.language,_that.sourceSha256,_that.text,_that.models,_that.failureReason,_that.requestedAt,_that.readyAt,_that.lastUpdatedAt,_that.synced);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotesTranslationModel extends NotesTranslationModel {
  const _NotesTranslationModel({@JsonKey(name: 'uid') this.uid = 'current', @JsonKey(name: 'caseUid') this.caseUid = '', @JsonKey(name: 'status') this.status = 'Queued', @JsonKey(name: 'sourceLanguage') this.sourceLanguage = '', @JsonKey(name: 'language') this.language = '', @JsonKey(name: 'sourceSha256') this.sourceSha256 = '', @JsonKey(name: 'text') this.text = '', @JsonKey(name: 'models') final  Map<String, String> models = const <String, String>{}, @JsonKey(name: 'failureReason') this.failureReason = '', @JsonKey(name: 'requestedAt') this.requestedAt = '', @JsonKey(name: 'readyAt') this.readyAt = '', @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = '', @JsonKey(includeFromJson: false, includeToJson: false) this.synced = true}): _models = models,super._();
  factory _NotesTranslationModel.fromJson(Map<String, dynamic> json) => _$NotesTranslationModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'caseUid') final  String caseUid;
@override@JsonKey(name: 'status') final  String status;
@override@JsonKey(name: 'sourceLanguage') final  String sourceLanguage;
@override@JsonKey(name: 'language') final  String language;
@override@JsonKey(name: 'sourceSha256') final  String sourceSha256;
@override@JsonKey(name: 'text') final  String text;
 final  Map<String, String> _models;
@override@JsonKey(name: 'models') Map<String, String> get models {
  if (_models is EqualUnmodifiableMapView) return _models;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_models);
}

@override@JsonKey(name: 'failureReason') final  String failureReason;
@override@JsonKey(name: 'requestedAt') final  String requestedAt;
@override@JsonKey(name: 'readyAt') final  String readyAt;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool synced;

/// Create a copy of NotesTranslationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotesTranslationModelCopyWith<_NotesTranslationModel> get copyWith => __$NotesTranslationModelCopyWithImpl<_NotesTranslationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotesTranslationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotesTranslationModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.status, status) || other.status == status)&&(identical(other.sourceLanguage, sourceLanguage) || other.sourceLanguage == sourceLanguage)&&(identical(other.language, language) || other.language == language)&&(identical(other.sourceSha256, sourceSha256) || other.sourceSha256 == sourceSha256)&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other._models, _models)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.readyAt, readyAt) || other.readyAt == readyAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,caseUid,status,sourceLanguage,language,sourceSha256,text,const DeepCollectionEquality().hash(_models),failureReason,requestedAt,readyAt,lastUpdatedAt,synced);

@override
String toString() {
  return 'NotesTranslationModel(uid: $uid, caseUid: $caseUid, status: $status, sourceLanguage: $sourceLanguage, language: $language, sourceSha256: $sourceSha256, text: $text, models: $models, failureReason: $failureReason, requestedAt: $requestedAt, readyAt: $readyAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class _$NotesTranslationModelCopyWith<$Res> implements $NotesTranslationModelCopyWith<$Res> {
  factory _$NotesTranslationModelCopyWith(_NotesTranslationModel value, $Res Function(_NotesTranslationModel) _then) = __$NotesTranslationModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'status') String status,@JsonKey(name: 'sourceLanguage') String sourceLanguage,@JsonKey(name: 'language') String language,@JsonKey(name: 'sourceSha256') String sourceSha256,@JsonKey(name: 'text') String text,@JsonKey(name: 'models') Map<String, String> models,@JsonKey(name: 'failureReason') String failureReason,@JsonKey(name: 'requestedAt') String requestedAt,@JsonKey(name: 'readyAt') String readyAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class __$NotesTranslationModelCopyWithImpl<$Res>
    implements _$NotesTranslationModelCopyWith<$Res> {
  __$NotesTranslationModelCopyWithImpl(this._self, this._then);

  final _NotesTranslationModel _self;
  final $Res Function(_NotesTranslationModel) _then;

/// Create a copy of NotesTranslationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? caseUid = null,Object? status = null,Object? sourceLanguage = null,Object? language = null,Object? sourceSha256 = null,Object? text = null,Object? models = null,Object? failureReason = null,Object? requestedAt = null,Object? readyAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_NotesTranslationModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,sourceLanguage: null == sourceLanguage ? _self.sourceLanguage : sourceLanguage // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,sourceSha256: null == sourceSha256 ? _self.sourceSha256 : sourceSha256 // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,models: null == models ? _self._models : models // ignore: cast_nullable_to_non_nullable
as Map<String, String>,failureReason: null == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as String,readyAt: null == readyAt ? _self.readyAt : readyAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
