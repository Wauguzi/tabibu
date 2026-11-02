// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pathology_report_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PathologyReportModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'caseUid') String get caseUid;@JsonKey(name: 'version') int get version;@JsonKey(name: 'stage') String get stage;@JsonKey(name: 'status') String get status;@JsonKey(name: 'orderNumber') String get orderNumber;@JsonKey(name: 'testName') String get testName;@JsonKey(name: 'sampleCollectedAt') String get sampleCollectedAt;@JsonKey(name: 'sampleReceivedAt') String get sampleReceivedAt;@JsonKey(name: 'labAccessionNo') String get labAccessionNo;@JsonKey(name: 'profile') String get profile;@JsonKey(name: 'templateKey') String get templateKey;@JsonKey(name: 'title') String get title;@JsonKey(name: 'diagnosisType') String get diagnosisType;@JsonKey(name: 'diagnosis') String get diagnosis;@JsonKey(name: 'comments') String get comments;@JsonKey(name: 'responses') List<ReportResponseModel> get responses;@JsonKey(name: 'isCritical') bool get isCritical;@JsonKey(name: 'measurements') List<ReportMeasurementModel> get measurements;@JsonKey(name: 'addenda') List<ReportAddendumModel> get addenda;@JsonKey(name: 'amendmentReason') String get amendmentReason;@JsonKey(name: 'prereadRunUid') String get prereadRunUid;@JsonKey(name: 'doctorUid') String get doctorUid;@JsonKey(name: 'pathologistUid') String get pathologistUid;@JsonKey(name: 'readerUids') List<String> get readerUids;@JsonKey(name: 'signedByTitle') String get signedByTitle;@JsonKey(name: 'signedByName') String get signedByName;@JsonKey(name: 'signedByKmpdcNumber') String get signedByKmpdcNumber;@JsonKey(name: 'signedByFacilityName') String get signedByFacilityName;@JsonKey(name: 'signaturePath') String get signaturePath;@JsonKey(name: 'signatureSha256') String get signatureSha256;@JsonKey(name: 'contentSha256') String get contentSha256;@JsonKey(name: 'startedAt') String get startedAt;@JsonKey(name: 'scoredAt') String get scoredAt;@JsonKey(name: 'signedAt') String get signedAt;@JsonKey(name: 'doctorOpenedAt') String get doctorOpenedAt;@JsonKey(name: 'releasedToPatient') bool get releasedToPatient;@JsonKey(name: 'releasedAt') String get releasedAt;@JsonKey(name: 'releasedByUid') String get releasedByUid;@JsonKey(name: 'supersededAt') String get supersededAt;@JsonKey(name: 'supersededByUid') String get supersededByUid;@JsonKey(name: 'notifiableFindings') List<NotifiableFindingModel> get notifiableFindings;@JsonKey(name: 'confirmatoryRequests') List<String> get confirmatoryRequests;@JsonKey(name: 'createdByUid') String get createdByUid;@JsonKey(name: 'language') String get language;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;@JsonKey(includeFromJson: false, includeToJson: false) bool get synced;
/// Create a copy of PathologyReportModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PathologyReportModelCopyWith<PathologyReportModel> get copyWith => _$PathologyReportModelCopyWithImpl<PathologyReportModel>(this as PathologyReportModel, _$identity);

  /// Serializes this PathologyReportModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PathologyReportModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.version, version) || other.version == version)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.status, status) || other.status == status)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.testName, testName) || other.testName == testName)&&(identical(other.sampleCollectedAt, sampleCollectedAt) || other.sampleCollectedAt == sampleCollectedAt)&&(identical(other.sampleReceivedAt, sampleReceivedAt) || other.sampleReceivedAt == sampleReceivedAt)&&(identical(other.labAccessionNo, labAccessionNo) || other.labAccessionNo == labAccessionNo)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.templateKey, templateKey) || other.templateKey == templateKey)&&(identical(other.title, title) || other.title == title)&&(identical(other.diagnosisType, diagnosisType) || other.diagnosisType == diagnosisType)&&(identical(other.diagnosis, diagnosis) || other.diagnosis == diagnosis)&&(identical(other.comments, comments) || other.comments == comments)&&const DeepCollectionEquality().equals(other.responses, responses)&&(identical(other.isCritical, isCritical) || other.isCritical == isCritical)&&const DeepCollectionEquality().equals(other.measurements, measurements)&&const DeepCollectionEquality().equals(other.addenda, addenda)&&(identical(other.amendmentReason, amendmentReason) || other.amendmentReason == amendmentReason)&&(identical(other.prereadRunUid, prereadRunUid) || other.prereadRunUid == prereadRunUid)&&(identical(other.doctorUid, doctorUid) || other.doctorUid == doctorUid)&&(identical(other.pathologistUid, pathologistUid) || other.pathologistUid == pathologistUid)&&const DeepCollectionEquality().equals(other.readerUids, readerUids)&&(identical(other.signedByTitle, signedByTitle) || other.signedByTitle == signedByTitle)&&(identical(other.signedByName, signedByName) || other.signedByName == signedByName)&&(identical(other.signedByKmpdcNumber, signedByKmpdcNumber) || other.signedByKmpdcNumber == signedByKmpdcNumber)&&(identical(other.signedByFacilityName, signedByFacilityName) || other.signedByFacilityName == signedByFacilityName)&&(identical(other.signaturePath, signaturePath) || other.signaturePath == signaturePath)&&(identical(other.signatureSha256, signatureSha256) || other.signatureSha256 == signatureSha256)&&(identical(other.contentSha256, contentSha256) || other.contentSha256 == contentSha256)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.scoredAt, scoredAt) || other.scoredAt == scoredAt)&&(identical(other.signedAt, signedAt) || other.signedAt == signedAt)&&(identical(other.doctorOpenedAt, doctorOpenedAt) || other.doctorOpenedAt == doctorOpenedAt)&&(identical(other.releasedToPatient, releasedToPatient) || other.releasedToPatient == releasedToPatient)&&(identical(other.releasedAt, releasedAt) || other.releasedAt == releasedAt)&&(identical(other.releasedByUid, releasedByUid) || other.releasedByUid == releasedByUid)&&(identical(other.supersededAt, supersededAt) || other.supersededAt == supersededAt)&&(identical(other.supersededByUid, supersededByUid) || other.supersededByUid == supersededByUid)&&const DeepCollectionEquality().equals(other.notifiableFindings, notifiableFindings)&&const DeepCollectionEquality().equals(other.confirmatoryRequests, confirmatoryRequests)&&(identical(other.createdByUid, createdByUid) || other.createdByUid == createdByUid)&&(identical(other.language, language) || other.language == language)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,caseUid,version,stage,status,orderNumber,testName,sampleCollectedAt,sampleReceivedAt,labAccessionNo,profile,templateKey,title,diagnosisType,diagnosis,comments,const DeepCollectionEquality().hash(responses),isCritical,const DeepCollectionEquality().hash(measurements),const DeepCollectionEquality().hash(addenda),amendmentReason,prereadRunUid,doctorUid,pathologistUid,const DeepCollectionEquality().hash(readerUids),signedByTitle,signedByName,signedByKmpdcNumber,signedByFacilityName,signaturePath,signatureSha256,contentSha256,startedAt,scoredAt,signedAt,doctorOpenedAt,releasedToPatient,releasedAt,releasedByUid,supersededAt,supersededByUid,const DeepCollectionEquality().hash(notifiableFindings),const DeepCollectionEquality().hash(confirmatoryRequests),createdByUid,language,lastUpdatedAt,synced]);

