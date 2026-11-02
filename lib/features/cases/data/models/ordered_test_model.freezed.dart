// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ordered_test_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderedTestModel {

@JsonKey(name: 'labTestId') String get labTestId;@JsonKey(name: 'testTypeId') String get testTypeId;@JsonKey(name: 'testTypeName') String get testTypeName;@JsonKey(name: 'name') String get name;@JsonKey(name: 'priceKes') int get priceKes;@JsonKey(name: 'isPriceEstimate') bool get isPriceEstimate;
/// Create a copy of OrderedTestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderedTestModelCopyWith<OrderedTestModel> get copyWith => _$OrderedTestModelCopyWithImpl<OrderedTestModel>(this as OrderedTestModel, _$identity);

  /// Serializes this OrderedTestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderedTestModel&&(identical(other.labTestId, labTestId) || other.labTestId == labTestId)&&(identical(other.testTypeId, testTypeId) || other.testTypeId == testTypeId)&&(identical(other.testTypeName, testTypeName) || other.testTypeName == testTypeName)&&(identical(other.name, name) || other.name == name)&&(identical(other.priceKes, priceKes) || other.priceKes == priceKes)&&(identical(other.isPriceEstimate, isPriceEstimate) || other.isPriceEstimate == isPriceEstimate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,labTestId,testTypeId,testTypeName,name,priceKes,isPriceEstimate);

@override
String toString() {
  return 'OrderedTestModel(labTestId: $labTestId, testTypeId: $testTypeId, testTypeName: $testTypeName, name: $name, priceKes: $priceKes, isPriceEstimate: $isPriceEstimate)';
}


}

