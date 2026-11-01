// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preread_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PrereadModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'caseUid') String get caseUid;@JsonKey(name: 'profile') String get profile;@JsonKey(name: 'status') String get status;@JsonKey(name: 'imagePaths') List<String> get imagePaths;@JsonKey(name: 'micronsPerPixel') double get micronsPerPixel;@JsonKey(name: 'segmentationPath') String get segmentationPath;@JsonKey(name: 'labelsPath') String get labelsPath;@JsonKey(name: 'labelCounts') Map<String, int> get labelCounts;@JsonKey(name: 'measurements') Map<String, double> get measurements;@JsonKey(name: 'draft') PrereadDraftModel get draft;@JsonKey(name: 'models') Map<String, String> get models;@JsonKey(name: 'inputLanguage') String get inputLanguage;@JsonKey(name: 'failureReason') String get failureReason;@JsonKey(name: 'requestedAt') String get requestedAt;@JsonKey(name: 'startedAt') String get startedAt;@JsonKey(name: 'readyAt') String get readyAt;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;
/// Create a copy of PrereadModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrereadModelCopyWith<PrereadModel> get copyWith => _$PrereadModelCopyWithImpl<PrereadModel>(this as PrereadModel, _$identity);

  /// Serializes this PrereadModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrereadModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.imagePaths, imagePaths)&&(identical(other.micronsPerPixel, micronsPerPixel) || other.micronsPerPixel == micronsPerPixel)&&(identical(other.segmentationPath, segmentationPath) || other.segmentationPath == segmentationPath)&&(identical(other.labelsPath, labelsPath) || other.labelsPath == labelsPath)&&const DeepCollectionEquality().equals(other.labelCounts, labelCounts)&&const DeepCollectionEquality().equals(other.measurements, measurements)&&(identical(other.draft, draft) || other.draft == draft)&&const DeepCollectionEquality().equals(other.models, models)&&(identical(other.inputLanguage, inputLanguage) || other.inputLanguage == inputLanguage)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.readyAt, readyAt) || other.readyAt == readyAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,caseUid,profile,status,const DeepCollectionEquality().hash(imagePaths),micronsPerPixel,segmentationPath,labelsPath,const DeepCollectionEquality().hash(labelCounts),const DeepCollectionEquality().hash(measurements),draft,const DeepCollectionEquality().hash(models),inputLanguage,failureReason,requestedAt,startedAt,readyAt,lastUpdatedAt);

@override
String toString() {
  return 'PrereadModel(uid: $uid, caseUid: $caseUid, profile: $profile, status: $status, imagePaths: $imagePaths, micronsPerPixel: $micronsPerPixel, segmentationPath: $segmentationPath, labelsPath: $labelsPath, labelCounts: $labelCounts, measurements: $measurements, draft: $draft, models: $models, inputLanguage: $inputLanguage, failureReason: $failureReason, requestedAt: $requestedAt, startedAt: $startedAt, readyAt: $readyAt, lastUpdatedAt: $lastUpdatedAt)';
}


}

/// @nodoc
abstract mixin class $PrereadModelCopyWith<$Res>  {
  factory $PrereadModelCopyWith(PrereadModel value, $Res Function(PrereadModel) _then) = _$PrereadModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'profile') String profile,@JsonKey(name: 'status') String status,@JsonKey(name: 'imagePaths') List<String> imagePaths,@JsonKey(name: 'micronsPerPixel') double micronsPerPixel,@JsonKey(name: 'segmentationPath') String segmentationPath,@JsonKey(name: 'labelsPath') String labelsPath,@JsonKey(name: 'labelCounts') Map<String, int> labelCounts,@JsonKey(name: 'measurements') Map<String, double> measurements,@JsonKey(name: 'draft') PrereadDraftModel draft,@JsonKey(name: 'models') Map<String, String> models,@JsonKey(name: 'inputLanguage') String inputLanguage,@JsonKey(name: 'failureReason') String failureReason,@JsonKey(name: 'requestedAt') String requestedAt,@JsonKey(name: 'startedAt') String startedAt,@JsonKey(name: 'readyAt') String readyAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt
});