@override
String toString() {
  return 'PathologyReportModel(uid: $uid, caseUid: $caseUid, version: $version, stage: $stage, status: $status, orderNumber: $orderNumber, testName: $testName, sampleCollectedAt: $sampleCollectedAt, sampleReceivedAt: $sampleReceivedAt, labAccessionNo: $labAccessionNo, profile: $profile, templateKey: $templateKey, title: $title, diagnosisType: $diagnosisType, diagnosis: $diagnosis, comments: $comments, responses: $responses, isCritical: $isCritical, measurements: $measurements, addenda: $addenda, amendmentReason: $amendmentReason, prereadRunUid: $prereadRunUid, doctorUid: $doctorUid, pathologistUid: $pathologistUid, readerUids: $readerUids, signedByTitle: $signedByTitle, signedByName: $signedByName, signedByKmpdcNumber: $signedByKmpdcNumber, signedByFacilityName: $signedByFacilityName, signaturePath: $signaturePath, signatureSha256: $signatureSha256, contentSha256: $contentSha256, startedAt: $startedAt, scoredAt: $scoredAt, signedAt: $signedAt, doctorOpenedAt: $doctorOpenedAt, releasedToPatient: $releasedToPatient, releasedAt: $releasedAt, releasedByUid: $releasedByUid, supersededAt: $supersededAt, supersededByUid: $supersededByUid, notifiableFindings: $notifiableFindings, confirmatoryRequests: $confirmatoryRequests, createdByUid: $createdByUid, language: $language, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class $PathologyReportModelCopyWith<$Res>  {
  factory $PathologyReportModelCopyWith(PathologyReportModel value, $Res Function(PathologyReportModel) _then) = _$PathologyReportModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'version') int version,@JsonKey(name: 'stage') String stage,@JsonKey(name: 'status') String status,@JsonKey(name: 'orderNumber') String orderNumber,@JsonKey(name: 'testName') String testName,@JsonKey(name: 'sampleCollectedAt') String sampleCollectedAt,@JsonKey(name: 'sampleReceivedAt') String sampleReceivedAt,@JsonKey(name: 'labAccessionNo') String labAccessionNo,@JsonKey(name: 'profile') String profile,@JsonKey(name: 'templateKey') String templateKey,@JsonKey(name: 'title') String title,@JsonKey(name: 'diagnosisType') String diagnosisType,@JsonKey(name: 'diagnosis') String diagnosis,@JsonKey(name: 'comments') String comments,@JsonKey(name: 'responses') List<ReportResponseModel> responses,@JsonKey(name: 'isCritical') bool isCritical,@JsonKey(name: 'measurements') List<ReportMeasurementModel> measurements,@JsonKey(name: 'addenda') List<ReportAddendumModel> addenda,@JsonKey(name: 'amendmentReason') String amendmentReason,@JsonKey(name: 'prereadRunUid') String prereadRunUid,@JsonKey(name: 'doctorUid') String doctorUid,@JsonKey(name: 'pathologistUid') String pathologistUid,@JsonKey(name: 'readerUids') List<String> readerUids,@JsonKey(name: 'signedByTitle') String signedByTitle,@JsonKey(name: 'signedByName') String signedByName,@JsonKey(name: 'signedByKmpdcNumber') String signedByKmpdcNumber,@JsonKey(name: 'signedByFacilityName') String signedByFacilityName,@JsonKey(name: 'signaturePath') String signaturePath,@JsonKey(name: 'signatureSha256') String signatureSha256,@JsonKey(name: 'contentSha256') String contentSha256,@JsonKey(name: 'startedAt') String startedAt,@JsonKey(name: 'scoredAt') String scoredAt,@JsonKey(name: 'signedAt') String signedAt,@JsonKey(name: 'doctorOpenedAt') String doctorOpenedAt,@JsonKey(name: 'releasedToPatient') bool releasedToPatient,@JsonKey(name: 'releasedAt') String releasedAt,@JsonKey(name: 'releasedByUid') String releasedByUid,@JsonKey(name: 'supersededAt') String supersededAt,@JsonKey(name: 'supersededByUid') String supersededByUid,@JsonKey(name: 'notifiableFindings') List<NotifiableFindingModel> notifiableFindings,@JsonKey(name: 'confirmatoryRequests') List<String> confirmatoryRequests,@JsonKey(name: 'createdByUid') String createdByUid,@JsonKey(name: 'language') String language,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class _$PathologyReportModelCopyWithImpl<$Res>
    implements $PathologyReportModelCopyWith<$Res> {
  _$PathologyReportModelCopyWithImpl(this._self, this._then);

  final PathologyReportModel _self;
  final $Res Function(PathologyReportModel) _then;

/// Create a copy of PathologyReportModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? caseUid = null,Object? version = null,Object? stage = null,Object? status = null,Object? orderNumber = null,Object? testName = null,Object? sampleCollectedAt = null,Object? sampleReceivedAt = null,Object? labAccessionNo = null,Object? profile = null,Object? templateKey = null,Object? title = null,Object? diagnosisType = null,Object? diagnosis = null,Object? comments = null,Object? responses = null,Object? isCritical = null,Object? measurements = null,Object? addenda = null,Object? amendmentReason = null,Object? prereadRunUid = null,Object? doctorUid = null,Object? pathologistUid = null,Object? readerUids = null,Object? signedByTitle = null,Object? signedByName = null,Object? signedByKmpdcNumber = null,Object? signedByFacilityName = null,Object? signaturePath = null,Object? signatureSha256 = null,Object? contentSha256 = null,Object? startedAt = null,Object? scoredAt = null,Object? signedAt = null,Object? doctorOpenedAt = null,Object? releasedToPatient = null,Object? releasedAt = null,Object? releasedByUid = null,Object? supersededAt = null,Object? supersededByUid = null,Object? notifiableFindings = null,Object? confirmatoryRequests = null,Object? createdByUid = null,Object? language = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,testName: null == testName ? _self.testName : testName // ignore: cast_nullable_to_non_nullable
as String,sampleCollectedAt: null == sampleCollectedAt ? _self.sampleCollectedAt : sampleCollectedAt // ignore: cast_nullable_to_non_nullable
as String,sampleReceivedAt: null == sampleReceivedAt ? _self.sampleReceivedAt : sampleReceivedAt // ignore: cast_nullable_to_non_nullable
as String,labAccessionNo: null == labAccessionNo ? _self.labAccessionNo : labAccessionNo // ignore: cast_nullable_to_non_nullable
as String,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String,templateKey: null == templateKey ? _self.templateKey : templateKey // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,diagnosisType: null == diagnosisType ? _self.diagnosisType : diagnosisType // ignore: cast_nullable_to_non_nullable
as String,diagnosis: null == diagnosis ? _self.diagnosis : diagnosis // ignore: cast_nullable_to_non_nullable
as String,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as String,responses: null == responses ? _self.responses : responses // ignore: cast_nullable_to_non_nullable
as List<ReportResponseModel>,isCritical: null == isCritical ? _self.isCritical : isCritical // ignore: cast_nullable_to_non_nullable
as bool,measurements: null == measurements ? _self.measurements : measurements // ignore: cast_nullable_to_non_nullable
as List<ReportMeasurementModel>,addenda: null == addenda ? _self.addenda : addenda // ignore: cast_nullable_to_non_nullable
as List<ReportAddendumModel>,amendmentReason: null == amendmentReason ? _self.amendmentReason : amendmentReason // ignore: cast_nullable_to_non_nullable
as String,prereadRunUid: null == prereadRunUid ? _self.prereadRunUid : prereadRunUid // ignore: cast_nullable_to_non_nullable
as String,doctorUid: null == doctorUid ? _self.doctorUid : doctorUid // ignore: cast_nullable_to_non_nullable
as String,pathologistUid: null == pathologistUid ? _self.pathologistUid : pathologistUid // ignore: cast_nullable_to_non_nullable
as String,readerUids: null == readerUids ? _self.readerUids : readerUids // ignore: cast_nullable_to_non_nullable
as List<String>,signedByTitle: null == signedByTitle ? _self.signedByTitle : signedByTitle // ignore: cast_nullable_to_non_nullable
as String,signedByName: null == signedByName ? _self.signedByName : signedByName // ignore: cast_nullable_to_non_nullable
as String,signedByKmpdcNumber: null == signedByKmpdcNumber ? _self.signedByKmpdcNumber : signedByKmpdcNumber // ignore: cast_nullable_to_non_nullable
as String,signedByFacilityName: null == signedByFacilityName ? _self.signedByFacilityName : signedByFacilityName // ignore: cast_nullable_to_non_nullable
as String,signaturePath: null == signaturePath ? _self.signaturePath : signaturePath // ignore: cast_nullable_to_non_nullable
as String,signatureSha256: null == signatureSha256 ? _self.signatureSha256 : signatureSha256 // ignore: cast_nullable_to_non_nullable
as String,contentSha256: null == contentSha256 ? _self.contentSha256 : contentSha256 // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String,scoredAt: null == scoredAt ? _self.scoredAt : scoredAt // ignore: cast_nullable_to_non_nullable
as String,signedAt: null == signedAt ? _self.signedAt : signedAt // ignore: cast_nullable_to_non_nullable
as String,doctorOpenedAt: null == doctorOpenedAt ? _self.doctorOpenedAt : doctorOpenedAt // ignore: cast_nullable_to_non_nullable
as String,releasedToPatient: null == releasedToPatient ? _self.releasedToPatient : releasedToPatient // ignore: cast_nullable_to_non_nullable
as bool,releasedAt: null == releasedAt ? _self.releasedAt : releasedAt // ignore: cast_nullable_to_non_nullable
as String,releasedByUid: null == releasedByUid ? _self.releasedByUid : releasedByUid // ignore: cast_nullable_to_non_nullable
as String,supersededAt: null == supersededAt ? _self.supersededAt : supersededAt // ignore: cast_nullable_to_non_nullable
as String,supersededByUid: null == supersededByUid ? _self.supersededByUid : supersededByUid // ignore: cast_nullable_to_non_nullable
as String,notifiableFindings: null == notifiableFindings ? _self.notifiableFindings : notifiableFindings // ignore: cast_nullable_to_non_nullable
as List<NotifiableFindingModel>,confirmatoryRequests: null == confirmatoryRequests ? _self.confirmatoryRequests : confirmatoryRequests // ignore: cast_nullable_to_non_nullable
as List<String>,createdByUid: null == createdByUid ? _self.createdByUid : createdByUid // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PathologyReportModel].
extension PathologyReportModelPatterns on PathologyReportModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PathologyReportModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PathologyReportModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PathologyReportModel value)  $default,){
final _that = this;
switch (_that) {
case _PathologyReportModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PathologyReportModel value)?  $default,){
final _that = this;
switch (_that) {
case _PathologyReportModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'version')  int version, @JsonKey(name: 'stage')  String stage, @JsonKey(name: 'status')  String status, @JsonKey(name: 'orderNumber')  String orderNumber, @JsonKey(name: 'testName')  String testName, @JsonKey(name: 'sampleCollectedAt')  String sampleCollectedAt, @JsonKey(name: 'sampleReceivedAt')  String sampleReceivedAt, @JsonKey(name: 'labAccessionNo')  String labAccessionNo, @JsonKey(name: 'profile')  String profile, @JsonKey(name: 'templateKey')  String templateKey, @JsonKey(name: 'title')  String title, @JsonKey(name: 'diagnosisType')  String diagnosisType, @JsonKey(name: 'diagnosis')  String diagnosis, @JsonKey(name: 'comments')  String comments, @JsonKey(name: 'responses')  List<ReportResponseModel> responses, @JsonKey(name: 'isCritical')  bool isCritical, @JsonKey(name: 'measurements')  List<ReportMeasurementModel> measurements, @JsonKey(name: 'addenda')  List<ReportAddendumModel> addenda, @JsonKey(name: 'amendmentReason')  String amendmentReason, @JsonKey(name: 'prereadRunUid')  String prereadRunUid, @JsonKey(name: 'doctorUid')  String doctorUid, @JsonKey(name: 'pathologistUid')  String pathologistUid, @JsonKey(name: 'readerUids')  List<String> readerUids, @JsonKey(name: 'signedByTitle')  String signedByTitle, @JsonKey(name: 'signedByName')  String signedByName, @JsonKey(name: 'signedByKmpdcNumber')  String signedByKmpdcNumber, @JsonKey(name: 'signedByFacilityName')  String signedByFacilityName, @JsonKey(name: 'signaturePath')  String signaturePath, @JsonKey(name: 'signatureSha256')  String signatureSha256, @JsonKey(name: 'contentSha256')  String contentSha256, @JsonKey(name: 'startedAt')  String startedAt, @JsonKey(name: 'scoredAt')  String scoredAt, @JsonKey(name: 'signedAt')  String signedAt, @JsonKey(name: 'doctorOpenedAt')  String doctorOpenedAt, @JsonKey(name: 'releasedToPatient')  bool releasedToPatient, @JsonKey(name: 'releasedAt')  String releasedAt, @JsonKey(name: 'releasedByUid')  String releasedByUid, @JsonKey(name: 'supersededAt')  String supersededAt, @JsonKey(name: 'supersededByUid')  String supersededByUid, @JsonKey(name: 'notifiableFindings')  List<NotifiableFindingModel> notifiableFindings, @JsonKey(name: 'confirmatoryRequests')  List<String> confirmatoryRequests, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'language')  String language, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PathologyReportModel() when $default != null:
return $default(_that.uid,_that.caseUid,_that.version,_that.stage,_that.status,_that.orderNumber,_that.testName,_that.sampleCollectedAt,_that.sampleReceivedAt,_that.labAccessionNo,_that.profile,_that.templateKey,_that.title,_that.diagnosisType,_that.diagnosis,_that.comments,_that.responses,_that.isCritical,_that.measurements,_that.addenda,_that.amendmentReason,_that.prereadRunUid,_that.doctorUid,_that.pathologistUid,_that.readerUids,_that.signedByTitle,_that.signedByName,_that.signedByKmpdcNumber,_that.signedByFacilityName,_that.signaturePath,_that.signatureSha256,_that.contentSha256,_that.startedAt,_that.scoredAt,_that.signedAt,_that.doctorOpenedAt,_that.releasedToPatient,_that.releasedAt,_that.releasedByUid,_that.supersededAt,_that.supersededByUid,_that.notifiableFindings,_that.confirmatoryRequests,_that.createdByUid,_that.language,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'version')  int version, @JsonKey(name: 'stage')  String stage, @JsonKey(name: 'status')  String status, @JsonKey(name: 'orderNumber')  String orderNumber, @JsonKey(name: 'testName')  String testName, @JsonKey(name: 'sampleCollectedAt')  String sampleCollectedAt, @JsonKey(name: 'sampleReceivedAt')  String sampleReceivedAt, @JsonKey(name: 'labAccessionNo')  String labAccessionNo, @JsonKey(name: 'profile')  String profile, @JsonKey(name: 'templateKey')  String templateKey, @JsonKey(name: 'title')  String title, @JsonKey(name: 'diagnosisType')  String diagnosisType, @JsonKey(name: 'diagnosis')  String diagnosis, @JsonKey(name: 'comments')  String comments, @JsonKey(name: 'responses')  List<ReportResponseModel> responses, @JsonKey(name: 'isCritical')  bool isCritical, @JsonKey(name: 'measurements')  List<ReportMeasurementModel> measurements, @JsonKey(name: 'addenda')  List<ReportAddendumModel> addenda, @JsonKey(name: 'amendmentReason')  String amendmentReason, @JsonKey(name: 'prereadRunUid')  String prereadRunUid, @JsonKey(name: 'doctorUid')  String doctorUid, @JsonKey(name: 'pathologistUid')  String pathologistUid, @JsonKey(name: 'readerUids')  List<String> readerUids, @JsonKey(name: 'signedByTitle')  String signedByTitle, @JsonKey(name: 'signedByName')  String signedByName, @JsonKey(name: 'signedByKmpdcNumber')  String signedByKmpdcNumber, @JsonKey(name: 'signedByFacilityName')  String signedByFacilityName, @JsonKey(name: 'signaturePath')  String signaturePath, @JsonKey(name: 'signatureSha256')  String signatureSha256, @JsonKey(name: 'contentSha256')  String contentSha256, @JsonKey(name: 'startedAt')  String startedAt, @JsonKey(name: 'scoredAt')  String scoredAt, @JsonKey(name: 'signedAt')  String signedAt, @JsonKey(name: 'doctorOpenedAt')  String doctorOpenedAt, @JsonKey(name: 'releasedToPatient')  bool releasedToPatient, @JsonKey(name: 'releasedAt')  String releasedAt, @JsonKey(name: 'releasedByUid')  String releasedByUid, @JsonKey(name: 'supersededAt')  String supersededAt, @JsonKey(name: 'supersededByUid')  String supersededByUid, @JsonKey(name: 'notifiableFindings')  List<NotifiableFindingModel> notifiableFindings, @JsonKey(name: 'confirmatoryRequests')  List<String> confirmatoryRequests, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'language')  String language, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)  $default,) {final _that = this;
switch (_that) {
case _PathologyReportModel():
return $default(_that.uid,_that.caseUid,_that.version,_that.stage,_that.status,_that.orderNumber,_that.testName,_that.sampleCollectedAt,_that.sampleReceivedAt,_that.labAccessionNo,_that.profile,_that.templateKey,_that.title,_that.diagnosisType,_that.diagnosis,_that.comments,_that.responses,_that.isCritical,_that.measurements,_that.addenda,_that.amendmentReason,_that.prereadRunUid,_that.doctorUid,_that.pathologistUid,_that.readerUids,_that.signedByTitle,_that.signedByName,_that.signedByKmpdcNumber,_that.signedByFacilityName,_that.signaturePath,_that.signatureSha256,_that.contentSha256,_that.startedAt,_that.scoredAt,_that.signedAt,_that.doctorOpenedAt,_that.releasedToPatient,_that.releasedAt,_that.releasedByUid,_that.supersededAt,_that.supersededByUid,_that.notifiableFindings,_that.confirmatoryRequests,_that.createdByUid,_that.language,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'version')  int version, @JsonKey(name: 'stage')  String stage, @JsonKey(name: 'status')  String status, @JsonKey(name: 'orderNumber')  String orderNumber, @JsonKey(name: 'testName')  String testName, @JsonKey(name: 'sampleCollectedAt')  String sampleCollectedAt, @JsonKey(name: 'sampleReceivedAt')  String sampleReceivedAt, @JsonKey(name: 'labAccessionNo')  String labAccessionNo, @JsonKey(name: 'profile')  String profile, @JsonKey(name: 'templateKey')  String templateKey, @JsonKey(name: 'title')  String title, @JsonKey(name: 'diagnosisType')  String diagnosisType, @JsonKey(name: 'diagnosis')  String diagnosis, @JsonKey(name: 'comments')  String comments, @JsonKey(name: 'responses')  List<ReportResponseModel> responses, @JsonKey(name: 'isCritical')  bool isCritical, @JsonKey(name: 'measurements')  List<ReportMeasurementModel> measurements, @JsonKey(name: 'addenda')  List<ReportAddendumModel> addenda, @JsonKey(name: 'amendmentReason')  String amendmentReason, @JsonKey(name: 'prereadRunUid')  String prereadRunUid, @JsonKey(name: 'doctorUid')  String doctorUid, @JsonKey(name: 'pathologistUid')  String pathologistUid, @JsonKey(name: 'readerUids')  List<String> readerUids, @JsonKey(name: 'signedByTitle')  String signedByTitle, @JsonKey(name: 'signedByName')  String signedByName, @JsonKey(name: 'signedByKmpdcNumber')  String signedByKmpdcNumber, @JsonKey(name: 'signedByFacilityName')  String signedByFacilityName, @JsonKey(name: 'signaturePath')  String signaturePath, @JsonKey(name: 'signatureSha256')  String signatureSha256, @JsonKey(name: 'contentSha256')  String contentSha256, @JsonKey(name: 'startedAt')  String startedAt, @JsonKey(name: 'scoredAt')  String scoredAt, @JsonKey(name: 'signedAt')  String signedAt, @JsonKey(name: 'doctorOpenedAt')  String doctorOpenedAt, @JsonKey(name: 'releasedToPatient')  bool releasedToPatient, @JsonKey(name: 'releasedAt')  String releasedAt, @JsonKey(name: 'releasedByUid')  String releasedByUid, @JsonKey(name: 'supersededAt')  String supersededAt, @JsonKey(name: 'supersededByUid')  String supersededByUid, @JsonKey(name: 'notifiableFindings')  List<NotifiableFindingModel> notifiableFindings, @JsonKey(name: 'confirmatoryRequests')  List<String> confirmatoryRequests, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'language')  String language, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,) {final _that = this;
switch (_that) {
case _PathologyReportModel() when $default != null:
return $default(_that.uid,_that.caseUid,_that.version,_that.stage,_that.status,_that.orderNumber,_that.testName,_that.sampleCollectedAt,_that.sampleReceivedAt,_that.labAccessionNo,_that.profile,_that.templateKey,_that.title,_that.diagnosisType,_that.diagnosis,_that.comments,_that.responses,_that.isCritical,_that.measurements,_that.addenda,_that.amendmentReason,_that.prereadRunUid,_that.doctorUid,_that.pathologistUid,_that.readerUids,_that.signedByTitle,_that.signedByName,_that.signedByKmpdcNumber,_that.signedByFacilityName,_that.signaturePath,_that.signatureSha256,_that.contentSha256,_that.startedAt,_that.scoredAt,_that.signedAt,_that.doctorOpenedAt,_that.releasedToPatient,_that.releasedAt,_that.releasedByUid,_that.supersededAt,_that.supersededByUid,_that.notifiableFindings,_that.confirmatoryRequests,_that.createdByUid,_that.language,_that.lastUpdatedAt,_that.synced);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _PathologyReportModel extends PathologyReportModel {
  const _PathologyReportModel({@JsonKey(name: 'uid') this.uid = '', @JsonKey(name: 'caseUid') this.caseUid = '', @JsonKey(name: 'version') this.version = 0, @JsonKey(name: 'stage') this.stage = 'Initial', @JsonKey(name: 'status') this.status = 'Signed', @JsonKey(name: 'orderNumber') this.orderNumber = '', @JsonKey(name: 'testName') this.testName = '', @JsonKey(name: 'sampleCollectedAt') this.sampleCollectedAt = '', @JsonKey(name: 'sampleReceivedAt') this.sampleReceivedAt = '', @JsonKey(name: 'labAccessionNo') this.labAccessionNo = '', @JsonKey(name: 'profile') this.profile = 'None', @JsonKey(name: 'templateKey') this.templateKey = 'General', @JsonKey(name: 'title') this.title = '', @JsonKey(name: 'diagnosisType') this.diagnosisType = 'Final', @JsonKey(name: 'diagnosis') this.diagnosis = '', @JsonKey(name: 'comments') this.comments = '', @JsonKey(name: 'responses') final  List<ReportResponseModel> responses = const <ReportResponseModel>[], @JsonKey(name: 'isCritical') this.isCritical = false, @JsonKey(name: 'measurements') final  List<ReportMeasurementModel> measurements = const <ReportMeasurementModel>[], @JsonKey(name: 'addenda') final  List<ReportAddendumModel> addenda = const <ReportAddendumModel>[], @JsonKey(name: 'amendmentReason') this.amendmentReason = '', @JsonKey(name: 'prereadRunUid') this.prereadRunUid = '', @JsonKey(name: 'doctorUid') this.doctorUid = '', @JsonKey(name: 'pathologistUid') this.pathologistUid = '', @JsonKey(name: 'readerUids') final  List<String> readerUids = const <String>[], @JsonKey(name: 'signedByTitle') this.signedByTitle = '', @JsonKey(name: 'signedByName') this.signedByName = '', @JsonKey(name: 'signedByKmpdcNumber') this.signedByKmpdcNumber = '', @JsonKey(name: 'signedByFacilityName') this.signedByFacilityName = '', @JsonKey(name: 'signaturePath') this.signaturePath = '', @JsonKey(name: 'signatureSha256') this.signatureSha256 = '', @JsonKey(name: 'contentSha256') this.contentSha256 = '', @JsonKey(name: 'startedAt') this.startedAt = '', @JsonKey(name: 'scoredAt') this.scoredAt = '', @JsonKey(name: 'signedAt') this.signedAt = '', @JsonKey(name: 'doctorOpenedAt') this.doctorOpenedAt = '', @JsonKey(name: 'releasedToPatient') this.releasedToPatient = false, @JsonKey(name: 'releasedAt') this.releasedAt = '', @JsonKey(name: 'releasedByUid') this.releasedByUid = '', @JsonKey(name: 'supersededAt') this.supersededAt = '', @JsonKey(name: 'supersededByUid') this.supersededByUid = '', @JsonKey(name: 'notifiableFindings') final  List<NotifiableFindingModel> notifiableFindings = const <NotifiableFindingModel>[], @JsonKey(name: 'confirmatoryRequests') final  List<String> confirmatoryRequests = const <String>[], @JsonKey(name: 'createdByUid') this.createdByUid = '', @JsonKey(name: 'language') this.language = 'en', @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = '', @JsonKey(includeFromJson: false, includeToJson: false) this.synced = true}): _responses = responses,_measurements = measurements,_addenda = addenda,_readerUids = readerUids,_notifiableFindings = notifiableFindings,_confirmatoryRequests = confirmatoryRequests,super._();
  factory _PathologyReportModel.fromJson(Map<String, dynamic> json) => _$PathologyReportModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'caseUid') final  String caseUid;
@override@JsonKey(name: 'version') final  int version;
@override@JsonKey(name: 'stage') final  String stage;
@override@JsonKey(name: 'status') final  String status;
@override@JsonKey(name: 'orderNumber') final  String orderNumber;
@override@JsonKey(name: 'testName') final  String testName;
@override@JsonKey(name: 'sampleCollectedAt') final  String sampleCollectedAt;
@override@JsonKey(name: 'sampleReceivedAt') final  String sampleReceivedAt;
@override@JsonKey(name: 'labAccessionNo') final  String labAccessionNo;
@override@JsonKey(name: 'profile') final  String profile;
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

@override@JsonKey(name: 'isCritical') final  bool isCritical;
 final  List<ReportMeasurementModel> _measurements;
@override@JsonKey(name: 'measurements') List<ReportMeasurementModel> get measurements {
  if (_measurements is EqualUnmodifiableListView) return _measurements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_measurements);
}

 final  List<ReportAddendumModel> _addenda;
@override@JsonKey(name: 'addenda') List<ReportAddendumModel> get addenda {
  if (_addenda is EqualUnmodifiableListView) return _addenda;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_addenda);
}

