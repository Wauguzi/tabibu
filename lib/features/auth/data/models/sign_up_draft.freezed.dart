// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sign_up_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SignUpDraft {

 Role? get role; String get firstName; String get middleName; String get lastName; Sex? get sex;/// `YYYY-MM-DD`.
 String get dateOfBirth; String get phoneNumber; int? get countyId; int? get subCountyId; AppLanguage get language; PractitionerTitle? get title; List<Specialty> get specialties; String get bio; String get kmpdcNumber; List<UploadFile> get licenses; UploadFile? get picture; String get facilityId; bool get isAvailable; bool get termsAccepted;
/// Create a copy of SignUpDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignUpDraftCopyWith<SignUpDraft> get copyWith => _$SignUpDraftCopyWithImpl<SignUpDraft>(this as SignUpDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignUpDraft&&(identical(other.role, role) || other.role == role)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.middleName, middleName) || other.middleName == middleName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.countyId, countyId) || other.countyId == countyId)&&(identical(other.subCountyId, subCountyId) || other.subCountyId == subCountyId)&&(identical(other.language, language) || other.language == language)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.specialties, specialties)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.kmpdcNumber, kmpdcNumber) || other.kmpdcNumber == kmpdcNumber)&&const DeepCollectionEquality().equals(other.licenses, licenses)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.termsAccepted, termsAccepted) || other.termsAccepted == termsAccepted));
}


@override
int get hashCode => Object.hashAll([runtimeType,role,firstName,middleName,lastName,sex,dateOfBirth,phoneNumber,countyId,subCountyId,language,title,const DeepCollectionEquality().hash(specialties),bio,kmpdcNumber,const DeepCollectionEquality().hash(licenses),picture,facilityId,isAvailable,termsAccepted]);

@override
String toString() {
  return 'SignUpDraft(role: $role, firstName: $firstName, middleName: $middleName, lastName: $lastName, sex: $sex, dateOfBirth: $dateOfBirth, phoneNumber: $phoneNumber, countyId: $countyId, subCountyId: $subCountyId, language: $language, title: $title, specialties: $specialties, bio: $bio, kmpdcNumber: $kmpdcNumber, licenses: $licenses, picture: $picture, facilityId: $facilityId, isAvailable: $isAvailable, termsAccepted: $termsAccepted)';
}


}

