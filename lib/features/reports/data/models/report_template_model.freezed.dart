// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_template_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReportTemplateModel {

@JsonKey(name: 'templateKey') String get templateKey;@JsonKey(name: 'testTypeIds') List<String> get testTypeIds;@JsonKey(name: 'sections') List<ReportTemplateSectionModel> get sections;
/// Create a copy of ReportTemplateModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportTemplateModelCopyWith<ReportTemplateModel> get copyWith => _$ReportTemplateModelCopyWithImpl<ReportTemplateModel>(this as ReportTemplateModel, _$identity);

  /// Serializes this ReportTemplateModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportTemplateModel&&(identical(other.templateKey, templateKey) || other.templateKey == templateKey)&&const DeepCollectionEquality().equals(other.testTypeIds, testTypeIds)&&const DeepCollectionEquality().equals(other.sections, sections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,templateKey,const DeepCollectionEquality().hash(testTypeIds),const DeepCollectionEquality().hash(sections));

@override
String toString() {
  return 'ReportTemplateModel(templateKey: $templateKey, testTypeIds: $testTypeIds, sections: $sections)';
}


}

/// @nodoc
abstract mixin class $ReportTemplateModelCopyWith<$Res>  {
  factory $ReportTemplateModelCopyWith(ReportTemplateModel value, $Res Function(ReportTemplateModel) _then) = _$ReportTemplateModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'templateKey') String templateKey,@JsonKey(name: 'testTypeIds') List<String> testTypeIds,@JsonKey(name: 'sections') List<ReportTemplateSectionModel> sections
});




}
/// @nodoc
class _$ReportTemplateModelCopyWithImpl<$Res>
    implements $ReportTemplateModelCopyWith<$Res> {
  _$ReportTemplateModelCopyWithImpl(this._self, this._then);

  final ReportTemplateModel _self;
  final $Res Function(ReportTemplateModel) _then;

/// Create a copy of ReportTemplateModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? templateKey = null,Object? testTypeIds = null,Object? sections = null,}) {
  return _then(_self.copyWith(
templateKey: null == templateKey ? _self.templateKey : templateKey // ignore: cast_nullable_to_non_nullable
as String,testTypeIds: null == testTypeIds ? _self.testTypeIds : testTypeIds // ignore: cast_nullable_to_non_nullable
as List<String>,sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as List<ReportTemplateSectionModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportTemplateModel].
extension ReportTemplateModelPatterns on ReportTemplateModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportTemplateModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportTemplateModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportTemplateModel value)  $default,){
final _that = this;
switch (_that) {
case _ReportTemplateModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportTemplateModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReportTemplateModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'templateKey')  String templateKey, @JsonKey(name: 'testTypeIds')  List<String> testTypeIds, @JsonKey(name: 'sections')  List<ReportTemplateSectionModel> sections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportTemplateModel() when $default != null:
return $default(_that.templateKey,_that.testTypeIds,_that.sections);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'templateKey')  String templateKey, @JsonKey(name: 'testTypeIds')  List<String> testTypeIds, @JsonKey(name: 'sections')  List<ReportTemplateSectionModel> sections)  $default,) {final _that = this;
switch (_that) {
case _ReportTemplateModel():
return $default(_that.templateKey,_that.testTypeIds,_that.sections);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'templateKey')  String templateKey, @JsonKey(name: 'testTypeIds')  List<String> testTypeIds, @JsonKey(name: 'sections')  List<ReportTemplateSectionModel> sections)?  $default,) {final _that = this;
switch (_that) {
case _ReportTemplateModel() when $default != null:
return $default(_that.templateKey,_that.testTypeIds,_that.sections);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _ReportTemplateModel extends ReportTemplateModel {
  const _ReportTemplateModel({@JsonKey(name: 'templateKey') this.templateKey = '', @JsonKey(name: 'testTypeIds') final  List<String> testTypeIds = const <String>[], @JsonKey(name: 'sections') final  List<ReportTemplateSectionModel> sections = const <ReportTemplateSectionModel>[]}): _testTypeIds = testTypeIds,_sections = sections,super._();
  factory _ReportTemplateModel.fromJson(Map<String, dynamic> json) => _$ReportTemplateModelFromJson(json);

@override@JsonKey(name: 'templateKey') final  String templateKey;
 final  List<String> _testTypeIds;
@override@JsonKey(name: 'testTypeIds') List<String> get testTypeIds {
  if (_testTypeIds is EqualUnmodifiableListView) return _testTypeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_testTypeIds);
}

 final  List<ReportTemplateSectionModel> _sections;
@override@JsonKey(name: 'sections') List<ReportTemplateSectionModel> get sections {
  if (_sections is EqualUnmodifiableListView) return _sections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sections);
}


/// Create a copy of ReportTemplateModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportTemplateModelCopyWith<_ReportTemplateModel> get copyWith => __$ReportTemplateModelCopyWithImpl<_ReportTemplateModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportTemplateModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportTemplateModel&&(identical(other.templateKey, templateKey) || other.templateKey == templateKey)&&const DeepCollectionEquality().equals(other._testTypeIds, _testTypeIds)&&const DeepCollectionEquality().equals(other._sections, _sections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,templateKey,const DeepCollectionEquality().hash(_testTypeIds),const DeepCollectionEquality().hash(_sections));

@override
String toString() {
  return 'ReportTemplateModel(templateKey: $templateKey, testTypeIds: $testTypeIds, sections: $sections)';
}


}

/// @nodoc
abstract mixin class _$ReportTemplateModelCopyWith<$Res> implements $ReportTemplateModelCopyWith<$Res> {
  factory _$ReportTemplateModelCopyWith(_ReportTemplateModel value, $Res Function(_ReportTemplateModel) _then) = __$ReportTemplateModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'templateKey') String templateKey,@JsonKey(name: 'testTypeIds') List<String> testTypeIds,@JsonKey(name: 'sections') List<ReportTemplateSectionModel> sections
});




}
/// @nodoc
class __$ReportTemplateModelCopyWithImpl<$Res>
    implements _$ReportTemplateModelCopyWith<$Res> {
  __$ReportTemplateModelCopyWithImpl(this._self, this._then);

  final _ReportTemplateModel _self;
  final $Res Function(_ReportTemplateModel) _then;

/// Create a copy of ReportTemplateModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? templateKey = null,Object? testTypeIds = null,Object? sections = null,}) {
  return _then(_ReportTemplateModel(
templateKey: null == templateKey ? _self.templateKey : templateKey // ignore: cast_nullable_to_non_nullable
as String,testTypeIds: null == testTypeIds ? _self._testTypeIds : testTypeIds // ignore: cast_nullable_to_non_nullable
as List<String>,sections: null == sections ? _self._sections : sections // ignore: cast_nullable_to_non_nullable
as List<ReportTemplateSectionModel>,
  ));
}


}

// dart format on
