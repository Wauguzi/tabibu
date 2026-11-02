// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_text_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReportTextModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'caseUid') String get caseUid;@JsonKey(name: 'reportUid') String get reportUid;@JsonKey(name: 'reportVersion') int get reportVersion;@JsonKey(name: 'kind') String get kind;@JsonKey(name: 'language') String get language;@JsonKey(name: 'sourceLanguage') String get sourceLanguage;@JsonKey(name: 'detectedSourceLanguage') String get detectedSourceLanguage;@JsonKey(name: 'languageMismatch') bool get languageMismatch;@JsonKey(name: 'sourceSha256') String get sourceSha256;@JsonKey(name: 'status') String get status;@JsonKey(name: 'machineText') Map<String, String> get machineText;@JsonKey(name: 'models') Map<String, String> get models;@JsonKey(name: 'approverUid') String get approverUid;@JsonKey(name: 'requestCount') int get requestCount;@JsonKey(name: 'acceptedUnchanged') bool get acceptedUnchanged;@JsonKey(name: 'editedSegmentKeys') List<String> get editedSegmentKeys;@JsonKey(name: 'editDistance') double get editDistance;@JsonKey(name: 'failureReason') String get failureReason;@JsonKey(name: 'requestedAt') String get requestedAt;@JsonKey(name: 'readyAt') String get readyAt;@JsonKey(name: 'approvedAt') String get approvedAt;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;
/// Create a copy of ReportTextModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportTextModelCopyWith<ReportTextModel> get copyWith => _$ReportTextModelCopyWithImpl<ReportTextModel>(this as ReportTextModel, _$identity);

  /// Serializes this ReportTextModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportTextModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.reportUid, reportUid) || other.reportUid == reportUid)&&(identical(other.reportVersion, reportVersion) || other.reportVersion == reportVersion)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.language, language) || other.language == language)&&(identical(other.sourceLanguage, sourceLanguage) || other.sourceLanguage == sourceLanguage)&&(identical(other.detectedSourceLanguage, detectedSourceLanguage) || other.detectedSourceLanguage == detectedSourceLanguage)&&(identical(other.languageMismatch, languageMismatch) || other.languageMismatch == languageMismatch)&&(identical(other.sourceSha256, sourceSha256) || other.sourceSha256 == sourceSha256)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.machineText, machineText)&&const DeepCollectionEquality().equals(other.models, models)&&(identical(other.approverUid, approverUid) || other.approverUid == approverUid)&&(identical(other.requestCount, requestCount) || other.requestCount == requestCount)&&(identical(other.acceptedUnchanged, acceptedUnchanged) || other.acceptedUnchanged == acceptedUnchanged)&&const DeepCollectionEquality().equals(other.editedSegmentKeys, editedSegmentKeys)&&(identical(other.editDistance, editDistance) || other.editDistance == editDistance)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.readyAt, readyAt) || other.readyAt == readyAt)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,caseUid,reportUid,reportVersion,kind,language,sourceLanguage,detectedSourceLanguage,languageMismatch,sourceSha256,status,const DeepCollectionEquality().hash(machineText),const DeepCollectionEquality().hash(models),approverUid,requestCount,acceptedUnchanged,const DeepCollectionEquality().hash(editedSegmentKeys),editDistance,failureReason,requestedAt,readyAt,approvedAt,lastUpdatedAt]);

@override
String toString() {
  return 'ReportTextModel(uid: $uid, caseUid: $caseUid, reportUid: $reportUid, reportVersion: $reportVersion, kind: $kind, language: $language, sourceLanguage: $sourceLanguage, detectedSourceLanguage: $detectedSourceLanguage, languageMismatch: $languageMismatch, sourceSha256: $sourceSha256, status: $status, machineText: $machineText, models: $models, approverUid: $approverUid, requestCount: $requestCount, acceptedUnchanged: $acceptedUnchanged, editedSegmentKeys: $editedSegmentKeys, editDistance: $editDistance, failureReason: $failureReason, requestedAt: $requestedAt, readyAt: $readyAt, approvedAt: $approvedAt, lastUpdatedAt: $lastUpdatedAt)';
}


}

