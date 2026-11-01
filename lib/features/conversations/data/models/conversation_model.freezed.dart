// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConversationModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'type') String get type;@JsonKey(name: 'status') String get status;@JsonKey(name: 'createdByUid') String get createdByUid;@JsonKey(name: 'linkedResourceType') String get linkedResourceType;@JsonKey(name: 'linkedResourceUid') String get linkedResourceUid;@JsonKey(name: 'specialty') String get specialty;@JsonKey(name: 'description') String get description;@JsonKey(name: 'participantUids') List<String> get participantUids;@JsonKey(name: 'members') Map<String, ConversationMemberModel> get members;@JsonKey(name: 'lastMessage') MessagePreviewModel get lastMessage;@JsonKey(name: 'lastMessageAt') String get lastMessageAt;@JsonKey(name: 'caseSummary') CaseSummaryModel get caseSummary;@JsonKey(name: 'createdAt') String get createdAt;@JsonKey(name: 'closedAt') String get closedAt;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;@JsonKey(includeFromJson: false, includeToJson: false) bool get synced;
/// Create a copy of ConversationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationModelCopyWith<ConversationModel> get copyWith => _$ConversationModelCopyWithImpl<ConversationModel>(this as ConversationModel, _$identity);

  /// Serializes this ConversationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdByUid, createdByUid) || other.createdByUid == createdByUid)&&(identical(other.linkedResourceType, linkedResourceType) || other.linkedResourceType == linkedResourceType)&&(identical(other.linkedResourceUid, linkedResourceUid) || other.linkedResourceUid == linkedResourceUid)&&(identical(other.specialty, specialty) || other.specialty == specialty)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.participantUids, participantUids)&&const DeepCollectionEquality().equals(other.members, members)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.caseSummary, caseSummary) || other.caseSummary == caseSummary)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,type,status,createdByUid,linkedResourceType,linkedResourceUid,specialty,description,const DeepCollectionEquality().hash(participantUids),const DeepCollectionEquality().hash(members),lastMessage,lastMessageAt,caseSummary,createdAt,closedAt,lastUpdatedAt,synced);

@override
String toString() {
  return 'ConversationModel(uid: $uid, type: $type, status: $status, createdByUid: $createdByUid, linkedResourceType: $linkedResourceType, linkedResourceUid: $linkedResourceUid, specialty: $specialty, description: $description, participantUids: $participantUids, members: $members, lastMessage: $lastMessage, lastMessageAt: $lastMessageAt, caseSummary: $caseSummary, createdAt: $createdAt, closedAt: $closedAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class $ConversationModelCopyWith<$Res>  {
  factory $ConversationModelCopyWith(ConversationModel value, $Res Function(ConversationModel) _then) = _$ConversationModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'type') String type,@JsonKey(name: 'status') String status,@JsonKey(name: 'createdByUid') String createdByUid,@JsonKey(name: 'linkedResourceType') String linkedResourceType,@JsonKey(name: 'linkedResourceUid') String linkedResourceUid,@JsonKey(name: 'specialty') String specialty,@JsonKey(name: 'description') String description,@JsonKey(name: 'participantUids') List<String> participantUids,@JsonKey(name: 'members') Map<String, ConversationMemberModel> members,@JsonKey(name: 'lastMessage') MessagePreviewModel lastMessage,@JsonKey(name: 'lastMessageAt') String lastMessageAt,@JsonKey(name: 'caseSummary') CaseSummaryModel caseSummary,@JsonKey(name: 'createdAt') String createdAt,@JsonKey(name: 'closedAt') String closedAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});


