// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alert_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AlertModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'signalUid') String get signalUid;@JsonKey(name: 'diseaseId') String get diseaseId;@JsonKey(name: 'countyId') int get countyId;@JsonKey(name: 'countyName') String get countyName;@JsonKey(name: 'epiWeek') String get epiWeek;@JsonKey(name: 'category') String get category;@JsonKey(name: 'rule') String get rule;@JsonKey(name: 'status') String get status;@JsonKey(name: 'draftRevision') int get draftRevision;@JsonKey(name: 'requestCount') int get requestCount;@JsonKey(name: 'evidenceRevision') int get evidenceRevision;@JsonKey(name: 'draftSource') String get draftSource;@JsonKey(name: 'machineText') Map<String, AlertTextModel> get machineText;@JsonKey(name: 'models') Map<String, String> get models;@JsonKey(name: 'failureReason') String get failureReason;@JsonKey(name: 'evidence') AlertEvidenceModel get evidence;@JsonKey(name: 'audience') String get audience;@JsonKey(name: 'decision') String get decision;@JsonKey(name: 'decidedByUid') String get decidedByUid;@JsonKey(name: 'decidedByName') String get decidedByName;@JsonKey(name: 'decidedAt') String get decidedAt;@JsonKey(name: 'rejectReason') String get rejectReason;@JsonKey(name: 'approvedText') Map<String, AlertTextModel> get approvedText;@JsonKey(name: 'approvedEvidence') AlertEvidenceModel get approvedEvidence;@JsonKey(name: 'acceptedUnchanged') bool get acceptedUnchanged;@JsonKey(name: 'editedKeys') List<String> get editedKeys;@JsonKey(name: 'editDistance') double get editDistance;@JsonKey(name: 'evidenceRetracted') bool get evidenceRetracted;@JsonKey(name: 'deliveredTo') String get deliveredTo;@JsonKey(name: 'deliveredAt') String get deliveredAt;@JsonKey(name: 'requestedAt') String get requestedAt;@JsonKey(name: 'draftedAt') String get draftedAt;@JsonKey(name: 'expiresAt') String get expiresAt;@JsonKey(name: 'reminderSentAt') String get reminderSentAt;@JsonKey(name: 'synthetic') bool get synthetic;@JsonKey(name: 'createdAt') String get createdAt;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;
/// Create a copy of AlertModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlertModelCopyWith<AlertModel> get copyWith => _$AlertModelCopyWithImpl<AlertModel>(this as AlertModel, _$identity);

  /// Serializes this AlertModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlertModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.signalUid, signalUid) || other.signalUid == signalUid)&&(identical(other.diseaseId, diseaseId) || other.diseaseId == diseaseId)&&(identical(other.countyId, countyId) || other.countyId == countyId)&&(identical(other.countyName, countyName) || other.countyName == countyName)&&(identical(other.epiWeek, epiWeek) || other.epiWeek == epiWeek)&&(identical(other.category, category) || other.category == category)&&(identical(other.rule, rule) || other.rule == rule)&&(identical(other.status, status) || other.status == status)&&(identical(other.draftRevision, draftRevision) || other.draftRevision == draftRevision)&&(identical(other.requestCount, requestCount) || other.requestCount == requestCount)&&(identical(other.evidenceRevision, evidenceRevision) || other.evidenceRevision == evidenceRevision)&&(identical(other.draftSource, draftSource) || other.draftSource == draftSource)&&const DeepCollectionEquality().equals(other.machineText, machineText)&&const DeepCollectionEquality().equals(other.models, models)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.evidence, evidence) || other.evidence == evidence)&&(identical(other.audience, audience) || other.audience == audience)&&(identical(other.decision, decision) || other.decision == decision)&&(identical(other.decidedByUid, decidedByUid) || other.decidedByUid == decidedByUid)&&(identical(other.decidedByName, decidedByName) || other.decidedByName == decidedByName)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.rejectReason, rejectReason) || other.rejectReason == rejectReason)&&const DeepCollectionEquality().equals(other.approvedText, approvedText)&&(identical(other.approvedEvidence, approvedEvidence) || other.approvedEvidence == approvedEvidence)&&(identical(other.acceptedUnchanged, acceptedUnchanged) || other.acceptedUnchanged == acceptedUnchanged)&&const DeepCollectionEquality().equals(other.editedKeys, editedKeys)&&(identical(other.editDistance, editDistance) || other.editDistance == editDistance)&&(identical(other.evidenceRetracted, evidenceRetracted) || other.evidenceRetracted == evidenceRetracted)&&(identical(other.deliveredTo, deliveredTo) || other.deliveredTo == deliveredTo)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.draftedAt, draftedAt) || other.draftedAt == draftedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.reminderSentAt, reminderSentAt) || other.reminderSentAt == reminderSentAt)&&(identical(other.synthetic, synthetic) || other.synthetic == synthetic)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,signalUid,diseaseId,countyId,countyName,epiWeek,category,rule,status,draftRevision,requestCount,evidenceRevision,draftSource,const DeepCollectionEquality().hash(machineText),const DeepCollectionEquality().hash(models),failureReason,evidence,audience,decision,decidedByUid,decidedByName,decidedAt,rejectReason,const DeepCollectionEquality().hash(approvedText),approvedEvidence,acceptedUnchanged,const DeepCollectionEquality().hash(editedKeys),editDistance,evidenceRetracted,deliveredTo,deliveredAt,requestedAt,draftedAt,expiresAt,reminderSentAt,synthetic,createdAt,lastUpdatedAt]);

