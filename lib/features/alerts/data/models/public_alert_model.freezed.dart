// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'public_alert_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PublicAlertModel {

@JsonKey(name: 'uid') String get uid;@JsonKey(name: 'diseaseId') String get diseaseId;@JsonKey(name: 'diseaseNameEn') String get diseaseNameEn;@JsonKey(name: 'diseaseNameSw') String get diseaseNameSw;@JsonKey(name: 'countyId') int get countyId;@JsonKey(name: 'countyName') String get countyName;@JsonKey(name: 'clinicianCountyIds') List<int> get clinicianCountyIds;@JsonKey(name: 'epiWeek') String get epiWeek;@JsonKey(name: 'category') String get category;@JsonKey(name: 'patientText') Map<String, AlertTextModel> get patientText;@JsonKey(name: 'patientGuidance') List<GuidanceBulletModel> get patientGuidance;@JsonKey(name: 'sources') List<GuidanceSourceModel> get sources;@JsonKey(name: 'issuedAt') String get issuedAt;@JsonKey(name: 'patientsReleased') bool get patientsReleased;@JsonKey(name: 'patientsReleasedAt') String get patientsReleasedAt;@JsonKey(name: 'synthetic') bool get synthetic;@JsonKey(name: 'createdAt') String get createdAt;@JsonKey(name: 'lastUpdatedAt') String get lastUpdatedAt;@JsonKey(includeFromJson: false, includeToJson: false) bool get synced;
/// Create a copy of PublicAlertModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicAlertModelCopyWith<PublicAlertModel> get copyWith => _$PublicAlertModelCopyWithImpl<PublicAlertModel>(this as PublicAlertModel, _$identity);

  /// Serializes this PublicAlertModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicAlertModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.diseaseId, diseaseId) || other.diseaseId == diseaseId)&&(identical(other.diseaseNameEn, diseaseNameEn) || other.diseaseNameEn == diseaseNameEn)&&(identical(other.diseaseNameSw, diseaseNameSw) || other.diseaseNameSw == diseaseNameSw)&&(identical(other.countyId, countyId) || other.countyId == countyId)&&(identical(other.countyName, countyName) || other.countyName == countyName)&&const DeepCollectionEquality().equals(other.clinicianCountyIds, clinicianCountyIds)&&(identical(other.epiWeek, epiWeek) || other.epiWeek == epiWeek)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.patientText, patientText)&&const DeepCollectionEquality().equals(other.patientGuidance, patientGuidance)&&const DeepCollectionEquality().equals(other.sources, sources)&&(identical(other.issuedAt, issuedAt) || other.issuedAt == issuedAt)&&(identical(other.patientsReleased, patientsReleased) || other.patientsReleased == patientsReleased)&&(identical(other.patientsReleasedAt, patientsReleasedAt) || other.patientsReleasedAt == patientsReleasedAt)&&(identical(other.synthetic, synthetic) || other.synthetic == synthetic)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,diseaseId,diseaseNameEn,diseaseNameSw,countyId,countyName,const DeepCollectionEquality().hash(clinicianCountyIds),epiWeek,category,const DeepCollectionEquality().hash(patientText),const DeepCollectionEquality().hash(patientGuidance),const DeepCollectionEquality().hash(sources),issuedAt,patientsReleased,patientsReleasedAt,synthetic,createdAt,lastUpdatedAt,synced]);

