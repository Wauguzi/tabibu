// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'threadUid') String get threadUid;@JsonKey(name: 'idempotencyKey') String get idempotencyKey;@JsonKey(name: 'creationDate') String get creationDate;@JsonKey(name: 'recipientUid') String get recipientUid;@JsonKey(name: 'recipientRole') String get recipientRole;@JsonKey(name: 'initiatorUid') String get initiatorUid;@JsonKey(name: 'initiatorRole') String get initiatorRole;@JsonKey(name: 'initiatorName') String get initiatorName;@JsonKey(name: 'title') String get title;@JsonKey(name: 'message') String get message;@JsonKey(name: 'templateKey') String get templateKey;@JsonKey(name: 'templateArgs') Map<String, String> get templateArgs;@JsonKey(name: 'category') String get category;@JsonKey(name: 'priority') String get priority;@JsonKey(name: 'channel') String get channel;@JsonKey(name: 'source') String get source;@JsonKey(name: 'scope') String get scope;@JsonKey(name: 'status') String get status;@JsonKey(name: 'readAt') String get readAt;@JsonKey(name: 'resourceType') String get resourceType;@JsonKey(name: 'resourceUid') String get resourceUid;@JsonKey(name: 'metadata') NotificationMetadataModel get metadata;@JsonKey(name: 'pushRequestedAt') String get pushRequestedAt;@JsonKey(name: 'pushSentAt') String get pushSentAt;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;@JsonKey(includeFromJson: false, includeToJson: false) bool get synced;
/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationModelCopyWith<NotificationModel> get copyWith => _$NotificationModelCopyWithImpl<NotificationModel>(this as NotificationModel, _$identity);

  /// Serializes this NotificationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.threadUid, threadUid) || other.threadUid == threadUid)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey)&&(identical(other.creationDate, creationDate) || other.creationDate == creationDate)&&(identical(other.recipientUid, recipientUid) || other.recipientUid == recipientUid)&&(identical(other.recipientRole, recipientRole) || other.recipientRole == recipientRole)&&(identical(other.initiatorUid, initiatorUid) || other.initiatorUid == initiatorUid)&&(identical(other.initiatorRole, initiatorRole) || other.initiatorRole == initiatorRole)&&(identical(other.initiatorName, initiatorName) || other.initiatorName == initiatorName)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.templateKey, templateKey) || other.templateKey == templateKey)&&const DeepCollectionEquality().equals(other.templateArgs, templateArgs)&&(identical(other.category, category) || other.category == category)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.source, source) || other.source == source)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.status, status) || other.status == status)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.resourceType, resourceType) || other.resourceType == resourceType)&&(identical(other.resourceUid, resourceUid) || other.resourceUid == resourceUid)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.pushRequestedAt, pushRequestedAt) || other.pushRequestedAt == pushRequestedAt)&&(identical(other.pushSentAt, pushSentAt) || other.pushSentAt == pushSentAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,threadUid,idempotencyKey,creationDate,recipientUid,recipientRole,initiatorUid,initiatorRole,initiatorName,title,message,templateKey,const DeepCollectionEquality().hash(templateArgs),category,priority,channel,source,scope,status,readAt,resourceType,resourceUid,metadata,pushRequestedAt,pushSentAt,lastUpdatedAt,synced]);