@override
String toString() {
  return 'AlertModel(uid: $uid, signalUid: $signalUid, diseaseId: $diseaseId, countyId: $countyId, countyName: $countyName, epiWeek: $epiWeek, category: $category, rule: $rule, status: $status, draftRevision: $draftRevision, requestCount: $requestCount, evidenceRevision: $evidenceRevision, draftSource: $draftSource, machineText: $machineText, models: $models, failureReason: $failureReason, evidence: $evidence, audience: $audience, decision: $decision, decidedByUid: $decidedByUid, decidedByName: $decidedByName, decidedAt: $decidedAt, rejectReason: $rejectReason, approvedText: $approvedText, approvedEvidence: $approvedEvidence, acceptedUnchanged: $acceptedUnchanged, editedKeys: $editedKeys, editDistance: $editDistance, evidenceRetracted: $evidenceRetracted, deliveredTo: $deliveredTo, deliveredAt: $deliveredAt, requestedAt: $requestedAt, draftedAt: $draftedAt, expiresAt: $expiresAt, reminderSentAt: $reminderSentAt, synthetic: $synthetic, createdAt: $createdAt, lastUpdatedAt: $lastUpdatedAt)';
}


}

/// @nodoc
abstract mixin class $AlertModelCopyWith<$Res>  {
  factory $AlertModelCopyWith(AlertModel value, $Res Function(AlertModel) _then) = _$AlertModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'signalUid') String signalUid,@JsonKey(name: 'diseaseId') String diseaseId,@JsonKey(name: 'countyId') int countyId,@JsonKey(name: 'countyName') String countyName,@JsonKey(name: 'epiWeek') String epiWeek,@JsonKey(name: 'category') String category,@JsonKey(name: 'rule') String rule,@JsonKey(name: 'status') String status,@JsonKey(name: 'draftRevision') int draftRevision,@JsonKey(name: 'requestCount') int requestCount,@JsonKey(name: 'evidenceRevision') int evidenceRevision,@JsonKey(name: 'draftSource') String draftSource,@JsonKey(name: 'machineText') Map<String, AlertTextModel> machineText,@JsonKey(name: 'models') Map<String, String> models,@JsonKey(name: 'failureReason') String failureReason,@JsonKey(name: 'evidence') AlertEvidenceModel evidence,@JsonKey(name: 'audience') String audience,@JsonKey(name: 'decision') String decision,@JsonKey(name: 'decidedByUid') String decidedByUid,@JsonKey(name: 'decidedByName') String decidedByName,@JsonKey(name: 'decidedAt') String decidedAt,@JsonKey(name: 'rejectReason') String rejectReason,@JsonKey(name: 'approvedText') Map<String, AlertTextModel> approvedText,@JsonKey(name: 'approvedEvidence') AlertEvidenceModel approvedEvidence,@JsonKey(name: 'acceptedUnchanged') bool acceptedUnchanged,@JsonKey(name: 'editedKeys') List<String> editedKeys,@JsonKey(name: 'editDistance') double editDistance,@JsonKey(name: 'evidenceRetracted') bool evidenceRetracted,@JsonKey(name: 'deliveredTo') String deliveredTo,@JsonKey(name: 'deliveredAt') String deliveredAt,@JsonKey(name: 'requestedAt') String requestedAt,@JsonKey(name: 'draftedAt') String draftedAt,@JsonKey(name: 'expiresAt') String expiresAt,@JsonKey(name: 'reminderSentAt') String reminderSentAt,@JsonKey(name: 'synthetic') bool synthetic,@JsonKey(name: 'createdAt') String createdAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt
});


