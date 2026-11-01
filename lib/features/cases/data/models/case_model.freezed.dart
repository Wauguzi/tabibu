// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'case_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CaseModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'orderNumber') String get orderNumber;@JsonKey(name: 'appointmentUid') String get appointmentUid;@JsonKey(name: 'createdByUid') String get createdByUid;@JsonKey(name: 'doctorUid') String get doctorUid;@JsonKey(name: 'doctorName') String get doctorName;@JsonKey(name: 'doctorFacilityName') String get doctorFacilityName;@JsonKey(name: 'patientId') String get patientId;@JsonKey(name: 'patientUid') String get patientUid;@JsonKey(name: 'patientName') String get patientName;@JsonKey(name: 'patientSex') String get patientSex;@JsonKey(name: 'patientAgeYears') int get patientAgeYears;@JsonKey(name: 'requestedPathologistUid') String get requestedPathologistUid;@JsonKey(name: 'requestedPathologistName') String get requestedPathologistName;@JsonKey(name: 'pathologistRequestedAt') String get pathologistRequestedAt;@JsonKey(name: 'pathologistRequestExpiresAt') String get pathologistRequestExpiresAt;@JsonKey(name: 'declinedPathologistUids') List<String> get declinedPathologistUids;@JsonKey(name: 'pathologistUid') String get pathologistUid;@JsonKey(name: 'pathologistName') String get pathologistName;@JsonKey(name: 'pathologistAcceptedAt') String get pathologistAcceptedAt;@JsonKey(name: 'viewerUids') List<String> get viewerUids;@JsonKey(name: 'participantUids') List<String> get participantUids;@JsonKey(name: 'tests') List<OrderedTestModel> get tests;@JsonKey(name: 'totalPriceKes') int get totalPriceKes;@JsonKey(name: 'isPriceEstimate') bool get isPriceEstimate;@JsonKey(name: 'priority') String get priority;@JsonKey(name: 'clinicalNotes') String get clinicalNotes;@JsonKey(name: 'sampleNotes') String get sampleNotes;@JsonKey(name: 'notesLanguage') String get notesLanguage;@JsonKey(name: 'sampleCollectedAt') String get sampleCollectedAt;@JsonKey(name: 'sampleReceivedAt') String get sampleReceivedAt;@JsonKey(name: 'labAccessionNo') String get labAccessionNo;@JsonKey(name: 'requiresSlides') bool get requiresSlides;@JsonKey(name: 'slideUploadUids') List<String> get slideUploadUids;@JsonKey(name: 'slideImages') List<SlideImageModel> get slideImages;@JsonKey(name: 'prereadRunUid') String get prereadRunUid;@JsonKey(name: 'currentReportUid') String get currentReportUid;@JsonKey(name: 'resultState') String get resultState;@JsonKey(name: 'discussionAppointmentUid') String get discussionAppointmentUid;@JsonKey(name: 'currentLocation') String get currentLocation;@JsonKey(name: 'currentStage') String get currentStage;@JsonKey(name: 'currentStep') String get currentStep;@JsonKey(name: 'stageSeq') int get stageSeq;@JsonKey(name: 'stageEnteredAt') String get stageEnteredAt;@JsonKey(name: 'releasedToPatient') bool get releasedToPatient;@JsonKey(name: 'discussedAt') String get discussedAt;@JsonKey(name: 'releasedAt') String get releasedAt;@JsonKey(name: 'cancelReason') String get cancelReason;@JsonKey(name: 'createdAt') String get createdAt;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;@JsonKey(includeFromJson: false, includeToJson: false) bool get synced;
/// Create a copy of CaseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaseModelCopyWith<CaseModel> get copyWith => _$CaseModelCopyWithImpl<CaseModel>(this as CaseModel, _$identity);

  /// Serializes this CaseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaseModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.appointmentUid, appointmentUid) || other.appointmentUid == appointmentUid)&&(identical(other.createdByUid, createdByUid) || other.createdByUid == createdByUid)&&(identical(other.doctorUid, doctorUid) || other.doctorUid == doctorUid)&&(identical(other.doctorName, doctorName) || other.doctorName == doctorName)&&(identical(other.doctorFacilityName, doctorFacilityName) || other.doctorFacilityName == doctorFacilityName)&&(identical(other.patientId, patientId) || other.patientId == patientId)&&(identical(other.patientUid, patientUid) || other.patientUid == patientUid)&&(identical(other.patientName, patientName) || other.patientName == patientName)&&(identical(other.patientSex, patientSex) || other.patientSex == patientSex)&&(identical(other.patientAgeYears, patientAgeYears) || other.patientAgeYears == patientAgeYears)&&(identical(other.requestedPathologistUid, requestedPathologistUid) || other.requestedPathologistUid == requestedPathologistUid)&&(identical(other.requestedPathologistName, requestedPathologistName) || other.requestedPathologistName == requestedPathologistName)&&(identical(other.pathologistRequestedAt, pathologistRequestedAt) || other.pathologistRequestedAt == pathologistRequestedAt)&&(identical(other.pathologistRequestExpiresAt, pathologistRequestExpiresAt) || other.pathologistRequestExpiresAt == pathologistRequestExpiresAt)&&const DeepCollectionEquality().equals(other.declinedPathologistUids, declinedPathologistUids)&&(identical(other.pathologistUid, pathologistUid) || other.pathologistUid == pathologistUid)&&(identical(other.pathologistName, pathologistName) || other.pathologistName == pathologistName)&&(identical(other.pathologistAcceptedAt, pathologistAcceptedAt) || other.pathologistAcceptedAt == pathologistAcceptedAt)&&const DeepCollectionEquality().equals(other.viewerUids, viewerUids)&&const DeepCollectionEquality().equals(other.participantUids, participantUids)&&const DeepCollectionEquality().equals(other.tests, tests)&&(identical(other.totalPriceKes, totalPriceKes) || other.totalPriceKes == totalPriceKes)&&(identical(other.isPriceEstimate, isPriceEstimate) || other.isPriceEstimate == isPriceEstimate)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.clinicalNotes, clinicalNotes) || other.clinicalNotes == clinicalNotes)&&(identical(other.sampleNotes, sampleNotes) || other.sampleNotes == sampleNotes)&&(identical(other.notesLanguage, notesLanguage) || other.notesLanguage == notesLanguage)&&(identical(other.sampleCollectedAt, sampleCollectedAt) || other.sampleCollectedAt == sampleCollectedAt)&&(identical(other.sampleReceivedAt, sampleReceivedAt) || other.sampleReceivedAt == sampleReceivedAt)&&(identical(other.labAccessionNo, labAccessionNo) || other.labAccessionNo == labAccessionNo)&&(identical(other.requiresSlides, requiresSlides) || other.requiresSlides == requiresSlides)&&const DeepCollectionEquality().equals(other.slideUploadUids, slideUploadUids)&&const DeepCollectionEquality().equals(other.slideImages, slideImages)&&(identical(other.prereadRunUid, prereadRunUid) || other.prereadRunUid == prereadRunUid)&&(identical(other.currentReportUid, currentReportUid) || other.currentReportUid == currentReportUid)&&(identical(other.resultState, resultState) || other.resultState == resultState)&&(identical(other.discussionAppointmentUid, discussionAppointmentUid) || other.discussionAppointmentUid == discussionAppointmentUid)&&(identical(other.currentLocation, currentLocation) || other.currentLocation == currentLocation)&&(identical(other.currentStage, currentStage) || other.currentStage == currentStage)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.stageSeq, stageSeq) || other.stageSeq == stageSeq)&&(identical(other.stageEnteredAt, stageEnteredAt) || other.stageEnteredAt == stageEnteredAt)&&(identical(other.releasedToPatient, releasedToPatient) || other.releasedToPatient == releasedToPatient)&&(identical(other.discussedAt, discussedAt) || other.discussedAt == discussedAt)&&(identical(other.releasedAt, releasedAt) || other.releasedAt == releasedAt)&&(identical(other.cancelReason, cancelReason) || other.cancelReason == cancelReason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,orderNumber,appointmentUid,createdByUid,doctorUid,doctorName,doctorFacilityName,patientId,patientUid,patientName,patientSex,patientAgeYears,requestedPathologistUid,requestedPathologistName,pathologistRequestedAt,pathologistRequestExpiresAt,const DeepCollectionEquality().hash(declinedPathologistUids),pathologistUid,pathologistName,pathologistAcceptedAt,const DeepCollectionEquality().hash(viewerUids),const DeepCollectionEquality().hash(participantUids),const DeepCollectionEquality().hash(tests),totalPriceKes,isPriceEstimate,priority,clinicalNotes,sampleNotes,notesLanguage,sampleCollectedAt,sampleReceivedAt,labAccessionNo,requiresSlides,const DeepCollectionEquality().hash(slideUploadUids),const DeepCollectionEquality().hash(slideImages),prereadRunUid,currentReportUid,resultState,discussionAppointmentUid,currentLocation,currentStage,currentStep,stageSeq,stageEnteredAt,releasedToPatient,discussedAt,releasedAt,cancelReason,createdAt,lastUpdatedAt,synced]);

