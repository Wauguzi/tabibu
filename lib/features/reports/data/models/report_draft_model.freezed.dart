// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_draft_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReportDraftModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'caseUid') String get caseUid;@JsonKey(name: 'pathologistUid') String get pathologistUid;@JsonKey(name: 'kind') String get kind;@JsonKey(name: 'status') String get status;@JsonKey(name: 'baseReportUid') String get baseReportUid;@JsonKey(name: 'targetReportUid') String get targetReportUid;@JsonKey(name: 'prereadRunUid') String get prereadRunUid;@JsonKey(name: 'templateKey') String get templateKey;@JsonKey(name: 'title') String get title;@JsonKey(name: 'diagnosisType') String get diagnosisType;@JsonKey(name: 'diagnosis') String get diagnosis;@JsonKey(name: 'comments') String get comments;@JsonKey(name: 'responses') List<ReportResponseModel> get responses;@JsonKey(name: 'labelOverrides') Map<String, String> get labelOverrides;@JsonKey(name: 'labelOverrideCount') int get labelOverrideCount;@JsonKey(name: 'isCritical') bool get isCritical;@JsonKey(name: 'addendumText') String get addendumText;@JsonKey(name: 'amendmentReason') String get amendmentReason;@JsonKey(name: 'diagnosisStartedAt') String get diagnosisStartedAt;@JsonKey(name: 'startedFromPreread') bool get startedFromPreread;@JsonKey(name: 'startedAt') String get startedAt;@JsonKey(name: 'signedReportUid') String get signedReportUid;@JsonKey(name: 'notifiableFindings') List<NotifiableFindingModel> get notifiableFindings;@JsonKey(name: 'hintShownDiseaseIds') List<String> get hintShownDiseaseIds;@JsonKey(name: 'confirmatoryRequests') List<String> get confirmatoryRequests;@JsonKey(name: 'createdByUid') String get createdByUid;@JsonKey(name: 'language') String get language;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;@JsonKey(includeFromJson: false, includeToJson: false) bool get synced;
/// Create a copy of ReportDraftModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportDraftModelCopyWith<ReportDraftModel> get copyWith => _$ReportDraftModelCopyWithImpl<ReportDraftModel>(this as ReportDraftModel, _$identity);

  /// Serializes this ReportDraftModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportDraftModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.pathologistUid, pathologistUid) || other.pathologistUid == pathologistUid)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.status, status) || other.status == status)&&(identical(other.baseReportUid, baseReportUid) || other.baseReportUid == baseReportUid)&&(identical(other.targetReportUid, targetReportUid) || other.targetReportUid == targetReportUid)&&(identical(other.prereadRunUid, prereadRunUid) || other.prereadRunUid == prereadRunUid)&&(identical(other.templateKey, templateKey) || other.templateKey == templateKey)&&(identical(other.title, title) || other.title == title)&&(identical(other.diagnosisType, diagnosisType) || other.diagnosisType == diagnosisType)&&(identical(other.diagnosis, diagnosis) || other.diagnosis == diagnosis)&&(identical(other.comments, comments) || other.comments == comments)&&const DeepCollectionEquality().equals(other.responses, responses)&&const DeepCollectionEquality().equals(other.labelOverrides, labelOverrides)&&(identical(other.labelOverrideCount, labelOverrideCount) || other.labelOverrideCount == labelOverrideCount)&&(identical(other.isCritical, isCritical) || other.isCritical == isCritical)&&(identical(other.addendumText, addendumText) || other.addendumText == addendumText)&&(identical(other.amendmentReason, amendmentReason) || other.amendmentReason == amendmentReason)&&(identical(other.diagnosisStartedAt, diagnosisStartedAt) || other.diagnosisStartedAt == diagnosisStartedAt)&&(identical(other.startedFromPreread, startedFromPreread) || other.startedFromPreread == startedFromPreread)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.signedReportUid, signedReportUid) || other.signedReportUid == signedReportUid)&&const DeepCollectionEquality().equals(other.notifiableFindings, notifiableFindings)&&const DeepCollectionEquality().equals(other.hintShownDiseaseIds, hintShownDiseaseIds)&&const DeepCollectionEquality().equals(other.confirmatoryRequests, confirmatoryRequests)&&(identical(other.createdByUid, createdByUid) || other.createdByUid == createdByUid)&&(identical(other.language, language) || other.language == language)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,caseUid,pathologistUid,kind,status,baseReportUid,targetReportUid,prereadRunUid,templateKey,title,diagnosisType,diagnosis,comments,const DeepCollectionEquality().hash(responses),const DeepCollectionEquality().hash(labelOverrides),labelOverrideCount,isCritical,addendumText,amendmentReason,diagnosisStartedAt,startedFromPreread,startedAt,signedReportUid,const DeepCollectionEquality().hash(notifiableFindings),const DeepCollectionEquality().hash(hintShownDiseaseIds),const DeepCollectionEquality().hash(confirmatoryRequests),createdByUid,language,lastUpdatedAt,synced]);