$AlertEvidenceModelCopyWith<$Res> get evidence;$AlertEvidenceModelCopyWith<$Res> get approvedEvidence;

}
/// @nodoc
class _$AlertModelCopyWithImpl<$Res>
    implements $AlertModelCopyWith<$Res> {
  _$AlertModelCopyWithImpl(this._self, this._then);

  final AlertModel _self;
  final $Res Function(AlertModel) _then;

/// Create a copy of AlertModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? signalUid = null,Object? diseaseId = null,Object? countyId = null,Object? countyName = null,Object? epiWeek = null,Object? category = null,Object? rule = null,Object? status = null,Object? draftRevision = null,Object? requestCount = null,Object? evidenceRevision = null,Object? draftSource = null,Object? machineText = null,Object? models = null,Object? failureReason = null,Object? evidence = null,Object? audience = null,Object? decision = null,Object? decidedByUid = null,Object? decidedByName = null,Object? decidedAt = null,Object? rejectReason = null,Object? approvedText = null,Object? approvedEvidence = null,Object? acceptedUnchanged = null,Object? editedKeys = null,Object? editDistance = null,Object? evidenceRetracted = null,Object? deliveredTo = null,Object? deliveredAt = null,Object? requestedAt = null,Object? draftedAt = null,Object? expiresAt = null,Object? reminderSentAt = null,Object? synthetic = null,Object? createdAt = null,Object? lastUpdatedAt = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,signalUid: null == signalUid ? _self.signalUid : signalUid // ignore: cast_nullable_to_non_nullable
as String,diseaseId: null == diseaseId ? _self.diseaseId : diseaseId // ignore: cast_nullable_to_non_nullable
as String,countyId: null == countyId ? _self.countyId : countyId // ignore: cast_nullable_to_non_nullable
as int,countyName: null == countyName ? _self.countyName : countyName // ignore: cast_nullable_to_non_nullable
as String,epiWeek: null == epiWeek ? _self.epiWeek : epiWeek // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,draftRevision: null == draftRevision ? _self.draftRevision : draftRevision // ignore: cast_nullable_to_non_nullable
as int,requestCount: null == requestCount ? _self.requestCount : requestCount // ignore: cast_nullable_to_non_nullable
as int,evidenceRevision: null == evidenceRevision ? _self.evidenceRevision : evidenceRevision // ignore: cast_nullable_to_non_nullable
as int,draftSource: null == draftSource ? _self.draftSource : draftSource // ignore: cast_nullable_to_non_nullable
as String,machineText: null == machineText ? _self.machineText : machineText // ignore: cast_nullable_to_non_nullable
as Map<String, AlertTextModel>,models: null == models ? _self.models : models // ignore: cast_nullable_to_non_nullable
as Map<String, String>,failureReason: null == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String,evidence: null == evidence ? _self.evidence : evidence // ignore: cast_nullable_to_non_nullable
as AlertEvidenceModel,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as String,decision: null == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as String,decidedByUid: null == decidedByUid ? _self.decidedByUid : decidedByUid // ignore: cast_nullable_to_non_nullable
as String,decidedByName: null == decidedByName ? _self.decidedByName : decidedByName // ignore: cast_nullable_to_non_nullable
as String,decidedAt: null == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as String,rejectReason: null == rejectReason ? _self.rejectReason : rejectReason // ignore: cast_nullable_to_non_nullable
as String,approvedText: null == approvedText ? _self.approvedText : approvedText // ignore: cast_nullable_to_non_nullable
as Map<String, AlertTextModel>,approvedEvidence: null == approvedEvidence ? _self.approvedEvidence : approvedEvidence // ignore: cast_nullable_to_non_nullable
as AlertEvidenceModel,acceptedUnchanged: null == acceptedUnchanged ? _self.acceptedUnchanged : acceptedUnchanged // ignore: cast_nullable_to_non_nullable
as bool,editedKeys: null == editedKeys ? _self.editedKeys : editedKeys // ignore: cast_nullable_to_non_nullable
as List<String>,editDistance: null == editDistance ? _self.editDistance : editDistance // ignore: cast_nullable_to_non_nullable
as double,evidenceRetracted: null == evidenceRetracted ? _self.evidenceRetracted : evidenceRetracted // ignore: cast_nullable_to_non_nullable
as bool,deliveredTo: null == deliveredTo ? _self.deliveredTo : deliveredTo // ignore: cast_nullable_to_non_nullable
as String,deliveredAt: null == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as String,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as String,draftedAt: null == draftedAt ? _self.draftedAt : draftedAt // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String,reminderSentAt: null == reminderSentAt ? _self.reminderSentAt : reminderSentAt // ignore: cast_nullable_to_non_nullable
as String,synthetic: null == synthetic ? _self.synthetic : synthetic // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of AlertModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlertEvidenceModelCopyWith<$Res> get evidence {
  
  return $AlertEvidenceModelCopyWith<$Res>(_self.evidence, (value) {
    return _then(_self.copyWith(evidence: value));
  });
}/// Create a copy of AlertModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlertEvidenceModelCopyWith<$Res> get approvedEvidence {
  
  return $AlertEvidenceModelCopyWith<$Res>(_self.approvedEvidence, (value) {
    return _then(_self.copyWith(approvedEvidence: value));
  });
}
}