@override@JsonKey(name: 'amendmentReason') final  String amendmentReason;
@override@JsonKey(name: 'prereadRunUid') final  String prereadRunUid;
@override@JsonKey(name: 'doctorUid') final  String doctorUid;
@override@JsonKey(name: 'pathologistUid') final  String pathologistUid;
 final  List<String> _readerUids;
@override@JsonKey(name: 'readerUids') List<String> get readerUids {
  if (_readerUids is EqualUnmodifiableListView) return _readerUids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_readerUids);
}

@override@JsonKey(name: 'signedByTitle') final  String signedByTitle;
@override@JsonKey(name: 'signedByName') final  String signedByName;
@override@JsonKey(name: 'signedByKmpdcNumber') final  String signedByKmpdcNumber;
@override@JsonKey(name: 'signedByFacilityName') final  String signedByFacilityName;
@override@JsonKey(name: 'signaturePath') final  String signaturePath;
@override@JsonKey(name: 'signatureSha256') final  String signatureSha256;
@override@JsonKey(name: 'contentSha256') final  String contentSha256;
@override@JsonKey(name: 'startedAt') final  String startedAt;
@override@JsonKey(name: 'scoredAt') final  String scoredAt;
@override@JsonKey(name: 'signedAt') final  String signedAt;
@override@JsonKey(name: 'doctorOpenedAt') final  String doctorOpenedAt;
@override@JsonKey(name: 'releasedToPatient') final  bool releasedToPatient;
@override@JsonKey(name: 'releasedAt') final  String releasedAt;
@override@JsonKey(name: 'releasedByUid') final  String releasedByUid;
@override@JsonKey(name: 'supersededAt') final  String supersededAt;
@override@JsonKey(name: 'supersededByUid') final  String supersededByUid;
 final  List<NotifiableFindingModel> _notifiableFindings;
