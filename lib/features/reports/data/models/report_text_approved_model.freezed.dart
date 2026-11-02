// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_text_approved_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReportTextApprovedModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'caseUid') String get caseUid;@JsonKey(name: 'reportUid') String get reportUid;@JsonKey(name: 'reportVersion') int get reportVersion;@JsonKey(name: 'kind') String get kind;@JsonKey(name: 'language') String get language;@JsonKey(name: 'sourceLanguage') String get sourceLanguage;@JsonKey(name: 'sourceSha256') String get sourceSha256;@JsonKey(name: 'approvedText') Map<String, String> get approvedText;@JsonKey(name: 'approverUid') String get approverUid;@JsonKey(name: 'approverName') String get approverName;@JsonKey(name: 'approvedAt') String get approvedAt;@JsonKey(name: 'acceptedUnchanged') bool get acceptedUnchanged;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;@JsonKey(includeFromJson: false, includeToJson: false) bool get synced;
/// Create a copy of ReportTextApprovedModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportTextApprovedModelCopyWith<ReportTextApprovedModel> get copyWith => _$ReportTextApprovedModelCopyWithImpl<ReportTextApprovedModel>(this as ReportTextApprovedModel, _$identity);

  /// Serializes this ReportTextApprovedModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportTextApprovedModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.reportUid, reportUid) || other.reportUid == reportUid)&&(identical(other.reportVersion, reportVersion) || other.reportVersion == reportVersion)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.language, language) || other.language == language)&&(identical(other.sourceLanguage, sourceLanguage) || other.sourceLanguage == sourceLanguage)&&(identical(other.sourceSha256, sourceSha256) || other.sourceSha256 == sourceSha256)&&const DeepCollectionEquality().equals(other.approvedText, approvedText)&&(identical(other.approverUid, approverUid) || other.approverUid == approverUid)&&(identical(other.approverName, approverName) || other.approverName == approverName)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.acceptedUnchanged, acceptedUnchanged) || other.acceptedUnchanged == acceptedUnchanged)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,caseUid,reportUid,reportVersion,kind,language,sourceLanguage,sourceSha256,const DeepCollectionEquality().hash(approvedText),approverUid,approverName,approvedAt,acceptedUnchanged,lastUpdatedAt,synced);