@override
String toString() {
  return 'NotificationModel(uid: $uid, threadUid: $threadUid, idempotencyKey: $idempotencyKey, creationDate: $creationDate, recipientUid: $recipientUid, recipientRole: $recipientRole, initiatorUid: $initiatorUid, initiatorRole: $initiatorRole, initiatorName: $initiatorName, title: $title, message: $message, templateKey: $templateKey, templateArgs: $templateArgs, category: $category, priority: $priority, channel: $channel, source: $source, scope: $scope, status: $status, readAt: $readAt, resourceType: $resourceType, resourceUid: $resourceUid, metadata: $metadata, pushRequestedAt: $pushRequestedAt, pushSentAt: $pushSentAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class $NotificationModelCopyWith<$Res>  {
  factory $NotificationModelCopyWith(NotificationModel value, $Res Function(NotificationModel) _then) = _$NotificationModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'threadUid') String threadUid,@JsonKey(name: 'idempotencyKey') String idempotencyKey,@JsonKey(name: 'creationDate') String creationDate,@JsonKey(name: 'recipientUid') String recipientUid,@JsonKey(name: 'recipientRole') String recipientRole,@JsonKey(name: 'initiatorUid') String initiatorUid,@JsonKey(name: 'initiatorRole') String initiatorRole,@JsonKey(name: 'initiatorName') String initiatorName,@JsonKey(name: 'title') String title,@JsonKey(name: 'message') String message,@JsonKey(name: 'templateKey') String templateKey,@JsonKey(name: 'templateArgs') Map<String, String> templateArgs,@JsonKey(name: 'category') String category,@JsonKey(name: 'priority') String priority,@JsonKey(name: 'channel') String channel,@JsonKey(name: 'source') String source,@JsonKey(name: 'scope') String scope,@JsonKey(name: 'status') String status,@JsonKey(name: 'readAt') String readAt,@JsonKey(name: 'resourceType') String resourceType,@JsonKey(name: 'resourceUid') String resourceUid,@JsonKey(name: 'metadata') NotificationMetadataModel metadata,@JsonKey(name: 'pushRequestedAt') String pushRequestedAt,@JsonKey(name: 'pushSentAt') String pushSentAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});