@override@JsonKey(name: 'notifiableFindings') List<NotifiableFindingModel> get notifiableFindings {
  if (_notifiableFindings is EqualUnmodifiableListView) return _notifiableFindings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notifiableFindings);
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

/// Create a copy of PathologyReportModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PathologyReportModelCopyWith<_PathologyReportModel> get copyWith => __$PathologyReportModelCopyWithImpl<_PathologyReportModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PathologyReportModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PathologyReportModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.version, version) || other.version == version)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.status, status) || other.status == status)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.testName, testName) || other.testName == testName)&&(identical(other.sampleCollectedAt, sampleCollectedAt) || other.sampleCollectedAt == sampleCollectedAt)&&(identical(other.sampleReceivedAt, sampleReceivedAt) || other.sampleReceivedAt == sampleReceivedAt)&&(identical(other.labAccessionNo, labAccessionNo) || other.labAccessionNo == labAccessionNo)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.templateKey, templateKey) || other.templateKey == templateKey)&&(identical(other.title, title) || other.title == title)&&(identical(other.diagnosisType, diagnosisType) || other.diagnosisType == diagnosisType)&&(identical(other.diagnosis, diagnosis) || other.diagnosis == diagnosis)&&(identical(other.comments, comments) || other.comments == comments)&&const DeepCollectionEquality().equals(other._responses, _responses)&&(identical(other.isCritical, isCritical) || other.isCritical == isCritical)&&const DeepCollectionEquality().equals(other._measurements, _measurements)&&const DeepCollectionEquality().equals(other._addenda, _addenda)&&(identical(other.amendmentReason, amendmentReason) || other.amendmentReason == amendmentReason)&&(identical(other.prereadRunUid, prereadRunUid) || other.prereadRunUid == prereadRunUid)&&(identical(other.doctorUid, doctorUid) || other.doctorUid == doctorUid)&&(identical(other.pathologistUid, pathologistUid) || other.pathologistUid == pathologistUid)&&const DeepCollectionEquality().equals(other._readerUids, _readerUids)&&(identical(other.signedByTitle, signedByTitle) || other.signedByTitle == signedByTitle)&&(identical(other.signedByName, signedByName) || other.signedByName == signedByName)&&(identical(other.signedByKmpdcNumber, signedByKmpdcNumber) || other.signedByKmpdcNumber == signedByKmpdcNumber)&&(identical(other.signedByFacilityName, signedByFacilityName) || other.signedByFacilityName == signedByFacilityName)&&(identical(other.signaturePath, signaturePath) || other.signaturePath == signaturePath)&&(identical(other.signatureSha256, signatureSha256) || other.signatureSha256 == signatureSha256)&&(identical(other.contentSha256, contentSha256) || other.contentSha256 == contentSha256)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.scoredAt, scoredAt) || other.scoredAt == scoredAt)&&(identical(other.signedAt, signedAt) || other.signedAt == signedAt)&&(identical(other.doctorOpenedAt, doctorOpenedAt) || other.doctorOpenedAt == doctorOpenedAt)&&(identical(other.releasedToPatient, releasedToPatient) || other.releasedToPatient == releasedToPatient)&&(identical(other.releasedAt, releasedAt) || other.releasedAt == releasedAt)&&(identical(other.releasedByUid, releasedByUid) || other.releasedByUid == releasedByUid)&&(identical(other.supersededAt, supersededAt) || other.supersededAt == supersededAt)&&(identical(other.supersededByUid, supersededByUid) || other.supersededByUid == supersededByUid)&&const DeepCollectionEquality().equals(other._notifiableFindings, _notifiableFindings)&&const DeepCollectionEquality().equals(other._confirmatoryRequests, _confirmatoryRequests)&&(identical(other.createdByUid, createdByUid) || other.createdByUid == createdByUid)&&(identical(other.language, language) || other.language == language)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,caseUid,version,stage,status,orderNumber,testName,sampleCollectedAt,sampleReceivedAt,labAccessionNo,profile,templateKey,title,diagnosisType,diagnosis,comments,const DeepCollectionEquality().hash(_responses),isCritical,const DeepCollectionEquality().hash(_measurements),const DeepCollectionEquality().hash(_addenda),amendmentReason,prereadRunUid,doctorUid,pathologistUid,const DeepCollectionEquality().hash(_readerUids),signedByTitle,signedByName,signedByKmpdcNumber,signedByFacilityName,signaturePath,signatureSha256,contentSha256,startedAt,scoredAt,signedAt,doctorOpenedAt,releasedToPatient,releasedAt,releasedByUid,supersededAt,supersededByUid,const DeepCollectionEquality().hash(_notifiableFindings),const DeepCollectionEquality().hash(_confirmatoryRequests),createdByUid,language,lastUpdatedAt,synced]);

