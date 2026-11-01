// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'public_health_guidance_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PublicHealthGuidanceModel {

@JsonKey(name: 'diseaseId') String get diseaseId;@JsonKey(name: 'reviewedOn') String get reviewedOn;@JsonKey(name: 'bullets') List<GuidanceBulletModel> get bullets;@JsonKey(name: 'sources') List<GuidanceSourceModel> get sources;
/// Create a copy of PublicHealthGuidanceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicHealthGuidanceModelCopyWith<PublicHealthGuidanceModel> get copyWith => _$PublicHealthGuidanceModelCopyWithImpl<PublicHealthGuidanceModel>(this as PublicHealthGuidanceModel, _$identity);

  /// Serializes this PublicHealthGuidanceModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicHealthGuidanceModel&&(identical(other.diseaseId, diseaseId) || other.diseaseId == diseaseId)&&(identical(other.reviewedOn, reviewedOn) || other.reviewedOn == reviewedOn)&&const DeepCollectionEquality().equals(other.bullets, bullets)&&const DeepCollectionEquality().equals(other.sources, sources));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,diseaseId,reviewedOn,const DeepCollectionEquality().hash(bullets),const DeepCollectionEquality().hash(sources));

@override
String toString() {
  return 'PublicHealthGuidanceModel(diseaseId: $diseaseId, reviewedOn: $reviewedOn, bullets: $bullets, sources: $sources)';
}


}

/// @nodoc
abstract mixin class $PublicHealthGuidanceModelCopyWith<$Res>  {
  factory $PublicHealthGuidanceModelCopyWith(PublicHealthGuidanceModel value, $Res Function(PublicHealthGuidanceModel) _then) = _$PublicHealthGuidanceModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'diseaseId') String diseaseId,@JsonKey(name: 'reviewedOn') String reviewedOn,@JsonKey(name: 'bullets') List<GuidanceBulletModel> bullets,@JsonKey(name: 'sources') List<GuidanceSourceModel> sources
});




}
/// @nodoc
class _$PublicHealthGuidanceModelCopyWithImpl<$Res>
    implements $PublicHealthGuidanceModelCopyWith<$Res> {
  _$PublicHealthGuidanceModelCopyWithImpl(this._self, this._then);

  final PublicHealthGuidanceModel _self;
  final $Res Function(PublicHealthGuidanceModel) _then;

/// Create a copy of PublicHealthGuidanceModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? diseaseId = null,Object? reviewedOn = null,Object? bullets = null,Object? sources = null,}) {
  return _then(_self.copyWith(
diseaseId: null == diseaseId ? _self.diseaseId : diseaseId // ignore: cast_nullable_to_non_nullable
as String,reviewedOn: null == reviewedOn ? _self.reviewedOn : reviewedOn // ignore: cast_nullable_to_non_nullable
as String,bullets: null == bullets ? _self.bullets : bullets // ignore: cast_nullable_to_non_nullable
as List<GuidanceBulletModel>,sources: null == sources ? _self.sources : sources // ignore: cast_nullable_to_non_nullable
as List<GuidanceSourceModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [PublicHealthGuidanceModel].
extension PublicHealthGuidanceModelPatterns on PublicHealthGuidanceModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicHealthGuidanceModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicHealthGuidanceModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicHealthGuidanceModel value)  $default,){
final _that = this;
switch (_that) {
case _PublicHealthGuidanceModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicHealthGuidanceModel value)?  $default,){
final _that = this;
switch (_that) {
case _PublicHealthGuidanceModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'diseaseId')  String diseaseId, @JsonKey(name: 'reviewedOn')  String reviewedOn, @JsonKey(name: 'bullets')  List<GuidanceBulletModel> bullets, @JsonKey(name: 'sources')  List<GuidanceSourceModel> sources)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicHealthGuidanceModel() when $default != null:
return $default(_that.diseaseId,_that.reviewedOn,_that.bullets,_that.sources);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'diseaseId')  String diseaseId, @JsonKey(name: 'reviewedOn')  String reviewedOn, @JsonKey(name: 'bullets')  List<GuidanceBulletModel> bullets, @JsonKey(name: 'sources')  List<GuidanceSourceModel> sources)  $default,) {final _that = this;
switch (_that) {
case _PublicHealthGuidanceModel():
return $default(_that.diseaseId,_that.reviewedOn,_that.bullets,_that.sources);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'diseaseId')  String diseaseId, @JsonKey(name: 'reviewedOn')  String reviewedOn, @JsonKey(name: 'bullets')  List<GuidanceBulletModel> bullets, @JsonKey(name: 'sources')  List<GuidanceSourceModel> sources)?  $default,) {final _that = this;
switch (_that) {
case _PublicHealthGuidanceModel() when $default != null:
return $default(_that.diseaseId,_that.reviewedOn,_that.bullets,_that.sources);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _PublicHealthGuidanceModel extends PublicHealthGuidanceModel {
  const _PublicHealthGuidanceModel({@JsonKey(name: 'diseaseId') this.diseaseId = '', @JsonKey(name: 'reviewedOn') this.reviewedOn = '', @JsonKey(name: 'bullets') final  List<GuidanceBulletModel> bullets = const <GuidanceBulletModel>[], @JsonKey(name: 'sources') final  List<GuidanceSourceModel> sources = const <GuidanceSourceModel>[]}): _bullets = bullets,_sources = sources,super._();
  factory _PublicHealthGuidanceModel.fromJson(Map<String, dynamic> json) => _$PublicHealthGuidanceModelFromJson(json);

@override@JsonKey(name: 'diseaseId') final  String diseaseId;
@override@JsonKey(name: 'reviewedOn') final  String reviewedOn;
 final  List<GuidanceBulletModel> _bullets;
@override@JsonKey(name: 'bullets') List<GuidanceBulletModel> get bullets {
  if (_bullets is EqualUnmodifiableListView) return _bullets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bullets);
}

 final  List<GuidanceSourceModel> _sources;
@override@JsonKey(name: 'sources') List<GuidanceSourceModel> get sources {
  if (_sources is EqualUnmodifiableListView) return _sources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sources);
}


/// Create a copy of PublicHealthGuidanceModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicHealthGuidanceModelCopyWith<_PublicHealthGuidanceModel> get copyWith => __$PublicHealthGuidanceModelCopyWithImpl<_PublicHealthGuidanceModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublicHealthGuidanceModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicHealthGuidanceModel&&(identical(other.diseaseId, diseaseId) || other.diseaseId == diseaseId)&&(identical(other.reviewedOn, reviewedOn) || other.reviewedOn == reviewedOn)&&const DeepCollectionEquality().equals(other._bullets, _bullets)&&const DeepCollectionEquality().equals(other._sources, _sources));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,diseaseId,reviewedOn,const DeepCollectionEquality().hash(_bullets),const DeepCollectionEquality().hash(_sources));

@override
String toString() {
  return 'PublicHealthGuidanceModel(diseaseId: $diseaseId, reviewedOn: $reviewedOn, bullets: $bullets, sources: $sources)';
}


}

