// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_provenance_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReportProvenanceModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'caseUid') String get caseUid;@JsonKey(name: 'reportUid') String get reportUid;@JsonKey(name: 'pathologistUid') String get pathologistUid;@JsonKey(name: 'prereadRunUid') String get prereadRunUid;@JsonKey(name: 'diffBase') String get diffBase;@JsonKey(name: 'aiDraft') Map<String, dynamic> get aiDraft;@JsonKey(name: 'aiModels') Map<String, String> get aiModels;@JsonKey(name: 'aiMeasurements') List<ReportMeasurementModel> get aiMeasurements;@JsonKey(name: 'finalMeasurements') List<ReportMeasurementModel> get finalMeasurements;@JsonKey(name: 'labelOverrideCount') int get labelOverrideCount;@JsonKey(name: 'diff') List<ReportFieldDiffModel> get diff;@JsonKey(name: 'editRate') double get editRate;@JsonKey(name: 'acceptedUnchanged') bool get acceptedUnchanged;@JsonKey(name: 'hintShownDiseaseIds') List<String> get hintShownDiseaseIds;@JsonKey(name: 'createdAt') String get createdAt;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;
/// Create a copy of ReportProvenanceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportProvenanceModelCopyWith<ReportProvenanceModel> get copyWith => _$ReportProvenanceModelCopyWithImpl<ReportProvenanceModel>(this as ReportProvenanceModel, _$identity);

  /// Serializes this ReportProvenanceModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportProvenanceModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.reportUid, reportUid) || other.reportUid == reportUid)&&(identical(other.pathologistUid, pathologistUid) || other.pathologistUid == pathologistUid)&&(identical(other.prereadRunUid, prereadRunUid) || other.prereadRunUid == prereadRunUid)&&(identical(other.diffBase, diffBase) || other.diffBase == diffBase)&&const DeepCollectionEquality().equals(other.aiDraft, aiDraft)&&const DeepCollectionEquality().equals(other.aiModels, aiModels)&&const DeepCollectionEquality().equals(other.aiMeasurements, aiMeasurements)&&const DeepCollectionEquality().equals(other.finalMeasurements, finalMeasurements)&&(identical(other.labelOverrideCount, labelOverrideCount) || other.labelOverrideCount == labelOverrideCount)&&const DeepCollectionEquality().equals(other.diff, diff)&&(identical(other.editRate, editRate) || other.editRate == editRate)&&(identical(other.acceptedUnchanged, acceptedUnchanged) || other.acceptedUnchanged == acceptedUnchanged)&&const DeepCollectionEquality().equals(other.hintShownDiseaseIds, hintShownDiseaseIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,caseUid,reportUid,pathologistUid,prereadRunUid,diffBase,const DeepCollectionEquality().hash(aiDraft),const DeepCollectionEquality().hash(aiModels),const DeepCollectionEquality().hash(aiMeasurements),const DeepCollectionEquality().hash(finalMeasurements),labelOverrideCount,const DeepCollectionEquality().hash(diff),editRate,acceptedUnchanged,const DeepCollectionEquality().hash(hintShownDiseaseIds),createdAt,lastUpdatedAt);

@override
String toString() {
  return 'ReportProvenanceModel(uid: $uid, caseUid: $caseUid, reportUid: $reportUid, pathologistUid: $pathologistUid, prereadRunUid: $prereadRunUid, diffBase: $diffBase, aiDraft: $aiDraft, aiModels: $aiModels, aiMeasurements: $aiMeasurements, finalMeasurements: $finalMeasurements, labelOverrideCount: $labelOverrideCount, diff: $diff, editRate: $editRate, acceptedUnchanged: $acceptedUnchanged, hintShownDiseaseIds: $hintShownDiseaseIds, createdAt: $createdAt, lastUpdatedAt: $lastUpdatedAt)';
}


}

