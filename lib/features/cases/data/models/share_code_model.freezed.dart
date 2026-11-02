// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'share_code_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShareCodeModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'caseUid') String get caseUid;@JsonKey(name: 'reportUid') String get reportUid;@JsonKey(name: 'purpose') String get purpose;@JsonKey(name: 'createdByUid') String get createdByUid;@JsonKey(name: 'createdByRole') String get createdByRole;@JsonKey(name: 'recipientUid') String get recipientUid;@JsonKey(name: 'status') String get status;@JsonKey(name: 'attempts') int get attempts;@JsonKey(name: 'reissueCount') int get reissueCount;@JsonKey(name: 'expiresAt') String get expiresAt;@JsonKey(name: 'redeemedAt') String get redeemedAt;@JsonKey(name: 'notificationUid') String get notificationUid;@JsonKey(name: 'createdAt') String get createdAt;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;@JsonKey(includeFromJson: false, includeToJson: false) bool get synced;
/// Create a copy of ShareCodeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShareCodeModelCopyWith<ShareCodeModel> get copyWith => _$ShareCodeModelCopyWithImpl<ShareCodeModel>(this as ShareCodeModel, _$identity);

  /// Serializes this ShareCodeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShareCodeModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.reportUid, reportUid) || other.reportUid == reportUid)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.createdByUid, createdByUid) || other.createdByUid == createdByUid)&&(identical(other.createdByRole, createdByRole) || other.createdByRole == createdByRole)&&(identical(other.recipientUid, recipientUid) || other.recipientUid == recipientUid)&&(identical(other.status, status) || other.status == status)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.reissueCount, reissueCount) || other.reissueCount == reissueCount)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.redeemedAt, redeemedAt) || other.redeemedAt == redeemedAt)&&(identical(other.notificationUid, notificationUid) || other.notificationUid == notificationUid)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,caseUid,reportUid,purpose,createdByUid,createdByRole,recipientUid,status,attempts,reissueCount,expiresAt,redeemedAt,notificationUid,createdAt,lastUpdatedAt,synced);

