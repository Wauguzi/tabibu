// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'worklist_entry_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorklistEntryModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'caseUid') String get caseUid;@JsonKey(name: 'pathologistUid') String get pathologistUid;@JsonKey(name: 'orderNumber') String get orderNumber;@JsonKey(name: 'testName') String get testName;@JsonKey(name: 'profile') String get profile;@JsonKey(name: 'status') String get status;@JsonKey(name: 'prereadStatus') String get prereadStatus;@JsonKey(name: 'urgency') String get urgency;@JsonKey(name: 'confidenceBand') String get confidenceBand;@JsonKey(name: 'confidence') double get confidence;@JsonKey(name: 'riskFlag') bool get riskFlag;@JsonKey(name: 'severity') String get severity;@JsonKey(name: 'basePriority') int get basePriority;@JsonKey(name: 'waitingSince') String get waitingSince;@JsonKey(name: 'assignedAt') String get assignedAt;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;@JsonKey(includeFromJson: false, includeToJson: false) bool get synced;
/// Create a copy of WorklistEntryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorklistEntryModelCopyWith<WorklistEntryModel> get copyWith => _$WorklistEntryModelCopyWithImpl<WorklistEntryModel>(this as WorklistEntryModel, _$identity);

  /// Serializes this WorklistEntryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorklistEntryModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.pathologistUid, pathologistUid) || other.pathologistUid == pathologistUid)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.testName, testName) || other.testName == testName)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.status, status) || other.status == status)&&(identical(other.prereadStatus, prereadStatus) || other.prereadStatus == prereadStatus)&&(identical(other.urgency, urgency) || other.urgency == urgency)&&(identical(other.confidenceBand, confidenceBand) || other.confidenceBand == confidenceBand)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.riskFlag, riskFlag) || other.riskFlag == riskFlag)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.basePriority, basePriority) || other.basePriority == basePriority)&&(identical(other.waitingSince, waitingSince) || other.waitingSince == waitingSince)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,caseUid,pathologistUid,orderNumber,testName,profile,status,prereadStatus,urgency,confidenceBand,confidence,riskFlag,severity,basePriority,waitingSince,assignedAt,lastUpdatedAt,synced);

