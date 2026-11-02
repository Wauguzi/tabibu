// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_member_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConversationMemberModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'actorRole') String get actorRole;@JsonKey(name: 'memberRole') String get memberRole;@JsonKey(name: 'status') String get status;@JsonKey(name: 'title') String get title;@JsonKey(name: 'firstName') String get firstName;@JsonKey(name: 'lastName') String get lastName;@JsonKey(name: 'specialty') String get specialty;@JsonKey(name: 'profilePictureUrl') String get profilePictureUrl;@JsonKey(name: 'invitedByUid') String get invitedByUid;@JsonKey(name: 'invitedAt') String get invitedAt;@JsonKey(name: 'inviteExpiresAt') String get inviteExpiresAt;@JsonKey(name: 'inviteRound') int get inviteRound;@JsonKey(name: 'respondedAt') String get respondedAt;
/// Create a copy of ConversationMemberModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationMemberModelCopyWith<ConversationMemberModel> get copyWith => _$ConversationMemberModelCopyWithImpl<ConversationMemberModel>(this as ConversationMemberModel, _$identity);

  /// Serializes this ConversationMemberModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationMemberModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.actorRole, actorRole) || other.actorRole == actorRole)&&(identical(other.memberRole, memberRole) || other.memberRole == memberRole)&&(identical(other.status, status) || other.status == status)&&(identical(other.title, title) || other.title == title)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.specialty, specialty) || other.specialty == specialty)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl)&&(identical(other.invitedByUid, invitedByUid) || other.invitedByUid == invitedByUid)&&(identical(other.invitedAt, invitedAt) || other.invitedAt == invitedAt)&&(identical(other.inviteExpiresAt, inviteExpiresAt) || other.inviteExpiresAt == inviteExpiresAt)&&(identical(other.inviteRound, inviteRound) || other.inviteRound == inviteRound)&&(identical(other.respondedAt, respondedAt) || other.respondedAt == respondedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,actorRole,memberRole,status,title,firstName,lastName,specialty,profilePictureUrl,invitedByUid,invitedAt,inviteExpiresAt,inviteRound,respondedAt);

@override
String toString() {
  return 'ConversationMemberModel(uid: $uid, actorRole: $actorRole, memberRole: $memberRole, status: $status, title: $title, firstName: $firstName, lastName: $lastName, specialty: $specialty, profilePictureUrl: $profilePictureUrl, invitedByUid: $invitedByUid, invitedAt: $invitedAt, inviteExpiresAt: $inviteExpiresAt, inviteRound: $inviteRound, respondedAt: $respondedAt)';
}


}