$PrereadDraftModelCopyWith<$Res> get draft;

}
/// @nodoc
class _$PrereadModelCopyWithImpl<$Res>
    implements $PrereadModelCopyWith<$Res> {
  _$PrereadModelCopyWithImpl(this._self, this._then);

  final PrereadModel _self;
  final $Res Function(PrereadModel) _then;

/// Create a copy of PrereadModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? caseUid = null,Object? profile = null,Object? status = null,Object? imagePaths = null,Object? micronsPerPixel = null,Object? segmentationPath = null,Object? labelsPath = null,Object? labelCounts = null,Object? measurements = null,Object? draft = null,Object? models = null,Object? inputLanguage = null,Object? failureReason = null,Object? requestedAt = null,Object? startedAt = null,Object? readyAt = null,Object? lastUpdatedAt = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,imagePaths: null == imagePaths ? _self.imagePaths : imagePaths // ignore: cast_nullable_to_non_nullable
as List<String>,micronsPerPixel: null == micronsPerPixel ? _self.micronsPerPixel : micronsPerPixel // ignore: cast_nullable_to_non_nullable
as double,segmentationPath: null == segmentationPath ? _self.segmentationPath : segmentationPath // ignore: cast_nullable_to_non_nullable
as String,labelsPath: null == labelsPath ? _self.labelsPath : labelsPath // ignore: cast_nullable_to_non_nullable
as String,labelCounts: null == labelCounts ? _self.labelCounts : labelCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,measurements: null == measurements ? _self.measurements : measurements // ignore: cast_nullable_to_non_nullable
as Map<String, double>,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as PrereadDraftModel,models: null == models ? _self.models : models // ignore: cast_nullable_to_non_nullable
as Map<String, String>,inputLanguage: null == inputLanguage ? _self.inputLanguage : inputLanguage // ignore: cast_nullable_to_non_nullable
as String,failureReason: null == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String,readyAt: null == readyAt ? _self.readyAt : readyAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of PrereadModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PrereadDraftModelCopyWith<$Res> get draft {
  
  return $PrereadDraftModelCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}
}


