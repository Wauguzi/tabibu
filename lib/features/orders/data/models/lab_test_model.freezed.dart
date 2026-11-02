// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lab_test_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LabTestModel {

@JsonKey(name: 'labTestId') String get labTestId;@JsonKey(name: 'testTypeId') String get testTypeId;@JsonKey(name: 'testTypeName') String get testTypeName;@JsonKey(name: 'name') String get name;@JsonKey(name: 'isActive') bool get isActive;@JsonKey(name: 'testPriceKes') int get testPriceKes;@JsonKey(name: 'isPriceEstimate') bool get isPriceEstimate;@JsonKey(name: 'tatCollectionToDelivery') int get tatCollectionToDelivery;@JsonKey(name: 'tatDeliveryToResults') int get tatDeliveryToResults;@JsonKey(name: 'totalTurnaroundTime') int get totalTurnaroundTime;
/// Create a copy of LabTestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LabTestModelCopyWith<LabTestModel> get copyWith => _$LabTestModelCopyWithImpl<LabTestModel>(this as LabTestModel, _$identity);

  /// Serializes this LabTestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabTestModel&&(identical(other.labTestId, labTestId) || other.labTestId == labTestId)&&(identical(other.testTypeId, testTypeId) || other.testTypeId == testTypeId)&&(identical(other.testTypeName, testTypeName) || other.testTypeName == testTypeName)&&(identical(other.name, name) || other.name == name)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.testPriceKes, testPriceKes) || other.testPriceKes == testPriceKes)&&(identical(other.isPriceEstimate, isPriceEstimate) || other.isPriceEstimate == isPriceEstimate)&&(identical(other.tatCollectionToDelivery, tatCollectionToDelivery) || other.tatCollectionToDelivery == tatCollectionToDelivery)&&(identical(other.tatDeliveryToResults, tatDeliveryToResults) || other.tatDeliveryToResults == tatDeliveryToResults)&&(identical(other.totalTurnaroundTime, totalTurnaroundTime) || other.totalTurnaroundTime == totalTurnaroundTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,labTestId,testTypeId,testTypeName,name,isActive,testPriceKes,isPriceEstimate,tatCollectionToDelivery,tatDeliveryToResults,totalTurnaroundTime);

@override
String toString() {
  return 'LabTestModel(labTestId: $labTestId, testTypeId: $testTypeId, testTypeName: $testTypeName, name: $name, isActive: $isActive, testPriceKes: $testPriceKes, isPriceEstimate: $isPriceEstimate, tatCollectionToDelivery: $tatCollectionToDelivery, tatDeliveryToResults: $tatDeliveryToResults, totalTurnaroundTime: $totalTurnaroundTime)';
}


}