@override
String toString() {
  return 'PathologyReportModel(uid: $uid, caseUid: $caseUid, version: $version, stage: $stage, status: $status, orderNumber: $orderNumber, testName: $testName, sampleCollectedAt: $sampleCollectedAt, sampleReceivedAt: $sampleReceivedAt, labAccessionNo: $labAccessionNo, profile: $profile, templateKey: $templateKey, title: $title, diagnosisType: $diagnosisType, diagnosis: $diagnosis, comments: $comments, responses: $responses, isCritical: $isCritical, measurements: $measurements, addenda: $addenda, amendmentReason: $amendmentReason, prereadRunUid: $prereadRunUid, doctorUid: $doctorUid, pathologistUid: $pathologistUid, readerUids: $readerUids, signedByTitle: $signedByTitle, signedByName: $signedByName, signedByKmpdcNumber: $signedByKmpdcNumber, signedByFacilityName: $signedByFacilityName, signaturePath: $signaturePath, signatureSha256: $signatureSha256, contentSha256: $contentSha256, startedAt: $startedAt, scoredAt: $scoredAt, signedAt: $signedAt, doctorOpenedAt: $doctorOpenedAt, releasedToPatient: $releasedToPatient, releasedAt: $releasedAt, releasedByUid: $releasedByUid, supersededAt: $supersededAt, supersededByUid: $supersededByUid, notifiableFindings: $notifiableFindings, confirmatoryRequests: $confirmatoryRequests, createdByUid: $createdByUid, language: $language, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class _$PathologyReportModelCopyWith<$Res> implements $PathologyReportModelCopyWith<$Res> {
  factory _$PathologyReportModelCopyWith(_PathologyReportModel value, $Res Function(_PathologyReportModel) _then) = __$PathologyReportModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'version') int version,@JsonKey(name: 'stage') String stage,@JsonKey(name: 'status') String status,@JsonKey(name: 'orderNumber') String orderNumber,@JsonKey(name: 'testName') String testName,@JsonKey(name: 'sampleCollectedAt') String sampleCollectedAt,@JsonKey(name: 'sampleReceivedAt') String sampleReceivedAt,@JsonKey(name: 'labAccessionNo') String labAccessionNo,@JsonKey(name: 'profile') String profile,@JsonKey(name: 'templateKey') String templateKey,@JsonKey(name: 'title') String title,@JsonKey(name: 'diagnosisType') String diagnosisType,@JsonKey(name: 'diagnosis') String diagnosis,@JsonKey(name: 'comments') String comments,@JsonKey(name: 'responses') List<ReportResponseModel> responses,@JsonKey(name: 'isCritical') bool isCritical,@JsonKey(name: 'measurements') List<ReportMeasurementModel> measurements,@JsonKey(name: 'addenda') List<ReportAddendumModel> addenda,@JsonKey(name: 'amendmentReason') String amendmentReason,@JsonKey(name: 'prereadRunUid') String prereadRunUid,@JsonKey(name: 'doctorUid') String doctorUid,@JsonKey(name: 'pathologistUid') String pathologistUid,@JsonKey(name: 'readerUids') List<String> readerUids,@JsonKey(name: 'signedByTitle') String signedByTitle,@JsonKey(name: 'signedByName') String signedByName,@JsonKey(name: 'signedByKmpdcNumber') String signedByKmpdcNumber,@JsonKey(name: 'signedByFacilityName') String signedByFacilityName,@JsonKey(name: 'signaturePath') String signaturePath,@JsonKey(name: 'signatureSha256') String signatureSha256,@JsonKey(name: 'contentSha256') String contentSha256,@JsonKey(name: 'startedAt') String startedAt,@JsonKey(name: 'scoredAt') String scoredAt,@JsonKey(name: 'signedAt') String signedAt,@JsonKey(name: 'doctorOpenedAt') String doctorOpenedAt,@JsonKey(name: 'releasedToPatient') bool releasedToPatient,@JsonKey(name: 'releasedAt') String releasedAt,@JsonKey(name: 'releasedByUid') String releasedByUid,@JsonKey(name: 'supersededAt') String supersededAt,@JsonKey(name: 'supersededByUid') String supersededByUid,@JsonKey(name: 'notifiableFindings') List<NotifiableFindingModel> notifiableFindings,@JsonKey(name: 'confirmatoryRequests') List<String> confirmatoryRequests,@JsonKey(name: 'createdByUid') String createdByUid,@JsonKey(name: 'language') String language,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class __$PathologyReportModelCopyWithImpl<$Res>
    implements _$PathologyReportModelCopyWith<$Res> {
  __$PathologyReportModelCopyWithImpl(this._self, this._then);

  final _PathologyReportModel _self;
  final $Res Function(_PathologyReportModel) _then;

/// Create a copy of PathologyReportModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? caseUid = null,Object? version = null,Object? stage = null,Object? status = null,Object? orderNumber = null,Object? testName = null,Object? sampleCollectedAt = null,Object? sampleReceivedAt = null,Object? labAccessionNo = null,Object? profile = null,Object? templateKey = null,Object? title = null,Object? diagnosisType = null,Object? diagnosis = null,Object? comments = null,Object? responses = null,Object? isCritical = null,Object? measurements = null,Object? addenda = null,Object? amendmentReason = null,Object? prereadRunUid = null,Object? doctorUid = null,Object? pathologistUid = null,Object? readerUids = null,Object? signedByTitle = null,Object? signedByName = null,Object? signedByKmpdcNumber = null,Object? signedByFacilityName = null,Object? signaturePath = null,Object? signatureSha256 = null,Object? contentSha256 = null,Object? startedAt = null,Object? scoredAt = null,Object? signedAt = null,Object? doctorOpenedAt = null,Object? releasedToPatient = null,Object? releasedAt = null,Object? releasedByUid = null,Object? supersededAt = null,Object? supersededByUid = null,Object? notifiableFindings = null,Object? confirmatoryRequests = null,Object? createdByUid = null,Object? language = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_PathologyReportModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,testName: null == testName ? _self.testName : testName // ignore: cast_nullable_to_non_nullable
as String,sampleCollectedAt: null == sampleCollectedAt ? _self.sampleCollectedAt : sampleCollectedAt // ignore: cast_nullable_to_non_nullable
as String,sampleReceivedAt: null == sampleReceivedAt ? _self.sampleReceivedAt : sampleReceivedAt // ignore: cast_nullable_to_non_nullable
as String,labAccessionNo: null == labAccessionNo ? _self.labAccessionNo : labAccessionNo // ignore: cast_nullable_to_non_nullable
as String,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String,templateKey: null == templateKey ? _self.templateKey : templateKey // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,diagnosisType: null == diagnosisType ? _self.diagnosisType : diagnosisType // ignore: cast_nullable_to_non_nullable
as String,diagnosis: null == diagnosis ? _self.diagnosis : diagnosis // ignore: cast_nullable_to_non_nullable
as String,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as String,responses: null == responses ? _self._responses : responses // ignore: cast_nullable_to_non_nullable
as List<ReportResponseModel>,isCritical: null == isCritical ? _self.isCritical : isCritical // ignore: cast_nullable_to_non_nullable
as bool,measurements: null == measurements ? _self._measurements : measurements // ignore: cast_nullable_to_non_nullable
as List<ReportMeasurementModel>,addenda: null == addenda ? _self._addenda : addenda // ignore: cast_nullable_to_non_nullable
as List<ReportAddendumModel>,amendmentReason: null == amendmentReason ? _self.amendmentReason : amendmentReason // ignore: cast_nullable_to_non_nullable
as String,prereadRunUid: null == prereadRunUid ? _self.prereadRunUid : prereadRunUid // ignore: cast_nullable_to_non_nullable
as String,doctorUid: null == doctorUid ? _self.doctorUid : doctorUid // ignore: cast_nullable_to_non_nullable
as String,pathologistUid: null == pathologistUid ? _self.pathologistUid : pathologistUid // ignore: cast_nullable_to_non_nullable
as String,readerUids: null == readerUids ? _self._readerUids : readerUids // ignore: cast_nullable_to_non_nullable
as List<String>,signedByTitle: null == signedByTitle ? _self.signedByTitle : signedByTitle // ignore: cast_nullable_to_non_nullable
as String,signedByName: null == signedByName ? _self.signedByName : signedByName // ignore: cast_nullable_to_non_nullable
as String,signedByKmpdcNumber: null == signedByKmpdcNumber ? _self.signedByKmpdcNumber : signedByKmpdcNumber // ignore: cast_nullable_to_non_nullable
as String,signedByFacilityName: null == signedByFacilityName ? _self.signedByFacilityName : signedByFacilityName // ignore: cast_nullable_to_non_nullable
as String,signaturePath: null == signaturePath ? _self.signaturePath : signaturePath // ignore: cast_nullable_to_non_nullable
as String,signatureSha256: null == signatureSha256 ? _self.signatureSha256 : signatureSha256 // ignore: cast_nullable_to_non_nullable
as String,contentSha256: null == contentSha256 ? _self.contentSha256 : contentSha256 // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String,scoredAt: null == scoredAt ? _self.scoredAt : scoredAt // ignore: cast_nullable_to_non_nullable
as String,signedAt: null == signedAt ? _self.signedAt : signedAt // ignore: cast_nullable_to_non_nullable
as String,doctorOpenedAt: null == doctorOpenedAt ? _self.doctorOpenedAt : doctorOpenedAt // ignore: cast_nullable_to_non_nullable
as String,releasedToPatient: null == releasedToPatient ? _self.releasedToPatient : releasedToPatient // ignore: cast_nullable_to_non_nullable
as bool,releasedAt: null == releasedAt ? _self.releasedAt : releasedAt // ignore: cast_nullable_to_non_nullable
as String,releasedByUid: null == releasedByUid ? _self.releasedByUid : releasedByUid // ignore: cast_nullable_to_non_nullable
as String,supersededAt: null == supersededAt ? _self.supersededAt : supersededAt // ignore: cast_nullable_to_non_nullable
as String,supersededByUid: null == supersededByUid ? _self.supersededByUid : supersededByUid // ignore: cast_nullable_to_non_nullable
as String,notifiableFindings: null == notifiableFindings ? _self._notifiableFindings : notifiableFindings // ignore: cast_nullable_to_non_nullable
as List<NotifiableFindingModel>,confirmatoryRequests: null == confirmatoryRequests ? _self._confirmatoryRequests : confirmatoryRequests // ignore: cast_nullable_to_non_nullable
as List<String>,createdByUid: null == createdByUid ? _self.createdByUid : createdByUid // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
