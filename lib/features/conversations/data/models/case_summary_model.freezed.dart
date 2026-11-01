// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'case_summary_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CaseSummaryModel {

@JsonKey(name: 'caseRef') String get caseRef;@JsonKey(name: 'ageBand') String get ageBand;@JsonKey(name: 'sex') String get sex;@JsonKey(name: 'testTypeNames') List<String> get testTypeNames;@JsonKey(name: 'testNames') List<String> get testNames;@JsonKey(name: 'reportStatus') String get reportStatus;@JsonKey(name: 'signedDiagnosisExcerpt') String get signedDiagnosisExcerpt;@JsonKey(name: 'signedAt') String get signedAt;@JsonKey(name: 'signedByName') String get signedByName;@JsonKey(name: 'reportLanguage') String get reportLanguage;@JsonKey(name: 'builtAt') String get builtAt;
/// Create a copy of CaseSummaryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaseSummaryModelCopyWith<CaseSummaryModel> get copyWith => _$CaseSummaryModelCopyWithImpl<CaseSummaryModel>(this as CaseSummaryModel, _$identity);

  /// Serializes this CaseSummaryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaseSummaryModel&&(identical(other.caseRef, caseRef) || other.caseRef == caseRef)&&(identical(other.ageBand, ageBand) || other.ageBand == ageBand)&&(identical(other.sex, sex) || other.sex == sex)&&const DeepCollectionEquality().equals(other.testTypeNames, testTypeNames)&&const DeepCollectionEquality().equals(other.testNames, testNames)&&(identical(other.reportStatus, reportStatus) || other.reportStatus == reportStatus)&&(identical(other.signedDiagnosisExcerpt, signedDiagnosisExcerpt) || other.signedDiagnosisExcerpt == signedDiagnosisExcerpt)&&(identical(other.signedAt, signedAt) || other.signedAt == signedAt)&&(identical(other.signedByName, signedByName) || other.signedByName == signedByName)&&(identical(other.reportLanguage, reportLanguage) || other.reportLanguage == reportLanguage)&&(identical(other.builtAt, builtAt) || other.builtAt == builtAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,caseRef,ageBand,sex,const DeepCollectionEquality().hash(testTypeNames),const DeepCollectionEquality().hash(testNames),reportStatus,signedDiagnosisExcerpt,signedAt,signedByName,reportLanguage,builtAt);

@override
String toString() {
  return 'CaseSummaryModel(caseRef: $caseRef, ageBand: $ageBand, sex: $sex, testTypeNames: $testTypeNames, testNames: $testNames, reportStatus: $reportStatus, signedDiagnosisExcerpt: $signedDiagnosisExcerpt, signedAt: $signedAt, signedByName: $signedByName, reportLanguage: $reportLanguage, builtAt: $builtAt)';
}


}

