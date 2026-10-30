// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'practitioner_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PractitionerModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'title') String get title;@JsonKey(name: 'firstName') String get firstName;@JsonKey(name: 'lastName') String get lastName;@JsonKey(name: 'profilePictureUrl') String get profilePictureUrl;@JsonKey(name: 'isPathologist') bool get isPathologist;@JsonKey(name: 'specialties') List<String> get specialties;@JsonKey(name: 'bio') String get bio;@JsonKey(name: 'facilityId') String get facilityId;@JsonKey(name: 'facilityMflCode') String get facilityMflCode;@JsonKey(name: 'facilityName') String get facilityName;@JsonKey(name: 'county') String get county;@JsonKey(name: 'subCounty') String get subCounty;@JsonKey(name: 'geohash') String get geohash;@JsonKey(name: 'isAvailable') bool get isAvailable;@JsonKey(name: 'appointmentsHandled') int get appointmentsHandled;@JsonKey(name: 'ordersCreated') int get ordersCreated;@JsonKey(name: 'reportsSigned') int get reportsSigned;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;@JsonKey(includeFromJson: false, includeToJson: false) bool get synced;
/// Create a copy of PractitionerModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PractitionerModelCopyWith<PractitionerModel> get copyWith => _$PractitionerModelCopyWithImpl<PractitionerModel>(this as PractitionerModel, _$identity);

  /// Serializes this PractitionerModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PractitionerModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.title, title) || other.title == title)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl)&&(identical(other.isPathologist, isPathologist) || other.isPathologist == isPathologist)&&const DeepCollectionEquality().equals(other.specialties, specialties)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.facilityMflCode, facilityMflCode) || other.facilityMflCode == facilityMflCode)&&(identical(other.facilityName, facilityName) || other.facilityName == facilityName)&&(identical(other.county, county) || other.county == county)&&(identical(other.subCounty, subCounty) || other.subCounty == subCounty)&&(identical(other.geohash, geohash) || other.geohash == geohash)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.appointmentsHandled, appointmentsHandled) || other.appointmentsHandled == appointmentsHandled)&&(identical(other.ordersCreated, ordersCreated) || other.ordersCreated == ordersCreated)&&(identical(other.reportsSigned, reportsSigned) || other.reportsSigned == reportsSigned)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,title,firstName,lastName,profilePictureUrl,isPathologist,const DeepCollectionEquality().hash(specialties),bio,facilityId,facilityMflCode,facilityName,county,subCounty,geohash,isAvailable,appointmentsHandled,ordersCreated,reportsSigned,lastUpdatedAt,synced]);