@override
String toString() {
  return 'ReportDraftModel(uid: $uid, caseUid: $caseUid, pathologistUid: $pathologistUid, kind: $kind, status: $status, baseReportUid: $baseReportUid, targetReportUid: $targetReportUid, prereadRunUid: $prereadRunUid, templateKey: $templateKey, title: $title, diagnosisType: $diagnosisType, diagnosis: $diagnosis, comments: $comments, responses: $responses, labelOverrides: $labelOverrides, labelOverrideCount: $labelOverrideCount, isCritical: $isCritical, addendumText: $addendumText, amendmentReason: $amendmentReason, diagnosisStartedAt: $diagnosisStartedAt, startedFromPreread: $startedFromPreread, startedAt: $startedAt, signedReportUid: $signedReportUid, notifiableFindings: $notifiableFindings, hintShownDiseaseIds: $hintShownDiseaseIds, confirmatoryRequests: $confirmatoryRequests, createdByUid: $createdByUid, language: $language, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class $ReportDraftModelCopyWith<$Res>  {
  factory $ReportDraftModelCopyWith(ReportDraftModel value, $Res Function(ReportDraftModel) _then) = _$ReportDraftModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'pathologistUid') String pathologistUid,@JsonKey(name: 'kind') String kind,@JsonKey(name: 'status') String status,@JsonKey(name: 'baseReportUid') String baseReportUid,@JsonKey(name: 'targetReportUid') String targetReportUid,@JsonKey(name: 'prereadRunUid') String prereadRunUid,@JsonKey(name: 'templateKey') String templateKey,@JsonKey(name: 'title') String title,@JsonKey(name: 'diagnosisType') String diagnosisType,@JsonKey(name: 'diagnosis') String diagnosis,@JsonKey(name: 'comments') String comments,@JsonKey(name: 'responses') List<ReportResponseModel> responses,@JsonKey(name: 'labelOverrides') Map<String, String> labelOverrides,@JsonKey(name: 'labelOverrideCount') int labelOverrideCount,@JsonKey(name: 'isCritical') bool isCritical,@JsonKey(name: 'addendumText') String addendumText,@JsonKey(name: 'amendmentReason') String amendmentReason,@JsonKey(name: 'diagnosisStartedAt') String diagnosisStartedAt,@JsonKey(name: 'startedFromPreread') bool startedFromPreread,@JsonKey(name: 'startedAt') String startedAt,@JsonKey(name: 'signedReportUid') String signedReportUid,@JsonKey(name: 'notifiableFindings') List<NotifiableFindingModel> notifiableFindings,@JsonKey(name: 'hintShownDiseaseIds') List<String> hintShownDiseaseIds,@JsonKey(name: 'confirmatoryRequests') List<String> confirmatoryRequests,@JsonKey(name: 'createdByUid') String createdByUid,@JsonKey(name: 'language') String language,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class _$ReportDraftModelCopyWithImpl<$Res>
    implements $ReportDraftModelCopyWith<$Res> {
  _$ReportDraftModelCopyWithImpl(this._self, this._then);

  final ReportDraftModel _self;
  final $Res Function(ReportDraftModel) _then;

/// Create a copy of ReportDraftModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? caseUid = null,Object? pathologistUid = null,Object? kind = null,Object? status = null,Object? baseReportUid = null,Object? targetReportUid = null,Object? prereadRunUid = null,Object? templateKey = null,Object? title = null,Object? diagnosisType = null,Object? diagnosis = null,Object? comments = null,Object? responses = null,Object? labelOverrides = null,Object? labelOverrideCount = null,Object? isCritical = null,Object? addendumText = null,Object? amendmentReason = null,Object? diagnosisStartedAt = null,Object? startedFromPreread = null,Object? startedAt = null,Object? signedReportUid = null,Object? notifiableFindings = null,Object? hintShownDiseaseIds = null,Object? confirmatoryRequests = null,Object? createdByUid = null,Object? language = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,pathologistUid: null == pathologistUid ? _self.pathologistUid : pathologistUid // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,baseReportUid: null == baseReportUid ? _self.baseReportUid : baseReportUid // ignore: cast_nullable_to_non_nullable
as String,targetReportUid: null == targetReportUid ? _self.targetReportUid : targetReportUid // ignore: cast_nullable_to_non_nullable
as String,prereadRunUid: null == prereadRunUid ? _self.prereadRunUid : prereadRunUid // ignore: cast_nullable_to_non_nullable
as String,templateKey: null == templateKey ? _self.templateKey : templateKey // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,diagnosisType: null == diagnosisType ? _self.diagnosisType : diagnosisType // ignore: cast_nullable_to_non_nullable
as String,diagnosis: null == diagnosis ? _self.diagnosis : diagnosis // ignore: cast_nullable_to_non_nullable
as String,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as String,responses: null == responses ? _self.responses : responses // ignore: cast_nullable_to_non_nullable
as List<ReportResponseModel>,labelOverrides: null == labelOverrides ? _self.labelOverrides : labelOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,labelOverrideCount: null == labelOverrideCount ? _self.labelOverrideCount : labelOverrideCount // ignore: cast_nullable_to_non_nullable
as int,isCritical: null == isCritical ? _self.isCritical : isCritical // ignore: cast_nullable_to_non_nullable
as bool,addendumText: null == addendumText ? _self.addendumText : addendumText // ignore: cast_nullable_to_non_nullable
as String,amendmentReason: null == amendmentReason ? _self.amendmentReason : amendmentReason // ignore: cast_nullable_to_non_nullable
as String,diagnosisStartedAt: null == diagnosisStartedAt ? _self.diagnosisStartedAt : diagnosisStartedAt // ignore: cast_nullable_to_non_nullable
as String,startedFromPreread: null == startedFromPreread ? _self.startedFromPreread : startedFromPreread // ignore: cast_nullable_to_non_nullable
as bool,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String,signedReportUid: null == signedReportUid ? _self.signedReportUid : signedReportUid // ignore: cast_nullable_to_non_nullable
as String,notifiableFindings: null == notifiableFindings ? _self.notifiableFindings : notifiableFindings // ignore: cast_nullable_to_non_nullable
as List<NotifiableFindingModel>,hintShownDiseaseIds: null == hintShownDiseaseIds ? _self.hintShownDiseaseIds : hintShownDiseaseIds // ignore: cast_nullable_to_non_nullable
as List<String>,confirmatoryRequests: null == confirmatoryRequests ? _self.confirmatoryRequests : confirmatoryRequests // ignore: cast_nullable_to_non_nullable
as List<String>,createdByUid: null == createdByUid ? _self.createdByUid : createdByUid // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportDraftModel].
extension ReportDraftModelPatterns on ReportDraftModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportDraftModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportDraftModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportDraftModel value)  $default,){
final _that = this;
switch (_that) {
case _ReportDraftModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportDraftModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReportDraftModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'pathologistUid')  String pathologistUid, @JsonKey(name: 'kind')  String kind, @JsonKey(name: 'status')  String status, @JsonKey(name: 'baseReportUid')  String baseReportUid, @JsonKey(name: 'targetReportUid')  String targetReportUid, @JsonKey(name: 'prereadRunUid')  String prereadRunUid, @JsonKey(name: 'templateKey')  String templateKey, @JsonKey(name: 'title')  String title, @JsonKey(name: 'diagnosisType')  String diagnosisType, @JsonKey(name: 'diagnosis')  String diagnosis, @JsonKey(name: 'comments')  String comments, @JsonKey(name: 'responses')  List<ReportResponseModel> responses, @JsonKey(name: 'labelOverrides')  Map<String, String> labelOverrides, @JsonKey(name: 'labelOverrideCount')  int labelOverrideCount, @JsonKey(name: 'isCritical')  bool isCritical, @JsonKey(name: 'addendumText')  String addendumText, @JsonKey(name: 'amendmentReason')  String amendmentReason, @JsonKey(name: 'diagnosisStartedAt')  String diagnosisStartedAt, @JsonKey(name: 'startedFromPreread')  bool startedFromPreread, @JsonKey(name: 'startedAt')  String startedAt, @JsonKey(name: 'signedReportUid')  String signedReportUid, @JsonKey(name: 'notifiableFindings')  List<NotifiableFindingModel> notifiableFindings, @JsonKey(name: 'hintShownDiseaseIds')  List<String> hintShownDiseaseIds, @JsonKey(name: 'confirmatoryRequests')  List<String> confirmatoryRequests, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'language')  String language, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportDraftModel() when $default != null:
return $default(_that.uid,_that.caseUid,_that.pathologistUid,_that.kind,_that.status,_that.baseReportUid,_that.targetReportUid,_that.prereadRunUid,_that.templateKey,_that.title,_that.diagnosisType,_that.diagnosis,_that.comments,_that.responses,_that.labelOverrides,_that.labelOverrideCount,_that.isCritical,_that.addendumText,_that.amendmentReason,_that.diagnosisStartedAt,_that.startedFromPreread,_that.startedAt,_that.signedReportUid,_that.notifiableFindings,_that.hintShownDiseaseIds,_that.confirmatoryRequests,_that.createdByUid,_that.language,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'pathologistUid')  String pathologistUid, @JsonKey(name: 'kind')  String kind, @JsonKey(name: 'status')  String status, @JsonKey(name: 'baseReportUid')  String baseReportUid, @JsonKey(name: 'targetReportUid')  String targetReportUid, @JsonKey(name: 'prereadRunUid')  String prereadRunUid, @JsonKey(name: 'templateKey')  String templateKey, @JsonKey(name: 'title')  String title, @JsonKey(name: 'diagnosisType')  String diagnosisType, @JsonKey(name: 'diagnosis')  String diagnosis, @JsonKey(name: 'comments')  String comments, @JsonKey(name: 'responses')  List<ReportResponseModel> responses, @JsonKey(name: 'labelOverrides')  Map<String, String> labelOverrides, @JsonKey(name: 'labelOverrideCount')  int labelOverrideCount, @JsonKey(name: 'isCritical')  bool isCritical, @JsonKey(name: 'addendumText')  String addendumText, @JsonKey(name: 'amendmentReason')  String amendmentReason, @JsonKey(name: 'diagnosisStartedAt')  String diagnosisStartedAt, @JsonKey(name: 'startedFromPreread')  bool startedFromPreread, @JsonKey(name: 'startedAt')  String startedAt, @JsonKey(name: 'signedReportUid')  String signedReportUid, @JsonKey(name: 'notifiableFindings')  List<NotifiableFindingModel> notifiableFindings, @JsonKey(name: 'hintShownDiseaseIds')  List<String> hintShownDiseaseIds, @JsonKey(name: 'confirmatoryRequests')  List<String> confirmatoryRequests, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'language')  String language, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)  $default,) {final _that = this;
switch (_that) {
case _ReportDraftModel():
return $default(_that.uid,_that.caseUid,_that.pathologistUid,_that.kind,_that.status,_that.baseReportUid,_that.targetReportUid,_that.prereadRunUid,_that.templateKey,_that.title,_that.diagnosisType,_that.diagnosis,_that.comments,_that.responses,_that.labelOverrides,_that.labelOverrideCount,_that.isCritical,_that.addendumText,_that.amendmentReason,_that.diagnosisStartedAt,_that.startedFromPreread,_that.startedAt,_that.signedReportUid,_that.notifiableFindings,_that.hintShownDiseaseIds,_that.confirmatoryRequests,_that.createdByUid,_that.language,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'pathologistUid')  String pathologistUid, @JsonKey(name: 'kind')  String kind, @JsonKey(name: 'status')  String status, @JsonKey(name: 'baseReportUid')  String baseReportUid, @JsonKey(name: 'targetReportUid')  String targetReportUid, @JsonKey(name: 'prereadRunUid')  String prereadRunUid, @JsonKey(name: 'templateKey')  String templateKey, @JsonKey(name: 'title')  String title, @JsonKey(name: 'diagnosisType')  String diagnosisType, @JsonKey(name: 'diagnosis')  String diagnosis, @JsonKey(name: 'comments')  String comments, @JsonKey(name: 'responses')  List<ReportResponseModel> responses, @JsonKey(name: 'labelOverrides')  Map<String, String> labelOverrides, @JsonKey(name: 'labelOverrideCount')  int labelOverrideCount, @JsonKey(name: 'isCritical')  bool isCritical, @JsonKey(name: 'addendumText')  String addendumText, @JsonKey(name: 'amendmentReason')  String amendmentReason, @JsonKey(name: 'diagnosisStartedAt')  String diagnosisStartedAt, @JsonKey(name: 'startedFromPreread')  bool startedFromPreread, @JsonKey(name: 'startedAt')  String startedAt, @JsonKey(name: 'signedReportUid')  String signedReportUid, @JsonKey(name: 'notifiableFindings')  List<NotifiableFindingModel> notifiableFindings, @JsonKey(name: 'hintShownDiseaseIds')  List<String> hintShownDiseaseIds, @JsonKey(name: 'confirmatoryRequests')  List<String> confirmatoryRequests, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'language')  String language, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,) {final _that = this;
switch (_that) {
case _ReportDraftModel() when $default != null:
return $default(_that.uid,_that.caseUid,_that.pathologistUid,_that.kind,_that.status,_that.baseReportUid,_that.targetReportUid,_that.prereadRunUid,_that.templateKey,_that.title,_that.diagnosisType,_that.diagnosis,_that.comments,_that.responses,_that.labelOverrides,_that.labelOverrideCount,_that.isCritical,_that.addendumText,_that.amendmentReason,_that.diagnosisStartedAt,_that.startedFromPreread,_that.startedAt,_that.signedReportUid,_that.notifiableFindings,_that.hintShownDiseaseIds,_that.confirmatoryRequests,_that.createdByUid,_that.language,_that.lastUpdatedAt,_that.synced);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _ReportDraftModel extends ReportDraftModel {
  const _ReportDraftModel({@JsonKey(name: 'uid') this.uid = '', @JsonKey(name: 'caseUid') this.caseUid = '', @JsonKey(name: 'pathologistUid') this.pathologistUid = '', @JsonKey(name: 'kind') this.kind = 'Initial', @JsonKey(name: 'status') this.status = 'Editing', @JsonKey(name: 'baseReportUid') this.baseReportUid = '', @JsonKey(name: 'targetReportUid') this.targetReportUid = '', @JsonKey(name: 'prereadRunUid') this.prereadRunUid = '', @JsonKey(name: 'templateKey') this.templateKey = 'General', @JsonKey(name: 'title') this.title = '', @JsonKey(name: 'diagnosisType') this.diagnosisType = 'Final', @JsonKey(name: 'diagnosis') this.diagnosis = '', @JsonKey(name: 'comments') this.comments = '', @JsonKey(name: 'responses') final  List<ReportResponseModel> responses = const <ReportResponseModel>[], @JsonKey(name: 'labelOverrides') final  Map<String, String> labelOverrides = const <String, String>{}, @JsonKey(name: 'labelOverrideCount') this.labelOverrideCount = 0, @JsonKey(name: 'isCritical') this.isCritical = false, @JsonKey(name: 'addendumText') this.addendumText = '', @JsonKey(name: 'amendmentReason') this.amendmentReason = '', @JsonKey(name: 'diagnosisStartedAt') this.diagnosisStartedAt = '', @JsonKey(name: 'startedFromPreread') this.startedFromPreread = false, @JsonKey(name: 'startedAt') this.startedAt = '', @JsonKey(name: 'signedReportUid') this.signedReportUid = '', @JsonKey(name: 'notifiableFindings') final  List<NotifiableFindingModel> notifiableFindings = const <NotifiableFindingModel>[], @JsonKey(name: 'hintShownDiseaseIds') final  List<String> hintShownDiseaseIds = const <String>[], @JsonKey(name: 'confirmatoryRequests') final  List<String> confirmatoryRequests = const <String>[], @JsonKey(name: 'createdByUid') this.createdByUid = '', @JsonKey(name: 'language') this.language = '', @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = '', @JsonKey(includeFromJson: false, includeToJson: false) this.synced = true}): _responses = responses,_labelOverrides = labelOverrides,_notifiableFindings = notifiableFindings,_hintShownDiseaseIds = hintShownDiseaseIds,_confirmatoryRequests = confirmatoryRequests,super._();
  factory _ReportDraftModel.fromJson(Map<String, dynamic> json) => _$ReportDraftModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'caseUid') final  String caseUid;
@override@JsonKey(name: 'pathologistUid') final  String pathologistUid;
@override@JsonKey(name: 'kind') final  String kind;
@override@JsonKey(name: 'status') final  String status;
@override@JsonKey(name: 'baseReportUid') final  String baseReportUid;
@override@JsonKey(name: 'targetReportUid') final  String targetReportUid;
@override@JsonKey(name: 'prereadRunUid') final  String prereadRunUid;
@override@JsonKey(name: 'templateKey') final  String templateKey;
@override@JsonKey(name: 'title') final  String title;
@override@JsonKey(name: 'diagnosisType') final  String diagnosisType;
@override@JsonKey(name: 'diagnosis') final  String diagnosis;
@override@JsonKey(name: 'comments') final  String comments;
 final  List<ReportResponseModel> _responses;
@override@JsonKey(name: 'responses') List<ReportResponseModel> get responses {
  if (_responses is EqualUnmodifiableListView) return _responses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_responses);
}

 final  Map<String, String> _labelOverrides;
@override@JsonKey(name: 'labelOverrides') Map<String, String> get labelOverrides {
  if (_labelOverrides is EqualUnmodifiableMapView) return _labelOverrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_labelOverrides);
}