@override
String toString() {
  return 'CaseModel(uid: $uid, orderNumber: $orderNumber, appointmentUid: $appointmentUid, createdByUid: $createdByUid, doctorUid: $doctorUid, doctorName: $doctorName, doctorFacilityName: $doctorFacilityName, patientId: $patientId, patientUid: $patientUid, patientName: $patientName, patientSex: $patientSex, patientAgeYears: $patientAgeYears, requestedPathologistUid: $requestedPathologistUid, requestedPathologistName: $requestedPathologistName, pathologistRequestedAt: $pathologistRequestedAt, pathologistRequestExpiresAt: $pathologistRequestExpiresAt, declinedPathologistUids: $declinedPathologistUids, pathologistUid: $pathologistUid, pathologistName: $pathologistName, pathologistAcceptedAt: $pathologistAcceptedAt, viewerUids: $viewerUids, participantUids: $participantUids, tests: $tests, totalPriceKes: $totalPriceKes, isPriceEstimate: $isPriceEstimate, priority: $priority, clinicalNotes: $clinicalNotes, sampleNotes: $sampleNotes, notesLanguage: $notesLanguage, sampleCollectedAt: $sampleCollectedAt, sampleReceivedAt: $sampleReceivedAt, labAccessionNo: $labAccessionNo, requiresSlides: $requiresSlides, slideUploadUids: $slideUploadUids, slideImages: $slideImages, prereadRunUid: $prereadRunUid, currentReportUid: $currentReportUid, resultState: $resultState, discussionAppointmentUid: $discussionAppointmentUid, currentLocation: $currentLocation, currentStage: $currentStage, currentStep: $currentStep, stageSeq: $stageSeq, stageEnteredAt: $stageEnteredAt, releasedToPatient: $releasedToPatient, discussedAt: $discussedAt, releasedAt: $releasedAt, cancelReason: $cancelReason, createdAt: $createdAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class $CaseModelCopyWith<$Res>  {
  factory $CaseModelCopyWith(CaseModel value, $Res Function(CaseModel) _then) = _$CaseModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'orderNumber') String orderNumber,@JsonKey(name: 'appointmentUid') String appointmentUid,@JsonKey(name: 'createdByUid') String createdByUid,@JsonKey(name: 'doctorUid') String doctorUid,@JsonKey(name: 'doctorName') String doctorName,@JsonKey(name: 'doctorFacilityName') String doctorFacilityName,@JsonKey(name: 'patientId') String patientId,@JsonKey(name: 'patientUid') String patientUid,@JsonKey(name: 'patientName') String patientName,@JsonKey(name: 'patientSex') String patientSex,@JsonKey(name: 'patientAgeYears') int patientAgeYears,@JsonKey(name: 'requestedPathologistUid') String requestedPathologistUid,@JsonKey(name: 'requestedPathologistName') String requestedPathologistName,@JsonKey(name: 'pathologistRequestedAt') String pathologistRequestedAt,@JsonKey(name: 'pathologistRequestExpiresAt') String pathologistRequestExpiresAt,@JsonKey(name: 'declinedPathologistUids') List<String> declinedPathologistUids,@JsonKey(name: 'pathologistUid') String pathologistUid,@JsonKey(name: 'pathologistName') String pathologistName,@JsonKey(name: 'pathologistAcceptedAt') String pathologistAcceptedAt,@JsonKey(name: 'viewerUids') List<String> viewerUids,@JsonKey(name: 'participantUids') List<String> participantUids,@JsonKey(name: 'tests') List<OrderedTestModel> tests,@JsonKey(name: 'totalPriceKes') int totalPriceKes,@JsonKey(name: 'isPriceEstimate') bool isPriceEstimate,@JsonKey(name: 'priority') String priority,@JsonKey(name: 'clinicalNotes') String clinicalNotes,@JsonKey(name: 'sampleNotes') String sampleNotes,@JsonKey(name: 'notesLanguage') String notesLanguage,@JsonKey(name: 'sampleCollectedAt') String sampleCollectedAt,@JsonKey(name: 'sampleReceivedAt') String sampleReceivedAt,@JsonKey(name: 'labAccessionNo') String labAccessionNo,@JsonKey(name: 'requiresSlides') bool requiresSlides,@JsonKey(name: 'slideUploadUids') List<String> slideUploadUids,@JsonKey(name: 'slideImages') List<SlideImageModel> slideImages,@JsonKey(name: 'prereadRunUid') String prereadRunUid,@JsonKey(name: 'currentReportUid') String currentReportUid,@JsonKey(name: 'resultState') String resultState,@JsonKey(name: 'discussionAppointmentUid') String discussionAppointmentUid,@JsonKey(name: 'currentLocation') String currentLocation,@JsonKey(name: 'currentStage') String currentStage,@JsonKey(name: 'currentStep') String currentStep,@JsonKey(name: 'stageSeq') int stageSeq,@JsonKey(name: 'stageEnteredAt') String stageEnteredAt,@JsonKey(name: 'releasedToPatient') bool releasedToPatient,@JsonKey(name: 'discussedAt') String discussedAt,@JsonKey(name: 'releasedAt') String releasedAt,@JsonKey(name: 'cancelReason') String cancelReason,@JsonKey(name: 'createdAt') String createdAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class _$CaseModelCopyWithImpl<$Res>
    implements $CaseModelCopyWith<$Res> {
  _$CaseModelCopyWithImpl(this._self, this._then);

  final CaseModel _self;
  final $Res Function(CaseModel) _then;

/// Create a copy of CaseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? orderNumber = null,Object? appointmentUid = null,Object? createdByUid = null,Object? doctorUid = null,Object? doctorName = null,Object? doctorFacilityName = null,Object? patientId = null,Object? patientUid = null,Object? patientName = null,Object? patientSex = null,Object? patientAgeYears = null,Object? requestedPathologistUid = null,Object? requestedPathologistName = null,Object? pathologistRequestedAt = null,Object? pathologistRequestExpiresAt = null,Object? declinedPathologistUids = null,Object? pathologistUid = null,Object? pathologistName = null,Object? pathologistAcceptedAt = null,Object? viewerUids = null,Object? participantUids = null,Object? tests = null,Object? totalPriceKes = null,Object? isPriceEstimate = null,Object? priority = null,Object? clinicalNotes = null,Object? sampleNotes = null,Object? notesLanguage = null,Object? sampleCollectedAt = null,Object? sampleReceivedAt = null,Object? labAccessionNo = null,Object? requiresSlides = null,Object? slideUploadUids = null,Object? slideImages = null,Object? prereadRunUid = null,Object? currentReportUid = null,Object? resultState = null,Object? discussionAppointmentUid = null,Object? currentLocation = null,Object? currentStage = null,Object? currentStep = null,Object? stageSeq = null,Object? stageEnteredAt = null,Object? releasedToPatient = null,Object? discussedAt = null,Object? releasedAt = null,Object? cancelReason = null,Object? createdAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,appointmentUid: null == appointmentUid ? _self.appointmentUid : appointmentUid // ignore: cast_nullable_to_non_nullable
as String,createdByUid: null == createdByUid ? _self.createdByUid : createdByUid // ignore: cast_nullable_to_non_nullable
as String,doctorUid: null == doctorUid ? _self.doctorUid : doctorUid // ignore: cast_nullable_to_non_nullable
as String,doctorName: null == doctorName ? _self.doctorName : doctorName // ignore: cast_nullable_to_non_nullable
as String,doctorFacilityName: null == doctorFacilityName ? _self.doctorFacilityName : doctorFacilityName // ignore: cast_nullable_to_non_nullable
as String,patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,patientUid: null == patientUid ? _self.patientUid : patientUid // ignore: cast_nullable_to_non_nullable
as String,patientName: null == patientName ? _self.patientName : patientName // ignore: cast_nullable_to_non_nullable
as String,patientSex: null == patientSex ? _self.patientSex : patientSex // ignore: cast_nullable_to_non_nullable
as String,patientAgeYears: null == patientAgeYears ? _self.patientAgeYears : patientAgeYears // ignore: cast_nullable_to_non_nullable
as int,requestedPathologistUid: null == requestedPathologistUid ? _self.requestedPathologistUid : requestedPathologistUid // ignore: cast_nullable_to_non_nullable
as String,requestedPathologistName: null == requestedPathologistName ? _self.requestedPathologistName : requestedPathologistName // ignore: cast_nullable_to_non_nullable
as String,pathologistRequestedAt: null == pathologistRequestedAt ? _self.pathologistRequestedAt : pathologistRequestedAt // ignore: cast_nullable_to_non_nullable
as String,pathologistRequestExpiresAt: null == pathologistRequestExpiresAt ? _self.pathologistRequestExpiresAt : pathologistRequestExpiresAt // ignore: cast_nullable_to_non_nullable
as String,declinedPathologistUids: null == declinedPathologistUids ? _self.declinedPathologistUids : declinedPathologistUids // ignore: cast_nullable_to_non_nullable
as List<String>,pathologistUid: null == pathologistUid ? _self.pathologistUid : pathologistUid // ignore: cast_nullable_to_non_nullable
as String,pathologistName: null == pathologistName ? _self.pathologistName : pathologistName // ignore: cast_nullable_to_non_nullable
as String,pathologistAcceptedAt: null == pathologistAcceptedAt ? _self.pathologistAcceptedAt : pathologistAcceptedAt // ignore: cast_nullable_to_non_nullable
as String,viewerUids: null == viewerUids ? _self.viewerUids : viewerUids // ignore: cast_nullable_to_non_nullable
as List<String>,participantUids: null == participantUids ? _self.participantUids : participantUids // ignore: cast_nullable_to_non_nullable
as List<String>,tests: null == tests ? _self.tests : tests // ignore: cast_nullable_to_non_nullable
as List<OrderedTestModel>,totalPriceKes: null == totalPriceKes ? _self.totalPriceKes : totalPriceKes // ignore: cast_nullable_to_non_nullable
as int,isPriceEstimate: null == isPriceEstimate ? _self.isPriceEstimate : isPriceEstimate // ignore: cast_nullable_to_non_nullable
as bool,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String,clinicalNotes: null == clinicalNotes ? _self.clinicalNotes : clinicalNotes // ignore: cast_nullable_to_non_nullable
as String,sampleNotes: null == sampleNotes ? _self.sampleNotes : sampleNotes // ignore: cast_nullable_to_non_nullable
as String,notesLanguage: null == notesLanguage ? _self.notesLanguage : notesLanguage // ignore: cast_nullable_to_non_nullable
as String,sampleCollectedAt: null == sampleCollectedAt ? _self.sampleCollectedAt : sampleCollectedAt // ignore: cast_nullable_to_non_nullable
as String,sampleReceivedAt: null == sampleReceivedAt ? _self.sampleReceivedAt : sampleReceivedAt // ignore: cast_nullable_to_non_nullable
as String,labAccessionNo: null == labAccessionNo ? _self.labAccessionNo : labAccessionNo // ignore: cast_nullable_to_non_nullable
as String,requiresSlides: null == requiresSlides ? _self.requiresSlides : requiresSlides // ignore: cast_nullable_to_non_nullable
as bool,slideUploadUids: null == slideUploadUids ? _self.slideUploadUids : slideUploadUids // ignore: cast_nullable_to_non_nullable
as List<String>,slideImages: null == slideImages ? _self.slideImages : slideImages // ignore: cast_nullable_to_non_nullable
as List<SlideImageModel>,prereadRunUid: null == prereadRunUid ? _self.prereadRunUid : prereadRunUid // ignore: cast_nullable_to_non_nullable
as String,currentReportUid: null == currentReportUid ? _self.currentReportUid : currentReportUid // ignore: cast_nullable_to_non_nullable
as String,resultState: null == resultState ? _self.resultState : resultState // ignore: cast_nullable_to_non_nullable
as String,discussionAppointmentUid: null == discussionAppointmentUid ? _self.discussionAppointmentUid : discussionAppointmentUid // ignore: cast_nullable_to_non_nullable
as String,currentLocation: null == currentLocation ? _self.currentLocation : currentLocation // ignore: cast_nullable_to_non_nullable
as String,currentStage: null == currentStage ? _self.currentStage : currentStage // ignore: cast_nullable_to_non_nullable
as String,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as String,stageSeq: null == stageSeq ? _self.stageSeq : stageSeq // ignore: cast_nullable_to_non_nullable
as int,stageEnteredAt: null == stageEnteredAt ? _self.stageEnteredAt : stageEnteredAt // ignore: cast_nullable_to_non_nullable
as String,releasedToPatient: null == releasedToPatient ? _self.releasedToPatient : releasedToPatient // ignore: cast_nullable_to_non_nullable
as bool,discussedAt: null == discussedAt ? _self.discussedAt : discussedAt // ignore: cast_nullable_to_non_nullable
as String,releasedAt: null == releasedAt ? _self.releasedAt : releasedAt // ignore: cast_nullable_to_non_nullable
as String,cancelReason: null == cancelReason ? _self.cancelReason : cancelReason // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CaseModel].
extension CaseModelPatterns on CaseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CaseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CaseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CaseModel value)  $default,){
final _that = this;
switch (_that) {
case _CaseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CaseModel value)?  $default,){
final _that = this;
switch (_that) {
case _CaseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'orderNumber')  String orderNumber, @JsonKey(name: 'appointmentUid')  String appointmentUid, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'doctorUid')  String doctorUid, @JsonKey(name: 'doctorName')  String doctorName, @JsonKey(name: 'doctorFacilityName')  String doctorFacilityName, @JsonKey(name: 'patientId')  String patientId, @JsonKey(name: 'patientUid')  String patientUid, @JsonKey(name: 'patientName')  String patientName, @JsonKey(name: 'patientSex')  String patientSex, @JsonKey(name: 'patientAgeYears')  int patientAgeYears, @JsonKey(name: 'requestedPathologistUid')  String requestedPathologistUid, @JsonKey(name: 'requestedPathologistName')  String requestedPathologistName, @JsonKey(name: 'pathologistRequestedAt')  String pathologistRequestedAt, @JsonKey(name: 'pathologistRequestExpiresAt')  String pathologistRequestExpiresAt, @JsonKey(name: 'declinedPathologistUids')  List<String> declinedPathologistUids, @JsonKey(name: 'pathologistUid')  String pathologistUid, @JsonKey(name: 'pathologistName')  String pathologistName, @JsonKey(name: 'pathologistAcceptedAt')  String pathologistAcceptedAt, @JsonKey(name: 'viewerUids')  List<String> viewerUids, @JsonKey(name: 'participantUids')  List<String> participantUids, @JsonKey(name: 'tests')  List<OrderedTestModel> tests, @JsonKey(name: 'totalPriceKes')  int totalPriceKes, @JsonKey(name: 'isPriceEstimate')  bool isPriceEstimate, @JsonKey(name: 'priority')  String priority, @JsonKey(name: 'clinicalNotes')  String clinicalNotes, @JsonKey(name: 'sampleNotes')  String sampleNotes, @JsonKey(name: 'notesLanguage')  String notesLanguage, @JsonKey(name: 'sampleCollectedAt')  String sampleCollectedAt, @JsonKey(name: 'sampleReceivedAt')  String sampleReceivedAt, @JsonKey(name: 'labAccessionNo')  String labAccessionNo, @JsonKey(name: 'requiresSlides')  bool requiresSlides, @JsonKey(name: 'slideUploadUids')  List<String> slideUploadUids, @JsonKey(name: 'slideImages')  List<SlideImageModel> slideImages, @JsonKey(name: 'prereadRunUid')  String prereadRunUid, @JsonKey(name: 'currentReportUid')  String currentReportUid, @JsonKey(name: 'resultState')  String resultState, @JsonKey(name: 'discussionAppointmentUid')  String discussionAppointmentUid, @JsonKey(name: 'currentLocation')  String currentLocation, @JsonKey(name: 'currentStage')  String currentStage, @JsonKey(name: 'currentStep')  String currentStep, @JsonKey(name: 'stageSeq')  int stageSeq, @JsonKey(name: 'stageEnteredAt')  String stageEnteredAt, @JsonKey(name: 'releasedToPatient')  bool releasedToPatient, @JsonKey(name: 'discussedAt')  String discussedAt, @JsonKey(name: 'releasedAt')  String releasedAt, @JsonKey(name: 'cancelReason')  String cancelReason, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CaseModel() when $default != null:
return $default(_that.uid,_that.orderNumber,_that.appointmentUid,_that.createdByUid,_that.doctorUid,_that.doctorName,_that.doctorFacilityName,_that.patientId,_that.patientUid,_that.patientName,_that.patientSex,_that.patientAgeYears,_that.requestedPathologistUid,_that.requestedPathologistName,_that.pathologistRequestedAt,_that.pathologistRequestExpiresAt,_that.declinedPathologistUids,_that.pathologistUid,_that.pathologistName,_that.pathologistAcceptedAt,_that.viewerUids,_that.participantUids,_that.tests,_that.totalPriceKes,_that.isPriceEstimate,_that.priority,_that.clinicalNotes,_that.sampleNotes,_that.notesLanguage,_that.sampleCollectedAt,_that.sampleReceivedAt,_that.labAccessionNo,_that.requiresSlides,_that.slideUploadUids,_that.slideImages,_that.prereadRunUid,_that.currentReportUid,_that.resultState,_that.discussionAppointmentUid,_that.currentLocation,_that.currentStage,_that.currentStep,_that.stageSeq,_that.stageEnteredAt,_that.releasedToPatient,_that.discussedAt,_that.releasedAt,_that.cancelReason,_that.createdAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'orderNumber')  String orderNumber, @JsonKey(name: 'appointmentUid')  String appointmentUid, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'doctorUid')  String doctorUid, @JsonKey(name: 'doctorName')  String doctorName, @JsonKey(name: 'doctorFacilityName')  String doctorFacilityName, @JsonKey(name: 'patientId')  String patientId, @JsonKey(name: 'patientUid')  String patientUid, @JsonKey(name: 'patientName')  String patientName, @JsonKey(name: 'patientSex')  String patientSex, @JsonKey(name: 'patientAgeYears')  int patientAgeYears, @JsonKey(name: 'requestedPathologistUid')  String requestedPathologistUid, @JsonKey(name: 'requestedPathologistName')  String requestedPathologistName, @JsonKey(name: 'pathologistRequestedAt')  String pathologistRequestedAt, @JsonKey(name: 'pathologistRequestExpiresAt')  String pathologistRequestExpiresAt, @JsonKey(name: 'declinedPathologistUids')  List<String> declinedPathologistUids, @JsonKey(name: 'pathologistUid')  String pathologistUid, @JsonKey(name: 'pathologistName')  String pathologistName, @JsonKey(name: 'pathologistAcceptedAt')  String pathologistAcceptedAt, @JsonKey(name: 'viewerUids')  List<String> viewerUids, @JsonKey(name: 'participantUids')  List<String> participantUids, @JsonKey(name: 'tests')  List<OrderedTestModel> tests, @JsonKey(name: 'totalPriceKes')  int totalPriceKes, @JsonKey(name: 'isPriceEstimate')  bool isPriceEstimate, @JsonKey(name: 'priority')  String priority, @JsonKey(name: 'clinicalNotes')  String clinicalNotes, @JsonKey(name: 'sampleNotes')  String sampleNotes, @JsonKey(name: 'notesLanguage')  String notesLanguage, @JsonKey(name: 'sampleCollectedAt')  String sampleCollectedAt, @JsonKey(name: 'sampleReceivedAt')  String sampleReceivedAt, @JsonKey(name: 'labAccessionNo')  String labAccessionNo, @JsonKey(name: 'requiresSlides')  bool requiresSlides, @JsonKey(name: 'slideUploadUids')  List<String> slideUploadUids, @JsonKey(name: 'slideImages')  List<SlideImageModel> slideImages, @JsonKey(name: 'prereadRunUid')  String prereadRunUid, @JsonKey(name: 'currentReportUid')  String currentReportUid, @JsonKey(name: 'resultState')  String resultState, @JsonKey(name: 'discussionAppointmentUid')  String discussionAppointmentUid, @JsonKey(name: 'currentLocation')  String currentLocation, @JsonKey(name: 'currentStage')  String currentStage, @JsonKey(name: 'currentStep')  String currentStep, @JsonKey(name: 'stageSeq')  int stageSeq, @JsonKey(name: 'stageEnteredAt')  String stageEnteredAt, @JsonKey(name: 'releasedToPatient')  bool releasedToPatient, @JsonKey(name: 'discussedAt')  String discussedAt, @JsonKey(name: 'releasedAt')  String releasedAt, @JsonKey(name: 'cancelReason')  String cancelReason, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)  $default,) {final _that = this;
switch (_that) {
case _CaseModel():
return $default(_that.uid,_that.orderNumber,_that.appointmentUid,_that.createdByUid,_that.doctorUid,_that.doctorName,_that.doctorFacilityName,_that.patientId,_that.patientUid,_that.patientName,_that.patientSex,_that.patientAgeYears,_that.requestedPathologistUid,_that.requestedPathologistName,_that.pathologistRequestedAt,_that.pathologistRequestExpiresAt,_that.declinedPathologistUids,_that.pathologistUid,_that.pathologistName,_that.pathologistAcceptedAt,_that.viewerUids,_that.participantUids,_that.tests,_that.totalPriceKes,_that.isPriceEstimate,_that.priority,_that.clinicalNotes,_that.sampleNotes,_that.notesLanguage,_that.sampleCollectedAt,_that.sampleReceivedAt,_that.labAccessionNo,_that.requiresSlides,_that.slideUploadUids,_that.slideImages,_that.prereadRunUid,_that.currentReportUid,_that.resultState,_that.discussionAppointmentUid,_that.currentLocation,_that.currentStage,_that.currentStep,_that.stageSeq,_that.stageEnteredAt,_that.releasedToPatient,_that.discussedAt,_that.releasedAt,_that.cancelReason,_that.createdAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'orderNumber')  String orderNumber, @JsonKey(name: 'appointmentUid')  String appointmentUid, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'doctorUid')  String doctorUid, @JsonKey(name: 'doctorName')  String doctorName, @JsonKey(name: 'doctorFacilityName')  String doctorFacilityName, @JsonKey(name: 'patientId')  String patientId, @JsonKey(name: 'patientUid')  String patientUid, @JsonKey(name: 'patientName')  String patientName, @JsonKey(name: 'patientSex')  String patientSex, @JsonKey(name: 'patientAgeYears')  int patientAgeYears, @JsonKey(name: 'requestedPathologistUid')  String requestedPathologistUid, @JsonKey(name: 'requestedPathologistName')  String requestedPathologistName, @JsonKey(name: 'pathologistRequestedAt')  String pathologistRequestedAt, @JsonKey(name: 'pathologistRequestExpiresAt')  String pathologistRequestExpiresAt, @JsonKey(name: 'declinedPathologistUids')  List<String> declinedPathologistUids, @JsonKey(name: 'pathologistUid')  String pathologistUid, @JsonKey(name: 'pathologistName')  String pathologistName, @JsonKey(name: 'pathologistAcceptedAt')  String pathologistAcceptedAt, @JsonKey(name: 'viewerUids')  List<String> viewerUids, @JsonKey(name: 'participantUids')  List<String> participantUids, @JsonKey(name: 'tests')  List<OrderedTestModel> tests, @JsonKey(name: 'totalPriceKes')  int totalPriceKes, @JsonKey(name: 'isPriceEstimate')  bool isPriceEstimate, @JsonKey(name: 'priority')  String priority, @JsonKey(name: 'clinicalNotes')  String clinicalNotes, @JsonKey(name: 'sampleNotes')  String sampleNotes, @JsonKey(name: 'notesLanguage')  String notesLanguage, @JsonKey(name: 'sampleCollectedAt')  String sampleCollectedAt, @JsonKey(name: 'sampleReceivedAt')  String sampleReceivedAt, @JsonKey(name: 'labAccessionNo')  String labAccessionNo, @JsonKey(name: 'requiresSlides')  bool requiresSlides, @JsonKey(name: 'slideUploadUids')  List<String> slideUploadUids, @JsonKey(name: 'slideImages')  List<SlideImageModel> slideImages, @JsonKey(name: 'prereadRunUid')  String prereadRunUid, @JsonKey(name: 'currentReportUid')  String currentReportUid, @JsonKey(name: 'resultState')  String resultState, @JsonKey(name: 'discussionAppointmentUid')  String discussionAppointmentUid, @JsonKey(name: 'currentLocation')  String currentLocation, @JsonKey(name: 'currentStage')  String currentStage, @JsonKey(name: 'currentStep')  String currentStep, @JsonKey(name: 'stageSeq')  int stageSeq, @JsonKey(name: 'stageEnteredAt')  String stageEnteredAt, @JsonKey(name: 'releasedToPatient')  bool releasedToPatient, @JsonKey(name: 'discussedAt')  String discussedAt, @JsonKey(name: 'releasedAt')  String releasedAt, @JsonKey(name: 'cancelReason')  String cancelReason, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,) {final _that = this;
switch (_that) {
case _CaseModel() when $default != null:
return $default(_that.uid,_that.orderNumber,_that.appointmentUid,_that.createdByUid,_that.doctorUid,_that.doctorName,_that.doctorFacilityName,_that.patientId,_that.patientUid,_that.patientName,_that.patientSex,_that.patientAgeYears,_that.requestedPathologistUid,_that.requestedPathologistName,_that.pathologistRequestedAt,_that.pathologistRequestExpiresAt,_that.declinedPathologistUids,_that.pathologistUid,_that.pathologistName,_that.pathologistAcceptedAt,_that.viewerUids,_that.participantUids,_that.tests,_that.totalPriceKes,_that.isPriceEstimate,_that.priority,_that.clinicalNotes,_that.sampleNotes,_that.notesLanguage,_that.sampleCollectedAt,_that.sampleReceivedAt,_that.labAccessionNo,_that.requiresSlides,_that.slideUploadUids,_that.slideImages,_that.prereadRunUid,_that.currentReportUid,_that.resultState,_that.discussionAppointmentUid,_that.currentLocation,_that.currentStage,_that.currentStep,_that.stageSeq,_that.stageEnteredAt,_that.releasedToPatient,_that.discussedAt,_that.releasedAt,_that.cancelReason,_that.createdAt,_that.lastUpdatedAt,_that.synced);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _CaseModel extends CaseModel {
  const _CaseModel({@JsonKey(name: 'uid') this.uid = '', @JsonKey(name: 'orderNumber') this.orderNumber = '', @JsonKey(name: 'appointmentUid') this.appointmentUid = '', @JsonKey(name: 'createdByUid') this.createdByUid = '', @JsonKey(name: 'doctorUid') this.doctorUid = '', @JsonKey(name: 'doctorName') this.doctorName = '', @JsonKey(name: 'doctorFacilityName') this.doctorFacilityName = '', @JsonKey(name: 'patientId') this.patientId = '', @JsonKey(name: 'patientUid') this.patientUid = '', @JsonKey(name: 'patientName') this.patientName = '', @JsonKey(name: 'patientSex') this.patientSex = '', @JsonKey(name: 'patientAgeYears') this.patientAgeYears = 0, @JsonKey(name: 'requestedPathologistUid') this.requestedPathologistUid = '', @JsonKey(name: 'requestedPathologistName') this.requestedPathologistName = '', @JsonKey(name: 'pathologistRequestedAt') this.pathologistRequestedAt = '', @JsonKey(name: 'pathologistRequestExpiresAt') this.pathologistRequestExpiresAt = '', @JsonKey(name: 'declinedPathologistUids') final  List<String> declinedPathologistUids = const <String>[], @JsonKey(name: 'pathologistUid') this.pathologistUid = '', @JsonKey(name: 'pathologistName') this.pathologistName = '', @JsonKey(name: 'pathologistAcceptedAt') this.pathologistAcceptedAt = '', @JsonKey(name: 'viewerUids') final  List<String> viewerUids = const <String>[], @JsonKey(name: 'participantUids') final  List<String> participantUids = const <String>[], @JsonKey(name: 'tests') final  List<OrderedTestModel> tests = const <OrderedTestModel>[], @JsonKey(name: 'totalPriceKes') this.totalPriceKes = 0, @JsonKey(name: 'isPriceEstimate') this.isPriceEstimate = false, @JsonKey(name: 'priority') this.priority = 'Routine', @JsonKey(name: 'clinicalNotes') this.clinicalNotes = '', @JsonKey(name: 'sampleNotes') this.sampleNotes = '', @JsonKey(name: 'notesLanguage') this.notesLanguage = '', @JsonKey(name: 'sampleCollectedAt') this.sampleCollectedAt = '', @JsonKey(name: 'sampleReceivedAt') this.sampleReceivedAt = '', @JsonKey(name: 'labAccessionNo') this.labAccessionNo = '', @JsonKey(name: 'requiresSlides') this.requiresSlides = false, @JsonKey(name: 'slideUploadUids') final  List<String> slideUploadUids = const <String>[], @JsonKey(name: 'slideImages') final  List<SlideImageModel> slideImages = const <SlideImageModel>[], @JsonKey(name: 'prereadRunUid') this.prereadRunUid = '', @JsonKey(name: 'currentReportUid') this.currentReportUid = '', @JsonKey(name: 'resultState') this.resultState = 'Pending', @JsonKey(name: 'discussionAppointmentUid') this.discussionAppointmentUid = '', @JsonKey(name: 'currentLocation') this.currentLocation = 'Doctor', @JsonKey(name: 'currentStage') this.currentStage = 'OrderCreated', @JsonKey(name: 'currentStep') this.currentStep = '', @JsonKey(name: 'stageSeq') this.stageSeq = 0, @JsonKey(name: 'stageEnteredAt') this.stageEnteredAt = '', @JsonKey(name: 'releasedToPatient') this.releasedToPatient = false, @JsonKey(name: 'discussedAt') this.discussedAt = '', @JsonKey(name: 'releasedAt') this.releasedAt = '', @JsonKey(name: 'cancelReason') this.cancelReason = '', @JsonKey(name: 'createdAt') this.createdAt = '', @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = '', @JsonKey(includeFromJson: false, includeToJson: false) this.synced = true}): _declinedPathologistUids = declinedPathologistUids,_viewerUids = viewerUids,_participantUids = participantUids,_tests = tests,_slideUploadUids = slideUploadUids,_slideImages = slideImages,super._();
  factory _CaseModel.fromJson(Map<String, dynamic> json) => _$CaseModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'orderNumber') final  String orderNumber;
@override@JsonKey(name: 'appointmentUid') final  String appointmentUid;
@override@JsonKey(name: 'createdByUid') final  String createdByUid;
@override@JsonKey(name: 'doctorUid') final  String doctorUid;
@override@JsonKey(name: 'doctorName') final  String doctorName;
@override@JsonKey(name: 'doctorFacilityName') final  String doctorFacilityName;
@override@JsonKey(name: 'patientId') final  String patientId;
@override@JsonKey(name: 'patientUid') final  String patientUid;
@override@JsonKey(name: 'patientName') final  String patientName;
@override@JsonKey(name: 'patientSex') final  String patientSex;
@override@JsonKey(name: 'patientAgeYears') final  int patientAgeYears;
@override@JsonKey(name: 'requestedPathologistUid') final  String requestedPathologistUid;
@override@JsonKey(name: 'requestedPathologistName') final  String requestedPathologistName;
@override@JsonKey(name: 'pathologistRequestedAt') final  String pathologistRequestedAt;
@override@JsonKey(name: 'pathologistRequestExpiresAt') final  String pathologistRequestExpiresAt;
 final  List<String> _declinedPathologistUids;
@override@JsonKey(name: 'declinedPathologistUids') List<String> get declinedPathologistUids {
  if (_declinedPathologistUids is EqualUnmodifiableListView) return _declinedPathologistUids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_declinedPathologistUids);
}

@override@JsonKey(name: 'pathologistUid') final  String pathologistUid;
@override@JsonKey(name: 'pathologistName') final  String pathologistName;
@override@JsonKey(name: 'pathologistAcceptedAt') final  String pathologistAcceptedAt;
 final  List<String> _viewerUids;
@override@JsonKey(name: 'viewerUids') List<String> get viewerUids {
  if (_viewerUids is EqualUnmodifiableListView) return _viewerUids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_viewerUids);
}

 final  List<String> _participantUids;
