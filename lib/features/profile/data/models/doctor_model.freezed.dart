// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'doctor_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DoctorModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'title') String get title;@JsonKey(name: 'firstName') String get firstName;@JsonKey(name: 'lastName') String get lastName;@JsonKey(name: 'email') String get email;@JsonKey(name: 'phoneNumber') String get phoneNumber;@JsonKey(name: 'profilePictureUrl') String get profilePictureUrl;@JsonKey(name: 'isPathologist') bool get isPathologist;@JsonKey(name: 'specialization') String get specialization;@JsonKey(name: 'bio') String get bio;@JsonKey(name: 'kmpdcNumber') String get kmpdcNumber;@JsonKey(name: 'licenseUrl') String get licenseUrl;@JsonKey(name: 'verificationStatus') String get verificationStatus;@JsonKey(name: 'facilityId') String get facilityId;@JsonKey(name: 'facilityMflCode') String get facilityMflCode;@JsonKey(name: 'facilityName') String get facilityName;@JsonKey(name: 'county') String get county;@JsonKey(name: 'subCounty') String get subCounty;@JsonKey(name: 'geohash') String get geohash;@JsonKey(name: 'isAvailable') bool get isAvailable;@JsonKey(name: 'fcmTokens') List<String> get fcmTokens;@JsonKey(name: 'language') String get language;@JsonKey(name: 'receiveNotifications') bool get receiveNotifications;@JsonKey(name: 'appointmentsHandled') int get appointmentsHandled;@JsonKey(name: 'ordersCreated') int get ordersCreated;@JsonKey(name: 'reportsSigned') int get reportsSigned;@JsonKey(name: 'termsAcceptedAt') String get termsAcceptedAt;@JsonKey(name: 'createdAt') String get createdAt;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;@JsonKey(includeFromJson: false, includeToJson: false) bool get synced;
/// Create a copy of DoctorModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoctorModelCopyWith<DoctorModel> get copyWith => _$DoctorModelCopyWithImpl<DoctorModel>(this as DoctorModel, _$identity);

  /// Serializes this DoctorModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoctorModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.title, title) || other.title == title)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl)&&(identical(other.isPathologist, isPathologist) || other.isPathologist == isPathologist)&&(identical(other.specialization, specialization) || other.specialization == specialization)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.kmpdcNumber, kmpdcNumber) || other.kmpdcNumber == kmpdcNumber)&&(identical(other.licenseUrl, licenseUrl) || other.licenseUrl == licenseUrl)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.facilityMflCode, facilityMflCode) || other.facilityMflCode == facilityMflCode)&&(identical(other.facilityName, facilityName) || other.facilityName == facilityName)&&(identical(other.county, county) || other.county == county)&&(identical(other.subCounty, subCounty) || other.subCounty == subCounty)&&(identical(other.geohash, geohash) || other.geohash == geohash)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&const DeepCollectionEquality().equals(other.fcmTokens, fcmTokens)&&(identical(other.language, language) || other.language == language)&&(identical(other.receiveNotifications, receiveNotifications) || other.receiveNotifications == receiveNotifications)&&(identical(other.appointmentsHandled, appointmentsHandled) || other.appointmentsHandled == appointmentsHandled)&&(identical(other.ordersCreated, ordersCreated) || other.ordersCreated == ordersCreated)&&(identical(other.reportsSigned, reportsSigned) || other.reportsSigned == reportsSigned)&&(identical(other.termsAcceptedAt, termsAcceptedAt) || other.termsAcceptedAt == termsAcceptedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,title,firstName,lastName,email,phoneNumber,profilePictureUrl,isPathologist,specialization,bio,kmpdcNumber,licenseUrl,verificationStatus,facilityId,facilityMflCode,facilityName,county,subCounty,geohash,isAvailable,const DeepCollectionEquality().hash(fcmTokens),language,receiveNotifications,appointmentsHandled,ordersCreated,reportsSigned,termsAcceptedAt,createdAt,lastUpdatedAt,synced]);