/// Adds pattern-matching-related methods to [AlertModel].
extension AlertModelPatterns on AlertModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlertModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlertModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlertModel value)  $default,){
final _that = this;
switch (_that) {
case _AlertModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlertModel value)?  $default,){
final _that = this;
switch (_that) {
case _AlertModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'signalUid')  String signalUid, @JsonKey(name: 'diseaseId')  String diseaseId, @JsonKey(name: 'countyId')  int countyId, @JsonKey(name: 'countyName')  String countyName, @JsonKey(name: 'epiWeek')  String epiWeek, @JsonKey(name: 'category')  String category, @JsonKey(name: 'rule')  String rule, @JsonKey(name: 'status')  String status, @JsonKey(name: 'draftRevision')  int draftRevision, @JsonKey(name: 'requestCount')  int requestCount, @JsonKey(name: 'evidenceRevision')  int evidenceRevision, @JsonKey(name: 'draftSource')  String draftSource, @JsonKey(name: 'machineText')  Map<String, AlertTextModel> machineText, @JsonKey(name: 'models')  Map<String, String> models, @JsonKey(name: 'failureReason')  String failureReason, @JsonKey(name: 'evidence')  AlertEvidenceModel evidence, @JsonKey(name: 'audience')  String audience, @JsonKey(name: 'decision')  String decision, @JsonKey(name: 'decidedByUid')  String decidedByUid, @JsonKey(name: 'decidedByName')  String decidedByName, @JsonKey(name: 'decidedAt')  String decidedAt, @JsonKey(name: 'rejectReason')  String rejectReason, @JsonKey(name: 'approvedText')  Map<String, AlertTextModel> approvedText, @JsonKey(name: 'approvedEvidence')  AlertEvidenceModel approvedEvidence, @JsonKey(name: 'acceptedUnchanged')  bool acceptedUnchanged, @JsonKey(name: 'editedKeys')  List<String> editedKeys, @JsonKey(name: 'editDistance')  double editDistance, @JsonKey(name: 'evidenceRetracted')  bool evidenceRetracted, @JsonKey(name: 'deliveredTo')  String deliveredTo, @JsonKey(name: 'deliveredAt')  String deliveredAt, @JsonKey(name: 'requestedAt')  String requestedAt, @JsonKey(name: 'draftedAt')  String draftedAt, @JsonKey(name: 'expiresAt')  String expiresAt, @JsonKey(name: 'reminderSentAt')  String reminderSentAt, @JsonKey(name: 'synthetic')  bool synthetic, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlertModel() when $default != null:
return $default(_that.uid,_that.signalUid,_that.diseaseId,_that.countyId,_that.countyName,_that.epiWeek,_that.category,_that.rule,_that.status,_that.draftRevision,_that.requestCount,_that.evidenceRevision,_that.draftSource,_that.machineText,_that.models,_that.failureReason,_that.evidence,_that.audience,_that.decision,_that.decidedByUid,_that.decidedByName,_that.decidedAt,_that.rejectReason,_that.approvedText,_that.approvedEvidence,_that.acceptedUnchanged,_that.editedKeys,_that.editDistance,_that.evidenceRetracted,_that.deliveredTo,_that.deliveredAt,_that.requestedAt,_that.draftedAt,_that.expiresAt,_that.reminderSentAt,_that.synthetic,_that.createdAt,_that.lastUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'signalUid')  String signalUid, @JsonKey(name: 'diseaseId')  String diseaseId, @JsonKey(name: 'countyId')  int countyId, @JsonKey(name: 'countyName')  String countyName, @JsonKey(name: 'epiWeek')  String epiWeek, @JsonKey(name: 'category')  String category, @JsonKey(name: 'rule')  String rule, @JsonKey(name: 'status')  String status, @JsonKey(name: 'draftRevision')  int draftRevision, @JsonKey(name: 'requestCount')  int requestCount, @JsonKey(name: 'evidenceRevision')  int evidenceRevision, @JsonKey(name: 'draftSource')  String draftSource, @JsonKey(name: 'machineText')  Map<String, AlertTextModel> machineText, @JsonKey(name: 'models')  Map<String, String> models, @JsonKey(name: 'failureReason')  String failureReason, @JsonKey(name: 'evidence')  AlertEvidenceModel evidence, @JsonKey(name: 'audience')  String audience, @JsonKey(name: 'decision')  String decision, @JsonKey(name: 'decidedByUid')  String decidedByUid, @JsonKey(name: 'decidedByName')  String decidedByName, @JsonKey(name: 'decidedAt')  String decidedAt, @JsonKey(name: 'rejectReason')  String rejectReason, @JsonKey(name: 'approvedText')  Map<String, AlertTextModel> approvedText, @JsonKey(name: 'approvedEvidence')  AlertEvidenceModel approvedEvidence, @JsonKey(name: 'acceptedUnchanged')  bool acceptedUnchanged, @JsonKey(name: 'editedKeys')  List<String> editedKeys, @JsonKey(name: 'editDistance')  double editDistance, @JsonKey(name: 'evidenceRetracted')  bool evidenceRetracted, @JsonKey(name: 'deliveredTo')  String deliveredTo, @JsonKey(name: 'deliveredAt')  String deliveredAt, @JsonKey(name: 'requestedAt')  String requestedAt, @JsonKey(name: 'draftedAt')  String draftedAt, @JsonKey(name: 'expiresAt')  String expiresAt, @JsonKey(name: 'reminderSentAt')  String reminderSentAt, @JsonKey(name: 'synthetic')  bool synthetic, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _AlertModel():
return $default(_that.uid,_that.signalUid,_that.diseaseId,_that.countyId,_that.countyName,_that.epiWeek,_that.category,_that.rule,_that.status,_that.draftRevision,_that.requestCount,_that.evidenceRevision,_that.draftSource,_that.machineText,_that.models,_that.failureReason,_that.evidence,_that.audience,_that.decision,_that.decidedByUid,_that.decidedByName,_that.decidedAt,_that.rejectReason,_that.approvedText,_that.approvedEvidence,_that.acceptedUnchanged,_that.editedKeys,_that.editDistance,_that.evidenceRetracted,_that.deliveredTo,_that.deliveredAt,_that.requestedAt,_that.draftedAt,_that.expiresAt,_that.reminderSentAt,_that.synthetic,_that.createdAt,_that.lastUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'signalUid')  String signalUid, @JsonKey(name: 'diseaseId')  String diseaseId, @JsonKey(name: 'countyId')  int countyId, @JsonKey(name: 'countyName')  String countyName, @JsonKey(name: 'epiWeek')  String epiWeek, @JsonKey(name: 'category')  String category, @JsonKey(name: 'rule')  String rule, @JsonKey(name: 'status')  String status, @JsonKey(name: 'draftRevision')  int draftRevision, @JsonKey(name: 'requestCount')  int requestCount, @JsonKey(name: 'evidenceRevision')  int evidenceRevision, @JsonKey(name: 'draftSource')  String draftSource, @JsonKey(name: 'machineText')  Map<String, AlertTextModel> machineText, @JsonKey(name: 'models')  Map<String, String> models, @JsonKey(name: 'failureReason')  String failureReason, @JsonKey(name: 'evidence')  AlertEvidenceModel evidence, @JsonKey(name: 'audience')  String audience, @JsonKey(name: 'decision')  String decision, @JsonKey(name: 'decidedByUid')  String decidedByUid, @JsonKey(name: 'decidedByName')  String decidedByName, @JsonKey(name: 'decidedAt')  String decidedAt, @JsonKey(name: 'rejectReason')  String rejectReason, @JsonKey(name: 'approvedText')  Map<String, AlertTextModel> approvedText, @JsonKey(name: 'approvedEvidence')  AlertEvidenceModel approvedEvidence, @JsonKey(name: 'acceptedUnchanged')  bool acceptedUnchanged, @JsonKey(name: 'editedKeys')  List<String> editedKeys, @JsonKey(name: 'editDistance')  double editDistance, @JsonKey(name: 'evidenceRetracted')  bool evidenceRetracted, @JsonKey(name: 'deliveredTo')  String deliveredTo, @JsonKey(name: 'deliveredAt')  String deliveredAt, @JsonKey(name: 'requestedAt')  String requestedAt, @JsonKey(name: 'draftedAt')  String draftedAt, @JsonKey(name: 'expiresAt')  String expiresAt, @JsonKey(name: 'reminderSentAt')  String reminderSentAt, @JsonKey(name: 'synthetic')  bool synthetic, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AlertModel() when $default != null:
return $default(_that.uid,_that.signalUid,_that.diseaseId,_that.countyId,_that.countyName,_that.epiWeek,_that.category,_that.rule,_that.status,_that.draftRevision,_that.requestCount,_that.evidenceRevision,_that.draftSource,_that.machineText,_that.models,_that.failureReason,_that.evidence,_that.audience,_that.decision,_that.decidedByUid,_that.decidedByName,_that.decidedAt,_that.rejectReason,_that.approvedText,_that.approvedEvidence,_that.acceptedUnchanged,_that.editedKeys,_that.editDistance,_that.evidenceRetracted,_that.deliveredTo,_that.deliveredAt,_that.requestedAt,_that.draftedAt,_that.expiresAt,_that.reminderSentAt,_that.synthetic,_that.createdAt,_that.lastUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _AlertModel extends AlertModel {
  const _AlertModel({@JsonKey(name: 'uid') this.uid = '', @JsonKey(name: 'signalUid') this.signalUid = '', @JsonKey(name: 'diseaseId') this.diseaseId = '', @JsonKey(name: 'countyId') this.countyId = 0, @JsonKey(name: 'countyName') this.countyName = '', @JsonKey(name: 'epiWeek') this.epiWeek = '', @JsonKey(name: 'category') this.category = '', @JsonKey(name: 'rule') this.rule = '', @JsonKey(name: 'status') this.status = 'Drafting', @JsonKey(name: 'draftRevision') this.draftRevision = 0, @JsonKey(name: 'requestCount') this.requestCount = 0, @JsonKey(name: 'evidenceRevision') this.evidenceRevision = 0, @JsonKey(name: 'draftSource') this.draftSource = 'Template', @JsonKey(name: 'machineText') final  Map<String, AlertTextModel> machineText = const <String, AlertTextModel>{}, @JsonKey(name: 'models') final  Map<String, String> models = const <String, String>{}, @JsonKey(name: 'failureReason') this.failureReason = '', @JsonKey(name: 'evidence') this.evidence = const AlertEvidenceModel(), @JsonKey(name: 'audience') this.audience = 'CliniciansThenPatients', @JsonKey(name: 'decision') this.decision = '', @JsonKey(name: 'decidedByUid') this.decidedByUid = '', @JsonKey(name: 'decidedByName') this.decidedByName = '', @JsonKey(name: 'decidedAt') this.decidedAt = '', @JsonKey(name: 'rejectReason') this.rejectReason = '', @JsonKey(name: 'approvedText') final  Map<String, AlertTextModel> approvedText = const <String, AlertTextModel>{}, @JsonKey(name: 'approvedEvidence') this.approvedEvidence = const AlertEvidenceModel(), @JsonKey(name: 'acceptedUnchanged') this.acceptedUnchanged = false, @JsonKey(name: 'editedKeys') final  List<String> editedKeys = const <String>[], @JsonKey(name: 'editDistance') this.editDistance = 0, @JsonKey(name: 'evidenceRetracted') this.evidenceRetracted = false, @JsonKey(name: 'deliveredTo') this.deliveredTo = '', @JsonKey(name: 'deliveredAt') this.deliveredAt = '', @JsonKey(name: 'requestedAt') this.requestedAt = '', @JsonKey(name: 'draftedAt') this.draftedAt = '', @JsonKey(name: 'expiresAt') this.expiresAt = '', @JsonKey(name: 'reminderSentAt') this.reminderSentAt = '', @JsonKey(name: 'synthetic') this.synthetic = false, @JsonKey(name: 'createdAt') this.createdAt = '', @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = ''}): _machineText = machineText,_models = models,_approvedText = approvedText,_editedKeys = editedKeys,super._();
  factory _AlertModel.fromJson(Map<String, dynamic> json) => _$AlertModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'signalUid') final  String signalUid;
@override@JsonKey(name: 'diseaseId') final  String diseaseId;
@override@JsonKey(name: 'countyId') final  int countyId;
@override@JsonKey(name: 'countyName') final  String countyName;
@override@JsonKey(name: 'epiWeek') final  String epiWeek;
@override@JsonKey(name: 'category') final  String category;
@override@JsonKey(name: 'rule') final  String rule;
@override@JsonKey(name: 'status') final  String status;
@override@JsonKey(name: 'draftRevision') final  int draftRevision;
@override@JsonKey(name: 'requestCount') final  int requestCount;
@override@JsonKey(name: 'evidenceRevision') final  int evidenceRevision;
@override@JsonKey(name: 'draftSource') final  String draftSource;
 final  Map<String, AlertTextModel> _machineText;
@override@JsonKey(name: 'machineText') Map<String, AlertTextModel> get machineText {
  if (_machineText is EqualUnmodifiableMapView) return _machineText;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_machineText);
}

 final  Map<String, String> _models;
@override@JsonKey(name: 'models') Map<String, String> get models {
  if (_models is EqualUnmodifiableMapView) return _models;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_models);
}