@override@JsonKey(name: 'labelOverrideCount') final  int labelOverrideCount;
@override@JsonKey(name: 'isCritical') final  bool isCritical;
@override@JsonKey(name: 'addendumText') final  String addendumText;
@override@JsonKey(name: 'amendmentReason') final  String amendmentReason;
@override@JsonKey(name: 'diagnosisStartedAt') final  String diagnosisStartedAt;
@override@JsonKey(name: 'startedFromPreread') final  bool startedFromPreread;
@override@JsonKey(name: 'startedAt') final  String startedAt;
@override@JsonKey(name: 'signedReportUid') final  String signedReportUid;
 final  List<NotifiableFindingModel> _notifiableFindings;
@override@JsonKey(name: 'notifiableFindings') List<NotifiableFindingModel> get notifiableFindings {
  if (_notifiableFindings is EqualUnmodifiableListView) return _notifiableFindings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notifiableFindings);
}

 final  List<String> _hintShownDiseaseIds;
@override@JsonKey(name: 'hintShownDiseaseIds') List<String> get hintShownDiseaseIds {
  if (_hintShownDiseaseIds is EqualUnmodifiableListView) return _hintShownDiseaseIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hintShownDiseaseIds);
}

 final  List<String> _confirmatoryRequests;
@override@JsonKey(name: 'confirmatoryRequests') List<String> get confirmatoryRequests {
  if (_confirmatoryRequests is EqualUnmodifiableListView) return _confirmatoryRequests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_confirmatoryRequests);
}

