// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'intake_draft_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IntakeDraftModel {

@JsonKey(name: 'chiefComplaint') String get chiefComplaint;@JsonKey(name: 'symptoms') List<String> get symptoms;@JsonKey(name: 'duration') String get duration;@JsonKey(name: 'redFlags') List<String> get redFlags;@JsonKey(name: 'summary') String get summary;@JsonKey(name: 'isTranslation') bool get isTranslation;
/// Create a copy of IntakeDraftModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IntakeDraftModelCopyWith<IntakeDraftModel> get copyWith => _$IntakeDraftModelCopyWithImpl<IntakeDraftModel>(this as IntakeDraftModel, _$identity);

  /// Serializes this IntakeDraftModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IntakeDraftModel&&(identical(other.chiefComplaint, chiefComplaint) || other.chiefComplaint == chiefComplaint)&&const DeepCollectionEquality().equals(other.symptoms, symptoms)&&(identical(other.duration, duration) || other.duration == duration)&&const DeepCollectionEquality().equals(other.redFlags, redFlags)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.isTranslation, isTranslation) || other.isTranslation == isTranslation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,chiefComplaint,const DeepCollectionEquality().hash(symptoms),duration,const DeepCollectionEquality().hash(redFlags),summary,isTranslation);

@override
String toString() {
  return 'IntakeDraftModel(chiefComplaint: $chiefComplaint, symptoms: $symptoms, duration: $duration, redFlags: $redFlags, summary: $summary, isTranslation: $isTranslation)';
}


}

