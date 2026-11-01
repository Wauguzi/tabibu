// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preread_score_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PrereadScoreModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'caseUid') String get caseUid;@JsonKey(name: 'runUid') String get runUid;@JsonKey(name: 'pathologistUid') String get pathologistUid;@JsonKey(name: 'profile') String get profile;@JsonKey(name: 'confidenceBand') String get confidenceBand;@JsonKey(name: 'urgency') String get urgency;@JsonKey(name: 'overall') int get overall;@JsonKey(name: 'findingsVerdict') String get findingsVerdict;@JsonKey(name: 'impressionVerdict') String get impressionVerdict;@JsonKey(name: 'measurementsVerdict') String get measurementsVerdict;@JsonKey(name: 'segmentationVerdict') String get segmentationVerdict;@JsonKey(name: 'urgencyVerdict') String get urgencyVerdict;@JsonKey(name: 'comment') String get comment;@JsonKey(name: 'prereadShownAt') String get prereadShownAt;@JsonKey(name: 'acceptedUnchanged') bool get acceptedUnchanged;@JsonKey(name: 'scoredAt') String get scoredAt;@JsonKey(name: 'createdByUid') String get createdByUid;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;@JsonKey(includeFromJson: false, includeToJson: false) bool get synced;
/// Create a copy of PrereadScoreModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrereadScoreModelCopyWith<PrereadScoreModel> get copyWith => _$PrereadScoreModelCopyWithImpl<PrereadScoreModel>(this as PrereadScoreModel, _$identity);

  /// Serializes this PrereadScoreModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrereadScoreModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.runUid, runUid) || other.runUid == runUid)&&(identical(other.pathologistUid, pathologistUid) || other.pathologistUid == pathologistUid)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.confidenceBand, confidenceBand) || other.confidenceBand == confidenceBand)&&(identical(other.urgency, urgency) || other.urgency == urgency)&&(identical(other.overall, overall) || other.overall == overall)&&(identical(other.findingsVerdict, findingsVerdict) || other.findingsVerdict == findingsVerdict)&&(identical(other.impressionVerdict, impressionVerdict) || other.impressionVerdict == impressionVerdict)&&(identical(other.measurementsVerdict, measurementsVerdict) || other.measurementsVerdict == measurementsVerdict)&&(identical(other.segmentationVerdict, segmentationVerdict) || other.segmentationVerdict == segmentationVerdict)&&(identical(other.urgencyVerdict, urgencyVerdict) || other.urgencyVerdict == urgencyVerdict)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.prereadShownAt, prereadShownAt) || other.prereadShownAt == prereadShownAt)&&(identical(other.acceptedUnchanged, acceptedUnchanged) || other.acceptedUnchanged == acceptedUnchanged)&&(identical(other.scoredAt, scoredAt) || other.scoredAt == scoredAt)&&(identical(other.createdByUid, createdByUid) || other.createdByUid == createdByUid)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,caseUid,runUid,pathologistUid,profile,confidenceBand,urgency,overall,findingsVerdict,impressionVerdict,measurementsVerdict,segmentationVerdict,urgencyVerdict,comment,prereadShownAt,acceptedUnchanged,scoredAt,createdByUid,lastUpdatedAt,synced]);

