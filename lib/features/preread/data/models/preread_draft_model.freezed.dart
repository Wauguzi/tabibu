// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preread_draft_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PrereadDraftModel {

@JsonKey(name: 'findings') List<PrereadFindingModel> get findings;@JsonKey(name: 'impression') String get impression;@JsonKey(name: 'confidence') double get confidence;@JsonKey(name: 'confidenceBand') String get confidenceBand;@JsonKey(name: 'urgency') String get urgency;@JsonKey(name: 'nextSteps') List<String> get nextSteps;
/// Create a copy of PrereadDraftModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrereadDraftModelCopyWith<PrereadDraftModel> get copyWith => _$PrereadDraftModelCopyWithImpl<PrereadDraftModel>(this as PrereadDraftModel, _$identity);

  /// Serializes this PrereadDraftModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrereadDraftModel&&const DeepCollectionEquality().equals(other.findings, findings)&&(identical(other.impression, impression) || other.impression == impression)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.confidenceBand, confidenceBand) || other.confidenceBand == confidenceBand)&&(identical(other.urgency, urgency) || other.urgency == urgency)&&const DeepCollectionEquality().equals(other.nextSteps, nextSteps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(findings),impression,confidence,confidenceBand,urgency,const DeepCollectionEquality().hash(nextSteps));

@override
String toString() {
  return 'PrereadDraftModel(findings: $findings, impression: $impression, confidence: $confidence, confidenceBand: $confidenceBand, urgency: $urgency, nextSteps: $nextSteps)';
}


}

/// @nodoc
abstract mixin class $PrereadDraftModelCopyWith<$Res>  {
  factory $PrereadDraftModelCopyWith(PrereadDraftModel value, $Res Function(PrereadDraftModel) _then) = _$PrereadDraftModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'findings') List<PrereadFindingModel> findings,@JsonKey(name: 'impression') String impression,@JsonKey(name: 'confidence') double confidence,@JsonKey(name: 'confidenceBand') String confidenceBand,@JsonKey(name: 'urgency') String urgency,@JsonKey(name: 'nextSteps') List<String> nextSteps
});




}
/// @nodoc
class _$PrereadDraftModelCopyWithImpl<$Res>
    implements $PrereadDraftModelCopyWith<$Res> {
  _$PrereadDraftModelCopyWithImpl(this._self, this._then);

  final PrereadDraftModel _self;
  final $Res Function(PrereadDraftModel) _then;

/// Create a copy of PrereadDraftModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? findings = null,Object? impression = null,Object? confidence = null,Object? confidenceBand = null,Object? urgency = null,Object? nextSteps = null,}) {
  return _then(_self.copyWith(
findings: null == findings ? _self.findings : findings // ignore: cast_nullable_to_non_nullable
as List<PrereadFindingModel>,impression: null == impression ? _self.impression : impression // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,confidenceBand: null == confidenceBand ? _self.confidenceBand : confidenceBand // ignore: cast_nullable_to_non_nullable
as String,urgency: null == urgency ? _self.urgency : urgency // ignore: cast_nullable_to_non_nullable
as String,nextSteps: null == nextSteps ? _self.nextSteps : nextSteps // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [PrereadDraftModel].
extension PrereadDraftModelPatterns on PrereadDraftModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrereadDraftModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrereadDraftModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrereadDraftModel value)  $default,){
final _that = this;
switch (_that) {
case _PrereadDraftModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrereadDraftModel value)?  $default,){
final _that = this;
switch (_that) {
case _PrereadDraftModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'findings')  List<PrereadFindingModel> findings, @JsonKey(name: 'impression')  String impression, @JsonKey(name: 'confidence')  double confidence, @JsonKey(name: 'confidenceBand')  String confidenceBand, @JsonKey(name: 'urgency')  String urgency, @JsonKey(name: 'nextSteps')  List<String> nextSteps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrereadDraftModel() when $default != null:
return $default(_that.findings,_that.impression,_that.confidence,_that.confidenceBand,_that.urgency,_that.nextSteps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'findings')  List<PrereadFindingModel> findings, @JsonKey(name: 'impression')  String impression, @JsonKey(name: 'confidence')  double confidence, @JsonKey(name: 'confidenceBand')  String confidenceBand, @JsonKey(name: 'urgency')  String urgency, @JsonKey(name: 'nextSteps')  List<String> nextSteps)  $default,) {final _that = this;
switch (_that) {
case _PrereadDraftModel():
return $default(_that.findings,_that.impression,_that.confidence,_that.confidenceBand,_that.urgency,_that.nextSteps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'findings')  List<PrereadFindingModel> findings, @JsonKey(name: 'impression')  String impression, @JsonKey(name: 'confidence')  double confidence, @JsonKey(name: 'confidenceBand')  String confidenceBand, @JsonKey(name: 'urgency')  String urgency, @JsonKey(name: 'nextSteps')  List<String> nextSteps)?  $default,) {final _that = this;
switch (_that) {
case _PrereadDraftModel() when $default != null:
return $default(_that.findings,_that.impression,_that.confidence,_that.confidenceBand,_that.urgency,_that.nextSteps);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _PrereadDraftModel extends PrereadDraftModel {
  const _PrereadDraftModel({@JsonKey(name: 'findings') final  List<PrereadFindingModel> findings = const <PrereadFindingModel>[], @JsonKey(name: 'impression') this.impression = '', @JsonKey(name: 'confidence') this.confidence = 0, @JsonKey(name: 'confidenceBand') this.confidenceBand = '', @JsonKey(name: 'urgency') this.urgency = '', @JsonKey(name: 'nextSteps') final  List<String> nextSteps = const <String>[]}): _findings = findings,_nextSteps = nextSteps,super._();
  factory _PrereadDraftModel.fromJson(Map<String, dynamic> json) => _$PrereadDraftModelFromJson(json);

 final  List<PrereadFindingModel> _findings;
@override@JsonKey(name: 'findings') List<PrereadFindingModel> get findings {
  if (_findings is EqualUnmodifiableListView) return _findings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_findings);
}

@override@JsonKey(name: 'impression') final  String impression;
@override@JsonKey(name: 'confidence') final  double confidence;
@override@JsonKey(name: 'confidenceBand') final  String confidenceBand;
@override@JsonKey(name: 'urgency') final  String urgency;
 final  List<String> _nextSteps;
@override@JsonKey(name: 'nextSteps') List<String> get nextSteps {
  if (_nextSteps is EqualUnmodifiableListView) return _nextSteps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_nextSteps);
}


/// Create a copy of PrereadDraftModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrereadDraftModelCopyWith<_PrereadDraftModel> get copyWith => __$PrereadDraftModelCopyWithImpl<_PrereadDraftModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrereadDraftModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrereadDraftModel&&const DeepCollectionEquality().equals(other._findings, _findings)&&(identical(other.impression, impression) || other.impression == impression)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.confidenceBand, confidenceBand) || other.confidenceBand == confidenceBand)&&(identical(other.urgency, urgency) || other.urgency == urgency)&&const DeepCollectionEquality().equals(other._nextSteps, _nextSteps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_findings),impression,confidence,confidenceBand,urgency,const DeepCollectionEquality().hash(_nextSteps));

@override
String toString() {
  return 'PrereadDraftModel(findings: $findings, impression: $impression, confidence: $confidence, confidenceBand: $confidenceBand, urgency: $urgency, nextSteps: $nextSteps)';
}


}

