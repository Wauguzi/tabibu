// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patient_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PatientModel {

@JsonKey(name: 'patientId') String get patientId;@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'isRegistered') bool get isRegistered;@JsonKey(name: 'createdByUid') String get createdByUid;@JsonKey(name: 'firstName') String get firstName;@JsonKey(name: 'middleName') String get middleName;@JsonKey(name: 'lastName') String get lastName;@JsonKey(name: 'sex') String get sex;@JsonKey(name: 'dateOfBirth') String get dateOfBirth;@JsonKey(name: 'phoneNumber') String get phoneNumber;@JsonKey(name: 'email') String get email;@JsonKey(name: 'profilePictureUrl') String get profilePictureUrl;@JsonKey(name: 'county') String get county;@JsonKey(name: 'subCounty') String get subCounty;@JsonKey(name: 'geohash') String get geohash;@JsonKey(name: 'doctorUids') List<String> get doctorUids;@JsonKey(name: 'fcmTokens') List<String> get fcmTokens;@JsonKey(name: 'language') String get language;@JsonKey(name: 'receiveNotifications') bool get receiveNotifications;@JsonKey(name: 'casesReported') int get casesReported;@JsonKey(name: 'appointmentsBooked') int get appointmentsBooked;@JsonKey(name: 'createdAt') String get createdAt;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;@JsonKey(includeFromJson: false, includeToJson: false) bool get synced;
/// Create a copy of PatientModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PatientModelCopyWith<PatientModel> get copyWith => _$PatientModelCopyWithImpl<PatientModel>(this as PatientModel, _$identity);

  /// Serializes this PatientModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PatientModel&&(identical(other.patientId, patientId) || other.patientId == patientId)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.isRegistered, isRegistered) || other.isRegistered == isRegistered)&&(identical(other.createdByUid, createdByUid) || other.createdByUid == createdByUid)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.middleName, middleName) || other.middleName == middleName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl)&&(identical(other.county, county) || other.county == county)&&(identical(other.subCounty, subCounty) || other.subCounty == subCounty)&&(identical(other.geohash, geohash) || other.geohash == geohash)&&const DeepCollectionEquality().equals(other.doctorUids, doctorUids)&&const DeepCollectionEquality().equals(other.fcmTokens, fcmTokens)&&(identical(other.language, language) || other.language == language)&&(identical(other.receiveNotifications, receiveNotifications) || other.receiveNotifications == receiveNotifications)&&(identical(other.casesReported, casesReported) || other.casesReported == casesReported)&&(identical(other.appointmentsBooked, appointmentsBooked) || other.appointmentsBooked == appointmentsBooked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,patientId,uid,isRegistered,createdByUid,firstName,middleName,lastName,sex,dateOfBirth,phoneNumber,email,profilePictureUrl,county,subCounty,geohash,const DeepCollectionEquality().hash(doctorUids),const DeepCollectionEquality().hash(fcmTokens),language,receiveNotifications,casesReported,appointmentsBooked,createdAt,lastUpdatedAt,synced]);

