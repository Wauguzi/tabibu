// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appointment_intake_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppointmentIntakeModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'appointmentUid') String get appointmentUid;@JsonKey(name: 'doctorUid') String get doctorUid;@JsonKey(name: 'status') String get status;@JsonKey(name: 'inputText') String get inputText;@JsonKey(name: 'inputMode') String get inputMode;@JsonKey(name: 'inputLanguage') String get inputLanguage;@JsonKey(name: 'transcriptLanguage') String get transcriptLanguage;@JsonKey(name: 'transcriptAcceptedUnchanged') bool get transcriptAcceptedUnchanged;@JsonKey(name: 'transcriptEditDistance') double get transcriptEditDistance;@JsonKey(name: 'drafts') Map<String, IntakeDraftModel> get drafts;@JsonKey(name: 'modelVersion') String get modelVersion;@JsonKey(name: 'promptVersion') String get promptVersion;@JsonKey(name: 'failureReason') String get failureReason;@JsonKey(name: 'requestedAt') String get requestedAt;@JsonKey(name: 'readyAt') String get readyAt;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;@JsonKey(includeFromJson: false, includeToJson: false) bool get synced;
/// Create a copy of AppointmentIntakeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppointmentIntakeModelCopyWith<AppointmentIntakeModel> get copyWith => _$AppointmentIntakeModelCopyWithImpl<AppointmentIntakeModel>(this as AppointmentIntakeModel, _$identity);

  /// Serializes this AppointmentIntakeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppointmentIntakeModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.appointmentUid, appointmentUid) || other.appointmentUid == appointmentUid)&&(identical(other.doctorUid, doctorUid) || other.doctorUid == doctorUid)&&(identical(other.status, status) || other.status == status)&&(identical(other.inputText, inputText) || other.inputText == inputText)&&(identical(other.inputMode, inputMode) || other.inputMode == inputMode)&&(identical(other.inputLanguage, inputLanguage) || other.inputLanguage == inputLanguage)&&(identical(other.transcriptLanguage, transcriptLanguage) || other.transcriptLanguage == transcriptLanguage)&&(identical(other.transcriptAcceptedUnchanged, transcriptAcceptedUnchanged) || other.transcriptAcceptedUnchanged == transcriptAcceptedUnchanged)&&(identical(other.transcriptEditDistance, transcriptEditDistance) || other.transcriptEditDistance == transcriptEditDistance)&&const DeepCollectionEquality().equals(other.drafts, drafts)&&(identical(other.modelVersion, modelVersion) || other.modelVersion == modelVersion)&&(identical(other.promptVersion, promptVersion) || other.promptVersion == promptVersion)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.readyAt, readyAt) || other.readyAt == readyAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,appointmentUid,doctorUid,status,inputText,inputMode,inputLanguage,transcriptLanguage,transcriptAcceptedUnchanged,transcriptEditDistance,const DeepCollectionEquality().hash(drafts),modelVersion,promptVersion,failureReason,requestedAt,readyAt,lastUpdatedAt,synced);

