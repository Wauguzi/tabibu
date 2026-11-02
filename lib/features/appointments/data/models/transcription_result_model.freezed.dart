// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transcription_result_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TranscriptionResultModel {

@JsonKey(name: 'transcriptionUid') String get transcriptionUid;@JsonKey(name: 'transcript') String get transcript;@JsonKey(name: 'detectedLanguage') String get detectedLanguage;@JsonKey(name: 'models') Map<String, String> get models;
/// Create a copy of TranscriptionResultModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranscriptionResultModelCopyWith<TranscriptionResultModel> get copyWith => _$TranscriptionResultModelCopyWithImpl<TranscriptionResultModel>(this as TranscriptionResultModel, _$identity);

  /// Serializes this TranscriptionResultModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranscriptionResultModel&&(identical(other.transcriptionUid, transcriptionUid) || other.transcriptionUid == transcriptionUid)&&(identical(other.transcript, transcript) || other.transcript == transcript)&&(identical(other.detectedLanguage, detectedLanguage) || other.detectedLanguage == detectedLanguage)&&const DeepCollectionEquality().equals(other.models, models));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,transcriptionUid,transcript,detectedLanguage,const DeepCollectionEquality().hash(models));

@override
String toString() {
  return 'TranscriptionResultModel(transcriptionUid: $transcriptionUid, transcript: $transcript, detectedLanguage: $detectedLanguage, models: $models)';
}


}