@override@JsonKey(name: 'createdByUid') final  String createdByUid;
@override@JsonKey(name: 'language') final  String language;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool synced;

/// Create a copy of ReportDraftModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportDraftModelCopyWith<_ReportDraftModel> get copyWith => __$ReportDraftModelCopyWithImpl<_ReportDraftModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportDraftModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportDraftModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.pathologistUid, pathologistUid) || other.pathologistUid == pathologistUid)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.status, status) || other.status == status)&&(identical(other.baseReportUid, baseReportUid) || other.baseReportUid == baseReportUid)&&(identical(other.targetReportUid, targetReportUid) || other.targetReportUid == targetReportUid)&&(identical(other.prereadRunUid, prereadRunUid) || other.prereadRunUid == prereadRunUid)&&(identical(other.templateKey, templateKey) || other.templateKey == templateKey)&&(identical(other.title, title) || other.title == title)&&(identical(other.diagnosisType, diagnosisType) || other.diagnosisType == diagnosisType)&&(identical(other.diagnosis, diagnosis) || other.diagnosis == diagnosis)&&(identical(other.comments, comments) || other.comments == comments)&&const DeepCollectionEquality().equals(other._responses, _responses)&&const DeepCollectionEquality().equals(other._labelOverrides, _labelOverrides)&&(identical(other.labelOverrideCount, labelOverrideCount) || other.labelOverrideCount == labelOverrideCount)&&(identical(other.isCritical, isCritical) || other.isCritical == isCritical)&&(identical(other.addendumText, addendumText) || other.addendumText == addendumText)&&(identical(other.amendmentReason, amendmentReason) || other.amendmentReason == amendmentReason)&&(identical(other.diagnosisStartedAt, diagnosisStartedAt) || other.diagnosisStartedAt == diagnosisStartedAt)&&(identical(other.startedFromPreread, startedFromPreread) || other.startedFromPreread == startedFromPreread)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.signedReportUid, signedReportUid) || other.signedReportUid == signedReportUid)&&const DeepCollectionEquality().equals(other._notifiableFindings, _notifiableFindings)&&const DeepCollectionEquality().equals(other._hintShownDiseaseIds, _hintShownDiseaseIds)&&const DeepCollectionEquality().equals(other._confirmatoryRequests, _confirmatoryRequests)&&(identical(other.createdByUid, createdByUid) || other.createdByUid == createdByUid)&&(identical(other.language, language) || other.language == language)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,caseUid,pathologistUid,kind,status,baseReportUid,targetReportUid,prereadRunUid,templateKey,title,diagnosisType,diagnosis,comments,const DeepCollectionEquality().hash(_responses),const DeepCollectionEquality().hash(_labelOverrides),labelOverrideCount,isCritical,addendumText,amendmentReason,diagnosisStartedAt,startedFromPreread,startedAt,signedReportUid,const DeepCollectionEquality().hash(_notifiableFindings),const DeepCollectionEquality().hash(_hintShownDiseaseIds),const DeepCollectionEquality().hash(_confirmatoryRequests),createdByUid,language,lastUpdatedAt,synced]);

