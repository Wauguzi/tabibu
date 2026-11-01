// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'risk_check_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RiskCheckModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'caseUid') String get caseUid;@JsonKey(name: 'status') String get status;@JsonKey(name: 'inputLanguage') String get inputLanguage;@JsonKey(name: 'suggestedLabTestIds') List<String> get suggestedLabTestIds;@JsonKey(name: 'advisoryKey') String get advisoryKey;@JsonKey(name: 'advisoryEn') String get advisoryEn;@JsonKey(name: 'advisorySw') String get advisorySw;@JsonKey(name: 'models') Map<String, String> get models;@JsonKey(name: 'failureReason') String get failureReason;@JsonKey(name: 'requestedAt') String get requestedAt;@JsonKey(name: 'readyAt') String get readyAt;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;@JsonKey(includeFromJson: false, includeToJson: false) bool get synced;
/// Create a copy of RiskCheckModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RiskCheckModelCopyWith<RiskCheckModel> get copyWith => _$RiskCheckModelCopyWithImpl<RiskCheckModel>(this as RiskCheckModel, _$identity);

  /// Serializes this RiskCheckModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RiskCheckModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.status, status) || other.status == status)&&(identical(other.inputLanguage, inputLanguage) || other.inputLanguage == inputLanguage)&&const DeepCollectionEquality().equals(other.suggestedLabTestIds, suggestedLabTestIds)&&(identical(other.advisoryKey, advisoryKey) || other.advisoryKey == advisoryKey)&&(identical(other.advisoryEn, advisoryEn) || other.advisoryEn == advisoryEn)&&(identical(other.advisorySw, advisorySw) || other.advisorySw == advisorySw)&&const DeepCollectionEquality().equals(other.models, models)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.readyAt, readyAt) || other.readyAt == readyAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,caseUid,status,inputLanguage,const DeepCollectionEquality().hash(suggestedLabTestIds),advisoryKey,advisoryEn,advisorySw,const DeepCollectionEquality().hash(models),failureReason,requestedAt,readyAt,lastUpdatedAt,synced);