@override@JsonKey(name: 'participantUids') List<String> get participantUids {
  if (_participantUids is EqualUnmodifiableListView) return _participantUids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantUids);
}

 final  List<OrderedTestModel> _tests;
@override@JsonKey(name: 'tests') List<OrderedTestModel> get tests {
  if (_tests is EqualUnmodifiableListView) return _tests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tests);
}

@override@JsonKey(name: 'totalPriceKes') final  int totalPriceKes;
@override@JsonKey(name: 'isPriceEstimate') final  bool isPriceEstimate;
@override@JsonKey(name: 'priority') final  String priority;
@override@JsonKey(name: 'clinicalNotes') final  String clinicalNotes;
@override@JsonKey(name: 'sampleNotes') final  String sampleNotes;
@override@JsonKey(name: 'notesLanguage') final  String notesLanguage;
@override@JsonKey(name: 'sampleCollectedAt') final  String sampleCollectedAt;
@override@JsonKey(name: 'sampleReceivedAt') final  String sampleReceivedAt;
@override@JsonKey(name: 'labAccessionNo') final  String labAccessionNo;
@override@JsonKey(name: 'requiresSlides') final  bool requiresSlides;
 final  List<String> _slideUploadUids;
@override@JsonKey(name: 'slideUploadUids') List<String> get slideUploadUids {
  if (_slideUploadUids is EqualUnmodifiableListView) return _slideUploadUids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_slideUploadUids);
}

 final  List<SlideImageModel> _slideImages;