@override
String toString() {
  return 'ShareCodeModel(uid: $uid, caseUid: $caseUid, reportUid: $reportUid, purpose: $purpose, createdByUid: $createdByUid, createdByRole: $createdByRole, recipientUid: $recipientUid, status: $status, attempts: $attempts, reissueCount: $reissueCount, expiresAt: $expiresAt, redeemedAt: $redeemedAt, notificationUid: $notificationUid, createdAt: $createdAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class $ShareCodeModelCopyWith<$Res>  {
  factory $ShareCodeModelCopyWith(ShareCodeModel value, $Res Function(ShareCodeModel) _then) = _$ShareCodeModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'reportUid') String reportUid,@JsonKey(name: 'purpose') String purpose,@JsonKey(name: 'createdByUid') String createdByUid,@JsonKey(name: 'createdByRole') String createdByRole,@JsonKey(name: 'recipientUid') String recipientUid,@JsonKey(name: 'status') String status,@JsonKey(name: 'attempts') int attempts,@JsonKey(name: 'reissueCount') int reissueCount,@JsonKey(name: 'expiresAt') String expiresAt,@JsonKey(name: 'redeemedAt') String redeemedAt,@JsonKey(name: 'notificationUid') String notificationUid,@JsonKey(name: 'createdAt') String createdAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class _$ShareCodeModelCopyWithImpl<$Res>
    implements $ShareCodeModelCopyWith<$Res> {
  _$ShareCodeModelCopyWithImpl(this._self, this._then);

  final ShareCodeModel _self;
  final $Res Function(ShareCodeModel) _then;

/// Create a copy of ShareCodeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? caseUid = null,Object? reportUid = null,Object? purpose = null,Object? createdByUid = null,Object? createdByRole = null,Object? recipientUid = null,Object? status = null,Object? attempts = null,Object? reissueCount = null,Object? expiresAt = null,Object? redeemedAt = null,Object? notificationUid = null,Object? createdAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,reportUid: null == reportUid ? _self.reportUid : reportUid // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String,createdByUid: null == createdByUid ? _self.createdByUid : createdByUid // ignore: cast_nullable_to_non_nullable
as String,createdByRole: null == createdByRole ? _self.createdByRole : createdByRole // ignore: cast_nullable_to_non_nullable
as String,recipientUid: null == recipientUid ? _self.recipientUid : recipientUid // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,reissueCount: null == reissueCount ? _self.reissueCount : reissueCount // ignore: cast_nullable_to_non_nullable
as int,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String,redeemedAt: null == redeemedAt ? _self.redeemedAt : redeemedAt // ignore: cast_nullable_to_non_nullable
as String,notificationUid: null == notificationUid ? _self.notificationUid : notificationUid // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ShareCodeModel].
extension ShareCodeModelPatterns on ShareCodeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShareCodeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShareCodeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShareCodeModel value)  $default,){
final _that = this;
switch (_that) {
case _ShareCodeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShareCodeModel value)?  $default,){
final _that = this;
switch (_that) {
case _ShareCodeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'reportUid')  String reportUid, @JsonKey(name: 'purpose')  String purpose, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'createdByRole')  String createdByRole, @JsonKey(name: 'recipientUid')  String recipientUid, @JsonKey(name: 'status')  String status, @JsonKey(name: 'attempts')  int attempts, @JsonKey(name: 'reissueCount')  int reissueCount, @JsonKey(name: 'expiresAt')  String expiresAt, @JsonKey(name: 'redeemedAt')  String redeemedAt, @JsonKey(name: 'notificationUid')  String notificationUid, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShareCodeModel() when $default != null:
return $default(_that.uid,_that.caseUid,_that.reportUid,_that.purpose,_that.createdByUid,_that.createdByRole,_that.recipientUid,_that.status,_that.attempts,_that.reissueCount,_that.expiresAt,_that.redeemedAt,_that.notificationUid,_that.createdAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'reportUid')  String reportUid, @JsonKey(name: 'purpose')  String purpose, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'createdByRole')  String createdByRole, @JsonKey(name: 'recipientUid')  String recipientUid, @JsonKey(name: 'status')  String status, @JsonKey(name: 'attempts')  int attempts, @JsonKey(name: 'reissueCount')  int reissueCount, @JsonKey(name: 'expiresAt')  String expiresAt, @JsonKey(name: 'redeemedAt')  String redeemedAt, @JsonKey(name: 'notificationUid')  String notificationUid, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)  $default,) {final _that = this;
switch (_that) {
case _ShareCodeModel():
return $default(_that.uid,_that.caseUid,_that.reportUid,_that.purpose,_that.createdByUid,_that.createdByRole,_that.recipientUid,_that.status,_that.attempts,_that.reissueCount,_that.expiresAt,_that.redeemedAt,_that.notificationUid,_that.createdAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'caseUid')  String caseUid, @JsonKey(name: 'reportUid')  String reportUid, @JsonKey(name: 'purpose')  String purpose, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'createdByRole')  String createdByRole, @JsonKey(name: 'recipientUid')  String recipientUid, @JsonKey(name: 'status')  String status, @JsonKey(name: 'attempts')  int attempts, @JsonKey(name: 'reissueCount')  int reissueCount, @JsonKey(name: 'expiresAt')  String expiresAt, @JsonKey(name: 'redeemedAt')  String redeemedAt, @JsonKey(name: 'notificationUid')  String notificationUid, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,) {final _that = this;
switch (_that) {
case _ShareCodeModel() when $default != null:
return $default(_that.uid,_that.caseUid,_that.reportUid,_that.purpose,_that.createdByUid,_that.createdByRole,_that.recipientUid,_that.status,_that.attempts,_that.reissueCount,_that.expiresAt,_that.redeemedAt,_that.notificationUid,_that.createdAt,_that.lastUpdatedAt,_that.synced);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShareCodeModel extends ShareCodeModel {
  const _ShareCodeModel({@JsonKey(name: 'uid') this.uid = '', @JsonKey(name: 'caseUid') this.caseUid = '', @JsonKey(name: 'reportUid') this.reportUid = '', @JsonKey(name: 'purpose') this.purpose = 'Join', @JsonKey(name: 'createdByUid') this.createdByUid = '', @JsonKey(name: 'createdByRole') this.createdByRole = '', @JsonKey(name: 'recipientUid') this.recipientUid = '', @JsonKey(name: 'status') this.status = 'Pending', @JsonKey(name: 'attempts') this.attempts = 0, @JsonKey(name: 'reissueCount') this.reissueCount = 0, @JsonKey(name: 'expiresAt') this.expiresAt = '', @JsonKey(name: 'redeemedAt') this.redeemedAt = '', @JsonKey(name: 'notificationUid') this.notificationUid = '', @JsonKey(name: 'createdAt') this.createdAt = '', @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = '', @JsonKey(includeFromJson: false, includeToJson: false) this.synced = true}): super._();
  factory _ShareCodeModel.fromJson(Map<String, dynamic> json) => _$ShareCodeModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'caseUid') final  String caseUid;
@override@JsonKey(name: 'reportUid') final  String reportUid;
@override@JsonKey(name: 'purpose') final  String purpose;
@override@JsonKey(name: 'createdByUid') final  String createdByUid;
@override@JsonKey(name: 'createdByRole') final  String createdByRole;
@override@JsonKey(name: 'recipientUid') final  String recipientUid;
@override@JsonKey(name: 'status') final  String status;
@override@JsonKey(name: 'attempts') final  int attempts;
@override@JsonKey(name: 'reissueCount') final  int reissueCount;
@override@JsonKey(name: 'expiresAt') final  String expiresAt;
@override@JsonKey(name: 'redeemedAt') final  String redeemedAt;
@override@JsonKey(name: 'notificationUid') final  String notificationUid;
@override@JsonKey(name: 'createdAt') final  String createdAt;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool synced;

/// Create a copy of ShareCodeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShareCodeModelCopyWith<_ShareCodeModel> get copyWith => __$ShareCodeModelCopyWithImpl<_ShareCodeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShareCodeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShareCodeModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.caseUid, caseUid) || other.caseUid == caseUid)&&(identical(other.reportUid, reportUid) || other.reportUid == reportUid)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.createdByUid, createdByUid) || other.createdByUid == createdByUid)&&(identical(other.createdByRole, createdByRole) || other.createdByRole == createdByRole)&&(identical(other.recipientUid, recipientUid) || other.recipientUid == recipientUid)&&(identical(other.status, status) || other.status == status)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.reissueCount, reissueCount) || other.reissueCount == reissueCount)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.redeemedAt, redeemedAt) || other.redeemedAt == redeemedAt)&&(identical(other.notificationUid, notificationUid) || other.notificationUid == notificationUid)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,caseUid,reportUid,purpose,createdByUid,createdByRole,recipientUid,status,attempts,reissueCount,expiresAt,redeemedAt,notificationUid,createdAt,lastUpdatedAt,synced);

@override
String toString() {
  return 'ShareCodeModel(uid: $uid, caseUid: $caseUid, reportUid: $reportUid, purpose: $purpose, createdByUid: $createdByUid, createdByRole: $createdByRole, recipientUid: $recipientUid, status: $status, attempts: $attempts, reissueCount: $reissueCount, expiresAt: $expiresAt, redeemedAt: $redeemedAt, notificationUid: $notificationUid, createdAt: $createdAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class _$ShareCodeModelCopyWith<$Res> implements $ShareCodeModelCopyWith<$Res> {
  factory _$ShareCodeModelCopyWith(_ShareCodeModel value, $Res Function(_ShareCodeModel) _then) = __$ShareCodeModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'caseUid') String caseUid,@JsonKey(name: 'reportUid') String reportUid,@JsonKey(name: 'purpose') String purpose,@JsonKey(name: 'createdByUid') String createdByUid,@JsonKey(name: 'createdByRole') String createdByRole,@JsonKey(name: 'recipientUid') String recipientUid,@JsonKey(name: 'status') String status,@JsonKey(name: 'attempts') int attempts,@JsonKey(name: 'reissueCount') int reissueCount,@JsonKey(name: 'expiresAt') String expiresAt,@JsonKey(name: 'redeemedAt') String redeemedAt,@JsonKey(name: 'notificationUid') String notificationUid,@JsonKey(name: 'createdAt') String createdAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class __$ShareCodeModelCopyWithImpl<$Res>
    implements _$ShareCodeModelCopyWith<$Res> {
  __$ShareCodeModelCopyWithImpl(this._self, this._then);

  final _ShareCodeModel _self;
  final $Res Function(_ShareCodeModel) _then;

/// Create a copy of ShareCodeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? caseUid = null,Object? reportUid = null,Object? purpose = null,Object? createdByUid = null,Object? createdByRole = null,Object? recipientUid = null,Object? status = null,Object? attempts = null,Object? reissueCount = null,Object? expiresAt = null,Object? redeemedAt = null,Object? notificationUid = null,Object? createdAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_ShareCodeModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,caseUid: null == caseUid ? _self.caseUid : caseUid // ignore: cast_nullable_to_non_nullable
as String,reportUid: null == reportUid ? _self.reportUid : reportUid // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String,createdByUid: null == createdByUid ? _self.createdByUid : createdByUid // ignore: cast_nullable_to_non_nullable
as String,createdByRole: null == createdByRole ? _self.createdByRole : createdByRole // ignore: cast_nullable_to_non_nullable
as String,recipientUid: null == recipientUid ? _self.recipientUid : recipientUid // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,reissueCount: null == reissueCount ? _self.reissueCount : reissueCount // ignore: cast_nullable_to_non_nullable
as int,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String,redeemedAt: null == redeemedAt ? _self.redeemedAt : redeemedAt // ignore: cast_nullable_to_non_nullable
as String,notificationUid: null == notificationUid ? _self.notificationUid : notificationUid // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
