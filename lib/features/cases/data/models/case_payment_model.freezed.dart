// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'case_payment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CasePaymentModel {

@JsonKey(name: 'caseUid') String get caseUid;@JsonKey(name: 'method') String get method;@JsonKey(name: 'insurerId') String get insurerId;@JsonKey(name: 'insurerName') String get insurerName;@JsonKey(name: 'policyNumber') String get policyNumber;@JsonKey(name: 'createdByUid') String get createdByUid;@JsonKey(name: 'createdAt') String get createdAt;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;@JsonKey(includeFromJson: false, includeToJson: false) bool get synced;
/// Create a copy of CasePaymentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CasePaymentModelCopyWith<CasePaymentModel> get copyWith => _$CasePaymentModelCopyWithImpl<CasePaymentModel>(this as CasePaymentModel, _$identity);

  /// Serializes this CasePaymentModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CasePaymentModel&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.method, method) || other.method == method)&&(identical(other.insurerId, insurerId) || other.insurerId == insurerId)&&(identical(other.insurerName, insurerName) || other.insurerName == insurerName)&&(identical(other.policyNumber, policyNumber) || other.policyNumber == policyNumber)&&(identical(other.createdByUid, createdByUid) || other.createdByUid == createdByUid)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,caseUid,method,insurerId,insurerName,policyNumber,createdByUid,createdAt,lastUpdatedAt,synced);