@override
String toString() {
  return 'PatientModel(patientId: $patientId, uid: $uid, isRegistered: $isRegistered, createdByUid: $createdByUid, firstName: $firstName, middleName: $middleName, lastName: $lastName, sex: $sex, dateOfBirth: $dateOfBirth, phoneNumber: $phoneNumber, email: $email, profilePictureUrl: $profilePictureUrl, county: $county, subCounty: $subCounty, geohash: $geohash, doctorUids: $doctorUids, fcmTokens: $fcmTokens, language: $language, receiveNotifications: $receiveNotifications, casesReported: $casesReported, appointmentsBooked: $appointmentsBooked, createdAt: $createdAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class $PatientModelCopyWith<$Res>  {
  factory $PatientModelCopyWith(PatientModel value, $Res Function(PatientModel) _then) = _$PatientModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'patientId') String patientId,@JsonKey(name: 'uid') String uid,@JsonKey(name: 'isRegistered') bool isRegistered,@JsonKey(name: 'createdByUid') String createdByUid,@JsonKey(name: 'firstName') String firstName,@JsonKey(name: 'middleName') String middleName,@JsonKey(name: 'lastName') String lastName,@JsonKey(name: 'sex') String sex,@JsonKey(name: 'dateOfBirth') String dateOfBirth,@JsonKey(name: 'phoneNumber') String phoneNumber,@JsonKey(name: 'email') String email,@JsonKey(name: 'profilePictureUrl') String profilePictureUrl,@JsonKey(name: 'county') String county,@JsonKey(name: 'subCounty') String subCounty,@JsonKey(name: 'geohash') String geohash,@JsonKey(name: 'doctorUids') List<String> doctorUids,@JsonKey(name: 'fcmTokens') List<String> fcmTokens,@JsonKey(name: 'language') String language,@JsonKey(name: 'receiveNotifications') bool receiveNotifications,@JsonKey(name: 'casesReported') int casesReported,@JsonKey(name: 'appointmentsBooked') int appointmentsBooked,@JsonKey(name: 'createdAt') String createdAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class _$PatientModelCopyWithImpl<$Res>
    implements $PatientModelCopyWith<$Res> {
  _$PatientModelCopyWithImpl(this._self, this._then);

  final PatientModel _self;
  final $Res Function(PatientModel) _then;

/// Create a copy of PatientModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? patientId = null,Object? uid = null,Object? isRegistered = null,Object? createdByUid = null,Object? firstName = null,Object? middleName = null,Object? lastName = null,Object? sex = null,Object? dateOfBirth = null,Object? phoneNumber = null,Object? email = null,Object? profilePictureUrl = null,Object? county = null,Object? subCounty = null,Object? geohash = null,Object? doctorUids = null,Object? fcmTokens = null,Object? language = null,Object? receiveNotifications = null,Object? casesReported = null,Object? appointmentsBooked = null,Object? createdAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_self.copyWith(
patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,isRegistered: null == isRegistered ? _self.isRegistered : isRegistered // ignore: cast_nullable_to_non_nullable
as bool,createdByUid: null == createdByUid ? _self.createdByUid : createdByUid // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,middleName: null == middleName ? _self.middleName : middleName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: null == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,profilePictureUrl: null == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String,county: null == county ? _self.county : county // ignore: cast_nullable_to_non_nullable
as String,subCounty: null == subCounty ? _self.subCounty : subCounty // ignore: cast_nullable_to_non_nullable
as String,geohash: null == geohash ? _self.geohash : geohash // ignore: cast_nullable_to_non_nullable
as String,doctorUids: null == doctorUids ? _self.doctorUids : doctorUids // ignore: cast_nullable_to_non_nullable
as List<String>,fcmTokens: null == fcmTokens ? _self.fcmTokens : fcmTokens // ignore: cast_nullable_to_non_nullable
as List<String>,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,receiveNotifications: null == receiveNotifications ? _self.receiveNotifications : receiveNotifications // ignore: cast_nullable_to_non_nullable
as bool,casesReported: null == casesReported ? _self.casesReported : casesReported // ignore: cast_nullable_to_non_nullable
as int,appointmentsBooked: null == appointmentsBooked ? _self.appointmentsBooked : appointmentsBooked // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PatientModel].
extension PatientModelPatterns on PatientModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PatientModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PatientModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PatientModel value)  $default,){
final _that = this;
switch (_that) {
case _PatientModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PatientModel value)?  $default,){
final _that = this;
switch (_that) {
case _PatientModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'patientId')  String patientId, @JsonKey(name: 'uid')  String uid, @JsonKey(name: 'isRegistered')  bool isRegistered, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'firstName')  String firstName, @JsonKey(name: 'middleName')  String middleName, @JsonKey(name: 'lastName')  String lastName, @JsonKey(name: 'sex')  String sex, @JsonKey(name: 'dateOfBirth')  String dateOfBirth, @JsonKey(name: 'phoneNumber')  String phoneNumber, @JsonKey(name: 'email')  String email, @JsonKey(name: 'profilePictureUrl')  String profilePictureUrl, @JsonKey(name: 'county')  String county, @JsonKey(name: 'subCounty')  String subCounty, @JsonKey(name: 'geohash')  String geohash, @JsonKey(name: 'doctorUids')  List<String> doctorUids, @JsonKey(name: 'fcmTokens')  List<String> fcmTokens, @JsonKey(name: 'language')  String language, @JsonKey(name: 'receiveNotifications')  bool receiveNotifications, @JsonKey(name: 'casesReported')  int casesReported, @JsonKey(name: 'appointmentsBooked')  int appointmentsBooked, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PatientModel() when $default != null:
return $default(_that.patientId,_that.uid,_that.isRegistered,_that.createdByUid,_that.firstName,_that.middleName,_that.lastName,_that.sex,_that.dateOfBirth,_that.phoneNumber,_that.email,_that.profilePictureUrl,_that.county,_that.subCounty,_that.geohash,_that.doctorUids,_that.fcmTokens,_that.language,_that.receiveNotifications,_that.casesReported,_that.appointmentsBooked,_that.createdAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'patientId')  String patientId, @JsonKey(name: 'uid')  String uid, @JsonKey(name: 'isRegistered')  bool isRegistered, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'firstName')  String firstName, @JsonKey(name: 'middleName')  String middleName, @JsonKey(name: 'lastName')  String lastName, @JsonKey(name: 'sex')  String sex, @JsonKey(name: 'dateOfBirth')  String dateOfBirth, @JsonKey(name: 'phoneNumber')  String phoneNumber, @JsonKey(name: 'email')  String email, @JsonKey(name: 'profilePictureUrl')  String profilePictureUrl, @JsonKey(name: 'county')  String county, @JsonKey(name: 'subCounty')  String subCounty, @JsonKey(name: 'geohash')  String geohash, @JsonKey(name: 'doctorUids')  List<String> doctorUids, @JsonKey(name: 'fcmTokens')  List<String> fcmTokens, @JsonKey(name: 'language')  String language, @JsonKey(name: 'receiveNotifications')  bool receiveNotifications, @JsonKey(name: 'casesReported')  int casesReported, @JsonKey(name: 'appointmentsBooked')  int appointmentsBooked, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)  $default,) {final _that = this;
switch (_that) {
case _PatientModel():
return $default(_that.patientId,_that.uid,_that.isRegistered,_that.createdByUid,_that.firstName,_that.middleName,_that.lastName,_that.sex,_that.dateOfBirth,_that.phoneNumber,_that.email,_that.profilePictureUrl,_that.county,_that.subCounty,_that.geohash,_that.doctorUids,_that.fcmTokens,_that.language,_that.receiveNotifications,_that.casesReported,_that.appointmentsBooked,_that.createdAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'patientId')  String patientId, @JsonKey(name: 'uid')  String uid, @JsonKey(name: 'isRegistered')  bool isRegistered, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'firstName')  String firstName, @JsonKey(name: 'middleName')  String middleName, @JsonKey(name: 'lastName')  String lastName, @JsonKey(name: 'sex')  String sex, @JsonKey(name: 'dateOfBirth')  String dateOfBirth, @JsonKey(name: 'phoneNumber')  String phoneNumber, @JsonKey(name: 'email')  String email, @JsonKey(name: 'profilePictureUrl')  String profilePictureUrl, @JsonKey(name: 'county')  String county, @JsonKey(name: 'subCounty')  String subCounty, @JsonKey(name: 'geohash')  String geohash, @JsonKey(name: 'doctorUids')  List<String> doctorUids, @JsonKey(name: 'fcmTokens')  List<String> fcmTokens, @JsonKey(name: 'language')  String language, @JsonKey(name: 'receiveNotifications')  bool receiveNotifications, @JsonKey(name: 'casesReported')  int casesReported, @JsonKey(name: 'appointmentsBooked')  int appointmentsBooked, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,) {final _that = this;
switch (_that) {
case _PatientModel() when $default != null:
return $default(_that.patientId,_that.uid,_that.isRegistered,_that.createdByUid,_that.firstName,_that.middleName,_that.lastName,_that.sex,_that.dateOfBirth,_that.phoneNumber,_that.email,_that.profilePictureUrl,_that.county,_that.subCounty,_that.geohash,_that.doctorUids,_that.fcmTokens,_that.language,_that.receiveNotifications,_that.casesReported,_that.appointmentsBooked,_that.createdAt,_that.lastUpdatedAt,_that.synced);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PatientModel extends PatientModel {
  const _PatientModel({@JsonKey(name: 'patientId') required this.patientId, @JsonKey(name: 'uid') required this.uid, @JsonKey(name: 'isRegistered') required this.isRegistered, @JsonKey(name: 'createdByUid') required this.createdByUid, @JsonKey(name: 'firstName') required this.firstName, @JsonKey(name: 'middleName') required this.middleName, @JsonKey(name: 'lastName') required this.lastName, @JsonKey(name: 'sex') required this.sex, @JsonKey(name: 'dateOfBirth') required this.dateOfBirth, @JsonKey(name: 'phoneNumber') required this.phoneNumber, @JsonKey(name: 'email') required this.email, @JsonKey(name: 'profilePictureUrl') required this.profilePictureUrl, @JsonKey(name: 'county') required this.county, @JsonKey(name: 'subCounty') required this.subCounty, @JsonKey(name: 'geohash') required this.geohash, @JsonKey(name: 'doctorUids') required final  List<String> doctorUids, @JsonKey(name: 'fcmTokens') required final  List<String> fcmTokens, @JsonKey(name: 'language') required this.language, @JsonKey(name: 'receiveNotifications') required this.receiveNotifications, @JsonKey(name: 'casesReported') required this.casesReported, @JsonKey(name: 'appointmentsBooked') required this.appointmentsBooked, @JsonKey(name: 'createdAt') required this.createdAt, @JsonKey(name: 'lastUpdatedAt') required this.lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false) this.synced = true}): _doctorUids = doctorUids,_fcmTokens = fcmTokens,super._();
  factory _PatientModel.fromJson(Map<String, dynamic> json) => _$PatientModelFromJson(json);

@override@JsonKey(name: 'patientId') final  String patientId;
@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'isRegistered') final  bool isRegistered;
@override@JsonKey(name: 'createdByUid') final  String createdByUid;
@override@JsonKey(name: 'firstName') final  String firstName;
@override@JsonKey(name: 'middleName') final  String middleName;
@override@JsonKey(name: 'lastName') final  String lastName;
@override@JsonKey(name: 'sex') final  String sex;
@override@JsonKey(name: 'dateOfBirth') final  String dateOfBirth;
@override@JsonKey(name: 'phoneNumber') final  String phoneNumber;
@override@JsonKey(name: 'email') final  String email;
@override@JsonKey(name: 'profilePictureUrl') final  String profilePictureUrl;
@override@JsonKey(name: 'county') final  String county;
@override@JsonKey(name: 'subCounty') final  String subCounty;
@override@JsonKey(name: 'geohash') final  String geohash;
 final  List<String> _doctorUids;
@override@JsonKey(name: 'doctorUids') List<String> get doctorUids {
  if (_doctorUids is EqualUnmodifiableListView) return _doctorUids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_doctorUids);
}

 final  List<String> _fcmTokens;
