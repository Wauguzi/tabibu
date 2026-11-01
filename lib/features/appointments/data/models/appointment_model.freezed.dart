// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appointment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppointmentModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'type') String get type;@JsonKey(name: 'status') String get status;@JsonKey(name: 'patientUid') String get patientUid;@JsonKey(name: 'patientId') String get patientId;@JsonKey(name: 'patientName') String get patientName;@JsonKey(name: 'doctorUid') String get doctorUid;@JsonKey(name: 'doctorName') String get doctorName;@JsonKey(name: 'facilityName') String get facilityName;@JsonKey(name: 'createdByUid') String get createdByUid;@JsonKey(name: 'scheduledStart') String get scheduledStart;@JsonKey(name: 'scheduledEnd') String get scheduledEnd;@JsonKey(name: 'symptomText') String get symptomText;@JsonKey(name: 'inputMode') String get inputMode;@JsonKey(name: 'symptomLanguage') String get symptomLanguage;@JsonKey(name: 'intakeStatus') String get intakeStatus;@JsonKey(name: 'discussedCaseUid') String get discussedCaseUid;@JsonKey(name: 'discussedOrderNumber') String get discussedOrderNumber;@JsonKey(name: 'caseUids') List<String> get caseUids;@JsonKey(name: 'expiresAt') String get expiresAt;@JsonKey(name: 'respondedAt') String get respondedAt;@JsonKey(name: 'acceptedAt') String get acceptedAt;@JsonKey(name: 'declineReason') String get declineReason;@JsonKey(name: 'declineNote') String get declineNote;@JsonKey(name: 'cancelledAt') String get cancelledAt;@JsonKey(name: 'cancelledByUid') String get cancelledByUid;@JsonKey(name: 'cancelNote') String get cancelNote;@JsonKey(name: 'completedAt') String get completedAt;@JsonKey(name: 'createdAt') String get createdAt;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;@JsonKey(includeFromJson: false, includeToJson: false) bool get synced;
/// Create a copy of AppointmentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppointmentModelCopyWith<AppointmentModel> get copyWith => _$AppointmentModelCopyWithImpl<AppointmentModel>(this as AppointmentModel, _$identity);

  /// Serializes this AppointmentModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppointmentModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.patientUid, patientUid) || other.patientUid == patientUid)&&(identical(other.patientId, patientId) || other.patientId == patientId)&&(identical(other.patientName, patientName) || other.patientName == patientName)&&(identical(other.doctorUid, doctorUid) || other.doctorUid == doctorUid)&&(identical(other.doctorName, doctorName) || other.doctorName == doctorName)&&(identical(other.facilityName, facilityName) || other.facilityName == facilityName)&&(identical(other.createdByUid, createdByUid) || other.createdByUid == createdByUid)&&(identical(other.scheduledStart, scheduledStart) || other.scheduledStart == scheduledStart)&&(identical(other.scheduledEnd, scheduledEnd) || other.scheduledEnd == scheduledEnd)&&(identical(other.symptomText, symptomText) || other.symptomText == symptomText)&&(identical(other.inputMode, inputMode) || other.inputMode == inputMode)&&(identical(other.symptomLanguage, symptomLanguage) || other.symptomLanguage == symptomLanguage)&&(identical(other.intakeStatus, intakeStatus) || other.intakeStatus == intakeStatus)&&(identical(other.discussedCaseUid, discussedCaseUid) || other.discussedCaseUid == discussedCaseUid)&&(identical(other.discussedOrderNumber, discussedOrderNumber) || other.discussedOrderNumber == discussedOrderNumber)&&const DeepCollectionEquality().equals(other.caseUids, caseUids)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.respondedAt, respondedAt) || other.respondedAt == respondedAt)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.declineReason, declineReason) || other.declineReason == declineReason)&&(identical(other.declineNote, declineNote) || other.declineNote == declineNote)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.cancelledByUid, cancelledByUid) || other.cancelledByUid == cancelledByUid)&&(identical(other.cancelNote, cancelNote) || other.cancelNote == cancelNote)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,type,status,patientUid,patientId,patientName,doctorUid,doctorName,facilityName,createdByUid,scheduledStart,scheduledEnd,symptomText,inputMode,symptomLanguage,intakeStatus,discussedCaseUid,discussedOrderNumber,const DeepCollectionEquality().hash(caseUids),expiresAt,respondedAt,acceptedAt,declineReason,declineNote,cancelledAt,cancelledByUid,cancelNote,completedAt,createdAt,lastUpdatedAt,synced]);