/// @nodoc
abstract mixin class $SignUpDraftCopyWith<$Res>  {
  factory $SignUpDraftCopyWith(SignUpDraft value, $Res Function(SignUpDraft) _then) = _$SignUpDraftCopyWithImpl;
@useResult
$Res call({
 Role? role, String firstName, String middleName, String lastName, Sex? sex, String dateOfBirth, String phoneNumber, int? countyId, int? subCountyId, AppLanguage language, PractitionerTitle? title, List<Specialty> specialties, String bio, String kmpdcNumber, List<UploadFile> licenses, UploadFile? picture, String facilityId, bool isAvailable, bool termsAccepted
});




}
/// @nodoc
class _$SignUpDraftCopyWithImpl<$Res>
    implements $SignUpDraftCopyWith<$Res> {
  _$SignUpDraftCopyWithImpl(this._self, this._then);

  final SignUpDraft _self;
  final $Res Function(SignUpDraft) _then;

/// Create a copy of SignUpDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? role = freezed,Object? firstName = null,Object? middleName = null,Object? lastName = null,Object? sex = freezed,Object? dateOfBirth = null,Object? phoneNumber = null,Object? countyId = freezed,Object? subCountyId = freezed,Object? language = null,Object? title = freezed,Object? specialties = null,Object? bio = null,Object? kmpdcNumber = null,Object? licenses = null,Object? picture = freezed,Object? facilityId = null,Object? isAvailable = null,Object? termsAccepted = null,}) {
  return _then(_self.copyWith(
role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role?,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,middleName: null == middleName ? _self.middleName : middleName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,sex: freezed == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as Sex?,dateOfBirth: null == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,countyId: freezed == countyId ? _self.countyId : countyId // ignore: cast_nullable_to_non_nullable
as int?,subCountyId: freezed == subCountyId ? _self.subCountyId : subCountyId // ignore: cast_nullable_to_non_nullable
as int?,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as AppLanguage,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as PractitionerTitle?,specialties: null == specialties ? _self.specialties : specialties // ignore: cast_nullable_to_non_nullable
as List<Specialty>,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,kmpdcNumber: null == kmpdcNumber ? _self.kmpdcNumber : kmpdcNumber // ignore: cast_nullable_to_non_nullable
as String,licenses: null == licenses ? _self.licenses : licenses // ignore: cast_nullable_to_non_nullable
as List<UploadFile>,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as UploadFile?,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as String,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,termsAccepted: null == termsAccepted ? _self.termsAccepted : termsAccepted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SignUpDraft].
extension SignUpDraftPatterns on SignUpDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SignUpDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SignUpDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SignUpDraft value)  $default,){
final _that = this;
switch (_that) {
case _SignUpDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SignUpDraft value)?  $default,){
final _that = this;
switch (_that) {
case _SignUpDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Role? role,  String firstName,  String middleName,  String lastName,  Sex? sex,  String dateOfBirth,  String phoneNumber,  int? countyId,  int? subCountyId,  AppLanguage language,  PractitionerTitle? title,  List<Specialty> specialties,  String bio,  String kmpdcNumber,  List<UploadFile> licenses,  UploadFile? picture,  String facilityId,  bool isAvailable,  bool termsAccepted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SignUpDraft() when $default != null:
return $default(_that.role,_that.firstName,_that.middleName,_that.lastName,_that.sex,_that.dateOfBirth,_that.phoneNumber,_that.countyId,_that.subCountyId,_that.language,_that.title,_that.specialties,_that.bio,_that.kmpdcNumber,_that.licenses,_that.picture,_that.facilityId,_that.isAvailable,_that.termsAccepted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Role? role,  String firstName,  String middleName,  String lastName,  Sex? sex,  String dateOfBirth,  String phoneNumber,  int? countyId,  int? subCountyId,  AppLanguage language,  PractitionerTitle? title,  List<Specialty> specialties,  String bio,  String kmpdcNumber,  List<UploadFile> licenses,  UploadFile? picture,  String facilityId,  bool isAvailable,  bool termsAccepted)  $default,) {final _that = this;
switch (_that) {
case _SignUpDraft():
return $default(_that.role,_that.firstName,_that.middleName,_that.lastName,_that.sex,_that.dateOfBirth,_that.phoneNumber,_that.countyId,_that.subCountyId,_that.language,_that.title,_that.specialties,_that.bio,_that.kmpdcNumber,_that.licenses,_that.picture,_that.facilityId,_that.isAvailable,_that.termsAccepted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Role? role,  String firstName,  String middleName,  String lastName,  Sex? sex,  String dateOfBirth,  String phoneNumber,  int? countyId,  int? subCountyId,  AppLanguage language,  PractitionerTitle? title,  List<Specialty> specialties,  String bio,  String kmpdcNumber,  List<UploadFile> licenses,  UploadFile? picture,  String facilityId,  bool isAvailable,  bool termsAccepted)?  $default,) {final _that = this;
switch (_that) {
case _SignUpDraft() when $default != null:
return $default(_that.role,_that.firstName,_that.middleName,_that.lastName,_that.sex,_that.dateOfBirth,_that.phoneNumber,_that.countyId,_that.subCountyId,_that.language,_that.title,_that.specialties,_that.bio,_that.kmpdcNumber,_that.licenses,_that.picture,_that.facilityId,_that.isAvailable,_that.termsAccepted);case _:
  return null;

}
}

}

/// @nodoc


class _SignUpDraft extends SignUpDraft {
  const _SignUpDraft({this.role, this.firstName = '', this.middleName = '', this.lastName = '', this.sex, this.dateOfBirth = '', this.phoneNumber = '', this.countyId, this.subCountyId, this.language = AppLanguage.en, this.title, final  List<Specialty> specialties = const <Specialty>[], this.bio = '', this.kmpdcNumber = '', final  List<UploadFile> licenses = const <UploadFile>[], this.picture, this.facilityId = '', this.isAvailable = true, this.termsAccepted = false}): _specialties = specialties,_licenses = licenses,super._();
  

@override final  Role? role;
@override@JsonKey() final  String firstName;
@override@JsonKey() final  String middleName;
@override@JsonKey() final  String lastName;
@override final  Sex? sex;
/// `YYYY-MM-DD`.
@override@JsonKey() final  String dateOfBirth;
@override@JsonKey() final  String phoneNumber;
@override final  int? countyId;
@override final  int? subCountyId;
@override@JsonKey() final  AppLanguage language;
@override final  PractitionerTitle? title;
 final  List<Specialty> _specialties;
@override@JsonKey() List<Specialty> get specialties {
  if (_specialties is EqualUnmodifiableListView) return _specialties;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_specialties);
}

@override@JsonKey() final  String bio;
@override@JsonKey() final  String kmpdcNumber;
 final  List<UploadFile> _licenses;
@override@JsonKey() List<UploadFile> get licenses {
  if (_licenses is EqualUnmodifiableListView) return _licenses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_licenses);
}

