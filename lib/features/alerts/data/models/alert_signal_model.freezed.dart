// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alert_signal_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AlertSignalModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'diseaseId') String get diseaseId;@JsonKey(name: 'countyId') int get countyId;@JsonKey(name: 'countyName') String get countyName;@JsonKey(name: 'epiWeek') String get epiWeek;@JsonKey(name: 'category') String get category;@JsonKey(name: 'rule') String get rule;@JsonKey(name: 'status') String get status;@JsonKey(name: 'evidence') AlertEvidenceModel get evidence;@JsonKey(name: 'alertUid') String get alertUid;@JsonKey(name: 'synthetic') bool get synthetic;@JsonKey(name: 'raisedAt') String get raisedAt;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;
/// Create a copy of AlertSignalModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlertSignalModelCopyWith<AlertSignalModel> get copyWith => _$AlertSignalModelCopyWithImpl<AlertSignalModel>(this as AlertSignalModel, _$identity);

  /// Serializes this AlertSignalModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlertSignalModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.diseaseId, diseaseId) || other.diseaseId == diseaseId)&&(identical(other.countyId, countyId) || other.countyId == countyId)&&(identical(other.countyName, countyName) || other.countyName == countyName)&&(identical(other.epiWeek, epiWeek) || other.epiWeek == epiWeek)&&(identical(other.category, category) || other.category == category)&&(identical(other.rule, rule) || other.rule == rule)&&(identical(other.status, status) || other.status == status)&&(identical(other.evidence, evidence) || other.evidence == evidence)&&(identical(other.alertUid, alertUid) || other.alertUid == alertUid)&&(identical(other.synthetic, synthetic) || other.synthetic == synthetic)&&(identical(other.raisedAt, raisedAt) || other.raisedAt == raisedAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,diseaseId,countyId,countyName,epiWeek,category,rule,status,evidence,alertUid,synthetic,raisedAt,lastUpdatedAt);

@override
String toString() {
  return 'AlertSignalModel(uid: $uid, diseaseId: $diseaseId, countyId: $countyId, countyName: $countyName, epiWeek: $epiWeek, category: $category, rule: $rule, status: $status, evidence: $evidence, alertUid: $alertUid, synthetic: $synthetic, raisedAt: $raisedAt, lastUpdatedAt: $lastUpdatedAt)';
}


}

/// @nodoc
abstract mixin class $AlertSignalModelCopyWith<$Res>  {
  factory $AlertSignalModelCopyWith(AlertSignalModel value, $Res Function(AlertSignalModel) _then) = _$AlertSignalModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'diseaseId') String diseaseId,@JsonKey(name: 'countyId') int countyId,@JsonKey(name: 'countyName') String countyName,@JsonKey(name: 'epiWeek') String epiWeek,@JsonKey(name: 'category') String category,@JsonKey(name: 'rule') String rule,@JsonKey(name: 'status') String status,@JsonKey(name: 'evidence') AlertEvidenceModel evidence,@JsonKey(name: 'alertUid') String alertUid,@JsonKey(name: 'synthetic') bool synthetic,@JsonKey(name: 'raisedAt') String raisedAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt
});


$AlertEvidenceModelCopyWith<$Res> get evidence;

}
/// @nodoc
class _$AlertSignalModelCopyWithImpl<$Res>
    implements $AlertSignalModelCopyWith<$Res> {
  _$AlertSignalModelCopyWithImpl(this._self, this._then);

  final AlertSignalModel _self;
  final $Res Function(AlertSignalModel) _then;

/// Create a copy of AlertSignalModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? diseaseId = null,Object? countyId = null,Object? countyName = null,Object? epiWeek = null,Object? category = null,Object? rule = null,Object? status = null,Object? evidence = null,Object? alertUid = null,Object? synthetic = null,Object? raisedAt = null,Object? lastUpdatedAt = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,diseaseId: null == diseaseId ? _self.diseaseId : diseaseId // ignore: cast_nullable_to_non_nullable
as String,countyId: null == countyId ? _self.countyId : countyId // ignore: cast_nullable_to_non_nullable
as int,countyName: null == countyName ? _self.countyName : countyName // ignore: cast_nullable_to_non_nullable
as String,epiWeek: null == epiWeek ? _self.epiWeek : epiWeek // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,evidence: null == evidence ? _self.evidence : evidence // ignore: cast_nullable_to_non_nullable
as AlertEvidenceModel,alertUid: null == alertUid ? _self.alertUid : alertUid // ignore: cast_nullable_to_non_nullable
as String,synthetic: null == synthetic ? _self.synthetic : synthetic // ignore: cast_nullable_to_non_nullable
as bool,raisedAt: null == raisedAt ? _self.raisedAt : raisedAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of AlertSignalModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlertEvidenceModelCopyWith<$Res> get evidence {
  
  return $AlertEvidenceModelCopyWith<$Res>(_self.evidence, (value) {
    return _then(_self.copyWith(evidence: value));
  });
}
}