$MessagePreviewModelCopyWith<$Res> get lastMessage;$CaseSummaryModelCopyWith<$Res> get caseSummary;

}
/// @nodoc
class _$ConversationModelCopyWithImpl<$Res>
    implements $ConversationModelCopyWith<$Res> {
  _$ConversationModelCopyWithImpl(this._self, this._then);

  final ConversationModel _self;
  final $Res Function(ConversationModel) _then;

/// Create a copy of ConversationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? type = null,Object? status = null,Object? createdByUid = null,Object? linkedResourceType = null,Object? linkedResourceUid = null,Object? specialty = null,Object? description = null,Object? participantUids = null,Object? members = null,Object? lastMessage = null,Object? lastMessageAt = null,Object? caseSummary = null,Object? createdAt = null,Object? closedAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdByUid: null == createdByUid ? _self.createdByUid : createdByUid // ignore: cast_nullable_to_non_nullable
as String,linkedResourceType: null == linkedResourceType ? _self.linkedResourceType : linkedResourceType // ignore: cast_nullable_to_non_nullable
as String,linkedResourceUid: null == linkedResourceUid ? _self.linkedResourceUid : linkedResourceUid // ignore: cast_nullable_to_non_nullable
as String,specialty: null == specialty ? _self.specialty : specialty // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,participantUids: null == participantUids ? _self.participantUids : participantUids // ignore: cast_nullable_to_non_nullable
as List<String>,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as Map<String, ConversationMemberModel>,lastMessage: null == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as MessagePreviewModel,lastMessageAt: null == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as String,caseSummary: null == caseSummary ? _self.caseSummary : caseSummary // ignore: cast_nullable_to_non_nullable
as CaseSummaryModel,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,closedAt: null == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ConversationModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessagePreviewModelCopyWith<$Res> get lastMessage {
  
  return $MessagePreviewModelCopyWith<$Res>(_self.lastMessage, (value) {
    return _then(_self.copyWith(lastMessage: value));
  });
}/// Create a copy of ConversationModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CaseSummaryModelCopyWith<$Res> get caseSummary {
  
  return $CaseSummaryModelCopyWith<$Res>(_self.caseSummary, (value) {
    return _then(_self.copyWith(caseSummary: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConversationModel].
extension ConversationModelPatterns on ConversationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConversationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConversationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConversationModel value)  $default,){
final _that = this;
switch (_that) {
case _ConversationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConversationModel value)?  $default,){
final _that = this;
switch (_that) {
case _ConversationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'type')  String type, @JsonKey(name: 'status')  String status, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'linkedResourceType')  String linkedResourceType, @JsonKey(name: 'linkedResourceUid')  String linkedResourceUid, @JsonKey(name: 'specialty')  String specialty, @JsonKey(name: 'description')  String description, @JsonKey(name: 'participantUids')  List<String> participantUids, @JsonKey(name: 'members')  Map<String, ConversationMemberModel> members, @JsonKey(name: 'lastMessage')  MessagePreviewModel lastMessage, @JsonKey(name: 'lastMessageAt')  String lastMessageAt, @JsonKey(name: 'caseSummary')  CaseSummaryModel caseSummary, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'closedAt')  String closedAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConversationModel() when $default != null:
return $default(_that.uid,_that.type,_that.status,_that.createdByUid,_that.linkedResourceType,_that.linkedResourceUid,_that.specialty,_that.description,_that.participantUids,_that.members,_that.lastMessage,_that.lastMessageAt,_that.caseSummary,_that.createdAt,_that.closedAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'type')  String type, @JsonKey(name: 'status')  String status, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'linkedResourceType')  String linkedResourceType, @JsonKey(name: 'linkedResourceUid')  String linkedResourceUid, @JsonKey(name: 'specialty')  String specialty, @JsonKey(name: 'description')  String description, @JsonKey(name: 'participantUids')  List<String> participantUids, @JsonKey(name: 'members')  Map<String, ConversationMemberModel> members, @JsonKey(name: 'lastMessage')  MessagePreviewModel lastMessage, @JsonKey(name: 'lastMessageAt')  String lastMessageAt, @JsonKey(name: 'caseSummary')  CaseSummaryModel caseSummary, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'closedAt')  String closedAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)  $default,) {final _that = this;
switch (_that) {
case _ConversationModel():
return $default(_that.uid,_that.type,_that.status,_that.createdByUid,_that.linkedResourceType,_that.linkedResourceUid,_that.specialty,_that.description,_that.participantUids,_that.members,_that.lastMessage,_that.lastMessageAt,_that.caseSummary,_that.createdAt,_that.closedAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'type')  String type, @JsonKey(name: 'status')  String status, @JsonKey(name: 'createdByUid')  String createdByUid, @JsonKey(name: 'linkedResourceType')  String linkedResourceType, @JsonKey(name: 'linkedResourceUid')  String linkedResourceUid, @JsonKey(name: 'specialty')  String specialty, @JsonKey(name: 'description')  String description, @JsonKey(name: 'participantUids')  List<String> participantUids, @JsonKey(name: 'members')  Map<String, ConversationMemberModel> members, @JsonKey(name: 'lastMessage')  MessagePreviewModel lastMessage, @JsonKey(name: 'lastMessageAt')  String lastMessageAt, @JsonKey(name: 'caseSummary')  CaseSummaryModel caseSummary, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'closedAt')  String closedAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,) {final _that = this;
switch (_that) {
case _ConversationModel() when $default != null:
return $default(_that.uid,_that.type,_that.status,_that.createdByUid,_that.linkedResourceType,_that.linkedResourceUid,_that.specialty,_that.description,_that.participantUids,_that.members,_that.lastMessage,_that.lastMessageAt,_that.caseSummary,_that.createdAt,_that.closedAt,_that.lastUpdatedAt,_that.synced);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _ConversationModel extends ConversationModel {
  const _ConversationModel({@JsonKey(name: 'uid') this.uid = '', @JsonKey(name: 'type') this.type = 'GroupConsult', @JsonKey(name: 'status') this.status = 'Open', @JsonKey(name: 'createdByUid') this.createdByUid = '', @JsonKey(name: 'linkedResourceType') this.linkedResourceType = 'Case', @JsonKey(name: 'linkedResourceUid') this.linkedResourceUid = '', @JsonKey(name: 'specialty') this.specialty = '', @JsonKey(name: 'description') this.description = '', @JsonKey(name: 'participantUids') final  List<String> participantUids = const <String>[], @JsonKey(name: 'members') final  Map<String, ConversationMemberModel> members = const <String, ConversationMemberModel>{}, @JsonKey(name: 'lastMessage') this.lastMessage = const MessagePreviewModel(), @JsonKey(name: 'lastMessageAt') this.lastMessageAt = '', @JsonKey(name: 'caseSummary') this.caseSummary = const CaseSummaryModel(), @JsonKey(name: 'createdAt') this.createdAt = '', @JsonKey(name: 'closedAt') this.closedAt = '', @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = '', @JsonKey(includeFromJson: false, includeToJson: false) this.synced = true}): _participantUids = participantUids,_members = members,super._();
  factory _ConversationModel.fromJson(Map<String, dynamic> json) => _$ConversationModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'type') final  String type;
@override@JsonKey(name: 'status') final  String status;
@override@JsonKey(name: 'createdByUid') final  String createdByUid;
@override@JsonKey(name: 'linkedResourceType') final  String linkedResourceType;
@override@JsonKey(name: 'linkedResourceUid') final  String linkedResourceUid;
@override@JsonKey(name: 'specialty') final  String specialty;
@override@JsonKey(name: 'description') final  String description;
 final  List<String> _participantUids;
@override@JsonKey(name: 'participantUids') List<String> get participantUids {
  if (_participantUids is EqualUnmodifiableListView) return _participantUids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantUids);
}

 final  Map<String, ConversationMemberModel> _members;
@override@JsonKey(name: 'members') Map<String, ConversationMemberModel> get members {
  if (_members is EqualUnmodifiableMapView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_members);
}

@override@JsonKey(name: 'lastMessage') final  MessagePreviewModel lastMessage;
@override@JsonKey(name: 'lastMessageAt') final  String lastMessageAt;
@override@JsonKey(name: 'caseSummary') final  CaseSummaryModel caseSummary;
@override@JsonKey(name: 'createdAt') final  String createdAt;
@override@JsonKey(name: 'closedAt') final  String closedAt;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool synced;

/// Create a copy of ConversationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationModelCopyWith<_ConversationModel> get copyWith => __$ConversationModelCopyWithImpl<_ConversationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConversationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConversationModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdByUid, createdByUid) || other.createdByUid == createdByUid)&&(identical(other.linkedResourceType, linkedResourceType) || other.linkedResourceType == linkedResourceType)&&(identical(other.linkedResourceUid, linkedResourceUid) || other.linkedResourceUid == linkedResourceUid)&&(identical(other.specialty, specialty) || other.specialty == specialty)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._participantUids, _participantUids)&&const DeepCollectionEquality().equals(other._members, _members)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.caseSummary, caseSummary) || other.caseSummary == caseSummary)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,type,status,createdByUid,linkedResourceType,linkedResourceUid,specialty,description,const DeepCollectionEquality().hash(_participantUids),const DeepCollectionEquality().hash(_members),lastMessage,lastMessageAt,caseSummary,createdAt,closedAt,lastUpdatedAt,synced);

@override
String toString() {
  return 'ConversationModel(uid: $uid, type: $type, status: $status, createdByUid: $createdByUid, linkedResourceType: $linkedResourceType, linkedResourceUid: $linkedResourceUid, specialty: $specialty, description: $description, participantUids: $participantUids, members: $members, lastMessage: $lastMessage, lastMessageAt: $lastMessageAt, caseSummary: $caseSummary, createdAt: $createdAt, closedAt: $closedAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class _$ConversationModelCopyWith<$Res> implements $ConversationModelCopyWith<$Res> {
  factory _$ConversationModelCopyWith(_ConversationModel value, $Res Function(_ConversationModel) _then) = __$ConversationModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'type') String type,@JsonKey(name: 'status') String status,@JsonKey(name: 'createdByUid') String createdByUid,@JsonKey(name: 'linkedResourceType') String linkedResourceType,@JsonKey(name: 'linkedResourceUid') String linkedResourceUid,@JsonKey(name: 'specialty') String specialty,@JsonKey(name: 'description') String description,@JsonKey(name: 'participantUids') List<String> participantUids,@JsonKey(name: 'members') Map<String, ConversationMemberModel> members,@JsonKey(name: 'lastMessage') MessagePreviewModel lastMessage,@JsonKey(name: 'lastMessageAt') String lastMessageAt,@JsonKey(name: 'caseSummary') CaseSummaryModel caseSummary,@JsonKey(name: 'createdAt') String createdAt,@JsonKey(name: 'closedAt') String closedAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});