@override
String toString() {
  return 'AppointmentModel(uid: $uid, type: $type, status: $status, patientUid: $patientUid, patientId: $patientId, patientName: $patientName, doctorUid: $doctorUid, doctorName: $doctorName, facilityName: $facilityName, createdByUid: $createdByUid, scheduledStart: $scheduledStart, scheduledEnd: $scheduledEnd, symptomText: $symptomText, inputMode: $inputMode, symptomLanguage: $symptomLanguage, intakeStatus: $intakeStatus, discussedCaseUid: $discussedCaseUid, discussedOrderNumber: $discussedOrderNumber, caseUids: $caseUids, expiresAt: $expiresAt, respondedAt: $respondedAt, acceptedAt: $acceptedAt, declineReason: $declineReason, declineNote: $declineNote, cancelledAt: $cancelledAt, cancelledByUid: $cancelledByUid, cancelNote: $cancelNote, completedAt: $completedAt, createdAt: $createdAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class $AppointmentModelCopyWith<$Res>  {
  factory $AppointmentModelCopyWith(AppointmentModel value, $Res Function(AppointmentModel) _then) = _$AppointmentModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'type') String type,@JsonKey(name: 'status') String status,@JsonKey(name: 'patientUid') String patientUid,@JsonKey(name: 'patientId') String patientId,@JsonKey(name: 'patientName') String patientName,@JsonKey(name: 'doctorUid') String doctorUid,@JsonKey(name: 'doctorName') String doctorName,@JsonKey(name: 'facilityName') String facilityName,@JsonKey(name: 'createdByUid') String createdByUid,@JsonKey(name: 'scheduledStart') String scheduledStart,@JsonKey(name: 'scheduledEnd') String scheduledEnd,@JsonKey(name: 'symptomText') String symptomText,@JsonKey(name: 'inputMode') String inputMode,@JsonKey(name: 'symptomLanguage') String symptomLanguage,@JsonKey(name: 'intakeStatus') String intakeStatus,@JsonKey(name: 'discussedCaseUid') String discussedCaseUid,@JsonKey(name: 'discussedOrderNumber') String discussedOrderNumber,@JsonKey(name: 'caseUids') List<String> caseUids,@JsonKey(name: 'expiresAt') String expiresAt,@JsonKey(name: 'respondedAt') String respondedAt,@JsonKey(name: 'acceptedAt') String acceptedAt,@JsonKey(name: 'declineReason') String declineReason,@JsonKey(name: 'declineNote') String declineNote,@JsonKey(name: 'cancelledAt') String cancelledAt,@JsonKey(name: 'cancelledByUid') String cancelledByUid,@JsonKey(name: 'cancelNote') String cancelNote,@JsonKey(name: 'completedAt') String completedAt,@JsonKey(name: 'createdAt') String createdAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class _$AppointmentModelCopyWithImpl<$Res>
    implements $AppointmentModelCopyWith<$Res> {
  _$AppointmentModelCopyWithImpl(this._self, this._then);

  final AppointmentModel _self;
  final $Res Function(AppointmentModel) _then;

/// Create a copy of AppointmentModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? type = null,Object? status = null,Object? patientUid = null,Object? patientId = null,Object? patientName = null,Object? doctorUid = null,Object? doctorName = null,Object? facilityName = null,Object? createdByUid = null,Object? scheduledStart = null,Object? scheduledEnd = null,Object? symptomText = null,Object? inputMode = null,Object? symptomLanguage = null,Object? intakeStatus = null,Object? discussedCaseUid = null,Object? discussedOrderNumber = null,Object? caseUids = null,Object? expiresAt = null,Object? respondedAt = null,Object? acceptedAt = null,Object? declineReason = null,Object? declineNote = null,Object? cancelledAt = null,Object? cancelledByUid = null,Object? cancelNote = null,Object? completedAt = null,Object? createdAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,patientUid: null == patientUid ? _self.patientUid : patientUid // ignore: cast_nullable_to_non_nullable
as String,patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,patientName: null == patientName ? _self.patientName : patientName // ignore: cast_nullable_to_non_nullable
as String,doctorUid: null == doctorUid ? _self.doctorUid : doctorUid // ignore: cast_nullable_to_non_nullable
as String,doctorName: null == doctorName ? _self.doctorName : doctorName // ignore: cast_nullable_to_non_nullable
as String,facilityName: null == facilityName ? _self.facilityName : facilityName // ignore: cast_nullable_to_non_nullable
as String,createdByUid: null == createdByUid ? _self.createdByUid : createdByUid // ignore: cast_nullable_to_non_nullable
as String,scheduledStart: null == scheduledStart ? _self.scheduledStart : scheduledStart // ignore: cast_nullable_to_non_nullable
as String,scheduledEnd: null == scheduledEnd ? _self.scheduledEnd : scheduledEnd // ignore: cast_nullable_to_non_nullable
as String,symptomText: null == symptomText ? _self.symptomText : symptomText // ignore: cast_nullable_to_non_nullable
as String,inputMode: null == inputMode ? _self.inputMode : inputMode // ignore: cast_nullable_to_non_nullable
as String,symptomLanguage: null == symptomLanguage ? _self.symptomLanguage : symptomLanguage // ignore: cast_nullable_to_non_nullable
as String,intakeStatus: null == intakeStatus ? _self.intakeStatus : intakeStatus // ignore: cast_nullable_to_non_nullable
as String,discussedCaseUid: null == discussedCaseUid ? _self.discussedCaseUid : discussedCaseUid // ignore: cast_nullable_to_non_nullable
as String,discussedOrderNumber: null == discussedOrderNumber ? _self.discussedOrderNumber : discussedOrderNumber // ignore: cast_nullable_to_non_nullable
as String,caseUids: null == caseUids ? _self.caseUids : caseUids // ignore: cast_nullable_to_non_nullable
as List<String>,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String,respondedAt: null == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as String,acceptedAt: null == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as String,declineReason: null == declineReason ? _self.declineReason : declineReason // ignore: cast_nullable_to_non_nullable
as String,declineNote: null == declineNote ? _self.declineNote : declineNote // ignore: cast_nullable_to_non_nullable
as String,cancelledAt: null == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as String,cancelledByUid: null == cancelledByUid ? _self.cancelledByUid : cancelledByUid // ignore: cast_nullable_to_non_nullable
as String,cancelNote: null == cancelNote ? _self.cancelNote : cancelNote // ignore: cast_nullable_to_non_nullable
as String,completedAt: null == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppointmentModel].
extension AppointmentModelPatterns on AppointmentModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppointmentModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppointmentModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppointmentModel value)  $default,){
final _that = this;
switch (_that) {
case _AppointmentModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppointmentModel value)?  $default,){
final _that = this;
switch (_that) {
case _AppointmentModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'type')  String type, @JsonKey(name: 'status')  String status, @JsonKey(name: 'patientUid')  String patientUid, @JsonKey(name: 'patientId')  String patientId, @JsonKey(name: 'patientName')  String patientName, @JsonKey(name: 'doctorUid')  String doctorUid, @JsonKey(name: 'doctorName')  String doctorName, @JsonKey(name: 'facilityName')  String facilityName, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'scheduledStart')  String scheduledStart, @JsonKey(name: 'scheduledEnd')  String scheduledEnd, @JsonKey(name: 'symptomText')  String symptomText, @JsonKey(name: 'inputMode')  String inputMode, @JsonKey(name: 'symptomLanguage')  String symptomLanguage, @JsonKey(name: 'intakeStatus')  String intakeStatus, @JsonKey(name: 'discussedCaseUid')  String discussedCaseUid, @JsonKey(name: 'discussedOrderNumber')  String discussedOrderNumber, @JsonKey(name: 'caseUids')  List<String> caseUids, @JsonKey(name: 'expiresAt')  String expiresAt, @JsonKey(name: 'respondedAt')  String respondedAt, @JsonKey(name: 'acceptedAt')  String acceptedAt, @JsonKey(name: 'declineReason')  String declineReason, @JsonKey(name: 'declineNote')  String declineNote, @JsonKey(name: 'cancelledAt')  String cancelledAt, @JsonKey(name: 'cancelledByUid')  String cancelledByUid, @JsonKey(name: 'cancelNote')  String cancelNote, @JsonKey(name: 'completedAt')  String completedAt, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppointmentModel() when $default != null:
return $default(_that.uid,_that.type,_that.status,_that.patientUid,_that.patientId,_that.patientName,_that.doctorUid,_that.doctorName,_that.facilityName,_that.createdByUid,_that.scheduledStart,_that.scheduledEnd,_that.symptomText,_that.inputMode,_that.symptomLanguage,_that.intakeStatus,_that.discussedCaseUid,_that.discussedOrderNumber,_that.caseUids,_that.expiresAt,_that.respondedAt,_that.acceptedAt,_that.declineReason,_that.declineNote,_that.cancelledAt,_that.cancelledByUid,_that.cancelNote,_that.completedAt,_that.createdAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'type')  String type, @JsonKey(name: 'status')  String status, @JsonKey(name: 'patientUid')  String patientUid, @JsonKey(name: 'patientId')  String patientId, @JsonKey(name: 'patientName')  String patientName, @JsonKey(name: 'doctorUid')  String doctorUid, @JsonKey(name: 'doctorName')  String doctorName, @JsonKey(name: 'facilityName')  String facilityName, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'scheduledStart')  String scheduledStart, @JsonKey(name: 'scheduledEnd')  String scheduledEnd, @JsonKey(name: 'symptomText')  String symptomText, @JsonKey(name: 'inputMode')  String inputMode, @JsonKey(name: 'symptomLanguage')  String symptomLanguage, @JsonKey(name: 'intakeStatus')  String intakeStatus, @JsonKey(name: 'discussedCaseUid')  String discussedCaseUid, @JsonKey(name: 'discussedOrderNumber')  String discussedOrderNumber, @JsonKey(name: 'caseUids')  List<String> caseUids, @JsonKey(name: 'expiresAt')  String expiresAt, @JsonKey(name: 'respondedAt')  String respondedAt, @JsonKey(name: 'acceptedAt')  String acceptedAt, @JsonKey(name: 'declineReason')  String declineReason, @JsonKey(name: 'declineNote')  String declineNote, @JsonKey(name: 'cancelledAt')  String cancelledAt, @JsonKey(name: 'cancelledByUid')  String cancelledByUid, @JsonKey(name: 'cancelNote')  String cancelNote, @JsonKey(name: 'completedAt')  String completedAt, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)  $default,) {final _that = this;
switch (_that) {
case _AppointmentModel():
return $default(_that.uid,_that.type,_that.status,_that.patientUid,_that.patientId,_that.patientName,_that.doctorUid,_that.doctorName,_that.facilityName,_that.createdByUid,_that.scheduledStart,_that.scheduledEnd,_that.symptomText,_that.inputMode,_that.symptomLanguage,_that.intakeStatus,_that.discussedCaseUid,_that.discussedOrderNumber,_that.caseUids,_that.expiresAt,_that.respondedAt,_that.acceptedAt,_that.declineReason,_that.declineNote,_that.cancelledAt,_that.cancelledByUid,_that.cancelNote,_that.completedAt,_that.createdAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'type')  String type, @JsonKey(name: 'status')  String status, @JsonKey(name: 'patientUid')  String patientUid, @JsonKey(name: 'patientId')  String patientId, @JsonKey(name: 'patientName')  String patientName, @JsonKey(name: 'doctorUid')  String doctorUid, @JsonKey(name: 'doctorName')  String doctorName, @JsonKey(name: 'facilityName')  String facilityName, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'scheduledStart')  String scheduledStart, @JsonKey(name: 'scheduledEnd')  String scheduledEnd, @JsonKey(name: 'symptomText')  String symptomText, @JsonKey(name: 'inputMode')  String inputMode, @JsonKey(name: 'symptomLanguage')  String symptomLanguage, @JsonKey(name: 'intakeStatus')  String intakeStatus, @JsonKey(name: 'discussedCaseUid')  String discussedCaseUid, @JsonKey(name: 'discussedOrderNumber')  String discussedOrderNumber, @JsonKey(name: 'caseUids')  List<String> caseUids, @JsonKey(name: 'expiresAt')  String expiresAt, @JsonKey(name: 'respondedAt')  String respondedAt, @JsonKey(name: 'acceptedAt')  String acceptedAt, @JsonKey(name: 'declineReason')  String declineReason, @JsonKey(name: 'declineNote')  String declineNote, @JsonKey(name: 'cancelledAt')  String cancelledAt, @JsonKey(name: 'cancelledByUid')  String cancelledByUid, @JsonKey(name: 'cancelNote')  String cancelNote, @JsonKey(name: 'completedAt')  String completedAt, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,) {final _that = this;
switch (_that) {
case _AppointmentModel() when $default != null:
return $default(_that.uid,_that.type,_that.status,_that.patientUid,_that.patientId,_that.patientName,_that.doctorUid,_that.doctorName,_that.facilityName,_that.createdByUid,_that.scheduledStart,_that.scheduledEnd,_that.symptomText,_that.inputMode,_that.symptomLanguage,_that.intakeStatus,_that.discussedCaseUid,_that.discussedOrderNumber,_that.caseUids,_that.expiresAt,_that.respondedAt,_that.acceptedAt,_that.declineReason,_that.declineNote,_that.cancelledAt,_that.cancelledByUid,_that.cancelNote,_that.completedAt,_that.createdAt,_that.lastUpdatedAt,_that.synced);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppointmentModel extends AppointmentModel {
  const _AppointmentModel({@JsonKey(name: 'uid') this.uid = '', @JsonKey(name: 'type') this.type = 'Consultation', @JsonKey(name: 'status') this.status = 'Requested', @JsonKey(name: 'patientUid') this.patientUid = '', @JsonKey(name: 'patientId') this.patientId = '', @JsonKey(name: 'patientName') this.patientName = '', @JsonKey(name: 'doctorUid') this.doctorUid = '', @JsonKey(name: 'doctorName') this.doctorName = '', @JsonKey(name: 'facilityName') this.facilityName = '', @JsonKey(name: 'createdByUid') this.createdByUid = '', @JsonKey(name: 'scheduledStart') this.scheduledStart = '', @JsonKey(name: 'scheduledEnd') this.scheduledEnd = '', @JsonKey(name: 'symptomText') this.symptomText = '', @JsonKey(name: 'inputMode') this.inputMode = 'Typed', @JsonKey(name: 'symptomLanguage') this.symptomLanguage = '', @JsonKey(name: 'intakeStatus') this.intakeStatus = 'None', @JsonKey(name: 'discussedCaseUid') this.discussedCaseUid = '', @JsonKey(name: 'discussedOrderNumber') this.discussedOrderNumber = '', @JsonKey(name: 'caseUids') final  List<String> caseUids = const <String>[], @JsonKey(name: 'expiresAt') this.expiresAt = '', @JsonKey(name: 'respondedAt') this.respondedAt = '', @JsonKey(name: 'acceptedAt') this.acceptedAt = '', @JsonKey(name: 'declineReason') this.declineReason = '', @JsonKey(name: 'declineNote') this.declineNote = '', @JsonKey(name: 'cancelledAt') this.cancelledAt = '', @JsonKey(name: 'cancelledByUid') this.cancelledByUid = '', @JsonKey(name: 'cancelNote') this.cancelNote = '', @JsonKey(name: 'completedAt') this.completedAt = '', @JsonKey(name: 'createdAt') this.createdAt = '', @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = '', @JsonKey(includeFromJson: false, includeToJson: false) this.synced = true}): _caseUids = caseUids,super._();
  factory _AppointmentModel.fromJson(Map<String, dynamic> json) => _$AppointmentModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'type') final  String type;
@override@JsonKey(name: 'status') final  String status;
@override@JsonKey(name: 'patientUid') final  String patientUid;
@override@JsonKey(name: 'patientId') final  String patientId;
@override@JsonKey(name: 'patientName') final  String patientName;
@override@JsonKey(name: 'doctorUid') final  String doctorUid;
@override@JsonKey(name: 'doctorName') final  String doctorName;
@override@JsonKey(name: 'facilityName') final  String facilityName;
@override@JsonKey(name: 'createdByUid') final  String createdByUid;
@override@JsonKey(name: 'scheduledStart') final  String scheduledStart;
@override@JsonKey(name: 'scheduledEnd') final  String scheduledEnd;
@override@JsonKey(name: 'symptomText') final  String symptomText;
@override@JsonKey(name: 'inputMode') final  String inputMode;
@override@JsonKey(name: 'symptomLanguage') final  String symptomLanguage;
@override@JsonKey(name: 'intakeStatus') final  String intakeStatus;
@override@JsonKey(name: 'discussedCaseUid') final  String discussedCaseUid;
@override@JsonKey(name: 'discussedOrderNumber') final  String discussedOrderNumber;
 final  List<String> _caseUids;
@override@JsonKey(name: 'caseUids') List<String> get caseUids {
  if (_caseUids is EqualUnmodifiableListView) return _caseUids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_caseUids);
}

@override@JsonKey(name: 'expiresAt') final  String expiresAt;
@override@JsonKey(name: 'respondedAt') final  String respondedAt;
@override@JsonKey(name: 'acceptedAt') final  String acceptedAt;
@override@JsonKey(name: 'declineReason') final  String declineReason;
@override@JsonKey(name: 'declineNote') final  String declineNote;
@override@JsonKey(name: 'cancelledAt') final  String cancelledAt;
@override@JsonKey(name: 'cancelledByUid') final  String cancelledByUid;
@override@JsonKey(name: 'cancelNote') final  String cancelNote;
@override@JsonKey(name: 'completedAt') final  String completedAt;
@override@JsonKey(name: 'createdAt') final  String createdAt;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool synced;

/// Create a copy of AppointmentModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppointmentModelCopyWith<_AppointmentModel> get copyWith => __$AppointmentModelCopyWithImpl<_AppointmentModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppointmentModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppointmentModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.patientUid, patientUid) || other.patientUid == patientUid)&&(identical(other.patientId, patientId) || other.patientId == patientId)&&(identical(other.patientName, patientName) || other.patientName == patientName)&&(identical(other.doctorUid, doctorUid) || other.doctorUid == doctorUid)&&(identical(other.doctorName, doctorName) || other.doctorName == doctorName)&&(identical(other.facilityName, facilityName) || other.facilityName == facilityName)&&(identical(other.createdByUid, createdByUid) || other.createdByUid == createdByUid)&&(identical(other.scheduledStart, scheduledStart) || other.scheduledStart == scheduledStart)&&(identical(other.scheduledEnd, scheduledEnd) || other.scheduledEnd == scheduledEnd)&&(identical(other.symptomText, symptomText) || other.symptomText == symptomText)&&(identical(other.inputMode, inputMode) || other.inputMode == inputMode)&&(identical(other.symptomLanguage, symptomLanguage) || other.symptomLanguage == symptomLanguage)&&(identical(other.intakeStatus, intakeStatus) || other.intakeStatus == intakeStatus)&&(identical(other.discussedCaseUid, discussedCaseUid) || other.discussedCaseUid == discussedCaseUid)&&(identical(other.discussedOrderNumber, discussedOrderNumber) || other.discussedOrderNumber == discussedOrderNumber)&&const DeepCollectionEquality().equals(other._caseUids, _caseUids)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.respondedAt, respondedAt) || other.respondedAt == respondedAt)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.declineReason, declineReason) || other.declineReason == declineReason)&&(identical(other.declineNote, declineNote) || other.declineNote == declineNote)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.cancelledByUid, cancelledByUid) || other.cancelledByUid == cancelledByUid)&&(identical(other.cancelNote, cancelNote) || other.cancelNote == cancelNote)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,type,status,patientUid,patientId,patientName,doctorUid,doctorName,facilityName,createdByUid,scheduledStart,scheduledEnd,symptomText,inputMode,symptomLanguage,intakeStatus,discussedCaseUid,discussedOrderNumber,const DeepCollectionEquality().hash(_caseUids),expiresAt,respondedAt,acceptedAt,declineReason,declineNote,cancelledAt,cancelledByUid,cancelNote,completedAt,createdAt,lastUpdatedAt,synced]);

@override
String toString() {
  return 'AppointmentModel(uid: $uid, type: $type, status: $status, patientUid: $patientUid, patientId: $patientId, patientName: $patientName, doctorUid: $doctorUid, doctorName: $doctorName, facilityName: $facilityName, createdByUid: $createdByUid, scheduledStart: $scheduledStart, scheduledEnd: $scheduledEnd, symptomText: $symptomText, inputMode: $inputMode, symptomLanguage: $symptomLanguage, intakeStatus: $intakeStatus, discussedCaseUid: $discussedCaseUid, discussedOrderNumber: $discussedOrderNumber, caseUids: $caseUids, expiresAt: $expiresAt, respondedAt: $respondedAt, acceptedAt: $acceptedAt, declineReason: $declineReason, declineNote: $declineNote, cancelledAt: $cancelledAt, cancelledByUid: $cancelledByUid, cancelNote: $cancelNote, completedAt: $completedAt, createdAt: $createdAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class _$AppointmentModelCopyWith<$Res> implements $AppointmentModelCopyWith<$Res> {
  factory _$AppointmentModelCopyWith(_AppointmentModel value, $Res Function(_AppointmentModel) _then) = __$AppointmentModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'type') String type,@JsonKey(name: 'status') String status,@JsonKey(name: 'patientUid') String patientUid,@JsonKey(name: 'patientId') String patientId,@JsonKey(name: 'patientName') String patientName,@JsonKey(name: 'doctorUid') String doctorUid,@JsonKey(name: 'doctorName') String doctorName,@JsonKey(name: 'facilityName') String facilityName,@JsonKey(name: 'createdByUid') String createdByUid,@JsonKey(name: 'scheduledStart') String scheduledStart,@JsonKey(name: 'scheduledEnd') String scheduledEnd,@JsonKey(name: 'symptomText') String symptomText,@JsonKey(name: 'inputMode') String inputMode,@JsonKey(name: 'symptomLanguage') String symptomLanguage,@JsonKey(name: 'intakeStatus') String intakeStatus,@JsonKey(name: 'discussedCaseUid') String discussedCaseUid,@JsonKey(name: 'discussedOrderNumber') String discussedOrderNumber,@JsonKey(name: 'caseUids') List<String> caseUids,@JsonKey(name: 'expiresAt') String expiresAt,@JsonKey(name: 'respondedAt') String respondedAt,@JsonKey(name: 'acceptedAt') String acceptedAt,@JsonKey(name: 'declineReason') String declineReason,@JsonKey(name: 'declineNote') String declineNote,@JsonKey(name: 'cancelledAt') String cancelledAt,@JsonKey(name: 'cancelledByUid') String cancelledByUid,@JsonKey(name: 'cancelNote') String cancelNote,@JsonKey(name: 'completedAt') String completedAt,@JsonKey(name: 'createdAt') String createdAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class __$AppointmentModelCopyWithImpl<$Res>
    implements _$AppointmentModelCopyWith<$Res> {
  __$AppointmentModelCopyWithImpl(this._self, this._then);

  final _AppointmentModel _self;
  final $Res Function(_AppointmentModel) _then;

/// Create a copy of AppointmentModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? type = null,Object? status = null,Object? patientUid = null,Object? patientId = null,Object? patientName = null,Object? doctorUid = null,Object? doctorName = null,Object? facilityName = null,Object? createdByUid = null,Object? scheduledStart = null,Object? scheduledEnd = null,Object? symptomText = null,Object? inputMode = null,Object? symptomLanguage = null,Object? intakeStatus = null,Object? discussedCaseUid = null,Object? discussedOrderNumber = null,Object? caseUids = null,Object? expiresAt = null,Object? respondedAt = null,Object? acceptedAt = null,Object? declineReason = null,Object? declineNote = null,Object? cancelledAt = null,Object? cancelledByUid = null,Object? cancelNote = null,Object? completedAt = null,Object? createdAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_AppointmentModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,patientUid: null == patientUid ? _self.patientUid : patientUid // ignore: cast_nullable_to_non_nullable
as String,patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,patientName: null == patientName ? _self.patientName : patientName // ignore: cast_nullable_to_non_nullable
as String,doctorUid: null == doctorUid ? _self.doctorUid : doctorUid // ignore: cast_nullable_to_non_nullable
as String,doctorName: null == doctorName ? _self.doctorName : doctorName // ignore: cast_nullable_to_non_nullable
as String,facilityName: null == facilityName ? _self.facilityName : facilityName // ignore: cast_nullable_to_non_nullable
as String,createdByUid: null == createdByUid ? _self.createdByUid : createdByUid // ignore: cast_nullable_to_non_nullable
as String,scheduledStart: null == scheduledStart ? _self.scheduledStart : scheduledStart // ignore: cast_nullable_to_non_nullable
as String,scheduledEnd: null == scheduledEnd ? _self.scheduledEnd : scheduledEnd // ignore: cast_nullable_to_non_nullable
as String,symptomText: null == symptomText ? _self.symptomText : symptomText // ignore: cast_nullable_to_non_nullable
as String,inputMode: null == inputMode ? _self.inputMode : inputMode // ignore: cast_nullable_to_non_nullable
as String,symptomLanguage: null == symptomLanguage ? _self.symptomLanguage : symptomLanguage // ignore: cast_nullable_to_non_nullable
as String,intakeStatus: null == intakeStatus ? _self.intakeStatus : intakeStatus // ignore: cast_nullable_to_non_nullable
as String,discussedCaseUid: null == discussedCaseUid ? _self.discussedCaseUid : discussedCaseUid // ignore: cast_nullable_to_non_nullable
as String,discussedOrderNumber: null == discussedOrderNumber ? _self.discussedOrderNumber : discussedOrderNumber // ignore: cast_nullable_to_non_nullable
as String,caseUids: null == caseUids ? _self._caseUids : caseUids // ignore: cast_nullable_to_non_nullable
as List<String>,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String,respondedAt: null == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as String,acceptedAt: null == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as String,declineReason: null == declineReason ? _self.declineReason : declineReason // ignore: cast_nullable_to_non_nullable
as String,declineNote: null == declineNote ? _self.declineNote : declineNote // ignore: cast_nullable_to_non_nullable
as String,cancelledAt: null == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as String,cancelledByUid: null == cancelledByUid ? _self.cancelledByUid : cancelledByUid // ignore: cast_nullable_to_non_nullable
as String,cancelNote: null == cancelNote ? _self.cancelNote : cancelNote // ignore: cast_nullable_to_non_nullable
as String,completedAt: null == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