@override@JsonKey(name: 'fcmTokens') List<String> get fcmTokens {
  if (_fcmTokens is EqualUnmodifiableListView) return _fcmTokens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fcmTokens);
}

@override@JsonKey(name: 'language') final  String language;
@override@JsonKey(name: 'receiveNotifications') final  bool receiveNotifications;
@override@JsonKey(name: 'casesReported') final  int casesReported;
@override@JsonKey(name: 'appointmentsBooked') final  int appointmentsBooked;
@override@JsonKey(name: 'createdAt') final  String createdAt;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool synced;

/// Create a copy of PatientModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PatientModelCopyWith<_PatientModel> get copyWith => __$PatientModelCopyWithImpl<_PatientModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PatientModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PatientModel&&(identical(other.patientId, patientId) || other.patientId == patientId)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.isRegistered, isRegistered) || other.isRegistered == isRegistered)&&(identical(other.createdByUid, createdByUid) || other.createdByUid == createdByUid)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.middleName, middleName) || other.middleName == middleName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl)&&(identical(other.county, county) || other.county == county)&&(identical(other.subCounty, subCounty) || other.subCounty == subCounty)&&(identical(other.geohash, geohash) || other.geohash == geohash)&&const DeepCollectionEquality().equals(other._doctorUids, _doctorUids)&&const DeepCollectionEquality().equals(other._fcmTokens, _fcmTokens)&&(identical(other.language, language) || other.language == language)&&(identical(other.receiveNotifications, receiveNotifications) || other.receiveNotifications == receiveNotifications)&&(identical(other.casesReported, casesReported) || other.casesReported == casesReported)&&(identical(other.appointmentsBooked, appointmentsBooked) || other.appointmentsBooked == appointmentsBooked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,patientId,uid,isRegistered,createdByUid,firstName,middleName,lastName,sex,dateOfBirth,phoneNumber,email,profilePictureUrl,county,subCounty,geohash,const DeepCollectionEquality().hash(_doctorUids),const DeepCollectionEquality().hash(_fcmTokens),language,receiveNotifications,casesReported,appointmentsBooked,createdAt,lastUpdatedAt,synced]);

