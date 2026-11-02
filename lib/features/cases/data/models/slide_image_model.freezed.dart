// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slide_image_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SlideImageModel {

@JsonKey(name: 'imageUid') String get imageUid;@JsonKey(name: 'path') String get path;@JsonKey(name: 'contentType') String get contentType;@JsonKey(name: 'micronsPerPixel') double get micronsPerPixel;@JsonKey(name: 'uploadedByUid') String get uploadedByUid;@JsonKey(name: 'uploadedAt') String get uploadedAt;
/// Create a copy of SlideImageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlideImageModelCopyWith<SlideImageModel> get copyWith => _$SlideImageModelCopyWithImpl<SlideImageModel>(this as SlideImageModel, _$identity);

  /// Serializes this SlideImageModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlideImageModel&&(identical(other.imageUid, imageUid) || other.imageUid == imageUid)&&(identical(other.path, path) || other.path == path)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.micronsPerPixel, micronsPerPixel) || other.micronsPerPixel == micronsPerPixel)&&(identical(other.uploadedByUid, uploadedByUid) || other.uploadedByUid == uploadedByUid)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageUid,path,contentType,micronsPerPixel,uploadedByUid,uploadedAt);

@override
String toString() {
  return 'SlideImageModel(imageUid: $imageUid, path: $path, contentType: $contentType, micronsPerPixel: $micronsPerPixel, uploadedByUid: $uploadedByUid, uploadedAt: $uploadedAt)';
}


}

