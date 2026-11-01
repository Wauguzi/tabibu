// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_template_question_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReportTemplateQuestionModel {

@JsonKey(name: 'questionKey') String get questionKey;@JsonKey(name: 'order') int get order;@JsonKey(name: 'required') bool get required;
/// Create a copy of ReportTemplateQuestionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportTemplateQuestionModelCopyWith<ReportTemplateQuestionModel> get copyWith => _$ReportTemplateQuestionModelCopyWithImpl<ReportTemplateQuestionModel>(this as ReportTemplateQuestionModel, _$identity);

  /// Serializes this ReportTemplateQuestionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportTemplateQuestionModel&&(identical(other.questionKey, questionKey) || other.questionKey == questionKey)&&(identical(other.order, order) || other.order == order)&&(identical(other.required, required) || other.required == required));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,questionKey,order,required);

@override
String toString() {
  return 'ReportTemplateQuestionModel(questionKey: $questionKey, order: $order, required: $required)';
}


}

/// @nodoc
abstract mixin class $ReportTemplateQuestionModelCopyWith<$Res>  {
  factory $ReportTemplateQuestionModelCopyWith(ReportTemplateQuestionModel value, $Res Function(ReportTemplateQuestionModel) _then) = _$ReportTemplateQuestionModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'questionKey') String questionKey,@JsonKey(name: 'order') int order,@JsonKey(name: 'required') bool required
});




}
/// @nodoc
class _$ReportTemplateQuestionModelCopyWithImpl<$Res>
    implements $ReportTemplateQuestionModelCopyWith<$Res> {
  _$ReportTemplateQuestionModelCopyWithImpl(this._self, this._then);

  final ReportTemplateQuestionModel _self;
  final $Res Function(ReportTemplateQuestionModel) _then;

/// Create a copy of ReportTemplateQuestionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? questionKey = null,Object? order = null,Object? required = null,}) {
  return _then(_self.copyWith(
questionKey: null == questionKey ? _self.questionKey : questionKey // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,required: null == required ? _self.required : required // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportTemplateQuestionModel].
extension ReportTemplateQuestionModelPatterns on ReportTemplateQuestionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportTemplateQuestionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportTemplateQuestionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportTemplateQuestionModel value)  $default,){
final _that = this;
switch (_that) {
case _ReportTemplateQuestionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportTemplateQuestionModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReportTemplateQuestionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'questionKey')  String questionKey, @JsonKey(name: 'order')  int order, @JsonKey(name: 'required')  bool required)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportTemplateQuestionModel() when $default != null:
return $default(_that.questionKey,_that.order,_that.required);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'questionKey')  String questionKey, @JsonKey(name: 'order')  int order, @JsonKey(name: 'required')  bool required)  $default,) {final _that = this;
switch (_that) {
case _ReportTemplateQuestionModel():
return $default(_that.questionKey,_that.order,_that.required);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'questionKey')  String questionKey, @JsonKey(name: 'order')  int order, @JsonKey(name: 'required')  bool required)?  $default,) {final _that = this;
switch (_that) {
case _ReportTemplateQuestionModel() when $default != null:
return $default(_that.questionKey,_that.order,_that.required);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportTemplateQuestionModel extends ReportTemplateQuestionModel {
  const _ReportTemplateQuestionModel({@JsonKey(name: 'questionKey') this.questionKey = '', @JsonKey(name: 'order') this.order = 0, @JsonKey(name: 'required') this.required = false}): super._();
  factory _ReportTemplateQuestionModel.fromJson(Map<String, dynamic> json) => _$ReportTemplateQuestionModelFromJson(json);

@override@JsonKey(name: 'questionKey') final  String questionKey;
@override@JsonKey(name: 'order') final  int order;
@override@JsonKey(name: 'required') final  bool required;

/// Create a copy of ReportTemplateQuestionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportTemplateQuestionModelCopyWith<_ReportTemplateQuestionModel> get copyWith => __$ReportTemplateQuestionModelCopyWithImpl<_ReportTemplateQuestionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportTemplateQuestionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportTemplateQuestionModel&&(identical(other.questionKey, questionKey) || other.questionKey == questionKey)&&(identical(other.order, order) || other.order == order)&&(identical(other.required, required) || other.required == required));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,questionKey,order,required);

@override
String toString() {
  return 'ReportTemplateQuestionModel(questionKey: $questionKey, order: $order, required: $required)';
}


}

/// @nodoc
abstract mixin class _$ReportTemplateQuestionModelCopyWith<$Res> implements $ReportTemplateQuestionModelCopyWith<$Res> {
  factory _$ReportTemplateQuestionModelCopyWith(_ReportTemplateQuestionModel value, $Res Function(_ReportTemplateQuestionModel) _then) = __$ReportTemplateQuestionModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'questionKey') String questionKey,@JsonKey(name: 'order') int order,@JsonKey(name: 'required') bool required
});




}
/// @nodoc
class __$ReportTemplateQuestionModelCopyWithImpl<$Res>
    implements _$ReportTemplateQuestionModelCopyWith<$Res> {
  __$ReportTemplateQuestionModelCopyWithImpl(this._self, this._then);

  final _ReportTemplateQuestionModel _self;
  final $Res Function(_ReportTemplateQuestionModel) _then;

/// Create a copy of ReportTemplateQuestionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? questionKey = null,Object? order = null,Object? required = null,}) {
  return _then(_ReportTemplateQuestionModel(
questionKey: null == questionKey ? _self.questionKey : questionKey // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,required: null == required ? _self.required : required // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