/// @nodoc
abstract mixin class _$PublicHealthGuidanceModelCopyWith<$Res> implements $PublicHealthGuidanceModelCopyWith<$Res> {
  factory _$PublicHealthGuidanceModelCopyWith(_PublicHealthGuidanceModel value, $Res Function(_PublicHealthGuidanceModel) _then) = __$PublicHealthGuidanceModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'diseaseId') String diseaseId,@JsonKey(name: 'reviewedOn') String reviewedOn,@JsonKey(name: 'bullets') List<GuidanceBulletModel> bullets,@JsonKey(name: 'sources') List<GuidanceSourceModel> sources
});




}
/// @nodoc
class __$PublicHealthGuidanceModelCopyWithImpl<$Res>
    implements _$PublicHealthGuidanceModelCopyWith<$Res> {
  __$PublicHealthGuidanceModelCopyWithImpl(this._self, this._then);

  final _PublicHealthGuidanceModel _self;
  final $Res Function(_PublicHealthGuidanceModel) _then;

/// Create a copy of PublicHealthGuidanceModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? diseaseId = null,Object? reviewedOn = null,Object? bullets = null,Object? sources = null,}) {
  return _then(_PublicHealthGuidanceModel(
diseaseId: null == diseaseId ? _self.diseaseId : diseaseId // ignore: cast_nullable_to_non_nullable
as String,reviewedOn: null == reviewedOn ? _self.reviewedOn : reviewedOn // ignore: cast_nullable_to_non_nullable
as String,bullets: null == bullets ? _self._bullets : bullets // ignore: cast_nullable_to_non_nullable
as List<GuidanceBulletModel>,sources: null == sources ? _self._sources : sources // ignore: cast_nullable_to_non_nullable
as List<GuidanceSourceModel>,
  ));
}


}

// dart format on
