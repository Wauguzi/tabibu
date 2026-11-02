// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessageModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'conversationUid') String get conversationUid;@JsonKey(name: 'senderUid') String get senderUid;@JsonKey(name: 'kind') String get kind;@JsonKey(name: 'text') String get text;@JsonKey(name: 'transcriptStatus') String get transcriptStatus;@JsonKey(name: 'transcriptShared') bool get transcriptShared;@JsonKey(name: 'transcriptLanguage') String get transcriptLanguage;@JsonKey(name: 'inputMode') String get inputMode;@JsonKey(name: 'identifierFlagged') bool get identifierFlagged;@JsonKey(name: 'attachmentPath') String get attachmentPath;@JsonKey(name: 'attachmentType') String get attachmentType;@JsonKey(name: 'attachmentSize') int get attachmentSize;@JsonKey(name: 'voiceDurationMs') int get voiceDurationMs;@JsonKey(name: 'voicePeaks') List<int> get voicePeaks;@JsonKey(name: 'withheldReason') String get withheldReason;@JsonKey(name: 'status') String get status;@JsonKey(name: 'sentAt') String get sentAt;@JsonKey(name: 'deliveredAt') String get deliveredAt;@JsonKey(includeFromJson: false, includeToJson: false) String get localAttachmentPath;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;@JsonKey(includeFromJson: false, includeToJson: false) bool get synced;
/// Create a copy of MessageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageModelCopyWith<MessageModel> get copyWith => _$MessageModelCopyWithImpl<MessageModel>(this as MessageModel, _$identity);

  /// Serializes this MessageModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.conversationUid, conversationUid) || other.conversationUid == conversationUid)&&(identical(other.senderUid, senderUid) || other.senderUid == senderUid)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.text, text) || other.text == text)&&(identical(other.transcriptStatus, transcriptStatus) || other.transcriptStatus == transcriptStatus)&&(identical(other.transcriptShared, transcriptShared) || other.transcriptShared == transcriptShared)&&(identical(other.transcriptLanguage, transcriptLanguage) || other.transcriptLanguage == transcriptLanguage)&&(identical(other.inputMode, inputMode) || other.inputMode == inputMode)&&(identical(other.identifierFlagged, identifierFlagged) || other.identifierFlagged == identifierFlagged)&&(identical(other.attachmentPath, attachmentPath) || other.attachmentPath == attachmentPath)&&(identical(other.attachmentType, attachmentType) || other.attachmentType == attachmentType)&&(identical(other.attachmentSize, attachmentSize) || other.attachmentSize == attachmentSize)&&(identical(other.voiceDurationMs, voiceDurationMs) || other.voiceDurationMs == voiceDurationMs)&&const DeepCollectionEquality().equals(other.voicePeaks, voicePeaks)&&(identical(other.withheldReason, withheldReason) || other.withheldReason == withheldReason)&&(identical(other.status, status) || other.status == status)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.localAttachmentPath, localAttachmentPath) || other.localAttachmentPath == localAttachmentPath)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,conversationUid,senderUid,kind,text,transcriptStatus,transcriptShared,transcriptLanguage,inputMode,identifierFlagged,attachmentPath,attachmentType,attachmentSize,voiceDurationMs,const DeepCollectionEquality().hash(voicePeaks),withheldReason,status,sentAt,deliveredAt,localAttachmentPath,lastUpdatedAt,synced]);

