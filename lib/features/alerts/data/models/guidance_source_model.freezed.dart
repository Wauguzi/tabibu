// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'guidance_source_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GuidanceSourceModel {

@JsonKey(name: 'sourceId') String get sourceId;@JsonKey(name: 'title') String get title;@JsonKey(name: 'publisher') String get publisher;@JsonKey(name: 'url') String get url;@JsonKey(name: 'publishedOn') String get publishedOn;@JsonKey(name: 'accessedOn') String get accessedOn;
/// Create a copy of GuidanceSourceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuidanceSourceModelCopyWith<GuidanceSourceModel> get copyWith => _$GuidanceSourceModelCopyWithImpl<GuidanceSourceModel>(this as GuidanceSourceModel, _$identity);

  /// Serializes this GuidanceSourceModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuidanceSourceModel&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.title, title) || other.title == title)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.url, url) || other.url == url)&&(identical(other.publishedOn, publishedOn) || other.publishedOn == publishedOn)&&(identical(other.accessedOn, accessedOn) || other.accessedOn == accessedOn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sourceId,title,publisher,url,publishedOn,accessedOn);

@override
String toString() {
  return 'GuidanceSourceModel(sourceId: $sourceId, title: $title, publisher: $publisher, url: $url, publishedOn: $publishedOn, accessedOn: $accessedOn)';
}


}

/// @nodoc
abstract mixin class $GuidanceSourceModelCopyWith<$Res>  {
  factory $GuidanceSourceModelCopyWith(GuidanceSourceModel value, $Res Function(GuidanceSourceModel) _then) = _$GuidanceSourceModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'sourceId') String sourceId,@JsonKey(name: 'title') String title,@JsonKey(name: 'publisher') String publisher,@JsonKey(name: 'url') String url,@JsonKey(name: 'publishedOn') String publishedOn,@JsonKey(name: 'accessedOn') String accessedOn
});




}
/// @nodoc
class _$GuidanceSourceModelCopyWithImpl<$Res>
    implements $GuidanceSourceModelCopyWith<$Res> {
  _$GuidanceSourceModelCopyWithImpl(this._self, this._then);

  final GuidanceSourceModel _self;
  final $Res Function(GuidanceSourceModel) _then;

/// Create a copy of GuidanceSourceModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sourceId = null,Object? title = null,Object? publisher = null,Object? url = null,Object? publishedOn = null,Object? accessedOn = null,}) {
  return _then(_self.copyWith(
sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,publisher: null == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,publishedOn: null == publishedOn ? _self.publishedOn : publishedOn // ignore: cast_nullable_to_non_nullable
as String,accessedOn: null == accessedOn ? _self.accessedOn : accessedOn // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GuidanceSourceModel].
extension GuidanceSourceModelPatterns on GuidanceSourceModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuidanceSourceModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuidanceSourceModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuidanceSourceModel value)  $default,){
final _that = this;
switch (_that) {
case _GuidanceSourceModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuidanceSourceModel value)?  $default,){
final _that = this;
switch (_that) {
case _GuidanceSourceModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'sourceId')  String sourceId, @JsonKey(name: 'title')  String title, @JsonKey(name: 'publisher')  String publisher, @JsonKey(name: 'url')  String url, @JsonKey(name: 'publishedOn')  String publishedOn, @JsonKey(name: 'accessedOn')  String accessedOn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuidanceSourceModel() when $default != null:
return $default(_that.sourceId,_that.title,_that.publisher,_that.url,_that.publishedOn,_that.accessedOn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'sourceId')  String sourceId, @JsonKey(name: 'title')  String title, @JsonKey(name: 'publisher')  String publisher, @JsonKey(name: 'url')  String url, @JsonKey(name: 'publishedOn')  String publishedOn, @JsonKey(name: 'accessedOn')  String accessedOn)  $default,) {final _that = this;
switch (_that) {
case _GuidanceSourceModel():
return $default(_that.sourceId,_that.title,_that.publisher,_that.url,_that.publishedOn,_that.accessedOn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'sourceId')  String sourceId, @JsonKey(name: 'title')  String title, @JsonKey(name: 'publisher')  String publisher, @JsonKey(name: 'url')  String url, @JsonKey(name: 'publishedOn')  String publishedOn, @JsonKey(name: 'accessedOn')  String accessedOn)?  $default,) {final _that = this;
switch (_that) {
case _GuidanceSourceModel() when $default != null:
return $default(_that.sourceId,_that.title,_that.publisher,_that.url,_that.publishedOn,_that.accessedOn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GuidanceSourceModel extends GuidanceSourceModel {
  const _GuidanceSourceModel({@JsonKey(name: 'sourceId') this.sourceId = '', @JsonKey(name: 'title') this.title = '', @JsonKey(name: 'publisher') this.publisher = '', @JsonKey(name: 'url') this.url = '', @JsonKey(name: 'publishedOn') this.publishedOn = '', @JsonKey(name: 'accessedOn') this.accessedOn = ''}): super._();
  factory _GuidanceSourceModel.fromJson(Map<String, dynamic> json) => _$GuidanceSourceModelFromJson(json);

@override@JsonKey(name: 'sourceId') final  String sourceId;
@override@JsonKey(name: 'title') final  String title;
@override@JsonKey(name: 'publisher') final  String publisher;
@override@JsonKey(name: 'url') final  String url;
@override@JsonKey(name: 'publishedOn') final  String publishedOn;
@override@JsonKey(name: 'accessedOn') final  String accessedOn;

/// Create a copy of GuidanceSourceModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuidanceSourceModelCopyWith<_GuidanceSourceModel> get copyWith => __$GuidanceSourceModelCopyWithImpl<_GuidanceSourceModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuidanceSourceModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuidanceSourceModel&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.title, title) || other.title == title)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.url, url) || other.url == url)&&(identical(other.publishedOn, publishedOn) || other.publishedOn == publishedOn)&&(identical(other.accessedOn, accessedOn) || other.accessedOn == accessedOn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sourceId,title,publisher,url,publishedOn,accessedOn);

@override
String toString() {
  return 'GuidanceSourceModel(sourceId: $sourceId, title: $title, publisher: $publisher, url: $url, publishedOn: $publishedOn, accessedOn: $accessedOn)';
}


}

/// @nodoc
abstract mixin class _$GuidanceSourceModelCopyWith<$Res> implements $GuidanceSourceModelCopyWith<$Res> {
  factory _$GuidanceSourceModelCopyWith(_GuidanceSourceModel value, $Res Function(_GuidanceSourceModel) _then) = __$GuidanceSourceModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'sourceId') String sourceId,@JsonKey(name: 'title') String title,@JsonKey(name: 'publisher') String publisher,@JsonKey(name: 'url') String url,@JsonKey(name: 'publishedOn') String publishedOn,@JsonKey(name: 'accessedOn') String accessedOn
});




}
/// @nodoc
class __$GuidanceSourceModelCopyWithImpl<$Res>
    implements _$GuidanceSourceModelCopyWith<$Res> {
  __$GuidanceSourceModelCopyWithImpl(this._self, this._then);

  final _GuidanceSourceModel _self;
  final $Res Function(_GuidanceSourceModel) _then;

/// Create a copy of GuidanceSourceModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sourceId = null,Object? title = null,Object? publisher = null,Object? url = null,Object? publishedOn = null,Object? accessedOn = null,}) {
  return _then(_GuidanceSourceModel(
sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,publisher: null == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,publishedOn: null == publishedOn ? _self.publishedOn : publishedOn // ignore: cast_nullable_to_non_nullable
as String,accessedOn: null == accessedOn ? _self.accessedOn : accessedOn // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