$NotificationMetadataModelCopyWith<$Res> get metadata;

}
/// @nodoc
class _$NotificationModelCopyWithImpl<$Res>
    implements $NotificationModelCopyWith<$Res> {
  _$NotificationModelCopyWithImpl(this._self, this._then);

  final NotificationModel _self;
  final $Res Function(NotificationModel) _then;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? threadUid = null,Object? idempotencyKey = null,Object? creationDate = null,Object? recipientUid = null,Object? recipientRole = null,Object? initiatorUid = null,Object? initiatorRole = null,Object? initiatorName = null,Object? title = null,Object? message = null,Object? templateKey = null,Object? templateArgs = null,Object? category = null,Object? priority = null,Object? channel = null,Object? source = null,Object? scope = null,Object? status = null,Object? readAt = null,Object? resourceType = null,Object? resourceUid = null,Object? metadata = null,Object? pushRequestedAt = null,Object? pushSentAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,threadUid: null == threadUid ? _self.threadUid : threadUid // ignore: cast_nullable_to_non_nullable
as String,idempotencyKey: null == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String,creationDate: null == creationDate ? _self.creationDate : creationDate // ignore: cast_nullable_to_non_nullable
as String,recipientUid: null == recipientUid ? _self.recipientUid : recipientUid // ignore: cast_nullable_to_non_nullable
as String,recipientRole: null == recipientRole ? _self.recipientRole : recipientRole // ignore: cast_nullable_to_non_nullable
as String,initiatorUid: null == initiatorUid ? _self.initiatorUid : initiatorUid // ignore: cast_nullable_to_non_nullable
as String,initiatorRole: null == initiatorRole ? _self.initiatorRole : initiatorRole // ignore: cast_nullable_to_non_nullable
as String,initiatorName: null == initiatorName ? _self.initiatorName : initiatorName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,templateKey: null == templateKey ? _self.templateKey : templateKey // ignore: cast_nullable_to_non_nullable
as String,templateArgs: null == templateArgs ? _self.templateArgs : templateArgs // ignore: cast_nullable_to_non_nullable
as Map<String, String>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,readAt: null == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as String,resourceType: null == resourceType ? _self.resourceType : resourceType // ignore: cast_nullable_to_non_nullable
as String,resourceUid: null == resourceUid ? _self.resourceUid : resourceUid // ignore: cast_nullable_to_non_nullable
as String,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as NotificationMetadataModel,pushRequestedAt: null == pushRequestedAt ? _self.pushRequestedAt : pushRequestedAt // ignore: cast_nullable_to_non_nullable
as String,pushSentAt: null == pushSentAt ? _self.pushSentAt : pushSentAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationMetadataModelCopyWith<$Res> get metadata {
  
  return $NotificationMetadataModelCopyWith<$Res>(_self.metadata, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}


/// Adds pattern-matching-related methods to [NotificationModel].
extension NotificationModelPatterns on NotificationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationModel value)  $default,){
final _that = this;
switch (_that) {
case _NotificationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationModel value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'threadUid')  String threadUid, @JsonKey(name: 'idempotencyKey')  String idempotencyKey, @JsonKey(name: 'creationDate')  String creationDate, @JsonKey(name: 'recipientUid')  String recipientUid, @JsonKey(name: 'recipientRole')  String recipientRole, @JsonKey(name: 'initiatorUid')  String initiatorUid, @JsonKey(name: 'initiatorRole')  String initiatorRole, @JsonKey(name: 'initiatorName')  String initiatorName, @JsonKey(name: 'title')  String title, @JsonKey(name: 'message')  String message, @JsonKey(name: 'templateKey')  String templateKey, @JsonKey(name: 'templateArgs')  Map<String, String> templateArgs, @JsonKey(name: 'category')  String category, @JsonKey(name: 'priority')  String priority, @JsonKey(name: 'channel')  String channel, @JsonKey(name: 'source')  String source, @JsonKey(name: 'scope')  String scope, @JsonKey(name: 'status')  String status, @JsonKey(name: 'readAt')  String readAt, @JsonKey(name: 'resourceType')  String resourceType, @JsonKey(name: 'resourceUid')  String resourceUid, @JsonKey(name: 'metadata')  NotificationMetadataModel metadata, @JsonKey(name: 'pushRequestedAt')  String pushRequestedAt, @JsonKey(name: 'pushSentAt')  String pushSentAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
return $default(_that.uid,_that.threadUid,_that.idempotencyKey,_that.creationDate,_that.recipientUid,_that.recipientRole,_that.initiatorUid,_that.initiatorRole,_that.initiatorName,_that.title,_that.message,_that.templateKey,_that.templateArgs,_that.category,_that.priority,_that.channel,_that.source,_that.scope,_that.status,_that.readAt,_that.resourceType,_that.resourceUid,_that.metadata,_that.pushRequestedAt,_that.pushSentAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'threadUid')  String threadUid, @JsonKey(name: 'idempotencyKey')  String idempotencyKey, @JsonKey(name: 'creationDate')  String creationDate, @JsonKey(name: 'recipientUid')  String recipientUid, @JsonKey(name: 'recipientRole')  String recipientRole, @JsonKey(name: 'initiatorUid')  String initiatorUid, @JsonKey(name: 'initiatorRole')  String initiatorRole, @JsonKey(name: 'initiatorName')  String initiatorName, @JsonKey(name: 'title')  String title, @JsonKey(name: 'message')  String message, @JsonKey(name: 'templateKey')  String templateKey, @JsonKey(name: 'templateArgs')  Map<String, String> templateArgs, @JsonKey(name: 'category')  String category, @JsonKey(name: 'priority')  String priority, @JsonKey(name: 'channel')  String channel, @JsonKey(name: 'source')  String source, @JsonKey(name: 'scope')  String scope, @JsonKey(name: 'status')  String status, @JsonKey(name: 'readAt')  String readAt, @JsonKey(name: 'resourceType')  String resourceType, @JsonKey(name: 'resourceUid')  String resourceUid, @JsonKey(name: 'metadata')  NotificationMetadataModel metadata, @JsonKey(name: 'pushRequestedAt')  String pushRequestedAt, @JsonKey(name: 'pushSentAt')  String pushSentAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)  $default,) {final _that = this;
switch (_that) {
case _NotificationModel():
return $default(_that.uid,_that.threadUid,_that.idempotencyKey,_that.creationDate,_that.recipientUid,_that.recipientRole,_that.initiatorUid,_that.initiatorRole,_that.initiatorName,_that.title,_that.message,_that.templateKey,_that.templateArgs,_that.category,_that.priority,_that.channel,_that.source,_that.scope,_that.status,_that.readAt,_that.resourceType,_that.resourceUid,_that.metadata,_that.pushRequestedAt,_that.pushSentAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'threadUid')  String threadUid, @JsonKey(name: 'idempotencyKey')  String idempotencyKey, @JsonKey(name: 'creationDate')  String creationDate, @JsonKey(name: 'recipientUid')  String recipientUid, @JsonKey(name: 'recipientRole')  String recipientRole, @JsonKey(name: 'initiatorUid')  String initiatorUid, @JsonKey(name: 'initiatorRole')  String initiatorRole, @JsonKey(name: 'initiatorName')  String initiatorName, @JsonKey(name: 'title')  String title, @JsonKey(name: 'message')  String message, @JsonKey(name: 'templateKey')  String templateKey, @JsonKey(name: 'templateArgs')  Map<String, String> templateArgs, @JsonKey(name: 'category')  String category, @JsonKey(name: 'priority')  String priority, @JsonKey(name: 'channel')  String channel, @JsonKey(name: 'source')  String source, @JsonKey(name: 'scope')  String scope, @JsonKey(name: 'status')  String status, @JsonKey(name: 'readAt')  String readAt, @JsonKey(name: 'resourceType')  String resourceType, @JsonKey(name: 'resourceUid')  String resourceUid, @JsonKey(name: 'metadata')  NotificationMetadataModel metadata, @JsonKey(name: 'pushRequestedAt')  String pushRequestedAt, @JsonKey(name: 'pushSentAt')  String pushSentAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,) {final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
return $default(_that.uid,_that.threadUid,_that.idempotencyKey,_that.creationDate,_that.recipientUid,_that.recipientRole,_that.initiatorUid,_that.initiatorRole,_that.initiatorName,_that.title,_that.message,_that.templateKey,_that.templateArgs,_that.category,_that.priority,_that.channel,_that.source,_that.scope,_that.status,_that.readAt,_that.resourceType,_that.resourceUid,_that.metadata,_that.pushRequestedAt,_that.pushSentAt,_that.lastUpdatedAt,_that.synced);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _NotificationModel extends NotificationModel {
  const _NotificationModel({@JsonKey(name: 'uid') this.uid = '', @JsonKey(name: 'threadUid') this.threadUid = '', @JsonKey(name: 'idempotencyKey') this.idempotencyKey = '', @JsonKey(name: 'creationDate') this.creationDate = '', @JsonKey(name: 'recipientUid') this.recipientUid = '', @JsonKey(name: 'recipientRole') this.recipientRole = '', @JsonKey(name: 'initiatorUid') this.initiatorUid = '', @JsonKey(name: 'initiatorRole') this.initiatorRole = '', @JsonKey(name: 'initiatorName') this.initiatorName = '', @JsonKey(name: 'title') this.title = '', @JsonKey(name: 'message') this.message = '', @JsonKey(name: 'templateKey') this.templateKey = '', @JsonKey(name: 'templateArgs') final  Map<String, String> templateArgs = const <String, String>{}, @JsonKey(name: 'category') this.category = '', @JsonKey(name: 'priority') this.priority = '', @JsonKey(name: 'channel') this.channel = '', @JsonKey(name: 'source') this.source = '', @JsonKey(name: 'scope') this.scope = '', @JsonKey(name: 'status') this.status = 'Unread', @JsonKey(name: 'readAt') this.readAt = '', @JsonKey(name: 'resourceType') this.resourceType = '', @JsonKey(name: 'resourceUid') this.resourceUid = '', @JsonKey(name: 'metadata') this.metadata = const NotificationMetadataModel(), @JsonKey(name: 'pushRequestedAt') this.pushRequestedAt = '', @JsonKey(name: 'pushSentAt') this.pushSentAt = '', @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = '', @JsonKey(includeFromJson: false, includeToJson: false) this.synced = true}): _templateArgs = templateArgs,super._();
  factory _NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'threadUid') final  String threadUid;
@override@JsonKey(name: 'idempotencyKey') final  String idempotencyKey;
@override@JsonKey(name: 'creationDate') final  String creationDate;
@override@JsonKey(name: 'recipientUid') final  String recipientUid;
@override@JsonKey(name: 'recipientRole') final  String recipientRole;
@override@JsonKey(name: 'initiatorUid') final  String initiatorUid;
@override@JsonKey(name: 'initiatorRole') final  String initiatorRole;
@override@JsonKey(name: 'initiatorName') final  String initiatorName;
@override@JsonKey(name: 'title') final  String title;
@override@JsonKey(name: 'message') final  String message;
@override@JsonKey(name: 'templateKey') final  String templateKey;
 final  Map<String, String> _templateArgs;
@override@JsonKey(name: 'templateArgs') Map<String, String> get templateArgs {
  if (_templateArgs is EqualUnmodifiableMapView) return _templateArgs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_templateArgs);
}

@override@JsonKey(name: 'category') final  String category;
@override@JsonKey(name: 'priority') final  String priority;
@override@JsonKey(name: 'channel') final  String channel;
@override@JsonKey(name: 'source') final  String source;
@override@JsonKey(name: 'scope') final  String scope;
@override@JsonKey(name: 'status') final  String status;
@override@JsonKey(name: 'readAt') final  String readAt;
@override@JsonKey(name: 'resourceType') final  String resourceType;
@override@JsonKey(name: 'resourceUid') final  String resourceUid;
@override@JsonKey(name: 'metadata') final  NotificationMetadataModel metadata;
@override@JsonKey(name: 'pushRequestedAt') final  String pushRequestedAt;
@override@JsonKey(name: 'pushSentAt') final  String pushSentAt;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool synced;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationModelCopyWith<_NotificationModel> get copyWith => __$NotificationModelCopyWithImpl<_NotificationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.threadUid, threadUid) || other.threadUid == threadUid)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey)&&(identical(other.creationDate, creationDate) || other.creationDate == creationDate)&&(identical(other.recipientUid, recipientUid) || other.recipientUid == recipientUid)&&(identical(other.recipientRole, recipientRole) || other.recipientRole == recipientRole)&&(identical(other.initiatorUid, initiatorUid) || other.initiatorUid == initiatorUid)&&(identical(other.initiatorRole, initiatorRole) || other.initiatorRole == initiatorRole)&&(identical(other.initiatorName, initiatorName) || other.initiatorName == initiatorName)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.templateKey, templateKey) || other.templateKey == templateKey)&&const DeepCollectionEquality().equals(other._templateArgs, _templateArgs)&&(identical(other.category, category) || other.category == category)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.source, source) || other.source == source)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.status, status) || other.status == status)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.resourceType, resourceType) || other.resourceType == resourceType)&&(identical(other.resourceUid, resourceUid) || other.resourceUid == resourceUid)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.pushRequestedAt, pushRequestedAt) || other.pushRequestedAt == pushRequestedAt)&&(identical(other.pushSentAt, pushSentAt) || other.pushSentAt == pushSentAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,threadUid,idempotencyKey,creationDate,recipientUid,recipientRole,initiatorUid,initiatorRole,initiatorName,title,message,templateKey,const DeepCollectionEquality().hash(_templateArgs),category,priority,channel,source,scope,status,readAt,resourceType,resourceUid,metadata,pushRequestedAt,pushSentAt,lastUpdatedAt,synced]);