@override final  UploadFile? picture;
@override@JsonKey() final  String facilityId;
@override@JsonKey() final  bool isAvailable;
@override@JsonKey() final  bool termsAccepted;

/// Create a copy of SignUpDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignUpDraftCopyWith<_SignUpDraft> get copyWith => __$SignUpDraftCopyWithImpl<_SignUpDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignUpDraft&&(identical(other.role, role) || other.role == role)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.middleName, middleName) || other.middleName == middleName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.countyId, countyId) || other.countyId == countyId)&&(identical(other.subCountyId, subCountyId) || other.subCountyId == subCountyId)&&(identical(other.language, language) || other.language == language)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._specialties, _specialties)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.kmpdcNumber, kmpdcNumber) || other.kmpdcNumber == kmpdcNumber)&&const DeepCollectionEquality().equals(other._licenses, _licenses)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.termsAccepted, termsAccepted) || other.termsAccepted == termsAccepted));
}


@override
int get hashCode => Object.hashAll([runtimeType,role,firstName,middleName,lastName,sex,dateOfBirth,phoneNumber,countyId,subCountyId,language,title,const DeepCollectionEquality().hash(_specialties),bio,kmpdcNumber,const DeepCollectionEquality().hash(_licenses),picture,facilityId,isAvailable,termsAccepted]);

@override
String toString() {
  return 'SignUpDraft(role: $role, firstName: $firstName, middleName: $middleName, lastName: $lastName, sex: $sex, dateOfBirth: $dateOfBirth, phoneNumber: $phoneNumber, countyId: $countyId, subCountyId: $subCountyId, language: $language, title: $title, specialties: $specialties, bio: $bio, kmpdcNumber: $kmpdcNumber, licenses: $licenses, picture: $picture, facilityId: $facilityId, isAvailable: $isAvailable, termsAccepted: $termsAccepted)';
}


}

/// @nodoc
abstract mixin class _$SignUpDraftCopyWith<$Res> implements $SignUpDraftCopyWith<$Res> {
  factory _$SignUpDraftCopyWith(_SignUpDraft value, $Res Function(_SignUpDraft) _then) = __$SignUpDraftCopyWithImpl;
@override @useResult
$Res call({
 Role? role, String firstName, String middleName, String lastName, Sex? sex, String dateOfBirth, String phoneNumber, int? countyId, int? subCountyId, AppLanguage language, PractitionerTitle? title, List<Specialty> specialties, String bio, String kmpdcNumber, List<UploadFile> licenses, UploadFile? picture, String facilityId, bool isAvailable, bool termsAccepted
});




}
/// @nodoc
class __$SignUpDraftCopyWithImpl<$Res>
    implements _$SignUpDraftCopyWith<$Res> {
  __$SignUpDraftCopyWithImpl(this._self, this._then);

  final _SignUpDraft _self;
  final $Res Function(_SignUpDraft) _then;

/// Create a copy of SignUpDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? role = freezed,Object? firstName = null,Object? middleName = null,Object? lastName = null,Object? sex = freezed,Object? dateOfBirth = null,Object? phoneNumber = null,Object? countyId = freezed,Object? subCountyId = freezed,Object? language = null,Object? title = freezed,Object? specialties = null,Object? bio = null,Object? kmpdcNumber = null,Object? licenses = null,Object? picture = freezed,Object? facilityId = null,Object? isAvailable = null,Object? termsAccepted = null,}) {
  return _then(_SignUpDraft(
role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role?,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,middleName: null == middleName ? _self.middleName : middleName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,sex: freezed == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as Sex?,dateOfBirth: null == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,countyId: freezed == countyId ? _self.countyId : countyId // ignore: cast_nullable_to_non_nullable
as int?,subCountyId: freezed == subCountyId ? _self.subCountyId : subCountyId // ignore: cast_nullable_to_non_nullable
as int?,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as AppLanguage,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as PractitionerTitle?,specialties: null == specialties ? _self._specialties : specialties // ignore: cast_nullable_to_non_nullable
as List<Specialty>,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,kmpdcNumber: null == kmpdcNumber ? _self.kmpdcNumber : kmpdcNumber // ignore: cast_nullable_to_non_nullable
as String,licenses: null == licenses ? _self._licenses : licenses // ignore: cast_nullable_to_non_nullable
as List<UploadFile>,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as UploadFile?,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as String,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,termsAccepted: null == termsAccepted ? _self.termsAccepted : termsAccepted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