@override@JsonKey(name: 'slideImages') List<SlideImageModel> get slideImages {
  if (_slideImages is EqualUnmodifiableListView) return _slideImages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_slideImages);
}

@override@JsonKey(name: 'prereadRunUid') final  String prereadRunUid;
@override@JsonKey(name: 'currentReportUid') final  String currentReportUid;
@override@JsonKey(name: 'resultState') final  String resultState;
@override@JsonKey(name: 'discussionAppointmentUid') final  String discussionAppointmentUid;
@override@JsonKey(name: 'currentLocation') final  String currentLocation;
@override@JsonKey(name: 'currentStage') final  String currentStage;
@override@JsonKey(name: 'currentStep') final  String currentStep;
@override@JsonKey(name: 'stageSeq') final  int stageSeq;
@override@JsonKey(name: 'stageEnteredAt') final  String stageEnteredAt;
@override@JsonKey(name: 'releasedToPatient') final  bool releasedToPatient;
@override@JsonKey(name: 'discussedAt') final  String discussedAt;
@override@JsonKey(name: 'releasedAt') final  String releasedAt;
@override@JsonKey(name: 'cancelReason') final  String cancelReason;
@override@JsonKey(name: 'createdAt') final  String createdAt;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool synced;

/// Create a copy of CaseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CaseModelCopyWith<_CaseModel> get copyWith => __$CaseModelCopyWithImpl<_CaseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CaseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CaseModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.appointmentUid, appointmentUid) || other.appointmentUid == appointmentUid)&&(identical(other.createdByUid, createdByUid) || other.createdByUid == createdByUid)&&(identical(other.doctorUid, doctorUid) || other.doctorUid == doctorUid)&&(identical(other.doctorName, doctorName) || other.doctorName == doctorName)&&(identical(other.doctorFacilityName, doctorFacilityName) || other.doctorFacilityName == doctorFacilityName)&&(identical(other.patientId, patientId) || other.patientId == patientId)&&(identical(other.patientUid, patientUid) || other.patientUid == patientUid)&&(identical(other.patientName, patientName) || other.patientName == patientName)&&(identical(other.patientSex, patientSex) || other.patientSex == patientSex)&&(identical(other.patientAgeYears, patientAgeYears) || other.patientAgeYears == patientAgeYears)&&(identical(other.requestedPathologistUid, requestedPathologistUid) || other.requestedPathologistUid == requestedPathologistUid)&&(identical(other.requestedPathologistName, requestedPathologistName) || other.requestedPathologistName == requestedPathologistName)&&(identical(other.pathologistRequestedAt, pathologistRequestedAt) || other.pathologistRequestedAt == pathologistRequestedAt)&&(identical(other.pathologistRequestExpiresAt, pathologistRequestExpiresAt) || other.pathologistRequestExpiresAt == pathologistRequestExpiresAt)&&const DeepCollectionEquality().equals(other._declinedPathologistUids, _declinedPathologistUids)&&(identical(other.pathologistUid, pathologistUid) || other.pathologistUid == pathologistUid)&&(identical(other.pathologistName, pathologistName) || other.pathologistName == pathologistName)&&(identical(other.pathologistAcceptedAt, pathologistAcceptedAt) || other.pathologistAcceptedAt == pathologistAcceptedAt)&&const DeepCollectionEquality().equals(other._viewerUids, _viewerUids)&&const DeepCollectionEquality().equals(other._participantUids, _participantUids)&&const DeepCollectionEquality().equals(other._tests, _tests)&&(identical(other.totalPriceKes, totalPriceKes) || other.totalPriceKes == totalPriceKes)&&(identical(other.isPriceEstimate, isPriceEstimate) || other.isPriceEstimate == isPriceEstimate)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.clinicalNotes, clinicalNotes) || other.clinicalNotes == clinicalNotes)&&(identical(other.sampleNotes, sampleNotes) || other.sampleNotes == sampleNotes)&&(identical(other.notesLanguage, notesLanguage) || other.notesLanguage == notesLanguage)&&(identical(other.sampleCollectedAt, sampleCollectedAt) || other.sampleCollectedAt == sampleCollectedAt)&&(identical(other.sampleReceivedAt, sampleReceivedAt) || other.sampleReceivedAt == sampleReceivedAt)&&(identical(other.labAccessionNo, labAccessionNo) || other.labAccessionNo == labAccessionNo)&&(identical(other.requiresSlides, requiresSlides) || other.requiresSlides == requiresSlides)&&const DeepCollectionEquality().equals(other._slideUploadUids, _slideUploadUids)&&const DeepCollectionEquality().equals(other._slideImages, _slideImages)&&(identical(other.prereadRunUid, prereadRunUid) || other.prereadRunUid == prereadRunUid)&&(identical(other.currentReportUid, currentReportUid) || other.currentReportUid == currentReportUid)&&(identical(other.resultState, resultState) || other.resultState == resultState)&&(identical(other.discussionAppointmentUid, discussionAppointmentUid) || other.discussionAppointmentUid == discussionAppointmentUid)&&(identical(other.currentLocation, currentLocation) || other.currentLocation == currentLocation)&&(identical(other.currentStage, currentStage) || other.currentStage == currentStage)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.stageSeq, stageSeq) || other.stageSeq == stageSeq)&&(identical(other.stageEnteredAt, stageEnteredAt) || other.stageEnteredAt == stageEnteredAt)&&(identical(other.releasedToPatient, releasedToPatient) || other.releasedToPatient == releasedToPatient)&&(identical(other.discussedAt, discussedAt) || other.discussedAt == discussedAt)&&(identical(other.releasedAt, releasedAt) || other.releasedAt == releasedAt)&&(identical(other.cancelReason, cancelReason) || other.cancelReason == cancelReason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,orderNumber,appointmentUid,createdByUid,doctorUid,doctorName,doctorFacilityName,patientId,patientUid,patientName,patientSex,patientAgeYears,requestedPathologistUid,requestedPathologistName,pathologistRequestedAt,pathologistRequestExpiresAt,const DeepCollectionEquality().hash(_declinedPathologistUids),pathologistUid,pathologistName,pathologistAcceptedAt,const DeepCollectionEquality().hash(_viewerUids),const DeepCollectionEquality().hash(_participantUids),const DeepCollectionEquality().hash(_tests),totalPriceKes,isPriceEstimate,priority,clinicalNotes,sampleNotes,notesLanguage,sampleCollectedAt,sampleReceivedAt,labAccessionNo,requiresSlides,const DeepCollectionEquality().hash(_slideUploadUids),const DeepCollectionEquality().hash(_slideImages),prereadRunUid,currentReportUid,resultState,discussionAppointmentUid,currentLocation,currentStage,currentStep,stageSeq,stageEnteredAt,releasedToPatient,discussedAt,releasedAt,cancelReason,createdAt,lastUpdatedAt,synced]);