/// Adds pattern-matching-related methods to [AlertSignalModel].
extension AlertSignalModelPatterns on AlertSignalModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlertSignalModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlertSignalModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlertSignalModel value)  $default,){
final _that = this;
switch (_that) {
case _AlertSignalModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlertSignalModel value)?  $default,){
final _that = this;
switch (_that) {
case _AlertSignalModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'diseaseId')  String diseaseId, @JsonKey(name: 'countyId')  int countyId, @JsonKey(name: 'countyName')  String countyName, @JsonKey(name: 'epiWeek')  String epiWeek, @JsonKey(name: 'category')  String category, @JsonKey(name: 'rule')  String rule, @JsonKey(name: 'status')  String status, @JsonKey(name: 'evidence')  AlertEvidenceModel evidence, @JsonKey(name: 'alertUid')  String alertUid, @JsonKey(name: 'synthetic')  bool synthetic, @JsonKey(name: 'raisedAt')  String raisedAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlertSignalModel() when $default != null:
return $default(_that.uid,_that.diseaseId,_that.countyId,_that.countyName,_that.epiWeek,_that.category,_that.rule,_that.status,_that.evidence,_that.alertUid,_that.synthetic,_that.raisedAt,_that.lastUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'diseaseId')  String diseaseId, @JsonKey(name: 'countyId')  int countyId, @JsonKey(name: 'countyName')  String countyName, @JsonKey(name: 'epiWeek')  String epiWeek, @JsonKey(name: 'category')  String category, @JsonKey(name: 'rule')  String rule, @JsonKey(name: 'status')  String status, @JsonKey(name: 'evidence')  AlertEvidenceModel evidence, @JsonKey(name: 'alertUid')  String alertUid, @JsonKey(name: 'synthetic')  bool synthetic, @JsonKey(name: 'raisedAt')  String raisedAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _AlertSignalModel():
return $default(_that.uid,_that.diseaseId,_that.countyId,_that.countyName,_that.epiWeek,_that.category,_that.rule,_that.status,_that.evidence,_that.alertUid,_that.synthetic,_that.raisedAt,_that.lastUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'diseaseId')  String diseaseId, @JsonKey(name: 'countyId')  int countyId, @JsonKey(name: 'countyName')  String countyName, @JsonKey(name: 'epiWeek')  String epiWeek, @JsonKey(name: 'category')  String category, @JsonKey(name: 'rule')  String rule, @JsonKey(name: 'status')  String status, @JsonKey(name: 'evidence')  AlertEvidenceModel evidence, @JsonKey(name: 'alertUid')  String alertUid, @JsonKey(name: 'synthetic')  bool synthetic, @JsonKey(name: 'raisedAt')  String raisedAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AlertSignalModel() when $default != null:
return $default(_that.uid,_that.diseaseId,_that.countyId,_that.countyName,_that.epiWeek,_that.category,_that.rule,_that.status,_that.evidence,_that.alertUid,_that.synthetic,_that.raisedAt,_that.lastUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _AlertSignalModel extends AlertSignalModel {
  const _AlertSignalModel({@JsonKey(name: 'uid') this.uid = '', @JsonKey(name: 'diseaseId') this.diseaseId = '', @JsonKey(name: 'countyId') this.countyId = 0, @JsonKey(name: 'countyName') this.countyName = '', @JsonKey(name: 'epiWeek') this.epiWeek = '', @JsonKey(name: 'category') this.category = '', @JsonKey(name: 'rule') this.rule = '', @JsonKey(name: 'status') this.status = 'Withdrawn', @JsonKey(name: 'evidence') this.evidence = const AlertEvidenceModel(), @JsonKey(name: 'alertUid') this.alertUid = '', @JsonKey(name: 'synthetic') this.synthetic = false, @JsonKey(name: 'raisedAt') this.raisedAt = '', @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = ''}): super._();
  factory _AlertSignalModel.fromJson(Map<String, dynamic> json) => _$AlertSignalModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'diseaseId') final  String diseaseId;
@override@JsonKey(name: 'countyId') final  int countyId;
@override@JsonKey(name: 'countyName') final  String countyName;
@override@JsonKey(name: 'epiWeek') final  String epiWeek;
@override@JsonKey(name: 'category') final  String category;
@override@JsonKey(name: 'rule') final  String rule;
@override@JsonKey(name: 'status') final  String status;
@override@JsonKey(name: 'evidence') final  AlertEvidenceModel evidence;
@override@JsonKey(name: 'alertUid') final  String alertUid;
@override@JsonKey(name: 'synthetic') final  bool synthetic;
@override@JsonKey(name: 'raisedAt') final  String raisedAt;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;

/// Create a copy of AlertSignalModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlertSignalModelCopyWith<_AlertSignalModel> get copyWith => __$AlertSignalModelCopyWithImpl<_AlertSignalModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AlertSignalModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlertSignalModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.diseaseId, diseaseId) || other.diseaseId == diseaseId)&&(identical(other.countyId, countyId) || other.countyId == countyId)&&(identical(other.countyName, countyName) || other.countyName == countyName)&&(identical(other.epiWeek, epiWeek) || other.epiWeek == epiWeek)&&(identical(other.category, category) || other.category == category)&&(identical(other.rule, rule) || other.rule == rule)&&(identical(other.status, status) || other.status == status)&&(identical(other.evidence, evidence) || other.evidence == evidence)&&(identical(other.alertUid, alertUid) || other.alertUid == alertUid)&&(identical(other.synthetic, synthetic) || other.synthetic == synthetic)&&(identical(other.raisedAt, raisedAt) || other.raisedAt == raisedAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,diseaseId,countyId,countyName,epiWeek,category,rule,status,evidence,alertUid,synthetic,raisedAt,lastUpdatedAt);

@override
String toString() {
  return 'AlertSignalModel(uid: $uid, diseaseId: $diseaseId, countyId: $countyId, countyName: $countyName, epiWeek: $epiWeek, category: $category, rule: $rule, status: $status, evidence: $evidence, alertUid: $alertUid, synthetic: $synthetic, raisedAt: $raisedAt, lastUpdatedAt: $lastUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$AlertSignalModelCopyWith<$Res> implements $AlertSignalModelCopyWith<$Res> {
  factory _$AlertSignalModelCopyWith(_AlertSignalModel value, $Res Function(_AlertSignalModel) _then) = __$AlertSignalModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'diseaseId') String diseaseId,@JsonKey(name: 'countyId') int countyId,@JsonKey(name: 'countyName') String countyName,@JsonKey(name: 'epiWeek') String epiWeek,@JsonKey(name: 'category') String category,@JsonKey(name: 'rule') String rule,@JsonKey(name: 'status') String status,@JsonKey(name: 'evidence') AlertEvidenceModel evidence,@JsonKey(name: 'alertUid') String alertUid,@JsonKey(name: 'synthetic') bool synthetic,@JsonKey(name: 'raisedAt') String raisedAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt
});