/// @nodoc
abstract mixin class $LabTestModelCopyWith<$Res>  {
  factory $LabTestModelCopyWith(LabTestModel value, $Res Function(LabTestModel) _then) = _$LabTestModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'labTestId') String labTestId,@JsonKey(name: 'testTypeId') String testTypeId,@JsonKey(name: 'testTypeName') String testTypeName,@JsonKey(name: 'name') String name,@JsonKey(name: 'isActive') bool isActive,@JsonKey(name: 'testPriceKes') int testPriceKes,@JsonKey(name: 'isPriceEstimate') bool isPriceEstimate,@JsonKey(name: 'tatCollectionToDelivery') int tatCollectionToDelivery,@JsonKey(name: 'tatDeliveryToResults') int tatDeliveryToResults,@JsonKey(name: 'totalTurnaroundTime') int totalTurnaroundTime
});




}
/// @nodoc
class _$LabTestModelCopyWithImpl<$Res>
    implements $LabTestModelCopyWith<$Res> {
  _$LabTestModelCopyWithImpl(this._self, this._then);

  final LabTestModel _self;
  final $Res Function(LabTestModel) _then;

/// Create a copy of LabTestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? labTestId = null,Object? testTypeId = null,Object? testTypeName = null,Object? name = null,Object? isActive = null,Object? testPriceKes = null,Object? isPriceEstimate = null,Object? tatCollectionToDelivery = null,Object? tatDeliveryToResults = null,Object? totalTurnaroundTime = null,}) {
  return _then(_self.copyWith(
labTestId: null == labTestId ? _self.labTestId : labTestId // ignore: cast_nullable_to_non_nullable
as String,testTypeId: null == testTypeId ? _self.testTypeId : testTypeId // ignore: cast_nullable_to_non_nullable
as String,testTypeName: null == testTypeName ? _self.testTypeName : testTypeName // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,testPriceKes: null == testPriceKes ? _self.testPriceKes : testPriceKes // ignore: cast_nullable_to_non_nullable
as int,isPriceEstimate: null == isPriceEstimate ? _self.isPriceEstimate : isPriceEstimate // ignore: cast_nullable_to_non_nullable
as bool,tatCollectionToDelivery: null == tatCollectionToDelivery ? _self.tatCollectionToDelivery : tatCollectionToDelivery // ignore: cast_nullable_to_non_nullable
as int,tatDeliveryToResults: null == tatDeliveryToResults ? _self.tatDeliveryToResults : tatDeliveryToResults // ignore: cast_nullable_to_non_nullable
as int,totalTurnaroundTime: null == totalTurnaroundTime ? _self.totalTurnaroundTime : totalTurnaroundTime // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LabTestModel].
extension LabTestModelPatterns on LabTestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LabTestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LabTestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LabTestModel value)  $default,){
final _that = this;
switch (_that) {
case _LabTestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LabTestModel value)?  $default,){
final _that = this;
switch (_that) {
case _LabTestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'labTestId')  String labTestId, @JsonKey(name: 'testTypeId')  String testTypeId, @JsonKey(name: 'testTypeName')  String testTypeName, @JsonKey(name: 'name')  String name, @JsonKey(name: 'isActive')  bool isActive, @JsonKey(name: 'testPriceKes')  int testPriceKes, @JsonKey(name: 'isPriceEstimate')  bool isPriceEstimate, @JsonKey(name: 'tatCollectionToDelivery')  int tatCollectionToDelivery, @JsonKey(name: 'tatDeliveryToResults')  int tatDeliveryToResults, @JsonKey(name: 'totalTurnaroundTime')  int totalTurnaroundTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LabTestModel() when $default != null:
return $default(_that.labTestId,_that.testTypeId,_that.testTypeName,_that.name,_that.isActive,_that.testPriceKes,_that.isPriceEstimate,_that.tatCollectionToDelivery,_that.tatDeliveryToResults,_that.totalTurnaroundTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'labTestId')  String labTestId, @JsonKey(name: 'testTypeId')  String testTypeId, @JsonKey(name: 'testTypeName')  String testTypeName, @JsonKey(name: 'name')  String name, @JsonKey(name: 'isActive')  bool isActive, @JsonKey(name: 'testPriceKes')  int testPriceKes, @JsonKey(name: 'isPriceEstimate')  bool isPriceEstimate, @JsonKey(name: 'tatCollectionToDelivery')  int tatCollectionToDelivery, @JsonKey(name: 'tatDeliveryToResults')  int tatDeliveryToResults, @JsonKey(name: 'totalTurnaroundTime')  int totalTurnaroundTime)  $default,) {final _that = this;
switch (_that) {
case _LabTestModel():
return $default(_that.labTestId,_that.testTypeId,_that.testTypeName,_that.name,_that.isActive,_that.testPriceKes,_that.isPriceEstimate,_that.tatCollectionToDelivery,_that.tatDeliveryToResults,_that.totalTurnaroundTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'labTestId')  String labTestId, @JsonKey(name: 'testTypeId')  String testTypeId, @JsonKey(name: 'testTypeName')  String testTypeName, @JsonKey(name: 'name')  String name, @JsonKey(name: 'isActive')  bool isActive, @JsonKey(name: 'testPriceKes')  int testPriceKes, @JsonKey(name: 'isPriceEstimate')  bool isPriceEstimate, @JsonKey(name: 'tatCollectionToDelivery')  int tatCollectionToDelivery, @JsonKey(name: 'tatDeliveryToResults')  int tatDeliveryToResults, @JsonKey(name: 'totalTurnaroundTime')  int totalTurnaroundTime)?  $default,) {final _that = this;
switch (_that) {
case _LabTestModel() when $default != null:
return $default(_that.labTestId,_that.testTypeId,_that.testTypeName,_that.name,_that.isActive,_that.testPriceKes,_that.isPriceEstimate,_that.tatCollectionToDelivery,_that.tatDeliveryToResults,_that.totalTurnaroundTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LabTestModel implements LabTestModel {
  const _LabTestModel({@JsonKey(name: 'labTestId') required this.labTestId, @JsonKey(name: 'testTypeId') required this.testTypeId, @JsonKey(name: 'testTypeName') required this.testTypeName, @JsonKey(name: 'name') required this.name, @JsonKey(name: 'isActive') required this.isActive, @JsonKey(name: 'testPriceKes') required this.testPriceKes, @JsonKey(name: 'isPriceEstimate') required this.isPriceEstimate, @JsonKey(name: 'tatCollectionToDelivery') required this.tatCollectionToDelivery, @JsonKey(name: 'tatDeliveryToResults') required this.tatDeliveryToResults, @JsonKey(name: 'totalTurnaroundTime') required this.totalTurnaroundTime});
  factory _LabTestModel.fromJson(Map<String, dynamic> json) => _$LabTestModelFromJson(json);

@override@JsonKey(name: 'labTestId') final  String labTestId;
@override@JsonKey(name: 'testTypeId') final  String testTypeId;
@override@JsonKey(name: 'testTypeName') final  String testTypeName;
@override@JsonKey(name: 'name') final  String name;
@override@JsonKey(name: 'isActive') final  bool isActive;
@override@JsonKey(name: 'testPriceKes') final  int testPriceKes;
@override@JsonKey(name: 'isPriceEstimate') final  bool isPriceEstimate;
@override@JsonKey(name: 'tatCollectionToDelivery') final  int tatCollectionToDelivery;
@override@JsonKey(name: 'tatDeliveryToResults') final  int tatDeliveryToResults;
@override@JsonKey(name: 'totalTurnaroundTime') final  int totalTurnaroundTime;

/// Create a copy of LabTestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LabTestModelCopyWith<_LabTestModel> get copyWith => __$LabTestModelCopyWithImpl<_LabTestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LabTestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LabTestModel&&(identical(other.labTestId, labTestId) || other.labTestId == labTestId)&&(identical(other.testTypeId, testTypeId) || other.testTypeId == testTypeId)&&(identical(other.testTypeName, testTypeName) || other.testTypeName == testTypeName)&&(identical(other.name, name) || other.name == name)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.testPriceKes, testPriceKes) || other.testPriceKes == testPriceKes)&&(identical(other.isPriceEstimate, isPriceEstimate) || other.isPriceEstimate == isPriceEstimate)&&(identical(other.tatCollectionToDelivery, tatCollectionToDelivery) || other.tatCollectionToDelivery == tatCollectionToDelivery)&&(identical(other.tatDeliveryToResults, tatDeliveryToResults) || other.tatDeliveryToResults == tatDeliveryToResults)&&(identical(other.totalTurnaroundTime, totalTurnaroundTime) || other.totalTurnaroundTime == totalTurnaroundTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,labTestId,testTypeId,testTypeName,name,isActive,testPriceKes,isPriceEstimate,tatCollectionToDelivery,tatDeliveryToResults,totalTurnaroundTime);

@override
String toString() {
  return 'LabTestModel(labTestId: $labTestId, testTypeId: $testTypeId, testTypeName: $testTypeName, name: $name, isActive: $isActive, testPriceKes: $testPriceKes, isPriceEstimate: $isPriceEstimate, tatCollectionToDelivery: $tatCollectionToDelivery, tatDeliveryToResults: $tatDeliveryToResults, totalTurnaroundTime: $totalTurnaroundTime)';
}


}

/// @nodoc
abstract mixin class _$LabTestModelCopyWith<$Res> implements $LabTestModelCopyWith<$Res> {
  factory _$LabTestModelCopyWith(_LabTestModel value, $Res Function(_LabTestModel) _then) = __$LabTestModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'labTestId') String labTestId,@JsonKey(name: 'testTypeId') String testTypeId,@JsonKey(name: 'testTypeName') String testTypeName,@JsonKey(name: 'name') String name,@JsonKey(name: 'isActive') bool isActive,@JsonKey(name: 'testPriceKes') int testPriceKes,@JsonKey(name: 'isPriceEstimate') bool isPriceEstimate,@JsonKey(name: 'tatCollectionToDelivery') int tatCollectionToDelivery,@JsonKey(name: 'tatDeliveryToResults') int tatDeliveryToResults,@JsonKey(name: 'totalTurnaroundTime') int totalTurnaroundTime
});




}
/// @nodoc
class __$LabTestModelCopyWithImpl<$Res>
    implements _$LabTestModelCopyWith<$Res> {
  __$LabTestModelCopyWithImpl(this._self, this._then);

  final _LabTestModel _self;
  final $Res Function(_LabTestModel) _then;

/// Create a copy of LabTestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? labTestId = null,Object? testTypeId = null,Object? testTypeName = null,Object? name = null,Object? isActive = null,Object? testPriceKes = null,Object? isPriceEstimate = null,Object? tatCollectionToDelivery = null,Object? tatDeliveryToResults = null,Object? totalTurnaroundTime = null,}) {
  return _then(_LabTestModel(
labTestId: null == labTestId ? _self.labTestId : labTestId // ignore: cast_nullable_to_non_nullable
as String,testTypeId: null == testTypeId ? _self.testTypeId : testTypeId // ignore: cast_nullable_to_non_nullable
as String,testTypeName: null == testTypeName ? _self.testTypeName : testTypeName // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,testPriceKes: null == testPriceKes ? _self.testPriceKes : testPriceKes // ignore: cast_nullable_to_non_nullable
as int,isPriceEstimate: null == isPriceEstimate ? _self.isPriceEstimate : isPriceEstimate // ignore: cast_nullable_to_non_nullable
as bool,tatCollectionToDelivery: null == tatCollectionToDelivery ? _self.tatCollectionToDelivery : tatCollectionToDelivery // ignore: cast_nullable_to_non_nullable
as int,tatDeliveryToResults: null == tatDeliveryToResults ? _self.tatDeliveryToResults : tatDeliveryToResults // ignore: cast_nullable_to_non_nullable
as int,totalTurnaroundTime: null == totalTurnaroundTime ? _self.totalTurnaroundTime : totalTurnaroundTime // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
