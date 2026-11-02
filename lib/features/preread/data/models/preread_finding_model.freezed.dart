// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preread_finding_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PrereadFindingModel {

@JsonKey(name: 'text') String get text;@JsonKey(name: 'evidenceIds') List<String> get evidenceIds;
/// Create a copy of PrereadFindingModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrereadFindingModelCopyWith<PrereadFindingModel> get copyWith => _$PrereadFindingModelCopyWithImpl<PrereadFindingModel>(this as PrereadFindingModel, _$identity);

  /// Serializes this PrereadFindingModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrereadFindingModel&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.evidenceIds, evidenceIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,const DeepCollectionEquality().hash(evidenceIds));

@override
String toString() {
  return 'PrereadFindingModel(text: $text, evidenceIds: $evidenceIds)';
}


}

/// @nodoc
abstract mixin class $PrereadFindingModelCopyWith<$Res>  {
  factory $PrereadFindingModelCopyWith(PrereadFindingModel value, $Res Function(PrereadFindingModel) _then) = _$PrereadFindingModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'text') String text,@JsonKey(name: 'evidenceIds') List<String> evidenceIds
});




}
/// @nodoc
class _$PrereadFindingModelCopyWithImpl<$Res>
    implements $PrereadFindingModelCopyWith<$Res> {
  _$PrereadFindingModelCopyWithImpl(this._self, this._then);

  final PrereadFindingModel _self;
  final $Res Function(PrereadFindingModel) _then;

/// Create a copy of PrereadFindingModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? evidenceIds = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,evidenceIds: null == evidenceIds ? _self.evidenceIds : evidenceIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [PrereadFindingModel].
extension PrereadFindingModelPatterns on PrereadFindingModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrereadFindingModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrereadFindingModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrereadFindingModel value)  $default,){
final _that = this;
switch (_that) {
case _PrereadFindingModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrereadFindingModel value)?  $default,){
final _that = this;
switch (_that) {
case _PrereadFindingModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'text')  String text, @JsonKey(name: 'evidenceIds')  List<String> evidenceIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrereadFindingModel() when $default != null:
return $default(_that.text,_that.evidenceIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'text')  String text, @JsonKey(name: 'evidenceIds')  List<String> evidenceIds)  $default,) {final _that = this;
switch (_that) {
case _PrereadFindingModel():
return $default(_that.text,_that.evidenceIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'text')  String text, @JsonKey(name: 'evidenceIds')  List<String> evidenceIds)?  $default,) {final _that = this;
switch (_that) {
case _PrereadFindingModel() when $default != null:
return $default(_that.text,_that.evidenceIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrereadFindingModel extends PrereadFindingModel {
  const _PrereadFindingModel({@JsonKey(name: 'text') this.text = '', @JsonKey(name: 'evidenceIds') final  List<String> evidenceIds = const <String>[]}): _evidenceIds = evidenceIds,super._();
  factory _PrereadFindingModel.fromJson(Map<String, dynamic> json) => _$PrereadFindingModelFromJson(json);

@override@JsonKey(name: 'text') final  String text;
 final  List<String> _evidenceIds;
@override@JsonKey(name: 'evidenceIds') List<String> get evidenceIds {
  if (_evidenceIds is EqualUnmodifiableListView) return _evidenceIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_evidenceIds);
}


/// Create a copy of PrereadFindingModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrereadFindingModelCopyWith<_PrereadFindingModel> get copyWith => __$PrereadFindingModelCopyWithImpl<_PrereadFindingModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrereadFindingModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrereadFindingModel&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other._evidenceIds, _evidenceIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,const DeepCollectionEquality().hash(_evidenceIds));

@override
String toString() {
  return 'PrereadFindingModel(text: $text, evidenceIds: $evidenceIds)';
}


}

/// @nodoc
abstract mixin class _$PrereadFindingModelCopyWith<$Res> implements $PrereadFindingModelCopyWith<$Res> {
  factory _$PrereadFindingModelCopyWith(_PrereadFindingModel value, $Res Function(_PrereadFindingModel) _then) = __$PrereadFindingModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'text') String text,@JsonKey(name: 'evidenceIds') List<String> evidenceIds
});




}
/// @nodoc
class __$PrereadFindingModelCopyWithImpl<$Res>
    implements _$PrereadFindingModelCopyWith<$Res> {
  __$PrereadFindingModelCopyWithImpl(this._self, this._then);

  final _PrereadFindingModel _self;
  final $Res Function(_PrereadFindingModel) _then;

/// Create a copy of PrereadFindingModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? evidenceIds = null,}) {
  return _then(_PrereadFindingModel(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,evidenceIds: null == evidenceIds ? _self._evidenceIds : evidenceIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