/// @nodoc
abstract mixin class $ReportTextModelCopyWith<$Res>  {
  factory $ReportTextModelCopyWith(ReportTextModel value, $Res Function(ReportTextModel) _then) = _$ReportTextModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'reportUid') String reportUid,@JsonKey(name: 'reportVersion') int reportVersion,@JsonKey(name: 'kind') String kind,@JsonKey(name: 'language') String language,@JsonKey(name: 'sourceLanguage') String sourceLanguage,@JsonKey(name: 'detectedSourceLanguage') String detectedSourceLanguage,@JsonKey(name: 'languageMismatch') bool languageMismatch,@JsonKey(name: 'sourceSha256') String sourceSha256,@JsonKey(name: 'status') String status,@JsonKey(name: 'machineText') Map<String, String> machineText,@JsonKey(name: 'models') Map<String, String> models,@JsonKey(name: 'approverUid') String approverUid,@JsonKey(name: 'requestCount') int requestCount,@JsonKey(name: 'acceptedUnchanged') bool acceptedUnchanged,@JsonKey(name: 'editedSegmentKeys') List<String> editedSegmentKeys,@JsonKey(name: 'editDistance') double editDistance,@JsonKey(name: 'failureReason') String failureReason,@JsonKey(name: 'requestedAt') String requestedAt,@JsonKey(name: 'readyAt') String readyAt,@JsonKey(name: 'approvedAt') String approvedAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt
});




}
/// @nodoc
class _$ReportTextModelCopyWithImpl<$Res>
    implements $ReportTextModelCopyWith<$Res> {
  _$ReportTextModelCopyWithImpl(this._self, this._then);

  final ReportTextModel _self;
  final $Res Function(ReportTextModel) _then;

/// Create a copy of ReportTextModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? caseUid = null,Object? reportUid = null,Object? reportVersion = null,Object? kind = null,Object? language = null,Object? sourceLanguage = null,Object? detectedSourceLanguage = null,Object? languageMismatch = null,Object? sourceSha256 = null,Object? status = null,Object? machineText = null,Object? models = null,Object? approverUid = null,Object? requestCount = null,Object? acceptedUnchanged = null,Object? editedSegmentKeys = null,Object? editDistance = null,Object? failureReason = null,Object? requestedAt = null,Object? readyAt = null,Object? approvedAt = null,Object? lastUpdatedAt = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,reportUid: null == reportUid ? _self.reportUid : reportUid // ignore: cast_nullable_to_non_nullable
as String,reportVersion: null == reportVersion ? _self.reportVersion : reportVersion // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,sourceLanguage: null == sourceLanguage ? _self.sourceLanguage : sourceLanguage // ignore: cast_nullable_to_non_nullable
as String,detectedSourceLanguage: null == detectedSourceLanguage ? _self.detectedSourceLanguage : detectedSourceLanguage // ignore: cast_nullable_to_non_nullable
as String,languageMismatch: null == languageMismatch ? _self.languageMismatch : languageMismatch // ignore: cast_nullable_to_non_nullable
as bool,sourceSha256: null == sourceSha256 ? _self.sourceSha256 : sourceSha256 // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,machineText: null == machineText ? _self.machineText : machineText // ignore: cast_nullable_to_non_nullable
as Map<String, String>,models: null == models ? _self.models : models // ignore: cast_nullable_to_non_nullable
as Map<String, String>,approverUid: null == approverUid ? _self.approverUid : approverUid // ignore: cast_nullable_to_non_nullable
as String,requestCount: null == requestCount ? _self.requestCount : requestCount // ignore: cast_nullable_to_non_nullable
as int,acceptedUnchanged: null == acceptedUnchanged ? _self.acceptedUnchanged : acceptedUnchanged // ignore: cast_nullable_to_non_nullable
as bool,editedSegmentKeys: null == editedSegmentKeys ? _self.editedSegmentKeys : editedSegmentKeys // ignore: cast_nullable_to_non_nullable
as List<String>,editDistance: null == editDistance ? _self.editDistance : editDistance // ignore: cast_nullable_to_non_nullable
as double,failureReason: null == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as String,readyAt: null == readyAt ? _self.readyAt : readyAt // ignore: cast_nullable_to_non_nullable
as String,approvedAt: null == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportTextModel].
extension ReportTextModelPatterns on ReportTextModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportTextModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportTextModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportTextModel value)  $default,){
final _that = this;
switch (_that) {
case _ReportTextModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportTextModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReportTextModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'reportUid')  String reportUid, @JsonKey(name: 'reportVersion')  int reportVersion, @JsonKey(name: 'kind')  String kind, @JsonKey(name: 'language')  String language, @JsonKey(name: 'sourceLanguage')  String sourceLanguage, @JsonKey(name: 'detectedSourceLanguage')  String detectedSourceLanguage, @JsonKey(name: 'languageMismatch')  bool languageMismatch, @JsonKey(name: 'sourceSha256')  String sourceSha256, @JsonKey(name: 'status')  String status, @JsonKey(name: 'machineText')  Map<String, String> machineText, @JsonKey(name: 'models')  Map<String, String> models, @JsonKey(name: 'approverUid')  String approverUid, @JsonKey(name: 'requestCount')  int requestCount, @JsonKey(name: 'acceptedUnchanged')  bool acceptedUnchanged, @JsonKey(name: 'editedSegmentKeys')  List<String> editedSegmentKeys, @JsonKey(name: 'editDistance')  double editDistance, @JsonKey(name: 'failureReason')  String failureReason, @JsonKey(name: 'requestedAt')  String requestedAt, @JsonKey(name: 'readyAt')  String readyAt, @JsonKey(name: 'approvedAt')  String approvedAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportTextModel() when $default != null:
return $default(_that.uid,_that.caseUid,_that.reportUid,_that.reportVersion,_that.kind,_that.language,_that.sourceLanguage,_that.detectedSourceLanguage,_that.languageMismatch,_that.sourceSha256,_that.status,_that.machineText,_that.models,_that.approverUid,_that.requestCount,_that.acceptedUnchanged,_that.editedSegmentKeys,_that.editDistance,_that.failureReason,_that.requestedAt,_that.readyAt,_that.approvedAt,_that.lastUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'reportUid')  String reportUid, @JsonKey(name: 'reportVersion')  int reportVersion, @JsonKey(name: 'kind')  String kind, @JsonKey(name: 'language')  String language, @JsonKey(name: 'sourceLanguage')  String sourceLanguage, @JsonKey(name: 'detectedSourceLanguage')  String detectedSourceLanguage, @JsonKey(name: 'languageMismatch')  bool languageMismatch, @JsonKey(name: 'sourceSha256')  String sourceSha256, @JsonKey(name: 'status')  String status, @JsonKey(name: 'machineText')  Map<String, String> machineText, @JsonKey(name: 'models')  Map<String, String> models, @JsonKey(name: 'approverUid')  String approverUid, @JsonKey(name: 'requestCount')  int requestCount, @JsonKey(name: 'acceptedUnchanged')  bool acceptedUnchanged, @JsonKey(name: 'editedSegmentKeys')  List<String> editedSegmentKeys, @JsonKey(name: 'editDistance')  double editDistance, @JsonKey(name: 'failureReason')  String failureReason, @JsonKey(name: 'requestedAt')  String requestedAt, @JsonKey(name: 'readyAt')  String readyAt, @JsonKey(name: 'approvedAt')  String approvedAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _ReportTextModel():
return $default(_that.uid,_that.caseUid,_that.reportUid,_that.reportVersion,_that.kind,_that.language,_that.sourceLanguage,_that.detectedSourceLanguage,_that.languageMismatch,_that.sourceSha256,_that.status,_that.machineText,_that.models,_that.approverUid,_that.requestCount,_that.acceptedUnchanged,_that.editedSegmentKeys,_that.editDistance,_that.failureReason,_that.requestedAt,_that.readyAt,_that.approvedAt,_that.lastUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'reportUid')  String reportUid, @JsonKey(name: 'reportVersion')  int reportVersion, @JsonKey(name: 'kind')  String kind, @JsonKey(name: 'language')  String language, @JsonKey(name: 'sourceLanguage')  String sourceLanguage, @JsonKey(name: 'detectedSourceLanguage')  String detectedSourceLanguage, @JsonKey(name: 'languageMismatch')  bool languageMismatch, @JsonKey(name: 'sourceSha256')  String sourceSha256, @JsonKey(name: 'status')  String status, @JsonKey(name: 'machineText')  Map<String, String> machineText, @JsonKey(name: 'models')  Map<String, String> models, @JsonKey(name: 'approverUid')  String approverUid, @JsonKey(name: 'requestCount')  int requestCount, @JsonKey(name: 'acceptedUnchanged')  bool acceptedUnchanged, @JsonKey(name: 'editedSegmentKeys')  List<String> editedSegmentKeys, @JsonKey(name: 'editDistance')  double editDistance, @JsonKey(name: 'failureReason')  String failureReason, @JsonKey(name: 'requestedAt')  String requestedAt, @JsonKey(name: 'readyAt')  String readyAt, @JsonKey(name: 'approvedAt')  String approvedAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ReportTextModel() when $default != null:
return $default(_that.uid,_that.caseUid,_that.reportUid,_that.reportVersion,_that.kind,_that.language,_that.sourceLanguage,_that.detectedSourceLanguage,_that.languageMismatch,_that.sourceSha256,_that.status,_that.machineText,_that.models,_that.approverUid,_that.requestCount,_that.acceptedUnchanged,_that.editedSegmentKeys,_that.editDistance,_that.failureReason,_that.requestedAt,_that.readyAt,_that.approvedAt,_that.lastUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportTextModel extends ReportTextModel {
  const _ReportTextModel({@JsonKey(name: 'uid') this.uid = '', @JsonKey(name: 'caseUid') this.caseUid = '', @JsonKey(name: 'reportUid') this.reportUid = '', @JsonKey(name: 'reportVersion') this.reportVersion = 0, @JsonKey(name: 'kind') this.kind = 'Translation', @JsonKey(name: 'language') this.language = 'sw', @JsonKey(name: 'sourceLanguage') this.sourceLanguage = 'en', @JsonKey(name: 'detectedSourceLanguage') this.detectedSourceLanguage = '', @JsonKey(name: 'languageMismatch') this.languageMismatch = false, @JsonKey(name: 'sourceSha256') this.sourceSha256 = '', @JsonKey(name: 'status') this.status = 'Queued', @JsonKey(name: 'machineText') final  Map<String, String> machineText = const <String, String>{}, @JsonKey(name: 'models') final  Map<String, String> models = const <String, String>{}, @JsonKey(name: 'approverUid') this.approverUid = '', @JsonKey(name: 'requestCount') this.requestCount = 0, @JsonKey(name: 'acceptedUnchanged') this.acceptedUnchanged = false, @JsonKey(name: 'editedSegmentKeys') final  List<String> editedSegmentKeys = const <String>[], @JsonKey(name: 'editDistance') this.editDistance = 0, @JsonKey(name: 'failureReason') this.failureReason = '', @JsonKey(name: 'requestedAt') this.requestedAt = '', @JsonKey(name: 'readyAt') this.readyAt = '', @JsonKey(name: 'approvedAt') this.approvedAt = '', @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = ''}): _machineText = machineText,_models = models,_editedSegmentKeys = editedSegmentKeys,super._();
  factory _ReportTextModel.fromJson(Map<String, dynamic> json) => _$ReportTextModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'caseUid') final  String caseUid;
@override@JsonKey(name: 'reportUid') final  String reportUid;
@override@JsonKey(name: 'reportVersion') final  int reportVersion;
@override@JsonKey(name: 'kind') final  String kind;
@override@JsonKey(name: 'language') final  String language;
@override@JsonKey(name: 'sourceLanguage') final  String sourceLanguage;
@override@JsonKey(name: 'detectedSourceLanguage') final  String detectedSourceLanguage;
@override@JsonKey(name: 'languageMismatch') final  bool languageMismatch;
@override@JsonKey(name: 'sourceSha256') final  String sourceSha256;
@override@JsonKey(name: 'status') final  String status;
 final  Map<String, String> _machineText;
@override@JsonKey(name: 'machineText') Map<String, String> get machineText {
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

@override@JsonKey(name: 'approverUid') final  String approverUid;
@override@JsonKey(name: 'requestCount') final  int requestCount;
@override@JsonKey(name: 'acceptedUnchanged') final  bool acceptedUnchanged;
 final  List<String> _editedSegmentKeys;
@override@JsonKey(name: 'editedSegmentKeys') List<String> get editedSegmentKeys {
  if (_editedSegmentKeys is EqualUnmodifiableListView) return _editedSegmentKeys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_editedSegmentKeys);
}

@override@JsonKey(name: 'editDistance') final  double editDistance;
@override@JsonKey(name: 'failureReason') final  String failureReason;
@override@JsonKey(name: 'requestedAt') final  String requestedAt;
@override@JsonKey(name: 'readyAt') final  String readyAt;
@override@JsonKey(name: 'approvedAt') final  String approvedAt;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;

/// Create a copy of ReportTextModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportTextModelCopyWith<_ReportTextModel> get copyWith => __$ReportTextModelCopyWithImpl<_ReportTextModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportTextModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportTextModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.reportUid, reportUid) || other.reportUid == reportUid)&&(identical(other.reportVersion, reportVersion) || other.reportVersion == reportVersion)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.language, language) || other.language == language)&&(identical(other.sourceLanguage, sourceLanguage) || other.sourceLanguage == sourceLanguage)&&(identical(other.detectedSourceLanguage, detectedSourceLanguage) || other.detectedSourceLanguage == detectedSourceLanguage)&&(identical(other.languageMismatch, languageMismatch) || other.languageMismatch == languageMismatch)&&(identical(other.sourceSha256, sourceSha256) || other.sourceSha256 == sourceSha256)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._machineText, _machineText)&&const DeepCollectionEquality().equals(other._models, _models)&&(identical(other.approverUid, approverUid) || other.approverUid == approverUid)&&(identical(other.requestCount, requestCount) || other.requestCount == requestCount)&&(identical(other.acceptedUnchanged, acceptedUnchanged) || other.acceptedUnchanged == acceptedUnchanged)&&const DeepCollectionEquality().equals(other._editedSegmentKeys, _editedSegmentKeys)&&(identical(other.editDistance, editDistance) || other.editDistance == editDistance)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.readyAt, readyAt) || other.readyAt == readyAt)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,caseUid,reportUid,reportVersion,kind,language,sourceLanguage,detectedSourceLanguage,languageMismatch,sourceSha256,status,const DeepCollectionEquality().hash(_machineText),const DeepCollectionEquality().hash(_models),approverUid,requestCount,acceptedUnchanged,const DeepCollectionEquality().hash(_editedSegmentKeys),editDistance,failureReason,requestedAt,readyAt,approvedAt,lastUpdatedAt]);

@override
String toString() {
  return 'ReportTextModel(uid: $uid, caseUid: $caseUid, reportUid: $reportUid, reportVersion: $reportVersion, kind: $kind, language: $language, sourceLanguage: $sourceLanguage, detectedSourceLanguage: $detectedSourceLanguage, languageMismatch: $languageMismatch, sourceSha256: $sourceSha256, status: $status, machineText: $machineText, models: $models, approverUid: $approverUid, requestCount: $requestCount, acceptedUnchanged: $acceptedUnchanged, editedSegmentKeys: $editedSegmentKeys, editDistance: $editDistance, failureReason: $failureReason, requestedAt: $requestedAt, readyAt: $readyAt, approvedAt: $approvedAt, lastUpdatedAt: $lastUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$ReportTextModelCopyWith<$Res> implements $ReportTextModelCopyWith<$Res> {
  factory _$ReportTextModelCopyWith(_ReportTextModel value, $Res Function(_ReportTextModel) _then) = __$ReportTextModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'reportUid') String reportUid,@JsonKey(name: 'reportVersion') int reportVersion,@JsonKey(name: 'kind') String kind,@JsonKey(name: 'language') String language,@JsonKey(name: 'sourceLanguage') String sourceLanguage,@JsonKey(name: 'detectedSourceLanguage') String detectedSourceLanguage,@JsonKey(name: 'languageMismatch') bool languageMismatch,@JsonKey(name: 'sourceSha256') String sourceSha256,@JsonKey(name: 'status') String status,@JsonKey(name: 'machineText') Map<String, String> machineText,@JsonKey(name: 'models') Map<String, String> models,@JsonKey(name: 'approverUid') String approverUid,@JsonKey(name: 'requestCount') int requestCount,@JsonKey(name: 'acceptedUnchanged') bool acceptedUnchanged,@JsonKey(name: 'editedSegmentKeys') List<String> editedSegmentKeys,@JsonKey(name: 'editDistance') double editDistance,@JsonKey(name: 'failureReason') String failureReason,@JsonKey(name: 'requestedAt') String requestedAt,@JsonKey(name: 'readyAt') String readyAt,@JsonKey(name: 'approvedAt') String approvedAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt
});




}
/// @nodoc
class __$ReportTextModelCopyWithImpl<$Res>
    implements _$ReportTextModelCopyWith<$Res> {
  __$ReportTextModelCopyWithImpl(this._self, this._then);

  final _ReportTextModel _self;
  final $Res Function(_ReportTextModel) _then;

/// Create a copy of ReportTextModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? caseUid = null,Object? reportUid = null,Object? reportVersion = null,Object? kind = null,Object? language = null,Object? sourceLanguage = null,Object? detectedSourceLanguage = null,Object? languageMismatch = null,Object? sourceSha256 = null,Object? status = null,Object? machineText = null,Object? models = null,Object? approverUid = null,Object? requestCount = null,Object? acceptedUnchanged = null,Object? editedSegmentKeys = null,Object? editDistance = null,Object? failureReason = null,Object? requestedAt = null,Object? readyAt = null,Object? approvedAt = null,Object? lastUpdatedAt = null,}) {
  return _then(_ReportTextModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,reportUid: null == reportUid ? _self.reportUid : reportUid // ignore: cast_nullable_to_non_nullable
as String,reportVersion: null == reportVersion ? _self.reportVersion : reportVersion // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,sourceLanguage: null == sourceLanguage ? _self.sourceLanguage : sourceLanguage // ignore: cast_nullable_to_non_nullable
as String,detectedSourceLanguage: null == detectedSourceLanguage ? _self.detectedSourceLanguage : detectedSourceLanguage // ignore: cast_nullable_to_non_nullable
as String,languageMismatch: null == languageMismatch ? _self.languageMismatch : languageMismatch // ignore: cast_nullable_to_non_nullable
as bool,sourceSha256: null == sourceSha256 ? _self.sourceSha256 : sourceSha256 // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,machineText: null == machineText ? _self._machineText : machineText // ignore: cast_nullable_to_non_nullable
as Map<String, String>,models: null == models ? _self._models : models // ignore: cast_nullable_to_non_nullable
as Map<String, String>,approverUid: null == approverUid ? _self.approverUid : approverUid // ignore: cast_nullable_to_non_nullable
as String,requestCount: null == requestCount ? _self.requestCount : requestCount // ignore: cast_nullable_to_non_nullable
as int,acceptedUnchanged: null == acceptedUnchanged ? _self.acceptedUnchanged : acceptedUnchanged // ignore: cast_nullable_to_non_nullable
as bool,editedSegmentKeys: null == editedSegmentKeys ? _self._editedSegmentKeys : editedSegmentKeys // ignore: cast_nullable_to_non_nullable
as List<String>,editDistance: null == editDistance ? _self.editDistance : editDistance // ignore: cast_nullable_to_non_nullable
as double,failureReason: null == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as String,readyAt: null == readyAt ? _self.readyAt : readyAt // ignore: cast_nullable_to_non_nullable
as String,approvedAt: null == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
