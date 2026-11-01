// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_template_section_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReportTemplateSectionModel {

@JsonKey(name: 'sectionKey') String get sectionKey;@JsonKey(name: 'order') int get order;@JsonKey(name: 'questions') List<ReportTemplateQuestionModel> get questions;
/// Create a copy of ReportTemplateSectionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportTemplateSectionModelCopyWith<ReportTemplateSectionModel> get copyWith => _$ReportTemplateSectionModelCopyWithImpl<ReportTemplateSectionModel>(this as ReportTemplateSectionModel, _$identity);

  /// Serializes this ReportTemplateSectionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportTemplateSectionModel&&(identical(other.sectionKey, sectionKey) || other.sectionKey == sectionKey)&&(identical(other.order, order) || other.order == order)&&const DeepCollectionEquality().equals(other.questions, questions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sectionKey,order,const DeepCollectionEquality().hash(questions));

@override
String toString() {
  return 'ReportTemplateSectionModel(sectionKey: $sectionKey, order: $order, questions: $questions)';
}


}

/// @nodoc
abstract mixin class $ReportTemplateSectionModelCopyWith<$Res>  {
  factory $ReportTemplateSectionModelCopyWith(ReportTemplateSectionModel value, $Res Function(ReportTemplateSectionModel) _then) = _$ReportTemplateSectionModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'sectionKey') String sectionKey,@JsonKey(name: 'order') int order,@JsonKey(name: 'questions') List<ReportTemplateQuestionModel> questions
});




}
/// @nodoc
class _$ReportTemplateSectionModelCopyWithImpl<$Res>
    implements $ReportTemplateSectionModelCopyWith<$Res> {
  _$ReportTemplateSectionModelCopyWithImpl(this._self, this._then);

  final ReportTemplateSectionModel _self;
  final $Res Function(ReportTemplateSectionModel) _then;

/// Create a copy of ReportTemplateSectionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sectionKey = null,Object? order = null,Object? questions = null,}) {
  return _then(_self.copyWith(
sectionKey: null == sectionKey ? _self.sectionKey : sectionKey // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,questions: null == questions ? _self.questions : questions // ignore: cast_nullable_to_non_nullable
as List<ReportTemplateQuestionModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportTemplateSectionModel].
extension ReportTemplateSectionModelPatterns on ReportTemplateSectionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportTemplateSectionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportTemplateSectionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportTemplateSectionModel value)  $default,){
final _that = this;
switch (_that) {
case _ReportTemplateSectionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportTemplateSectionModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReportTemplateSectionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'sectionKey')  String sectionKey, @JsonKey(name: 'order')  int order, @JsonKey(name: 'questions')  List<ReportTemplateQuestionModel> questions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportTemplateSectionModel() when $default != null:
return $default(_that.sectionKey,_that.order,_that.questions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'sectionKey')  String sectionKey, @JsonKey(name: 'order')  int order, @JsonKey(name: 'questions')  List<ReportTemplateQuestionModel> questions)  $default,) {final _that = this;
switch (_that) {
case _ReportTemplateSectionModel():
return $default(_that.sectionKey,_that.order,_that.questions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'sectionKey')  String sectionKey, @JsonKey(name: 'order')  int order, @JsonKey(name: 'questions')  List<ReportTemplateQuestionModel> questions)?  $default,) {final _that = this;
switch (_that) {
case _ReportTemplateSectionModel() when $default != null:
return $default(_that.sectionKey,_that.order,_that.questions);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _ReportTemplateSectionModel extends ReportTemplateSectionModel {
  const _ReportTemplateSectionModel({@JsonKey(name: 'sectionKey') this.sectionKey = '', @JsonKey(name: 'order') this.order = 0, @JsonKey(name: 'questions') final  List<ReportTemplateQuestionModel> questions = const <ReportTemplateQuestionModel>[]}): _questions = questions,super._();
  factory _ReportTemplateSectionModel.fromJson(Map<String, dynamic> json) => _$ReportTemplateSectionModelFromJson(json);

@override@JsonKey(name: 'sectionKey') final  String sectionKey;
@override@JsonKey(name: 'order') final  int order;
 final  List<ReportTemplateQuestionModel> _questions;
@override@JsonKey(name: 'questions') List<ReportTemplateQuestionModel> get questions {
  if (_questions is EqualUnmodifiableListView) return _questions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_questions);
}


/// Create a copy of ReportTemplateSectionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportTemplateSectionModelCopyWith<_ReportTemplateSectionModel> get copyWith => __$ReportTemplateSectionModelCopyWithImpl<_ReportTemplateSectionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportTemplateSectionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportTemplateSectionModel&&(identical(other.sectionKey, sectionKey) || other.sectionKey == sectionKey)&&(identical(other.order, order) || other.order == order)&&const DeepCollectionEquality().equals(other._questions, _questions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sectionKey,order,const DeepCollectionEquality().hash(_questions));

@override
String toString() {
  return 'ReportTemplateSectionModel(sectionKey: $sectionKey, order: $order, questions: $questions)';
}


}

/// @nodoc
abstract mixin class _$ReportTemplateSectionModelCopyWith<$Res> implements $ReportTemplateSectionModelCopyWith<$Res> {
  factory _$ReportTemplateSectionModelCopyWith(_ReportTemplateSectionModel value, $Res Function(_ReportTemplateSectionModel) _then) = __$ReportTemplateSectionModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'sectionKey') String sectionKey,@JsonKey(name: 'order') int order,@JsonKey(name: 'questions') List<ReportTemplateQuestionModel> questions
});




}
/// @nodoc
class __$ReportTemplateSectionModelCopyWithImpl<$Res>
    implements _$ReportTemplateSectionModelCopyWith<$Res> {
  __$ReportTemplateSectionModelCopyWithImpl(this._self, this._then);

  final _ReportTemplateSectionModel _self;
  final $Res Function(_ReportTemplateSectionModel) _then;

/// Create a copy of ReportTemplateSectionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sectionKey = null,Object? order = null,Object? questions = null,}) {
  return _then(_ReportTemplateSectionModel(
sectionKey: null == sectionKey ? _self.sectionKey : sectionKey // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,questions: null == questions ? _self._questions : questions // ignore: cast_nullable_to_non_nullable
as List<ReportTemplateQuestionModel>,
  ));
}


}

// dart format on