@override
String toString() {
  return 'DoctorModel(uid: $uid, title: $title, firstName: $firstName, lastName: $lastName, email: $email, phoneNumber: $phoneNumber, profilePictureUrl: $profilePictureUrl, isPathologist: $isPathologist, specialization: $specialization, bio: $bio, kmpdcNumber: $kmpdcNumber, licenseUrl: $licenseUrl, verificationStatus: $verificationStatus, facilityId: $facilityId, facilityMflCode: $facilityMflCode, facilityName: $facilityName, county: $county, subCounty: $subCounty, geohash: $geohash, isAvailable: $isAvailable, fcmTokens: $fcmTokens, language: $language, receiveNotifications: $receiveNotifications, appointmentsHandled: $appointmentsHandled, ordersCreated: $ordersCreated, reportsSigned: $reportsSigned, termsAcceptedAt: $termsAcceptedAt, createdAt: $createdAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class $DoctorModelCopyWith<$Res>  {
  factory $DoctorModelCopyWith(DoctorModel value, $Res Function(DoctorModel) _then) = _$DoctorModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'title') String title,@JsonKey(name: 'firstName') String firstName,@JsonKey(name: 'lastName') String lastName,@JsonKey(name: 'email') String email,@JsonKey(name: 'phoneNumber') String phoneNumber,@JsonKey(name: 'profilePictureUrl') String profilePictureUrl,@JsonKey(name: 'isPathologist') bool isPathologist,@JsonKey(name: 'specialization') String specialization,@JsonKey(name: 'bio') String bio,@JsonKey(name: 'kmpdcNumber') String kmpdcNumber,@JsonKey(name: 'licenseUrl') String licenseUrl,@JsonKey(name: 'verificationStatus') String verificationStatus,@JsonKey(name: 'facilityId') String facilityId,@JsonKey(name: 'facilityMflCode') String facilityMflCode,@JsonKey(name: 'facilityName') String facilityName,@JsonKey(name: 'county') String county,@JsonKey(name: 'subCounty') String subCounty,@JsonKey(name: 'geohash') String geohash,@JsonKey(name: 'isAvailable') bool isAvailable,@JsonKey(name: 'fcmTokens') List<String> fcmTokens,@JsonKey(name: 'language') String language,@JsonKey(name: 'receiveNotifications') bool receiveNotifications,@JsonKey(name: 'appointmentsHandled') int appointmentsHandled,@JsonKey(name: 'ordersCreated') int ordersCreated,@JsonKey(name: 'reportsSigned') int reportsSigned,@JsonKey(name: 'termsAcceptedAt') String termsAcceptedAt,@JsonKey(name: 'createdAt') String createdAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class _$DoctorModelCopyWithImpl<$Res>
    implements $DoctorModelCopyWith<$Res> {
  _$DoctorModelCopyWithImpl(this._self, this._then);

  final DoctorModel _self;
  final $Res Function(DoctorModel) _then;

/// Create a copy of DoctorModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? title = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? phoneNumber = null,Object? profilePictureUrl = null,Object? isPathologist = null,Object? specialization = null,Object? bio = null,Object? kmpdcNumber = null,Object? licenseUrl = null,Object? verificationStatus = null,Object? facilityId = null,Object? facilityMflCode = null,Object? facilityName = null,Object? county = null,Object? subCounty = null,Object? geohash = null,Object? isAvailable = null,Object? fcmTokens = null,Object? language = null,Object? receiveNotifications = null,Object? appointmentsHandled = null,Object? ordersCreated = null,Object? reportsSigned = null,Object? termsAcceptedAt = null,Object? createdAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,profilePictureUrl: null == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String,isPathologist: null == isPathologist ? _self.isPathologist : isPathologist // ignore: cast_nullable_to_non_nullable
as bool,specialization: null == specialization ? _self.specialization : specialization // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,kmpdcNumber: null == kmpdcNumber ? _self.kmpdcNumber : kmpdcNumber // ignore: cast_nullable_to_non_nullable
as String,licenseUrl: null == licenseUrl ? _self.licenseUrl : licenseUrl // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as String,facilityMflCode: null == facilityMflCode ? _self.facilityMflCode : facilityMflCode // ignore: cast_nullable_to_non_nullable
as String,facilityName: null == facilityName ? _self.facilityName : facilityName // ignore: cast_nullable_to_non_nullable
as String,county: null == county ? _self.county : county // ignore: cast_nullable_to_non_nullable
as String,subCounty: null == subCounty ? _self.subCounty : subCounty // ignore: cast_nullable_to_non_nullable
as String,geohash: null == geohash ? _self.geohash : geohash // ignore: cast_nullable_to_non_nullable
as String,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,fcmTokens: null == fcmTokens ? _self.fcmTokens : fcmTokens // ignore: cast_nullable_to_non_nullable
as List<String>,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,receiveNotifications: null == receiveNotifications ? _self.receiveNotifications : receiveNotifications // ignore: cast_nullable_to_non_nullable
as bool,appointmentsHandled: null == appointmentsHandled ? _self.appointmentsHandled : appointmentsHandled // ignore: cast_nullable_to_non_nullable
as int,ordersCreated: null == ordersCreated ? _self.ordersCreated : ordersCreated // ignore: cast_nullable_to_non_nullable
as int,reportsSigned: null == reportsSigned ? _self.reportsSigned : reportsSigned // ignore: cast_nullable_to_non_nullable
as int,termsAcceptedAt: null == termsAcceptedAt ? _self.termsAcceptedAt : termsAcceptedAt // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DoctorModel].
extension DoctorModelPatterns on DoctorModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DoctorModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DoctorModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DoctorModel value)  $default,){
final _that = this;
switch (_that) {
case _DoctorModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DoctorModel value)?  $default,){
final _that = this;
switch (_that) {
case _DoctorModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'title')  String title, @JsonKey(name: 'firstName')  String firstName, @JsonKey(name: 'lastName')  String lastName, @JsonKey(name: 'email')  String email, @JsonKey(name: 'phoneNumber')  String phoneNumber, @JsonKey(name: 'profilePictureUrl')  String profilePictureUrl, @JsonKey(name: 'isPathologist')  bool isPathologist, @JsonKey(name: 'specialization')  String specialization, @JsonKey(name: 'bio')  String bio, @JsonKey(name: 'kmpdcNumber')  String kmpdcNumber, @JsonKey(name: 'licenseUrl')  String licenseUrl, @JsonKey(name: 'verificationStatus')  String verificationStatus, @JsonKey(name: 'facilityId')  String facilityId, @JsonKey(name: 'facilityMflCode')  String facilityMflCode, @JsonKey(name: 'facilityName')  String facilityName, @JsonKey(name: 'county')  String county, @JsonKey(name: 'subCounty')  String subCounty, @JsonKey(name: 'geohash')  String geohash, @JsonKey(name: 'isAvailable')  bool isAvailable, @JsonKey(name: 'fcmTokens')  List<String> fcmTokens, @JsonKey(name: 'language')  String language, @JsonKey(name: 'receiveNotifications')  bool receiveNotifications, @JsonKey(name: 'appointmentsHandled')  int appointmentsHandled, @JsonKey(name: 'ordersCreated')  int ordersCreated, @JsonKey(name: 'reportsSigned')  int reportsSigned, @JsonKey(name: 'termsAcceptedAt')  String termsAcceptedAt, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DoctorModel() when $default != null:
return $default(_that.uid,_that.title,_that.firstName,_that.lastName,_that.email,_that.phoneNumber,_that.profilePictureUrl,_that.isPathologist,_that.specialization,_that.bio,_that.kmpdcNumber,_that.licenseUrl,_that.verificationStatus,_that.facilityId,_that.facilityMflCode,_that.facilityName,_that.county,_that.subCounty,_that.geohash,_that.isAvailable,_that.fcmTokens,_that.language,_that.receiveNotifications,_that.appointmentsHandled,_that.ordersCreated,_that.reportsSigned,_that.termsAcceptedAt,_that.createdAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'title')  String title, @JsonKey(name: 'firstName')  String firstName, @JsonKey(name: 'lastName')  String lastName, @JsonKey(name: 'email')  String email, @JsonKey(name: 'phoneNumber')  String phoneNumber, @JsonKey(name: 'profilePictureUrl')  String profilePictureUrl, @JsonKey(name: 'isPathologist')  bool isPathologist, @JsonKey(name: 'specialization')  String specialization, @JsonKey(name: 'bio')  String bio, @JsonKey(name: 'kmpdcNumber')  String kmpdcNumber, @JsonKey(name: 'licenseUrl')  String licenseUrl, @JsonKey(name: 'verificationStatus')  String verificationStatus, @JsonKey(name: 'facilityId')  String facilityId, @JsonKey(name: 'facilityMflCode')  String facilityMflCode, @JsonKey(name: 'facilityName')  String facilityName, @JsonKey(name: 'county')  String county, @JsonKey(name: 'subCounty')  String subCounty, @JsonKey(name: 'geohash')  String geohash, @JsonKey(name: 'isAvailable')  bool isAvailable, @JsonKey(name: 'fcmTokens')  List<String> fcmTokens, @JsonKey(name: 'language')  String language, @JsonKey(name: 'receiveNotifications')  bool receiveNotifications, @JsonKey(name: 'appointmentsHandled')  int appointmentsHandled, @JsonKey(name: 'ordersCreated')  int ordersCreated, @JsonKey(name: 'reportsSigned')  int reportsSigned, @JsonKey(name: 'termsAcceptedAt')  String termsAcceptedAt, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)  $default,) {final _that = this;
switch (_that) {
case _DoctorModel():
return $default(_that.uid,_that.title,_that.firstName,_that.lastName,_that.email,_that.phoneNumber,_that.profilePictureUrl,_that.isPathologist,_that.specialization,_that.bio,_that.kmpdcNumber,_that.licenseUrl,_that.verificationStatus,_that.facilityId,_that.facilityMflCode,_that.facilityName,_that.county,_that.subCounty,_that.geohash,_that.isAvailable,_that.fcmTokens,_that.language,_that.receiveNotifications,_that.appointmentsHandled,_that.ordersCreated,_that.reportsSigned,_that.termsAcceptedAt,_that.createdAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'title')  String title, @JsonKey(name: 'firstName')  String firstName, @JsonKey(name: 'lastName')  String lastName, @JsonKey(name: 'email')  String email, @JsonKey(name: 'phoneNumber')  String phoneNumber, @JsonKey(name: 'profilePictureUrl')  String profilePictureUrl, @JsonKey(name: 'isPathologist')  bool isPathologist, @JsonKey(name: 'specialization')  String specialization, @JsonKey(name: 'bio')  String bio, @JsonKey(name: 'kmpdcNumber')  String kmpdcNumber, @JsonKey(name: 'licenseUrl')  String licenseUrl, @JsonKey(name: 'verificationStatus')  String verificationStatus, @JsonKey(name: 'facilityId')  String facilityId, @JsonKey(name: 'facilityMflCode')  String facilityMflCode, @JsonKey(name: 'facilityName')  String facilityName, @JsonKey(name: 'county')  String county, @JsonKey(name: 'subCounty')  String subCounty, @JsonKey(name: 'geohash')  String geohash, @JsonKey(name: 'isAvailable')  bool isAvailable, @JsonKey(name: 'fcmTokens')  List<String> fcmTokens, @JsonKey(name: 'language')  String language, @JsonKey(name: 'receiveNotifications')  bool receiveNotifications, @JsonKey(name: 'appointmentsHandled')  int appointmentsHandled, @JsonKey(name: 'ordersCreated')  int ordersCreated, @JsonKey(name: 'reportsSigned')  int reportsSigned, @JsonKey(name: 'termsAcceptedAt')  String termsAcceptedAt, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,) {final _that = this;
switch (_that) {
case _DoctorModel() when $default != null:
return $default(_that.uid,_that.title,_that.firstName,_that.lastName,_that.email,_that.phoneNumber,_that.profilePictureUrl,_that.isPathologist,_that.specialization,_that.bio,_that.kmpdcNumber,_that.licenseUrl,_that.verificationStatus,_that.facilityId,_that.facilityMflCode,_that.facilityName,_that.county,_that.subCounty,_that.geohash,_that.isAvailable,_that.fcmTokens,_that.language,_that.receiveNotifications,_that.appointmentsHandled,_that.ordersCreated,_that.reportsSigned,_that.termsAcceptedAt,_that.createdAt,_that.lastUpdatedAt,_that.synced);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DoctorModel extends DoctorModel {
  const _DoctorModel({@JsonKey(name: 'uid') required this.uid, @JsonKey(name: 'title') required this.title, @JsonKey(name: 'firstName') required this.firstName, @JsonKey(name: 'lastName') required this.lastName, @JsonKey(name: 'email') required this.email, @JsonKey(name: 'phoneNumber') required this.phoneNumber, @JsonKey(name: 'profilePictureUrl') required this.profilePictureUrl, @JsonKey(name: 'isPathologist') required this.isPathologist, @JsonKey(name: 'specialization') required this.specialization, @JsonKey(name: 'bio') required this.bio, @JsonKey(name: 'kmpdcNumber') required this.kmpdcNumber, @JsonKey(name: 'licenseUrl') required this.licenseUrl, @JsonKey(name: 'verificationStatus') required this.verificationStatus, @JsonKey(name: 'facilityId') required this.facilityId, @JsonKey(name: 'facilityMflCode') required this.facilityMflCode, @JsonKey(name: 'facilityName') required this.facilityName, @JsonKey(name: 'county') required this.county, @JsonKey(name: 'subCounty') required this.subCounty, @JsonKey(name: 'geohash') required this.geohash, @JsonKey(name: 'isAvailable') required this.isAvailable, @JsonKey(name: 'fcmTokens') required final  List<String> fcmTokens, @JsonKey(name: 'language') required this.language, @JsonKey(name: 'receiveNotifications') required this.receiveNotifications, @JsonKey(name: 'appointmentsHandled') required this.appointmentsHandled, @JsonKey(name: 'ordersCreated') required this.ordersCreated, @JsonKey(name: 'reportsSigned') required this.reportsSigned, @JsonKey(name: 'termsAcceptedAt') required this.termsAcceptedAt, @JsonKey(name: 'createdAt') required this.createdAt, @JsonKey(name: 'lastUpdatedAt') required this.lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false) this.synced = true}): _fcmTokens = fcmTokens,super._();
  factory _DoctorModel.fromJson(Map<String, dynamic> json) => _$DoctorModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'title') final  String title;
@override@JsonKey(name: 'firstName') final  String firstName;
@override@JsonKey(name: 'lastName') final  String lastName;
@override@JsonKey(name: 'email') final  String email;
@override@JsonKey(name: 'phoneNumber') final  String phoneNumber;
@override@JsonKey(name: 'profilePictureUrl') final  String profilePictureUrl;
@override@JsonKey(name: 'isPathologist') final  bool isPathologist;
@override@JsonKey(name: 'specialization') final  String specialization;
@override@JsonKey(name: 'bio') final  String bio;
@override@JsonKey(name: 'kmpdcNumber') final  String kmpdcNumber;
@override@JsonKey(name: 'licenseUrl') final  String licenseUrl;
@override@JsonKey(name: 'verificationStatus') final  String verificationStatus;
@override@JsonKey(name: 'facilityId') final  String facilityId;
@override@JsonKey(name: 'facilityMflCode') final  String facilityMflCode;
@override@JsonKey(name: 'facilityName') final  String facilityName;
@override@JsonKey(name: 'county') final  String county;
@override@JsonKey(name: 'subCounty') final  String subCounty;
@override@JsonKey(name: 'geohash') final  String geohash;
@override@JsonKey(name: 'isAvailable') final  bool isAvailable;
 final  List<String> _fcmTokens;
@override@JsonKey(name: 'fcmTokens') List<String> get fcmTokens {
  if (_fcmTokens is EqualUnmodifiableListView) return _fcmTokens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fcmTokens);
}

@override@JsonKey(name: 'language') final  String language;
@override@JsonKey(name: 'receiveNotifications') final  bool receiveNotifications;
@override@JsonKey(name: 'appointmentsHandled') final  int appointmentsHandled;
@override@JsonKey(name: 'ordersCreated') final  int ordersCreated;
@override@JsonKey(name: 'reportsSigned') final  int reportsSigned;
@override@JsonKey(name: 'termsAcceptedAt') final  String termsAcceptedAt;
@override@JsonKey(name: 'createdAt') final  String createdAt;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool synced;

/// Create a copy of DoctorModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoctorModelCopyWith<_DoctorModel> get copyWith => __$DoctorModelCopyWithImpl<_DoctorModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DoctorModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DoctorModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.title, title) || other.title == title)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl)&&(identical(other.isPathologist, isPathologist) || other.isPathologist == isPathologist)&&(identical(other.specialization, specialization) || other.specialization == specialization)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.kmpdcNumber, kmpdcNumber) || other.kmpdcNumber == kmpdcNumber)&&(identical(other.licenseUrl, licenseUrl) || other.licenseUrl == licenseUrl)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.facilityMflCode, facilityMflCode) || other.facilityMflCode == facilityMflCode)&&(identical(other.facilityName, facilityName) || other.facilityName == facilityName)&&(identical(other.county, county) || other.county == county)&&(identical(other.subCounty, subCounty) || other.subCounty == subCounty)&&(identical(other.geohash, geohash) || other.geohash == geohash)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&const DeepCollectionEquality().equals(other._fcmTokens, _fcmTokens)&&(identical(other.language, language) || other.language == language)&&(identical(other.receiveNotifications, receiveNotifications) || other.receiveNotifications == receiveNotifications)&&(identical(other.appointmentsHandled, appointmentsHandled) || other.appointmentsHandled == appointmentsHandled)&&(identical(other.ordersCreated, ordersCreated) || other.ordersCreated == ordersCreated)&&(identical(other.reportsSigned, reportsSigned) || other.reportsSigned == reportsSigned)&&(identical(other.termsAcceptedAt, termsAcceptedAt) || other.termsAcceptedAt == termsAcceptedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,title,firstName,lastName,email,phoneNumber,profilePictureUrl,isPathologist,specialization,bio,kmpdcNumber,licenseUrl,verificationStatus,facilityId,facilityMflCode,facilityName,county,subCounty,geohash,isAvailable,const DeepCollectionEquality().hash(_fcmTokens),language,receiveNotifications,appointmentsHandled,ordersCreated,reportsSigned,termsAcceptedAt,createdAt,lastUpdatedAt,synced]);

@override
String toString() {
  return 'DoctorModel(uid: $uid, title: $title, firstName: $firstName, lastName: $lastName, email: $email, phoneNumber: $phoneNumber, profilePictureUrl: $profilePictureUrl, isPathologist: $isPathologist, specialization: $specialization, bio: $bio, kmpdcNumber: $kmpdcNumber, licenseUrl: $licenseUrl, verificationStatus: $verificationStatus, facilityId: $facilityId, facilityMflCode: $facilityMflCode, facilityName: $facilityName, county: $county, subCounty: $subCounty, geohash: $geohash, isAvailable: $isAvailable, fcmTokens: $fcmTokens, language: $language, receiveNotifications: $receiveNotifications, appointmentsHandled: $appointmentsHandled, ordersCreated: $ordersCreated, reportsSigned: $reportsSigned, termsAcceptedAt: $termsAcceptedAt, createdAt: $createdAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class _$DoctorModelCopyWith<$Res> implements $DoctorModelCopyWith<$Res> {
  factory _$DoctorModelCopyWith(_DoctorModel value, $Res Function(_DoctorModel) _then) = __$DoctorModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'title') String title,@JsonKey(name: 'firstName') String firstName,@JsonKey(name: 'lastName') String lastName,@JsonKey(name: 'email') String email,@JsonKey(name: 'phoneNumber') String phoneNumber,@JsonKey(name: 'profilePictureUrl') String profilePictureUrl,@JsonKey(name: 'isPathologist') bool isPathologist,@JsonKey(name: 'specialization') String specialization,@JsonKey(name: 'bio') String bio,@JsonKey(name: 'kmpdcNumber') String kmpdcNumber,@JsonKey(name: 'licenseUrl') String licenseUrl,@JsonKey(name: 'verificationStatus') String verificationStatus,@JsonKey(name: 'facilityId') String facilityId,@JsonKey(name: 'facilityMflCode') String facilityMflCode,@JsonKey(name: 'facilityName') String facilityName,@JsonKey(name: 'county') String county,@JsonKey(name: 'subCounty') String subCounty,@JsonKey(name: 'geohash') String geohash,@JsonKey(name: 'isAvailable') bool isAvailable,@JsonKey(name: 'fcmTokens') List<String> fcmTokens,@JsonKey(name: 'language') String language,@JsonKey(name: 'receiveNotifications') bool receiveNotifications,@JsonKey(name: 'appointmentsHandled') int appointmentsHandled,@JsonKey(name: 'ordersCreated') int ordersCreated,@JsonKey(name: 'reportsSigned') int reportsSigned,@JsonKey(name: 'termsAcceptedAt') String termsAcceptedAt,@JsonKey(name: 'createdAt') String createdAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class __$DoctorModelCopyWithImpl<$Res>
    implements _$DoctorModelCopyWith<$Res> {
  __$DoctorModelCopyWithImpl(this._self, this._then);

  final _DoctorModel _self;
  final $Res Function(_DoctorModel) _then;

/// Create a copy of DoctorModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? title = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? phoneNumber = null,Object? profilePictureUrl = null,Object? isPathologist = null,Object? specialization = null,Object? bio = null,Object? kmpdcNumber = null,Object? licenseUrl = null,Object? verificationStatus = null,Object? facilityId = null,Object? facilityMflCode = null,Object? facilityName = null,Object? county = null,Object? subCounty = null,Object? geohash = null,Object? isAvailable = null,Object? fcmTokens = null,Object? language = null,Object? receiveNotifications = null,Object? appointmentsHandled = null,Object? ordersCreated = null,Object? reportsSigned = null,Object? termsAcceptedAt = null,Object? createdAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_DoctorModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,profilePictureUrl: null == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String,isPathologist: null == isPathologist ? _self.isPathologist : isPathologist // ignore: cast_nullable_to_non_nullable
as bool,specialization: null == specialization ? _self.specialization : specialization // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,kmpdcNumber: null == kmpdcNumber ? _self.kmpdcNumber : kmpdcNumber // ignore: cast_nullable_to_non_nullable
as String,licenseUrl: null == licenseUrl ? _self.licenseUrl : licenseUrl // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as String,facilityMflCode: null == facilityMflCode ? _self.facilityMflCode : facilityMflCode // ignore: cast_nullable_to_non_nullable
as String,facilityName: null == facilityName ? _self.facilityName : facilityName // ignore: cast_nullable_to_non_nullable
as String,county: null == county ? _self.county : county // ignore: cast_nullable_to_non_nullable
as String,subCounty: null == subCounty ? _self.subCounty : subCounty // ignore: cast_nullable_to_non_nullable
as String,geohash: null == geohash ? _self.geohash : geohash // ignore: cast_nullable_to_non_nullable
as String,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,fcmTokens: null == fcmTokens ? _self._fcmTokens : fcmTokens // ignore: cast_nullable_to_non_nullable
as List<String>,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,receiveNotifications: null == receiveNotifications ? _self.receiveNotifications : receiveNotifications // ignore: cast_nullable_to_non_nullable
as bool,appointmentsHandled: null == appointmentsHandled ? _self.appointmentsHandled : appointmentsHandled // ignore: cast_nullable_to_non_nullable
as int,ordersCreated: null == ordersCreated ? _self.ordersCreated : ordersCreated // ignore: cast_nullable_to_non_nullable
as int,reportsSigned: null == reportsSigned ? _self.reportsSigned : reportsSigned // ignore: cast_nullable_to_non_nullable
as int,termsAcceptedAt: null == termsAcceptedAt ? _self.termsAcceptedAt : termsAcceptedAt // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