@override@JsonKey(name: 'failureReason') final  String failureReason;
@override@JsonKey(name: 'evidence') final  AlertEvidenceModel evidence;
@override@JsonKey(name: 'audience') final  String audience;
@override@JsonKey(name: 'decision') final  String decision;
@override@JsonKey(name: 'decidedByUid') final  String decidedByUid;
@override@JsonKey(name: 'decidedByName') final  String decidedByName;
@override@JsonKey(name: 'decidedAt') final  String decidedAt;
@override@JsonKey(name: 'rejectReason') final  String rejectReason;
 final  Map<String, AlertTextModel> _approvedText;
@override@JsonKey(name: 'approvedText') Map<String, AlertTextModel> get approvedText {
  if (_approvedText is EqualUnmodifiableMapView) return _approvedText;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_approvedText);
}

@override@JsonKey(name: 'approvedEvidence') final  AlertEvidenceModel approvedEvidence;
@override@JsonKey(name: 'acceptedUnchanged') final  bool acceptedUnchanged;
 final  List<String> _editedKeys;
@override@JsonKey(name: 'editedKeys') List<String> get editedKeys {
  if (_editedKeys is EqualUnmodifiableListView) return _editedKeys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_editedKeys);
}

@override@JsonKey(name: 'editDistance') final  double editDistance;
@override@JsonKey(name: 'evidenceRetracted') final  bool evidenceRetracted;
@override@JsonKey(name: 'deliveredTo') final  String deliveredTo;
@override@JsonKey(name: 'deliveredAt') final  String deliveredAt;
@override@JsonKey(name: 'requestedAt') final  String requestedAt;
@override@JsonKey(name: 'draftedAt') final  String draftedAt;
@override@JsonKey(name: 'expiresAt') final  String expiresAt;
@override@JsonKey(name: 'reminderSentAt') final  String reminderSentAt;
@override@JsonKey(name: 'synthetic') final  bool synthetic;
@override@JsonKey(name: 'createdAt') final  String createdAt;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;