@override
String toString() {
  return 'WorklistEntryModel(uid: $uid, caseUid: $caseUid, pathologistUid: $pathologistUid, orderNumber: $orderNumber, testName: $testName, profile: $profile, status: $status, prereadStatus: $prereadStatus, urgency: $urgency, confidenceBand: $confidenceBand, confidence: $confidence, riskFlag: $riskFlag, severity: $severity, basePriority: $basePriority, waitingSince: $waitingSince, assignedAt: $assignedAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class $WorklistEntryModelCopyWith<$Res>  {
  factory $WorklistEntryModelCopyWith(WorklistEntryModel value, $Res Function(WorklistEntryModel) _then) = _$WorklistEntryModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'pathologistUid') String pathologistUid,@JsonKey(name: 'orderNumber') String orderNumber,@JsonKey(name: 'testName') String testName,@JsonKey(name: 'profile') String profile,@JsonKey(name: 'status') String status,@JsonKey(name: 'prereadStatus') String prereadStatus,@JsonKey(name: 'urgency') String urgency,@JsonKey(name: 'confidenceBand') String confidenceBand,@JsonKey(name: 'confidence') double confidence,@JsonKey(name: 'riskFlag') bool riskFlag,@JsonKey(name: 'severity') String severity,@JsonKey(name: 'basePriority') int basePriority,@JsonKey(name: 'waitingSince') String waitingSince,@JsonKey(name: 'assignedAt') String assignedAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class _$WorklistEntryModelCopyWithImpl<$Res>
    implements $WorklistEntryModelCopyWith<$Res> {
  _$WorklistEntryModelCopyWithImpl(this._self, this._then);

  final WorklistEntryModel _self;
  final $Res Function(WorklistEntryModel) _then;

/// Create a copy of WorklistEntryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? caseUid = null,Object? pathologistUid = null,Object? orderNumber = null,Object? testName = null,Object? profile = null,Object? status = null,Object? prereadStatus = null,Object? urgency = null,Object? confidenceBand = null,Object? confidence = null,Object? riskFlag = null,Object? severity = null,Object? basePriority = null,Object? waitingSince = null,Object? assignedAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,pathologistUid: null == pathologistUid ? _self.pathologistUid : pathologistUid // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,testName: null == testName ? _self.testName : testName // ignore: cast_nullable_to_non_nullable
as String,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,prereadStatus: null == prereadStatus ? _self.prereadStatus : prereadStatus // ignore: cast_nullable_to_non_nullable
as String,urgency: null == urgency ? _self.urgency : urgency // ignore: cast_nullable_to_non_nullable
as String,confidenceBand: null == confidenceBand ? _self.confidenceBand : confidenceBand // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,riskFlag: null == riskFlag ? _self.riskFlag : riskFlag // ignore: cast_nullable_to_non_nullable
as bool,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,basePriority: null == basePriority ? _self.basePriority : basePriority // ignore: cast_nullable_to_non_nullable
as int,waitingSince: null == waitingSince ? _self.waitingSince : waitingSince // ignore: cast_nullable_to_non_nullable
as String,assignedAt: null == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WorklistEntryModel].
extension WorklistEntryModelPatterns on WorklistEntryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorklistEntryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorklistEntryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorklistEntryModel value)  $default,){
final _that = this;
switch (_that) {
case _WorklistEntryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorklistEntryModel value)?  $default,){
final _that = this;
switch (_that) {
case _WorklistEntryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'pathologistUid')  String pathologistUid, @JsonKey(name: 'orderNumber')  String orderNumber, @JsonKey(name: 'testName')  String testName, @JsonKey(name: 'profile')  String profile, @JsonKey(name: 'status')  String status, @JsonKey(name: 'prereadStatus')  String prereadStatus, @JsonKey(name: 'urgency')  String urgency, @JsonKey(name: 'confidenceBand')  String confidenceBand, @JsonKey(name: 'confidence')  double confidence, @JsonKey(name: 'riskFlag')  bool riskFlag, @JsonKey(name: 'severity')  String severity, @JsonKey(name: 'basePriority')  int basePriority, @JsonKey(name: 'waitingSince')  String waitingSince, @JsonKey(name: 'assignedAt')  String assignedAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorklistEntryModel() when $default != null:
return $default(_that.uid,_that.caseUid,_that.pathologistUid,_that.orderNumber,_that.testName,_that.profile,_that.status,_that.prereadStatus,_that.urgency,_that.confidenceBand,_that.confidence,_that.riskFlag,_that.severity,_that.basePriority,_that.waitingSince,_that.assignedAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'pathologistUid')  String pathologistUid, @JsonKey(name: 'orderNumber')  String orderNumber, @JsonKey(name: 'testName')  String testName, @JsonKey(name: 'profile')  String profile, @JsonKey(name: 'status')  String status, @JsonKey(name: 'prereadStatus')  String prereadStatus, @JsonKey(name: 'urgency')  String urgency, @JsonKey(name: 'confidenceBand')  String confidenceBand, @JsonKey(name: 'confidence')  double confidence, @JsonKey(name: 'riskFlag')  bool riskFlag, @JsonKey(name: 'severity')  String severity, @JsonKey(name: 'basePriority')  int basePriority, @JsonKey(name: 'waitingSince')  String waitingSince, @JsonKey(name: 'assignedAt')  String assignedAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)  $default,) {final _that = this;
switch (_that) {
case _WorklistEntryModel():
return $default(_that.uid,_that.caseUid,_that.pathologistUid,_that.orderNumber,_that.testName,_that.profile,_that.status,_that.prereadStatus,_that.urgency,_that.confidenceBand,_that.confidence,_that.riskFlag,_that.severity,_that.basePriority,_that.waitingSince,_that.assignedAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'pathologistUid')  String pathologistUid, @JsonKey(name: 'orderNumber')  String orderNumber, @JsonKey(name: 'testName')  String testName, @JsonKey(name: 'profile')  String profile, @JsonKey(name: 'status')  String status, @JsonKey(name: 'prereadStatus')  String prereadStatus, @JsonKey(name: 'urgency')  String urgency, @JsonKey(name: 'confidenceBand')  String confidenceBand, @JsonKey(name: 'confidence')  double confidence, @JsonKey(name: 'riskFlag')  bool riskFlag, @JsonKey(name: 'severity')  String severity, @JsonKey(name: 'basePriority')  int basePriority, @JsonKey(name: 'waitingSince')  String waitingSince, @JsonKey(name: 'assignedAt')  String assignedAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,) {final _that = this;
switch (_that) {
case _WorklistEntryModel() when $default != null:
return $default(_that.uid,_that.caseUid,_that.pathologistUid,_that.orderNumber,_that.testName,_that.profile,_that.status,_that.prereadStatus,_that.urgency,_that.confidenceBand,_that.confidence,_that.riskFlag,_that.severity,_that.basePriority,_that.waitingSince,_that.assignedAt,_that.lastUpdatedAt,_that.synced);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorklistEntryModel extends WorklistEntryModel {
  const _WorklistEntryModel({@JsonKey(name: 'uid') this.uid = '', @JsonKey(name: 'caseUid') this.caseUid = '', @JsonKey(name: 'pathologistUid') this.pathologistUid = '', @JsonKey(name: 'orderNumber') this.orderNumber = '', @JsonKey(name: 'testName') this.testName = '', @JsonKey(name: 'profile') this.profile = 'None', @JsonKey(name: 'status') this.status = 'Open', @JsonKey(name: 'prereadStatus') this.prereadStatus = '', @JsonKey(name: 'urgency') this.urgency = 'Routine', @JsonKey(name: 'confidenceBand') this.confidenceBand = 'Low', @JsonKey(name: 'confidence') this.confidence = 0, @JsonKey(name: 'riskFlag') this.riskFlag = false, @JsonKey(name: 'severity') this.severity = 'Routine', @JsonKey(name: 'basePriority') this.basePriority = 0, @JsonKey(name: 'waitingSince') this.waitingSince = '', @JsonKey(name: 'assignedAt') this.assignedAt = '', @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = '', @JsonKey(includeFromJson: false, includeToJson: false) this.synced = true}): super._();
  factory _WorklistEntryModel.fromJson(Map<String, dynamic> json) => _$WorklistEntryModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'caseUid') final  String caseUid;
@override@JsonKey(name: 'pathologistUid') final  String pathologistUid;
@override@JsonKey(name: 'orderNumber') final  String orderNumber;
@override@JsonKey(name: 'testName') final  String testName;
@override@JsonKey(name: 'profile') final  String profile;
@override@JsonKey(name: 'status') final  String status;
@override@JsonKey(name: 'prereadStatus') final  String prereadStatus;
@override@JsonKey(name: 'urgency') final  String urgency;
@override@JsonKey(name: 'confidenceBand') final  String confidenceBand;
@override@JsonKey(name: 'confidence') final  double confidence;
@override@JsonKey(name: 'riskFlag') final  bool riskFlag;
@override@JsonKey(name: 'severity') final  String severity;
@override@JsonKey(name: 'basePriority') final  int basePriority;
@override@JsonKey(name: 'waitingSince') final  String waitingSince;
@override@JsonKey(name: 'assignedAt') final  String assignedAt;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool synced;

/// Create a copy of WorklistEntryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorklistEntryModelCopyWith<_WorklistEntryModel> get copyWith => __$WorklistEntryModelCopyWithImpl<_WorklistEntryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorklistEntryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorklistEntryModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.pathologistUid, pathologistUid) || other.pathologistUid == pathologistUid)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.testName, testName) || other.testName == testName)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.status, status) || other.status == status)&&(identical(other.prereadStatus, prereadStatus) || other.prereadStatus == prereadStatus)&&(identical(other.urgency, urgency) || other.urgency == urgency)&&(identical(other.confidenceBand, confidenceBand) || other.confidenceBand == confidenceBand)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.riskFlag, riskFlag) || other.riskFlag == riskFlag)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.basePriority, basePriority) || other.basePriority == basePriority)&&(identical(other.waitingSince, waitingSince) || other.waitingSince == waitingSince)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,caseUid,pathologistUid,orderNumber,testName,profile,status,prereadStatus,urgency,confidenceBand,confidence,riskFlag,severity,basePriority,waitingSince,assignedAt,lastUpdatedAt,synced);

@override
String toString() {
  return 'WorklistEntryModel(uid: $uid, caseUid: $caseUid, pathologistUid: $pathologistUid, orderNumber: $orderNumber, testName: $testName, profile: $profile, status: $status, prereadStatus: $prereadStatus, urgency: $urgency, confidenceBand: $confidenceBand, confidence: $confidence, riskFlag: $riskFlag, severity: $severity, basePriority: $basePriority, waitingSince: $waitingSince, assignedAt: $assignedAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class _$WorklistEntryModelCopyWith<$Res> implements $WorklistEntryModelCopyWith<$Res> {
  factory _$WorklistEntryModelCopyWith(_WorklistEntryModel value, $Res Function(_WorklistEntryModel) _then) = __$WorklistEntryModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'pathologistUid') String pathologistUid,@JsonKey(name: 'orderNumber') String orderNumber,@JsonKey(name: 'testName') String testName,@JsonKey(name: 'profile') String profile,@JsonKey(name: 'status') String status,@JsonKey(name: 'prereadStatus') String prereadStatus,@JsonKey(name: 'urgency') String urgency,@JsonKey(name: 'confidenceBand') String confidenceBand,@JsonKey(name: 'confidence') double confidence,@JsonKey(name: 'riskFlag') bool riskFlag,@JsonKey(name: 'severity') String severity,@JsonKey(name: 'basePriority') int basePriority,@JsonKey(name: 'waitingSince') String waitingSince,@JsonKey(name: 'assignedAt') String assignedAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class __$WorklistEntryModelCopyWithImpl<$Res>
    implements _$WorklistEntryModelCopyWith<$Res> {
  __$WorklistEntryModelCopyWithImpl(this._self, this._then);

  final _WorklistEntryModel _self;
  final $Res Function(_WorklistEntryModel) _then;

/// Create a copy of WorklistEntryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? caseUid = null,Object? pathologistUid = null,Object? orderNumber = null,Object? testName = null,Object? profile = null,Object? status = null,Object? prereadStatus = null,Object? urgency = null,Object? confidenceBand = null,Object? confidence = null,Object? riskFlag = null,Object? severity = null,Object? basePriority = null,Object? waitingSince = null,Object? assignedAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_WorklistEntryModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,pathologistUid: null == pathologistUid ? _self.pathologistUid : pathologistUid // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,testName: null == testName ? _self.testName : testName // ignore: cast_nullable_to_non_nullable
as String,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,prereadStatus: null == prereadStatus ? _self.prereadStatus : prereadStatus // ignore: cast_nullable_to_non_nullable
as String,urgency: null == urgency ? _self.urgency : urgency // ignore: cast_nullable_to_non_nullable
as String,confidenceBand: null == confidenceBand ? _self.confidenceBand : confidenceBand // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,riskFlag: null == riskFlag ? _self.riskFlag : riskFlag // ignore: cast_nullable_to_non_nullable
as bool,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,basePriority: null == basePriority ? _self.basePriority : basePriority // ignore: cast_nullable_to_non_nullable
as int,waitingSince: null == waitingSince ? _self.waitingSince : waitingSince // ignore: cast_nullable_to_non_nullable
as String,assignedAt: null == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