/// Adds pattern-matching-related methods to [PrereadModel].
extension PrereadModelPatterns on PrereadModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrereadModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrereadModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrereadModel value)  $default,){
final _that = this;
switch (_that) {
case _PrereadModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrereadModel value)?  $default,){
final _that = this;
switch (_that) {
case _PrereadModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'profile')  String profile, @JsonKey(name: 'status')  String status, @JsonKey(name: 'imagePaths')  List<String> imagePaths, @JsonKey(name: 'micronsPerPixel')  double micronsPerPixel, @JsonKey(name: 'segmentationPath')  String segmentationPath, @JsonKey(name: 'labelsPath')  String labelsPath, @JsonKey(name: 'labelCounts')  Map<String, int> labelCounts, @JsonKey(name: 'measurements')  Map<String, double> measurements, @JsonKey(name: 'draft')  PrereadDraftModel draft, @JsonKey(name: 'models')  Map<String, String> models, @JsonKey(name: 'inputLanguage')  String inputLanguage, @JsonKey(name: 'failureReason')  String failureReason, @JsonKey(name: 'requestedAt')  String requestedAt, @JsonKey(name: 'startedAt')  String startedAt, @JsonKey(name: 'readyAt')  String readyAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrereadModel() when $default != null:
return $default(_that.uid,_that.caseUid,_that.profile,_that.status,_that.imagePaths,_that.micronsPerPixel,_that.segmentationPath,_that.labelsPath,_that.labelCounts,_that.measurements,_that.draft,_that.models,_that.inputLanguage,_that.failureReason,_that.requestedAt,_that.startedAt,_that.readyAt,_that.lastUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'profile')  String profile, @JsonKey(name: 'status')  String status, @JsonKey(name: 'imagePaths')  List<String> imagePaths, @JsonKey(name: 'micronsPerPixel')  double micronsPerPixel, @JsonKey(name: 'segmentationPath')  String segmentationPath, @JsonKey(name: 'labelsPath')  String labelsPath, @JsonKey(name: 'labelCounts')  Map<String, int> labelCounts, @JsonKey(name: 'measurements')  Map<String, double> measurements, @JsonKey(name: 'draft')  PrereadDraftModel draft, @JsonKey(name: 'models')  Map<String, String> models, @JsonKey(name: 'inputLanguage')  String inputLanguage, @JsonKey(name: 'failureReason')  String failureReason, @JsonKey(name: 'requestedAt')  String requestedAt, @JsonKey(name: 'startedAt')  String startedAt, @JsonKey(name: 'readyAt')  String readyAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _PrereadModel():
return $default(_that.uid,_that.caseUid,_that.profile,_that.status,_that.imagePaths,_that.micronsPerPixel,_that.segmentationPath,_that.labelsPath,_that.labelCounts,_that.measurements,_that.draft,_that.models,_that.inputLanguage,_that.failureReason,_that.requestedAt,_that.startedAt,_that.readyAt,_that.lastUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'profile')  String profile, @JsonKey(name: 'status')  String status, @JsonKey(name: 'imagePaths')  List<String> imagePaths, @JsonKey(name: 'micronsPerPixel')  double micronsPerPixel, @JsonKey(name: 'segmentationPath')  String segmentationPath, @JsonKey(name: 'labelsPath')  String labelsPath, @JsonKey(name: 'labelCounts')  Map<String, int> labelCounts, @JsonKey(name: 'measurements')  Map<String, double> measurements, @JsonKey(name: 'draft')  PrereadDraftModel draft, @JsonKey(name: 'models')  Map<String, String> models, @JsonKey(name: 'inputLanguage')  String inputLanguage, @JsonKey(name: 'failureReason')  String failureReason, @JsonKey(name: 'requestedAt')  String requestedAt, @JsonKey(name: 'startedAt')  String startedAt, @JsonKey(name: 'readyAt')  String readyAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PrereadModel() when $default != null:
return $default(_that.uid,_that.caseUid,_that.profile,_that.status,_that.imagePaths,_that.micronsPerPixel,_that.segmentationPath,_that.labelsPath,_that.labelCounts,_that.measurements,_that.draft,_that.models,_that.inputLanguage,_that.failureReason,_that.requestedAt,_that.startedAt,_that.readyAt,_that.lastUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _PrereadModel extends PrereadModel {
  const _PrereadModel({@JsonKey(name: 'uid') this.uid = '', @JsonKey(name: 'caseUid') this.caseUid = '', @JsonKey(name: 'profile') this.profile = '', @JsonKey(name: 'status') this.status = 'Queued', @JsonKey(name: 'imagePaths') final  List<String> imagePaths = const <String>[], @JsonKey(name: 'micronsPerPixel') this.micronsPerPixel = 0, @JsonKey(name: 'segmentationPath') this.segmentationPath = '', @JsonKey(name: 'labelsPath') this.labelsPath = '', @JsonKey(name: 'labelCounts') final  Map<String, int> labelCounts = const <String, int>{}, @JsonKey(name: 'measurements') final  Map<String, double> measurements = const <String, double>{}, @JsonKey(name: 'draft') this.draft = const PrereadDraftModel(), @JsonKey(name: 'models') final  Map<String, String> models = const <String, String>{}, @JsonKey(name: 'inputLanguage') this.inputLanguage = '', @JsonKey(name: 'failureReason') this.failureReason = '', @JsonKey(name: 'requestedAt') this.requestedAt = '', @JsonKey(name: 'startedAt') this.startedAt = '', @JsonKey(name: 'readyAt') this.readyAt = '', @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = ''}): _imagePaths = imagePaths,_labelCounts = labelCounts,_measurements = measurements,_models = models,super._();
  factory _PrereadModel.fromJson(Map<String, dynamic> json) => _$PrereadModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'caseUid') final  String caseUid;
@override@JsonKey(name: 'profile') final  String profile;
@override@JsonKey(name: 'status') final  String status;
 final  List<String> _imagePaths;
@override@JsonKey(name: 'imagePaths') List<String> get imagePaths {
  if (_imagePaths is EqualUnmodifiableListView) return _imagePaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imagePaths);
}

@override@JsonKey(name: 'micronsPerPixel') final  double micronsPerPixel;
@override@JsonKey(name: 'segmentationPath') final  String segmentationPath;
@override@JsonKey(name: 'labelsPath') final  String labelsPath;
 final  Map<String, int> _labelCounts;
@override@JsonKey(name: 'labelCounts') Map<String, int> get labelCounts {
  if (_labelCounts is EqualUnmodifiableMapView) return _labelCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_labelCounts);
}

 final  Map<String, double> _measurements;
@override@JsonKey(name: 'measurements') Map<String, double> get measurements {
  if (_measurements is EqualUnmodifiableMapView) return _measurements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_measurements);
}

@override@JsonKey(name: 'draft') final  PrereadDraftModel draft;
 final  Map<String, String> _models;
@override@JsonKey(name: 'models') Map<String, String> get models {
  if (_models is EqualUnmodifiableMapView) return _models;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_models);
}

@override@JsonKey(name: 'inputLanguage') final  String inputLanguage;
@override@JsonKey(name: 'failureReason') final  String failureReason;
@override@JsonKey(name: 'requestedAt') final  String requestedAt;
@override@JsonKey(name: 'startedAt') final  String startedAt;
@override@JsonKey(name: 'readyAt') final  String readyAt;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;