/// @nodoc
abstract mixin class $ReportProvenanceModelCopyWith<$Res>  {
  factory $ReportProvenanceModelCopyWith(ReportProvenanceModel value, $Res Function(ReportProvenanceModel) _then) = _$ReportProvenanceModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'reportUid') String reportUid,@JsonKey(name: 'pathologistUid') String pathologistUid,@JsonKey(name: 'prereadRunUid') String prereadRunUid,@JsonKey(name: 'diffBase') String diffBase,@JsonKey(name: 'aiDraft') Map<String, dynamic> aiDraft,@JsonKey(name: 'aiModels') Map<String, String> aiModels,@JsonKey(name: 'aiMeasurements') List<ReportMeasurementModel> aiMeasurements,@JsonKey(name: 'finalMeasurements') List<ReportMeasurementModel> finalMeasurements,@JsonKey(name: 'labelOverrideCount') int labelOverrideCount,@JsonKey(name: 'diff') List<ReportFieldDiffModel> diff,@JsonKey(name: 'editRate') double editRate,@JsonKey(name: 'acceptedUnchanged') bool acceptedUnchanged,@JsonKey(name: 'hintShownDiseaseIds') List<String> hintShownDiseaseIds,@JsonKey(name: 'createdAt') String createdAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt
});




}
/// @nodoc
class _$ReportProvenanceModelCopyWithImpl<$Res>
    implements $ReportProvenanceModelCopyWith<$Res> {
  _$ReportProvenanceModelCopyWithImpl(this._self, this._then);

  final ReportProvenanceModel _self;
  final $Res Function(ReportProvenanceModel) _then;

/// Create a copy of ReportProvenanceModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? caseUid = null,Object? reportUid = null,Object? pathologistUid = null,Object? prereadRunUid = null,Object? diffBase = null,Object? aiDraft = null,Object? aiModels = null,Object? aiMeasurements = null,Object? finalMeasurements = null,Object? labelOverrideCount = null,Object? diff = null,Object? editRate = null,Object? acceptedUnchanged = null,Object? hintShownDiseaseIds = null,Object? createdAt = null,Object? lastUpdatedAt = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,reportUid: null == reportUid ? _self.reportUid : reportUid // ignore: cast_nullable_to_non_nullable
as String,pathologistUid: null == pathologistUid ? _self.pathologistUid : pathologistUid // ignore: cast_nullable_to_non_nullable
as String,prereadRunUid: null == prereadRunUid ? _self.prereadRunUid : prereadRunUid // ignore: cast_nullable_to_non_nullable
as String,diffBase: null == diffBase ? _self.diffBase : diffBase // ignore: cast_nullable_to_non_nullable
as String,aiDraft: null == aiDraft ? _self.aiDraft : aiDraft // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,aiModels: null == aiModels ? _self.aiModels : aiModels // ignore: cast_nullable_to_non_nullable
as Map<String, String>,aiMeasurements: null == aiMeasurements ? _self.aiMeasurements : aiMeasurements // ignore: cast_nullable_to_non_nullable
as List<ReportMeasurementModel>,finalMeasurements: null == finalMeasurements ? _self.finalMeasurements : finalMeasurements // ignore: cast_nullable_to_non_nullable
as List<ReportMeasurementModel>,labelOverrideCount: null == labelOverrideCount ? _self.labelOverrideCount : labelOverrideCount // ignore: cast_nullable_to_non_nullable
as int,diff: null == diff ? _self.diff : diff // ignore: cast_nullable_to_non_nullable
as List<ReportFieldDiffModel>,editRate: null == editRate ? _self.editRate : editRate // ignore: cast_nullable_to_non_nullable
as double,acceptedUnchanged: null == acceptedUnchanged ? _self.acceptedUnchanged : acceptedUnchanged // ignore: cast_nullable_to_non_nullable
as bool,hintShownDiseaseIds: null == hintShownDiseaseIds ? _self.hintShownDiseaseIds : hintShownDiseaseIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportProvenanceModel].
extension ReportProvenanceModelPatterns on ReportProvenanceModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportProvenanceModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportProvenanceModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportProvenanceModel value)  $default,){
final _that = this;
switch (_that) {
case _ReportProvenanceModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportProvenanceModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReportProvenanceModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'reportUid')  String reportUid, @JsonKey(name: 'pathologistUid')  String pathologistUid, @JsonKey(name: 'prereadRunUid')  String prereadRunUid, @JsonKey(name: 'diffBase')  String diffBase, @JsonKey(name: 'aiDraft')  Map<String, dynamic> aiDraft, @JsonKey(name: 'aiModels')  Map<String, String> aiModels, @JsonKey(name: 'aiMeasurements')  List<ReportMeasurementModel> aiMeasurements, @JsonKey(name: 'finalMeasurements')  List<ReportMeasurementModel> finalMeasurements, @JsonKey(name: 'labelOverrideCount')  int labelOverrideCount, @JsonKey(name: 'diff')  List<ReportFieldDiffModel> diff, @JsonKey(name: 'editRate')  double editRate, @JsonKey(name: 'acceptedUnchanged')  bool acceptedUnchanged, @JsonKey(name: 'hintShownDiseaseIds')  List<String> hintShownDiseaseIds, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportProvenanceModel() when $default != null:
return $default(_that.uid,_that.caseUid,_that.reportUid,_that.pathologistUid,_that.prereadRunUid,_that.diffBase,_that.aiDraft,_that.aiModels,_that.aiMeasurements,_that.finalMeasurements,_that.labelOverrideCount,_that.diff,_that.editRate,_that.acceptedUnchanged,_that.hintShownDiseaseIds,_that.createdAt,_that.lastUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'reportUid')  String reportUid, @JsonKey(name: 'pathologistUid')  String pathologistUid, @JsonKey(name: 'prereadRunUid')  String prereadRunUid, @JsonKey(name: 'diffBase')  String diffBase, @JsonKey(name: 'aiDraft')  Map<String, dynamic> aiDraft, @JsonKey(name: 'aiModels')  Map<String, String> aiModels, @JsonKey(name: 'aiMeasurements')  List<ReportMeasurementModel> aiMeasurements, @JsonKey(name: 'finalMeasurements')  List<ReportMeasurementModel> finalMeasurements, @JsonKey(name: 'labelOverrideCount')  int labelOverrideCount, @JsonKey(name: 'diff')  List<ReportFieldDiffModel> diff, @JsonKey(name: 'editRate')  double editRate, @JsonKey(name: 'acceptedUnchanged')  bool acceptedUnchanged, @JsonKey(name: 'hintShownDiseaseIds')  List<String> hintShownDiseaseIds, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _ReportProvenanceModel():
return $default(_that.uid,_that.caseUid,_that.reportUid,_that.pathologistUid,_that.prereadRunUid,_that.diffBase,_that.aiDraft,_that.aiModels,_that.aiMeasurements,_that.finalMeasurements,_that.labelOverrideCount,_that.diff,_that.editRate,_that.acceptedUnchanged,_that.hintShownDiseaseIds,_that.createdAt,_that.lastUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'reportUid')  String reportUid, @JsonKey(name: 'pathologistUid')  String pathologistUid, @JsonKey(name: 'prereadRunUid')  String prereadRunUid, @JsonKey(name: 'diffBase')  String diffBase, @JsonKey(name: 'aiDraft')  Map<String, dynamic> aiDraft, @JsonKey(name: 'aiModels')  Map<String, String> aiModels, @JsonKey(name: 'aiMeasurements')  List<ReportMeasurementModel> aiMeasurements, @JsonKey(name: 'finalMeasurements')  List<ReportMeasurementModel> finalMeasurements, @JsonKey(name: 'labelOverrideCount')  int labelOverrideCount, @JsonKey(name: 'diff')  List<ReportFieldDiffModel> diff, @JsonKey(name: 'editRate')  double editRate, @JsonKey(name: 'acceptedUnchanged')  bool acceptedUnchanged, @JsonKey(name: 'hintShownDiseaseIds')  List<String> hintShownDiseaseIds, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ReportProvenanceModel() when $default != null:
return $default(_that.uid,_that.caseUid,_that.reportUid,_that.pathologistUid,_that.prereadRunUid,_that.diffBase,_that.aiDraft,_that.aiModels,_that.aiMeasurements,_that.finalMeasurements,_that.labelOverrideCount,_that.diff,_that.editRate,_that.acceptedUnchanged,_that.hintShownDiseaseIds,_that.createdAt,_that.lastUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _ReportProvenanceModel extends ReportProvenanceModel {
  const _ReportProvenanceModel({@JsonKey(name: 'uid') this.uid = '', @JsonKey(name: 'caseUid') this.caseUid = '', @JsonKey(name: 'reportUid') this.reportUid = '', @JsonKey(name: 'pathologistUid') this.pathologistUid = '', @JsonKey(name: 'prereadRunUid') this.prereadRunUid = '', @JsonKey(name: 'diffBase') this.diffBase = 'None', @JsonKey(name: 'aiDraft') final  Map<String, dynamic> aiDraft = const <String, dynamic>{}, @JsonKey(name: 'aiModels') final  Map<String, String> aiModels = const <String, String>{}, @JsonKey(name: 'aiMeasurements') final  List<ReportMeasurementModel> aiMeasurements = const <ReportMeasurementModel>[], @JsonKey(name: 'finalMeasurements') final  List<ReportMeasurementModel> finalMeasurements = const <ReportMeasurementModel>[], @JsonKey(name: 'labelOverrideCount') this.labelOverrideCount = 0, @JsonKey(name: 'diff') final  List<ReportFieldDiffModel> diff = const <ReportFieldDiffModel>[], @JsonKey(name: 'editRate') this.editRate = 0, @JsonKey(name: 'acceptedUnchanged') this.acceptedUnchanged = false, @JsonKey(name: 'hintShownDiseaseIds') final  List<String> hintShownDiseaseIds = const <String>[], @JsonKey(name: 'createdAt') this.createdAt = '', @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = ''}): _aiDraft = aiDraft,_aiModels = aiModels,_aiMeasurements = aiMeasurements,_finalMeasurements = finalMeasurements,_diff = diff,_hintShownDiseaseIds = hintShownDiseaseIds,super._();
  factory _ReportProvenanceModel.fromJson(Map<String, dynamic> json) => _$ReportProvenanceModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'caseUid') final  String caseUid;
@override@JsonKey(name: 'reportUid') final  String reportUid;
@override@JsonKey(name: 'pathologistUid') final  String pathologistUid;
@override@JsonKey(name: 'prereadRunUid') final  String prereadRunUid;
@override@JsonKey(name: 'diffBase') final  String diffBase;
 final  Map<String, dynamic> _aiDraft;
@override@JsonKey(name: 'aiDraft') Map<String, dynamic> get aiDraft {
  if (_aiDraft is EqualUnmodifiableMapView) return _aiDraft;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_aiDraft);
}

