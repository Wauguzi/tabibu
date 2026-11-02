// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alert_clinician_brief_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AlertClinicianBriefModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'alertUid') String get alertUid;@JsonKey(name: 'countyId') int get countyId;@JsonKey(name: 'clinicianText') Map<String, AlertTextModel> get clinicianText;@JsonKey(name: 'clinicianGuidance') List<GuidanceBulletModel> get clinicianGuidance;@JsonKey(name: 'sources') List<GuidanceSourceModel> get sources;@JsonKey(name: 'confirmedCount') int get confirmedCount;@JsonKey(name: 'weekStart') String get weekStart;@JsonKey(name: 'rule') String get rule;@JsonKey(name: 'categoryVerified') bool get categoryVerified;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;@JsonKey(includeFromJson: false, includeToJson: false) bool get synced;
/// Create a copy of AlertClinicianBriefModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlertClinicianBriefModelCopyWith<AlertClinicianBriefModel> get copyWith => _$AlertClinicianBriefModelCopyWithImpl<AlertClinicianBriefModel>(this as AlertClinicianBriefModel, _$identity);

  /// Serializes this AlertClinicianBriefModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlertClinicianBriefModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.alertUid, alertUid) || other.alertUid == alertUid)&&(identical(other.countyId, countyId) || other.countyId == countyId)&&const DeepCollectionEquality().equals(other.clinicianText, clinicianText)&&const DeepCollectionEquality().equals(other.clinicianGuidance, clinicianGuidance)&&const DeepCollectionEquality().equals(other.sources, sources)&&(identical(other.confirmedCount, confirmedCount) || other.confirmedCount == confirmedCount)&&(identical(other.weekStart, weekStart) || other.weekStart == weekStart)&&(identical(other.rule, rule) || other.rule == rule)&&(identical(other.categoryVerified, categoryVerified) || other.categoryVerified == categoryVerified)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,alertUid,countyId,const DeepCollectionEquality().hash(clinicianText),const DeepCollectionEquality().hash(clinicianGuidance),const DeepCollectionEquality().hash(sources),confirmedCount,weekStart,rule,categoryVerified,lastUpdatedAt,synced);

