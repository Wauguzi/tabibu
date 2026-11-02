// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'case_log_entry_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CaseLogEntryModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'caseUid') String get caseUid;@JsonKey(name: 'seq') int get seq;@JsonKey(name: 'fromLocation') String get fromLocation;@JsonKey(name: 'fromStage') String get fromStage;@JsonKey(name: 'fromStep') String get fromStep;@JsonKey(name: 'toLocation') String get toLocation;@JsonKey(name: 'toStage') String get toStage;@JsonKey(name: 'toStep') String get toStep;@JsonKey(name: 'createdByUid') String get createdByUid;@JsonKey(name: 'actorRole') String get actorRole;@JsonKey(name: 'actionType') String get actionType;@JsonKey(name: 'actionReason') String get actionReason;@JsonKey(name: 'patientVisible') bool get patientVisible;@JsonKey(name: 'createdAt') String get createdAt;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;@JsonKey(includeFromJson: false, includeToJson: false) bool get synced;
/// Create a copy of CaseLogEntryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaseLogEntryModelCopyWith<CaseLogEntryModel> get copyWith => _$CaseLogEntryModelCopyWithImpl<CaseLogEntryModel>(this as CaseLogEntryModel, _$identity);

  /// Serializes this CaseLogEntryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaseLogEntryModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.seq, seq) || other.seq == seq)&&(identical(other.fromLocation, fromLocation) || other.fromLocation == fromLocation)&&(identical(other.fromStage, fromStage) || other.fromStage == fromStage)&&(identical(other.fromStep, fromStep) || other.fromStep == fromStep)&&(identical(other.toLocation, toLocation) || other.toLocation == toLocation)&&(identical(other.toStage, toStage) || other.toStage == toStage)&&(identical(other.toStep, toStep) || other.toStep == toStep)&&(identical(other.createdByUid, createdByUid) || other.createdByUid == createdByUid)&&(identical(other.actorRole, actorRole) || other.actorRole == actorRole)&&(identical(other.actionType, actionType) || other.actionType == actionType)&&(identical(other.actionReason, actionReason) || other.actionReason == actionReason)&&(identical(other.patientVisible, patientVisible) || other.patientVisible == patientVisible)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,caseUid,seq,fromLocation,fromStage,fromStep,toLocation,toStage,toStep,createdByUid,actorRole,actionType,actionReason,patientVisible,createdAt,lastUpdatedAt,synced);