 final  Map<String, String> _aiModels;
@override@JsonKey(name: 'aiModels') Map<String, String> get aiModels {
  if (_aiModels is EqualUnmodifiableMapView) return _aiModels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_aiModels);
}

 final  List<ReportMeasurementModel> _aiMeasurements;
@override@JsonKey(name: 'aiMeasurements') List<ReportMeasurementModel> get aiMeasurements {
  if (_aiMeasurements is EqualUnmodifiableListView) return _aiMeasurements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_aiMeasurements);
}

 final  List<ReportMeasurementModel> _finalMeasurements;
@override@JsonKey(name: 'finalMeasurements') List<ReportMeasurementModel> get finalMeasurements {
  if (_finalMeasurements is EqualUnmodifiableListView) return _finalMeasurements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_finalMeasurements);
}

@override@JsonKey(name: 'labelOverrideCount') final  int labelOverrideCount;
 final  List<ReportFieldDiffModel> _diff;
@override@JsonKey(name: 'diff') List<ReportFieldDiffModel> get diff {
  if (_diff is EqualUnmodifiableListView) return _diff;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_diff);
}

@override@JsonKey(name: 'editRate') final  double editRate;
@override@JsonKey(name: 'acceptedUnchanged') final  bool acceptedUnchanged;
 final  List<String> _hintShownDiseaseIds;