@override
String toString() {
  return 'ReportDraftModel(uid: $uid, caseUid: $caseUid, pathologistUid: $pathologistUid, kind: $kind, status: $status, baseReportUid: $baseReportUid, targetReportUid: $targetReportUid, prereadRunUid: $prereadRunUid, templateKey: $templateKey, title: $title, diagnosisType: $diagnosisType, diagnosis: $diagnosis, comments: $comments, responses: $responses, labelOverrides: $labelOverrides, labelOverrideCount: $labelOverrideCount, isCritical: $isCritical, addendumText: $addendumText, amendmentReason: $amendmentReason, diagnosisStartedAt: $diagnosisStartedAt, startedFromPreread: $startedFromPreread, startedAt: $startedAt, signedReportUid: $signedReportUid, notifiableFindings: $notifiableFindings, hintShownDiseaseIds: $hintShownDiseaseIds, confirmatoryRequests: $confirmatoryRequests, createdByUid: $createdByUid, language: $language, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class _$ReportDraftModelCopyWith<$Res> implements $ReportDraftModelCopyWith<$Res> {
  factory _$ReportDraftModelCopyWith(_ReportDraftModel value, $Res Function(_ReportDraftModel) _then) = __$ReportDraftModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'pathologistUid') String pathologistUid,@JsonKey(name: 'kind') String kind,@JsonKey(name: 'status') String status,@JsonKey(name: 'baseReportUid') String baseReportUid,@JsonKey(name: 'targetReportUid') String targetReportUid,@JsonKey(name: 'prereadRunUid') String prereadRunUid,@JsonKey(name: 'templateKey') String templateKey,@JsonKey(name: 'title') String title,@JsonKey(name: 'diagnosisType') String diagnosisType,@JsonKey(name: 'diagnosis') String diagnosis,@JsonKey(name: 'comments') String comments,@JsonKey(name: 'responses') List<ReportResponseModel> responses,@JsonKey(name: 'labelOverrides') Map<String, String> labelOverrides,@JsonKey(name: 'labelOverrideCount') int labelOverrideCount,@JsonKey(name: 'isCritical') bool isCritical,@JsonKey(name: 'addendumText') String addendumText,@JsonKey(name: 'amendmentReason') String amendmentReason,@JsonKey(name: 'diagnosisStartedAt') String diagnosisStartedAt,@JsonKey(name: 'startedFromPreread') bool startedFromPreread,@JsonKey(name: 'startedAt') String startedAt,@JsonKey(name: 'signedReportUid') String signedReportUid,@JsonKey(name: 'notifiableFindings') List<NotifiableFindingModel> notifiableFindings,@JsonKey(name: 'hintShownDiseaseIds') List<String> hintShownDiseaseIds,@JsonKey(name: 'confirmatoryRequests') List<String> confirmatoryRequests,@JsonKey(name: 'createdByUid') String createdByUid,@JsonKey(name: 'language') String language,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class __$ReportDraftModelCopyWithImpl<$Res>
    implements _$ReportDraftModelCopyWith<$Res> {
  __$ReportDraftModelCopyWithImpl(this._self, this._then);

  final _ReportDraftModel _self;
  final $Res Function(_ReportDraftModel) _then;

/// Create a copy of ReportDraftModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? caseUid = null,Object? pathologistUid = null,Object? kind = null,Object? status = null,Object? baseReportUid = null,Object? targetReportUid = null,Object? prereadRunUid = null,Object? templateKey = null,Object? title = null,Object? diagnosisType = null,Object? diagnosis = null,Object? comments = null,Object? responses = null,Object? labelOverrides = null,Object? labelOverrideCount = null,Object? isCritical = null,Object? addendumText = null,Object? amendmentReason = null,Object? diagnosisStartedAt = null,Object? startedFromPreread = null,Object? startedAt = null,Object? signedReportUid = null,Object? notifiableFindings = null,Object? hintShownDiseaseIds = null,Object? confirmatoryRequests = null,Object? createdByUid = null,Object? language = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_ReportDraftModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,pathologistUid: null == pathologistUid ? _self.pathologistUid : pathologistUid // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,baseReportUid: null == baseReportUid ? _self.baseReportUid : baseReportUid // ignore: cast_nullable_to_non_nullable
as String,targetReportUid: null == targetReportUid ? _self.targetReportUid : targetReportUid // ignore: cast_nullable_to_non_nullable
as String,prereadRunUid: null == prereadRunUid ? _self.prereadRunUid : prereadRunUid // ignore: cast_nullable_to_non_nullable
as String,templateKey: null == templateKey ? _self.templateKey : templateKey // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,diagnosisType: null == diagnosisType ? _self.diagnosisType : diagnosisType // ignore: cast_nullable_to_non_nullable
as String,diagnosis: null == diagnosis ? _self.diagnosis : diagnosis // ignore: cast_nullable_to_non_nullable
as String,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as String,responses: null == responses ? _self._responses : responses // ignore: cast_nullable_to_non_nullable
as List<ReportResponseModel>,labelOverrides: null == labelOverrides ? _self._labelOverrides : labelOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,labelOverrideCount: null == labelOverrideCount ? _self.labelOverrideCount : labelOverrideCount // ignore: cast_nullable_to_non_nullable
as int,isCritical: null == isCritical ? _self.isCritical : isCritical // ignore: cast_nullable_to_non_nullable
as bool,addendumText: null == addendumText ? _self.addendumText : addendumText // ignore: cast_nullable_to_non_nullable
as String,amendmentReason: null == amendmentReason ? _self.amendmentReason : amendmentReason // ignore: cast_nullable_to_non_nullable
as String,diagnosisStartedAt: null == diagnosisStartedAt ? _self.diagnosisStartedAt : diagnosisStartedAt // ignore: cast_nullable_to_non_nullable
as String,startedFromPreread: null == startedFromPreread ? _self.startedFromPreread : startedFromPreread // ignore: cast_nullable_to_non_nullable
as bool,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String,signedReportUid: null == signedReportUid ? _self.signedReportUid : signedReportUid // ignore: cast_nullable_to_non_nullable
as String,notifiableFindings: null == notifiableFindings ? _self._notifiableFindings : notifiableFindings // ignore: cast_nullable_to_non_nullable
as List<NotifiableFindingModel>,hintShownDiseaseIds: null == hintShownDiseaseIds ? _self._hintShownDiseaseIds : hintShownDiseaseIds // ignore: cast_nullable_to_non_nullable
as List<String>,confirmatoryRequests: null == confirmatoryRequests ? _self._confirmatoryRequests : confirmatoryRequests // ignore: cast_nullable_to_non_nullable
as List<String>,createdByUid: null == createdByUid ? _self.createdByUid : createdByUid // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