@override
String toString() {
  return 'CaseLogEntryModel(uid: $uid, caseUid: $caseUid, seq: $seq, fromLocation: $fromLocation, fromStage: $fromStage, fromStep: $fromStep, toLocation: $toLocation, toStage: $toStage, toStep: $toStep, createdByUid: $createdByUid, actorRole: $actorRole, actionType: $actionType, actionReason: $actionReason, patientVisible: $patientVisible, createdAt: $createdAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class $CaseLogEntryModelCopyWith<$Res>  {
  factory $CaseLogEntryModelCopyWith(CaseLogEntryModel value, $Res Function(CaseLogEntryModel) _then) = _$CaseLogEntryModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'seq') int seq,@JsonKey(name: 'fromLocation') String fromLocation,@JsonKey(name: 'fromStage') String fromStage,@JsonKey(name: 'fromStep') String fromStep,@JsonKey(name: 'toLocation') String toLocation,@JsonKey(name: 'toStage') String toStage,@JsonKey(name: 'toStep') String toStep,@JsonKey(name: 'createdByUid') String createdByUid,@JsonKey(name: 'actorRole') String actorRole,@JsonKey(name: 'actionType') String actionType,@JsonKey(name: 'actionReason') String actionReason,@JsonKey(name: 'patientVisible') bool patientVisible,@JsonKey(name: 'createdAt') String createdAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class _$CaseLogEntryModelCopyWithImpl<$Res>
    implements $CaseLogEntryModelCopyWith<$Res> {
  _$CaseLogEntryModelCopyWithImpl(this._self, this._then);

  final CaseLogEntryModel _self;
  final $Res Function(CaseLogEntryModel) _then;

/// Create a copy of CaseLogEntryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? caseUid = null,Object? seq = null,Object? fromLocation = null,Object? fromStage = null,Object? fromStep = null,Object? toLocation = null,Object? toStage = null,Object? toStep = null,Object? createdByUid = null,Object? actorRole = null,Object? actionType = null,Object? actionReason = null,Object? patientVisible = null,Object? createdAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,fromLocation: null == fromLocation ? _self.fromLocation : fromLocation // ignore: cast_nullable_to_non_nullable
as String,fromStage: null == fromStage ? _self.fromStage : fromStage // ignore: cast_nullable_to_non_nullable
as String,fromStep: null == fromStep ? _self.fromStep : fromStep // ignore: cast_nullable_to_non_nullable
as String,toLocation: null == toLocation ? _self.toLocation : toLocation // ignore: cast_nullable_to_non_nullable
as String,toStage: null == toStage ? _self.toStage : toStage // ignore: cast_nullable_to_non_nullable
as String,toStep: null == toStep ? _self.toStep : toStep // ignore: cast_nullable_to_non_nullable
as String,createdByUid: null == createdByUid ? _self.createdByUid : createdByUid // ignore: cast_nullable_to_non_nullable
as String,actorRole: null == actorRole ? _self.actorRole : actorRole // ignore: cast_nullable_to_non_nullable
as String,actionType: null == actionType ? _self.actionType : actionType // ignore: cast_nullable_to_non_nullable
as String,actionReason: null == actionReason ? _self.actionReason : actionReason // ignore: cast_nullable_to_non_nullable
as String,patientVisible: null == patientVisible ? _self.patientVisible : patientVisible // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CaseLogEntryModel].
extension CaseLogEntryModelPatterns on CaseLogEntryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CaseLogEntryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CaseLogEntryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CaseLogEntryModel value)  $default,){
final _that = this;
switch (_that) {
case _CaseLogEntryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CaseLogEntryModel value)?  $default,){
final _that = this;
switch (_that) {
case _CaseLogEntryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'seq')  int seq, @JsonKey(name: 'fromLocation')  String fromLocation, @JsonKey(name: 'fromStage')  String fromStage, @JsonKey(name: 'fromStep')  String fromStep, @JsonKey(name: 'toLocation')  String toLocation, @JsonKey(name: 'toStage')  String toStage, @JsonKey(name: 'toStep')  String toStep, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'actorRole')  String actorRole, @JsonKey(name: 'actionType')  String actionType, @JsonKey(name: 'actionReason')  String actionReason, @JsonKey(name: 'patientVisible')  bool patientVisible, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CaseLogEntryModel() when $default != null:
return $default(_that.uid,_that.caseUid,_that.seq,_that.fromLocation,_that.fromStage,_that.fromStep,_that.toLocation,_that.toStage,_that.toStep,_that.createdByUid,_that.actorRole,_that.actionType,_that.actionReason,_that.patientVisible,_that.createdAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'seq')  int seq, @JsonKey(name: 'fromLocation')  String fromLocation, @JsonKey(name: 'fromStage')  String fromStage, @JsonKey(name: 'fromStep')  String fromStep, @JsonKey(name: 'toLocation')  String toLocation, @JsonKey(name: 'toStage')  String toStage, @JsonKey(name: 'toStep')  String toStep, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'actorRole')  String actorRole, @JsonKey(name: 'actionType')  String actionType, @JsonKey(name: 'actionReason')  String actionReason, @JsonKey(name: 'patientVisible')  bool patientVisible, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)  $default,) {final _that = this;
switch (_that) {
case _CaseLogEntryModel():
return $default(_that.uid,_that.caseUid,_that.seq,_that.fromLocation,_that.fromStage,_that.fromStep,_that.toLocation,_that.toStage,_that.toStep,_that.createdByUid,_that.actorRole,_that.actionType,_that.actionReason,_that.patientVisible,_that.createdAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'seq')  int seq, @JsonKey(name: 'fromLocation')  String fromLocation, @JsonKey(name: 'fromStage')  String fromStage, @JsonKey(name: 'fromStep')  String fromStep, @JsonKey(name: 'toLocation')  String toLocation, @JsonKey(name: 'toStage')  String toStage, @JsonKey(name: 'toStep')  String toStep, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'actorRole')  String actorRole, @JsonKey(name: 'actionType')  String actionType, @JsonKey(name: 'actionReason')  String actionReason, @JsonKey(name: 'patientVisible')  bool patientVisible, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,) {final _that = this;
switch (_that) {
case _CaseLogEntryModel() when $default != null:
return $default(_that.uid,_that.caseUid,_that.seq,_that.fromLocation,_that.fromStage,_that.fromStep,_that.toLocation,_that.toStage,_that.toStep,_that.createdByUid,_that.actorRole,_that.actionType,_that.actionReason,_that.patientVisible,_that.createdAt,_that.lastUpdatedAt,_that.synced);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CaseLogEntryModel extends CaseLogEntryModel {
  const _CaseLogEntryModel({@JsonKey(name: 'uid') this.uid = '', @JsonKey(name: 'caseUid') this.caseUid = '', @JsonKey(name: 'seq') this.seq = 0, @JsonKey(name: 'fromLocation') this.fromLocation = '', @JsonKey(name: 'fromStage') this.fromStage = '', @JsonKey(name: 'fromStep') this.fromStep = '', @JsonKey(name: 'toLocation') this.toLocation = '', @JsonKey(name: 'toStage') this.toStage = '', @JsonKey(name: 'toStep') this.toStep = '', @JsonKey(name: 'createdByUid') this.createdByUid = '', @JsonKey(name: 'actorRole') this.actorRole = 'System', @JsonKey(name: 'actionType') this.actionType = '', @JsonKey(name: 'actionReason') this.actionReason = '', @JsonKey(name: 'patientVisible') this.patientVisible = false, @JsonKey(name: 'createdAt') this.createdAt = '', @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = '', @JsonKey(includeFromJson: false, includeToJson: false) this.synced = true}): super._();
  factory _CaseLogEntryModel.fromJson(Map<String, dynamic> json) => _$CaseLogEntryModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'caseUid') final  String caseUid;
@override@JsonKey(name: 'seq') final  int seq;
@override@JsonKey(name: 'fromLocation') final  String fromLocation;
@override@JsonKey(name: 'fromStage') final  String fromStage;
@override@JsonKey(name: 'fromStep') final  String fromStep;
@override@JsonKey(name: 'toLocation') final  String toLocation;
@override@JsonKey(name: 'toStage') final  String toStage;
@override@JsonKey(name: 'toStep') final  String toStep;
@override@JsonKey(name: 'createdByUid') final  String createdByUid;
@override@JsonKey(name: 'actorRole') final  String actorRole;
@override@JsonKey(name: 'actionType') final  String actionType;
@override@JsonKey(name: 'actionReason') final  String actionReason;
@override@JsonKey(name: 'patientVisible') final  bool patientVisible;
@override@JsonKey(name: 'createdAt') final  String createdAt;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool synced;

/// Create a copy of CaseLogEntryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CaseLogEntryModelCopyWith<_CaseLogEntryModel> get copyWith => __$CaseLogEntryModelCopyWithImpl<_CaseLogEntryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CaseLogEntryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CaseLogEntryModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.seq, seq) || other.seq == seq)&&(identical(other.fromLocation, fromLocation) || other.fromLocation == fromLocation)&&(identical(other.fromStage, fromStage) || other.fromStage == fromStage)&&(identical(other.fromStep, fromStep) || other.fromStep == fromStep)&&(identical(other.toLocation, toLocation) || other.toLocation == toLocation)&&(identical(other.toStage, toStage) || other.toStage == toStage)&&(identical(other.toStep, toStep) || other.toStep == toStep)&&(identical(other.createdByUid, createdByUid) || other.createdByUid == createdByUid)&&(identical(other.actorRole, actorRole) || other.actorRole == actorRole)&&(identical(other.actionType, actionType) || other.actionType == actionType)&&(identical(other.actionReason, actionReason) || other.actionReason == actionReason)&&(identical(other.patientVisible, patientVisible) || other.patientVisible == patientVisible)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,caseUid,seq,fromLocation,fromStage,fromStep,toLocation,toStage,toStep,createdByUid,actorRole,actionType,actionReason,patientVisible,createdAt,lastUpdatedAt,synced);

@override
String toString() {
  return 'CaseLogEntryModel(uid: $uid, caseUid: $caseUid, seq: $seq, fromLocation: $fromLocation, fromStage: $fromStage, fromStep: $fromStep, toLocation: $toLocation, toStage: $toStage, toStep: $toStep, createdByUid: $createdByUid, actorRole: $actorRole, actionType: $actionType, actionReason: $actionReason, patientVisible: $patientVisible, createdAt: $createdAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class _$CaseLogEntryModelCopyWith<$Res> implements $CaseLogEntryModelCopyWith<$Res> {
  factory _$CaseLogEntryModelCopyWith(_CaseLogEntryModel value, $Res Function(_CaseLogEntryModel) _then) = __$CaseLogEntryModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'seq') int seq,@JsonKey(name: 'fromLocation') String fromLocation,@JsonKey(name: 'fromStage') String fromStage,@JsonKey(name: 'fromStep') String fromStep,@JsonKey(name: 'toLocation') String toLocation,@JsonKey(name: 'toStage') String toStage,@JsonKey(name: 'toStep') String toStep,@JsonKey(name: 'createdByUid') String createdByUid,@JsonKey(name: 'actorRole') String actorRole,@JsonKey(name: 'actionType') String actionType,@JsonKey(name: 'actionReason') String actionReason,@JsonKey(name: 'patientVisible') bool patientVisible,@JsonKey(name: 'createdAt') String createdAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class __$CaseLogEntryModelCopyWithImpl<$Res>
    implements _$CaseLogEntryModelCopyWith<$Res> {
  __$CaseLogEntryModelCopyWithImpl(this._self, this._then);

  final _CaseLogEntryModel _self;
  final $Res Function(_CaseLogEntryModel) _then;

/// Create a copy of CaseLogEntryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? caseUid = null,Object? seq = null,Object? fromLocation = null,Object? fromStage = null,Object? fromStep = null,Object? toLocation = null,Object? toStage = null,Object? toStep = null,Object? createdByUid = null,Object? actorRole = null,Object? actionType = null,Object? actionReason = null,Object? patientVisible = null,Object? createdAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_CaseLogEntryModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,fromLocation: null == fromLocation ? _self.fromLocation : fromLocation // ignore: cast_nullable_to_non_nullable
as String,fromStage: null == fromStage ? _self.fromStage : fromStage // ignore: cast_nullable_to_non_nullable
as String,fromStep: null == fromStep ? _self.fromStep : fromStep // ignore: cast_nullable_to_non_nullable
as String,toLocation: null == toLocation ? _self.toLocation : toLocation // ignore: cast_nullable_to_non_nullable
as String,toStage: null == toStage ? _self.toStage : toStage // ignore: cast_nullable_to_non_nullable
as String,toStep: null == toStep ? _self.toStep : toStep // ignore: cast_nullable_to_non_nullable
as String,createdByUid: null == createdByUid ? _self.createdByUid : createdByUid // ignore: cast_nullable_to_non_nullable
as String,actorRole: null == actorRole ? _self.actorRole : actorRole // ignore: cast_nullable_to_non_nullable
as String,actionType: null == actionType ? _self.actionType : actionType // ignore: cast_nullable_to_non_nullable
as String,actionReason: null == actionReason ? _self.actionReason : actionReason // ignore: cast_nullable_to_non_nullable
as String,patientVisible: null == patientVisible ? _self.patientVisible : patientVisible // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