@override $AlertEvidenceModelCopyWith<$Res> get evidence;

}
/// @nodoc
class __$AlertSignalModelCopyWithImpl<$Res>
    implements _$AlertSignalModelCopyWith<$Res> {
  __$AlertSignalModelCopyWithImpl(this._self, this._then);

  final _AlertSignalModel _self;
  final $Res Function(_AlertSignalModel) _then;

/// Create a copy of AlertSignalModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? diseaseId = null,Object? countyId = null,Object? countyName = null,Object? epiWeek = null,Object? category = null,Object? rule = null,Object? status = null,Object? evidence = null,Object? alertUid = null,Object? synthetic = null,Object? raisedAt = null,Object? lastUpdatedAt = null,}) {
  return _then(_AlertSignalModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,diseaseId: null == diseaseId ? _self.diseaseId : diseaseId // ignore: cast_nullable_to_non_nullable
as String,countyId: null == countyId ? _self.countyId : countyId // ignore: cast_nullable_to_non_nullable
as int,countyName: null == countyName ? _self.countyName : countyName // ignore: cast_nullable_to_non_nullable
as String,epiWeek: null == epiWeek ? _self.epiWeek : epiWeek // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,evidence: null == evidence ? _self.evidence : evidence // ignore: cast_nullable_to_non_nullable
as AlertEvidenceModel,alertUid: null == alertUid ? _self.alertUid : alertUid // ignore: cast_nullable_to_non_nullable
as String,synthetic: null == synthetic ? _self.synthetic : synthetic // ignore: cast_nullable_to_non_nullable
as bool,raisedAt: null == raisedAt ? _self.raisedAt : raisedAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of AlertSignalModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlertEvidenceModelCopyWith<$Res> get evidence {
  
  return $AlertEvidenceModelCopyWith<$Res>(_self.evidence, (value) {
    return _then(_self.copyWith(evidence: value));
  });
}
}

// dart format on