@override@JsonKey(name: 'hintShownDiseaseIds') List<String> get hintShownDiseaseIds {
  if (_hintShownDiseaseIds is EqualUnmodifiableListView) return _hintShownDiseaseIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hintShownDiseaseIds);
}

@override@JsonKey(name: 'createdAt') final  String createdAt;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;

/// Create a copy of ReportProvenanceModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportProvenanceModelCopyWith<_ReportProvenanceModel> get copyWith => __$ReportProvenanceModelCopyWithImpl<_ReportProvenanceModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportProvenanceModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportProvenanceModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.reportUid, reportUid) || other.reportUid == reportUid)&&(identical(other.pathologistUid, pathologistUid) || other.pathologistUid == pathologistUid)&&(identical(other.prereadRunUid, prereadRunUid) || other.prereadRunUid == prereadRunUid)&&(identical(other.diffBase, diffBase) || other.diffBase == diffBase)&&const DeepCollectionEquality().equals(other._aiDraft, _aiDraft)&&const DeepCollectionEquality().equals(other._aiModels, _aiModels)&&const DeepCollectionEquality().equals(other._aiMeasurements, _aiMeasurements)&&const DeepCollectionEquality().equals(other._finalMeasurements, _finalMeasurements)&&(identical(other.labelOverrideCount, labelOverrideCount) || other.labelOverrideCount == labelOverrideCount)&&const DeepCollectionEquality().equals(other._diff, _diff)&&(identical(other.editRate, editRate) || other.editRate == editRate)&&(identical(other.acceptedUnchanged, acceptedUnchanged) || other.acceptedUnchanged == acceptedUnchanged)&&const DeepCollectionEquality().equals(other._hintShownDiseaseIds, _hintShownDiseaseIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,caseUid,reportUid,pathologistUid,prereadRunUid,diffBase,const DeepCollectionEquality().hash(_aiDraft),const DeepCollectionEquality().hash(_aiModels),const DeepCollectionEquality().hash(_aiMeasurements),const DeepCollectionEquality().hash(_finalMeasurements),labelOverrideCount,const DeepCollectionEquality().hash(_diff),editRate,acceptedUnchanged,const DeepCollectionEquality().hash(_hintShownDiseaseIds),createdAt,lastUpdatedAt);