@override
String toString() {
  return 'ReportTextApprovedModel(uid: $uid, caseUid: $caseUid, reportUid: $reportUid, reportVersion: $reportVersion, kind: $kind, language: $language, sourceLanguage: $sourceLanguage, sourceSha256: $sourceSha256, approvedText: $approvedText, approverUid: $approverUid, approverName: $approverName, approvedAt: $approvedAt, acceptedUnchanged: $acceptedUnchanged, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class $ReportTextApprovedModelCopyWith<$Res>  {
  factory $ReportTextApprovedModelCopyWith(ReportTextApprovedModel value, $Res Function(ReportTextApprovedModel) _then) = _$ReportTextApprovedModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'reportUid') String reportUid,@JsonKey(name: 'reportVersion') int reportVersion,@JsonKey(name: 'kind') String kind,@JsonKey(name: 'language') String language,@JsonKey(name: 'sourceLanguage') String sourceLanguage,@JsonKey(name: 'sourceSha256') String sourceSha256,@JsonKey(name: 'approvedText') Map<String, String> approvedText,@JsonKey(name: 'approverUid') String approverUid,@JsonKey(name: 'approverName') String approverName,@JsonKey(name: 'approvedAt') String approvedAt,@JsonKey(name: 'acceptedUnchanged') bool acceptedUnchanged,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class _$ReportTextApprovedModelCopyWithImpl<$Res>
    implements $ReportTextApprovedModelCopyWith<$Res> {
  _$ReportTextApprovedModelCopyWithImpl(this._self, this._then);

  final ReportTextApprovedModel _self;
  final $Res Function(ReportTextApprovedModel) _then;

/// Create a copy of ReportTextApprovedModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? caseUid = null,Object? reportUid = null,Object? reportVersion = null,Object? kind = null,Object? language = null,Object? sourceLanguage = null,Object? sourceSha256 = null,Object? approvedText = null,Object? approverUid = null,Object? approverName = null,Object? approvedAt = null,Object? acceptedUnchanged = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,reportUid: null == reportUid ? _self.reportUid : reportUid // ignore: cast_nullable_to_non_nullable
as String,reportVersion: null == reportVersion ? _self.reportVersion : reportVersion // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,sourceLanguage: null == sourceLanguage ? _self.sourceLanguage : sourceLanguage // ignore: cast_nullable_to_non_nullable
as String,sourceSha256: null == sourceSha256 ? _self.sourceSha256 : sourceSha256 // ignore: cast_nullable_to_non_nullable
as String,approvedText: null == approvedText ? _self.approvedText : approvedText // ignore: cast_nullable_to_non_nullable
as Map<String, String>,approverUid: null == approverUid ? _self.approverUid : approverUid // ignore: cast_nullable_to_non_nullable
as String,approverName: null == approverName ? _self.approverName : approverName // ignore: cast_nullable_to_non_nullable
as String,approvedAt: null == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as String,acceptedUnchanged: null == acceptedUnchanged ? _self.acceptedUnchanged : acceptedUnchanged // ignore: cast_nullable_to_non_nullable
as bool,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportTextApprovedModel].
extension ReportTextApprovedModelPatterns on ReportTextApprovedModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportTextApprovedModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportTextApprovedModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportTextApprovedModel value)  $default,){
final _that = this;
switch (_that) {
case _ReportTextApprovedModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportTextApprovedModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReportTextApprovedModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'reportUid')  String reportUid, @JsonKey(name: 'reportVersion')  int reportVersion, @JsonKey(name: 'kind')  String kind, @JsonKey(name: 'language')  String language, @JsonKey(name: 'sourceLanguage')  String sourceLanguage, @JsonKey(name: 'sourceSha256')  String sourceSha256, @JsonKey(name: 'approvedText')  Map<String, String> approvedText, @JsonKey(name: 'approverUid')  String approverUid, @JsonKey(name: 'approverName')  String approverName, @JsonKey(name: 'approvedAt')  String approvedAt, @JsonKey(name: 'acceptedUnchanged')  bool acceptedUnchanged, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportTextApprovedModel() when $default != null:
return $default(_that.uid,_that.caseUid,_that.reportUid,_that.reportVersion,_that.kind,_that.language,_that.sourceLanguage,_that.sourceSha256,_that.approvedText,_that.approverUid,_that.approverName,_that.approvedAt,_that.acceptedUnchanged,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'reportUid')  String reportUid, @JsonKey(name: 'reportVersion')  int reportVersion, @JsonKey(name: 'kind')  String kind, @JsonKey(name: 'language')  String language, @JsonKey(name: 'sourceLanguage')  String sourceLanguage, @JsonKey(name: 'sourceSha256')  String sourceSha256, @JsonKey(name: 'approvedText')  Map<String, String> approvedText, @JsonKey(name: 'approverUid')  String approverUid, @JsonKey(name: 'approverName')  String approverName, @JsonKey(name: 'approvedAt')  String approvedAt, @JsonKey(name: 'acceptedUnchanged')  bool acceptedUnchanged, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)  $default,) {final _that = this;
switch (_that) {
case _ReportTextApprovedModel():
return $default(_that.uid,_that.caseUid,_that.reportUid,_that.reportVersion,_that.kind,_that.language,_that.sourceLanguage,_that.sourceSha256,_that.approvedText,_that.approverUid,_that.approverName,_that.approvedAt,_that.acceptedUnchanged,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'reportUid')  String reportUid, @JsonKey(name: 'reportVersion')  int reportVersion, @JsonKey(name: 'kind')  String kind, @JsonKey(name: 'language')  String language, @JsonKey(name: 'sourceLanguage')  String sourceLanguage, @JsonKey(name: 'sourceSha256')  String sourceSha256, @JsonKey(name: 'approvedText')  Map<String, String> approvedText, @JsonKey(name: 'approverUid')  String approverUid, @JsonKey(name: 'approverName')  String approverName, @JsonKey(name: 'approvedAt')  String approvedAt, @JsonKey(name: 'acceptedUnchanged')  bool acceptedUnchanged, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,) {final _that = this;
switch (_that) {
case _ReportTextApprovedModel() when $default != null:
return $default(_that.uid,_that.caseUid,_that.reportUid,_that.reportVersion,_that.kind,_that.language,_that.sourceLanguage,_that.sourceSha256,_that.approvedText,_that.approverUid,_that.approverName,_that.approvedAt,_that.acceptedUnchanged,_that.lastUpdatedAt,_that.synced);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportTextApprovedModel extends ReportTextApprovedModel {
  const _ReportTextApprovedModel({@JsonKey(name: 'uid') this.uid = '', @JsonKey(name: 'caseUid') this.caseUid = '', @JsonKey(name: 'reportUid') this.reportUid = '', @JsonKey(name: 'reportVersion') this.reportVersion = 0, @JsonKey(name: 'kind') this.kind = '', @JsonKey(name: 'language') this.language = '', @JsonKey(name: 'sourceLanguage') this.sourceLanguage = '', @JsonKey(name: 'sourceSha256') this.sourceSha256 = '', @JsonKey(name: 'approvedText') final  Map<String, String> approvedText = const <String, String>{}, @JsonKey(name: 'approverUid') this.approverUid = '', @JsonKey(name: 'approverName') this.approverName = '', @JsonKey(name: 'approvedAt') this.approvedAt = '', @JsonKey(name: 'acceptedUnchanged') this.acceptedUnchanged = false, @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = '', @JsonKey(includeFromJson: false, includeToJson: false) this.synced = true}): _approvedText = approvedText,super._();
  factory _ReportTextApprovedModel.fromJson(Map<String, dynamic> json) => _$ReportTextApprovedModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'caseUid') final  String caseUid;
@override@JsonKey(name: 'reportUid') final  String reportUid;
@override@JsonKey(name: 'reportVersion') final  int reportVersion;
@override@JsonKey(name: 'kind') final  String kind;
@override@JsonKey(name: 'language') final  String language;
@override@JsonKey(name: 'sourceLanguage') final  String sourceLanguage;
@override@JsonKey(name: 'sourceSha256') final  String sourceSha256;
 final  Map<String, String> _approvedText;
@override@JsonKey(name: 'approvedText') Map<String, String> get approvedText {
  if (_approvedText is EqualUnmodifiableMapView) return _approvedText;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_approvedText);
}

@override@JsonKey(name: 'approverUid') final  String approverUid;
@override@JsonKey(name: 'approverName') final  String approverName;
@override@JsonKey(name: 'approvedAt') final  String approvedAt;
@override@JsonKey(name: 'acceptedUnchanged') final  bool acceptedUnchanged;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool synced;

/// Create a copy of ReportTextApprovedModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportTextApprovedModelCopyWith<_ReportTextApprovedModel> get copyWith => __$ReportTextApprovedModelCopyWithImpl<_ReportTextApprovedModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportTextApprovedModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportTextApprovedModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.reportUid, reportUid) || other.reportUid == reportUid)&&(identical(other.reportVersion, reportVersion) || other.reportVersion == reportVersion)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.language, language) || other.language == language)&&(identical(other.sourceLanguage, sourceLanguage) || other.sourceLanguage == sourceLanguage)&&(identical(other.sourceSha256, sourceSha256) || other.sourceSha256 == sourceSha256)&&const DeepCollectionEquality().equals(other._approvedText, _approvedText)&&(identical(other.approverUid, approverUid) || other.approverUid == approverUid)&&(identical(other.approverName, approverName) || other.approverName == approverName)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.acceptedUnchanged, acceptedUnchanged) || other.acceptedUnchanged == acceptedUnchanged)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,caseUid,reportUid,reportVersion,kind,language,sourceLanguage,sourceSha256,const DeepCollectionEquality().hash(_approvedText),approverUid,approverName,approvedAt,acceptedUnchanged,lastUpdatedAt,synced);

@override
String toString() {
  return 'ReportTextApprovedModel(uid: $uid, caseUid: $caseUid, reportUid: $reportUid, reportVersion: $reportVersion, kind: $kind, language: $language, sourceLanguage: $sourceLanguage, sourceSha256: $sourceSha256, approvedText: $approvedText, approverUid: $approverUid, approverName: $approverName, approvedAt: $approvedAt, acceptedUnchanged: $acceptedUnchanged, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class _$ReportTextApprovedModelCopyWith<$Res> implements $ReportTextApprovedModelCopyWith<$Res> {
  factory _$ReportTextApprovedModelCopyWith(_ReportTextApprovedModel value, $Res Function(_ReportTextApprovedModel) _then) = __$ReportTextApprovedModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'reportUid') String reportUid,@JsonKey(name: 'reportVersion') int reportVersion,@JsonKey(name: 'kind') String kind,@JsonKey(name: 'language') String language,@JsonKey(name: 'sourceLanguage') String sourceLanguage,@JsonKey(name: 'sourceSha256') String sourceSha256,@JsonKey(name: 'approvedText') Map<String, String> approvedText,@JsonKey(name: 'approverUid') String approverUid,@JsonKey(name: 'approverName') String approverName,@JsonKey(name: 'approvedAt') String approvedAt,@JsonKey(name: 'acceptedUnchanged') bool acceptedUnchanged,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class __$ReportTextApprovedModelCopyWithImpl<$Res>
    implements _$ReportTextApprovedModelCopyWith<$Res> {
  __$ReportTextApprovedModelCopyWithImpl(this._self, this._then);

  final _ReportTextApprovedModel _self;
  final $Res Function(_ReportTextApprovedModel) _then;

/// Create a copy of ReportTextApprovedModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? caseUid = null,Object? reportUid = null,Object? reportVersion = null,Object? kind = null,Object? language = null,Object? sourceLanguage = null,Object? sourceSha256 = null,Object? approvedText = null,Object? approverUid = null,Object? approverName = null,Object? approvedAt = null,Object? acceptedUnchanged = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_ReportTextApprovedModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,reportUid: null == reportUid ? _self.reportUid : reportUid // ignore: cast_nullable_to_non_nullable
as String,reportVersion: null == reportVersion ? _self.reportVersion : reportVersion // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,sourceLanguage: null == sourceLanguage ? _self.sourceLanguage : sourceLanguage // ignore: cast_nullable_to_non_nullable
as String,sourceSha256: null == sourceSha256 ? _self.sourceSha256 : sourceSha256 // ignore: cast_nullable_to_non_nullable
as String,approvedText: null == approvedText ? _self._approvedText : approvedText // ignore: cast_nullable_to_non_nullable
as Map<String, String>,approverUid: null == approverUid ? _self.approverUid : approverUid // ignore: cast_nullable_to_non_nullable
as String,approverName: null == approverName ? _self.approverName : approverName // ignore: cast_nullable_to_non_nullable
as String,approvedAt: null == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as String,acceptedUnchanged: null == acceptedUnchanged ? _self.acceptedUnchanged : acceptedUnchanged // ignore: cast_nullable_to_non_nullable
as bool,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