/// @nodoc
abstract mixin class $ConversationMemberModelCopyWith<$Res>  {
  factory $ConversationMemberModelCopyWith(ConversationMemberModel value, $Res Function(ConversationMemberModel) _then) = _$ConversationMemberModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'actorRole') String actorRole,@JsonKey(name: 'memberRole') String memberRole,@JsonKey(name: 'status') String status,@JsonKey(name: 'title') String title,@JsonKey(name: 'firstName') String firstName,@JsonKey(name: 'lastName') String lastName,@JsonKey(name: 'specialty') String specialty,@JsonKey(name: 'profilePictureUrl') String profilePictureUrl,@JsonKey(name: 'invitedByUid') String invitedByUid,@JsonKey(name: 'invitedAt') String invitedAt,@JsonKey(name: 'inviteExpiresAt') String inviteExpiresAt,@JsonKey(name: 'inviteRound') int inviteRound,@JsonKey(name: 'respondedAt') String respondedAt
});




}
/// @nodoc
class _$ConversationMemberModelCopyWithImpl<$Res>
    implements $ConversationMemberModelCopyWith<$Res> {
  _$ConversationMemberModelCopyWithImpl(this._self, this._then);

  final ConversationMemberModel _self;
  final $Res Function(ConversationMemberModel) _then;

/// Create a copy of ConversationMemberModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? actorRole = null,Object? memberRole = null,Object? status = null,Object? title = null,Object? firstName = null,Object? lastName = null,Object? specialty = null,Object? profilePictureUrl = null,Object? invitedByUid = null,Object? invitedAt = null,Object? inviteExpiresAt = null,Object? inviteRound = null,Object? respondedAt = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,actorRole: null == actorRole ? _self.actorRole : actorRole // ignore: cast_nullable_to_non_nullable
as String,memberRole: null == memberRole ? _self.memberRole : memberRole // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,specialty: null == specialty ? _self.specialty : specialty // ignore: cast_nullable_to_non_nullable
as String,profilePictureUrl: null == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String,invitedByUid: null == invitedByUid ? _self.invitedByUid : invitedByUid // ignore: cast_nullable_to_non_nullable
as String,invitedAt: null == invitedAt ? _self.invitedAt : invitedAt // ignore: cast_nullable_to_non_nullable
as String,inviteExpiresAt: null == inviteExpiresAt ? _self.inviteExpiresAt : inviteExpiresAt // ignore: cast_nullable_to_non_nullable
as String,inviteRound: null == inviteRound ? _self.inviteRound : inviteRound // ignore: cast_nullable_to_non_nullable
as int,respondedAt: null == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ConversationMemberModel].
extension ConversationMemberModelPatterns on ConversationMemberModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConversationMemberModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConversationMemberModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConversationMemberModel value)  $default,){
final _that = this;
switch (_that) {
case _ConversationMemberModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConversationMemberModel value)?  $default,){
final _that = this;
switch (_that) {
case _ConversationMemberModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'actorRole')  String actorRole, @JsonKey(name: 'memberRole')  String memberRole, @JsonKey(name: 'status')  String status, @JsonKey(name: 'title')  String title, @JsonKey(name: 'firstName')  String firstName, @JsonKey(name: 'lastName')  String lastName, @JsonKey(name: 'specialty')  String specialty, @JsonKey(name: 'profilePictureUrl')  String profilePictureUrl, @JsonKey(name: 'invitedByUid')  String invitedByUid, @JsonKey(name: 'invitedAt')  String invitedAt, @JsonKey(name: 'inviteExpiresAt')  String inviteExpiresAt, @JsonKey(name: 'inviteRound')  int inviteRound, @JsonKey(name: 'respondedAt')  String respondedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConversationMemberModel() when $default != null:
return $default(_that.uid,_that.actorRole,_that.memberRole,_that.status,_that.title,_that.firstName,_that.lastName,_that.specialty,_that.profilePictureUrl,_that.invitedByUid,_that.invitedAt,_that.inviteExpiresAt,_that.inviteRound,_that.respondedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'actorRole')  String actorRole, @JsonKey(name: 'memberRole')  String memberRole, @JsonKey(name: 'status')  String status, @JsonKey(name: 'title')  String title, @JsonKey(name: 'firstName')  String firstName, @JsonKey(name: 'lastName')  String lastName, @JsonKey(name: 'specialty')  String specialty, @JsonKey(name: 'profilePictureUrl')  String profilePictureUrl, @JsonKey(name: 'invitedByUid')  String invitedByUid, @JsonKey(name: 'invitedAt')  String invitedAt, @JsonKey(name: 'inviteExpiresAt')  String inviteExpiresAt, @JsonKey(name: 'inviteRound')  int inviteRound, @JsonKey(name: 'respondedAt')  String respondedAt)  $default,) {final _that = this;
switch (_that) {
case _ConversationMemberModel():
return $default(_that.uid,_that.actorRole,_that.memberRole,_that.status,_that.title,_that.firstName,_that.lastName,_that.specialty,_that.profilePictureUrl,_that.invitedByUid,_that.invitedAt,_that.inviteExpiresAt,_that.inviteRound,_that.respondedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'actorRole')  String actorRole, @JsonKey(name: 'memberRole')  String memberRole, @JsonKey(name: 'status')  String status, @JsonKey(name: 'title')  String title, @JsonKey(name: 'firstName')  String firstName, @JsonKey(name: 'lastName')  String lastName, @JsonKey(name: 'specialty')  String specialty, @JsonKey(name: 'profilePictureUrl')  String profilePictureUrl, @JsonKey(name: 'invitedByUid')  String invitedByUid, @JsonKey(name: 'invitedAt')  String invitedAt, @JsonKey(name: 'inviteExpiresAt')  String inviteExpiresAt, @JsonKey(name: 'inviteRound')  int inviteRound, @JsonKey(name: 'respondedAt')  String respondedAt)?  $default,) {final _that = this;
switch (_that) {
case _ConversationMemberModel() when $default != null:
return $default(_that.uid,_that.actorRole,_that.memberRole,_that.status,_that.title,_that.firstName,_that.lastName,_that.specialty,_that.profilePictureUrl,_that.invitedByUid,_that.invitedAt,_that.inviteExpiresAt,_that.inviteRound,_that.respondedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConversationMemberModel extends ConversationMemberModel {
  const _ConversationMemberModel({@JsonKey(name: 'uid') this.uid = '', @JsonKey(name: 'actorRole') this.actorRole = '', @JsonKey(name: 'memberRole') this.memberRole = 'Member', @JsonKey(name: 'status') this.status = 'Invited', @JsonKey(name: 'title') this.title = '', @JsonKey(name: 'firstName') this.firstName = '', @JsonKey(name: 'lastName') this.lastName = '', @JsonKey(name: 'specialty') this.specialty = '', @JsonKey(name: 'profilePictureUrl') this.profilePictureUrl = '', @JsonKey(name: 'invitedByUid') this.invitedByUid = '', @JsonKey(name: 'invitedAt') this.invitedAt = '', @JsonKey(name: 'inviteExpiresAt') this.inviteExpiresAt = '', @JsonKey(name: 'inviteRound') this.inviteRound = 0, @JsonKey(name: 'respondedAt') this.respondedAt = ''}): super._();
  factory _ConversationMemberModel.fromJson(Map<String, dynamic> json) => _$ConversationMemberModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'actorRole') final  String actorRole;
@override@JsonKey(name: 'memberRole') final  String memberRole;
@override@JsonKey(name: 'status') final  String status;
@override@JsonKey(name: 'title') final  String title;
@override@JsonKey(name: 'firstName') final  String firstName;
@override@JsonKey(name: 'lastName') final  String lastName;
@override@JsonKey(name: 'specialty') final  String specialty;
@override@JsonKey(name: 'profilePictureUrl') final  String profilePictureUrl;
@override@JsonKey(name: 'invitedByUid') final  String invitedByUid;
@override@JsonKey(name: 'invitedAt') final  String invitedAt;
@override@JsonKey(name: 'inviteExpiresAt') final  String inviteExpiresAt;
@override@JsonKey(name: 'inviteRound') final  int inviteRound;
@override@JsonKey(name: 'respondedAt') final  String respondedAt;

/// Create a copy of ConversationMemberModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationMemberModelCopyWith<_ConversationMemberModel> get copyWith => __$ConversationMemberModelCopyWithImpl<_ConversationMemberModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConversationMemberModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConversationMemberModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.actorRole, actorRole) || other.actorRole == actorRole)&&(identical(other.memberRole, memberRole) || other.memberRole == memberRole)&&(identical(other.status, status) || other.status == status)&&(identical(other.title, title) || other.title == title)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.specialty, specialty) || other.specialty == specialty)&&(identical(other.profilePictureUrl, profilePictureUrl) || other.profilePictureUrl == profilePictureUrl)&&(identical(other.invitedByUid, invitedByUid) || other.invitedByUid == invitedByUid)&&(identical(other.invitedAt, invitedAt) || other.invitedAt == invitedAt)&&(identical(other.inviteExpiresAt, inviteExpiresAt) || other.inviteExpiresAt == inviteExpiresAt)&&(identical(other.inviteRound, inviteRound) || other.inviteRound == inviteRound)&&(identical(other.respondedAt, respondedAt) || other.respondedAt == respondedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,actorRole,memberRole,status,title,firstName,lastName,specialty,profilePictureUrl,invitedByUid,invitedAt,inviteExpiresAt,inviteRound,respondedAt);

@override
String toString() {
  return 'ConversationMemberModel(uid: $uid, actorRole: $actorRole, memberRole: $memberRole, status: $status, title: $title, firstName: $firstName, lastName: $lastName, specialty: $specialty, profilePictureUrl: $profilePictureUrl, invitedByUid: $invitedByUid, invitedAt: $invitedAt, inviteExpiresAt: $inviteExpiresAt, inviteRound: $inviteRound, respondedAt: $respondedAt)';
}


}

/// @nodoc
abstract mixin class _$ConversationMemberModelCopyWith<$Res> implements $ConversationMemberModelCopyWith<$Res> {
  factory _$ConversationMemberModelCopyWith(_ConversationMemberModel value, $Res Function(_ConversationMemberModel) _then) = __$ConversationMemberModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'actorRole') String actorRole,@JsonKey(name: 'memberRole') String memberRole,@JsonKey(name: 'status') String status,@JsonKey(name: 'title') String title,@JsonKey(name: 'firstName') String firstName,@JsonKey(name: 'lastName') String lastName,@JsonKey(name: 'specialty') String specialty,@JsonKey(name: 'profilePictureUrl') String profilePictureUrl,@JsonKey(name: 'invitedByUid') String invitedByUid,@JsonKey(name: 'invitedAt') String invitedAt,@JsonKey(name: 'inviteExpiresAt') String inviteExpiresAt,@JsonKey(name: 'inviteRound') int inviteRound,@JsonKey(name: 'respondedAt') String respondedAt
});




}
/// @nodoc
class __$ConversationMemberModelCopyWithImpl<$Res>
    implements _$ConversationMemberModelCopyWith<$Res> {
  __$ConversationMemberModelCopyWithImpl(this._self, this._then);

  final _ConversationMemberModel _self;
  final $Res Function(_ConversationMemberModel) _then;

/// Create a copy of ConversationMemberModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? actorRole = null,Object? memberRole = null,Object? status = null,Object? title = null,Object? firstName = null,Object? lastName = null,Object? specialty = null,Object? profilePictureUrl = null,Object? invitedByUid = null,Object? invitedAt = null,Object? inviteExpiresAt = null,Object? inviteRound = null,Object? respondedAt = null,}) {
  return _then(_ConversationMemberModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,actorRole: null == actorRole ? _self.actorRole : actorRole // ignore: cast_nullable_to_non_nullable
as String,memberRole: null == memberRole ? _self.memberRole : memberRole // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,specialty: null == specialty ? _self.specialty : specialty // ignore: cast_nullable_to_non_nullable
as String,profilePictureUrl: null == profilePictureUrl ? _self.profilePictureUrl : profilePictureUrl // ignore: cast_nullable_to_non_nullable
as String,invitedByUid: null == invitedByUid ? _self.invitedByUid : invitedByUid // ignore: cast_nullable_to_non_nullable
as String,invitedAt: null == invitedAt ? _self.invitedAt : invitedAt // ignore: cast_nullable_to_non_nullable
as String,inviteExpiresAt: null == inviteExpiresAt ? _self.inviteExpiresAt : inviteExpiresAt // ignore: cast_nullable_to_non_nullable
as String,inviteRound: null == inviteRound ? _self.inviteRound : inviteRound // ignore: cast_nullable_to_non_nullable
as int,respondedAt: null == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