/// @nodoc
abstract mixin class _$PrereadDraftModelCopyWith<$Res> implements $PrereadDraftModelCopyWith<$Res> {
  factory _$PrereadDraftModelCopyWith(_PrereadDraftModel value, $Res Function(_PrereadDraftModel) _then) = __$PrereadDraftModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'findings') List<PrereadFindingModel> findings,@JsonKey(name: 'impression') String impression,@JsonKey(name: 'confidence') double confidence,@JsonKey(name: 'confidenceBand') String confidenceBand,@JsonKey(name: 'urgency') String urgency,@JsonKey(name: 'nextSteps') List<String> nextSteps
});




}
/// @nodoc
class __$PrereadDraftModelCopyWithImpl<$Res>
    implements _$PrereadDraftModelCopyWith<$Res> {
  __$PrereadDraftModelCopyWithImpl(this._self, this._then);

  final _PrereadDraftModel _self;
  final $Res Function(_PrereadDraftModel) _then;

/// Create a copy of PrereadDraftModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? findings = null,Object? impression = null,Object? confidence = null,Object? confidenceBand = null,Object? urgency = null,Object? nextSteps = null,}) {
  return _then(_PrereadDraftModel(
findings: null == findings ? _self._findings : findings // ignore: cast_nullable_to_non_nullable
as List<PrereadFindingModel>,impression: null == impression ? _self.impression : impression // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,confidenceBand: null == confidenceBand ? _self.confidenceBand : confidenceBand // ignore: cast_nullable_to_non_nullable
as String,urgency: null == urgency ? _self.urgency : urgency // ignore: cast_nullable_to_non_nullable
as String,nextSteps: null == nextSteps ? _self._nextSteps : nextSteps // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