@override
String toString() {
  return 'CaseModel(uid: $uid, orderNumber: $orderNumber, appointmentUid: $appointmentUid, createdByUid: $createdByUid, doctorUid: $doctorUid, doctorName: $doctorName, doctorFacilityName: $doctorFacilityName, patientId: $patientId, patientUid: $patientUid, patientName: $patientName, patientSex: $patientSex, patientAgeYears: $patientAgeYears, requestedPathologistUid: $requestedPathologistUid, requestedPathologistName: $requestedPathologistName, pathologistRequestedAt: $pathologistRequestedAt, pathologistRequestExpiresAt: $pathologistRequestExpiresAt, declinedPathologistUids: $declinedPathologistUids, pathologistUid: $pathologistUid, pathologistName: $pathologistName, pathologistAcceptedAt: $pathologistAcceptedAt, viewerUids: $viewerUids, participantUids: $participantUids, tests: $tests, totalPriceKes: $totalPriceKes, isPriceEstimate: $isPriceEstimate, priority: $priority, clinicalNotes: $clinicalNotes, sampleNotes: $sampleNotes, notesLanguage: $notesLanguage, sampleCollectedAt: $sampleCollectedAt, sampleReceivedAt: $sampleReceivedAt, labAccessionNo: $labAccessionNo, requiresSlides: $requiresSlides, slideUploadUids: $slideUploadUids, slideImages: $slideImages, prereadRunUid: $prereadRunUid, currentReportUid: $currentReportUid, resultState: $resultState, discussionAppointmentUid: $discussionAppointmentUid, currentLocation: $currentLocation, currentStage: $currentStage, currentStep: $currentStep, stageSeq: $stageSeq, stageEnteredAt: $stageEnteredAt, releasedToPatient: $releasedToPatient, discussedAt: $discussedAt, releasedAt: $releasedAt, cancelReason: $cancelReason, createdAt: $createdAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class _$CaseModelCopyWith<$Res> implements $CaseModelCopyWith<$Res> {
  factory _$CaseModelCopyWith(_CaseModel value, $Res Function(_CaseModel) _then) = __$CaseModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'orderNumber') String orderNumber,@JsonKey(name: 'appointmentUid') String appointmentUid,@JsonKey(name: 'createdByUid') String createdByUid,@JsonKey(name: 'doctorUid') String doctorUid,@JsonKey(name: 'doctorName') String doctorName,@JsonKey(name: 'doctorFacilityName') String doctorFacilityName,@JsonKey(name: 'patientId') String patientId,@JsonKey(name: 'patientUid') String patientUid,@JsonKey(name: 'patientName') String patientName,@JsonKey(name: 'patientSex') String patientSex,@JsonKey(name: 'patientAgeYears') int patientAgeYears,@JsonKey(name: 'requestedPathologistUid') String requestedPathologistUid,@JsonKey(name: 'requestedPathologistName') String requestedPathologistName,@JsonKey(name: 'pathologistRequestedAt') String pathologistRequestedAt,@JsonKey(name: 'pathologistRequestExpiresAt') String pathologistRequestExpiresAt,@JsonKey(name: 'declinedPathologistUids') List<String> declinedPathologistUids,@JsonKey(name: 'pathologistUid') String pathologistUid,@JsonKey(name: 'pathologistName') String pathologistName,@JsonKey(name: 'pathologistAcceptedAt') String pathologistAcceptedAt,@JsonKey(name: 'viewerUids') List<String> viewerUids,@JsonKey(name: 'participantUids') List<String> participantUids,@JsonKey(name: 'tests') List<OrderedTestModel> tests,@JsonKey(name: 'totalPriceKes') int totalPriceKes,@JsonKey(name: 'isPriceEstimate') bool isPriceEstimate,@JsonKey(name: 'priority') String priority,@JsonKey(name: 'clinicalNotes') String clinicalNotes,@JsonKey(name: 'sampleNotes') String sampleNotes,@JsonKey(name: 'notesLanguage') String notesLanguage,@JsonKey(name: 'sampleCollectedAt') String sampleCollectedAt,@JsonKey(name: 'sampleReceivedAt') String sampleReceivedAt,@JsonKey(name: 'labAccessionNo') String labAccessionNo,@JsonKey(name: 'requiresSlides') bool requiresSlides,@JsonKey(name: 'slideUploadUids') List<String> slideUploadUids,@JsonKey(name: 'slideImages') List<SlideImageModel> slideImages,@JsonKey(name: 'prereadRunUid') String prereadRunUid,@JsonKey(name: 'currentReportUid') String currentReportUid,@JsonKey(name: 'resultState') String resultState,@JsonKey(name: 'discussionAppointmentUid') String discussionAppointmentUid,@JsonKey(name: 'currentLocation') String currentLocation,@JsonKey(name: 'currentStage') String currentStage,@JsonKey(name: 'currentStep') String currentStep,@JsonKey(name: 'stageSeq') int stageSeq,@JsonKey(name: 'stageEnteredAt') String stageEnteredAt,@JsonKey(name: 'releasedToPatient') bool releasedToPatient,@JsonKey(name: 'discussedAt') String discussedAt,@JsonKey(name: 'releasedAt') String releasedAt,@JsonKey(name: 'cancelReason') String cancelReason,@JsonKey(name: 'createdAt') String createdAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class __$CaseModelCopyWithImpl<$Res>
    implements _$CaseModelCopyWith<$Res> {
  __$CaseModelCopyWithImpl(this._self, this._then);

  final _CaseModel _self;
  final $Res Function(_CaseModel) _then;

/// Create a copy of CaseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? orderNumber = null,Object? appointmentUid = null,Object? createdByUid = null,Object? doctorUid = null,Object? doctorName = null,Object? doctorFacilityName = null,Object? patientId = null,Object? patientUid = null,Object? patientName = null,Object? patientSex = null,Object? patientAgeYears = null,Object? requestedPathologistUid = null,Object? requestedPathologistName = null,Object? pathologistRequestedAt = null,Object? pathologistRequestExpiresAt = null,Object? declinedPathologistUids = null,Object? pathologistUid = null,Object? pathologistName = null,Object? pathologistAcceptedAt = null,Object? viewerUids = null,Object? participantUids = null,Object? tests = null,Object? totalPriceKes = null,Object? isPriceEstimate = null,Object? priority = null,Object? clinicalNotes = null,Object? sampleNotes = null,Object? notesLanguage = null,Object? sampleCollectedAt = null,Object? sampleReceivedAt = null,Object? labAccessionNo = null,Object? requiresSlides = null,Object? slideUploadUids = null,Object? slideImages = null,Object? prereadRunUid = null,Object? currentReportUid = null,Object? resultState = null,Object? discussionAppointmentUid = null,Object? currentLocation = null,Object? currentStage = null,Object? currentStep = null,Object? stageSeq = null,Object? stageEnteredAt = null,Object? releasedToPatient = null,Object? discussedAt = null,Object? releasedAt = null,Object? cancelReason = null,Object? createdAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_CaseModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,appointmentUid: null == appointmentUid ? _self.appointmentUid : appointmentUid // ignore: cast_nullable_to_non_nullable
as String,createdByUid: null == createdByUid ? _self.createdByUid : createdByUid // ignore: cast_nullable_to_non_nullable
as String,doctorUid: null == doctorUid ? _self.doctorUid : doctorUid // ignore: cast_nullable_to_non_nullable
as String,doctorName: null == doctorName ? _self.doctorName : doctorName // ignore: cast_nullable_to_non_nullable
as String,doctorFacilityName: null == doctorFacilityName ? _self.doctorFacilityName : doctorFacilityName // ignore: cast_nullable_to_non_nullable
as String,patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,patientUid: null == patientUid ? _self.patientUid : patientUid // ignore: cast_nullable_to_non_nullable
as String,patientName: null == patientName ? _self.patientName : patientName // ignore: cast_nullable_to_non_nullable
as String,patientSex: null == patientSex ? _self.patientSex : patientSex // ignore: cast_nullable_to_non_nullable
as String,patientAgeYears: null == patientAgeYears ? _self.patientAgeYears : patientAgeYears // ignore: cast_nullable_to_non_nullable
as int,requestedPathologistUid: null == requestedPathologistUid ? _self.requestedPathologistUid : requestedPathologistUid // ignore: cast_nullable_to_non_nullable
as String,requestedPathologistName: null == requestedPathologistName ? _self.requestedPathologistName : requestedPathologistName // ignore: cast_nullable_to_non_nullable
as String,pathologistRequestedAt: null == pathologistRequestedAt ? _self.pathologistRequestedAt : pathologistRequestedAt // ignore: cast_nullable_to_non_nullable
as String,pathologistRequestExpiresAt: null == pathologistRequestExpiresAt ? _self.pathologistRequestExpiresAt : pathologistRequestExpiresAt // ignore: cast_nullable_to_non_nullable
as String,declinedPathologistUids: null == declinedPathologistUids ? _self._declinedPathologistUids : declinedPathologistUids // ignore: cast_nullable_to_non_nullable
as List<String>,pathologistUid: null == pathologistUid ? _self.pathologistUid : pathologistUid // ignore: cast_nullable_to_non_nullable
as String,pathologistName: null == pathologistName ? _self.pathologistName : pathologistName // ignore: cast_nullable_to_non_nullable
as String,pathologistAcceptedAt: null == pathologistAcceptedAt ? _self.pathologistAcceptedAt : pathologistAcceptedAt // ignore: cast_nullable_to_non_nullable
as String,viewerUids: null == viewerUids ? _self._viewerUids : viewerUids // ignore: cast_nullable_to_non_nullable
as List<String>,participantUids: null == participantUids ? _self._participantUids : participantUids // ignore: cast_nullable_to_non_nullable
as List<String>,tests: null == tests ? _self._tests : tests // ignore: cast_nullable_to_non_nullable
as List<OrderedTestModel>,totalPriceKes: null == totalPriceKes ? _self.totalPriceKes : totalPriceKes // ignore: cast_nullable_to_non_nullable
as int,isPriceEstimate: null == isPriceEstimate ? _self.isPriceEstimate : isPriceEstimate // ignore: cast_nullable_to_non_nullable
as bool,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String,clinicalNotes: null == clinicalNotes ? _self.clinicalNotes : clinicalNotes // ignore: cast_nullable_to_non_nullable
as String,sampleNotes: null == sampleNotes ? _self.sampleNotes : sampleNotes // ignore: cast_nullable_to_non_nullable
as String,notesLanguage: null == notesLanguage ? _self.notesLanguage : notesLanguage // ignore: cast_nullable_to_non_nullable
as String,sampleCollectedAt: null == sampleCollectedAt ? _self.sampleCollectedAt : sampleCollectedAt // ignore: cast_nullable_to_non_nullable
as String,sampleReceivedAt: null == sampleReceivedAt ? _self.sampleReceivedAt : sampleReceivedAt // ignore: cast_nullable_to_non_nullable
as String,labAccessionNo: null == labAccessionNo ? _self.labAccessionNo : labAccessionNo // ignore: cast_nullable_to_non_nullable
as String,requiresSlides: null == requiresSlides ? _self.requiresSlides : requiresSlides // ignore: cast_nullable_to_non_nullable
as bool,slideUploadUids: null == slideUploadUids ? _self._slideUploadUids : slideUploadUids // ignore: cast_nullable_to_non_nullable
as List<String>,slideImages: null == slideImages ? _self._slideImages : slideImages // ignore: cast_nullable_to_non_nullable
as List<SlideImageModel>,prereadRunUid: null == prereadRunUid ? _self.prereadRunUid : prereadRunUid // ignore: cast_nullable_to_non_nullable
as String,currentReportUid: null == currentReportUid ? _self.currentReportUid : currentReportUid // ignore: cast_nullable_to_non_nullable
as String,resultState: null == resultState ? _self.resultState : resultState // ignore: cast_nullable_to_non_nullable
as String,discussionAppointmentUid: null == discussionAppointmentUid ? _self.discussionAppointmentUid : discussionAppointmentUid // ignore: cast_nullable_to_non_nullable
as String,currentLocation: null == currentLocation ? _self.currentLocation : currentLocation // ignore: cast_nullable_to_non_nullable
as String,currentStage: null == currentStage ? _self.currentStage : currentStage // ignore: cast_nullable_to_non_nullable
as String,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as String,stageSeq: null == stageSeq ? _self.stageSeq : stageSeq // ignore: cast_nullable_to_non_nullable
as int,stageEnteredAt: null == stageEnteredAt ? _self.stageEnteredAt : stageEnteredAt // ignore: cast_nullable_to_non_nullable
as String,releasedToPatient: null == releasedToPatient ? _self.releasedToPatient : releasedToPatient // ignore: cast_nullable_to_non_nullable
as bool,discussedAt: null == discussedAt ? _self.discussedAt : discussedAt // ignore: cast_nullable_to_non_nullable
as String,releasedAt: null == releasedAt ? _self.releasedAt : releasedAt // ignore: cast_nullable_to_non_nullable
as String,cancelReason: null == cancelReason ? _self.cancelReason : cancelReason // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