/// @nodoc
abstract mixin class $SlideImageModelCopyWith<$Res>  {
  factory $SlideImageModelCopyWith(SlideImageModel value, $Res Function(SlideImageModel) _then) = _$SlideImageModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'imageUid') String imageUid,@JsonKey(name: 'path') String path,@JsonKey(name: 'contentType') String contentType,@JsonKey(name: 'micronsPerPixel') double micronsPerPixel,@JsonKey(name: 'uploadedByUid') String uploadedByUid,@JsonKey(name: 'uploadedAt') String uploadedAt
});




}
/// @nodoc
class _$SlideImageModelCopyWithImpl<$Res>
    implements $SlideImageModelCopyWith<$Res> {
  _$SlideImageModelCopyWithImpl(this._self, this._then);

  final SlideImageModel _self;
  final $Res Function(SlideImageModel) _then;

/// Create a copy of SlideImageModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? imageUid = null,Object? path = null,Object? contentType = null,Object? micronsPerPixel = null,Object? uploadedByUid = null,Object? uploadedAt = null,}) {
  return _then(_self.copyWith(
imageUid: null == imageUid ? _self.imageUid : imageUid // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,micronsPerPixel: null == micronsPerPixel ? _self.micronsPerPixel : micronsPerPixel // ignore: cast_nullable_to_non_nullable
as double,uploadedByUid: null == uploadedByUid ? _self.uploadedByUid : uploadedByUid // ignore: cast_nullable_to_non_nullable
as String,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SlideImageModel].
extension SlideImageModelPatterns on SlideImageModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SlideImageModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SlideImageModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SlideImageModel value)  $default,){
final _that = this;
switch (_that) {
case _SlideImageModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SlideImageModel value)?  $default,){
final _that = this;
switch (_that) {
case _SlideImageModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'imageUid')  String imageUid, @JsonKey(name: 'path')  String path, @JsonKey(name: 'contentType')  String contentType, @JsonKey(name: 'micronsPerPixel')  double micronsPerPixel, @JsonKey(name: 'uploadedByUid')  String uploadedByUid, @JsonKey(name: 'uploadedAt')  String uploadedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SlideImageModel() when $default != null:
return $default(_that.imageUid,_that.path,_that.contentType,_that.micronsPerPixel,_that.uploadedByUid,_that.uploadedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'imageUid')  String imageUid, @JsonKey(name: 'path')  String path, @JsonKey(name: 'contentType')  String contentType, @JsonKey(name: 'micronsPerPixel')  double micronsPerPixel, @JsonKey(name: 'uploadedByUid')  String uploadedByUid, @JsonKey(name: 'uploadedAt')  String uploadedAt)  $default,) {final _that = this;
switch (_that) {
case _SlideImageModel():
return $default(_that.imageUid,_that.path,_that.contentType,_that.micronsPerPixel,_that.uploadedByUid,_that.uploadedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'imageUid')  String imageUid, @JsonKey(name: 'path')  String path, @JsonKey(name: 'contentType')  String contentType, @JsonKey(name: 'micronsPerPixel')  double micronsPerPixel, @JsonKey(name: 'uploadedByUid')  String uploadedByUid, @JsonKey(name: 'uploadedAt')  String uploadedAt)?  $default,) {final _that = this;
switch (_that) {
case _SlideImageModel() when $default != null:
return $default(_that.imageUid,_that.path,_that.contentType,_that.micronsPerPixel,_that.uploadedByUid,_that.uploadedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SlideImageModel implements SlideImageModel {
  const _SlideImageModel({@JsonKey(name: 'imageUid') this.imageUid = '', @JsonKey(name: 'path') this.path = '', @JsonKey(name: 'contentType') this.contentType = '', @JsonKey(name: 'micronsPerPixel') this.micronsPerPixel = 0.0, @JsonKey(name: 'uploadedByUid') this.uploadedByUid = '', @JsonKey(name: 'uploadedAt') this.uploadedAt = ''});
  factory _SlideImageModel.fromJson(Map<String, dynamic> json) => _$SlideImageModelFromJson(json);

@override@JsonKey(name: 'imageUid') final  String imageUid;
@override@JsonKey(name: 'path') final  String path;
@override@JsonKey(name: 'contentType') final  String contentType;
@override@JsonKey(name: 'micronsPerPixel') final  double micronsPerPixel;
@override@JsonKey(name: 'uploadedByUid') final  String uploadedByUid;
@override@JsonKey(name: 'uploadedAt') final  String uploadedAt;

/// Create a copy of SlideImageModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SlideImageModelCopyWith<_SlideImageModel> get copyWith => __$SlideImageModelCopyWithImpl<_SlideImageModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SlideImageModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SlideImageModel&&(identical(other.imageUid, imageUid) || other.imageUid == imageUid)&&(identical(other.path, path) || other.path == path)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.micronsPerPixel, micronsPerPixel) || other.micronsPerPixel == micronsPerPixel)&&(identical(other.uploadedByUid, uploadedByUid) || other.uploadedByUid == uploadedByUid)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageUid,path,contentType,micronsPerPixel,uploadedByUid,uploadedAt);

@override
String toString() {
  return 'SlideImageModel(imageUid: $imageUid, path: $path, contentType: $contentType, micronsPerPixel: $micronsPerPixel, uploadedByUid: $uploadedByUid, uploadedAt: $uploadedAt)';
}


}

/// @nodoc
abstract mixin class _$SlideImageModelCopyWith<$Res> implements $SlideImageModelCopyWith<$Res> {
  factory _$SlideImageModelCopyWith(_SlideImageModel value, $Res Function(_SlideImageModel) _then) = __$SlideImageModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'imageUid') String imageUid,@JsonKey(name: 'path') String path,@JsonKey(name: 'contentType') String contentType,@JsonKey(name: 'micronsPerPixel') double micronsPerPixel,@JsonKey(name: 'uploadedByUid') String uploadedByUid,@JsonKey(name: 'uploadedAt') String uploadedAt
});




}
/// @nodoc
class __$SlideImageModelCopyWithImpl<$Res>
    implements _$SlideImageModelCopyWith<$Res> {
  __$SlideImageModelCopyWithImpl(this._self, this._then);

  final _SlideImageModel _self;
  final $Res Function(_SlideImageModel) _then;

/// Create a copy of SlideImageModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? imageUid = null,Object? path = null,Object? contentType = null,Object? micronsPerPixel = null,Object? uploadedByUid = null,Object? uploadedAt = null,}) {
  return _then(_SlideImageModel(
imageUid: null == imageUid ? _self.imageUid : imageUid // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,micronsPerPixel: null == micronsPerPixel ? _self.micronsPerPixel : micronsPerPixel // ignore: cast_nullable_to_non_nullable
as double,uploadedByUid: null == uploadedByUid ? _self.uploadedByUid : uploadedByUid // ignore: cast_nullable_to_non_nullable
as String,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