/// Create a copy of AlertModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlertModelCopyWith<_AlertModel> get copyWith => __$AlertModelCopyWithImpl<_AlertModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AlertModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlertModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.signalUid, signalUid) || other.signalUid == signalUid)&&(identical(other.diseaseId, diseaseId) || other.diseaseId == diseaseId)&&(identical(other.countyId, countyId) || other.countyId == countyId)&&(identical(other.countyName, countyName) || other.countyName == countyName)&&(identical(other.epiWeek, epiWeek) || other.epiWeek == epiWeek)&&(identical(other.category, category) || other.category == category)&&(identical(other.rule, rule) || other.rule == rule)&&(identical(other.status, status) || other.status == status)&&(identical(other.draftRevision, draftRevision) || other.draftRevision == draftRevision)&&(identical(other.requestCount, requestCount) || other.requestCount == requestCount)&&(identical(other.evidenceRevision, evidenceRevision) || other.evidenceRevision == evidenceRevision)&&(identical(other.draftSource, draftSource) || other.draftSource == draftSource)&&const DeepCollectionEquality().equals(other._machineText, _machineText)&&const DeepCollectionEquality().equals(other._models, _models)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.evidence, evidence) || other.evidence == evidence)&&(identical(other.audience, audience) || other.audience == audience)&&(identical(other.decision, decision) || other.decision == decision)&&(identical(other.decidedByUid, decidedByUid) || other.decidedByUid == decidedByUid)&&(identical(other.decidedByName, decidedByName) || other.decidedByName == decidedByName)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.rejectReason, rejectReason) || other.rejectReason == rejectReason)&&const DeepCollectionEquality().equals(other._approvedText, _approvedText)&&(identical(other.approvedEvidence, approvedEvidence) || other.approvedEvidence == approvedEvidence)&&(identical(other.acceptedUnchanged, acceptedUnchanged) || other.acceptedUnchanged == acceptedUnchanged)&&const DeepCollectionEquality().equals(other._editedKeys, _editedKeys)&&(identical(other.editDistance, editDistance) || other.editDistance == editDistance)&&(identical(other.evidenceRetracted, evidenceRetracted) || other.evidenceRetracted == evidenceRetracted)&&(identical(other.deliveredTo, deliveredTo) || other.deliveredTo == deliveredTo)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.draftedAt, draftedAt) || other.draftedAt == draftedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.reminderSentAt, reminderSentAt) || other.reminderSentAt == reminderSentAt)&&(identical(other.synthetic, synthetic) || other.synthetic == synthetic)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,signalUid,diseaseId,countyId,countyName,epiWeek,category,rule,status,draftRevision,requestCount,evidenceRevision,draftSource,const DeepCollectionEquality().hash(_machineText),const DeepCollectionEquality().hash(_models),failureReason,evidence,audience,decision,decidedByUid,decidedByName,decidedAt,rejectReason,const DeepCollectionEquality().hash(_approvedText),approvedEvidence,acceptedUnchanged,const DeepCollectionEquality().hash(_editedKeys),editDistance,evidenceRetracted,deliveredTo,deliveredAt,requestedAt,draftedAt,expiresAt,reminderSentAt,synthetic,createdAt,lastUpdatedAt]);