/// @nodoc
abstract mixin class $OrderedTestModelCopyWith<$Res>  {
  factory $OrderedTestModelCopyWith(OrderedTestModel value, $Res Function(OrderedTestModel) _then) = _$OrderedTestModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'labTestId') String labTestId,@JsonKey(name: 'testTypeId') String testTypeId,@JsonKey(name: 'testTypeName') String testTypeName,@JsonKey(name: 'name') String name,@JsonKey(name: 'priceKes') int priceKes,@JsonKey(name: 'isPriceEstimate') bool isPriceEstimate
});




}
/// @nodoc
class _$OrderedTestModelCopyWithImpl<$Res>
    implements $OrderedTestModelCopyWith<$Res> {
  _$OrderedTestModelCopyWithImpl(this._self, this._then);

  final OrderedTestModel _self;
  final $Res Function(OrderedTestModel) _then;

/// Create a copy of OrderedTestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? labTestId = null,Object? testTypeId = null,Object? testTypeName = null,Object? name = null,Object? priceKes = null,Object? isPriceEstimate = null,}) {
  return _then(_self.copyWith(
labTestId: null == labTestId ? _self.labTestId : labTestId // ignore: cast_nullable_to_non_nullable
as String,testTypeId: null == testTypeId ? _self.testTypeId : testTypeId // ignore: cast_nullable_to_non_nullable
as String,testTypeName: null == testTypeName ? _self.testTypeName : testTypeName // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,priceKes: null == priceKes ? _self.priceKes : priceKes // ignore: cast_nullable_to_non_nullable
as int,isPriceEstimate: null == isPriceEstimate ? _self.isPriceEstimate : isPriceEstimate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderedTestModel].
extension OrderedTestModelPatterns on OrderedTestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderedTestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderedTestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderedTestModel value)  $default,){
final _that = this;
switch (_that) {
case _OrderedTestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderedTestModel value)?  $default,){
final _that = this;
switch (_that) {
case _OrderedTestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'labTestId')  String labTestId, @JsonKey(name: 'testTypeId')  String testTypeId, @JsonKey(name: 'testTypeName')  String testTypeName, @JsonKey(name: 'name')  String name, @JsonKey(name: 'priceKes')  int priceKes, @JsonKey(name: 'isPriceEstimate')  bool isPriceEstimate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderedTestModel() when $default != null:
return $default(_that.labTestId,_that.testTypeId,_that.testTypeName,_that.name,_that.priceKes,_that.isPriceEstimate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'labTestId')  String labTestId, @JsonKey(name: 'testTypeId')  String testTypeId, @JsonKey(name: 'testTypeName')  String testTypeName, @JsonKey(name: 'name')  String name, @JsonKey(name: 'priceKes')  int priceKes, @JsonKey(name: 'isPriceEstimate')  bool isPriceEstimate)  $default,) {final _that = this;
switch (_that) {
case _OrderedTestModel():
return $default(_that.labTestId,_that.testTypeId,_that.testTypeName,_that.name,_that.priceKes,_that.isPriceEstimate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'labTestId')  String labTestId, @JsonKey(name: 'testTypeId')  String testTypeId, @JsonKey(name: 'testTypeName')  String testTypeName, @JsonKey(name: 'name')  String name, @JsonKey(name: 'priceKes')  int priceKes, @JsonKey(name: 'isPriceEstimate')  bool isPriceEstimate)?  $default,) {final _that = this;
switch (_that) {
case _OrderedTestModel() when $default != null:
return $default(_that.labTestId,_that.testTypeId,_that.testTypeName,_that.name,_that.priceKes,_that.isPriceEstimate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderedTestModel implements OrderedTestModel {
  const _OrderedTestModel({@JsonKey(name: 'labTestId') this.labTestId = '', @JsonKey(name: 'testTypeId') this.testTypeId = '', @JsonKey(name: 'testTypeName') this.testTypeName = '', @JsonKey(name: 'name') this.name = '', @JsonKey(name: 'priceKes') this.priceKes = 0, @JsonKey(name: 'isPriceEstimate') this.isPriceEstimate = false});
  factory _OrderedTestModel.fromJson(Map<String, dynamic> json) => _$OrderedTestModelFromJson(json);

@override@JsonKey(name: 'labTestId') final  String labTestId;
@override@JsonKey(name: 'testTypeId') final  String testTypeId;
@override@JsonKey(name: 'testTypeName') final  String testTypeName;
@override@JsonKey(name: 'name') final  String name;
@override@JsonKey(name: 'priceKes') final  int priceKes;
@override@JsonKey(name: 'isPriceEstimate') final  bool isPriceEstimate;

/// Create a copy of OrderedTestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderedTestModelCopyWith<_OrderedTestModel> get copyWith => __$OrderedTestModelCopyWithImpl<_OrderedTestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderedTestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderedTestModel&&(identical(other.labTestId, labTestId) || other.labTestId == labTestId)&&(identical(other.testTypeId, testTypeId) || other.testTypeId == testTypeId)&&(identical(other.testTypeName, testTypeName) || other.testTypeName == testTypeName)&&(identical(other.name, name) || other.name == name)&&(identical(other.priceKes, priceKes) || other.priceKes == priceKes)&&(identical(other.isPriceEstimate, isPriceEstimate) || other.isPriceEstimate == isPriceEstimate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,labTestId,testTypeId,testTypeName,name,priceKes,isPriceEstimate);

@override
String toString() {
  return 'OrderedTestModel(labTestId: $labTestId, testTypeId: $testTypeId, testTypeName: $testTypeName, name: $name, priceKes: $priceKes, isPriceEstimate: $isPriceEstimate)';
}


}

/// @nodoc
abstract mixin class _$OrderedTestModelCopyWith<$Res> implements $OrderedTestModelCopyWith<$Res> {
  factory _$OrderedTestModelCopyWith(_OrderedTestModel value, $Res Function(_OrderedTestModel) _then) = __$OrderedTestModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'labTestId') String labTestId,@JsonKey(name: 'testTypeId') String testTypeId,@JsonKey(name: 'testTypeName') String testTypeName,@JsonKey(name: 'name') String name,@JsonKey(name: 'priceKes') int priceKes,@JsonKey(name: 'isPriceEstimate') bool isPriceEstimate
});




}
/// @nodoc
class __$OrderedTestModelCopyWithImpl<$Res>
    implements _$OrderedTestModelCopyWith<$Res> {
  __$OrderedTestModelCopyWithImpl(this._self, this._then);

  final _OrderedTestModel _self;
  final $Res Function(_OrderedTestModel) _then;

/// Create a copy of OrderedTestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? labTestId = null,Object? testTypeId = null,Object? testTypeName = null,Object? name = null,Object? priceKes = null,Object? isPriceEstimate = null,}) {
  return _then(_OrderedTestModel(
labTestId: null == labTestId ? _self.labTestId : labTestId // ignore: cast_nullable_to_non_nullable
as String,testTypeId: null == testTypeId ? _self.testTypeId : testTypeId // ignore: cast_nullable_to_non_nullable
as String,testTypeName: null == testTypeName ? _self.testTypeName : testTypeName // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,priceKes: null == priceKes ? _self.priceKes : priceKes // ignore: cast_nullable_to_non_nullable
as int,isPriceEstimate: null == isPriceEstimate ? _self.isPriceEstimate : isPriceEstimate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