@override
String toString() {
  return 'AppointmentIntakeModel(uid: $uid, appointmentUid: $appointmentUid, doctorUid: $doctorUid, status: $status, inputText: $inputText, inputMode: $inputMode, inputLanguage: $inputLanguage, transcriptLanguage: $transcriptLanguage, transcriptAcceptedUnchanged: $transcriptAcceptedUnchanged, transcriptEditDistance: $transcriptEditDistance, drafts: $drafts, modelVersion: $modelVersion, promptVersion: $promptVersion, failureReason: $failureReason, requestedAt: $requestedAt, readyAt: $readyAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class $AppointmentIntakeModelCopyWith<$Res>  {
  factory $AppointmentIntakeModelCopyWith(AppointmentIntakeModel value, $Res Function(AppointmentIntakeModel) _then) = _$AppointmentIntakeModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'appointmentUid') String appointmentUid,@JsonKey(name: 'doctorUid') String doctorUid,@JsonKey(name: 'status') String status,@JsonKey(name: 'inputText') String inputText,@JsonKey(name: 'inputMode') String inputMode,@JsonKey(name: 'inputLanguage') String inputLanguage,@JsonKey(name: 'transcriptLanguage') String transcriptLanguage,@JsonKey(name: 'transcriptAcceptedUnchanged') bool transcriptAcceptedUnchanged,@JsonKey(name: 'transcriptEditDistance') double transcriptEditDistance,@JsonKey(name: 'drafts') Map<String, IntakeDraftModel> drafts,@JsonKey(name: 'modelVersion') String modelVersion,@JsonKey(name: 'promptVersion') String promptVersion,@JsonKey(name: 'failureReason') String failureReason,@JsonKey(name: 'requestedAt') String requestedAt,@JsonKey(name: 'readyAt') String readyAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class _$AppointmentIntakeModelCopyWithImpl<$Res>
    implements $AppointmentIntakeModelCopyWith<$Res> {
  _$AppointmentIntakeModelCopyWithImpl(this._self, this._then);

  final AppointmentIntakeModel _self;
  final $Res Function(AppointmentIntakeModel) _then;

/// Create a copy of AppointmentIntakeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? appointmentUid = null,Object? doctorUid = null,Object? status = null,Object? inputText = null,Object? inputMode = null,Object? inputLanguage = null,Object? transcriptLanguage = null,Object? transcriptAcceptedUnchanged = null,Object? transcriptEditDistance = null,Object? drafts = null,Object? modelVersion = null,Object? promptVersion = null,Object? failureReason = null,Object? requestedAt = null,Object? readyAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,appointmentUid: null == appointmentUid ? _self.appointmentUid : appointmentUid // ignore: cast_nullable_to_non_nullable
as String,doctorUid: null == doctorUid ? _self.doctorUid : doctorUid // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,inputText: null == inputText ? _self.inputText : inputText // ignore: cast_nullable_to_non_nullable
as String,inputMode: null == inputMode ? _self.inputMode : inputMode // ignore: cast_nullable_to_non_nullable
as String,inputLanguage: null == inputLanguage ? _self.inputLanguage : inputLanguage // ignore: cast_nullable_to_non_nullable
as String,transcriptLanguage: null == transcriptLanguage ? _self.transcriptLanguage : transcriptLanguage // ignore: cast_nullable_to_non_nullable
as String,transcriptAcceptedUnchanged: null == transcriptAcceptedUnchanged ? _self.transcriptAcceptedUnchanged : transcriptAcceptedUnchanged // ignore: cast_nullable_to_non_nullable
as bool,transcriptEditDistance: null == transcriptEditDistance ? _self.transcriptEditDistance : transcriptEditDistance // ignore: cast_nullable_to_non_nullable
as double,drafts: null == drafts ? _self.drafts : drafts // ignore: cast_nullable_to_non_nullable
as Map<String, IntakeDraftModel>,modelVersion: null == modelVersion ? _self.modelVersion : modelVersion // ignore: cast_nullable_to_non_nullable
as String,promptVersion: null == promptVersion ? _self.promptVersion : promptVersion // ignore: cast_nullable_to_non_nullable
as String,failureReason: null == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as String,readyAt: null == readyAt ? _self.readyAt : readyAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppointmentIntakeModel].
extension AppointmentIntakeModelPatterns on AppointmentIntakeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppointmentIntakeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppointmentIntakeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppointmentIntakeModel value)  $default,){
final _that = this;
switch (_that) {
case _AppointmentIntakeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppointmentIntakeModel value)?  $default,){
final _that = this;
switch (_that) {
case _AppointmentIntakeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'appointmentUid')  String appointmentUid, @JsonKey(name: 'doctorUid')  String doctorUid, @JsonKey(name: 'status')  String status, @JsonKey(name: 'inputText')  String inputText, @JsonKey(name: 'inputMode')  String inputMode, @JsonKey(name: 'inputLanguage')  String inputLanguage, @JsonKey(name: 'transcriptLanguage')  String transcriptLanguage, @JsonKey(name: 'transcriptAcceptedUnchanged')  bool transcriptAcceptedUnchanged, @JsonKey(name: 'transcriptEditDistance')  double transcriptEditDistance, @JsonKey(name: 'drafts')  Map<String, IntakeDraftModel> drafts, @JsonKey(name: 'modelVersion')  String modelVersion, @JsonKey(name: 'promptVersion')  String promptVersion, @JsonKey(name: 'failureReason')  String failureReason, @JsonKey(name: 'requestedAt')  String requestedAt, @JsonKey(name: 'readyAt')  String readyAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppointmentIntakeModel() when $default != null:
return $default(_that.uid,_that.appointmentUid,_that.doctorUid,_that.status,_that.inputText,_that.inputMode,_that.inputLanguage,_that.transcriptLanguage,_that.transcriptAcceptedUnchanged,_that.transcriptEditDistance,_that.drafts,_that.modelVersion,_that.promptVersion,_that.failureReason,_that.requestedAt,_that.readyAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'appointmentUid')  String appointmentUid, @JsonKey(name: 'doctorUid')  String doctorUid, @JsonKey(name: 'status')  String status, @JsonKey(name: 'inputText')  String inputText, @JsonKey(name: 'inputMode')  String inputMode, @JsonKey(name: 'inputLanguage')  String inputLanguage, @JsonKey(name: 'transcriptLanguage')  String transcriptLanguage, @JsonKey(name: 'transcriptAcceptedUnchanged')  bool transcriptAcceptedUnchanged, @JsonKey(name: 'transcriptEditDistance')  double transcriptEditDistance, @JsonKey(name: 'drafts')  Map<String, IntakeDraftModel> drafts, @JsonKey(name: 'modelVersion')  String modelVersion, @JsonKey(name: 'promptVersion')  String promptVersion, @JsonKey(name: 'failureReason')  String failureReason, @JsonKey(name: 'requestedAt')  String requestedAt, @JsonKey(name: 'readyAt')  String readyAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)  $default,) {final _that = this;
switch (_that) {
case _AppointmentIntakeModel():
return $default(_that.uid,_that.appointmentUid,_that.doctorUid,_that.status,_that.inputText,_that.inputMode,_that.inputLanguage,_that.transcriptLanguage,_that.transcriptAcceptedUnchanged,_that.transcriptEditDistance,_that.drafts,_that.modelVersion,_that.promptVersion,_that.failureReason,_that.requestedAt,_that.readyAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'appointmentUid')  String appointmentUid, @JsonKey(name: 'doctorUid')  String doctorUid, @JsonKey(name: 'status')  String status, @JsonKey(name: 'inputText')  String inputText, @JsonKey(name: 'inputMode')  String inputMode, @JsonKey(name: 'inputLanguage')  String inputLanguage, @JsonKey(name: 'transcriptLanguage')  String transcriptLanguage, @JsonKey(name: 'transcriptAcceptedUnchanged')  bool transcriptAcceptedUnchanged, @JsonKey(name: 'transcriptEditDistance')  double transcriptEditDistance, @JsonKey(name: 'drafts')  Map<String, IntakeDraftModel> drafts, @JsonKey(name: 'modelVersion')  String modelVersion, @JsonKey(name: 'promptVersion')  String promptVersion, @JsonKey(name: 'failureReason')  String failureReason, @JsonKey(name: 'requestedAt')  String requestedAt, @JsonKey(name: 'readyAt')  String readyAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,) {final _that = this;
switch (_that) {
case _AppointmentIntakeModel() when $default != null:
return $default(_that.uid,_that.appointmentUid,_that.doctorUid,_that.status,_that.inputText,_that.inputMode,_that.inputLanguage,_that.transcriptLanguage,_that.transcriptAcceptedUnchanged,_that.transcriptEditDistance,_that.drafts,_that.modelVersion,_that.promptVersion,_that.failureReason,_that.requestedAt,_that.readyAt,_that.lastUpdatedAt,_that.synced);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _AppointmentIntakeModel extends AppointmentIntakeModel {
  const _AppointmentIntakeModel({@JsonKey(name: 'uid') this.uid = 'summary', @JsonKey(name: 'appointmentUid') this.appointmentUid = '', @JsonKey(name: 'doctorUid') this.doctorUid = '', @JsonKey(name: 'status') this.status = 'Queued', @JsonKey(name: 'inputText') this.inputText = '', @JsonKey(name: 'inputMode') this.inputMode = 'Typed', @JsonKey(name: 'inputLanguage') this.inputLanguage = '', @JsonKey(name: 'transcriptLanguage') this.transcriptLanguage = '', @JsonKey(name: 'transcriptAcceptedUnchanged') this.transcriptAcceptedUnchanged = false, @JsonKey(name: 'transcriptEditDistance') this.transcriptEditDistance = 0, @JsonKey(name: 'drafts') final  Map<String, IntakeDraftModel> drafts = const <String, IntakeDraftModel>{}, @JsonKey(name: 'modelVersion') this.modelVersion = '', @JsonKey(name: 'promptVersion') this.promptVersion = '', @JsonKey(name: 'failureReason') this.failureReason = '', @JsonKey(name: 'requestedAt') this.requestedAt = '', @JsonKey(name: 'readyAt') this.readyAt = '', @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = '', @JsonKey(includeFromJson: false, includeToJson: false) this.synced = true}): _drafts = drafts,super._();
  factory _AppointmentIntakeModel.fromJson(Map<String, dynamic> json) => _$AppointmentIntakeModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'appointmentUid') final  String appointmentUid;
@override@JsonKey(name: 'doctorUid') final  String doctorUid;
@override@JsonKey(name: 'status') final  String status;
@override@JsonKey(name: 'inputText') final  String inputText;
@override@JsonKey(name: 'inputMode') final  String inputMode;
@override@JsonKey(name: 'inputLanguage') final  String inputLanguage;
@override@JsonKey(name: 'transcriptLanguage') final  String transcriptLanguage;
@override@JsonKey(name: 'transcriptAcceptedUnchanged') final  bool transcriptAcceptedUnchanged;
@override@JsonKey(name: 'transcriptEditDistance') final  double transcriptEditDistance;
 final  Map<String, IntakeDraftModel> _drafts;
@override@JsonKey(name: 'drafts') Map<String, IntakeDraftModel> get drafts {
  if (_drafts is EqualUnmodifiableMapView) return _drafts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_drafts);
}

@override@JsonKey(name: 'modelVersion') final  String modelVersion;
@override@JsonKey(name: 'promptVersion') final  String promptVersion;
@override@JsonKey(name: 'failureReason') final  String failureReason;
@override@JsonKey(name: 'requestedAt') final  String requestedAt;
@override@JsonKey(name: 'readyAt') final  String readyAt;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool synced;

/// Create a copy of AppointmentIntakeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppointmentIntakeModelCopyWith<_AppointmentIntakeModel> get copyWith => __$AppointmentIntakeModelCopyWithImpl<_AppointmentIntakeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppointmentIntakeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppointmentIntakeModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.appointmentUid, appointmentUid) || other.appointmentUid == appointmentUid)&&(identical(other.doctorUid, doctorUid) || other.doctorUid == doctorUid)&&(identical(other.status, status) || other.status == status)&&(identical(other.inputText, inputText) || other.inputText == inputText)&&(identical(other.inputMode, inputMode) || other.inputMode == inputMode)&&(identical(other.inputLanguage, inputLanguage) || other.inputLanguage == inputLanguage)&&(identical(other.transcriptLanguage, transcriptLanguage) || other.transcriptLanguage == transcriptLanguage)&&(identical(other.transcriptAcceptedUnchanged, transcriptAcceptedUnchanged) || other.transcriptAcceptedUnchanged == transcriptAcceptedUnchanged)&&(identical(other.transcriptEditDistance, transcriptEditDistance) || other.transcriptEditDistance == transcriptEditDistance)&&const DeepCollectionEquality().equals(other._drafts, _drafts)&&(identical(other.modelVersion, modelVersion) || other.modelVersion == modelVersion)&&(identical(other.promptVersion, promptVersion) || other.promptVersion == promptVersion)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.readyAt, readyAt) || other.readyAt == readyAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,appointmentUid,doctorUid,status,inputText,inputMode,inputLanguage,transcriptLanguage,transcriptAcceptedUnchanged,transcriptEditDistance,const DeepCollectionEquality().hash(_drafts),modelVersion,promptVersion,failureReason,requestedAt,readyAt,lastUpdatedAt,synced);

@override
String toString() {
  return 'AppointmentIntakeModel(uid: $uid, appointmentUid: $appointmentUid, doctorUid: $doctorUid, status: $status, inputText: $inputText, inputMode: $inputMode, inputLanguage: $inputLanguage, transcriptLanguage: $transcriptLanguage, transcriptAcceptedUnchanged: $transcriptAcceptedUnchanged, transcriptEditDistance: $transcriptEditDistance, drafts: $drafts, modelVersion: $modelVersion, promptVersion: $promptVersion, failureReason: $failureReason, requestedAt: $requestedAt, readyAt: $readyAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class _$AppointmentIntakeModelCopyWith<$Res> implements $AppointmentIntakeModelCopyWith<$Res> {
  factory _$AppointmentIntakeModelCopyWith(_AppointmentIntakeModel value, $Res Function(_AppointmentIntakeModel) _then) = __$AppointmentIntakeModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'appointmentUid') String appointmentUid,@JsonKey(name: 'doctorUid') String doctorUid,@JsonKey(name: 'status') String status,@JsonKey(name: 'inputText') String inputText,@JsonKey(name: 'inputMode') String inputMode,@JsonKey(name: 'inputLanguage') String inputLanguage,@JsonKey(name: 'transcriptLanguage') String transcriptLanguage,@JsonKey(name: 'transcriptAcceptedUnchanged') bool transcriptAcceptedUnchanged,@JsonKey(name: 'transcriptEditDistance') double transcriptEditDistance,@JsonKey(name: 'drafts') Map<String, IntakeDraftModel> drafts,@JsonKey(name: 'modelVersion') String modelVersion,@JsonKey(name: 'promptVersion') String promptVersion,@JsonKey(name: 'failureReason') String failureReason,@JsonKey(name: 'requestedAt') String requestedAt,@JsonKey(name: 'readyAt') String readyAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class __$AppointmentIntakeModelCopyWithImpl<$Res>
    implements _$AppointmentIntakeModelCopyWith<$Res> {
  __$AppointmentIntakeModelCopyWithImpl(this._self, this._then);

  final _AppointmentIntakeModel _self;
  final $Res Function(_AppointmentIntakeModel) _then;

/// Create a copy of AppointmentIntakeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? appointmentUid = null,Object? doctorUid = null,Object? status = null,Object? inputText = null,Object? inputMode = null,Object? inputLanguage = null,Object? transcriptLanguage = null,Object? transcriptAcceptedUnchanged = null,Object? transcriptEditDistance = null,Object? drafts = null,Object? modelVersion = null,Object? promptVersion = null,Object? failureReason = null,Object? requestedAt = null,Object? readyAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_AppointmentIntakeModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,appointmentUid: null == appointmentUid ? _self.appointmentUid : appointmentUid // ignore: cast_nullable_to_non_nullable
as String,doctorUid: null == doctorUid ? _self.doctorUid : doctorUid // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,inputText: null == inputText ? _self.inputText : inputText // ignore: cast_nullable_to_non_nullable
as String,inputMode: null == inputMode ? _self.inputMode : inputMode // ignore: cast_nullable_to_non_nullable
as String,inputLanguage: null == inputLanguage ? _self.inputLanguage : inputLanguage // ignore: cast_nullable_to_non_nullable
as String,transcriptLanguage: null == transcriptLanguage ? _self.transcriptLanguage : transcriptLanguage // ignore: cast_nullable_to_non_nullable
as String,transcriptAcceptedUnchanged: null == transcriptAcceptedUnchanged ? _self.transcriptAcceptedUnchanged : transcriptAcceptedUnchanged // ignore: cast_nullable_to_non_nullable
as bool,transcriptEditDistance: null == transcriptEditDistance ? _self.transcriptEditDistance : transcriptEditDistance // ignore: cast_nullable_to_non_nullable
as double,drafts: null == drafts ? _self._drafts : drafts // ignore: cast_nullable_to_non_nullable
as Map<String, IntakeDraftModel>,modelVersion: null == modelVersion ? _self.modelVersion : modelVersion // ignore: cast_nullable_to_non_nullable
as String,promptVersion: null == promptVersion ? _self.promptVersion : promptVersion // ignore: cast_nullable_to_non_nullable
as String,failureReason: null == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as String,readyAt: null == readyAt ? _self.readyAt : readyAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