@override
String toString() {
  return 'PublicAlertModel(uid: $uid, diseaseId: $diseaseId, diseaseNameEn: $diseaseNameEn, diseaseNameSw: $diseaseNameSw, countyId: $countyId, countyName: $countyName, clinicianCountyIds: $clinicianCountyIds, epiWeek: $epiWeek, category: $category, patientText: $patientText, patientGuidance: $patientGuidance, sources: $sources, issuedAt: $issuedAt, patientsReleased: $patientsReleased, patientsReleasedAt: $patientsReleasedAt, synthetic: $synthetic, createdAt: $createdAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class $PublicAlertModelCopyWith<$Res>  {
  factory $PublicAlertModelCopyWith(PublicAlertModel value, $Res Function(PublicAlertModel) _then) = _$PublicAlertModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'diseaseId') String diseaseId,@JsonKey(name: 'diseaseNameEn') String diseaseNameEn,@JsonKey(name: 'diseaseNameSw') String diseaseNameSw,@JsonKey(name: 'countyId') int countyId,@JsonKey(name: 'countyName') String countyName,@JsonKey(name: 'clinicianCountyIds') List<int> clinicianCountyIds,@JsonKey(name: 'epiWeek') String epiWeek,@JsonKey(name: 'category') String category,@JsonKey(name: 'patientText') Map<String, AlertTextModel> patientText,@JsonKey(name: 'patientGuidance') List<GuidanceBulletModel> patientGuidance,@JsonKey(name: 'sources') List<GuidanceSourceModel> sources,@JsonKey(name: 'issuedAt') String issuedAt,@JsonKey(name: 'patientsReleased') bool patientsReleased,@JsonKey(name: 'patientsReleasedAt') String patientsReleasedAt,@JsonKey(name: 'synthetic') bool synthetic,@JsonKey(name: 'createdAt') String createdAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class _$PublicAlertModelCopyWithImpl<$Res>
    implements $PublicAlertModelCopyWith<$Res> {
  _$PublicAlertModelCopyWithImpl(this._self, this._then);

  final PublicAlertModel _self;
  final $Res Function(PublicAlertModel) _then;

/// Create a copy of PublicAlertModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? diseaseId = null,Object? diseaseNameEn = null,Object? diseaseNameSw = null,Object? countyId = null,Object? countyName = null,Object? clinicianCountyIds = null,Object? epiWeek = null,Object? category = null,Object? patientText = null,Object? patientGuidance = null,Object? sources = null,Object? issuedAt = null,Object? patientsReleased = null,Object? patientsReleasedAt = null,Object? synthetic = null,Object? createdAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,diseaseId: null == diseaseId ? _self.diseaseId : diseaseId // ignore: cast_nullable_to_non_nullable
as String,diseaseNameEn: null == diseaseNameEn ? _self.diseaseNameEn : diseaseNameEn // ignore: cast_nullable_to_non_nullable
as String,diseaseNameSw: null == diseaseNameSw ? _self.diseaseNameSw : diseaseNameSw // ignore: cast_nullable_to_non_nullable
as String,countyId: null == countyId ? _self.countyId : countyId // ignore: cast_nullable_to_non_nullable
as int,countyName: null == countyName ? _self.countyName : countyName // ignore: cast_nullable_to_non_nullable
as String,clinicianCountyIds: null == clinicianCountyIds ? _self.clinicianCountyIds : clinicianCountyIds // ignore: cast_nullable_to_non_nullable
as List<int>,epiWeek: null == epiWeek ? _self.epiWeek : epiWeek // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,patientText: null == patientText ? _self.patientText : patientText // ignore: cast_nullable_to_non_nullable
as Map<String, AlertTextModel>,patientGuidance: null == patientGuidance ? _self.patientGuidance : patientGuidance // ignore: cast_nullable_to_non_nullable
as List<GuidanceBulletModel>,sources: null == sources ? _self.sources : sources // ignore: cast_nullable_to_non_nullable
as List<GuidanceSourceModel>,issuedAt: null == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as String,patientsReleased: null == patientsReleased ? _self.patientsReleased : patientsReleased // ignore: cast_nullable_to_non_nullable
as bool,patientsReleasedAt: null == patientsReleasedAt ? _self.patientsReleasedAt : patientsReleasedAt // ignore: cast_nullable_to_non_nullable
as String,synthetic: null == synthetic ? _self.synthetic : synthetic // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PublicAlertModel].
extension PublicAlertModelPatterns on PublicAlertModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicAlertModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicAlertModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicAlertModel value)  $default,){
final _that = this;
switch (_that) {
case _PublicAlertModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicAlertModel value)?  $default,){
final _that = this;
switch (_that) {
case _PublicAlertModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'diseaseId')  String diseaseId, @JsonKey(name: 'diseaseNameEn')  String diseaseNameEn, @JsonKey(name: 'diseaseNameSw')  String diseaseNameSw, @JsonKey(name: 'countyId')  int countyId, @JsonKey(name: 'countyName')  String countyName, @JsonKey(name: 'clinicianCountyIds')  List<int> clinicianCountyIds, @JsonKey(name: 'epiWeek')  String epiWeek, @JsonKey(name: 'category')  String category, @JsonKey(name: 'patientText')  Map<String, AlertTextModel> patientText, @JsonKey(name: 'patientGuidance')  List<GuidanceBulletModel> patientGuidance, @JsonKey(name: 'sources')  List<GuidanceSourceModel> sources, @JsonKey(name: 'issuedAt')  String issuedAt, @JsonKey(name: 'patientsReleased')  bool patientsReleased, @JsonKey(name: 'patientsReleasedAt')  String patientsReleasedAt, @JsonKey(name: 'synthetic')  bool synthetic, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicAlertModel() when $default != null:
return $default(_that.uid,_that.diseaseId,_that.diseaseNameEn,_that.diseaseNameSw,_that.countyId,_that.countyName,_that.clinicianCountyIds,_that.epiWeek,_that.category,_that.patientText,_that.patientGuidance,_that.sources,_that.issuedAt,_that.patientsReleased,_that.patientsReleasedAt,_that.synthetic,_that.createdAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'diseaseId')  String diseaseId, @JsonKey(name: 'diseaseNameEn')  String diseaseNameEn, @JsonKey(name: 'diseaseNameSw')  String diseaseNameSw, @JsonKey(name: 'countyId')  int countyId, @JsonKey(name: 'countyName')  String countyName, @JsonKey(name: 'clinicianCountyIds')  List<int> clinicianCountyIds, @JsonKey(name: 'epiWeek')  String epiWeek, @JsonKey(name: 'category')  String category, @JsonKey(name: 'patientText')  Map<String, AlertTextModel> patientText, @JsonKey(name: 'patientGuidance')  List<GuidanceBulletModel> patientGuidance, @JsonKey(name: 'sources')  List<GuidanceSourceModel> sources, @JsonKey(name: 'issuedAt')  String issuedAt, @JsonKey(name: 'patientsReleased')  bool patientsReleased, @JsonKey(name: 'patientsReleasedAt')  String patientsReleasedAt, @JsonKey(name: 'synthetic')  bool synthetic, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)  $default,) {final _that = this;
switch (_that) {
case _PublicAlertModel():
return $default(_that.uid,_that.diseaseId,_that.diseaseNameEn,_that.diseaseNameSw,_that.countyId,_that.countyName,_that.clinicianCountyIds,_that.epiWeek,_that.category,_that.patientText,_that.patientGuidance,_that.sources,_that.issuedAt,_that.patientsReleased,_that.patientsReleasedAt,_that.synthetic,_that.createdAt,_that.lastUpdatedAt,_that.synced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String uid, @JsonKey(name: 'diseaseId')  String diseaseId, @JsonKey(name: 'diseaseNameEn')  String diseaseNameEn, @JsonKey(name: 'diseaseNameSw')  String diseaseNameSw, @JsonKey(name: 'countyId')  int countyId, @JsonKey(name: 'countyName')  String countyName, @JsonKey(name: 'clinicianCountyIds')  List<int> clinicianCountyIds, @JsonKey(name: 'epiWeek')  String epiWeek, @JsonKey(name: 'category')  String category, @JsonKey(name: 'patientText')  Map<String, AlertTextModel> patientText, @JsonKey(name: 'patientGuidance')  List<GuidanceBulletModel> patientGuidance, @JsonKey(name: 'sources')  List<GuidanceSourceModel> sources, @JsonKey(name: 'issuedAt')  String issuedAt, @JsonKey(name: 'patientsReleased')  bool patientsReleased, @JsonKey(name: 'patientsReleasedAt')  String patientsReleasedAt, @JsonKey(name: 'synthetic')  bool synthetic, @JsonKey(name: 'createdAt')  String createdAt, @JsonKey(name: 'lastUpdatedAt')  String lastUpdatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  bool synced)?  $default,) {final _that = this;
switch (_that) {
case _PublicAlertModel() when $default != null:
return $default(_that.uid,_that.diseaseId,_that.diseaseNameEn,_that.diseaseNameSw,_that.countyId,_that.countyName,_that.clinicianCountyIds,_that.epiWeek,_that.category,_that.patientText,_that.patientGuidance,_that.sources,_that.issuedAt,_that.patientsReleased,_that.patientsReleasedAt,_that.synthetic,_that.createdAt,_that.lastUpdatedAt,_that.synced);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _PublicAlertModel extends PublicAlertModel {
  const _PublicAlertModel({@JsonKey(name: 'uid') this.uid = '', @JsonKey(name: 'diseaseId') this.diseaseId = '', @JsonKey(name: 'diseaseNameEn') this.diseaseNameEn = '', @JsonKey(name: 'diseaseNameSw') this.diseaseNameSw = '', @JsonKey(name: 'countyId') this.countyId = 0, @JsonKey(name: 'countyName') this.countyName = '', @JsonKey(name: 'clinicianCountyIds') final  List<int> clinicianCountyIds = const <int>[], @JsonKey(name: 'epiWeek') this.epiWeek = '', @JsonKey(name: 'category') this.category = 'Immediate', @JsonKey(name: 'patientText') final  Map<String, AlertTextModel> patientText = const <String, AlertTextModel>{}, @JsonKey(name: 'patientGuidance') final  List<GuidanceBulletModel> patientGuidance = const <GuidanceBulletModel>[], @JsonKey(name: 'sources') final  List<GuidanceSourceModel> sources = const <GuidanceSourceModel>[], @JsonKey(name: 'issuedAt') this.issuedAt = '', @JsonKey(name: 'patientsReleased') this.patientsReleased = false, @JsonKey(name: 'patientsReleasedAt') this.patientsReleasedAt = '', @JsonKey(name: 'synthetic') this.synthetic = false, @JsonKey(name: 'createdAt') this.createdAt = '', @JsonKey(name: 'lastUpdatedAt') this.lastUpdatedAt = '', @JsonKey(includeFromJson: false, includeToJson: false) this.synced = true}): _clinicianCountyIds = clinicianCountyIds,_patientText = patientText,_patientGuidance = patientGuidance,_sources = sources,super._();
  factory _PublicAlertModel.fromJson(Map<String, dynamic> json) => _$PublicAlertModelFromJson(json);

@override@JsonKey(name: 'uid') final  String uid;
@override@JsonKey(name: 'diseaseId') final  String diseaseId;
@override@JsonKey(name: 'diseaseNameEn') final  String diseaseNameEn;
@override@JsonKey(name: 'diseaseNameSw') final  String diseaseNameSw;
@override@JsonKey(name: 'countyId') final  int countyId;
@override@JsonKey(name: 'countyName') final  String countyName;
 final  List<int> _clinicianCountyIds;
@override@JsonKey(name: 'clinicianCountyIds') List<int> get clinicianCountyIds {
  if (_clinicianCountyIds is EqualUnmodifiableListView) return _clinicianCountyIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_clinicianCountyIds);
}

@override@JsonKey(name: 'epiWeek') final  String epiWeek;
@override@JsonKey(name: 'category') final  String category;
 final  Map<String, AlertTextModel> _patientText;
@override@JsonKey(name: 'patientText') Map<String, AlertTextModel> get patientText {
  if (_patientText is EqualUnmodifiableMapView) return _patientText;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_patientText);
}

 final  List<GuidanceBulletModel> _patientGuidance;
@override@JsonKey(name: 'patientGuidance') List<GuidanceBulletModel> get patientGuidance {
  if (_patientGuidance is EqualUnmodifiableListView) return _patientGuidance;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_patientGuidance);
}

 final  List<GuidanceSourceModel> _sources;
@override@JsonKey(name: 'sources') List<GuidanceSourceModel> get sources {
  if (_sources is EqualUnmodifiableListView) return _sources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sources);
}