@override
String toString() {
  return 'PractitionerModel(uid: $uid, title: $title, firstName: $firstName, lastName: $lastName, profilePictureUrl: $profilePictureUrl, isPathologist: $isPathologist, specialties: $specialties, bio: $bio, facilityId: $facilityId, facilityMflCode: $facilityMflCode, facilityName: $facilityName, county: $county, subCounty: $subCounty, geohash: $geohash, isAvailable: $isAvailable, appointmentsHandled: $appointmentsHandled, ordersCreated: $ordersCreated, reportsSigned: $reportsSigned, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class $PractitionerModelCopyWith<$Res>  {
  factory $PractitionerModelCopyWith(PractitionerModel value, $Res Function(PractitionerModel) _then) = _$PractitionerModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'title') String title,@JsonKey(name: 'firstName') String firstName,@JsonKey(name: 'lastName') String lastName,@JsonKey(name: 'profilePictureUrl') String profilePictureUrl,@JsonKey(name: 'isPathologist') bool isPathologist,@JsonKey(name: 'specialties') List<String> specialties,@JsonKey(name: 'bio') String bio,@JsonKey(name: 'facilityId') String facilityId,@JsonKey(name: 'facilityMflCode') String facilityMflCode,@JsonKey(name: 'facilityName') String facilityName,@JsonKey(name: 'county') String county,@JsonKey(name: 'subCounty') String subCounty,@JsonKey(name: 'geohash') String geohash,@JsonKey(name: 'isAvailable') bool isAvailable,@JsonKey(name: 'appointmentsHandled') int appointmentsHandled,@JsonKey(name: 'ordersCreated') int ordersCreated,@JsonKey(name: 'reportsSigned') int reportsSigned,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class _$PractitionerModelCopyWithImpl<$Res>
    implements $PractitionerModelCopyWith<$Res> {
  _$PractitionerModelCopyWithImpl(this._self, this._then);

  final PractitionerModel _self;
  final $Res Function(PractitionerModel) _then;

/// Create a copy of PractitionerModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? title = null,Object? firstName = null,Object? lastName = null,Object? profilePictureUrl = null,Object? isPathologist = null,Object? specialties = null,Object? bio = null,Object? facilityId = null,Object? facilityMflCode = null,Object? facilityName = null,Object? county = null,Object? subCounty = null,Object? geohash = null,Object? isAvailable = null,Object? appointmentsHandled = null,Object? ordersCreated = null,Object? reportsSigned = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,profilePictureUrl: null == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String,isPathologist: null == isPathologist ? _self.isPathologist : isPathologist // ignore: cast_nullable_to_non_nullable
as bool,specialties: null == specialties ? _self.specialties : specialties // ignore: cast_nullable_to_non_nullable
as List<String>,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as String,facilityMflCode: null == facilityMflCode ? _self.facilityMflCode : facilityMflCode // ignore: cast_nullable_to_non_nullable
as String,facilityName: null == facilityName ? _self.facilityName : facilityName // ignore: cast_nullable_to_non_nullable
as String,county: null == county ? _self.county : county // ignore: cast_nullable_to_non_nullable
as String,subCounty: null == subCounty ? _self.subCounty : subCounty // ignore: cast_nullable_to_non_nullable
as String,geohash: null == geohash ? _self.geohash : geohash // ignore: cast_nullable_to_non_nullable
as String,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,appointmentsHandled: null == appointmentsHandled ? _self.appointmentsHandled : appointmentsHandled // ignore: cast_nullable_to_non_nullable
as int,ordersCreated: null == ordersCreated ? _self.ordersCreated : ordersCreated // ignore: cast_nullable_to_non_nullable
as int,reportsSigned: null == reportsSigned ? _self.reportsSigned : reportsSigned // ignore: cast_nullable_to_non_nullable
as int,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PractitionerModel].
extension PractitionerModelPatterns on PractitionerModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PractitionerModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PractitionerModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PractitionerModel value)  $default,){
final _that = this;
switch (_that) {
case _PractitionerModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PractitionerModel value)?  $default,){
final _that = this;
switch (_that) {
case _PractitionerModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'title')  String title, @JsonKey(name: 'firstName')  String firstName, @JsonKey(name: 'lastName')  String lastName, @JsonKey(name: 'profilePictureUrl')  String profilePictureUrl, @JsonKey(name: 'isPathologist')  bool isPathologist, @JsonKey(name: 'specialties')  List<String> specialties, @JsonKey(name: 'bio')  String bio, @JsonKey(name: 'facilityId')  String facilityId, @JsonKey(name: 'facilityMflCode')  String facilityMflCode, @JsonKey(name: 'facilityName')  String facilityName, @JsonKey(name: 'county')  String county, @JsonKey(name: 'subCounty')  String subCounty, @JsonKey(name: 'geohash')  String geohash, @JsonKey(name: 'isAvailable')  bool isAvailable, @JsonKey(name: 'appointmentsHandled')  int appointmentsHandled, @JsonKey(name: 'ordersCreated')  int ordersCreated, @JsonKey(name: 'reportsSigned')  int reportsSigned, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PractitionerModel() when $default != null:
return $default(_that.uid,_that.title,_that.firstName,_that.lastName,_that.profilePictureUrl,_that.isPathologist,_that.specialties,_that.bio,_that.facilityId,_that.facilityMflCode,_that.facilityName,_that.county,_that.subCounty,_that.geohash,_that.isAvailable,_that.appointmentsHandled,_that.ordersCreated,_that.reportsSigned,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'title')  String title, @JsonKey(name: 'firstName')  String firstName, @JsonKey(name: 'lastName')  String lastName, @JsonKey(name: 'profilePictureUrl')  String profilePictureUrl, @JsonKey(name: 'isPathologist')  bool isPathologist, @JsonKey(name: 'specialties')  List<String> specialties, @JsonKey(name: 'bio')  String bio, @JsonKey(name: 'facilityId')  String facilityId, @JsonKey(name: 'facilityMflCode')  String facilityMflCode, @JsonKey(name: 'facilityName')  String facilityName, @JsonKey(name: 'county')  String county, @JsonKey(name: 'subCounty')  String subCounty, @JsonKey(name: 'geohash')  String geohash, @JsonKey(name: 'isAvailable')  bool isAvailable, @JsonKey(name: 'appointmentsHandled')  int appointmentsHandled, @JsonKey(name: 'ordersCreated')  int ordersCreated, @JsonKey(name: 'reportsSigned')  int reportsSigned, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)  $default,) {final _that = this;
switch (_that) {
case _PractitionerModel():
return $default(_that.uid,_that.title,_that.firstName,_that.lastName,_that.profilePictureUrl,_that.isPathologist,_that.specialties,_that.bio,_that.facilityId,_that.facilityMflCode,_that.facilityName,_that.county,_that.subCounty,_that.geohash,_that.isAvailable,_that.appointmentsHandled,_that.ordersCreated,_that.reportsSigned,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'title')  String title, @JsonKey(name: 'firstName')  String firstName, @JsonKey(name: 'lastName')  String lastName, @JsonKey(name: 'profilePictureUrl')  String profilePictureUrl, @JsonKey(name: 'isPathologist')  bool isPathologist, @JsonKey(name: 'specialties')  List<String> specialties, @JsonKey(name: 'bio')  String bio, @JsonKey(name: 'facilityId')  String facilityId, @JsonKey(name: 'facilityMflCode')  String facilityMflCode, @JsonKey(name: 'facilityName')  String facilityName, @JsonKey(name: 'county')  String county, @JsonKey(name: 'subCounty')  String subCounty, @JsonKey(name: 'geohash')  String geohash, @JsonKey(name: 'isAvailable')  bool isAvailable, @JsonKey(name: 'appointmentsHandled')  int appointmentsHandled, @JsonKey(name: 'ordersCreated')  int ordersCreated, @JsonKey(name: 'reportsSigned')  int reportsSigned, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,) {final _that = this;
switch (_that) {
case _PractitionerModel() when $default != null:
return $default(_that.uid,_that.title,_that.firstName,_that.lastName,_that.profilePictureUrl,_that.isPathologist,_that.specialties,_that.bio,_that.facilityId,_that.facilityMflCode,_that.facilityName,_that.county,_that.subCounty,_that.geohash,_that.isAvailable,_that.appointmentsHandled,_that.ordersCreated,_that.reportsSigned,_that.lastUpdatedAt,_that.synced);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PractitionerModel extends PractitionerModel {
  const _PractitionerModel({@JsonKey(name: 'uid') required this.uid, @JsonKey(name: 'title') required this.title, @JsonKey(name: 'firstName') required this.firstName, @JsonKey(name: 'lastName') required this.lastName, @JsonKey(name: 'profilePictureUrl') required this.profilePictureUrl, @JsonKey(name: 'isPathologist') required this.isPathologist, @JsonKey(name: 'specialties') required final  List<String> specialties, @JsonKey(name: 'bio') required this.bio, @JsonKey(name: 'facilityId') required this.facilityId, @JsonKey(name: 'facilityMflCode') required this.facilityMflCode, @JsonKey(name: 'facilityName') required this.facilityName, @JsonKey(name: 'county') required this.county, @JsonKey(name: 'subCounty') required this.subCounty, @JsonKey(name: 'geohash') required this.geohash, @JsonKey(name: 'isAvailable') required this.isAvailable, @JsonKey(name: 'appointmentsHandled') required this.appointmentsHandled, @JsonKey(name: 'ordersCreated') required this.ordersCreated, @JsonKey(name: 'reportsSigned') required this.reportsSigned, @JsonKey(name: 'lastUpdatedAt') required this.lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false) this.synced = true}): _specialties = specialties,super._();
  factory _PractitionerModel.fromJson(Map<String, dynamic> json) => _$PractitionerModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'title') final  String title;
@override@JsonKey(name: 'firstName') final  String firstName;
@override@JsonKey(name: 'lastName') final  String lastName;
@override@JsonKey(name: 'profilePictureUrl') final  String profilePictureUrl;
@override@JsonKey(name: 'isPathologist') final  bool isPathologist;
 final  List<String> _specialties;
@override@JsonKey(name: 'specialties') List<String> get specialties {
  if (_specialties is EqualUnmodifiableListView) return _specialties;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_specialties);
}

@override@JsonKey(name: 'bio') final  String bio;
@override@JsonKey(name: 'facilityId') final  String facilityId;
@override@JsonKey(name: 'facilityMflCode') final  String facilityMflCode;
@override@JsonKey(name: 'facilityName') final  String facilityName;
@override@JsonKey(name: 'county') final  String county;
@override@JsonKey(name: 'subCounty') final  String subCounty;
@override@JsonKey(name: 'geohash') final  String geohash;
@override@JsonKey(name: 'isAvailable') final  bool isAvailable;
@override@JsonKey(name: 'appointmentsHandled') final  int appointmentsHandled;
@override@JsonKey(name: 'ordersCreated') final  int ordersCreated;
@override@JsonKey(name: 'reportsSigned') final  int reportsSigned;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool synced;

/// Create a copy of PractitionerModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PractitionerModelCopyWith<_PractitionerModel> get copyWith => __$PractitionerModelCopyWithImpl<_PractitionerModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PractitionerModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PractitionerModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.title, title) || other.title == title)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl)&&(identical(other.isPathologist, isPathologist) || other.isPathologist == isPathologist)&&const DeepCollectionEquality().equals(other._specialties, _specialties)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.facilityMflCode, facilityMflCode) || other.facilityMflCode == facilityMflCode)&&(identical(other.facilityName, facilityName) || other.facilityName == facilityName)&&(identical(other.county, county) || other.county == county)&&(identical(other.subCounty, subCounty) || other.subCounty == subCounty)&&(identical(other.geohash, geohash) || other.geohash == geohash)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.appointmentsHandled, appointmentsHandled) || other.appointmentsHandled == appointmentsHandled)&&(identical(other.ordersCreated, ordersCreated) || other.ordersCreated == ordersCreated)&&(identical(other.reportsSigned, reportsSigned) || other.reportsSigned == reportsSigned)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,title,firstName,lastName,profilePictureUrl,isPathologist,const DeepCollectionEquality().hash(_specialties),bio,facilityId,facilityMflCode,facilityName,county,subCounty,geohash,isAvailable,appointmentsHandled,ordersCreated,reportsSigned,lastUpdatedAt,synced]);

@override
String toString() {
  return 'PractitionerModel(uid: $uid, title: $title, firstName: $firstName, lastName: $lastName, profilePictureUrl: $profilePictureUrl, isPathologist: $isPathologist, specialties: $specialties, bio: $bio, facilityId: $facilityId, facilityMflCode: $facilityMflCode, facilityName: $facilityName, county: $county, subCounty: $subCounty, geohash: $geohash, isAvailable: $isAvailable, appointmentsHandled: $appointmentsHandled, ordersCreated: $ordersCreated, reportsSigned: $reportsSigned, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class _$PractitionerModelCopyWith<$Res> implements $PractitionerModelCopyWith<$Res> {
  factory _$PractitionerModelCopyWith(_PractitionerModel value, $Res Function(_PractitionerModel) _then) = __$PractitionerModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'title') String title,@JsonKey(name: 'firstName') String firstName,@JsonKey(name: 'lastName') String lastName,@JsonKey(name: 'profilePictureUrl') String profilePictureUrl,@JsonKey(name: 'isPathologist') bool isPathologist,@JsonKey(name: 'specialties') List<String> specialties,@JsonKey(name: 'bio') String bio,@JsonKey(name: 'facilityId') String facilityId,@JsonKey(name: 'facilityMflCode') String facilityMflCode,@JsonKey(name: 'facilityName') String facilityName,@JsonKey(name: 'county') String county,@JsonKey(name: 'subCounty') String subCounty,@JsonKey(name: 'geohash') String geohash,@JsonKey(name: 'isAvailable') bool isAvailable,@JsonKey(name: 'appointmentsHandled') int appointmentsHandled,@JsonKey(name: 'ordersCreated') int ordersCreated,@JsonKey(name: 'reportsSigned') int reportsSigned,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class __$PractitionerModelCopyWithImpl<$Res>
    implements _$PractitionerModelCopyWith<$Res> {
  __$PractitionerModelCopyWithImpl(this._self, this._then);

  final _PractitionerModel _self;
  final $Res Function(_PractitionerModel) _then;

/// Create a copy of PractitionerModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? title = null,Object? firstName = null,Object? lastName = null,Object? profilePictureUrl = null,Object? isPathologist = null,Object? specialties = null,Object? bio = null,Object? facilityId = null,Object? facilityMflCode = null,Object? facilityName = null,Object? county = null,Object? subCounty = null,Object? geohash = null,Object? isAvailable = null,Object? appointmentsHandled = null,Object? ordersCreated = null,Object? reportsSigned = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_PractitionerModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,profilePictureUrl: null == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String,isPathologist: null == isPathologist ? _self.isPathologist : isPathologist // ignore: cast_nullable_to_non_nullable
as bool,specialties: null == specialties ? _self._specialties : specialties // ignore: cast_nullable_to_non_nullable
as List<String>,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as String,facilityMflCode: null == facilityMflCode ? _self.facilityMflCode : facilityMflCode // ignore: cast_nullable_to_non_nullable
as String,facilityName: null == facilityName ? _self.facilityName : facilityName // ignore: cast_nullable_to_non_nullable
as String,county: null == county ? _self.county : county // ignore: cast_nullable_to_non_nullable
as String,subCounty: null == subCounty ? _self.subCounty : subCounty // ignore: cast_nullable_to_non_nullable
as String,geohash: null == geohash ? _self.geohash : geohash // ignore: cast_nullable_to_non_nullable
as String,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,appointmentsHandled: null == appointmentsHandled ? _self.appointmentsHandled : appointmentsHandled // ignore: cast_nullable_to_non_nullable
as int,ordersCreated: null == ordersCreated ? _self.ordersCreated : ordersCreated // ignore: cast_nullable_to_non_nullable
as int,reportsSigned: null == reportsSigned ? _self.reportsSigned : reportsSigned // ignore: cast_nullable_to_non_nullable
as int,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