@override
String toString() {
  return 'RiskCheckModel(uid: $uid, caseUid: $caseUid, status: $status, inputLanguage: $inputLanguage, suggestedLabTestIds: $suggestedLabTestIds, advisoryKey: $advisoryKey, advisoryEn: $advisoryEn, advisorySw: $advisorySw, models: $models, failureReason: $failureReason, requestedAt: $requestedAt, readyAt: $readyAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class $RiskCheckModelCopyWith<$Res>  {
  factory $RiskCheckModelCopyWith(RiskCheckModel value, $Res Function(RiskCheckModel) _then) = _$RiskCheckModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'status') String status,@JsonKey(name: 'inputLanguage') String inputLanguage,@JsonKey(name: 'suggestedLabTestIds') List<String> suggestedLabTestIds,@JsonKey(name: 'advisoryKey') String advisoryKey,@JsonKey(name: 'advisoryEn') String advisoryEn,@JsonKey(name: 'advisorySw') String advisorySw,@JsonKey(name: 'models') Map<String, String> models,@JsonKey(name: 'failureReason') String failureReason,@JsonKey(name: 'requestedAt') String requestedAt,@JsonKey(name: 'readyAt') String readyAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class _$RiskCheckModelCopyWithImpl<$Res>
    implements $RiskCheckModelCopyWith<$Res> {
  _$RiskCheckModelCopyWithImpl(this._self, this._then);

  final RiskCheckModel _self;
  final $Res Function(RiskCheckModel) _then;

/// Create a copy of RiskCheckModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? caseUid = null,Object? status = null,Object? inputLanguage = null,Object? suggestedLabTestIds = null,Object? advisoryKey = null,Object? advisoryEn = null,Object? advisorySw = null,Object? models = null,Object? failureReason = null,Object? requestedAt = null,Object? readyAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,inputLanguage: null == inputLanguage ? _self.inputLanguage : inputLanguage // ignore: cast_nullable_to_non_nullable
as String,suggestedLabTestIds: null == suggestedLabTestIds ? _self.suggestedLabTestIds : suggestedLabTestIds // ignore: cast_nullable_to_non_nullable
as List<String>,advisoryKey: null == advisoryKey ? _self.advisoryKey : advisoryKey // ignore: cast_nullable_to_non_nullable
as String,advisoryEn: null == advisoryEn ? _self.advisoryEn : advisoryEn // ignore: cast_nullable_to_non_nullable
as String,advisorySw: null == advisorySw ? _self.advisorySw : advisorySw // ignore: cast_nullable_to_non_nullable
as String,models: null == models ? _self.models : models // ignore: cast_nullable_to_non_nullable
as Map<String, String>,failureReason: null == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as String,readyAt: null == readyAt ? _self.readyAt : readyAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RiskCheckModel].
extension RiskCheckModelPatterns on RiskCheckModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RiskCheckModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RiskCheckModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RiskCheckModel value)  $default,){
final _that = this;
switch (_that) {
case _RiskCheckModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RiskCheckModel value)?  $default,){
final _that = this;
switch (_that) {
case _RiskCheckModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'status')  String status, @JsonKey(name: 'inputLanguage')  String inputLanguage, @JsonKey(name: 'suggestedLabTestIds')  List<String> suggestedLabTestIds, @JsonKey(name: 'advisoryKey')  String advisoryKey, @JsonKey(name: 'advisoryEn')  String advisoryEn, @JsonKey(name: 'advisorySw')  String advisorySw, @JsonKey(name: 'models')  Map<String, String> models, @JsonKey(name: 'failureReason')  String failureReason, @JsonKey(name: 'requestedAt')  String requestedAt, @JsonKey(name: 'readyAt')  String readyAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RiskCheckModel() when $default != null:
return $default(_that.uid,_that.caseUid,_that.status,_that.inputLanguage,_that.suggestedLabTestIds,_that.advisoryKey,_that.advisoryEn,_that.advisorySw,_that.models,_that.failureReason,_that.requestedAt,_that.readyAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'status')  String status, @JsonKey(name: 'inputLanguage')  String inputLanguage, @JsonKey(name: 'suggestedLabTestIds')  List<String> suggestedLabTestIds, @JsonKey(name: 'advisoryKey')  String advisoryKey, @JsonKey(name: 'advisoryEn')  String advisoryEn, @JsonKey(name: 'advisorySw')  String advisorySw, @JsonKey(name: 'models')  Map<String, String> models, @JsonKey(name: 'failureReason')  String failureReason, @JsonKey(name: 'requestedAt')  String requestedAt, @JsonKey(name: 'readyAt')  String readyAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)  $default,) {final _that = this;
switch (_that) {
case _RiskCheckModel():
return $default(_that.uid,_that.caseUid,_that.status,_that.inputLanguage,_that.suggestedLabTestIds,_that.advisoryKey,_that.advisoryEn,_that.advisorySw,_that.models,_that.failureReason,_that.requestedAt,_that.readyAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'status')  String status, @JsonKey(name: 'inputLanguage')  String inputLanguage, @JsonKey(name: 'suggestedLabTestIds')  List<String> suggestedLabTestIds, @JsonKey(name: 'advisoryKey')  String advisoryKey, @JsonKey(name: 'advisoryEn')  String advisoryEn, @JsonKey(name: 'advisorySw')  String advisorySw, @JsonKey(name: 'models')  Map<String, String> models, @JsonKey(name: 'failureReason')  String failureReason, @JsonKey(name: 'requestedAt')  String requestedAt, @JsonKey(name: 'readyAt')  String readyAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,) {final _that = this;
switch (_that) {
case _RiskCheckModel() when $default != null:
return $default(_that.uid,_that.caseUid,_that.status,_that.inputLanguage,_that.suggestedLabTestIds,_that.advisoryKey,_that.advisoryEn,_that.advisorySw,_that.models,_that.failureReason,_that.requestedAt,_that.readyAt,_that.lastUpdatedAt,_that.synced);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RiskCheckModel extends RiskCheckModel {
  const _RiskCheckModel({@JsonKey(name: 'uid') this.uid = 'current', @JsonKey(name: 'caseUid') this.caseUid = '', @JsonKey(name: 'status') this.status = 'Queued', @JsonKey(name: 'inputLanguage') this.inputLanguage = '', @JsonKey(name: 'suggestedLabTestIds') final  List<String> suggestedLabTestIds = const <String>[], @JsonKey(name: 'advisoryKey') this.advisoryKey = '', @JsonKey(name: 'advisoryEn') this.advisoryEn = '', @JsonKey(name: 'advisorySw') this.advisorySw = '', @JsonKey(name: 'models') final  Map<String, String> models = const <String, String>{}, @JsonKey(name: 'failureReason') this.failureReason = '', @JsonKey(name: 'requestedAt') this.requestedAt = '', @JsonKey(name: 'readyAt') this.readyAt = '', @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = '', @JsonKey(includeFromJson: false, includeToJson: false) this.synced = true}): _suggestedLabTestIds = suggestedLabTestIds,_models = models,super._();
  factory _RiskCheckModel.fromJson(Map<String, dynamic> json) => _$RiskCheckModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'caseUid') final  String caseUid;
@override@JsonKey(name: 'status') final  String status;
@override@JsonKey(name: 'inputLanguage') final  String inputLanguage;
 final  List<String> _suggestedLabTestIds;
@override@JsonKey(name: 'suggestedLabTestIds') List<String> get suggestedLabTestIds {
  if (_suggestedLabTestIds is EqualUnmodifiableListView) return _suggestedLabTestIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_suggestedLabTestIds);
}

@override@JsonKey(name: 'advisoryKey') final  String advisoryKey;
@override@JsonKey(name: 'advisoryEn') final  String advisoryEn;
@override@JsonKey(name: 'advisorySw') final  String advisorySw;
 final  Map<String, String> _models;
@override@JsonKey(name: 'models') Map<String, String> get models {
  if (_models is EqualUnmodifiableMapView) return _models;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_models);
}

@override@JsonKey(name: 'failureReason') final  String failureReason;
@override@JsonKey(name: 'requestedAt') final  String requestedAt;
@override@JsonKey(name: 'readyAt') final  String readyAt;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool synced;

/// Create a copy of RiskCheckModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RiskCheckModelCopyWith<_RiskCheckModel> get copyWith => __$RiskCheckModelCopyWithImpl<_RiskCheckModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RiskCheckModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RiskCheckModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.status, status) || other.status == status)&&(identical(other.inputLanguage, inputLanguage) || other.inputLanguage == inputLanguage)&&const DeepCollectionEquality().equals(other._suggestedLabTestIds, _suggestedLabTestIds)&&(identical(other.advisoryKey, advisoryKey) || other.advisoryKey == advisoryKey)&&(identical(other.advisoryEn, advisoryEn) || other.advisoryEn == advisoryEn)&&(identical(other.advisorySw, advisorySw) || other.advisorySw == advisorySw)&&const DeepCollectionEquality().equals(other._models, _models)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.readyAt, readyAt) || other.readyAt == readyAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,caseUid,status,inputLanguage,const DeepCollectionEquality().hash(_suggestedLabTestIds),advisoryKey,advisoryEn,advisorySw,const DeepCollectionEquality().hash(_models),failureReason,requestedAt,readyAt,lastUpdatedAt,synced);

@override
String toString() {
  return 'RiskCheckModel(uid: $uid, caseUid: $caseUid, status: $status, inputLanguage: $inputLanguage, suggestedLabTestIds: $suggestedLabTestIds, advisoryKey: $advisoryKey, advisoryEn: $advisoryEn, advisorySw: $advisorySw, models: $models, failureReason: $failureReason, requestedAt: $requestedAt, readyAt: $readyAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class _$RiskCheckModelCopyWith<$Res> implements $RiskCheckModelCopyWith<$Res> {
  factory _$RiskCheckModelCopyWith(_RiskCheckModel value, $Res Function(_RiskCheckModel) _then) = __$RiskCheckModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'status') String status,@JsonKey(name: 'inputLanguage') String inputLanguage,@JsonKey(name: 'suggestedLabTestIds') List<String> suggestedLabTestIds,@JsonKey(name: 'advisoryKey') String advisoryKey,@JsonKey(name: 'advisoryEn') String advisoryEn,@JsonKey(name: 'advisorySw') String advisorySw,@JsonKey(name: 'models') Map<String, String> models,@JsonKey(name: 'failureReason') String failureReason,@JsonKey(name: 'requestedAt') String requestedAt,@JsonKey(name: 'readyAt') String readyAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class __$RiskCheckModelCopyWithImpl<$Res>
    implements _$RiskCheckModelCopyWith<$Res> {
  __$RiskCheckModelCopyWithImpl(this._self, this._then);

  final _RiskCheckModel _self;
  final $Res Function(_RiskCheckModel) _then;

/// Create a copy of RiskCheckModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? caseUid = null,Object? status = null,Object? inputLanguage = null,Object? suggestedLabTestIds = null,Object? advisoryKey = null,Object? advisoryEn = null,Object? advisorySw = null,Object? models = null,Object? failureReason = null,Object? requestedAt = null,Object? readyAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_RiskCheckModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,inputLanguage: null == inputLanguage ? _self.inputLanguage : inputLanguage // ignore: cast_nullable_to_non_nullable
as String,suggestedLabTestIds: null == suggestedLabTestIds ? _self._suggestedLabTestIds : suggestedLabTestIds // ignore: cast_nullable_to_non_nullable
as List<String>,advisoryKey: null == advisoryKey ? _self.advisoryKey : advisoryKey // ignore: cast_nullable_to_non_nullable
as String,advisoryEn: null == advisoryEn ? _self.advisoryEn : advisoryEn // ignore: cast_nullable_to_non_nullable
as String,advisorySw: null == advisorySw ? _self.advisorySw : advisorySw // ignore: cast_nullable_to_non_nullable
as String,models: null == models ? _self._models : models // ignore: cast_nullable_to_non_nullable
as Map<String, String>,failureReason: null == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as String,readyAt: null == readyAt ? _self.readyAt : readyAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