@override@JsonKey(name: 'issuedAt') final  String issuedAt;
@override@JsonKey(name: 'patientsReleased') final  bool patientsReleased;
@override@JsonKey(name: 'patientsReleasedAt') final  String patientsReleasedAt;
@override@JsonKey(name: 'synthetic') final  bool synthetic;
@override@JsonKey(name: 'createdAt') final  String createdAt;
@override@JsonKey(name: 'lastUpdatedAt') final  String lastUpdatedAt;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool synced;

/// Create a copy of PublicAlertModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicAlertModelCopyWith<_PublicAlertModel> get copyWith => __$PublicAlertModelCopyWithImpl<_PublicAlertModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublicAlertModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicAlertModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.diseaseId, diseaseId) || other.diseaseId == diseaseId)&&(identical(other.diseaseNameEn, diseaseNameEn) || other.diseaseNameEn == diseaseNameEn)&&(identical(other.diseaseNameSw, diseaseNameSw) || other.diseaseNameSw == diseaseNameSw)&&(identical(other.countyId, countyId) || other.countyId == countyId)&&(identical(other.countyName, countyName) || other.countyName == countyName)&&const DeepCollectionEquality().equals(other._clinicianCountyIds, _clinicianCountyIds)&&(identical(other.epiWeek, epiWeek) || other.epiWeek == epiWeek)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._patientText, _patientText)&&const DeepCollectionEquality().equals(other._patientGuidance, _patientGuidance)&&const DeepCollectionEquality().equals(other._sources, _sources)&&(identical(other.issuedAt, issuedAt) || other.issuedAt == issuedAt)&&(identical(other.patientsReleased, patientsReleased) || other.patientsReleased == patientsReleased)&&(identical(other.patientsReleasedAt, patientsReleasedAt) || other.patientsReleasedAt == patientsReleasedAt)&&(identical(other.synthetic, synthetic) || other.synthetic == synthetic)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.synced, synced) || other.synced == synced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,diseaseId,diseaseNameEn,diseaseNameSw,countyId,countyName,const DeepCollectionEquality().hash(_clinicianCountyIds),epiWeek,category,const DeepCollectionEquality().hash(_patientText),const DeepCollectionEquality().hash(_patientGuidance),const DeepCollectionEquality().hash(_sources),issuedAt,patientsReleased,patientsReleasedAt,synthetic,createdAt,lastUpdatedAt,synced]);