@override
String toString() {
  return 'CasePaymentModel(caseUid: $caseUid, method: $method, insurerId: $insurerId, insurerName: $insurerName, policyNumber: $policyNumber, createdByUid: $createdByUid, createdAt: $createdAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class $CasePaymentModelCopyWith<$Res>  {
  factory $CasePaymentModelCopyWith(CasePaymentModel value, $Res Function(CasePaymentModel) _then) = _$CasePaymentModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'method') String method,@JsonKey(name: 'insurerId') String insurerId,@JsonKey(name: 'insurerName') String insurerName,@JsonKey(name: 'policyNumber') String policyNumber,@JsonKey(name: 'createdByUid') String createdByUid,@JsonKey(name: 'createdAt') String createdAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class _$CasePaymentModelCopyWithImpl<$Res>
    implements $CasePaymentModelCopyWith<$Res> {
  _$CasePaymentModelCopyWithImpl(this._self, this._then);

  final CasePaymentModel _self;
  final $Res Function(CasePaymentModel) _then;

/// Create a copy of CasePaymentModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? caseUid = null,Object? method = null,Object? insurerId = null,Object? insurerName = null,Object? policyNumber = null,Object? createdByUid = null,Object? createdAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_self.copyWith(
caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,insurerId: null == insurerId ? _self.insurerId : insurerId // ignore: cast_nullable_to_non_nullable
as String,insurerName: null == insurerName ? _self.insurerName : insurerName // ignore: cast_nullable_to_non_nullable
as String,policyNumber: null == policyNumber ? _self.policyNumber : policyNumber // ignore: cast_nullable_to_non_nullable
as String,createdByUid: null == createdByUid ? _self.createdByUid : createdByUid // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CasePaymentModel].
extension CasePaymentModelPatterns on CasePaymentModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CasePaymentModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CasePaymentModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CasePaymentModel value)  $default,){
final _that = this;
switch (_that) {
case _CasePaymentModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CasePaymentModel value)?  $default,){
final _that = this;
switch (_that) {
case _CasePaymentModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'method')  String method, @JsonKey(name: 'insurerId')  String insurerId, @JsonKey(name: 'insurerName')  String insurerName, @JsonKey(name: 'policyNumber')  String policyNumber, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CasePaymentModel() when $default != null:
return $default(_that.caseUid,_that.method,_that.insurerId,_that.insurerName,_that.policyNumber,_that.createdByUid,_that.createdAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'method')  String method, @JsonKey(name: 'insurerId')  String insurerId, @JsonKey(name: 'insurerName')  String insurerName, @JsonKey(name: 'policyNumber')  String policyNumber, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)  $default,) {final _that = this;
switch (_that) {
case _CasePaymentModel():
return $default(_that.caseUid,_that.method,_that.insurerId,_that.insurerName,_that.policyNumber,_that.createdByUid,_that.createdAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'method')  String method, @JsonKey(name: 'insurerId')  String insurerId, @JsonKey(name: 'insurerName')  String insurerName, @JsonKey(name: 'policyNumber')  String policyNumber, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,) {final _that = this;
switch (_that) {
case _CasePaymentModel() when $default != null:
return $default(_that.caseUid,_that.method,_that.insurerId,_that.insurerName,_that.policyNumber,_that.createdByUid,_that.createdAt,_that.lastUpdatedAt,_that.synced);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CasePaymentModel extends CasePaymentModel {
  const _CasePaymentModel({@JsonKey(name: 'caseUid') this.caseUid = '', @JsonKey(name: 'method') this.method = 'Cash', @JsonKey(name: 'insurerId') this.insurerId = '', @JsonKey(name: 'insurerName') this.insurerName = '', @JsonKey(name: 'policyNumber') this.policyNumber = '', @JsonKey(name: 'createdByUid') this.createdByUid = '', @JsonKey(name: 'createdAt') this.createdAt = '', @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = '', @JsonKey(includeFromJson: false, includeToJson: false) this.synced = true}): super._();
  factory _CasePaymentModel.fromJson(Map<String, dynamic> json) => _$CasePaymentModelFromJson(json);

@override@JsonKey(name: 'caseUid') final  String caseUid;
@override@JsonKey(name: 'method') final  String method;
@override@JsonKey(name: 'insurerId') final  String insurerId;
@override@JsonKey(name: 'insurerName') final  String insurerName;
@override@JsonKey(name: 'policyNumber') final  String policyNumber;
@override@JsonKey(name: 'createdByUid') final  String createdByUid;
@override@JsonKey(name: 'createdAt') final  String createdAt;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool synced;

/// Create a copy of CasePaymentModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CasePaymentModelCopyWith<_CasePaymentModel> get copyWith => __$CasePaymentModelCopyWithImpl<_CasePaymentModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CasePaymentModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CasePaymentModel&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.method, method) || other.method == method)&&(identical(other.insurerId, insurerId) || other.insurerId == insurerId)&&(identical(other.insurerName, insurerName) || other.insurerName == insurerName)&&(identical(other.policyNumber, policyNumber) || other.policyNumber == policyNumber)&&(identical(other.createdByUid, createdByUid) || other.createdByUid == createdByUid)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,caseUid,method,insurerId,insurerName,policyNumber,createdByUid,createdAt,lastUpdatedAt,synced);

@override
String toString() {
  return 'CasePaymentModel(caseUid: $caseUid, method: $method, insurerId: $insurerId, insurerName: $insurerName, policyNumber: $policyNumber, createdByUid: $createdByUid, createdAt: $createdAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class _$CasePaymentModelCopyWith<$Res> implements $CasePaymentModelCopyWith<$Res> {
  factory _$CasePaymentModelCopyWith(_CasePaymentModel value, $Res Function(_CasePaymentModel) _then) = __$CasePaymentModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'method') String method,@JsonKey(name: 'insurerId') String insurerId,@JsonKey(name: 'insurerName') String insurerName,@JsonKey(name: 'policyNumber') String policyNumber,@JsonKey(name: 'createdByUid') String createdByUid,@JsonKey(name: 'createdAt') String createdAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class __$CasePaymentModelCopyWithImpl<$Res>
    implements _$CasePaymentModelCopyWith<$Res> {
  __$CasePaymentModelCopyWithImpl(this._self, this._then);

  final _CasePaymentModel _self;
  final $Res Function(_CasePaymentModel) _then;

/// Create a copy of CasePaymentModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? caseUid = null,Object? method = null,Object? insurerId = null,Object? insurerName = null,Object? policyNumber = null,Object? createdByUid = null,Object? createdAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_CasePaymentModel(
caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,insurerId: null == insurerId ? _self.insurerId : insurerId // ignore: cast_nullable_to_non_nullable
as String,insurerName: null == insurerName ? _self.insurerName : insurerName // ignore: cast_nullable_to_non_nullable
as String,policyNumber: null == policyNumber ? _self.policyNumber : policyNumber // ignore: cast_nullable_to_non_nullable
as String,createdByUid: null == createdByUid ? _self.createdByUid : createdByUid // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