@override
String toString() {
  return 'NotificationModel(uid: $uid, threadUid: $threadUid, idempotencyKey: $idempotencyKey, creationDate: $creationDate, recipientUid: $recipientUid, recipientRole: $recipientRole, initiatorUid: $initiatorUid, initiatorRole: $initiatorRole, initiatorName: $initiatorName, title: $title, message: $message, templateKey: $templateKey, templateArgs: $templateArgs, category: $category, priority: $priority, channel: $channel, source: $source, scope: $scope, status: $status, readAt: $readAt, resourceType: $resourceType, resourceUid: $resourceUid, metadata: $metadata, pushRequestedAt: $pushRequestedAt, pushSentAt: $pushSentAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class _$NotificationModelCopyWith<$Res> implements $NotificationModelCopyWith<$Res> {
  factory _$NotificationModelCopyWith(_NotificationModel value, $Res Function(_NotificationModel) _then) = __$NotificationModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'threadUid') String threadUid,@JsonKey(name: 'idempotencyKey') String idempotencyKey,@JsonKey(name: 'creationDate') String creationDate,@JsonKey(name: 'recipientUid') String recipientUid,@JsonKey(name: 'recipientRole') String recipientRole,@JsonKey(name: 'initiatorUid') String initiatorUid,@JsonKey(name: 'initiatorRole') String initiatorRole,@JsonKey(name: 'initiatorName') String initiatorName,@JsonKey(name: 'title') String title,@JsonKey(name: 'message') String message,@JsonKey(name: 'templateKey') String templateKey,@JsonKey(name: 'templateArgs') Map<String, String> templateArgs,@JsonKey(name: 'category') String category,@JsonKey(name: 'priority') String priority,@JsonKey(name: 'channel') String channel,@JsonKey(name: 'source') String source,@JsonKey(name: 'scope') String scope,@JsonKey(name: 'status') String status,@JsonKey(name: 'readAt') String readAt,@JsonKey(name: 'resourceType') String resourceType,@JsonKey(name: 'resourceUid') String resourceUid,@JsonKey(name: 'metadata') NotificationMetadataModel metadata,@JsonKey(name: 'pushRequestedAt') String pushRequestedAt,@JsonKey(name: 'pushSentAt') String pushSentAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});