@override
String toString() {
  return 'PatientModel(patientId: $patientId, uid: $uid, isRegistered: $isRegistered, createdByUid: $createdByUid, firstName: $firstName, middleName: $middleName, lastName: $lastName, sex: $sex, dateOfBirth: $dateOfBirth, phoneNumber: $phoneNumber, email: $email, profilePictureUrl: $profilePictureUrl, county: $county, subCounty: $subCounty, geohash: $geohash, doctorUids: $doctorUids, fcmTokens: $fcmTokens, language: $language, receiveNotifications: $receiveNotifications, casesReported: $casesReported, appointmentsBooked: $appointmentsBooked, createdAt: $createdAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class _$PatientModelCopyWith<$Res> implements $PatientModelCopyWith<$Res> {
  factory _$PatientModelCopyWith(_PatientModel value, $Res Function(_PatientModel) _then) = __$PatientModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'patientId') String patientId,@JsonKey(name: 'uid') String uid,@JsonKey(name: 'isRegistered') bool isRegistered,@JsonKey(name: 'createdByUid') String createdByUid,@JsonKey(name: 'firstName') String firstName,@JsonKey(name: 'middleName') String middleName,@JsonKey(name: 'lastName') String lastName,@JsonKey(name: 'sex') String sex,@JsonKey(name: 'dateOfBirth') String dateOfBirth,@JsonKey(name: 'phoneNumber') String phoneNumber,@JsonKey(name: 'email') String email,@JsonKey(name: 'profilePictureUrl') String profilePictureUrl,@JsonKey(name: 'county') String county,@JsonKey(name: 'subCounty') String subCounty,@JsonKey(name: 'geohash') String geohash,@JsonKey(name: 'doctorUids') List<String> doctorUids,@JsonKey(name: 'fcmTokens') List<String> fcmTokens,@JsonKey(name: 'language') String language,@JsonKey(name: 'receiveNotifications') bool receiveNotifications,@JsonKey(name: 'casesReported') int casesReported,@JsonKey(name: 'appointmentsBooked') int appointmentsBooked,@JsonKey(name: 'createdAt') String createdAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class __$PatientModelCopyWithImpl<$Res>
    implements _$PatientModelCopyWith<$Res> {
  __$PatientModelCopyWithImpl(this._self, this._then);

  final _PatientModel _self;
  final $Res Function(_PatientModel) _then;

/// Create a copy of PatientModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? patientId = null,Object? uid = null,Object? isRegistered = null,Object? createdByUid = null,Object? firstName = null,Object? middleName = null,Object? lastName = null,Object? sex = null,Object? dateOfBirth = null,Object? phoneNumber = null,Object? email = null,Object? profilePictureUrl = null,Object? county = null,Object? subCounty = null,Object? geohash = null,Object? doctorUids = null,Object? fcmTokens = null,Object? language = null,Object? receiveNotifications = null,Object? casesReported = null,Object? appointmentsBooked = null,Object? createdAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_PatientModel(
patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,isRegistered: null == isRegistered ? _self.isRegistered : isRegistered // ignore: cast_nullable_to_non_nullable
as bool,createdByUid: null == createdByUid ? _self.createdByUid : createdByUid // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,middleName: null == middleName ? _self.middleName : middleName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: null == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,profilePictureUrl: null == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String,county: null == county ? _self.county : county // ignore: cast_nullable_to_non_nullable
as String,subCounty: null == subCounty ? _self.subCounty : subCounty // ignore: cast_nullable_to_non_nullable
as String,geohash: null == geohash ? _self.geohash : geohash // ignore: cast_nullable_to_non_nullable
as String,doctorUids: null == doctorUids ? _self._doctorUids : doctorUids // ignore: cast_nullable_to_non_nullable
as List<String>,fcmTokens: null == fcmTokens ? _self._fcmTokens : fcmTokens // ignore: cast_nullable_to_non_nullable
as List<String>,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,receiveNotifications: null == receiveNotifications ? _self.receiveNotifications : receiveNotifications // ignore: cast_nullable_to_non_nullable
as bool,casesReported: null == casesReported ? _self.casesReported : casesReported // ignore: cast_nullable_to_non_nullable
as int,appointmentsBooked: null == appointmentsBooked ? _self.appointmentsBooked : appointmentsBooked // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
