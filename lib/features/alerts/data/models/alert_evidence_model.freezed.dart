// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alert_evidence_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AlertEvidenceModel {

@JsonKey(name: 'confirmedCount') int get confirmedCount;@JsonKey(name: 'baselineMean') double get baselineMean;@JsonKey(name: 'baselineSd') double get baselineSd;@JsonKey(name: 'threshold') double get threshold;@JsonKey(name: 'floor') int get floor;@JsonKey(name: 'windowWeeks') int get windowWeeks;@JsonKey(name: 'multiplier') double get multiplier;@JsonKey(name: 'ageBandCounts') Map<String, int> get ageBandCounts;@JsonKey(name: 'manualRequests') int get manualRequests;@JsonKey(name: 'categoryVerified') bool get categoryVerified;@JsonKey(name: 'mappingVerified') bool get mappingVerified;@JsonKey(name: 'categorySourceId') String get categorySourceId;@JsonKey(name: 'weekStart') String get weekStart;
/// Create a copy of AlertEvidenceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlertEvidenceModelCopyWith<AlertEvidenceModel> get copyWith => _$AlertEvidenceModelCopyWithImpl<AlertEvidenceModel>(this as AlertEvidenceModel, _$identity);

  /// Serializes this AlertEvidenceModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlertEvidenceModel&&(identical(other.confirmedCount, confirmedCount) || other.confirmedCount == confirmedCount)&&(identical(other.baselineMean, baselineMean) || other.baselineMean == baselineMean)&&(identical(other.baselineSd, baselineSd) || other.baselineSd == baselineSd)&&(identical(other.threshold, threshold) || other.threshold == threshold)&&(identical(other.floor, floor) || other.floor == floor)&&(identical(other.windowWeeks, windowWeeks) || other.windowWeeks == windowWeeks)&&(identical(other.multiplier, multiplier) || other.multiplier == multiplier)&&const DeepCollectionEquality().equals(other.ageBandCounts, ageBandCounts)&&(identical(other.manualRequests, manualRequests) || other.manualRequests == manualRequests)&&(identical(other.categoryVerified, categoryVerified) || other.categoryVerified == categoryVerified)&&(identical(other.mappingVerified, mappingVerified) || other.mappingVerified == mappingVerified)&&(identical(other.categorySourceId, categorySourceId) || other.categorySourceId == categorySourceId)&&(identical(other.weekStart, weekStart) || other.weekStart == weekStart));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,confirmedCount,baselineMean,baselineSd,threshold,floor,windowWeeks,multiplier,const DeepCollectionEquality().hash(ageBandCounts),manualRequests,categoryVerified,mappingVerified,categorySourceId,weekStart);

@override
String toString() {
  return 'AlertEvidenceModel(confirmedCount: $confirmedCount, baselineMean: $baselineMean, baselineSd: $baselineSd, threshold: $threshold, floor: $floor, windowWeeks: $windowWeeks, multiplier: $multiplier, ageBandCounts: $ageBandCounts, manualRequests: $manualRequests, categoryVerified: $categoryVerified, mappingVerified: $mappingVerified, categorySourceId: $categorySourceId, weekStart: $weekStart)';
}


}

