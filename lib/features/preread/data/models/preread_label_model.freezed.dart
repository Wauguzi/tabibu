// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preread_label_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PrereadLabelModel {

@JsonKey(name: 'id') String get id;@JsonKey(name: 'imageUid') String get imageUid;@JsonKey(name: 'label') String get label;@JsonKey(name: 'probability') double get probability;
/// Create a copy of PrereadLabelModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrereadLabelModelCopyWith<PrereadLabelModel> get copyWith => _$PrereadLabelModelCopyWithImpl<PrereadLabelModel>(this as PrereadLabelModel, _$identity);

  /// Serializes this PrereadLabelModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrereadLabelModel&&(identical(other.id, id) || other.id == id)&&(identical(other.imageUid, imageUid) || other.imageUid == imageUid)&&(identical(other.label, label) || other.label == label)&&(identical(other.probability, probability) || other.probability == probability));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,imageUid,label,probability);

@override
String toString() {
  return 'PrereadLabelModel(id: $id, imageUid: $imageUid, label: $label, probability: $probability)';
}


}

/// @nodoc
abstract mixin class $PrereadLabelModelCopyWith<$Res>  {
  factory $PrereadLabelModelCopyWith(PrereadLabelModel value, $Res Function(PrereadLabelModel) _then) = _$PrereadLabelModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'imageUid') String imageUid,@JsonKey(name: 'label') String label,@JsonKey(name: 'probability') double probability
});




}
/// @nodoc
class _$PrereadLabelModelCopyWithImpl<$Res>
    implements $PrereadLabelModelCopyWith<$Res> {
  _$PrereadLabelModelCopyWithImpl(this._self, this._then);

  final PrereadLabelModel _self;
  final $Res Function(PrereadLabelModel) _then;

/// Create a copy of PrereadLabelModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? imageUid = null,Object? label = null,Object? probability = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,imageUid: null == imageUid ? _self.imageUid : imageUid // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,probability: null == probability ? _self.probability : probability // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PrereadLabelModel].
extension PrereadLabelModelPatterns on PrereadLabelModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrereadLabelModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrereadLabelModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrereadLabelModel value)  $default,){
final _that = this;
switch (_that) {
case _PrereadLabelModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrereadLabelModel value)?  $default,){
final _that = this;
switch (_that) {
case _PrereadLabelModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'imageUid')  String imageUid, @JsonKey(name: 'label')  String label, @JsonKey(name: 'probability')  double probability)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrereadLabelModel() when $default != null:
return $default(_that.id,_that.imageUid,_that.label,_that.probability);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'imageUid')  String imageUid, @JsonKey(name: 'label')  String label, @JsonKey(name: 'probability')  double probability)  $default,) {final _that = this;
switch (_that) {
case _PrereadLabelModel():
return $default(_that.id,_that.imageUid,_that.label,_that.probability);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'imageUid')  String imageUid, @JsonKey(name: 'label')  String label, @JsonKey(name: 'probability')  double probability)?  $default,) {final _that = this;
switch (_that) {
case _PrereadLabelModel() when $default != null:
return $default(_that.id,_that.imageUid,_that.label,_that.probability);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrereadLabelModel extends PrereadLabelModel {
  const _PrereadLabelModel({@JsonKey(name: 'id') this.id = '', @JsonKey(name: 'imageUid') this.imageUid = '', @JsonKey(name: 'label') this.label = '', @JsonKey(name: 'probability') this.probability = 0}): super._();
  factory _PrereadLabelModel.fromJson(Map<String, dynamic> json) => _$PrereadLabelModelFromJson(json);

@override@JsonKey(name: 'id') final  String id;
@override@JsonKey(name: 'imageUid') final  String imageUid;
@override@JsonKey(name: 'label') final  String label;
@override@JsonKey(name: 'probability') final  double probability;

/// Create a copy of PrereadLabelModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrereadLabelModelCopyWith<_PrereadLabelModel> get copyWith => __$PrereadLabelModelCopyWithImpl<_PrereadLabelModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrereadLabelModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrereadLabelModel&&(identical(other.id, id) || other.id == id)&&(identical(other.imageUid, imageUid) || other.imageUid == imageUid)&&(identical(other.label, label) || other.label == label)&&(identical(other.probability, probability) || other.probability == probability));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,imageUid,label,probability);

@override
String toString() {
  return 'PrereadLabelModel(id: $id, imageUid: $imageUid, label: $label, probability: $probability)';
}


}

/// @nodoc
abstract mixin class _$PrereadLabelModelCopyWith<$Res> implements $PrereadLabelModelCopyWith<$Res> {
  factory _$PrereadLabelModelCopyWith(_PrereadLabelModel value, $Res Function(_PrereadLabelModel) _then) = __$PrereadLabelModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'imageUid') String imageUid,@JsonKey(name: 'label') String label,@JsonKey(name: 'probability') double probability
});




}
/// @nodoc
class __$PrereadLabelModelCopyWithImpl<$Res>
    implements _$PrereadLabelModelCopyWith<$Res> {
  __$PrereadLabelModelCopyWithImpl(this._self, this._then);

  final _PrereadLabelModel _self;
  final $Res Function(_PrereadLabelModel) _then;

/// Create a copy of PrereadLabelModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? imageUid = null,Object? label = null,Object? probability = null,}) {
  return _then(_PrereadLabelModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,imageUid: null == imageUid ? _self.imageUid : imageUid // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,probability: null == probability ? _self.probability : probability // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