@override
String toString() {
  return 'PrereadScoreModel(uid: $uid, caseUid: $caseUid, runUid: $runUid, pathologistUid: $pathologistUid, profile: $profile, confidenceBand: $confidenceBand, urgency: $urgency, overall: $overall, findingsVerdict: $findingsVerdict, impressionVerdict: $impressionVerdict, measurementsVerdict: $measurementsVerdict, segmentationVerdict: $segmentationVerdict, urgencyVerdict: $urgencyVerdict, comment: $comment, prereadShownAt: $prereadShownAt, acceptedUnchanged: $acceptedUnchanged, scoredAt: $scoredAt, createdByUid: $createdByUid, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class $PrereadScoreModelCopyWith<$Res>  {
  factory $PrereadScoreModelCopyWith(PrereadScoreModel value, $Res Function(PrereadScoreModel) _then) = _$PrereadScoreModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'runUid') String runUid,@JsonKey(name: 'pathologistUid') String pathologistUid,@JsonKey(name: 'profile') String profile,@JsonKey(name: 'confidenceBand') String confidenceBand,@JsonKey(name: 'urgency') String urgency,@JsonKey(name: 'overall') int overall,@JsonKey(name: 'findingsVerdict') String findingsVerdict,@JsonKey(name: 'impressionVerdict') String impressionVerdict,@JsonKey(name: 'measurementsVerdict') String measurementsVerdict,@JsonKey(name: 'segmentationVerdict') String segmentationVerdict,@JsonKey(name: 'urgencyVerdict') String urgencyVerdict,@JsonKey(name: 'comment') String comment,@JsonKey(name: 'prereadShownAt') String prereadShownAt,@JsonKey(name: 'acceptedUnchanged') bool acceptedUnchanged,@JsonKey(name: 'scoredAt') String scoredAt,@JsonKey(name: 'createdByUid') String createdByUid,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class _$PrereadScoreModelCopyWithImpl<$Res>
    implements $PrereadScoreModelCopyWith<$Res> {
  _$PrereadScoreModelCopyWithImpl(this._self, this._then);

  final PrereadScoreModel _self;
  final $Res Function(PrereadScoreModel) _then;

/// Create a copy of PrereadScoreModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? caseUid = null,Object? runUid = null,Object? pathologistUid = null,Object? profile = null,Object? confidenceBand = null,Object? urgency = null,Object? overall = null,Object? findingsVerdict = null,Object? impressionVerdict = null,Object? measurementsVerdict = null,Object? segmentationVerdict = null,Object? urgencyVerdict = null,Object? comment = null,Object? prereadShownAt = null,Object? acceptedUnchanged = null,Object? scoredAt = null,Object? createdByUid = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,runUid: null == runUid ? _self.runUid : runUid // ignore: cast_nullable_to_non_nullable
as String,pathologistUid: null == pathologistUid ? _self.pathologistUid : pathologistUid // ignore: cast_nullable_to_non_nullable
as String,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String,confidenceBand: null == confidenceBand ? _self.confidenceBand : confidenceBand // ignore: cast_nullable_to_non_nullable
as String,urgency: null == urgency ? _self.urgency : urgency // ignore: cast_nullable_to_non_nullable
as String,overall: null == overall ? _self.overall : overall // ignore: cast_nullable_to_non_nullable
as int,findingsVerdict: null == findingsVerdict ? _self.findingsVerdict : findingsVerdict // ignore: cast_nullable_to_non_nullable
as String,impressionVerdict: null == impressionVerdict ? _self.impressionVerdict : impressionVerdict // ignore: cast_nullable_to_non_nullable
as String,measurementsVerdict: null == measurementsVerdict ? _self.measurementsVerdict : measurementsVerdict // ignore: cast_nullable_to_non_nullable
as String,segmentationVerdict: null == segmentationVerdict ? _self.segmentationVerdict : segmentationVerdict // ignore: cast_nullable_to_non_nullable
as String,urgencyVerdict: null == urgencyVerdict ? _self.urgencyVerdict : urgencyVerdict // ignore: cast_nullable_to_non_nullable
as String,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,prereadShownAt: null == prereadShownAt ? _self.prereadShownAt : prereadShownAt // ignore: cast_nullable_to_non_nullable
as String,acceptedUnchanged: null == acceptedUnchanged ? _self.acceptedUnchanged : acceptedUnchanged // ignore: cast_nullable_to_non_nullable
as bool,scoredAt: null == scoredAt ? _self.scoredAt : scoredAt // ignore: cast_nullable_to_non_nullable
as String,createdByUid: null == createdByUid ? _self.createdByUid : createdByUid // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PrereadScoreModel].
extension PrereadScoreModelPatterns on PrereadScoreModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrereadScoreModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrereadScoreModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrereadScoreModel value)  $default,){
final _that = this;
switch (_that) {
case _PrereadScoreModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrereadScoreModel value)?  $default,){
final _that = this;
switch (_that) {
case _PrereadScoreModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'runUid')  String runUid, @JsonKey(name: 'pathologistUid')  String pathologistUid, @JsonKey(name: 'profile')  String profile, @JsonKey(name: 'confidenceBand')  String confidenceBand, @JsonKey(name: 'urgency')  String urgency, @JsonKey(name: 'overall')  int overall, @JsonKey(name: 'findingsVerdict')  String findingsVerdict, @JsonKey(name: 'impressionVerdict')  String impressionVerdict, @JsonKey(name: 'measurementsVerdict')  String measurementsVerdict, @JsonKey(name: 'segmentationVerdict')  String segmentationVerdict, @JsonKey(name: 'urgencyVerdict')  String urgencyVerdict, @JsonKey(name: 'comment')  String comment, @JsonKey(name: 'prereadShownAt')  String prereadShownAt, @JsonKey(name: 'acceptedUnchanged')  bool acceptedUnchanged, @JsonKey(name: 'scoredAt')  String scoredAt, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrereadScoreModel() when $default != null:
return $default(_that.uid,_that.caseUid,_that.runUid,_that.pathologistUid,_that.profile,_that.confidenceBand,_that.urgency,_that.overall,_that.findingsVerdict,_that.impressionVerdict,_that.measurementsVerdict,_that.segmentationVerdict,_that.urgencyVerdict,_that.comment,_that.prereadShownAt,_that.acceptedUnchanged,_that.scoredAt,_that.createdByUid,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'runUid')  String runUid, @JsonKey(name: 'pathologistUid')  String pathologistUid, @JsonKey(name: 'profile')  String profile, @JsonKey(name: 'confidenceBand')  String confidenceBand, @JsonKey(name: 'urgency')  String urgency, @JsonKey(name: 'overall')  int overall, @JsonKey(name: 'findingsVerdict')  String findingsVerdict, @JsonKey(name: 'impressionVerdict')  String impressionVerdict, @JsonKey(name: 'measurementsVerdict')  String measurementsVerdict, @JsonKey(name: 'segmentationVerdict')  String segmentationVerdict, @JsonKey(name: 'urgencyVerdict')  String urgencyVerdict, @JsonKey(name: 'comment')  String comment, @JsonKey(name: 'prereadShownAt')  String prereadShownAt, @JsonKey(name: 'acceptedUnchanged')  bool acceptedUnchanged, @JsonKey(name: 'scoredAt')  String scoredAt, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)  $default,) {final _that = this;
switch (_that) {
case _PrereadScoreModel():
return $default(_that.uid,_that.caseUid,_that.runUid,_that.pathologistUid,_that.profile,_that.confidenceBand,_that.urgency,_that.overall,_that.findingsVerdict,_that.impressionVerdict,_that.measurementsVerdict,_that.segmentationVerdict,_that.urgencyVerdict,_that.comment,_that.prereadShownAt,_that.acceptedUnchanged,_that.scoredAt,_that.createdByUid,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'runUid')  String runUid, @JsonKey(name: 'pathologistUid')  String pathologistUid, @JsonKey(name: 'profile')  String profile, @JsonKey(name: 'confidenceBand')  String confidenceBand, @JsonKey(name: 'urgency')  String urgency, @JsonKey(name: 'overall')  int overall, @JsonKey(name: 'findingsVerdict')  String findingsVerdict, @JsonKey(name: 'impressionVerdict')  String impressionVerdict, @JsonKey(name: 'measurementsVerdict')  String measurementsVerdict, @JsonKey(name: 'segmentationVerdict')  String segmentationVerdict, @JsonKey(name: 'urgencyVerdict')  String urgencyVerdict, @JsonKey(name: 'comment')  String comment, @JsonKey(name: 'prereadShownAt')  String prereadShownAt, @JsonKey(name: 'acceptedUnchanged')  bool acceptedUnchanged, @JsonKey(name: 'scoredAt')  String scoredAt, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,) {final _that = this;
switch (_that) {
case _PrereadScoreModel() when $default != null:
return $default(_that.uid,_that.caseUid,_that.runUid,_that.pathologistUid,_that.profile,_that.confidenceBand,_that.urgency,_that.overall,_that.findingsVerdict,_that.impressionVerdict,_that.measurementsVerdict,_that.segmentationVerdict,_that.urgencyVerdict,_that.comment,_that.prereadShownAt,_that.acceptedUnchanged,_that.scoredAt,_that.createdByUid,_that.lastUpdatedAt,_that.synced);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrereadScoreModel extends PrereadScoreModel {
  const _PrereadScoreModel({@JsonKey(name: 'uid') this.uid = '', @JsonKey(name: 'caseUid') this.caseUid = '', @JsonKey(name: 'runUid') this.runUid = '', @JsonKey(name: 'pathologistUid') this.pathologistUid = '', @JsonKey(name: 'profile') this.profile = 'None', @JsonKey(name: 'confidenceBand') this.confidenceBand = 'Low', @JsonKey(name: 'urgency') this.urgency = 'Routine', @JsonKey(name: 'overall') this.overall = 0, @JsonKey(name: 'findingsVerdict') this.findingsVerdict = 'Agree', @JsonKey(name: 'impressionVerdict') this.impressionVerdict = 'Agree', @JsonKey(name: 'measurementsVerdict') this.measurementsVerdict = 'NotApplicable', @JsonKey(name: 'segmentationVerdict') this.segmentationVerdict = 'NotApplicable', @JsonKey(name: 'urgencyVerdict') this.urgencyVerdict = 'Agree', @JsonKey(name: 'comment') this.comment = '', @JsonKey(name: 'prereadShownAt') this.prereadShownAt = '', @JsonKey(name: 'acceptedUnchanged') this.acceptedUnchanged = false, @JsonKey(name: 'scoredAt') this.scoredAt = '', @JsonKey(name: 'createdByUid') this.createdByUid = '', @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = '', @JsonKey(includeFromJson: false, includeToJson: false) this.synced = true}): super._();
  factory _PrereadScoreModel.fromJson(Map<String, dynamic> json) => _$PrereadScoreModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'caseUid') final  String caseUid;
@override@JsonKey(name: 'runUid') final  String runUid;
@override@JsonKey(name: 'pathologistUid') final  String pathologistUid;
@override@JsonKey(name: 'profile') final  String profile;
@override@JsonKey(name: 'confidenceBand') final  String confidenceBand;
@override@JsonKey(name: 'urgency') final  String urgency;
@override@JsonKey(name: 'overall') final  int overall;
@override@JsonKey(name: 'findingsVerdict') final  String findingsVerdict;
@override@JsonKey(name: 'impressionVerdict') final  String impressionVerdict;
@override@JsonKey(name: 'measurementsVerdict') final  String measurementsVerdict;
@override@JsonKey(name: 'segmentationVerdict') final  String segmentationVerdict;
@override@JsonKey(name: 'urgencyVerdict') final  String urgencyVerdict;
@override@JsonKey(name: 'comment') final  String comment;
@override@JsonKey(name: 'prereadShownAt') final  String prereadShownAt;
@override@JsonKey(name: 'acceptedUnchanged') final  bool acceptedUnchanged;
@override@JsonKey(name: 'scoredAt') final  String scoredAt;
@override@JsonKey(name: 'createdByUid') final  String createdByUid;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool synced;

/// Create a copy of PrereadScoreModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrereadScoreModelCopyWith<_PrereadScoreModel> get copyWith => __$PrereadScoreModelCopyWithImpl<_PrereadScoreModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrereadScoreModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrereadScoreModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.runUid, runUid) || other.runUid == runUid)&&(identical(other.pathologistUid, pathologistUid) || other.pathologistUid == pathologistUid)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.confidenceBand, confidenceBand) || other.confidenceBand == confidenceBand)&&(identical(other.urgency, urgency) || other.urgency == urgency)&&(identical(other.overall, overall) || other.overall == overall)&&(identical(other.findingsVerdict, findingsVerdict) || other.findingsVerdict == findingsVerdict)&&(identical(other.impressionVerdict, impressionVerdict) || other.impressionVerdict == impressionVerdict)&&(identical(other.measurementsVerdict, measurementsVerdict) || other.measurementsVerdict == measurementsVerdict)&&(identical(other.segmentationVerdict, segmentationVerdict) || other.segmentationVerdict == segmentationVerdict)&&(identical(other.urgencyVerdict, urgencyVerdict) || other.urgencyVerdict == urgencyVerdict)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.prereadShownAt, prereadShownAt) || other.prereadShownAt == prereadShownAt)&&(identical(other.acceptedUnchanged, acceptedUnchanged) || other.acceptedUnchanged == acceptedUnchanged)&&(identical(other.scoredAt, scoredAt) || other.scoredAt == scoredAt)&&(identical(other.createdByUid, createdByUid) || other.createdByUid == createdByUid)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,caseUid,runUid,pathologistUid,profile,confidenceBand,urgency,overall,findingsVerdict,impressionVerdict,measurementsVerdict,segmentationVerdict,urgencyVerdict,comment,prereadShownAt,acceptedUnchanged,scoredAt,createdByUid,lastUpdatedAt,synced]);

@override
String toString() {
  return 'PrereadScoreModel(uid: $uid, caseUid: $caseUid, runUid: $runUid, pathologistUid: $pathologistUid, profile: $profile, confidenceBand: $confidenceBand, urgency: $urgency, overall: $overall, findingsVerdict: $findingsVerdict, impressionVerdict: $impressionVerdict, measurementsVerdict: $measurementsVerdict, segmentationVerdict: $segmentationVerdict, urgencyVerdict: $urgencyVerdict, comment: $comment, prereadShownAt: $prereadShownAt, acceptedUnchanged: $acceptedUnchanged, scoredAt: $scoredAt, createdByUid: $createdByUid, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class _$PrereadScoreModelCopyWith<$Res> implements $PrereadScoreModelCopyWith<$Res> {
  factory _$PrereadScoreModelCopyWith(_PrereadScoreModel value, $Res Function(_PrereadScoreModel) _then) = __$PrereadScoreModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'runUid') String runUid,@JsonKey(name: 'pathologistUid') String pathologistUid,@JsonKey(name: 'profile') String profile,@JsonKey(name: 'confidenceBand') String confidenceBand,@JsonKey(name: 'urgency') String urgency,@JsonKey(name: 'overall') int overall,@JsonKey(name: 'findingsVerdict') String findingsVerdict,@JsonKey(name: 'impressionVerdict') String impressionVerdict,@JsonKey(name: 'measurementsVerdict') String measurementsVerdict,@JsonKey(name: 'segmentationVerdict') String segmentationVerdict,@JsonKey(name: 'urgencyVerdict') String urgencyVerdict,@JsonKey(name: 'comment') String comment,@JsonKey(name: 'prereadShownAt') String prereadShownAt,@JsonKey(name: 'acceptedUnchanged') bool acceptedUnchanged,@JsonKey(name: 'scoredAt') String scoredAt,@JsonKey(name: 'createdByUid') String createdByUid,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class __$PrereadScoreModelCopyWithImpl<$Res>
    implements _$PrereadScoreModelCopyWith<$Res> {
  __$PrereadScoreModelCopyWithImpl(this._self, this._then);

  final _PrereadScoreModel _self;
  final $Res Function(_PrereadScoreModel) _then;

/// Create a copy of PrereadScoreModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? caseUid = null,Object? runUid = null,Object? pathologistUid = null,Object? profile = null,Object? confidenceBand = null,Object? urgency = null,Object? overall = null,Object? findingsVerdict = null,Object? impressionVerdict = null,Object? measurementsVerdict = null,Object? segmentationVerdict = null,Object? urgencyVerdict = null,Object? comment = null,Object? prereadShownAt = null,Object? acceptedUnchanged = null,Object? scoredAt = null,Object? createdByUid = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_PrereadScoreModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,runUid: null == runUid ? _self.runUid : runUid // ignore: cast_nullable_to_non_nullable
as String,pathologistUid: null == pathologistUid ? _self.pathologistUid : pathologistUid // ignore: cast_nullable_to_non_nullable
as String,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String,confidenceBand: null == confidenceBand ? _self.confidenceBand : confidenceBand // ignore: cast_nullable_to_non_nullable
as String,urgency: null == urgency ? _self.urgency : urgency // ignore: cast_nullable_to_non_nullable
as String,overall: null == overall ? _self.overall : overall // ignore: cast_nullable_to_non_nullable
as int,findingsVerdict: null == findingsVerdict ? _self.findingsVerdict : findingsVerdict // ignore: cast_nullable_to_non_nullable
as String,impressionVerdict: null == impressionVerdict ? _self.impressionVerdict : impressionVerdict // ignore: cast_nullable_to_non_nullable
as String,measurementsVerdict: null == measurementsVerdict ? _self.measurementsVerdict : measurementsVerdict // ignore: cast_nullable_to_non_nullable
as String,segmentationVerdict: null == segmentationVerdict ? _self.segmentationVerdict : segmentationVerdict // ignore: cast_nullable_to_non_nullable
as String,urgencyVerdict: null == urgencyVerdict ? _self.urgencyVerdict : urgencyVerdict // ignore: cast_nullable_to_non_nullable
as String,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,prereadShownAt: null == prereadShownAt ? _self.prereadShownAt : prereadShownAt // ignore: cast_nullable_to_non_nullable
as String,acceptedUnchanged: null == acceptedUnchanged ? _self.acceptedUnchanged : acceptedUnchanged // ignore: cast_nullable_to_non_nullable
as bool,scoredAt: null == scoredAt ? _self.scoredAt : scoredAt // ignore: cast_nullable_to_non_nullable
as String,createdByUid: null == createdByUid ? _self.createdByUid : createdByUid // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
