// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notifiable_disease_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotifiableDiseaseModel {

@JsonKey(name: 'diseaseId') String get diseaseId;@JsonKey(name: 'nameEn') String get nameEn;@JsonKey(name: 'nameSw') String get nameSw;@JsonKey(name: 'ihrStatus') String get ihrStatus;@JsonKey(name: 'reportingCategory') String get reportingCategory;@JsonKey(name: 'kenyaGroup') String get kenyaGroup;@JsonKey(name: 'categorySourceId') String get categorySourceId;@JsonKey(name: 'categoryVerified') bool get categoryVerified;@JsonKey(name: 'caseDefinitionEn') String get caseDefinitionEn;@JsonKey(name: 'caseDefinitionSw') String get caseDefinitionSw;@JsonKey(name: 'labTests') List<NotifiableLabTestModel> get labTests;@JsonKey(name: 'publicAlertEligible') bool get publicAlertEligible;@JsonKey(name: 'allowManualAlert') bool get allowManualAlert;@JsonKey(name: 'preReadHint') String get preReadHint;@JsonKey(name: 'sourceIds') List<String> get sourceIds;
/// Create a copy of NotifiableDiseaseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotifiableDiseaseModelCopyWith<NotifiableDiseaseModel> get copyWith => _$NotifiableDiseaseModelCopyWithImpl<NotifiableDiseaseModel>(this as NotifiableDiseaseModel, _$identity);

  /// Serializes this NotifiableDiseaseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotifiableDiseaseModel&&(identical(other.diseaseId, diseaseId) || other.diseaseId == diseaseId)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.nameSw, nameSw) || other.nameSw == nameSw)&&(identical(other.ihrStatus, ihrStatus) || other.ihrStatus == ihrStatus)&&(identical(other.reportingCategory, reportingCategory) || other.reportingCategory == reportingCategory)&&(identical(other.kenyaGroup, kenyaGroup) || other.kenyaGroup == kenyaGroup)&&(identical(other.categorySourceId, categorySourceId) || other.categorySourceId == categorySourceId)&&(identical(other.categoryVerified, categoryVerified) || other.categoryVerified == categoryVerified)&&(identical(other.caseDefinitionEn, caseDefinitionEn) || other.caseDefinitionEn == caseDefinitionEn)&&(identical(other.caseDefinitionSw, caseDefinitionSw) || other.caseDefinitionSw == caseDefinitionSw)&&const DeepCollectionEquality().equals(other.labTests, labTests)&&(identical(other.publicAlertEligible, publicAlertEligible) || other.publicAlertEligible == publicAlertEligible)&&(identical(other.allowManualAlert, allowManualAlert) || other.allowManualAlert == allowManualAlert)&&(identical(other.preReadHint, preReadHint) || other.preReadHint == preReadHint)&&const DeepCollectionEquality().equals(other.sourceIds, sourceIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,diseaseId,nameEn,nameSw,ihrStatus,reportingCategory,kenyaGroup,categorySourceId,categoryVerified,caseDefinitionEn,caseDefinitionSw,const DeepCollectionEquality().hash(labTests),publicAlertEligible,allowManualAlert,preReadHint,const DeepCollectionEquality().hash(sourceIds));

@override
String toString() {
  return 'NotifiableDiseaseModel(diseaseId: $diseaseId, nameEn: $nameEn, nameSw: $nameSw, ihrStatus: $ihrStatus, reportingCategory: $reportingCategory, kenyaGroup: $kenyaGroup, categorySourceId: $categorySourceId, categoryVerified: $categoryVerified, caseDefinitionEn: $caseDefinitionEn, caseDefinitionSw: $caseDefinitionSw, labTests: $labTests, publicAlertEligible: $publicAlertEligible, allowManualAlert: $allowManualAlert, preReadHint: $preReadHint, sourceIds: $sourceIds)';
}


}