@override
String toString() {
  return 'AlertModel(uid: $uid, signalUid: $signalUid, diseaseId: $diseaseId, countyId: $countyId, countyName: $countyName, epiWeek: $epiWeek, category: $category, rule: $rule, status: $status, draftRevision: $draftRevision, requestCount: $requestCount, evidenceRevision: $evidenceRevision, draftSource: $draftSource, machineText: $machineText, models: $models, failureReason: $failureReason, evidence: $evidence, audience: $audience, decision: $decision, decidedByUid: $decidedByUid, decidedByName: $decidedByName, decidedAt: $decidedAt, rejectReason: $rejectReason, approvedText: $approvedText, approvedEvidence: $approvedEvidence, acceptedUnchanged: $acceptedUnchanged, editedKeys: $editedKeys, editDistance: $editDistance, evidenceRetracted: $evidenceRetracted, deliveredTo: $deliveredTo, deliveredAt: $deliveredAt, requestedAt: $requestedAt, draftedAt: $draftedAt, expiresAt: $expiresAt, reminderSentAt: $reminderSentAt, synthetic: $synthetic, createdAt: $createdAt, lastUpdatedAt: $lastUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$AlertModelCopyWith<$Res> implements $AlertModelCopyWith<$Res> {
  factory _$AlertModelCopyWith(_AlertModel value, $Res Function(_AlertModel) _then) = __$AlertModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'signalUid') String signalUid,@JsonKey(name: 'diseaseId') String diseaseId,@JsonKey(name: 'countyId') int countyId,@JsonKey(name: 'countyName') String countyName,@JsonKey(name: 'epiWeek') String epiWeek,@JsonKey(name: 'category') String category,@JsonKey(name: 'rule') String rule,@JsonKey(name: 'status') String status,@JsonKey(name: 'draftRevision') int draftRevision,@JsonKey(name: 'requestCount') int requestCount,@JsonKey(name: 'evidenceRevision') int evidenceRevision,@JsonKey(name: 'draftSource') String draftSource,@JsonKey(name: 'machineText') Map<String, AlertTextModel> machineText,@JsonKey(name: 'models') Map<String, String> models,@JsonKey(name: 'failureReason') String failureReason,@JsonKey(name: 'evidence') AlertEvidenceModel evidence,@JsonKey(name: 'audience') String audience,@JsonKey(name: 'decision') String decision,@JsonKey(name: 'decidedByUid') String decidedByUid,@JsonKey(name: 'decidedByName') String decidedByName,@JsonKey(name: 'decidedAt') String decidedAt,@JsonKey(name: 'rejectReason') String rejectReason,@JsonKey(name: 'approvedText') Map<String, AlertTextModel> approvedText,@JsonKey(name: 'approvedEvidence') AlertEvidenceModel approvedEvidence,@JsonKey(name: 'acceptedUnchanged') bool acceptedUnchanged,@JsonKey(name: 'editedKeys') List<String> editedKeys,@JsonKey(name: 'editDistance') double editDistance,@JsonKey(name: 'evidenceRetracted') bool evidenceRetracted,@JsonKey(name: 'deliveredTo') String deliveredTo,@JsonKey(name: 'deliveredAt') String deliveredAt,@JsonKey(name: 'requestedAt') String requestedAt,@JsonKey(name: 'draftedAt') String draftedAt,@JsonKey(name: 'expiresAt') String expiresAt,@JsonKey(name: 'reminderSentAt') String reminderSentAt,@JsonKey(name: 'synthetic') bool synthetic,@JsonKey(name: 'createdAt') String createdAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt
});