@override
String toString() {
  return 'PublicAlertModel(uid: $uid, diseaseId: $diseaseId, diseaseNameEn: $diseaseNameEn, diseaseNameSw: $diseaseNameSw, countyId: $countyId, countyName: $countyName, clinicianCountyIds: $clinicianCountyIds, epiWeek: $epiWeek, category: $category, patientText: $patientText, patientGuidance: $patientGuidance, sources: $sources, issuedAt: $issuedAt, patientsReleased: $patientsReleased, patientsReleasedAt: $patientsReleasedAt, synthetic: $synthetic, createdAt: $createdAt, lastUpdatedAt: $lastUpdatedAt, synced: $synced)';
}


}

/// @nodoc
abstract mixin class _$PublicAlertModelCopyWith<$Res> implements $PublicAlertModelCopyWith<$Res> {
  factory _$PublicAlertModelCopyWith(_PublicAlertModel value, $Res Function(_PublicAlertModel) _then) = __$PublicAlertModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String uid,@JsonKey(name: 'diseaseId') String diseaseId,@JsonKey(name: 'diseaseNameEn') String diseaseNameEn,@JsonKey(name: 'diseaseNameSw') String diseaseNameSw,@JsonKey(name: 'countyId') int countyId,@JsonKey(name: 'countyName') String countyName,@JsonKey(name: 'clinicianCountyIds') List<int> clinicianCountyIds,@JsonKey(name: 'epiWeek') String epiWeek,@JsonKey(name: 'category') String category,@JsonKey(name: 'patientText') Map<String, AlertTextModel> patientText,@JsonKey(name: 'patientGuidance') List<GuidanceBulletModel> patientGuidance,@JsonKey(name: 'sources') List<GuidanceSourceModel> sources,@JsonKey(name: 'issuedAt') String issuedAt,@JsonKey(name: 'patientsReleased') bool patientsReleased,@JsonKey(name: 'patientsReleasedAt') String patientsReleasedAt,@JsonKey(name: 'synthetic') bool synthetic,@JsonKey(name: 'createdAt') String createdAt,@JsonKey(name: 'lastUpdatedAt') String lastUpdatedAt,@JsonKey(includeFromJson: false, includeToJson: false) bool synced
});




}
/// @nodoc
class __$PublicAlertModelCopyWithImpl<$Res>
    implements _$PublicAlertModelCopyWith<$Res> {
  __$PublicAlertModelCopyWithImpl(this._self, this._then);

  final _PublicAlertModel _self;
  final $Res Function(_PublicAlertModel) _then;

/// Create a copy of PublicAlertModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? diseaseId = null,Object? diseaseNameEn = null,Object? diseaseNameSw = null,Object? countyId = null,Object? countyName = null,Object? clinicianCountyIds = null,Object? epiWeek = null,Object? category = null,Object? patientText = null,Object? patientGuidance = null,Object? sources = null,Object? issuedAt = null,Object? patientsReleased = null,Object? patientsReleasedAt = null,Object? synthetic = null,Object? createdAt = null,Object? lastUpdatedAt = null,Object? synced = null,}) {
  return _then(_PublicAlertModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,diseaseId: null == diseaseId ? _self.diseaseId : diseaseId // ignore: cast_nullable_to_non_nullable
as String,diseaseNameEn: null == diseaseNameEn ? _self.diseaseNameEn : diseaseNameEn // ignore: cast_nullable_to_non_nullable
as String,diseaseNameSw: null == diseaseNameSw ? _self.diseaseNameSw : diseaseNameSw // ignore: cast_nullable_to_non_nullable
as String,countyId: null == countyId ? _self.countyId : countyId // ignore: cast_nullable_to_non_nullable
as int,countyName: null == countyName ? _self.countyName : countyName // ignore: cast_nullable_to_non_nullable
as String,clinicianCountyIds: null == clinicianCountyIds ? _self._clinicianCountyIds : clinicianCountyIds // ignore: cast_nullable_to_non_nullable
as List<int>,epiWeek: null == epiWeek ? _self.epiWeek : epiWeek // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,patientText: null == patientText ? _self._patientText : patientText // ignore: cast_nullable_to_non_nullable
as Map<String, AlertTextModel>,patientGuidance: null == patientGuidance ? _self._patientGuidance : patientGuidance // ignore: cast_nullable_to_non_nullable
as List<GuidanceBulletModel>,sources: null == sources ? _self._sources : sources // ignore: cast_nullable_to_non_nullable
as List<GuidanceSourceModel>,issuedAt: null == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as String,patientsReleased: null == patientsReleased ? _self.patientsReleased : patientsReleased // ignore: cast_nullable_to_non_nullable
as bool,patientsReleasedAt: null == patientsReleasedAt ? _self.patientsReleasedAt : patientsReleasedAt // ignore: cast_nullable_to_non_nullable
as String,synthetic: null == synthetic ? _self.synthetic : synthetic // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as String,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
