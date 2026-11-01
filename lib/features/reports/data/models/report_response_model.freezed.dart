// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReportResponseModel {

@JsonKey(name: 'section') String get section;@JsonKey(name: 'question') String get question;@JsonKey(name: 'answer') String get answer;@JsonKey(name: 'order') int get order;
/// Create a copy of ReportResponseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportResponseModelCopyWith<ReportResponseModel> get copyWith => _$ReportResponseModelCopyWithImpl<ReportResponseModel>(this as ReportResponseModel, _$identity);

  /// Serializes this ReportResponseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportResponseModel&&(identical(other.section, section) || other.section == section)&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,section,question,answer,order);

@override
String toString() {
  return 'ReportResponseModel(section: $section, question: $question, answer: $answer, order: $order)';
}


}

/// @nodoc
abstract mixin class $ReportResponseModelCopyWith<$Res>  {
  factory $ReportResponseModelCopyWith(ReportResponseModel value, $Res Function(ReportResponseModel) _then) = _$ReportResponseModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'section') String section,@JsonKey(name: 'question') String question,@JsonKey(name: 'answer') String answer,@JsonKey(name: 'order') int order
});




}
/// @nodoc
class _$ReportResponseModelCopyWithImpl<$Res>
    implements $ReportResponseModelCopyWith<$Res> {
  _$ReportResponseModelCopyWithImpl(this._self, this._then);

  final ReportResponseModel _self;
  final $Res Function(ReportResponseModel) _then;

/// Create a copy of ReportResponseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? section = null,Object? question = null,Object? answer = null,Object? order = null,}) {
  return _then(_self.copyWith(
section: null == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportResponseModel].
extension ReportResponseModelPatterns on ReportResponseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportResponseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportResponseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportResponseModel value)  $default,){
final _that = this;
switch (_that) {
case _ReportResponseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportResponseModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReportResponseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'section')  String section, @JsonKey(name: 'question')  String question, @JsonKey(name: 'answer')  String answer, @JsonKey(name: 'order')  int order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportResponseModel() when $default != null:
return $default(_that.section,_that.question,_that.answer,_that.order);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'section')  String section, @JsonKey(name: 'question')  String question, @JsonKey(name: 'answer')  String answer, @JsonKey(name: 'order')  int order)  $default,) {final _that = this;
switch (_that) {
case _ReportResponseModel():
return $default(_that.section,_that.question,_that.answer,_that.order);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'section')  String section, @JsonKey(name: 'question')  String question, @JsonKey(name: 'answer')  String answer, @JsonKey(name: 'order')  int order)?  $default,) {final _that = this;
switch (_that) {
case _ReportResponseModel() when $default != null:
return $default(_that.section,_that.question,_that.answer,_that.order);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportResponseModel extends ReportResponseModel {
  const _ReportResponseModel({@JsonKey(name: 'section') this.section = '', @JsonKey(name: 'question') this.question = '', @JsonKey(name: 'answer') this.answer = '', @JsonKey(name: 'order') this.order = 0}): super._();
  factory _ReportResponseModel.fromJson(Map<String, dynamic> json) => _$ReportResponseModelFromJson(json);

@override@JsonKey(name: 'section') final  String section;
@override@JsonKey(name: 'question') final  String question;
@override@JsonKey(name: 'answer') final  String answer;
@override@JsonKey(name: 'order') final  int order;

/// Create a copy of ReportResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportResponseModelCopyWith<_ReportResponseModel> get copyWith => __$ReportResponseModelCopyWithImpl<_ReportResponseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportResponseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportResponseModel&&(identical(other.section, section) || other.section == section)&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,section,question,answer,order);

@override
String toString() {
  return 'ReportResponseModel(section: $section, question: $question, answer: $answer, order: $order)';
}


}

/// @nodoc
abstract mixin class _$ReportResponseModelCopyWith<$Res> implements $ReportResponseModelCopyWith<$Res> {
  factory _$ReportResponseModelCopyWith(_ReportResponseModel value, $Res Function(_ReportResponseModel) _then) = __$ReportResponseModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'section') String section,@JsonKey(name: 'question') String question,@JsonKey(name: 'answer') String answer,@JsonKey(name: 'order') int order
});




}
/// @nodoc
class __$ReportResponseModelCopyWithImpl<$Res>
    implements _$ReportResponseModelCopyWith<$Res> {
  __$ReportResponseModelCopyWithImpl(this._self, this._then);

  final _ReportResponseModel _self;
  final $Res Function(_ReportResponseModel) _then;

/// Create a copy of ReportResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? section = null,Object? question = null,Object? answer = null,Object? order = null,}) {
  return _then(_ReportResponseModel(
section: null == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