/// @nodoc
abstract mixin class $NotifiableDiseaseModelCopyWith<$Res>  {
  factory $NotifiableDiseaseModelCopyWith(NotifiableDiseaseModel value, $Res Function(NotifiableDiseaseModel) _then) = _$NotifiableDiseaseModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'diseaseId') String diseaseId,@JsonKey(name: 'nameEn') String nameEn,@JsonKey(name: 'nameSw') String nameSw,@JsonKey(name: 'ihrStatus') String ihrStatus,@JsonKey(name: 'reportingCategory') String reportingCategory,@JsonKey(name: 'kenyaGroup') String kenyaGroup,@JsonKey(name: 'categorySourceId') String categorySourceId,@JsonKey(name: 'categoryVerified') bool categoryVerified,@JsonKey(name: 'caseDefinitionEn') String caseDefinitionEn,@JsonKey(name: 'caseDefinitionSw') String caseDefinitionSw,@JsonKey(name: 'labTests') List<NotifiableLabTestModel> labTests,@JsonKey(name: 'publicAlertEligible') bool publicAlertEligible,@JsonKey(name: 'allowManualAlert') bool allowManualAlert,@JsonKey(name: 'preReadHint') String preReadHint,@JsonKey(name: 'sourceIds') List<String> sourceIds
});




}
/// @nodoc
class _$NotifiableDiseaseModelCopyWithImpl<$Res>
    implements $NotifiableDiseaseModelCopyWith<$Res> {
  _$NotifiableDiseaseModelCopyWithImpl(this._self, this._then);

  final NotifiableDiseaseModel _self;
  final $Res Function(NotifiableDiseaseModel) _then;

/// Create a copy of NotifiableDiseaseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? diseaseId = null,Object? nameEn = null,Object? nameSw = null,Object? ihrStatus = null,Object? reportingCategory = null,Object? kenyaGroup = null,Object? categorySourceId = null,Object? categoryVerified = null,Object? caseDefinitionEn = null,Object? caseDefinitionSw = null,Object? labTests = null,Object? publicAlertEligible = null,Object? allowManualAlert = null,Object? preReadHint = null,Object? sourceIds = null,}) {
  return _then(_self.copyWith(
diseaseId: null == diseaseId ? _self.diseaseId : diseaseId // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,nameSw: null == nameSw ? _self.nameSw : nameSw // ignore: cast_nullable_to_non_nullable
as String,ihrStatus: null == ihrStatus ? _self.ihrStatus : ihrStatus // ignore: cast_nullable_to_non_nullable
as String,reportingCategory: null == reportingCategory ? _self.reportingCategory : reportingCategory // ignore: cast_nullable_to_non_nullable
as String,kenyaGroup: null == kenyaGroup ? _self.kenyaGroup : kenyaGroup // ignore: cast_nullable_to_non_nullable
as String,categorySourceId: null == categorySourceId ? _self.categorySourceId : categorySourceId // ignore: cast_nullable_to_non_nullable
as String,categoryVerified: null == categoryVerified ? _self.categoryVerified : categoryVerified // ignore: cast_nullable_to_non_nullable
as bool,caseDefinitionEn: null == caseDefinitionEn ? _self.caseDefinitionEn : caseDefinitionEn // ignore: cast_nullable_to_non_nullable
as String,caseDefinitionSw: null == caseDefinitionSw ? _self.caseDefinitionSw : caseDefinitionSw // ignore: cast_nullable_to_non_nullable
as String,labTests: null == labTests ? _self.labTests : labTests // ignore: cast_nullable_to_non_nullable
as List<NotifiableLabTestModel>,publicAlertEligible: null == publicAlertEligible ? _self.publicAlertEligible : publicAlertEligible // ignore: cast_nullable_to_non_nullable
as bool,allowManualAlert: null == allowManualAlert ? _self.allowManualAlert : allowManualAlert // ignore: cast_nullable_to_non_nullable
as bool,preReadHint: null == preReadHint ? _self.preReadHint : preReadHint // ignore: cast_nullable_to_non_nullable
as String,sourceIds: null == sourceIds ? _self.sourceIds : sourceIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [NotifiableDiseaseModel].
extension NotifiableDiseaseModelPatterns on NotifiableDiseaseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotifiableDiseaseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotifiableDiseaseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotifiableDiseaseModel value)  $default,){
final _that = this;
switch (_that) {
case _NotifiableDiseaseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotifiableDiseaseModel value)?  $default,){
final _that = this;
switch (_that) {
case _NotifiableDiseaseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'diseaseId')  String diseaseId, @JsonKey(name: 'nameEn')  String nameEn, @JsonKey(name: 'nameSw')  String nameSw, @JsonKey(name: 'ihrStatus')  String ihrStatus, @JsonKey(name: 'reportingCategory')  String reportingCategory, @JsonKey(name: 'kenyaGroup')  String kenyaGroup, @JsonKey(name: 'categorySourceId')  String categorySourceId, @JsonKey(name: 'categoryVerified')  bool categoryVerified, @JsonKey(name: 'caseDefinitionEn')  String caseDefinitionEn, @JsonKey(name: 'caseDefinitionSw')  String caseDefinitionSw, @JsonKey(name: 'labTests')  List<NotifiableLabTestModel> labTests, @JsonKey(name: 'publicAlertEligible')  bool publicAlertEligible, @JsonKey(name: 'allowManualAlert')  bool allowManualAlert, @JsonKey(name: 'preReadHint')  String preReadHint, @JsonKey(name: 'sourceIds')  List<String> sourceIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotifiableDiseaseModel() when $default != null:
return $default(_that.diseaseId,_that.nameEn,_that.nameSw,_that.ihrStatus,_that.reportingCategory,_that.kenyaGroup,_that.categorySourceId,_that.categoryVerified,_that.caseDefinitionEn,_that.caseDefinitionSw,_that.labTests,_that.publicAlertEligible,_that.allowManualAlert,_that.preReadHint,_that.sourceIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'diseaseId')  String diseaseId, @JsonKey(name: 'nameEn')  String nameEn, @JsonKey(name: 'nameSw')  String nameSw, @JsonKey(name: 'ihrStatus')  String ihrStatus, @JsonKey(name: 'reportingCategory')  String reportingCategory, @JsonKey(name: 'kenyaGroup')  String kenyaGroup, @JsonKey(name: 'categorySourceId')  String categorySourceId, @JsonKey(name: 'categoryVerified')  bool categoryVerified, @JsonKey(name: 'caseDefinitionEn')  String caseDefinitionEn, @JsonKey(name: 'caseDefinitionSw')  String caseDefinitionSw, @JsonKey(name: 'labTests')  List<NotifiableLabTestModel> labTests, @JsonKey(name: 'publicAlertEligible')  bool publicAlertEligible, @JsonKey(name: 'allowManualAlert')  bool allowManualAlert, @JsonKey(name: 'preReadHint')  String preReadHint, @JsonKey(name: 'sourceIds')  List<String> sourceIds)  $default,) {final _that = this;
switch (_that) {
case _NotifiableDiseaseModel():
return $default(_that.diseaseId,_that.nameEn,_that.nameSw,_that.ihrStatus,_that.reportingCategory,_that.kenyaGroup,_that.categorySourceId,_that.categoryVerified,_that.caseDefinitionEn,_that.caseDefinitionSw,_that.labTests,_that.publicAlertEligible,_that.allowManualAlert,_that.preReadHint,_that.sourceIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'diseaseId')  String diseaseId, @JsonKey(name: 'nameEn')  String nameEn, @JsonKey(name: 'nameSw')  String nameSw, @JsonKey(name: 'ihrStatus')  String ihrStatus, @JsonKey(name: 'reportingCategory')  String reportingCategory, @JsonKey(name: 'kenyaGroup')  String kenyaGroup, @JsonKey(name: 'categorySourceId')  String categorySourceId, @JsonKey(name: 'categoryVerified')  bool categoryVerified, @JsonKey(name: 'caseDefinitionEn')  String caseDefinitionEn, @JsonKey(name: 'caseDefinitionSw')  String caseDefinitionSw, @JsonKey(name: 'labTests')  List<NotifiableLabTestModel> labTests, @JsonKey(name: 'publicAlertEligible')  bool publicAlertEligible, @JsonKey(name: 'allowManualAlert')  bool allowManualAlert, @JsonKey(name: 'preReadHint')  String preReadHint, @JsonKey(name: 'sourceIds')  List<String> sourceIds)?  $default,) {final _that = this;
switch (_that) {
case _NotifiableDiseaseModel() when $default != null:
return $default(_that.diseaseId,_that.nameEn,_that.nameSw,_that.ihrStatus,_that.reportingCategory,_that.kenyaGroup,_that.categorySourceId,_that.categoryVerified,_that.caseDefinitionEn,_that.caseDefinitionSw,_that.labTests,_that.publicAlertEligible,_that.allowManualAlert,_that.preReadHint,_that.sourceIds);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _NotifiableDiseaseModel extends NotifiableDiseaseModel {
  const _NotifiableDiseaseModel({@JsonKey(name: 'diseaseId') this.diseaseId = '', @JsonKey(name: 'nameEn') this.nameEn = '', @JsonKey(name: 'nameSw') this.nameSw = '', @JsonKey(name: 'ihrStatus') this.ihrStatus = 'None', @JsonKey(name: 'reportingCategory') this.reportingCategory = 'NotListed', @JsonKey(name: 'kenyaGroup') this.kenyaGroup = 'NotListed', @JsonKey(name: 'categorySourceId') this.categorySourceId = '', @JsonKey(name: 'categoryVerified') this.categoryVerified = false, @JsonKey(name: 'caseDefinitionEn') this.caseDefinitionEn = '', @JsonKey(name: 'caseDefinitionSw') this.caseDefinitionSw = '', @JsonKey(name: 'labTests') final  List<NotifiableLabTestModel> labTests = const <NotifiableLabTestModel>[], @JsonKey(name: 'publicAlertEligible') this.publicAlertEligible = false, @JsonKey(name: 'allowManualAlert') this.allowManualAlert = false, @JsonKey(name: 'preReadHint') this.preReadHint = '', @JsonKey(name: 'sourceIds') final  List<String> sourceIds = const <String>[]}): _labTests = labTests,_sourceIds = sourceIds,super._();
  factory _NotifiableDiseaseModel.fromJson(Map<String, dynamic> json) => _$NotifiableDiseaseModelFromJson(json);

@override@JsonKey(name: 'diseaseId') final  String diseaseId;
@override@JsonKey(name: 'nameEn') final  String nameEn;
@override@JsonKey(name: 'nameSw') final  String nameSw;
@override@JsonKey(name: 'ihrStatus') final  String ihrStatus;
@override@JsonKey(name: 'reportingCategory') final  String reportingCategory;
@override@JsonKey(name: 'kenyaGroup') final  String kenyaGroup;
@override@JsonKey(name: 'categorySourceId') final  String categorySourceId;
@override@JsonKey(name: 'categoryVerified') final  bool categoryVerified;
@override@JsonKey(name: 'caseDefinitionEn') final  String caseDefinitionEn;
@override@JsonKey(name: 'caseDefinitionSw') final  String caseDefinitionSw;
 final  List<NotifiableLabTestModel> _labTests;
@override@JsonKey(name: 'labTests') List<NotifiableLabTestModel> get labTests {
  if (_labTests is EqualUnmodifiableListView) return _labTests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_labTests);
}

@override@JsonKey(name: 'publicAlertEligible') final  bool publicAlertEligible;
@override@JsonKey(name: 'allowManualAlert') final  bool allowManualAlert;
@override@JsonKey(name: 'preReadHint') final  String preReadHint;
 final  List<String> _sourceIds;
@override@JsonKey(name: 'sourceIds') List<String> get sourceIds {
  if (_sourceIds is EqualUnmodifiableListView) return _sourceIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sourceIds);
}


/// Create a copy of NotifiableDiseaseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotifiableDiseaseModelCopyWith<_NotifiableDiseaseModel> get copyWith => __$NotifiableDiseaseModelCopyWithImpl<_NotifiableDiseaseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotifiableDiseaseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotifiableDiseaseModel&&(identical(other.diseaseId, diseaseId) || other.diseaseId == diseaseId)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.nameSw, nameSw) || other.nameSw == nameSw)&&(identical(other.ihrStatus, ihrStatus) || other.ihrStatus == ihrStatus)&&(identical(other.reportingCategory, reportingCategory) || other.reportingCategory == reportingCategory)&&(identical(other.kenyaGroup, kenyaGroup) || other.kenyaGroup == kenyaGroup)&&(identical(other.categorySourceId, categorySourceId) || other.categorySourceId == categorySourceId)&&(identical(other.categoryVerified, categoryVerified) || other.categoryVerified == categoryVerified)&&(identical(other.caseDefinitionEn, caseDefinitionEn) || other.caseDefinitionEn == caseDefinitionEn)&&(identical(other.caseDefinitionSw, caseDefinitionSw) || other.caseDefinitionSw == caseDefinitionSw)&&const DeepCollectionEquality().equals(other._labTests, _labTests)&&(identical(other.publicAlertEligible, publicAlertEligible) || other.publicAlertEligible == publicAlertEligible)&&(identical(other.allowManualAlert, allowManualAlert) || other.allowManualAlert == allowManualAlert)&&(identical(other.preReadHint, preReadHint) || other.preReadHint == preReadHint)&&const DeepCollectionEquality().equals(other._sourceIds, _sourceIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,diseaseId,nameEn,nameSw,ihrStatus,reportingCategory,kenyaGroup,categorySourceId,categoryVerified,caseDefinitionEn,caseDefinitionSw,const DeepCollectionEquality().hash(_labTests),publicAlertEligible,allowManualAlert,preReadHint,const DeepCollectionEquality().hash(_sourceIds));

@override
String toString() {
  return 'NotifiableDiseaseModel(diseaseId: $diseaseId, nameEn: $nameEn, nameSw: $nameSw, ihrStatus: $ihrStatus, reportingCategory: $reportingCategory, kenyaGroup: $kenyaGroup, categorySourceId: $categorySourceId, categoryVerified: $categoryVerified, caseDefinitionEn: $caseDefinitionEn, caseDefinitionSw: $caseDefinitionSw, labTests: $labTests, publicAlertEligible: $publicAlertEligible, allowManualAlert: $allowManualAlert, preReadHint: $preReadHint, sourceIds: $sourceIds)';
}


}