@override $AlertEvidenceModelCopyWith<$Res> get evidence;@override $AlertEvidenceModelCopyWith<$Res> get approvedEvidence;

}
/// @nodoc
class __$AlertModelCopyWithImpl<$Res>
    implements _$AlertModelCopyWith<$Res> {
  __$AlertModelCopyWithImpl(this._self, this._then);

  final _AlertModel _self;
  final $Res Function(_AlertModel) _then;

/// Create a copy of AlertModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? signalUid = null,Object? diseaseId = null,Object? countyId = null,Object? countyName = null,Object? epiWeek = null,Object? category = null,Object? rule = null,Object? status = null,Object? draftRevision = null,Object? requestCount = null,Object? evidenceRevision = null,Object? draftSource = null,Object? machineText = null,Object? models = null,Object? failureReason = null,Object? evidence = null,Object? audience = null,Object? decision = null,Object? decidedByUid = null,Object? decidedByName = null,Object? decidedAt = null,Object? rejectReason = null,Object? approvedText = null,Object? approvedEvidence = null,Object? acceptedUnchanged = null,Object? editedKeys = null,Object? editDistance = null,Object? evidenceRetracted = null,Object? deliveredTo = null,Object? deliveredAt = null,Object? requestedAt = null,Object? draftedAt = null,Object? expiresAt = null,Object? reminderSentAt = null,Object? synthetic = null,Object? createdAt = null,Object? lastUpdatedAt = null,}) {
  return _then(_AlertModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,signalUid: null == signalUid ? _self.signalUid : signalUid // ignore: cast_nullable_to_non_nullable
as String,diseaseId: null == diseaseId ? _self.diseaseId : diseaseId // ignore: cast_nullable_to_non_nullable
as String,countyId: null == countyId ? _self.countyId : countyId // ignore: cast_nullable_to_non_nullable
as int,countyName: null == countyName ? _self.countyName : countyName // ignore: cast_nullable_to_non_nullable
as String,epiWeek: null == epiWeek ? _self.epiWeek : epiWeek // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,draftRevision: null == draftRevision ? _self.draftRevision : draftRevision // ignore: cast_nullable_to_non_nullable
as int,requestCount: null == requestCount ? _self.requestCount : requestCount // ignore: cast_nullable_to_non_nullable
as int,evidenceRevision: null == evidenceRevision ? _self.evidenceRevision : evidenceRevision // ignore: cast_nullable_to_non_nullable
as int,draftSource: null == draftSource ? _self.draftSource : draftSource // ignore: cast_nullable_to_non_nullable
as String,machineText: null == machineText ? _self._machineText : machineText // ignore: cast_nullable_to_non_nullable
as Map<String, AlertTextModel>,models: null == models ? _self._models : models // ignore: cast_nullable_to_non_nullable
as Map<String, String>,failureReason: null == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String,evidence: null == evidence ? _self.evidence : evidence // ignore: cast_nullable_to_non_nullable
as AlertEvidenceModel,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as String,decision: null == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as String,decidedByUid: null == decidedByUid ? _self.decidedByUid : decidedByUid // ignore: cast_nullable_to_non_nullable
as String,decidedByName: null == decidedByName ? _self.decidedByName : decidedByName // ignore: cast_nullable_to_non_nullable
as String,decidedAt: null == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as String,rejectReason: null == rejectReason ? _self.rejectReason : rejectReason // ignore: cast_nullable_to_non_nullable
as String,approvedText: null == approvedText ? _self._approvedText : approvedText // ignore: cast_nullable_to_non_nullable
as Map<String, AlertTextModel>,approvedEvidence: null == approvedEvidence ? _self.approvedEvidence : approvedEvidence // ignore: cast_nullable_to_non_nullable
as AlertEvidenceModel,acceptedUnchanged: null == acceptedUnchanged ? _self.acceptedUnchanged : acceptedUnchanged // ignore: cast_nullable_to_non_nullable
as bool,editedKeys: null == editedKeys ? _self._editedKeys : editedKeys // ignore: cast_nullable_to_non_nullable
as List<String>,editDistance: null == editDistance ? _self.editDistance : editDistance // ignore: cast_nullable_to_non_nullable
as double,evidenceRetracted: null == evidenceRetracted ? _self.evidenceRetracted : evidenceRetracted // ignore: cast_nullable_to_non_nullable
as bool,deliveredTo: null == deliveredTo ? _self.deliveredTo : deliveredTo // ignore: cast_nullable_to_non_nullable
as String,deliveredAt: null == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as String,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as String,draftedAt: null == draftedAt ? _self.draftedAt : draftedAt // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String,reminderSentAt: null == reminderSentAt ? _self.reminderSentAt : reminderSentAt // ignore: cast_nullable_to_non_nullable
as String,synthetic: null == synthetic ? _self.synthetic : synthetic // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of AlertModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlertEvidenceModelCopyWith<$Res> get evidence {
  
  return $AlertEvidenceModelCopyWith<$Res>(_self.evidence, (value) {
    return _then(_self.copyWith(evidence: value));
  });
}/// Create a copy of AlertModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlertEvidenceModelCopyWith<$Res> get approvedEvidence {
  
  return $AlertEvidenceModelCopyWith<$Res>(_self.approvedEvidence, (value) {
    return _then(_self.copyWith(approvedEvidence: value));
  });
}
}

// dart format on