/// @nodoc
abstract mixin class $AlertEvidenceModelCopyWith<$Res>  {
  factory $AlertEvidenceModelCopyWith(AlertEvidenceModel value, $Res Function(AlertEvidenceModel) _then) = _$AlertEvidenceModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'confirmedCount') int confirmedCount,@JsonKey(name: 'baselineMean') double baselineMean,@JsonKey(name: 'baselineSd') double baselineSd,@JsonKey(name: 'threshold') double threshold,@JsonKey(name: 'floor') int floor,@JsonKey(name: 'windowWeeks') int windowWeeks,@JsonKey(name: 'multiplier') double multiplier,@JsonKey(name: 'ageBandCounts') Map<String, int> ageBandCounts,@JsonKey(name: 'manualRequests') int manualRequests,@JsonKey(name: 'categoryVerified') bool categoryVerified,@JsonKey(name: 'mappingVerified') bool mappingVerified,@JsonKey(name: 'categorySourceId') String categorySourceId,@JsonKey(name: 'weekStart') String weekStart
});




}
/// @nodoc
class _$AlertEvidenceModelCopyWithImpl<$Res>
    implements $AlertEvidenceModelCopyWith<$Res> {
  _$AlertEvidenceModelCopyWithImpl(this._self, this._then);

  final AlertEvidenceModel _self;
  final $Res Function(AlertEvidenceModel) _then;

/// Create a copy of AlertEvidenceModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? confirmedCount = null,Object? baselineMean = null,Object? baselineSd = null,Object? threshold = null,Object? floor = null,Object? windowWeeks = null,Object? multiplier = null,Object? ageBandCounts = null,Object? manualRequests = null,Object? categoryVerified = null,Object? mappingVerified = null,Object? categorySourceId = null,Object? weekStart = null,}) {
  return _then(_self.copyWith(
confirmedCount: null == confirmedCount ? _self.confirmedCount : confirmedCount // ignore: cast_nullable_to_non_nullable
as int,baselineMean: null == baselineMean ? _self.baselineMean : baselineMean // ignore: cast_nullable_to_non_nullable
as double,baselineSd: null == baselineSd ? _self.baselineSd : baselineSd // ignore: cast_nullable_to_non_nullable
as double,threshold: null == threshold ? _self.threshold : threshold // ignore: cast_nullable_to_non_nullable
as double,floor: null == floor ? _self.floor : floor // ignore: cast_nullable_to_non_nullable
as int,windowWeeks: null == windowWeeks ? _self.windowWeeks : windowWeeks // ignore: cast_nullable_to_non_nullable
as int,multiplier: null == multiplier ? _self.multiplier : multiplier // ignore: cast_nullable_to_non_nullable
as double,ageBandCounts: null == ageBandCounts ? _self.ageBandCounts : ageBandCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,manualRequests: null == manualRequests ? _self.manualRequests : manualRequests // ignore: cast_nullable_to_non_nullable
as int,categoryVerified: null == categoryVerified ? _self.categoryVerified : categoryVerified // ignore: cast_nullable_to_non_nullable
as bool,mappingVerified: null == mappingVerified ? _self.mappingVerified : mappingVerified // ignore: cast_nullable_to_non_nullable
as bool,categorySourceId: null == categorySourceId ? _self.categorySourceId : categorySourceId // ignore: cast_nullable_to_non_nullable
as String,weekStart: null == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AlertEvidenceModel].
extension AlertEvidenceModelPatterns on AlertEvidenceModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlertEvidenceModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlertEvidenceModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlertEvidenceModel value)  $default,){
final _that = this;
switch (_that) {
case _AlertEvidenceModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlertEvidenceModel value)?  $default,){
final _that = this;
switch (_that) {
case _AlertEvidenceModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'confirmedCount')  int confirmedCount, @JsonKey(name: 'baselineMean')  double baselineMean, @JsonKey(name: 'baselineSd')  double baselineSd, @JsonKey(name: 'threshold')  double threshold, @JsonKey(name: 'floor')  int floor, @JsonKey(name: 'windowWeeks')  int windowWeeks, @JsonKey(name: 'multiplier')  double multiplier, @JsonKey(name: 'ageBandCounts')  Map<String, int> ageBandCounts, @JsonKey(name: 'manualRequests')  int manualRequests, @JsonKey(name: 'categoryVerified')  bool categoryVerified, @JsonKey(name: 'mappingVerified')  bool mappingVerified, @JsonKey(name: 'categorySourceId')  String categorySourceId, @JsonKey(name: 'weekStart')  String weekStart)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlertEvidenceModel() when $default != null:
return $default(_that.confirmedCount,_that.baselineMean,_that.baselineSd,_that.threshold,_that.floor,_that.windowWeeks,_that.multiplier,_that.ageBandCounts,_that.manualRequests,_that.categoryVerified,_that.mappingVerified,_that.categorySourceId,_that.weekStart);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'confirmedCount')  int confirmedCount, @JsonKey(name: 'baselineMean')  double baselineMean, @JsonKey(name: 'baselineSd')  double baselineSd, @JsonKey(name: 'threshold')  double threshold, @JsonKey(name: 'floor')  int floor, @JsonKey(name: 'windowWeeks')  int windowWeeks, @JsonKey(name: 'multiplier')  double multiplier, @JsonKey(name: 'ageBandCounts')  Map<String, int> ageBandCounts, @JsonKey(name: 'manualRequests')  int manualRequests, @JsonKey(name: 'categoryVerified')  bool categoryVerified, @JsonKey(name: 'mappingVerified')  bool mappingVerified, @JsonKey(name: 'categorySourceId')  String categorySourceId, @JsonKey(name: 'weekStart')  String weekStart)  $default,) {final _that = this;
switch (_that) {
case _AlertEvidenceModel():
return $default(_that.confirmedCount,_that.baselineMean,_that.baselineSd,_that.threshold,_that.floor,_that.windowWeeks,_that.multiplier,_that.ageBandCounts,_that.manualRequests,_that.categoryVerified,_that.mappingVerified,_that.categorySourceId,_that.weekStart);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'confirmedCount')  int confirmedCount, @JsonKey(name: 'baselineMean')  double baselineMean, @JsonKey(name: 'baselineSd')  double baselineSd, @JsonKey(name: 'threshold')  double threshold, @JsonKey(name: 'floor')  int floor, @JsonKey(name: 'windowWeeks')  int windowWeeks, @JsonKey(name: 'multiplier')  double multiplier, @JsonKey(name: 'ageBandCounts')  Map<String, int> ageBandCounts, @JsonKey(name: 'manualRequests')  int manualRequests, @JsonKey(name: 'categoryVerified')  bool categoryVerified, @JsonKey(name: 'mappingVerified')  bool mappingVerified, @JsonKey(name: 'categorySourceId')  String categorySourceId, @JsonKey(name: 'weekStart')  String weekStart)?  $default,) {final _that = this;
switch (_that) {
case _AlertEvidenceModel() when $default != null:
return $default(_that.confirmedCount,_that.baselineMean,_that.baselineSd,_that.threshold,_that.floor,_that.windowWeeks,_that.multiplier,_that.ageBandCounts,_that.manualRequests,_that.categoryVerified,_that.mappingVerified,_that.categorySourceId,_that.weekStart);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AlertEvidenceModel extends AlertEvidenceModel {
  const _AlertEvidenceModel({@JsonKey(name: 'confirmedCount') this.confirmedCount = 0, @JsonKey(name: 'baselineMean') this.baselineMean = 0, @JsonKey(name: 'baselineSd') this.baselineSd = 0, @JsonKey(name: 'threshold') this.threshold = 0, @JsonKey(name: 'floor') this.floor = 0, @JsonKey(name: 'windowWeeks') this.windowWeeks = 0, @JsonKey(name: 'multiplier') this.multiplier = 0, @JsonKey(name: 'ageBandCounts') final  Map<String, int> ageBandCounts = const <String, int>{}, @JsonKey(name: 'manualRequests') this.manualRequests = 0, @JsonKey(name: 'categoryVerified') this.categoryVerified = false, @JsonKey(name: 'mappingVerified') this.mappingVerified = false, @JsonKey(name: 'categorySourceId') this.categorySourceId = '', @JsonKey(name: 'weekStart') this.weekStart = ''}): _ageBandCounts = ageBandCounts,super._();
  factory _AlertEvidenceModel.fromJson(Map<String, dynamic> json) => _$AlertEvidenceModelFromJson(json);

@override@JsonKey(name: 'confirmedCount') final  int confirmedCount;
@override@JsonKey(name: 'baselineMean') final  double baselineMean;
@override@JsonKey(name: 'baselineSd') final  double baselineSd;
@override@JsonKey(name: 'threshold') final  double threshold;
@override@JsonKey(name: 'floor') final  int floor;
@override@JsonKey(name: 'windowWeeks') final  int windowWeeks;
@override@JsonKey(name: 'multiplier') final  double multiplier;
 final  Map<String, int> _ageBandCounts;
@override@JsonKey(name: 'ageBandCounts') Map<String, int> get ageBandCounts {
  if (_ageBandCounts is EqualUnmodifiableMapView) return _ageBandCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_ageBandCounts);
}

@override@JsonKey(name: 'manualRequests') final  int manualRequests;
@override@JsonKey(name: 'categoryVerified') final  bool categoryVerified;
@override@JsonKey(name: 'mappingVerified') final  bool mappingVerified;
@override@JsonKey(name: 'categorySourceId') final  String categorySourceId;
@override@JsonKey(name: 'weekStart') final  String weekStart;

/// Create a copy of AlertEvidenceModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlertEvidenceModelCopyWith<_AlertEvidenceModel> get copyWith => __$AlertEvidenceModelCopyWithImpl<_AlertEvidenceModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AlertEvidenceModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlertEvidenceModel&&(identical(other.confirmedCount, confirmedCount) || other.confirmedCount == confirmedCount)&&(identical(other.baselineMean, baselineMean) || other.baselineMean == baselineMean)&&(identical(other.baselineSd, baselineSd) || other.baselineSd == baselineSd)&&(identical(other.threshold, threshold) || other.threshold == threshold)&&(identical(other.floor, floor) || other.floor == floor)&&(identical(other.windowWeeks, windowWeeks) || other.windowWeeks == windowWeeks)&&(identical(other.multiplier, multiplier) || other.multiplier == multiplier)&&const DeepCollectionEquality().equals(other._ageBandCounts, _ageBandCounts)&&(identical(other.manualRequests, manualRequests) || other.manualRequests == manualRequests)&&(identical(other.categoryVerified, categoryVerified) || other.categoryVerified == categoryVerified)&&(identical(other.mappingVerified, mappingVerified) || other.mappingVerified == mappingVerified)&&(identical(other.categorySourceId, categorySourceId) || other.categorySourceId == categorySourceId)&&(identical(other.weekStart, weekStart) || other.weekStart == weekStart));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,confirmedCount,baselineMean,baselineSd,threshold,floor,windowWeeks,multiplier,const DeepCollectionEquality().hash(_ageBandCounts),manualRequests,categoryVerified,mappingVerified,categorySourceId,weekStart);

@override
String toString() {
  return 'AlertEvidenceModel(confirmedCount: $confirmedCount, baselineMean: $baselineMean, baselineSd: $baselineSd, threshold: $threshold, floor: $floor, windowWeeks: $windowWeeks, multiplier: $multiplier, ageBandCounts: $ageBandCounts, manualRequests: $manualRequests, categoryVerified: $categoryVerified, mappingVerified: $mappingVerified, categorySourceId: $categorySourceId, weekStart: $weekStart)';
}


}

/// @nodoc
abstract mixin class _$AlertEvidenceModelCopyWith<$Res> implements $AlertEvidenceModelCopyWith<$Res> {
  factory _$AlertEvidenceModelCopyWith(_AlertEvidenceModel value, $Res Function(_AlertEvidenceModel) _then) = __$AlertEvidenceModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'confirmedCount') int confirmedCount,@JsonKey(name: 'baselineMean') double baselineMean,@JsonKey(name: 'baselineSd') double baselineSd,@JsonKey(name: 'threshold') double threshold,@JsonKey(name: 'floor') int floor,@JsonKey(name: 'windowWeeks') int windowWeeks,@JsonKey(name: 'multiplier') double multiplier,@JsonKey(name: 'ageBandCounts') Map<String, int> ageBandCounts,@JsonKey(name: 'manualRequests') int manualRequests,@JsonKey(name: 'categoryVerified') bool categoryVerified,@JsonKey(name: 'mappingVerified') bool mappingVerified,@JsonKey(name: 'categorySourceId') String categorySourceId,@JsonKey(name: 'weekStart') String weekStart
});




}
/// @nodoc
class __$AlertEvidenceModelCopyWithImpl<$Res>
    implements _$AlertEvidenceModelCopyWith<$Res> {
  __$AlertEvidenceModelCopyWithImpl(this._self, this._then);

  final _AlertEvidenceModel _self;
  final $Res Function(_AlertEvidenceModel) _then;

/// Create a copy of AlertEvidenceModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? confirmedCount = null,Object? baselineMean = null,Object? baselineSd = null,Object? threshold = null,Object? floor = null,Object? windowWeeks = null,Object? multiplier = null,Object? ageBandCounts = null,Object? manualRequests = null,Object? categoryVerified = null,Object? mappingVerified = null,Object? categorySourceId = null,Object? weekStart = null,}) {
  return _then(_AlertEvidenceModel(
confirmedCount: null == confirmedCount ? _self.confirmedCount : confirmedCount // ignore: cast_nullable_to_non_nullable
as int,baselineMean: null == baselineMean ? _self.baselineMean : baselineMean // ignore: cast_nullable_to_non_nullable
as double,baselineSd: null == baselineSd ? _self.baselineSd : baselineSd // ignore: cast_nullable_to_non_nullable
as double,threshold: null == threshold ? _self.threshold : threshold // ignore: cast_nullable_to_non_nullable
as double,floor: null == floor ? _self.floor : floor // ignore: cast_nullable_to_non_nullable
as int,windowWeeks: null == windowWeeks ? _self.windowWeeks : windowWeeks // ignore: cast_nullable_to_non_nullable
as int,multiplier: null == multiplier ? _self.multiplier : multiplier // ignore: cast_nullable_to_non_nullable
as double,ageBandCounts: null == ageBandCounts ? _self._ageBandCounts : ageBandCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,manualRequests: null == manualRequests ? _self.manualRequests : manualRequests // ignore: cast_nullable_to_non_nullable
as int,categoryVerified: null == categoryVerified ? _self.categoryVerified : categoryVerified // ignore: cast_nullable_to_non_nullable
as bool,mappingVerified: null == mappingVerified ? _self.mappingVerified : mappingVerified // ignore: cast_nullable_to_non_nullable
as bool,categorySourceId: null == categorySourceId ? _self.categorySourceId : categorySourceId // ignore: cast_nullable_to_non_nullable
as String,weekStart: null == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