@override $MessagePreviewModelCopyWith<$Res> get lastMessage;@override $CaseSummaryModelCopyWith<$Res> get caseSummary;

}
/// @nodoc
class __$ConversationModelCopyWithImpl<$Res>
    implements _$ConversationModelCopyWith<$Res> {
  __$ConversationModelCopyWithImpl(this._self, this._then);

  final _ConversationModel _self;
  final $Res Function(_ConversationModel) _then;

/// Create a copy of ConversationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? type = null,Object? status = null,Object? createdByUid = null,Object? linkedResourceType = null,Object? linkedResourceUid = null,Object? specialty = null,Object? description = null,Object? participantUids = null,Object? members = null,Object? lastMessage = null,Object? lastMessageAt = null,Object? caseSummary = null,Object? createdAt = null,Object? closedAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_ConversationModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdByUid: null == createdByUid ? _self.createdByUid : createdByUid // ignore: cast_nullable_to_non_nullable
as String,linkedResourceType: null == linkedResourceType ? _self.linkedResourceType : linkedResourceType // ignore: cast_nullable_to_non_nullable
as String,linkedResourceUid: null == linkedResourceUid ? _self.linkedResourceUid : linkedResourceUid // ignore: cast_nullable_to_non_nullable
as String,specialty: null == specialty ? _self.specialty : specialty // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,participantUids: null == participantUids ? _self._participantUids : participantUids // ignore: cast_nullable_to_non_nullable
as List<String>,members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as Map<String, ConversationMemberModel>,lastMessage: null == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as MessagePreviewModel,lastMessageAt: null == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as String,caseSummary: null == caseSummary ? _self.caseSummary : caseSummary // ignore: cast_nullable_to_non_nullable
as CaseSummaryModel,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,closedAt: null == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ConversationModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessagePreviewModelCopyWith<$Res> get lastMessage {
  
  return $MessagePreviewModelCopyWith<$Res>(_self.lastMessage, (value) {
    return _then(_self.copyWith(lastMessage: value));
  });
}/// Create a copy of ConversationModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CaseSummaryModelCopyWith<$Res> get caseSummary {
  
  return $CaseSummaryModelCopyWith<$Res>(_self.caseSummary, (value) {
    return _then(_self.copyWith(caseSummary: value));
  });
}
}

// dart format on