@override
String toString() {
  return 'ReportProvenanceModel(uid: $uid, caseUid: $caseUid, reportUid: $reportUid, pathologistUid: $pathologistUid, prereadRunUid: $prereadRunUid, diffBase: $diffBase, aiDraft: $aiDraft, aiModels: $aiModels, aiMeasurements: $aiMeasurements, finalMeasurements: $finalMeasurements, labelOverrideCount: $labelOverrideCount, diff: $diff, editRate: $editRate, acceptedUnchanged: $acceptedUnchanged, hintShownDiseaseIds: $hintShownDiseaseIds, createdAt: $createdAt, lastUpdatedAt: $lastUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$ReportProvenanceModelCopyWith<$Res> implements $ReportProvenanceModelCopyWith<$Res> {
  factory _$ReportProvenanceModelCopyWith(_ReportProvenanceModel value, $Res Function(_ReportProvenanceModel) _then) = __$ReportProvenanceModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'reportUid') String reportUid,@JsonKey(name: 'pathologistUid') String pathologistUid,@JsonKey(name: 'prereadRunUid') String prereadRunUid,@JsonKey(name: 'diffBase') String diffBase,@JsonKey(name: 'aiDraft') Map<String, dynamic> aiDraft,@JsonKey(name: 'aiModels') Map<String, String> aiModels,@JsonKey(name: 'aiMeasurements') List<ReportMeasurementModel> aiMeasurements,@JsonKey(name: 'finalMeasurements') List<ReportMeasurementModel> finalMeasurements,@JsonKey(name: 'labelOverrideCount') int labelOverrideCount,@JsonKey(name: 'diff') List<ReportFieldDiffModel> diff,@JsonKey(name: 'editRate') double editRate,@JsonKey(name: 'acceptedUnchanged') bool acceptedUnchanged,@JsonKey(name: 'hintShownDiseaseIds') List<String> hintShownDiseaseIds,@JsonKey(name: 'createdAt') String createdAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt
});




}
/// @nodoc
class __$ReportProvenanceModelCopyWithImpl<$Res>
    implements _$ReportProvenanceModelCopyWith<$Res> {
  __$ReportProvenanceModelCopyWithImpl(this._self, this._then);

  final _ReportProvenanceModel _self;
  final $Res Function(_ReportProvenanceModel) _then;

/// Create a copy of ReportProvenanceModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? caseUid = null,Object? reportUid = null,Object? pathologistUid = null,Object? prereadRunUid = null,Object? diffBase = null,Object? aiDraft = null,Object? aiModels = null,Object? aiMeasurements = null,Object? finalMeasurements = null,Object? labelOverrideCount = null,Object? diff = null,Object? editRate = null,Object? acceptedUnchanged = null,Object? hintShownDiseaseIds = null,Object? createdAt = null,Object? lastUpdatedAt = null,}) {
  return _then(_ReportProvenanceModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,reportUid: null == reportUid ? _self.reportUid : reportUid // ignore: cast_nullable_to_non_nullable
as String,pathologistUid: null == pathologistUid ? _self.pathologistUid : pathologistUid // ignore: cast_nullable_to_non_nullable
as String,prereadRunUid: null == prereadRunUid ? _self.prereadRunUid : prereadRunUid // ignore: cast_nullable_to_non_nullable
as String,diffBase: null == diffBase ? _self.diffBase : diffBase // ignore: cast_nullable_to_non_nullable
as String,aiDraft: null == aiDraft ? _self._aiDraft : aiDraft // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,aiModels: null == aiModels ? _self._aiModels : aiModels // ignore: cast_nullable_to_non_nullable
as Map<String, String>,aiMeasurements: null == aiMeasurements ? _self._aiMeasurements : aiMeasurements // ignore: cast_nullable_to_non_nullable
as List<ReportMeasurementModel>,finalMeasurements: null == finalMeasurements ? _self._finalMeasurements : finalMeasurements // ignore: cast_nullable_to_non_nullable
as List<ReportMeasurementModel>,labelOverrideCount: null == labelOverrideCount ? _self.labelOverrideCount : labelOverrideCount // ignore: cast_nullable_to_non_nullable
as int,diff: null == diff ? _self._diff : diff // ignore: cast_nullable_to_non_nullable
as List<ReportFieldDiffModel>,editRate: null == editRate ? _self.editRate : editRate // ignore: cast_nullable_to_non_nullable
as double,acceptedUnchanged: null == acceptedUnchanged ? _self.acceptedUnchanged : acceptedUnchanged // ignore: cast_nullable_to_non_nullable
as bool,hintShownDiseaseIds: null == hintShownDiseaseIds ? _self._hintShownDiseaseIds : hintShownDiseaseIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