@override
String toString() {
  return 'MessageModel(uid: $uid, conversationUid: $conversationUid, senderUid: $senderUid, kind: $kind, text: $text, transcriptStatus: $transcriptStatus, transcriptShared: $transcriptShared, transcriptLanguage: $transcriptLanguage, inputMode: $inputMode, identifierFlagged: $identifierFlagged, attachmentPath: $attachmentPath, attachmentType: $attachmentType, attachmentSize: $attachmentSize, voiceDurationMs: $voiceDurationMs, voicePeaks: $voicePeaks, withheldReason: $withheldReason, status: $status, sentAt: $sentAt, deliveredAt: $deliveredAt, localAttachmentPath: $localAttachmentPath, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class $MessageModelCopyWith<$Res>  {
  factory $MessageModelCopyWith(MessageModel value, $Res Function(MessageModel) _then) = _$MessageModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'conversationUid') String conversationUid,@JsonKey(name: 'senderUid') String senderUid,@JsonKey(name: 'kind') String kind,@JsonKey(name: 'text') String text,@JsonKey(name: 'transcriptStatus') String transcriptStatus,@JsonKey(name: 'transcriptShared') bool transcriptShared,@JsonKey(name: 'transcriptLanguage') String transcriptLanguage,@JsonKey(name: 'inputMode') String inputMode,@JsonKey(name: 'identifierFlagged') bool identifierFlagged,@JsonKey(name: 'attachmentPath') String attachmentPath,@JsonKey(name: 'attachmentType') String attachmentType,@JsonKey(name: 'attachmentSize') int attachmentSize,@JsonKey(name: 'voiceDurationMs') int voiceDurationMs,@JsonKey(name: 'voicePeaks') List<int> voicePeaks,@JsonKey(name: 'withheldReason') String withheldReason,@JsonKey(name: 'status') String status,@JsonKey(name: 'sentAt') String sentAt,@JsonKey(name: 'deliveredAt') String deliveredAt,@JsonKey(includeFromJson: false, includeToJson: false) String localAttachmentPath,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class _$MessageModelCopyWithImpl<$Res>
    implements $MessageModelCopyWith<$Res> {
  _$MessageModelCopyWithImpl(this._self, this._then);

  final MessageModel _self;
  final $Res Function(MessageModel) _then;

/// Create a copy of MessageModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? conversationUid = null,Object? senderUid = null,Object? kind = null,Object? text = null,Object? transcriptStatus = null,Object? transcriptShared = null,Object? transcriptLanguage = null,Object? inputMode = null,Object? identifierFlagged = null,Object? attachmentPath = null,Object? attachmentType = null,Object? attachmentSize = null,Object? voiceDurationMs = null,Object? voicePeaks = null,Object? withheldReason = null,Object? status = null,Object? sentAt = null,Object? deliveredAt = null,Object? localAttachmentPath = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,conversationUid: null == conversationUid ? _self.conversationUid : conversationUid // ignore: cast_nullable_to_non_nullable
as String,senderUid: null == senderUid ? _self.senderUid : senderUid // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,transcriptStatus: null == transcriptStatus ? _self.transcriptStatus : transcriptStatus // ignore: cast_nullable_to_non_nullable
as String,transcriptShared: null == transcriptShared ? _self.transcriptShared : transcriptShared // ignore: cast_nullable_to_non_nullable
as bool,transcriptLanguage: null == transcriptLanguage ? _self.transcriptLanguage : transcriptLanguage // ignore: cast_nullable_to_non_nullable
as String,inputMode: null == inputMode ? _self.inputMode : inputMode // ignore: cast_nullable_to_non_nullable
as String,identifierFlagged: null == identifierFlagged ? _self.identifierFlagged : identifierFlagged // ignore: cast_nullable_to_non_nullable
as bool,attachmentPath: null == attachmentPath ? _self.attachmentPath : attachmentPath // ignore: cast_nullable_to_non_nullable
as String,attachmentType: null == attachmentType ? _self.attachmentType : attachmentType // ignore: cast_nullable_to_non_nullable
as String,attachmentSize: null == attachmentSize ? _self.attachmentSize : attachmentSize // ignore: cast_nullable_to_non_nullable
as int,voiceDurationMs: null == voiceDurationMs ? _self.voiceDurationMs : voiceDurationMs // ignore: cast_nullable_to_non_nullable
as int,voicePeaks: null == voicePeaks ? _self.voicePeaks : voicePeaks // ignore: cast_nullable_to_non_nullable
as List<int>,withheldReason: null == withheldReason ? _self.withheldReason : withheldReason // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as String,deliveredAt: null == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as String,localAttachmentPath: null == localAttachmentPath ? _self.localAttachmentPath : localAttachmentPath // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageModel].
extension MessageModelPatterns on MessageModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageModel value)  $default,){
final _that = this;
switch (_that) {
case _MessageModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageModel value)?  $default,){
final _that = this;
switch (_that) {
case _MessageModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'conversationUid')  String conversationUid, @JsonKey(name: 'senderUid')  String senderUid, @JsonKey(name: 'kind')  String kind, @JsonKey(name: 'text')  String text, @JsonKey(name: 'transcriptStatus')  String transcriptStatus, @JsonKey(name: 'transcriptShared')  bool transcriptShared, @JsonKey(name: 'transcriptLanguage')  String transcriptLanguage, @JsonKey(name: 'inputMode')  String inputMode, @JsonKey(name: 'identifierFlagged')  bool identifierFlagged, @JsonKey(name: 'attachmentPath')  String attachmentPath, @JsonKey(name: 'attachmentType')  String attachmentType, @JsonKey(name: 'attachmentSize')  int attachmentSize, @JsonKey(name: 'voiceDurationMs')  int voiceDurationMs, @JsonKey(name: 'voicePeaks')  List<int> voicePeaks, @JsonKey(name: 'withheldReason')  String withheldReason, @JsonKey(name: 'status')  String status, @JsonKey(name: 'sentAt')  String sentAt, @JsonKey(name: 'deliveredAt')  String deliveredAt, @JsonKey(includeFromJson: false, includeToJson: false)  String localAttachmentPath, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageModel() when $default != null:
return $default(_that.uid,_that.conversationUid,_that.senderUid,_that.kind,_that.text,_that.transcriptStatus,_that.transcriptShared,_that.transcriptLanguage,_that.inputMode,_that.identifierFlagged,_that.attachmentPath,_that.attachmentType,_that.attachmentSize,_that.voiceDurationMs,_that.voicePeaks,_that.withheldReason,_that.status,_that.sentAt,_that.deliveredAt,_that.localAttachmentPath,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'conversationUid')  String conversationUid, @JsonKey(name: 'senderUid')  String senderUid, @JsonKey(name: 'kind')  String kind, @JsonKey(name: 'text')  String text, @JsonKey(name: 'transcriptStatus')  String transcriptStatus, @JsonKey(name: 'transcriptShared')  bool transcriptShared, @JsonKey(name: 'transcriptLanguage')  String transcriptLanguage, @JsonKey(name: 'inputMode')  String inputMode, @JsonKey(name: 'identifierFlagged')  bool identifierFlagged, @JsonKey(name: 'attachmentPath')  String attachmentPath, @JsonKey(name: 'attachmentType')  String attachmentType, @JsonKey(name: 'attachmentSize')  int attachmentSize, @JsonKey(name: 'voiceDurationMs')  int voiceDurationMs, @JsonKey(name: 'voicePeaks')  List<int> voicePeaks, @JsonKey(name: 'withheldReason')  String withheldReason, @JsonKey(name: 'status')  String status, @JsonKey(name: 'sentAt')  String sentAt, @JsonKey(name: 'deliveredAt')  String deliveredAt, @JsonKey(includeFromJson: false, includeToJson: false)  String localAttachmentPath, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)  $default,) {final _that = this;
switch (_that) {
case _MessageModel():
return $default(_that.uid,_that.conversationUid,_that.senderUid,_that.kind,_that.text,_that.transcriptStatus,_that.transcriptShared,_that.transcriptLanguage,_that.inputMode,_that.identifierFlagged,_that.attachmentPath,_that.attachmentType,_that.attachmentSize,_that.voiceDurationMs,_that.voicePeaks,_that.withheldReason,_that.status,_that.sentAt,_that.deliveredAt,_that.localAttachmentPath,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'conversationUid')  String conversationUid, @JsonKey(name: 'senderUid')  String senderUid, @JsonKey(name: 'kind')  String kind, @JsonKey(name: 'text')  String text, @JsonKey(name: 'transcriptStatus')  String transcriptStatus, @JsonKey(name: 'transcriptShared')  bool transcriptShared, @JsonKey(name: 'transcriptLanguage')  String transcriptLanguage, @JsonKey(name: 'inputMode')  String inputMode, @JsonKey(name: 'identifierFlagged')  bool identifierFlagged, @JsonKey(name: 'attachmentPath')  String attachmentPath, @JsonKey(name: 'attachmentType')  String attachmentType, @JsonKey(name: 'attachmentSize')  int attachmentSize, @JsonKey(name: 'voiceDurationMs')  int voiceDurationMs, @JsonKey(name: 'voicePeaks')  List<int> voicePeaks, @JsonKey(name: 'withheldReason')  String withheldReason, @JsonKey(name: 'status')  String status, @JsonKey(name: 'sentAt')  String sentAt, @JsonKey(name: 'deliveredAt')  String deliveredAt, @JsonKey(includeFromJson: false, includeToJson: false)  String localAttachmentPath, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,) {final _that = this;
switch (_that) {
case _MessageModel() when $default != null:
return $default(_that.uid,_that.conversationUid,_that.senderUid,_that.kind,_that.text,_that.transcriptStatus,_that.transcriptShared,_that.transcriptLanguage,_that.inputMode,_that.identifierFlagged,_that.attachmentPath,_that.attachmentType,_that.attachmentSize,_that.voiceDurationMs,_that.voicePeaks,_that.withheldReason,_that.status,_that.sentAt,_that.deliveredAt,_that.localAttachmentPath,_that.lastUpdatedAt,_that.synced);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageModel extends MessageModel {
  const _MessageModel({@JsonKey(name: 'uid') this.uid = '', @JsonKey(name: 'conversationUid') this.conversationUid = '', @JsonKey(name: 'senderUid') this.senderUid = '', @JsonKey(name: 'kind') this.kind = 'Text', @JsonKey(name: 'text') this.text = '', @JsonKey(name: 'transcriptStatus') this.transcriptStatus = 'None', @JsonKey(name: 'transcriptShared') this.transcriptShared = false, @JsonKey(name: 'transcriptLanguage') this.transcriptLanguage = '', @JsonKey(name: 'inputMode') this.inputMode = 'Typed', @JsonKey(name: 'identifierFlagged') this.identifierFlagged = false, @JsonKey(name: 'attachmentPath') this.attachmentPath = '', @JsonKey(name: 'attachmentType') this.attachmentType = '', @JsonKey(name: 'attachmentSize') this.attachmentSize = 0, @JsonKey(name: 'voiceDurationMs') this.voiceDurationMs = 0, @JsonKey(name: 'voicePeaks') final  List<int> voicePeaks = const <int>[], @JsonKey(name: 'withheldReason') this.withheldReason = '', @JsonKey(name: 'status') this.status = '', @JsonKey(name: 'sentAt') this.sentAt = '', @JsonKey(name: 'deliveredAt') this.deliveredAt = '', @JsonKey(includeFromJson: false, includeToJson: false) this.localAttachmentPath = '', @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = '', @JsonKey(includeFromJson: false, includeToJson: false) this.synced = true}): _voicePeaks = voicePeaks,super._();
  factory _MessageModel.fromJson(Map<String, dynamic> json) => _$MessageModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'conversationUid') final  String conversationUid;
@override@JsonKey(name: 'senderUid') final  String senderUid;
@override@JsonKey(name: 'kind') final  String kind;
@override@JsonKey(name: 'text') final  String text;
@override@JsonKey(name: 'transcriptStatus') final  String transcriptStatus;
@override@JsonKey(name: 'transcriptShared') final  bool transcriptShared;
@override@JsonKey(name: 'transcriptLanguage') final  String transcriptLanguage;
@override@JsonKey(name: 'inputMode') final  String inputMode;
@override@JsonKey(name: 'identifierFlagged') final  bool identifierFlagged;
@override@JsonKey(name: 'attachmentPath') final  String attachmentPath;
@override@JsonKey(name: 'attachmentType') final  String attachmentType;
@override@JsonKey(name: 'attachmentSize') final  int attachmentSize;
@override@JsonKey(name: 'voiceDurationMs') final  int voiceDurationMs;
 final  List<int> _voicePeaks;
@override@JsonKey(name: 'voicePeaks') List<int> get voicePeaks {
  if (_voicePeaks is EqualUnmodifiableListView) return _voicePeaks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_voicePeaks);
}

@override@JsonKey(name: 'withheldReason') final  String withheldReason;
@override@JsonKey(name: 'status') final  String status;
@override@JsonKey(name: 'sentAt') final  String sentAt;
@override@JsonKey(name: 'deliveredAt') final  String deliveredAt;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  String localAttachmentPath;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool synced;

/// Create a copy of MessageModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageModelCopyWith<_MessageModel> get copyWith => __$MessageModelCopyWithImpl<_MessageModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.conversationUid, conversationUid) || other.conversationUid == conversationUid)&&(identical(other.senderUid, senderUid) || other.senderUid == senderUid)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.text, text) || other.text == text)&&(identical(other.transcriptStatus, transcriptStatus) || other.transcriptStatus == transcriptStatus)&&(identical(other.transcriptShared, transcriptShared) || other.transcriptShared == transcriptShared)&&(identical(other.transcriptLanguage, transcriptLanguage) || other.transcriptLanguage == transcriptLanguage)&&(identical(other.inputMode, inputMode) || other.inputMode == inputMode)&&(identical(other.identifierFlagged, identifierFlagged) || other.identifierFlagged == identifierFlagged)&&(identical(other.attachmentPath, attachmentPath) || other.attachmentPath == attachmentPath)&&(identical(other.attachmentType, attachmentType) || other.attachmentType == attachmentType)&&(identical(other.attachmentSize, attachmentSize) || other.attachmentSize == attachmentSize)&&(identical(other.voiceDurationMs, voiceDurationMs) || other.voiceDurationMs == voiceDurationMs)&&const DeepCollectionEquality().equals(other._voicePeaks, _voicePeaks)&&(identical(other.withheldReason, withheldReason) || other.withheldReason == withheldReason)&&(identical(other.status, status) || other.status == status)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.localAttachmentPath, localAttachmentPath) || other.localAttachmentPath == localAttachmentPath)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,conversationUid,senderUid,kind,text,transcriptStatus,transcriptShared,transcriptLanguage,inputMode,identifierFlagged,attachmentPath,attachmentType,attachmentSize,voiceDurationMs,const DeepCollectionEquality().hash(_voicePeaks),withheldReason,status,sentAt,deliveredAt,localAttachmentPath,lastUpdatedAt,synced]);

@override
String toString() {
  return 'MessageModel(uid: $uid, conversationUid: $conversationUid, senderUid: $senderUid, kind: $kind, text: $text, transcriptStatus: $transcriptStatus, transcriptShared: $transcriptShared, transcriptLanguage: $transcriptLanguage, inputMode: $inputMode, identifierFlagged: $identifierFlagged, attachmentPath: $attachmentPath, attachmentType: $attachmentType, attachmentSize: $attachmentSize, voiceDurationMs: $voiceDurationMs, voicePeaks: $voicePeaks, withheldReason: $withheldReason, status: $status, sentAt: $sentAt, deliveredAt: $deliveredAt, localAttachmentPath: $localAttachmentPath, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class _$MessageModelCopyWith<$Res> implements $MessageModelCopyWith<$Res> {
  factory _$MessageModelCopyWith(_MessageModel value, $Res Function(_MessageModel) _then) = __$MessageModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'conversationUid') String conversationUid,@JsonKey(name: 'senderUid') String senderUid,@JsonKey(name: 'kind') String kind,@JsonKey(name: 'text') String text,@JsonKey(name: 'transcriptStatus') String transcriptStatus,@JsonKey(name: 'transcriptShared') bool transcriptShared,@JsonKey(name: 'transcriptLanguage') String transcriptLanguage,@JsonKey(name: 'inputMode') String inputMode,@JsonKey(name: 'identifierFlagged') bool identifierFlagged,@JsonKey(name: 'attachmentPath') String attachmentPath,@JsonKey(name: 'attachmentType') String attachmentType,@JsonKey(name: 'attachmentSize') int attachmentSize,@JsonKey(name: 'voiceDurationMs') int voiceDurationMs,@JsonKey(name: 'voicePeaks') List<int> voicePeaks,@JsonKey(name: 'withheldReason') String withheldReason,@JsonKey(name: 'status') String status,@JsonKey(name: 'sentAt') String sentAt,@JsonKey(name: 'deliveredAt') String deliveredAt,@JsonKey(includeFromJson: false, includeToJson: false) String localAttachmentPath,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class __$MessageModelCopyWithImpl<$Res>
    implements _$MessageModelCopyWith<$Res> {
  __$MessageModelCopyWithImpl(this._self, this._then);

  final _MessageModel _self;
  final $Res Function(_MessageModel) _then;

/// Create a copy of MessageModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? conversationUid = null,Object? senderUid = null,Object? kind = null,Object? text = null,Object? transcriptStatus = null,Object? transcriptShared = null,Object? transcriptLanguage = null,Object? inputMode = null,Object? identifierFlagged = null,Object? attachmentPath = null,Object? attachmentType = null,Object? attachmentSize = null,Object? voiceDurationMs = null,Object? voicePeaks = null,Object? withheldReason = null,Object? status = null,Object? sentAt = null,Object? deliveredAt = null,Object? localAttachmentPath = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_MessageModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,conversationUid: null == conversationUid ? _self.conversationUid : conversationUid // ignore: cast_nullable_to_non_nullable
as String,senderUid: null == senderUid ? _self.senderUid : senderUid // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,transcriptStatus: null == transcriptStatus ? _self.transcriptStatus : transcriptStatus // ignore: cast_nullable_to_non_nullable
as String,transcriptShared: null == transcriptShared ? _self.transcriptShared : transcriptShared // ignore: cast_nullable_to_non_nullable
as bool,transcriptLanguage: null == transcriptLanguage ? _self.transcriptLanguage : transcriptLanguage // ignore: cast_nullable_to_non_nullable
as String,inputMode: null == inputMode ? _self.inputMode : inputMode // ignore: cast_nullable_to_non_nullable
as String,identifierFlagged: null == identifierFlagged ? _self.identifierFlagged : identifierFlagged // ignore: cast_nullable_to_non_nullable
as bool,attachmentPath: null == attachmentPath ? _self.attachmentPath : attachmentPath // ignore: cast_nullable_to_non_nullable
as String,attachmentType: null == attachmentType ? _self.attachmentType : attachmentType // ignore: cast_nullable_to_non_nullable
as String,attachmentSize: null == attachmentSize ? _self.attachmentSize : attachmentSize // ignore: cast_nullable_to_non_nullable
as int,voiceDurationMs: null == voiceDurationMs ? _self.voiceDurationMs : voiceDurationMs // ignore: cast_nullable_to_non_nullable
as int,voicePeaks: null == voicePeaks ? _self._voicePeaks : voicePeaks // ignore: cast_nullable_to_non_nullable
as List<int>,withheldReason: null == withheldReason ? _self.withheldReason : withheldReason // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as String,deliveredAt: null == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as String,localAttachmentPath: null == localAttachmentPath ? _self.localAttachmentPath : localAttachmentPath // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