/// @nodoc
abstract mixin class $CaseSummaryModelCopyWith<$Res>  {
  factory $CaseSummaryModelCopyWith(CaseSummaryModel value, $Res Function(CaseSummaryModel) _then) = _$CaseSummaryModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'caseRef') String caseRef,@JsonKey(name: 'ageBand') String ageBand,@JsonKey(name: 'sex') String sex,@JsonKey(name: 'testTypeNames') List<String> testTypeNames,@JsonKey(name: 'testNames') List<String> testNames,@JsonKey(name: 'reportStatus') String reportStatus,@JsonKey(name: 'signedDiagnosisExcerpt') String signedDiagnosisExcerpt,@JsonKey(name: 'signedAt') String signedAt,@JsonKey(name: 'signedByName') String signedByName,@JsonKey(name: 'reportLanguage') String reportLanguage,@JsonKey(name: 'builtAt') String builtAt
});




}
/// @nodoc
class _$CaseSummaryModelCopyWithImpl<$Res>
    implements $CaseSummaryModelCopyWith<$Res> {
  _$CaseSummaryModelCopyWithImpl(this._self, this._then);

  final CaseSummaryModel _self;
  final $Res Function(CaseSummaryModel) _then;

/// Create a copy of CaseSummaryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? caseRef = null,Object? ageBand = null,Object? sex = null,Object? testTypeNames = null,Object? testNames = null,Object? reportStatus = null,Object? signedDiagnosisExcerpt = null,Object? signedAt = null,Object? signedByName = null,Object? reportLanguage = null,Object? builtAt = null,}) {
  return _then(_self.copyWith(
caseRef: null == caseRef ? _self.caseRef : caseRef // ignore: cast_nullable_to_non_nullable
as String,ageBand: null == ageBand ? _self.ageBand : ageBand // ignore: cast_nullable_to_non_nullable
as String,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as String,testTypeNames: null == testTypeNames ? _self.testTypeNames : testTypeNames // ignore: cast_nullable_to_non_nullable
as List<String>,testNames: null == testNames ? _self.testNames : testNames // ignore: cast_nullable_to_non_nullable
as List<String>,reportStatus: null == reportStatus ? _self.reportStatus : reportStatus // ignore: cast_nullable_to_non_nullable
as String,signedDiagnosisExcerpt: null == signedDiagnosisExcerpt ? _self.signedDiagnosisExcerpt : signedDiagnosisExcerpt // ignore: cast_nullable_to_non_nullable
as String,signedAt: null == signedAt ? _self.signedAt : signedAt // ignore: cast_nullable_to_non_nullable
as String,signedByName: null == signedByName ? _self.signedByName : signedByName // ignore: cast_nullable_to_non_nullable
as String,reportLanguage: null == reportLanguage ? _self.reportLanguage : reportLanguage // ignore: cast_nullable_to_non_nullable
as String,builtAt: null == builtAt ? _self.builtAt : builtAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CaseSummaryModel].
extension CaseSummaryModelPatterns on CaseSummaryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CaseSummaryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CaseSummaryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CaseSummaryModel value)  $default,){
final _that = this;
switch (_that) {
case _CaseSummaryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CaseSummaryModel value)?  $default,){
final _that = this;
switch (_that) {
case _CaseSummaryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'caseRef')  String caseRef, @JsonKey(name: 'ageBand')  String ageBand, @JsonKey(name: 'sex')  String sex, @JsonKey(name: 'testTypeNames')  List<String> testTypeNames, @JsonKey(name: 'testNames')  List<String> testNames, @JsonKey(name: 'reportStatus')  String reportStatus, @JsonKey(name: 'signedDiagnosisExcerpt')  String signedDiagnosisExcerpt, @JsonKey(name: 'signedAt')  String signedAt, @JsonKey(name: 'signedByName')  String signedByName, @JsonKey(name: 'reportLanguage')  String reportLanguage, @JsonKey(name: 'builtAt')  String builtAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CaseSummaryModel() when $default != null:
return $default(_that.caseRef,_that.ageBand,_that.sex,_that.testTypeNames,_that.testNames,_that.reportStatus,_that.signedDiagnosisExcerpt,_that.signedAt,_that.signedByName,_that.reportLanguage,_that.builtAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'caseRef')  String caseRef, @JsonKey(name: 'ageBand')  String ageBand, @JsonKey(name: 'sex')  String sex, @JsonKey(name: 'testTypeNames')  List<String> testTypeNames, @JsonKey(name: 'testNames')  List<String> testNames, @JsonKey(name: 'reportStatus')  String reportStatus, @JsonKey(name: 'signedDiagnosisExcerpt')  String signedDiagnosisExcerpt, @JsonKey(name: 'signedAt')  String signedAt, @JsonKey(name: 'signedByName')  String signedByName, @JsonKey(name: 'reportLanguage')  String reportLanguage, @JsonKey(name: 'builtAt')  String builtAt)  $default,) {final _that = this;
switch (_that) {
case _CaseSummaryModel():
return $default(_that.caseRef,_that.ageBand,_that.sex,_that.testTypeNames,_that.testNames,_that.reportStatus,_that.signedDiagnosisExcerpt,_that.signedAt,_that.signedByName,_that.reportLanguage,_that.builtAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'caseRef')  String caseRef, @JsonKey(name: 'ageBand')  String ageBand, @JsonKey(name: 'sex')  String sex, @JsonKey(name: 'testTypeNames')  List<String> testTypeNames, @JsonKey(name: 'testNames')  List<String> testNames, @JsonKey(name: 'reportStatus')  String reportStatus, @JsonKey(name: 'signedDiagnosisExcerpt')  String signedDiagnosisExcerpt, @JsonKey(name: 'signedAt')  String signedAt, @JsonKey(name: 'signedByName')  String signedByName, @JsonKey(name: 'reportLanguage')  String reportLanguage, @JsonKey(name: 'builtAt')  String builtAt)?  $default,) {final _that = this;
switch (_that) {
case _CaseSummaryModel() when $default != null:
return $default(_that.caseRef,_that.ageBand,_that.sex,_that.testTypeNames,_that.testNames,_that.reportStatus,_that.signedDiagnosisExcerpt,_that.signedAt,_that.signedByName,_that.reportLanguage,_that.builtAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CaseSummaryModel extends CaseSummaryModel {
  const _CaseSummaryModel({@JsonKey(name: 'caseRef') this.caseRef = '', @JsonKey(name: 'ageBand') this.ageBand = '', @JsonKey(name: 'sex') this.sex = '', @JsonKey(name: 'testTypeNames') final  List<String> testTypeNames = const <String>[], @JsonKey(name: 'testNames') final  List<String> testNames = const <String>[], @JsonKey(name: 'reportStatus') this.reportStatus = 'Pending', @JsonKey(name: 'signedDiagnosisExcerpt') this.signedDiagnosisExcerpt = '', @JsonKey(name: 'signedAt') this.signedAt = '', @JsonKey(name: 'signedByName') this.signedByName = '', @JsonKey(name: 'reportLanguage') this.reportLanguage = '', @JsonKey(name: 'builtAt') this.builtAt = ''}): _testTypeNames = testTypeNames,_testNames = testNames,super._();
  factory _CaseSummaryModel.fromJson(Map<String, dynamic> json) => _$CaseSummaryModelFromJson(json);

@override@JsonKey(name: 'caseRef') final  String caseRef;
@override@JsonKey(name: 'ageBand') final  String ageBand;
@override@JsonKey(name: 'sex') final  String sex;
 final  List<String> _testTypeNames;
@override@JsonKey(name: 'testTypeNames') List<String> get testTypeNames {
  if (_testTypeNames is EqualUnmodifiableListView) return _testTypeNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_testTypeNames);
}

 final  List<String> _testNames;
@override@JsonKey(name: 'testNames') List<String> get testNames {
  if (_testNames is EqualUnmodifiableListView) return _testNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_testNames);
}

@override@JsonKey(name: 'reportStatus') final  String reportStatus;
@override@JsonKey(name: 'signedDiagnosisExcerpt') final  String signedDiagnosisExcerpt;
@override@JsonKey(name: 'signedAt') final  String signedAt;
@override@JsonKey(name: 'signedByName') final  String signedByName;
@override@JsonKey(name: 'reportLanguage') final  String reportLanguage;
@override@JsonKey(name: 'builtAt') final  String builtAt;

/// Create a copy of CaseSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CaseSummaryModelCopyWith<_CaseSummaryModel> get copyWith => __$CaseSummaryModelCopyWithImpl<_CaseSummaryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CaseSummaryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CaseSummaryModel&&(identical(other.caseRef, caseRef) || other.caseRef == caseRef)&&(identical(other.ageBand, ageBand) || other.ageBand == ageBand)&&(identical(other.sex, sex) || other.sex == sex)&&const DeepCollectionEquality().equals(other._testTypeNames, _testTypeNames)&&const DeepCollectionEquality().equals(other._testNames, _testNames)&&(identical(other.reportStatus, reportStatus) || other.reportStatus == reportStatus)&&(identical(other.signedDiagnosisExcerpt, signedDiagnosisExcerpt) || other.signedDiagnosisExcerpt == signedDiagnosisExcerpt)&&(identical(other.signedAt, signedAt) || other.signedAt == signedAt)&&(identical(other.signedByName, signedByName) || other.signedByName == signedByName)&&(identical(other.reportLanguage, reportLanguage) || other.reportLanguage == reportLanguage)&&(identical(other.builtAt, builtAt) || other.builtAt == builtAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,caseRef,ageBand,sex,const DeepCollectionEquality().hash(_testTypeNames),const DeepCollectionEquality().hash(_testNames),reportStatus,signedDiagnosisExcerpt,signedAt,signedByName,reportLanguage,builtAt);

@override
String toString() {
  return 'CaseSummaryModel(caseRef: $caseRef, ageBand: $ageBand, sex: $sex, testTypeNames: $testTypeNames, testNames: $testNames, reportStatus: $reportStatus, signedDiagnosisExcerpt: $signedDiagnosisExcerpt, signedAt: $signedAt, signedByName: $signedByName, reportLanguage: $reportLanguage, builtAt: $builtAt)';
}


}

/// @nodoc
abstract mixin class _$CaseSummaryModelCopyWith<$Res> implements $CaseSummaryModelCopyWith<$Res> {
  factory _$CaseSummaryModelCopyWith(_CaseSummaryModel value, $Res Function(_CaseSummaryModel) _then) = __$CaseSummaryModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'caseRef') String caseRef,@JsonKey(name: 'ageBand') String ageBand,@JsonKey(name: 'sex') String sex,@JsonKey(name: 'testTypeNames') List<String> testTypeNames,@JsonKey(name: 'testNames') List<String> testNames,@JsonKey(name: 'reportStatus') String reportStatus,@JsonKey(name: 'signedDiagnosisExcerpt') String signedDiagnosisExcerpt,@JsonKey(name: 'signedAt') String signedAt,@JsonKey(name: 'signedByName') String signedByName,@JsonKey(name: 'reportLanguage') String reportLanguage,@JsonKey(name: 'builtAt') String builtAt
});




}
/// @nodoc
class __$CaseSummaryModelCopyWithImpl<$Res>
    implements _$CaseSummaryModelCopyWith<$Res> {
  __$CaseSummaryModelCopyWithImpl(this._self, this._then);

  final _CaseSummaryModel _self;
  final $Res Function(_CaseSummaryModel) _then;

/// Create a copy of CaseSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? caseRef = null,Object? ageBand = null,Object? sex = null,Object? testTypeNames = null,Object? testNames = null,Object? reportStatus = null,Object? signedDiagnosisExcerpt = null,Object? signedAt = null,Object? signedByName = null,Object? reportLanguage = null,Object? builtAt = null,}) {
  return _then(_CaseSummaryModel(
caseRef: null == caseRef ? _self.caseRef : caseRef // ignore: cast_nullable_to_non_nullable
as String,ageBand: null == ageBand ? _self.ageBand : ageBand // ignore: cast_nullable_to_non_nullable
as String,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as String,testTypeNames: null == testTypeNames ? _self._testTypeNames : testTypeNames // ignore: cast_nullable_to_non_nullable
as List<String>,testNames: null == testNames ? _self._testNames : testNames // ignore: cast_nullable_to_non_nullable
as List<String>,reportStatus: null == reportStatus ? _self.reportStatus : reportStatus // ignore: cast_nullable_to_non_nullable
as String,signedDiagnosisExcerpt: null == signedDiagnosisExcerpt ? _self.signedDiagnosisExcerpt : signedDiagnosisExcerpt // ignore: cast_nullable_to_non_nullable
as String,signedAt: null == signedAt ? _self.signedAt : signedAt // ignore: cast_nullable_to_non_nullable
as String,signedByName: null == signedByName ? _self.signedByName : signedByName // ignore: cast_nullable_to_non_nullable
as String,reportLanguage: null == reportLanguage ? _self.reportLanguage : reportLanguage // ignore: cast_nullable_to_non_nullable
as String,builtAt: null == builtAt ? _self.builtAt : builtAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