/// @nodoc
abstract mixin class $TranscriptionResultModelCopyWith<$Res>  {
  factory $TranscriptionResultModelCopyWith(TranscriptionResultModel value, $Res Function(TranscriptionResultModel) _then) = _$TranscriptionResultModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'transcriptionUid') String transcriptionUid,@JsonKey(name: 'transcript') String transcript,@JsonKey(name: 'detectedLanguage') String detectedLanguage,@JsonKey(name: 'models') Map<String, String> models
});




}
/// @nodoc
class _$TranscriptionResultModelCopyWithImpl<$Res>
    implements $TranscriptionResultModelCopyWith<$Res> {
  _$TranscriptionResultModelCopyWithImpl(this._self, this._then);

  final TranscriptionResultModel _self;
  final $Res Function(TranscriptionResultModel) _then;

/// Create a copy of TranscriptionResultModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transcriptionUid = null,Object? transcript = null,Object? detectedLanguage = null,Object? models = null,}) {
  return _then(_self.copyWith(
transcriptionUid: null == transcriptionUid ? _self.transcriptionUid : transcriptionUid // ignore: cast_nullable_to_non_nullable
as String,transcript: null == transcript ? _self.transcript : transcript // ignore: cast_nullable_to_non_nullable
as String,detectedLanguage: null == detectedLanguage ? _self.detectedLanguage : detectedLanguage // ignore: cast_nullable_to_non_nullable
as String,models: null == models ? _self.models : models // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [TranscriptionResultModel].
extension TranscriptionResultModelPatterns on TranscriptionResultModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranscriptionResultModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranscriptionResultModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranscriptionResultModel value)  $default,){
final _that = this;
switch (_that) {
case _TranscriptionResultModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranscriptionResultModel value)?  $default,){
final _that = this;
switch (_that) {
case _TranscriptionResultModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'transcriptionUid')  String transcriptionUid, @JsonKey(name: 'transcript')  String transcript, @JsonKey(name: 'detectedLanguage')  String detectedLanguage, @JsonKey(name: 'models')  Map<String, String> models)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranscriptionResultModel() when $default != null:
return $default(_that.transcriptionUid,_that.transcript,_that.detectedLanguage,_that.models);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'transcriptionUid')  String transcriptionUid, @JsonKey(name: 'transcript')  String transcript, @JsonKey(name: 'detectedLanguage')  String detectedLanguage, @JsonKey(name: 'models')  Map<String, String> models)  $default,) {final _that = this;
switch (_that) {
case _TranscriptionResultModel():
return $default(_that.transcriptionUid,_that.transcript,_that.detectedLanguage,_that.models);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'transcriptionUid')  String transcriptionUid, @JsonKey(name: 'transcript')  String transcript, @JsonKey(name: 'detectedLanguage')  String detectedLanguage, @JsonKey(name: 'models')  Map<String, String> models)?  $default,) {final _that = this;
switch (_that) {
case _TranscriptionResultModel() when $default != null:
return $default(_that.transcriptionUid,_that.transcript,_that.detectedLanguage,_that.models);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TranscriptionResultModel extends TranscriptionResultModel {
  const _TranscriptionResultModel({@JsonKey(name: 'transcriptionUid') this.transcriptionUid = '', @JsonKey(name: 'transcript') this.transcript = '', @JsonKey(name: 'detectedLanguage') this.detectedLanguage = '', @JsonKey(name: 'models') final  Map<String, String> models = const <String, String>{}}): _models = models,super._();
  factory _TranscriptionResultModel.fromJson(Map<String, dynamic> json) => _$TranscriptionResultModelFromJson(json);

@override@JsonKey(name: 'transcriptionUid') final  String transcriptionUid;
@override@JsonKey(name: 'transcript') final  String transcript;
@override@JsonKey(name: 'detectedLanguage') final  String detectedLanguage;
 final  Map<String, String> _models;
@override@JsonKey(name: 'models') Map<String, String> get models {
  if (_models is EqualUnmodifiableMapView) return _models;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_models);
}


/// Create a copy of TranscriptionResultModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranscriptionResultModelCopyWith<_TranscriptionResultModel> get copyWith => __$TranscriptionResultModelCopyWithImpl<_TranscriptionResultModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TranscriptionResultModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranscriptionResultModel&&(identical(other.transcriptionUid, transcriptionUid) || other.transcriptionUid == transcriptionUid)&&(identical(other.transcript, transcript) || other.transcript == transcript)&&(identical(other.detectedLanguage, detectedLanguage) || other.detectedLanguage == detectedLanguage)&&const DeepCollectionEquality().equals(other._models, _models));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,transcriptionUid,transcript,detectedLanguage,const DeepCollectionEquality().hash(_models));

@override
String toString() {
  return 'TranscriptionResultModel(transcriptionUid: $transcriptionUid, transcript: $transcript, detectedLanguage: $detectedLanguage, models: $models)';
}


}

/// @nodoc
abstract mixin class _$TranscriptionResultModelCopyWith<$Res> implements $TranscriptionResultModelCopyWith<$Res> {
  factory _$TranscriptionResultModelCopyWith(_TranscriptionResultModel value, $Res Function(_TranscriptionResultModel) _then) = __$TranscriptionResultModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'transcriptionUid') String transcriptionUid,@JsonKey(name: 'transcript') String transcript,@JsonKey(name: 'detectedLanguage') String detectedLanguage,@JsonKey(name: 'models') Map<String, String> models
});




}
/// @nodoc
class __$TranscriptionResultModelCopyWithImpl<$Res>
    implements _$TranscriptionResultModelCopyWith<$Res> {
  __$TranscriptionResultModelCopyWithImpl(this._self, this._then);

  final _TranscriptionResultModel _self;
  final $Res Function(_TranscriptionResultModel) _then;

/// Create a copy of TranscriptionResultModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transcriptionUid = null,Object? transcript = null,Object? detectedLanguage = null,Object? models = null,}) {
  return _then(_TranscriptionResultModel(
transcriptionUid: null == transcriptionUid ? _self.transcriptionUid : transcriptionUid // ignore: cast_nullable_to_non_nullable
as String,transcript: null == transcript ? _self.transcript : transcript // ignore: cast_nullable_to_non_nullable
as String,detectedLanguage: null == detectedLanguage ? _self.detectedLanguage : detectedLanguage // ignore: cast_nullable_to_non_nullable
as String,models: null == models ? _self._models : models // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