@override
String toString() {
  return 'AlertClinicianBriefModel(uid: $uid, alertUid: $alertUid, countyId: $countyId, clinicianText: $clinicianText, clinicianGuidance: $clinicianGuidance, sources: $sources, confirmedCount: $confirmedCount, weekStart: $weekStart, rule: $rule, categoryVerified: $categoryVerified, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class $AlertClinicianBriefModelCopyWith<$Res>  {
  factory $AlertClinicianBriefModelCopyWith(AlertClinicianBriefModel value, $Res Function(AlertClinicianBriefModel) _then) = _$AlertClinicianBriefModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'alertUid') String alertUid,@JsonKey(name: 'countyId') int countyId,@JsonKey(name: 'clinicianText') Map<String, AlertTextModel> clinicianText,@JsonKey(name: 'clinicianGuidance') List<GuidanceBulletModel> clinicianGuidance,@JsonKey(name: 'sources') List<GuidanceSourceModel> sources,@JsonKey(name: 'confirmedCount') int confirmedCount,@JsonKey(name: 'weekStart') String weekStart,@JsonKey(name: 'rule') String rule,@JsonKey(name: 'categoryVerified') bool categoryVerified,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class _$AlertClinicianBriefModelCopyWithImpl<$Res>
    implements $AlertClinicianBriefModelCopyWith<$Res> {
  _$AlertClinicianBriefModelCopyWithImpl(this._self, this._then);

  final AlertClinicianBriefModel _self;
  final $Res Function(AlertClinicianBriefModel) _then;

/// Create a copy of AlertClinicianBriefModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? alertUid = null,Object? countyId = null,Object? clinicianText = null,Object? clinicianGuidance = null,Object? sources = null,Object? confirmedCount = null,Object? weekStart = null,Object? rule = null,Object? categoryVerified = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,alertUid: null == alertUid ? _self.alertUid : alertUid // ignore: cast_nullable_to_non_nullable
as String,countyId: null == countyId ? _self.countyId : countyId // ignore: cast_nullable_to_non_nullable
as int,clinicianText: null == clinicianText ? _self.clinicianText : clinicianText // ignore: cast_nullable_to_non_nullable
as Map<String, AlertTextModel>,clinicianGuidance: null == clinicianGuidance ? _self.clinicianGuidance : clinicianGuidance // ignore: cast_nullable_to_non_nullable
as List<GuidanceBulletModel>,sources: null == sources ? _self.sources : sources // ignore: cast_nullable_to_non_nullable
as List<GuidanceSourceModel>,confirmedCount: null == confirmedCount ? _self.confirmedCount : confirmedCount // ignore: cast_nullable_to_non_nullable
as int,weekStart: null == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as String,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as String,categoryVerified: null == categoryVerified ? _self.categoryVerified : categoryVerified // ignore: cast_nullable_to_non_nullable
as bool,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AlertClinicianBriefModel].
extension AlertClinicianBriefModelPatterns on AlertClinicianBriefModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlertClinicianBriefModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlertClinicianBriefModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlertClinicianBriefModel value)  $default,){
final _that = this;
switch (_that) {
case _AlertClinicianBriefModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlertClinicianBriefModel value)?  $default,){
final _that = this;
switch (_that) {
case _AlertClinicianBriefModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'alertUid')  String alertUid, @JsonKey(name: 'countyId')  int countyId, @JsonKey(name: 'clinicianText')  Map<String, AlertTextModel> clinicianText, @JsonKey(name: 'clinicianGuidance')  List<GuidanceBulletModel> clinicianGuidance, @JsonKey(name: 'sources')  List<GuidanceSourceModel> sources, @JsonKey(name: 'confirmedCount')  int confirmedCount, @JsonKey(name: 'weekStart')  String weekStart, @JsonKey(name: 'rule')  String rule, @JsonKey(name: 'categoryVerified')  bool categoryVerified, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlertClinicianBriefModel() when $default != null:
return $default(_that.uid,_that.alertUid,_that.countyId,_that.clinicianText,_that.clinicianGuidance,_that.sources,_that.confirmedCount,_that.weekStart,_that.rule,_that.categoryVerified,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'alertUid')  String alertUid, @JsonKey(name: 'countyId')  int countyId, @JsonKey(name: 'clinicianText')  Map<String, AlertTextModel> clinicianText, @JsonKey(name: 'clinicianGuidance')  List<GuidanceBulletModel> clinicianGuidance, @JsonKey(name: 'sources')  List<GuidanceSourceModel> sources, @JsonKey(name: 'confirmedCount')  int confirmedCount, @JsonKey(name: 'weekStart')  String weekStart, @JsonKey(name: 'rule')  String rule, @JsonKey(name: 'categoryVerified')  bool categoryVerified, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)  $default,) {final _that = this;
switch (_that) {
case _AlertClinicianBriefModel():
return $default(_that.uid,_that.alertUid,_that.countyId,_that.clinicianText,_that.clinicianGuidance,_that.sources,_that.confirmedCount,_that.weekStart,_that.rule,_that.categoryVerified,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'alertUid')  String alertUid, @JsonKey(name: 'countyId')  int countyId, @JsonKey(name: 'clinicianText')  Map<String, AlertTextModel> clinicianText, @JsonKey(name: 'clinicianGuidance')  List<GuidanceBulletModel> clinicianGuidance, @JsonKey(name: 'sources')  List<GuidanceSourceModel> sources, @JsonKey(name: 'confirmedCount')  int confirmedCount, @JsonKey(name: 'weekStart')  String weekStart, @JsonKey(name: 'rule')  String rule, @JsonKey(name: 'categoryVerified')  bool categoryVerified, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,) {final _that = this;
switch (_that) {
case _AlertClinicianBriefModel() when $default != null:
return $default(_that.uid,_that.alertUid,_that.countyId,_that.clinicianText,_that.clinicianGuidance,_that.sources,_that.confirmedCount,_that.weekStart,_that.rule,_that.categoryVerified,_that.lastUpdatedAt,_that.synced);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _AlertClinicianBriefModel extends AlertClinicianBriefModel {
  const _AlertClinicianBriefModel({@JsonKey(name: 'uid') this.uid = 'brief', @JsonKey(name: 'alertUid') this.alertUid = '', @JsonKey(name: 'countyId') this.countyId = 0, @JsonKey(name: 'clinicianText') final  Map<String, AlertTextModel> clinicianText = const <String, AlertTextModel>{}, @JsonKey(name: 'clinicianGuidance') final  List<GuidanceBulletModel> clinicianGuidance = const <GuidanceBulletModel>[], @JsonKey(name: 'sources') final  List<GuidanceSourceModel> sources = const <GuidanceSourceModel>[], @JsonKey(name: 'confirmedCount') this.confirmedCount = 0, @JsonKey(name: 'weekStart') this.weekStart = '', @JsonKey(name: 'rule') this.rule = 'Manual', @JsonKey(name: 'categoryVerified') this.categoryVerified = false, @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = '', @JsonKey(includeFromJson: false, includeToJson: false) this.synced = true}): _clinicianText = clinicianText,_clinicianGuidance = clinicianGuidance,_sources = sources,super._();
  factory _AlertClinicianBriefModel.fromJson(Map<String, dynamic> json) => _$AlertClinicianBriefModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'alertUid') final  String alertUid;
@override@JsonKey(name: 'countyId') final  int countyId;
 final  Map<String, AlertTextModel> _clinicianText;
@override@JsonKey(name: 'clinicianText') Map<String, AlertTextModel> get clinicianText {
  if (_clinicianText is EqualUnmodifiableMapView) return _clinicianText;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_clinicianText);
}

 final  List<GuidanceBulletModel> _clinicianGuidance;
@override@JsonKey(name: 'clinicianGuidance') List<GuidanceBulletModel> get clinicianGuidance {
  if (_clinicianGuidance is EqualUnmodifiableListView) return _clinicianGuidance;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_clinicianGuidance);
}

 final  List<GuidanceSourceModel> _sources;
@override@JsonKey(name: 'sources') List<GuidanceSourceModel> get sources {
  if (_sources is EqualUnmodifiableListView) return _sources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sources);
}