/// @nodoc
abstract mixin class _$NotifiableDiseaseModelCopyWith<$Res> implements $NotifiableDiseaseModelCopyWith<$Res> {
  factory _$NotifiableDiseaseModelCopyWith(_NotifiableDiseaseModel value, $Res Function(_NotifiableDiseaseModel) _then) = __$NotifiableDiseaseModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'diseaseId') String diseaseId,@JsonKey(name: 'nameEn') String nameEn,@JsonKey(name: 'nameSw') String nameSw,@JsonKey(name: 'ihrStatus') String ihrStatus,@JsonKey(name: 'reportingCategory') String reportingCategory,@JsonKey(name: 'kenyaGroup') String kenyaGroup,@JsonKey(name: 'categorySourceId') String categorySourceId,@JsonKey(name: 'categoryVerified') bool categoryVerified,@JsonKey(name: 'caseDefinitionEn') String caseDefinitionEn,@JsonKey(name: 'caseDefinitionSw') String caseDefinitionSw,@JsonKey(name: 'labTests') List<NotifiableLabTestModel> labTests,@JsonKey(name: 'publicAlertEligible') bool publicAlertEligible,@JsonKey(name: 'allowManualAlert') bool allowManualAlert,@JsonKey(name: 'preReadHint') String preReadHint,@JsonKey(name: 'sourceIds') List<String> sourceIds
});




}
/// @nodoc
class __$NotifiableDiseaseModelCopyWithImpl<$Res>
    implements _$NotifiableDiseaseModelCopyWith<$Res> {
  __$NotifiableDiseaseModelCopyWithImpl(this._self, this._then);

  final _NotifiableDiseaseModel _self;
  final $Res Function(_NotifiableDiseaseModel) _then;

/// Create a copy of NotifiableDiseaseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? diseaseId = null,Object? nameEn = null,Object? nameSw = null,Object? ihrStatus = null,Object? reportingCategory = null,Object? kenyaGroup = null,Object? categorySourceId = null,Object? categoryVerified = null,Object? caseDefinitionEn = null,Object? caseDefinitionSw = null,Object? labTests = null,Object? publicAlertEligible = null,Object? allowManualAlert = null,Object? preReadHint = null,Object? sourceIds = null,}) {
  return _then(_NotifiableDiseaseModel(
diseaseId: null == diseaseId ? _self.diseaseId : diseaseId // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,nameSw: null == nameSw ? _self.nameSw : nameSw // ignore: cast_nullable_to_non_nullable
as String,ihrStatus: null == ihrStatus ? _self.ihrStatus : ihrStatus // ignore: cast_nullable_to_non_nullable
as String,reportingCategory: null == reportingCategory ? _self.reportingCategory : reportingCategory // ignore: cast_nullable_to_non_nullable
as String,kenyaGroup: null == kenyaGroup ? _self.kenyaGroup : kenyaGroup // ignore: cast_nullable_to_non_nullable
as String,categorySourceId: null == categorySourceId ? _self.categorySourceId : categorySourceId // ignore: cast_nullable_to_non_nullable
as String,categoryVerified: null == categoryVerified ? _self.categoryVerified : categoryVerified // ignore: cast_nullable_to_non_nullable
as bool,caseDefinitionEn: null == caseDefinitionEn ? _self.caseDefinitionEn : caseDefinitionEn // ignore: cast_nullable_to_non_nullable
as String,caseDefinitionSw: null == caseDefinitionSw ? _self.caseDefinitionSw : caseDefinitionSw // ignore: cast_nullable_to_non_nullable
as String,labTests: null == labTests ? _self._labTests : labTests // ignore: cast_nullable_to_non_nullable
as List<NotifiableLabTestModel>,publicAlertEligible: null == publicAlertEligible ? _self.publicAlertEligible : publicAlertEligible // ignore: cast_nullable_to_non_nullable
as bool,allowManualAlert: null == allowManualAlert ? _self.allowManualAlert : allowManualAlert // ignore: cast_nullable_to_non_nullable
as bool,preReadHint: null == preReadHint ? _self.preReadHint : preReadHint // ignore: cast_nullable_to_non_nullable
as String,sourceIds: null == sourceIds ? _self._sourceIds : sourceIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