/// Create a copy of PrereadModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrereadModelCopyWith<_PrereadModel> get copyWith => __$PrereadModelCopyWithImpl<_PrereadModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrereadModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrereadModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._imagePaths, _imagePaths)&&(identical(other.micronsPerPixel, micronsPerPixel) || other.micronsPerPixel == micronsPerPixel)&&(identical(other.segmentationPath, segmentationPath) || other.segmentationPath == segmentationPath)&&(identical(other.labelsPath, labelsPath) || other.labelsPath == labelsPath)&&const DeepCollectionEquality().equals(other._labelCounts, _labelCounts)&&const DeepCollectionEquality().equals(other._measurements, _measurements)&&(identical(other.draft, draft) || other.draft == draft)&&const DeepCollectionEquality().equals(other._models, _models)&&(identical(other.inputLanguage, inputLanguage) || other.inputLanguage == inputLanguage)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.readyAt, readyAt) || other.readyAt == readyAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,caseUid,profile,status,const DeepCollectionEquality().hash(_imagePaths),micronsPerPixel,segmentationPath,labelsPath,const DeepCollectionEquality().hash(_labelCounts),const DeepCollectionEquality().hash(_measurements),draft,const DeepCollectionEquality().hash(_models),inputLanguage,failureReason,requestedAt,startedAt,readyAt,lastUpdatedAt);

@override
String toString() {
  return 'PrereadModel(uid: $uid, caseUid: $caseUid, profile: $profile, status: $status, imagePaths: $imagePaths, micronsPerPixel: $micronsPerPixel, segmentationPath: $segmentationPath, labelsPath: $labelsPath, labelCounts: $labelCounts, measurements: $measurements, draft: $draft, models: $models, inputLanguage: $inputLanguage, failureReason: $failureReason, requestedAt: $requestedAt, startedAt: $startedAt, readyAt: $readyAt, lastUpdatedAt: $lastUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$PrereadModelCopyWith<$Res> implements $PrereadModelCopyWith<$Res> {
  factory _$PrereadModelCopyWith(_PrereadModel value, $Res Function(_PrereadModel) _then) = __$PrereadModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'profile') String profile,@JsonKey(name: 'status') String status,@JsonKey(name: 'imagePaths') List<String> imagePaths,@JsonKey(name: 'micronsPerPixel') double micronsPerPixel,@JsonKey(name: 'segmentationPath') String segmentationPath,@JsonKey(name: 'labelsPath') String labelsPath,@JsonKey(name: 'labelCounts') Map<String, int> labelCounts,@JsonKey(name: 'measurements') Map<String, double> measurements,@JsonKey(name: 'draft') PrereadDraftModel draft,@JsonKey(name: 'models') Map<String, String> models,@JsonKey(name: 'inputLanguage') String inputLanguage,@JsonKey(name: 'failureReason') String failureReason,@JsonKey(name: 'requestedAt') String requestedAt,@JsonKey(name: 'startedAt') String startedAt,@JsonKey(name: 'readyAt') String readyAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt
});


@override $PrereadDraftModelCopyWith<$Res> get draft;

}
/// @nodoc
class __$PrereadModelCopyWithImpl<$Res>
    implements _$PrereadModelCopyWith<$Res> {
  __$PrereadModelCopyWithImpl(this._self, this._then);

  final _PrereadModel _self;
  final $Res Function(_PrereadModel) _then;

/// Create a copy of PrereadModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? caseUid = null,Object? profile = null,Object? status = null,Object? imagePaths = null,Object? micronsPerPixel = null,Object? segmentationPath = null,Object? labelsPath = null,Object? labelCounts = null,Object? measurements = null,Object? draft = null,Object? models = null,Object? inputLanguage = null,Object? failureReason = null,Object? requestedAt = null,Object? startedAt = null,Object? readyAt = null,Object? lastUpdatedAt = null,}) {
  return _then(_PrereadModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,imagePaths: null == imagePaths ? _self._imagePaths : imagePaths // ignore: cast_nullable_to_non_nullable
as List<String>,micronsPerPixel: null == micronsPerPixel ? _self.micronsPerPixel : micronsPerPixel // ignore: cast_nullable_to_non_nullable
as double,segmentationPath: null == segmentationPath ? _self.segmentationPath : segmentationPath // ignore: cast_nullable_to_non_nullable
as String,labelsPath: null == labelsPath ? _self.labelsPath : labelsPath // ignore: cast_nullable_to_non_nullable
as String,labelCounts: null == labelCounts ? _self._labelCounts : labelCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,measurements: null == measurements ? _self._measurements : measurements // ignore: cast_nullable_to_non_nullable
as Map<String, double>,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as PrereadDraftModel,models: null == models ? _self._models : models // ignore: cast_nullable_to_non_nullable
as Map<String, String>,inputLanguage: null == inputLanguage ? _self.inputLanguage : inputLanguage // ignore: cast_nullable_to_non_nullable
as String,failureReason: null == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String,readyAt: null == readyAt ? _self.readyAt : readyAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of PrereadModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PrereadDraftModelCopyWith<$Res> get draft {
  
  return $PrereadDraftModelCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}
}

// dart format on