@override@JsonKey(name: 'confirmedCount') final  int confirmedCount;
@override@JsonKey(name: 'weekStart') final  String weekStart;
@override@JsonKey(name: 'rule') final  String rule;
@override@JsonKey(name: 'categoryVerified') final  bool categoryVerified;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool synced;

/// Create a copy of AlertClinicianBriefModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlertClinicianBriefModelCopyWith<_AlertClinicianBriefModel> get copyWith => __$AlertClinicianBriefModelCopyWithImpl<_AlertClinicianBriefModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AlertClinicianBriefModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlertClinicianBriefModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.alertUid, alertUid) || other.alertUid == alertUid)&&(identical(other.countyId, countyId) || other.countyId == countyId)&&const DeepCollectionEquality().equals(other._clinicianText, _clinicianText)&&const DeepCollectionEquality().equals(other._clinicianGuidance, _clinicianGuidance)&&const DeepCollectionEquality().equals(other._sources, _sources)&&(identical(other.confirmedCount, confirmedCount) || other.confirmedCount == confirmedCount)&&(identical(other.weekStart, weekStart) || other.weekStart == weekStart)&&(identical(other.rule, rule) || other.rule == rule)&&(identical(other.categoryVerified, categoryVerified) || other.categoryVerified == categoryVerified)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,alertUid,countyId,const DeepCollectionEquality().hash(_clinicianText),const DeepCollectionEquality().hash(_clinicianGuidance),const DeepCollectionEquality().hash(_sources),confirmedCount,weekStart,rule,categoryVerified,lastUpdatedAt,synced);

@override
String toString() {
  return 'AlertClinicianBriefModel(uid: $uid, alertUid: $alertUid, countyId: $countyId, clinicianText: $clinicianText, clinicianGuidance: $clinicianGuidance, sources: $sources, confirmedCount: $confirmedCount, weekStart: $weekStart, rule: $rule, categoryVerified: $categoryVerified, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class _$AlertClinicianBriefModelCopyWith<$Res> implements $AlertClinicianBriefModelCopyWith<$Res> {
  factory _$AlertClinicianBriefModelCopyWith(_AlertClinicianBriefModel value, $Res Function(_AlertClinicianBriefModel) _then) = __$AlertClinicianBriefModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'alertUid') String alertUid,@JsonKey(name: 'countyId') int countyId,@JsonKey(name: 'clinicianText') Map<String, AlertTextModel> clinicianText,@JsonKey(name: 'clinicianGuidance') List<GuidanceBulletModel> clinicianGuidance,@JsonKey(name: 'sources') List<GuidanceSourceModel> sources,@JsonKey(name: 'confirmedCount') int confirmedCount,@JsonKey(name: 'weekStart') String weekStart,@JsonKey(name: 'rule') String rule,@JsonKey(name: 'categoryVerified') bool categoryVerified,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class __$AlertClinicianBriefModelCopyWithImpl<$Res>
    implements _$AlertClinicianBriefModelCopyWith<$Res> {
  __$AlertClinicianBriefModelCopyWithImpl(this._self, this._then);

  final _AlertClinicianBriefModel _self;
  final $Res Function(_AlertClinicianBriefModel) _then;

/// Create a copy of AlertClinicianBriefModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? alertUid = null,Object? countyId = null,Object? clinicianText = null,Object? clinicianGuidance = null,Object? sources = null,Object? confirmedCount = null,Object? weekStart = null,Object? rule = null,Object? categoryVerified = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_AlertClinicianBriefModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,alertUid: null == alertUid ? _self.alertUid : alertUid // ignore: cast_nullable_to_non_nullable
as String,countyId: null == countyId ? _self.countyId : countyId // ignore: cast_nullable_to_non_nullable
as int,clinicianText: null == clinicianText ? _self._clinicianText : clinicianText // ignore: cast_nullable_to_non_nullable
as Map<String, AlertTextModel>,clinicianGuidance: null == clinicianGuidance ? _self._clinicianGuidance : clinicianGuidance // ignore: cast_nullable_to_non_nullable
as List<GuidanceBulletModel>,sources: null == sources ? _self._sources : sources // ignore: cast_nullable_to_non_nullable
as List<GuidanceSourceModel>,confirmedCount: null == confirmedCount ? _self.confirmedCount : confirmedCount // ignore: cast_nullable_to_non_nullable
as int,weekStart: null == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as String,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as String,categoryVerified: null == categoryVerified ? _self.categoryVerified : categoryVerified // ignore: cast_nullable_to_non_nullable
as bool,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