@override $NotificationMetadataModelCopyWith<$Res> get metadata;

}
/// @nodoc
class __$NotificationModelCopyWithImpl<$Res>
    implements _$NotificationModelCopyWith<$Res> {
  __$NotificationModelCopyWithImpl(this._self, this._then);

  final _NotificationModel _self;
  final $Res Function(_NotificationModel) _then;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? threadUid = null,Object? idempotencyKey = null,Object? creationDate = null,Object? recipientUid = null,Object? recipientRole = null,Object? initiatorUid = null,Object? initiatorRole = null,Object? initiatorName = null,Object? title = null,Object? message = null,Object? templateKey = null,Object? templateArgs = null,Object? category = null,Object? priority = null,Object? channel = null,Object? source = null,Object? scope = null,Object? status = null,Object? readAt = null,Object? resourceType = null,Object? resourceUid = null,Object? metadata = null,Object? pushRequestedAt = null,Object? pushSentAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_NotificationModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,threadUid: null == threadUid ? _self.threadUid : threadUid // ignore: cast_nullable_to_non_nullable
as String,idempotencyKey: null == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String,creationDate: null == creationDate ? _self.creationDate : creationDate // ignore: cast_nullable_to_non_nullable
as String,recipientUid: null == recipientUid ? _self.recipientUid : recipientUid // ignore: cast_nullable_to_non_nullable
as String,recipientRole: null == recipientRole ? _self.recipientRole : recipientRole // ignore: cast_nullable_to_non_nullable
as String,initiatorUid: null == initiatorUid ? _self.initiatorUid : initiatorUid // ignore: cast_nullable_to_non_nullable
as String,initiatorRole: null == initiatorRole ? _self.initiatorRole : initiatorRole // ignore: cast_nullable_to_non_nullable
as String,initiatorName: null == initiatorName ? _self.initiatorName : initiatorName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,templateKey: null == templateKey ? _self.templateKey : templateKey // ignore: cast_nullable_to_non_nullable
as String,templateArgs: null == templateArgs ? _self._templateArgs : templateArgs // ignore: cast_nullable_to_non_nullable
as Map<String, String>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,readAt: null == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as String,resourceType: null == resourceType ? _self.resourceType : resourceType // ignore: cast_nullable_to_non_nullable
as String,resourceUid: null == resourceUid ? _self.resourceUid : resourceUid // ignore: cast_nullable_to_non_nullable
as String,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as NotificationMetadataModel,pushRequestedAt: null == pushRequestedAt ? _self.pushRequestedAt : pushRequestedAt // ignore: cast_nullable_to_non_nullable
as String,pushSentAt: null == pushSentAt ? _self.pushSentAt : pushSentAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationMetadataModelCopyWith<$Res> get metadata {
  
  return $NotificationMetadataModelCopyWith<$Res>(_self.metadata, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}

// dart format on