/// @nodoc
abstract mixin class $IntakeDraftModelCopyWith<$Res>  {
  factory $IntakeDraftModelCopyWith(IntakeDraftModel value, $Res Function(IntakeDraftModel) _then) = _$IntakeDraftModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'chiefComplaint') String chiefComplaint,@JsonKey(name: 'symptoms') List<String> symptoms,@JsonKey(name: 'duration') String duration,@JsonKey(name: 'redFlags') List<String> redFlags,@JsonKey(name: 'summary') String summary,@JsonKey(name: 'isTranslation') bool isTranslation
});




}
/// @nodoc
class _$IntakeDraftModelCopyWithImpl<$Res>
    implements $IntakeDraftModelCopyWith<$Res> {
  _$IntakeDraftModelCopyWithImpl(this._self, this._then);

  final IntakeDraftModel _self;
  final $Res Function(IntakeDraftModel) _then;

/// Create a copy of IntakeDraftModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chiefComplaint = null,Object? symptoms = null,Object? duration = null,Object? redFlags = null,Object? summary = null,Object? isTranslation = null,}) {
  return _then(_self.copyWith(
chiefComplaint: null == chiefComplaint ? _self.chiefComplaint : chiefComplaint // ignore: cast_nullable_to_non_nullable
as String,symptoms: null == symptoms ? _self.symptoms : symptoms // ignore: cast_nullable_to_non_nullable
as List<String>,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String,redFlags: null == redFlags ? _self.redFlags : redFlags // ignore: cast_nullable_to_non_nullable
as List<String>,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,isTranslation: null == isTranslation ? _self.isTranslation : isTranslation // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [IntakeDraftModel].
extension IntakeDraftModelPatterns on IntakeDraftModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IntakeDraftModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IntakeDraftModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IntakeDraftModel value)  $default,){
final _that = this;
switch (_that) {
case _IntakeDraftModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IntakeDraftModel value)?  $default,){
final _that = this;
switch (_that) {
case _IntakeDraftModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'chiefComplaint')  String chiefComplaint, @JsonKey(name: 'symptoms')  List<String> symptoms, @JsonKey(name: 'duration')  String duration, @JsonKey(name: 'redFlags')  List<String> redFlags, @JsonKey(name: 'summary')  String summary, @JsonKey(name: 'isTranslation')  bool isTranslation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IntakeDraftModel() when $default != null:
return $default(_that.chiefComplaint,_that.symptoms,_that.duration,_that.redFlags,_that.summary,_that.isTranslation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'chiefComplaint')  String chiefComplaint, @JsonKey(name: 'symptoms')  List<String> symptoms, @JsonKey(name: 'duration')  String duration, @JsonKey(name: 'redFlags')  List<String> redFlags, @JsonKey(name: 'summary')  String summary, @JsonKey(name: 'isTranslation')  bool isTranslation)  $default,) {final _that = this;
switch (_that) {
case _IntakeDraftModel():
return $default(_that.chiefComplaint,_that.symptoms,_that.duration,_that.redFlags,_that.summary,_that.isTranslation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'chiefComplaint')  String chiefComplaint, @JsonKey(name: 'symptoms')  List<String> symptoms, @JsonKey(name: 'duration')  String duration, @JsonKey(name: 'redFlags')  List<String> redFlags, @JsonKey(name: 'summary')  String summary, @JsonKey(name: 'isTranslation')  bool isTranslation)?  $default,) {final _that = this;
switch (_that) {
case _IntakeDraftModel() when $default != null:
return $default(_that.chiefComplaint,_that.symptoms,_that.duration,_that.redFlags,_that.summary,_that.isTranslation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IntakeDraftModel extends IntakeDraftModel {
  const _IntakeDraftModel({@JsonKey(name: 'chiefComplaint') this.chiefComplaint = '', @JsonKey(name: 'symptoms') final  List<String> symptoms = const <String>[], @JsonKey(name: 'duration') this.duration = '', @JsonKey(name: 'redFlags') final  List<String> redFlags = const <String>[], @JsonKey(name: 'summary') this.summary = '', @JsonKey(name: 'isTranslation') this.isTranslation = false}): _symptoms = symptoms,_redFlags = redFlags,super._();
  factory _IntakeDraftModel.fromJson(Map<String, dynamic> json) => _$IntakeDraftModelFromJson(json);

@override@JsonKey(name: 'chiefComplaint') final  String chiefComplaint;
 final  List<String> _symptoms;
@override@JsonKey(name: 'symptoms') List<String> get symptoms {
  if (_symptoms is EqualUnmodifiableListView) return _symptoms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_symptoms);
}

@override@JsonKey(name: 'duration') final  String duration;
 final  List<String> _redFlags;
@override@JsonKey(name: 'redFlags') List<String> get redFlags {
  if (_redFlags is EqualUnmodifiableListView) return _redFlags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_redFlags);
}

@override@JsonKey(name: 'summary') final  String summary;
@override@JsonKey(name: 'isTranslation') final  bool isTranslation;

/// Create a copy of IntakeDraftModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IntakeDraftModelCopyWith<_IntakeDraftModel> get copyWith => __$IntakeDraftModelCopyWithImpl<_IntakeDraftModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IntakeDraftModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IntakeDraftModel&&(identical(other.chiefComplaint, chiefComplaint) || other.chiefComplaint == chiefComplaint)&&const DeepCollectionEquality().equals(other._symptoms, _symptoms)&&(identical(other.duration, duration) || other.duration == duration)&&const DeepCollectionEquality().equals(other._redFlags, _redFlags)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.isTranslation, isTranslation) || other.isTranslation == isTranslation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,chiefComplaint,const DeepCollectionEquality().hash(_symptoms),duration,const DeepCollectionEquality().hash(_redFlags),summary,isTranslation);

@override
String toString() {
  return 'IntakeDraftModel(chiefComplaint: $chiefComplaint, symptoms: $symptoms, duration: $duration, redFlags: $redFlags, summary: $summary, isTranslation: $isTranslation)';
}


}

/// @nodoc
abstract mixin class _$IntakeDraftModelCopyWith<$Res> implements $IntakeDraftModelCopyWith<$Res> {
  factory _$IntakeDraftModelCopyWith(_IntakeDraftModel value, $Res Function(_IntakeDraftModel) _then) = __$IntakeDraftModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'chiefComplaint') String chiefComplaint,@JsonKey(name: 'symptoms') List<String> symptoms,@JsonKey(name: 'duration') String duration,@JsonKey(name: 'redFlags') List<String> redFlags,@JsonKey(name: 'summary') String summary,@JsonKey(name: 'isTranslation') bool isTranslation
});




}
/// @nodoc
class __$IntakeDraftModelCopyWithImpl<$Res>
    implements _$IntakeDraftModelCopyWith<$Res> {
  __$IntakeDraftModelCopyWithImpl(this._self, this._then);

  final _IntakeDraftModel _self;
  final $Res Function(_IntakeDraftModel) _then;

/// Create a copy of IntakeDraftModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chiefComplaint = null,Object? symptoms = null,Object? duration = null,Object? redFlags = null,Object? summary = null,Object? isTranslation = null,}) {
  return _then(_IntakeDraftModel(
chiefComplaint: null == chiefComplaint ? _self.chiefComplaint : chiefComplaint // ignore: cast_nullable_to_non_nullable
as String,symptoms: null == symptoms ? _self._symptoms : symptoms // ignore: cast_nullable_to_non_nullable
as List<String>,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String,redFlags: null == redFlags ? _self._redFlags : redFlags // ignore: cast_nullable_to_non_nullable
as List<String>,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,isTranslation: null == isTranslation ? _self.isTranslation : isTranslation // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
