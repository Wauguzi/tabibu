// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_pdf_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PdfLine {

@JsonKey(name: 'label') String get label;@JsonKey(name: 'value') String get value;
/// Create a copy of PdfLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PdfLineCopyWith<PdfLine> get copyWith => _$PdfLineCopyWithImpl<PdfLine>(this as PdfLine, _$identity);

  /// Serializes this PdfLine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PdfLine&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,value);

@override
String toString() {
  return 'PdfLine(label: $label, value: $value)';
}


}

/// @nodoc
abstract mixin class $PdfLineCopyWith<$Res>  {
  factory $PdfLineCopyWith(PdfLine value, $Res Function(PdfLine) _then) = _$PdfLineCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'label') String label,@JsonKey(name: 'value') String value
});




}
/// @nodoc
class _$PdfLineCopyWithImpl<$Res>
    implements $PdfLineCopyWith<$Res> {
  _$PdfLineCopyWithImpl(this._self, this._then);

  final PdfLine _self;
  final $Res Function(PdfLine) _then;

/// Create a copy of PdfLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? value = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PdfLine].
extension PdfLinePatterns on PdfLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PdfLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PdfLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PdfLine value)  $default,){
final _that = this;
switch (_that) {
case _PdfLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PdfLine value)?  $default,){
final _that = this;
switch (_that) {
case _PdfLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'label')  String label, @JsonKey(name: 'value')  String value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PdfLine() when $default != null:
return $default(_that.label,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'label')  String label, @JsonKey(name: 'value')  String value)  $default,) {final _that = this;
switch (_that) {
case _PdfLine():
return $default(_that.label,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'label')  String label, @JsonKey(name: 'value')  String value)?  $default,) {final _that = this;
switch (_that) {
case _PdfLine() when $default != null:
return $default(_that.label,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PdfLine extends PdfLine {
  const _PdfLine({@JsonKey(name: 'label') this.label = '', @JsonKey(name: 'value') this.value = ''}): super._();
  factory _PdfLine.fromJson(Map<String, dynamic> json) => _$PdfLineFromJson(json);

@override@JsonKey(name: 'label') final  String label;
@override@JsonKey(name: 'value') final  String value;

/// Create a copy of PdfLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PdfLineCopyWith<_PdfLine> get copyWith => __$PdfLineCopyWithImpl<_PdfLine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PdfLineToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PdfLine&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,value);

@override
String toString() {
  return 'PdfLine(label: $label, value: $value)';
}


}

/// @nodoc
abstract mixin class _$PdfLineCopyWith<$Res> implements $PdfLineCopyWith<$Res> {
  factory _$PdfLineCopyWith(_PdfLine value, $Res Function(_PdfLine) _then) = __$PdfLineCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'label') String label,@JsonKey(name: 'value') String value
});




}
/// @nodoc
class __$PdfLineCopyWithImpl<$Res>
    implements _$PdfLineCopyWith<$Res> {
  __$PdfLineCopyWithImpl(this._self, this._then);

  final _PdfLine _self;
  final $Res Function(_PdfLine) _then;

/// Create a copy of PdfLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? value = null,}) {
  return _then(_PdfLine(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PdfBlock {

@JsonKey(name: 'title') String get title;@JsonKey(name: 'lines') List<PdfLine> get lines;
/// Create a copy of PdfBlock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PdfBlockCopyWith<PdfBlock> get copyWith => _$PdfBlockCopyWithImpl<PdfBlock>(this as PdfBlock, _$identity);

  /// Serializes this PdfBlock to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PdfBlock&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.lines, lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(lines));

@override
String toString() {
  return 'PdfBlock(title: $title, lines: $lines)';
}


}

/// @nodoc
abstract mixin class $PdfBlockCopyWith<$Res>  {
  factory $PdfBlockCopyWith(PdfBlock value, $Res Function(PdfBlock) _then) = _$PdfBlockCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'title') String title,@JsonKey(name: 'lines') List<PdfLine> lines
});




}
/// @nodoc
class _$PdfBlockCopyWithImpl<$Res>
    implements $PdfBlockCopyWith<$Res> {
  _$PdfBlockCopyWithImpl(this._self, this._then);

  final PdfBlock _self;
  final $Res Function(PdfBlock) _then;

/// Create a copy of PdfBlock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? lines = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<PdfLine>,
  ));
}

}


/// Adds pattern-matching-related methods to [PdfBlock].
extension PdfBlockPatterns on PdfBlock {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PdfBlock value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PdfBlock() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PdfBlock value)  $default,){
final _that = this;
switch (_that) {
case _PdfBlock():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PdfBlock value)?  $default,){
final _that = this;
switch (_that) {
case _PdfBlock() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'title')  String title, @JsonKey(name: 'lines')  List<PdfLine> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PdfBlock() when $default != null:
return $default(_that.title,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'title')  String title, @JsonKey(name: 'lines')  List<PdfLine> lines)  $default,) {final _that = this;
switch (_that) {
case _PdfBlock():
return $default(_that.title,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'title')  String title, @JsonKey(name: 'lines')  List<PdfLine> lines)?  $default,) {final _that = this;
switch (_that) {
case _PdfBlock() when $default != null:
return $default(_that.title,_that.lines);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _PdfBlock extends PdfBlock {
  const _PdfBlock({@JsonKey(name: 'title') this.title = '', @JsonKey(name: 'lines') final  List<PdfLine> lines = const <PdfLine>[]}): _lines = lines,super._();
  factory _PdfBlock.fromJson(Map<String, dynamic> json) => _$PdfBlockFromJson(json);

@override@JsonKey(name: 'title') final  String title;
 final  List<PdfLine> _lines;
@override@JsonKey(name: 'lines') List<PdfLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


/// Create a copy of PdfBlock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PdfBlockCopyWith<_PdfBlock> get copyWith => __$PdfBlockCopyWithImpl<_PdfBlock>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PdfBlockToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PdfBlock&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._lines, _lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(_lines));

@override
String toString() {
  return 'PdfBlock(title: $title, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$PdfBlockCopyWith<$Res> implements $PdfBlockCopyWith<$Res> {
  factory _$PdfBlockCopyWith(_PdfBlock value, $Res Function(_PdfBlock) _then) = __$PdfBlockCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'title') String title,@JsonKey(name: 'lines') List<PdfLine> lines
});




}
/// @nodoc
class __$PdfBlockCopyWithImpl<$Res>
    implements _$PdfBlockCopyWith<$Res> {
  __$PdfBlockCopyWithImpl(this._self, this._then);

  final _PdfBlock _self;
  final $Res Function(_PdfBlock) _then;

/// Create a copy of PdfBlock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? lines = null,}) {
  return _then(_PdfBlock(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<PdfLine>,
  ));
}


}


/// @nodoc
mixin _$PdfHeader {

@JsonKey(name: 'orderNumber') String get orderNumber;@JsonKey(name: 'testName') String get testName;@JsonKey(name: 'templateLabel') String get templateLabel;@JsonKey(name: 'version') int get version;/// The report's stage wire value (`Initial`, `Addended`, `Amended`); the PDF
/// builder localises it, so no display text is fixed here.
@JsonKey(name: 'stage') String get stage;@JsonKey(name: 'doctorName') String get doctorName;@JsonKey(name: 'doctorFacilityName') String get doctorFacilityName;@JsonKey(name: 'signedByFacilityName') String get signedByFacilityName;@JsonKey(name: 'sampleCollectedAt') String get sampleCollectedAt;@JsonKey(name: 'sampleReceivedAt') String get sampleReceivedAt;@JsonKey(name: 'labAccessionNo') String get labAccessionNo;@JsonKey(name: 'releasedAtLabel') String get releasedAtLabel;
/// Create a copy of PdfHeader
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PdfHeaderCopyWith<PdfHeader> get copyWith => _$PdfHeaderCopyWithImpl<PdfHeader>(this as PdfHeader, _$identity);

  /// Serializes this PdfHeader to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PdfHeader&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.testName, testName) || other.testName == testName)&&(identical(other.templateLabel, templateLabel) || other.templateLabel == templateLabel)&&(identical(other.version, version) || other.version == version)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.doctorName, doctorName) || other.doctorName == doctorName)&&(identical(other.doctorFacilityName, doctorFacilityName) || other.doctorFacilityName == doctorFacilityName)&&(identical(other.signedByFacilityName, signedByFacilityName) || other.signedByFacilityName == signedByFacilityName)&&(identical(other.sampleCollectedAt, sampleCollectedAt) || other.sampleCollectedAt == sampleCollectedAt)&&(identical(other.sampleReceivedAt, sampleReceivedAt) || other.sampleReceivedAt == sampleReceivedAt)&&(identical(other.labAccessionNo, labAccessionNo) || other.labAccessionNo == labAccessionNo)&&(identical(other.releasedAtLabel, releasedAtLabel) || other.releasedAtLabel == releasedAtLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orderNumber,testName,templateLabel,version,stage,doctorName,doctorFacilityName,signedByFacilityName,sampleCollectedAt,sampleReceivedAt,labAccessionNo,releasedAtLabel);

@override
String toString() {
  return 'PdfHeader(orderNumber: $orderNumber, testName: $testName, templateLabel: $templateLabel, version: $version, stage: $stage, doctorName: $doctorName, doctorFacilityName: $doctorFacilityName, signedByFacilityName: $signedByFacilityName, sampleCollectedAt: $sampleCollectedAt, sampleReceivedAt: $sampleReceivedAt, labAccessionNo: $labAccessionNo, releasedAtLabel: $releasedAtLabel)';
}


}

/// @nodoc
abstract mixin class $PdfHeaderCopyWith<$Res>  {
  factory $PdfHeaderCopyWith(PdfHeader value, $Res Function(PdfHeader) _then) = _$PdfHeaderCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'orderNumber') String orderNumber,@JsonKey(name: 'testName') String testName,@JsonKey(name: 'templateLabel') String templateLabel,@JsonKey(name: 'version') int version,@JsonKey(name: 'stage') String stage,@JsonKey(name: 'doctorName') String doctorName,@JsonKey(name: 'doctorFacilityName') String doctorFacilityName,@JsonKey(name: 'signedByFacilityName') String signedByFacilityName,@JsonKey(name: 'sampleCollectedAt') String sampleCollectedAt,@JsonKey(name: 'sampleReceivedAt') String sampleReceivedAt,@JsonKey(name: 'labAccessionNo') String labAccessionNo,@JsonKey(name: 'releasedAtLabel') String releasedAtLabel
});




}
/// @nodoc
class _$PdfHeaderCopyWithImpl<$Res>
    implements $PdfHeaderCopyWith<$Res> {
  _$PdfHeaderCopyWithImpl(this._self, this._then);

  final PdfHeader _self;
  final $Res Function(PdfHeader) _then;

/// Create a copy of PdfHeader
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orderNumber = null,Object? testName = null,Object? templateLabel = null,Object? version = null,Object? stage = null,Object? doctorName = null,Object? doctorFacilityName = null,Object? signedByFacilityName = null,Object? sampleCollectedAt = null,Object? sampleReceivedAt = null,Object? labAccessionNo = null,Object? releasedAtLabel = null,}) {
  return _then(_self.copyWith(
orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,testName: null == testName ? _self.testName : testName // ignore: cast_nullable_to_non_nullable
as String,templateLabel: null == templateLabel ? _self.templateLabel : templateLabel // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as String,doctorName: null == doctorName ? _self.doctorName : doctorName // ignore: cast_nullable_to_non_nullable
as String,doctorFacilityName: null == doctorFacilityName ? _self.doctorFacilityName : doctorFacilityName // ignore: cast_nullable_to_non_nullable
as String,signedByFacilityName: null == signedByFacilityName ? _self.signedByFacilityName : signedByFacilityName // ignore: cast_nullable_to_non_nullable
as String,sampleCollectedAt: null == sampleCollectedAt ? _self.sampleCollectedAt : sampleCollectedAt // ignore: cast_nullable_to_non_nullable
as String,sampleReceivedAt: null == sampleReceivedAt ? _self.sampleReceivedAt : sampleReceivedAt // ignore: cast_nullable_to_non_nullable
as String,labAccessionNo: null == labAccessionNo ? _self.labAccessionNo : labAccessionNo // ignore: cast_nullable_to_non_nullable
as String,releasedAtLabel: null == releasedAtLabel ? _self.releasedAtLabel : releasedAtLabel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PdfHeader].
extension PdfHeaderPatterns on PdfHeader {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PdfHeader value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PdfHeader() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PdfHeader value)  $default,){
final _that = this;
switch (_that) {
case _PdfHeader():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PdfHeader value)?  $default,){
final _that = this;
switch (_that) {
case _PdfHeader() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'orderNumber')  String orderNumber, @JsonKey(name: 'testName')  String testName, @JsonKey(name: 'templateLabel')  String templateLabel, @JsonKey(name: 'version')  int version, @JsonKey(name: 'stage')  String stage, @JsonKey(name: 'doctorName')  String doctorName, @JsonKey(name: 'doctorFacilityName')  String doctorFacilityName, @JsonKey(name: 'signedByFacilityName')  String signedByFacilityName, @JsonKey(name: 'sampleCollectedAt')  String sampleCollectedAt, @JsonKey(name: 'sampleReceivedAt')  String sampleReceivedAt, @JsonKey(name: 'labAccessionNo')  String labAccessionNo, @JsonKey(name: 'releasedAtLabel')  String releasedAtLabel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PdfHeader() when $default != null:
return $default(_that.orderNumber,_that.testName,_that.templateLabel,_that.version,_that.stage,_that.doctorName,_that.doctorFacilityName,_that.signedByFacilityName,_that.sampleCollectedAt,_that.sampleReceivedAt,_that.labAccessionNo,_that.releasedAtLabel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'orderNumber')  String orderNumber, @JsonKey(name: 'testName')  String testName, @JsonKey(name: 'templateLabel')  String templateLabel, @JsonKey(name: 'version')  int version, @JsonKey(name: 'stage')  String stage, @JsonKey(name: 'doctorName')  String doctorName, @JsonKey(name: 'doctorFacilityName')  String doctorFacilityName, @JsonKey(name: 'signedByFacilityName')  String signedByFacilityName, @JsonKey(name: 'sampleCollectedAt')  String sampleCollectedAt, @JsonKey(name: 'sampleReceivedAt')  String sampleReceivedAt, @JsonKey(name: 'labAccessionNo')  String labAccessionNo, @JsonKey(name: 'releasedAtLabel')  String releasedAtLabel)  $default,) {final _that = this;
switch (_that) {
case _PdfHeader():
return $default(_that.orderNumber,_that.testName,_that.templateLabel,_that.version,_that.stage,_that.doctorName,_that.doctorFacilityName,_that.signedByFacilityName,_that.sampleCollectedAt,_that.sampleReceivedAt,_that.labAccessionNo,_that.releasedAtLabel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'orderNumber')  String orderNumber, @JsonKey(name: 'testName')  String testName, @JsonKey(name: 'templateLabel')  String templateLabel, @JsonKey(name: 'version')  int version, @JsonKey(name: 'stage')  String stage, @JsonKey(name: 'doctorName')  String doctorName, @JsonKey(name: 'doctorFacilityName')  String doctorFacilityName, @JsonKey(name: 'signedByFacilityName')  String signedByFacilityName, @JsonKey(name: 'sampleCollectedAt')  String sampleCollectedAt, @JsonKey(name: 'sampleReceivedAt')  String sampleReceivedAt, @JsonKey(name: 'labAccessionNo')  String labAccessionNo, @JsonKey(name: 'releasedAtLabel')  String releasedAtLabel)?  $default,) {final _that = this;
switch (_that) {
case _PdfHeader() when $default != null:
return $default(_that.orderNumber,_that.testName,_that.templateLabel,_that.version,_that.stage,_that.doctorName,_that.doctorFacilityName,_that.signedByFacilityName,_that.sampleCollectedAt,_that.sampleReceivedAt,_that.labAccessionNo,_that.releasedAtLabel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PdfHeader extends PdfHeader {
  const _PdfHeader({@JsonKey(name: 'orderNumber') this.orderNumber = '', @JsonKey(name: 'testName') this.testName = '', @JsonKey(name: 'templateLabel') this.templateLabel = '', @JsonKey(name: 'version') this.version = 0, @JsonKey(name: 'stage') this.stage = '', @JsonKey(name: 'doctorName') this.doctorName = '', @JsonKey(name: 'doctorFacilityName') this.doctorFacilityName = '', @JsonKey(name: 'signedByFacilityName') this.signedByFacilityName = '', @JsonKey(name: 'sampleCollectedAt') this.sampleCollectedAt = '', @JsonKey(name: 'sampleReceivedAt') this.sampleReceivedAt = '', @JsonKey(name: 'labAccessionNo') this.labAccessionNo = '', @JsonKey(name: 'releasedAtLabel') this.releasedAtLabel = ''}): super._();
  factory _PdfHeader.fromJson(Map<String, dynamic> json) => _$PdfHeaderFromJson(json);

@override@JsonKey(name: 'orderNumber') final  String orderNumber;
@override@JsonKey(name: 'testName') final  String testName;
@override@JsonKey(name: 'templateLabel') final  String templateLabel;
@override@JsonKey(name: 'version') final  int version;
/// The report's stage wire value (`Initial`, `Addended`, `Amended`); the PDF
/// builder localises it, so no display text is fixed here.
@override@JsonKey(name: 'stage') final  String stage;
@override@JsonKey(name: 'doctorName') final  String doctorName;
@override@JsonKey(name: 'doctorFacilityName') final  String doctorFacilityName;
@override@JsonKey(name: 'signedByFacilityName') final  String signedByFacilityName;
@override@JsonKey(name: 'sampleCollectedAt') final  String sampleCollectedAt;
@override@JsonKey(name: 'sampleReceivedAt') final  String sampleReceivedAt;
@override@JsonKey(name: 'labAccessionNo') final  String labAccessionNo;
@override@JsonKey(name: 'releasedAtLabel') final  String releasedAtLabel;

/// Create a copy of PdfHeader
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PdfHeaderCopyWith<_PdfHeader> get copyWith => __$PdfHeaderCopyWithImpl<_PdfHeader>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PdfHeaderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PdfHeader&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.testName, testName) || other.testName == testName)&&(identical(other.templateLabel, templateLabel) || other.templateLabel == templateLabel)&&(identical(other.version, version) || other.version == version)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.doctorName, doctorName) || other.doctorName == doctorName)&&(identical(other.doctorFacilityName, doctorFacilityName) || other.doctorFacilityName == doctorFacilityName)&&(identical(other.signedByFacilityName, signedByFacilityName) || other.signedByFacilityName == signedByFacilityName)&&(identical(other.sampleCollectedAt, sampleCollectedAt) || other.sampleCollectedAt == sampleCollectedAt)&&(identical(other.sampleReceivedAt, sampleReceivedAt) || other.sampleReceivedAt == sampleReceivedAt)&&(identical(other.labAccessionNo, labAccessionNo) || other.labAccessionNo == labAccessionNo)&&(identical(other.releasedAtLabel, releasedAtLabel) || other.releasedAtLabel == releasedAtLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orderNumber,testName,templateLabel,version,stage,doctorName,doctorFacilityName,signedByFacilityName,sampleCollectedAt,sampleReceivedAt,labAccessionNo,releasedAtLabel);

@override
String toString() {
  return 'PdfHeader(orderNumber: $orderNumber, testName: $testName, templateLabel: $templateLabel, version: $version, stage: $stage, doctorName: $doctorName, doctorFacilityName: $doctorFacilityName, signedByFacilityName: $signedByFacilityName, sampleCollectedAt: $sampleCollectedAt, sampleReceivedAt: $sampleReceivedAt, labAccessionNo: $labAccessionNo, releasedAtLabel: $releasedAtLabel)';
}


}

/// @nodoc
abstract mixin class _$PdfHeaderCopyWith<$Res> implements $PdfHeaderCopyWith<$Res> {
  factory _$PdfHeaderCopyWith(_PdfHeader value, $Res Function(_PdfHeader) _then) = __$PdfHeaderCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'orderNumber') String orderNumber,@JsonKey(name: 'testName') String testName,@JsonKey(name: 'templateLabel') String templateLabel,@JsonKey(name: 'version') int version,@JsonKey(name: 'stage') String stage,@JsonKey(name: 'doctorName') String doctorName,@JsonKey(name: 'doctorFacilityName') String doctorFacilityName,@JsonKey(name: 'signedByFacilityName') String signedByFacilityName,@JsonKey(name: 'sampleCollectedAt') String sampleCollectedAt,@JsonKey(name: 'sampleReceivedAt') String sampleReceivedAt,@JsonKey(name: 'labAccessionNo') String labAccessionNo,@JsonKey(name: 'releasedAtLabel') String releasedAtLabel
});




}
/// @nodoc
class __$PdfHeaderCopyWithImpl<$Res>
    implements _$PdfHeaderCopyWith<$Res> {
  __$PdfHeaderCopyWithImpl(this._self, this._then);

  final _PdfHeader _self;
  final $Res Function(_PdfHeader) _then;

/// Create a copy of PdfHeader
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orderNumber = null,Object? testName = null,Object? templateLabel = null,Object? version = null,Object? stage = null,Object? doctorName = null,Object? doctorFacilityName = null,Object? signedByFacilityName = null,Object? sampleCollectedAt = null,Object? sampleReceivedAt = null,Object? labAccessionNo = null,Object? releasedAtLabel = null,}) {
  return _then(_PdfHeader(
orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,testName: null == testName ? _self.testName : testName // ignore: cast_nullable_to_non_nullable
as String,templateLabel: null == templateLabel ? _self.templateLabel : templateLabel // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as String,doctorName: null == doctorName ? _self.doctorName : doctorName // ignore: cast_nullable_to_non_nullable
as String,doctorFacilityName: null == doctorFacilityName ? _self.doctorFacilityName : doctorFacilityName // ignore: cast_nullable_to_non_nullable
as String,signedByFacilityName: null == signedByFacilityName ? _self.signedByFacilityName : signedByFacilityName // ignore: cast_nullable_to_non_nullable
as String,sampleCollectedAt: null == sampleCollectedAt ? _self.sampleCollectedAt : sampleCollectedAt // ignore: cast_nullable_to_non_nullable
as String,sampleReceivedAt: null == sampleReceivedAt ? _self.sampleReceivedAt : sampleReceivedAt // ignore: cast_nullable_to_non_nullable
as String,labAccessionNo: null == labAccessionNo ? _self.labAccessionNo : labAccessionNo // ignore: cast_nullable_to_non_nullable
as String,releasedAtLabel: null == releasedAtLabel ? _self.releasedAtLabel : releasedAtLabel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PdfSubject {

@JsonKey(name: 'displayName') String get displayName;@JsonKey(name: 'ageLabel') String get ageLabel;@JsonKey(name: 'sex') String get sex;@JsonKey(name: 'residence') String get residence;
/// Create a copy of PdfSubject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PdfSubjectCopyWith<PdfSubject> get copyWith => _$PdfSubjectCopyWithImpl<PdfSubject>(this as PdfSubject, _$identity);

  /// Serializes this PdfSubject to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PdfSubject&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.ageLabel, ageLabel) || other.ageLabel == ageLabel)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.residence, residence) || other.residence == residence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayName,ageLabel,sex,residence);

@override
String toString() {
  return 'PdfSubject(displayName: $displayName, ageLabel: $ageLabel, sex: $sex, residence: $residence)';
}


}

/// @nodoc
abstract mixin class $PdfSubjectCopyWith<$Res>  {
  factory $PdfSubjectCopyWith(PdfSubject value, $Res Function(PdfSubject) _then) = _$PdfSubjectCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'displayName') String displayName,@JsonKey(name: 'ageLabel') String ageLabel,@JsonKey(name: 'sex') String sex,@JsonKey(name: 'residence') String residence
});




}
/// @nodoc
class _$PdfSubjectCopyWithImpl<$Res>
    implements $PdfSubjectCopyWith<$Res> {
  _$PdfSubjectCopyWithImpl(this._self, this._then);

  final PdfSubject _self;
  final $Res Function(PdfSubject) _then;

/// Create a copy of PdfSubject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayName = null,Object? ageLabel = null,Object? sex = null,Object? residence = null,}) {
  return _then(_self.copyWith(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,ageLabel: null == ageLabel ? _self.ageLabel : ageLabel // ignore: cast_nullable_to_non_nullable
as String,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as String,residence: null == residence ? _self.residence : residence // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PdfSubject].
extension PdfSubjectPatterns on PdfSubject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PdfSubject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PdfSubject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PdfSubject value)  $default,){
final _that = this;
switch (_that) {
case _PdfSubject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PdfSubject value)?  $default,){
final _that = this;
switch (_that) {
case _PdfSubject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'displayName')  String displayName, @JsonKey(name: 'ageLabel')  String ageLabel, @JsonKey(name: 'sex')  String sex, @JsonKey(name: 'residence')  String residence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PdfSubject() when $default != null:
return $default(_that.displayName,_that.ageLabel,_that.sex,_that.residence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'displayName')  String displayName, @JsonKey(name: 'ageLabel')  String ageLabel, @JsonKey(name: 'sex')  String sex, @JsonKey(name: 'residence')  String residence)  $default,) {final _that = this;
switch (_that) {
case _PdfSubject():
return $default(_that.displayName,_that.ageLabel,_that.sex,_that.residence);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'displayName')  String displayName, @JsonKey(name: 'ageLabel')  String ageLabel, @JsonKey(name: 'sex')  String sex, @JsonKey(name: 'residence')  String residence)?  $default,) {final _that = this;
switch (_that) {
case _PdfSubject() when $default != null:
return $default(_that.displayName,_that.ageLabel,_that.sex,_that.residence);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PdfSubject extends PdfSubject {
  const _PdfSubject({@JsonKey(name: 'displayName') this.displayName = '', @JsonKey(name: 'ageLabel') this.ageLabel = '', @JsonKey(name: 'sex') this.sex = '', @JsonKey(name: 'residence') this.residence = ''}): super._();
  factory _PdfSubject.fromJson(Map<String, dynamic> json) => _$PdfSubjectFromJson(json);

@override@JsonKey(name: 'displayName') final  String displayName;
@override@JsonKey(name: 'ageLabel') final  String ageLabel;
@override@JsonKey(name: 'sex') final  String sex;
@override@JsonKey(name: 'residence') final  String residence;

/// Create a copy of PdfSubject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PdfSubjectCopyWith<_PdfSubject> get copyWith => __$PdfSubjectCopyWithImpl<_PdfSubject>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PdfSubjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PdfSubject&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.ageLabel, ageLabel) || other.ageLabel == ageLabel)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.residence, residence) || other.residence == residence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayName,ageLabel,sex,residence);

@override
String toString() {
  return 'PdfSubject(displayName: $displayName, ageLabel: $ageLabel, sex: $sex, residence: $residence)';
}


}

/// @nodoc
abstract mixin class _$PdfSubjectCopyWith<$Res> implements $PdfSubjectCopyWith<$Res> {
  factory _$PdfSubjectCopyWith(_PdfSubject value, $Res Function(_PdfSubject) _then) = __$PdfSubjectCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'displayName') String displayName,@JsonKey(name: 'ageLabel') String ageLabel,@JsonKey(name: 'sex') String sex,@JsonKey(name: 'residence') String residence
});




}
/// @nodoc
class __$PdfSubjectCopyWithImpl<$Res>
    implements _$PdfSubjectCopyWith<$Res> {
  __$PdfSubjectCopyWithImpl(this._self, this._then);

  final _PdfSubject _self;
  final $Res Function(_PdfSubject) _then;

/// Create a copy of PdfSubject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = null,Object? ageLabel = null,Object? sex = null,Object? residence = null,}) {
  return _then(_PdfSubject(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,ageLabel: null == ageLabel ? _self.ageLabel : ageLabel // ignore: cast_nullable_to_non_nullable
as String,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as String,residence: null == residence ? _self.residence : residence // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PdfSignature {

@JsonKey(name: 'title') String get title;@JsonKey(name: 'name') String get name;@JsonKey(name: 'kmpdcNumber') String get kmpdcNumber;@JsonKey(name: 'signedAtLabel') String get signedAtLabel;@JsonKey(name: 'contentRef') String get contentRef;@JsonKey(name: 'png') List<int> get png;
/// Create a copy of PdfSignature
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PdfSignatureCopyWith<PdfSignature> get copyWith => _$PdfSignatureCopyWithImpl<PdfSignature>(this as PdfSignature, _$identity);

  /// Serializes this PdfSignature to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PdfSignature&&(identical(other.title, title) || other.title == title)&&(identical(other.name, name) || other.name == name)&&(identical(other.kmpdcNumber, kmpdcNumber) || other.kmpdcNumber == kmpdcNumber)&&(identical(other.signedAtLabel, signedAtLabel) || other.signedAtLabel == signedAtLabel)&&(identical(other.contentRef, contentRef) || other.contentRef == contentRef)&&const DeepCollectionEquality().equals(other.png, png));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,name,kmpdcNumber,signedAtLabel,contentRef,const DeepCollectionEquality().hash(png));

@override
String toString() {
  return 'PdfSignature(title: $title, name: $name, kmpdcNumber: $kmpdcNumber, signedAtLabel: $signedAtLabel, contentRef: $contentRef, png: $png)';
}


}

/// @nodoc
abstract mixin class $PdfSignatureCopyWith<$Res>  {
  factory $PdfSignatureCopyWith(PdfSignature value, $Res Function(PdfSignature) _then) = _$PdfSignatureCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'title') String title,@JsonKey(name: 'name') String name,@JsonKey(name: 'kmpdcNumber') String kmpdcNumber,@JsonKey(name: 'signedAtLabel') String signedAtLabel,@JsonKey(name: 'contentRef') String contentRef,@JsonKey(name: 'png') List<int> png
});




}
/// @nodoc
class _$PdfSignatureCopyWithImpl<$Res>
    implements $PdfSignatureCopyWith<$Res> {
  _$PdfSignatureCopyWithImpl(this._self, this._then);

  final PdfSignature _self;
  final $Res Function(PdfSignature) _then;

/// Create a copy of PdfSignature
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? name = null,Object? kmpdcNumber = null,Object? signedAtLabel = null,Object? contentRef = null,Object? png = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kmpdcNumber: null == kmpdcNumber ? _self.kmpdcNumber : kmpdcNumber // ignore: cast_nullable_to_non_nullable
as String,signedAtLabel: null == signedAtLabel ? _self.signedAtLabel : signedAtLabel // ignore: cast_nullable_to_non_nullable
as String,contentRef: null == contentRef ? _self.contentRef : contentRef // ignore: cast_nullable_to_non_nullable
as String,png: null == png ? _self.png : png // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [PdfSignature].
extension PdfSignaturePatterns on PdfSignature {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PdfSignature value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PdfSignature() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PdfSignature value)  $default,){
final _that = this;
switch (_that) {
case _PdfSignature():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PdfSignature value)?  $default,){
final _that = this;
switch (_that) {
case _PdfSignature() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'title')  String title, @JsonKey(name: 'name')  String name, @JsonKey(name: 'kmpdcNumber')  String kmpdcNumber, @JsonKey(name: 'signedAtLabel')  String signedAtLabel, @JsonKey(name: 'contentRef')  String contentRef, @JsonKey(name: 'png')  List<int> png)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PdfSignature() when $default != null:
return $default(_that.title,_that.name,_that.kmpdcNumber,_that.signedAtLabel,_that.contentRef,_that.png);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'title')  String title, @JsonKey(name: 'name')  String name, @JsonKey(name: 'kmpdcNumber')  String kmpdcNumber, @JsonKey(name: 'signedAtLabel')  String signedAtLabel, @JsonKey(name: 'contentRef')  String contentRef, @JsonKey(name: 'png')  List<int> png)  $default,) {final _that = this;
switch (_that) {
case _PdfSignature():
return $default(_that.title,_that.name,_that.kmpdcNumber,_that.signedAtLabel,_that.contentRef,_that.png);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'title')  String title, @JsonKey(name: 'name')  String name, @JsonKey(name: 'kmpdcNumber')  String kmpdcNumber, @JsonKey(name: 'signedAtLabel')  String signedAtLabel, @JsonKey(name: 'contentRef')  String contentRef, @JsonKey(name: 'png')  List<int> png)?  $default,) {final _that = this;
switch (_that) {
case _PdfSignature() when $default != null:
return $default(_that.title,_that.name,_that.kmpdcNumber,_that.signedAtLabel,_that.contentRef,_that.png);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PdfSignature extends PdfSignature {
  const _PdfSignature({@JsonKey(name: 'title') this.title = '', @JsonKey(name: 'name') this.name = '', @JsonKey(name: 'kmpdcNumber') this.kmpdcNumber = '', @JsonKey(name: 'signedAtLabel') this.signedAtLabel = '', @JsonKey(name: 'contentRef') this.contentRef = '', @JsonKey(name: 'png') final  List<int> png = const <int>[]}): _png = png,super._();
  factory _PdfSignature.fromJson(Map<String, dynamic> json) => _$PdfSignatureFromJson(json);

@override@JsonKey(name: 'title') final  String title;
@override@JsonKey(name: 'name') final  String name;
@override@JsonKey(name: 'kmpdcNumber') final  String kmpdcNumber;
@override@JsonKey(name: 'signedAtLabel') final  String signedAtLabel;
@override@JsonKey(name: 'contentRef') final  String contentRef;
 final  List<int> _png;
@override@JsonKey(name: 'png') List<int> get png {
  if (_png is EqualUnmodifiableListView) return _png;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_png);
}


/// Create a copy of PdfSignature
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PdfSignatureCopyWith<_PdfSignature> get copyWith => __$PdfSignatureCopyWithImpl<_PdfSignature>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PdfSignatureToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PdfSignature&&(identical(other.title, title) || other.title == title)&&(identical(other.name, name) || other.name == name)&&(identical(other.kmpdcNumber, kmpdcNumber) || other.kmpdcNumber == kmpdcNumber)&&(identical(other.signedAtLabel, signedAtLabel) || other.signedAtLabel == signedAtLabel)&&(identical(other.contentRef, contentRef) || other.contentRef == contentRef)&&const DeepCollectionEquality().equals(other._png, _png));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,name,kmpdcNumber,signedAtLabel,contentRef,const DeepCollectionEquality().hash(_png));

@override
String toString() {
  return 'PdfSignature(title: $title, name: $name, kmpdcNumber: $kmpdcNumber, signedAtLabel: $signedAtLabel, contentRef: $contentRef, png: $png)';
}


}

/// @nodoc
abstract mixin class _$PdfSignatureCopyWith<$Res> implements $PdfSignatureCopyWith<$Res> {
  factory _$PdfSignatureCopyWith(_PdfSignature value, $Res Function(_PdfSignature) _then) = __$PdfSignatureCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'title') String title,@JsonKey(name: 'name') String name,@JsonKey(name: 'kmpdcNumber') String kmpdcNumber,@JsonKey(name: 'signedAtLabel') String signedAtLabel,@JsonKey(name: 'contentRef') String contentRef,@JsonKey(name: 'png') List<int> png
});




}
/// @nodoc
class __$PdfSignatureCopyWithImpl<$Res>
    implements _$PdfSignatureCopyWith<$Res> {
  __$PdfSignatureCopyWithImpl(this._self, this._then);

  final _PdfSignature _self;
  final $Res Function(_PdfSignature) _then;

/// Create a copy of PdfSignature
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? name = null,Object? kmpdcNumber = null,Object? signedAtLabel = null,Object? contentRef = null,Object? png = null,}) {
  return _then(_PdfSignature(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kmpdcNumber: null == kmpdcNumber ? _self.kmpdcNumber : kmpdcNumber // ignore: cast_nullable_to_non_nullable
as String,signedAtLabel: null == signedAtLabel ? _self.signedAtLabel : signedAtLabel // ignore: cast_nullable_to_non_nullable
as String,contentRef: null == contentRef ? _self.contentRef : contentRef // ignore: cast_nullable_to_non_nullable
as String,png: null == png ? _self._png : png // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}


/// @nodoc
mixin _$PdfFooter {

@JsonKey(name: 'patientName') String get patientName;@JsonKey(name: 'labAccessionNo') String get labAccessionNo;@JsonKey(name: 'pageLabel') String get pageLabel;@JsonKey(name: 'disclaimer') String get disclaimer;@JsonKey(name: 'supportContact') String get supportContact;
/// Create a copy of PdfFooter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PdfFooterCopyWith<PdfFooter> get copyWith => _$PdfFooterCopyWithImpl<PdfFooter>(this as PdfFooter, _$identity);

  /// Serializes this PdfFooter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PdfFooter&&(identical(other.patientName, patientName) || other.patientName == patientName)&&(identical(other.labAccessionNo, labAccessionNo) || other.labAccessionNo == labAccessionNo)&&(identical(other.pageLabel, pageLabel) || other.pageLabel == pageLabel)&&(identical(other.disclaimer, disclaimer) || other.disclaimer == disclaimer)&&(identical(other.supportContact, supportContact) || other.supportContact == supportContact));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,patientName,labAccessionNo,pageLabel,disclaimer,supportContact);

@override
String toString() {
  return 'PdfFooter(patientName: $patientName, labAccessionNo: $labAccessionNo, pageLabel: $pageLabel, disclaimer: $disclaimer, supportContact: $supportContact)';
}


}

/// @nodoc
abstract mixin class $PdfFooterCopyWith<$Res>  {
  factory $PdfFooterCopyWith(PdfFooter value, $Res Function(PdfFooter) _then) = _$PdfFooterCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'patientName') String patientName,@JsonKey(name: 'labAccessionNo') String labAccessionNo,@JsonKey(name: 'pageLabel') String pageLabel,@JsonKey(name: 'disclaimer') String disclaimer,@JsonKey(name: 'supportContact') String supportContact
});




}
/// @nodoc
class _$PdfFooterCopyWithImpl<$Res>
    implements $PdfFooterCopyWith<$Res> {
  _$PdfFooterCopyWithImpl(this._self, this._then);

  final PdfFooter _self;
  final $Res Function(PdfFooter) _then;

/// Create a copy of PdfFooter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? patientName = null,Object? labAccessionNo = null,Object? pageLabel = null,Object? disclaimer = null,Object? supportContact = null,}) {
  return _then(_self.copyWith(
patientName: null == patientName ? _self.patientName : patientName // ignore: cast_nullable_to_non_nullable
as String,labAccessionNo: null == labAccessionNo ? _self.labAccessionNo : labAccessionNo // ignore: cast_nullable_to_non_nullable
as String,pageLabel: null == pageLabel ? _self.pageLabel : pageLabel // ignore: cast_nullable_to_non_nullable
as String,disclaimer: null == disclaimer ? _self.disclaimer : disclaimer // ignore: cast_nullable_to_non_nullable
as String,supportContact: null == supportContact ? _self.supportContact : supportContact // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PdfFooter].
extension PdfFooterPatterns on PdfFooter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PdfFooter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PdfFooter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PdfFooter value)  $default,){
final _that = this;
switch (_that) {
case _PdfFooter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PdfFooter value)?  $default,){
final _that = this;
switch (_that) {
case _PdfFooter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'patientName')  String patientName, @JsonKey(name: 'labAccessionNo')  String labAccessionNo, @JsonKey(name: 'pageLabel')  String pageLabel, @JsonKey(name: 'disclaimer')  String disclaimer, @JsonKey(name: 'supportContact')  String supportContact)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PdfFooter() when $default != null:
return $default(_that.patientName,_that.labAccessionNo,_that.pageLabel,_that.disclaimer,_that.supportContact);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'patientName')  String patientName, @JsonKey(name: 'labAccessionNo')  String labAccessionNo, @JsonKey(name: 'pageLabel')  String pageLabel, @JsonKey(name: 'disclaimer')  String disclaimer, @JsonKey(name: 'supportContact')  String supportContact)  $default,) {final _that = this;
switch (_that) {
case _PdfFooter():
return $default(_that.patientName,_that.labAccessionNo,_that.pageLabel,_that.disclaimer,_that.supportContact);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'patientName')  String patientName, @JsonKey(name: 'labAccessionNo')  String labAccessionNo, @JsonKey(name: 'pageLabel')  String pageLabel, @JsonKey(name: 'disclaimer')  String disclaimer, @JsonKey(name: 'supportContact')  String supportContact)?  $default,) {final _that = this;
switch (_that) {
case _PdfFooter() when $default != null:
return $default(_that.patientName,_that.labAccessionNo,_that.pageLabel,_that.disclaimer,_that.supportContact);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PdfFooter extends PdfFooter {
  const _PdfFooter({@JsonKey(name: 'patientName') this.patientName = '', @JsonKey(name: 'labAccessionNo') this.labAccessionNo = '', @JsonKey(name: 'pageLabel') this.pageLabel = '', @JsonKey(name: 'disclaimer') this.disclaimer = '', @JsonKey(name: 'supportContact') this.supportContact = ''}): super._();
  factory _PdfFooter.fromJson(Map<String, dynamic> json) => _$PdfFooterFromJson(json);

@override@JsonKey(name: 'patientName') final  String patientName;
@override@JsonKey(name: 'labAccessionNo') final  String labAccessionNo;
@override@JsonKey(name: 'pageLabel') final  String pageLabel;
@override@JsonKey(name: 'disclaimer') final  String disclaimer;
@override@JsonKey(name: 'supportContact') final  String supportContact;

/// Create a copy of PdfFooter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PdfFooterCopyWith<_PdfFooter> get copyWith => __$PdfFooterCopyWithImpl<_PdfFooter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PdfFooterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PdfFooter&&(identical(other.patientName, patientName) || other.patientName == patientName)&&(identical(other.labAccessionNo, labAccessionNo) || other.labAccessionNo == labAccessionNo)&&(identical(other.pageLabel, pageLabel) || other.pageLabel == pageLabel)&&(identical(other.disclaimer, disclaimer) || other.disclaimer == disclaimer)&&(identical(other.supportContact, supportContact) || other.supportContact == supportContact));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,patientName,labAccessionNo,pageLabel,disclaimer,supportContact);

@override
String toString() {
  return 'PdfFooter(patientName: $patientName, labAccessionNo: $labAccessionNo, pageLabel: $pageLabel, disclaimer: $disclaimer, supportContact: $supportContact)';
}


}

/// @nodoc
abstract mixin class _$PdfFooterCopyWith<$Res> implements $PdfFooterCopyWith<$Res> {
  factory _$PdfFooterCopyWith(_PdfFooter value, $Res Function(_PdfFooter) _then) = __$PdfFooterCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'patientName') String patientName,@JsonKey(name: 'labAccessionNo') String labAccessionNo,@JsonKey(name: 'pageLabel') String pageLabel,@JsonKey(name: 'disclaimer') String disclaimer,@JsonKey(name: 'supportContact') String supportContact
});




}
/// @nodoc
class __$PdfFooterCopyWithImpl<$Res>
    implements _$PdfFooterCopyWith<$Res> {
  __$PdfFooterCopyWithImpl(this._self, this._then);

  final _PdfFooter _self;
  final $Res Function(_PdfFooter) _then;

/// Create a copy of PdfFooter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? patientName = null,Object? labAccessionNo = null,Object? pageLabel = null,Object? disclaimer = null,Object? supportContact = null,}) {
  return _then(_PdfFooter(
patientName: null == patientName ? _self.patientName : patientName // ignore: cast_nullable_to_non_nullable
as String,labAccessionNo: null == labAccessionNo ? _self.labAccessionNo : labAccessionNo // ignore: cast_nullable_to_non_nullable
as String,pageLabel: null == pageLabel ? _self.pageLabel : pageLabel // ignore: cast_nullable_to_non_nullable
as String,disclaimer: null == disclaimer ? _self.disclaimer : disclaimer // ignore: cast_nullable_to_non_nullable
as String,supportContact: null == supportContact ? _self.supportContact : supportContact // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ReportPdfInput {

@JsonKey(name: 'locale') String get locale;@JsonKey(name: 'viewerRole') String get viewerRole;@JsonKey(name: 'header') PdfHeader get header;@JsonKey(name: 'subject') PdfSubject get subject;@JsonKey(name: 'blocks') List<PdfBlock> get blocks;@JsonKey(name: 'measurements') List<String> get measurements;@JsonKey(name: 'addenda') List<String> get addenda;@JsonKey(name: 'amendmentReason') String get amendmentReason;@JsonKey(name: 'isCritical') bool get isCritical;@JsonKey(name: 'signature') PdfSignature get signature;@JsonKey(name: 'translation') Map<String, String> get translation;@JsonKey(name: 'watermark') String get watermark;@JsonKey(name: 'footer') PdfFooter get footer;@JsonKey(name: 'generatedAtLabel') String get generatedAtLabel;
/// Create a copy of ReportPdfInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportPdfInputCopyWith<ReportPdfInput> get copyWith => _$ReportPdfInputCopyWithImpl<ReportPdfInput>(this as ReportPdfInput, _$identity);

  /// Serializes this ReportPdfInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportPdfInput&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.viewerRole, viewerRole) || other.viewerRole == viewerRole)&&(identical(other.header, header) || other.header == header)&&(identical(other.subject, subject) || other.subject == subject)&&const DeepCollectionEquality().equals(other.blocks, blocks)&&const DeepCollectionEquality().equals(other.measurements, measurements)&&const DeepCollectionEquality().equals(other.addenda, addenda)&&(identical(other.amendmentReason, amendmentReason) || other.amendmentReason == amendmentReason)&&(identical(other.isCritical, isCritical) || other.isCritical == isCritical)&&(identical(other.signature, signature) || other.signature == signature)&&const DeepCollectionEquality().equals(other.translation, translation)&&(identical(other.watermark, watermark) || other.watermark == watermark)&&(identical(other.footer, footer) || other.footer == footer)&&(identical(other.generatedAtLabel, generatedAtLabel) || other.generatedAtLabel == generatedAtLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,locale,viewerRole,header,subject,const DeepCollectionEquality().hash(blocks),const DeepCollectionEquality().hash(measurements),const DeepCollectionEquality().hash(addenda),amendmentReason,isCritical,signature,const DeepCollectionEquality().hash(translation),watermark,footer,generatedAtLabel);

@override
String toString() {
  return 'ReportPdfInput(locale: $locale, viewerRole: $viewerRole, header: $header, subject: $subject, blocks: $blocks, measurements: $measurements, addenda: $addenda, amendmentReason: $amendmentReason, isCritical: $isCritical, signature: $signature, translation: $translation, watermark: $watermark, footer: $footer, generatedAtLabel: $generatedAtLabel)';
}


}

/// @nodoc
abstract mixin class $ReportPdfInputCopyWith<$Res>  {
  factory $ReportPdfInputCopyWith(ReportPdfInput value, $Res Function(ReportPdfInput) _then) = _$ReportPdfInputCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'locale') String locale,@JsonKey(name: 'viewerRole') String viewerRole,@JsonKey(name: 'header') PdfHeader header,@JsonKey(name: 'subject') PdfSubject subject,@JsonKey(name: 'blocks') List<PdfBlock> blocks,@JsonKey(name: 'measurements') List<String> measurements,@JsonKey(name: 'addenda') List<String> addenda,@JsonKey(name: 'amendmentReason') String amendmentReason,@JsonKey(name: 'isCritical') bool isCritical,@JsonKey(name: 'signature') PdfSignature signature,@JsonKey(name: 'translation') Map<String, String> translation,@JsonKey(name: 'watermark') String watermark,@JsonKey(name: 'footer') PdfFooter footer,@JsonKey(name: 'generatedAtLabel') String generatedAtLabel
});


$PdfHeaderCopyWith<$Res> get header;$PdfSubjectCopyWith<$Res> get subject;$PdfSignatureCopyWith<$Res> get signature;$PdfFooterCopyWith<$Res> get footer;

}
/// @nodoc
class _$ReportPdfInputCopyWithImpl<$Res>
    implements $ReportPdfInputCopyWith<$Res> {
  _$ReportPdfInputCopyWithImpl(this._self, this._then);

  final ReportPdfInput _self;
  final $Res Function(ReportPdfInput) _then;

/// Create a copy of ReportPdfInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locale = null,Object? viewerRole = null,Object? header = null,Object? subject = null,Object? blocks = null,Object? measurements = null,Object? addenda = null,Object? amendmentReason = null,Object? isCritical = null,Object? signature = null,Object? translation = null,Object? watermark = null,Object? footer = null,Object? generatedAtLabel = null,}) {
  return _then(_self.copyWith(
locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,viewerRole: null == viewerRole ? _self.viewerRole : viewerRole // ignore: cast_nullable_to_non_nullable
as String,header: null == header ? _self.header : header // ignore: cast_nullable_to_non_nullable
as PdfHeader,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as PdfSubject,blocks: null == blocks ? _self.blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<PdfBlock>,measurements: null == measurements ? _self.measurements : measurements // ignore: cast_nullable_to_non_nullable
as List<String>,addenda: null == addenda ? _self.addenda : addenda // ignore: cast_nullable_to_non_nullable
as List<String>,amendmentReason: null == amendmentReason ? _self.amendmentReason : amendmentReason // ignore: cast_nullable_to_non_nullable
as String,isCritical: null == isCritical ? _self.isCritical : isCritical // ignore: cast_nullable_to_non_nullable
as bool,signature: null == signature ? _self.signature : signature // ignore: cast_nullable_to_non_nullable
as PdfSignature,translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as Map<String, String>,watermark: null == watermark ? _self.watermark : watermark // ignore: cast_nullable_to_non_nullable
as String,footer: null == footer ? _self.footer : footer // ignore: cast_nullable_to_non_nullable
as PdfFooter,generatedAtLabel: null == generatedAtLabel ? _self.generatedAtLabel : generatedAtLabel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of ReportPdfInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PdfHeaderCopyWith<$Res> get header {
  
  return $PdfHeaderCopyWith<$Res>(_self.header, (value) {
    return _then(_self.copyWith(header: value));
  });
}/// Create a copy of ReportPdfInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PdfSubjectCopyWith<$Res> get subject {
  
  return $PdfSubjectCopyWith<$Res>(_self.subject, (value) {
    return _then(_self.copyWith(subject: value));
  });
}/// Create a copy of ReportPdfInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PdfSignatureCopyWith<$Res> get signature {
  
  return $PdfSignatureCopyWith<$Res>(_self.signature, (value) {
    return _then(_self.copyWith(signature: value));
  });
}/// Create a copy of ReportPdfInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PdfFooterCopyWith<$Res> get footer {
  
  return $PdfFooterCopyWith<$Res>(_self.footer, (value) {
    return _then(_self.copyWith(footer: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReportPdfInput].
extension ReportPdfInputPatterns on ReportPdfInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportPdfInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportPdfInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportPdfInput value)  $default,){
final _that = this;
switch (_that) {
case _ReportPdfInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportPdfInput value)?  $default,){
final _that = this;
switch (_that) {
case _ReportPdfInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'locale')  String locale, @JsonKey(name: 'viewerRole')  String viewerRole, @JsonKey(name: 'header')  PdfHeader header, @JsonKey(name: 'subject')  PdfSubject subject, @JsonKey(name: 'blocks')  List<PdfBlock> blocks, @JsonKey(name: 'measurements')  List<String> measurements, @JsonKey(name: 'addenda')  List<String> addenda, @JsonKey(name: 'amendmentReason')  String amendmentReason, @JsonKey(name: 'isCritical')  bool isCritical, @JsonKey(name: 'signature')  PdfSignature signature, @JsonKey(name: 'translation')  Map<String, String> translation, @JsonKey(name: 'watermark')  String watermark, @JsonKey(name: 'footer')  PdfFooter footer, @JsonKey(name: 'generatedAtLabel')  String generatedAtLabel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportPdfInput() when $default != null:
return $default(_that.locale,_that.viewerRole,_that.header,_that.subject,_that.blocks,_that.measurements,_that.addenda,_that.amendmentReason,_that.isCritical,_that.signature,_that.translation,_that.watermark,_that.footer,_that.generatedAtLabel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'locale')  String locale, @JsonKey(name: 'viewerRole')  String viewerRole, @JsonKey(name: 'header')  PdfHeader header, @JsonKey(name: 'subject')  PdfSubject subject, @JsonKey(name: 'blocks')  List<PdfBlock> blocks, @JsonKey(name: 'measurements')  List<String> measurements, @JsonKey(name: 'addenda')  List<String> addenda, @JsonKey(name: 'amendmentReason')  String amendmentReason, @JsonKey(name: 'isCritical')  bool isCritical, @JsonKey(name: 'signature')  PdfSignature signature, @JsonKey(name: 'translation')  Map<String, String> translation, @JsonKey(name: 'watermark')  String watermark, @JsonKey(name: 'footer')  PdfFooter footer, @JsonKey(name: 'generatedAtLabel')  String generatedAtLabel)  $default,) {final _that = this;
switch (_that) {
case _ReportPdfInput():
return $default(_that.locale,_that.viewerRole,_that.header,_that.subject,_that.blocks,_that.measurements,_that.addenda,_that.amendmentReason,_that.isCritical,_that.signature,_that.translation,_that.watermark,_that.footer,_that.generatedAtLabel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'locale')  String locale, @JsonKey(name: 'viewerRole')  String viewerRole, @JsonKey(name: 'header')  PdfHeader header, @JsonKey(name: 'subject')  PdfSubject subject, @JsonKey(name: 'blocks')  List<PdfBlock> blocks, @JsonKey(name: 'measurements')  List<String> measurements, @JsonKey(name: 'addenda')  List<String> addenda, @JsonKey(name: 'amendmentReason')  String amendmentReason, @JsonKey(name: 'isCritical')  bool isCritical, @JsonKey(name: 'signature')  PdfSignature signature, @JsonKey(name: 'translation')  Map<String, String> translation, @JsonKey(name: 'watermark')  String watermark, @JsonKey(name: 'footer')  PdfFooter footer, @JsonKey(name: 'generatedAtLabel')  String generatedAtLabel)?  $default,) {final _that = this;
switch (_that) {
case _ReportPdfInput() when $default != null:
return $default(_that.locale,_that.viewerRole,_that.header,_that.subject,_that.blocks,_that.measurements,_that.addenda,_that.amendmentReason,_that.isCritical,_that.signature,_that.translation,_that.watermark,_that.footer,_that.generatedAtLabel);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _ReportPdfInput extends ReportPdfInput {
  const _ReportPdfInput({@JsonKey(name: 'locale') this.locale = 'en', @JsonKey(name: 'viewerRole') this.viewerRole = '', @JsonKey(name: 'header') this.header = const PdfHeader(), @JsonKey(name: 'subject') this.subject = const PdfSubject(), @JsonKey(name: 'blocks') final  List<PdfBlock> blocks = const <PdfBlock>[], @JsonKey(name: 'measurements') final  List<String> measurements = const <String>[], @JsonKey(name: 'addenda') final  List<String> addenda = const <String>[], @JsonKey(name: 'amendmentReason') this.amendmentReason = '', @JsonKey(name: 'isCritical') this.isCritical = false, @JsonKey(name: 'signature') this.signature = const PdfSignature(), @JsonKey(name: 'translation') final  Map<String, String> translation = const <String, String>{}, @JsonKey(name: 'watermark') this.watermark = '', @JsonKey(name: 'footer') this.footer = const PdfFooter(), @JsonKey(name: 'generatedAtLabel') this.generatedAtLabel = ''}): _blocks = blocks,_measurements = measurements,_addenda = addenda,_translation = translation,super._();
  factory _ReportPdfInput.fromJson(Map<String, dynamic> json) => _$ReportPdfInputFromJson(json);

@override@JsonKey(name: 'locale') final  String locale;
@override@JsonKey(name: 'viewerRole') final  String viewerRole;
@override@JsonKey(name: 'header') final  PdfHeader header;
@override@JsonKey(name: 'subject') final  PdfSubject subject;
 final  List<PdfBlock> _blocks;
@override@JsonKey(name: 'blocks') List<PdfBlock> get blocks {
  if (_blocks is EqualUnmodifiableListView) return _blocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blocks);
}

 final  List<String> _measurements;
@override@JsonKey(name: 'measurements') List<String> get measurements {
  if (_measurements is EqualUnmodifiableListView) return _measurements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_measurements);
}

 final  List<String> _addenda;
@override@JsonKey(name: 'addenda') List<String> get addenda {
  if (_addenda is EqualUnmodifiableListView) return _addenda;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_addenda);
}

@override@JsonKey(name: 'amendmentReason') final  String amendmentReason;
@override@JsonKey(name: 'isCritical') final  bool isCritical;
@override@JsonKey(name: 'signature') final  PdfSignature signature;
 final  Map<String, String> _translation;
@override@JsonKey(name: 'translation') Map<String, String> get translation {
  if (_translation is EqualUnmodifiableMapView) return _translation;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_translation);
}

@override@JsonKey(name: 'watermark') final  String watermark;
@override@JsonKey(name: 'footer') final  PdfFooter footer;
@override@JsonKey(name: 'generatedAtLabel') final  String generatedAtLabel;

/// Create a copy of ReportPdfInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportPdfInputCopyWith<_ReportPdfInput> get copyWith => __$ReportPdfInputCopyWithImpl<_ReportPdfInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportPdfInputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportPdfInput&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.viewerRole, viewerRole) || other.viewerRole == viewerRole)&&(identical(other.header, header) || other.header == header)&&(identical(other.subject, subject) || other.subject == subject)&&const DeepCollectionEquality().equals(other._blocks, _blocks)&&const DeepCollectionEquality().equals(other._measurements, _measurements)&&const DeepCollectionEquality().equals(other._addenda, _addenda)&&(identical(other.amendmentReason, amendmentReason) || other.amendmentReason == amendmentReason)&&(identical(other.isCritical, isCritical) || other.isCritical == isCritical)&&(identical(other.signature, signature) || other.signature == signature)&&const DeepCollectionEquality().equals(other._translation, _translation)&&(identical(other.watermark, watermark) || other.watermark == watermark)&&(identical(other.footer, footer) || other.footer == footer)&&(identical(other.generatedAtLabel, generatedAtLabel) || other.generatedAtLabel == generatedAtLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,locale,viewerRole,header,subject,const DeepCollectionEquality().hash(_blocks),const DeepCollectionEquality().hash(_measurements),const DeepCollectionEquality().hash(_addenda),amendmentReason,isCritical,signature,const DeepCollectionEquality().hash(_translation),watermark,footer,generatedAtLabel);

@override
String toString() {
  return 'ReportPdfInput(locale: $locale, viewerRole: $viewerRole, header: $header, subject: $subject, blocks: $blocks, measurements: $measurements, addenda: $addenda, amendmentReason: $amendmentReason, isCritical: $isCritical, signature: $signature, translation: $translation, watermark: $watermark, footer: $footer, generatedAtLabel: $generatedAtLabel)';
}


}

/// @nodoc
abstract mixin class _$ReportPdfInputCopyWith<$Res> implements $ReportPdfInputCopyWith<$Res> {
  factory _$ReportPdfInputCopyWith(_ReportPdfInput value, $Res Function(_ReportPdfInput) _then) = __$ReportPdfInputCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'locale') String locale,@JsonKey(name: 'viewerRole') String viewerRole,@JsonKey(name: 'header') PdfHeader header,@JsonKey(name: 'subject') PdfSubject subject,@JsonKey(name: 'blocks') List<PdfBlock> blocks,@JsonKey(name: 'measurements') List<String> measurements,@JsonKey(name: 'addenda') List<String> addenda,@JsonKey(name: 'amendmentReason') String amendmentReason,@JsonKey(name: 'isCritical') bool isCritical,@JsonKey(name: 'signature') PdfSignature signature,@JsonKey(name: 'translation') Map<String, String> translation,@JsonKey(name: 'watermark') String watermark,@JsonKey(name: 'footer') PdfFooter footer,@JsonKey(name: 'generatedAtLabel') String generatedAtLabel
});


@override $PdfHeaderCopyWith<$Res> get header;@override $PdfSubjectCopyWith<$Res> get subject;@override $PdfSignatureCopyWith<$Res> get signature;@override $PdfFooterCopyWith<$Res> get footer;

}
/// @nodoc
class __$ReportPdfInputCopyWithImpl<$Res>
    implements _$ReportPdfInputCopyWith<$Res> {
  __$ReportPdfInputCopyWithImpl(this._self, this._then);

  final _ReportPdfInput _self;
  final $Res Function(_ReportPdfInput) _then;

/// Create a copy of ReportPdfInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locale = null,Object? viewerRole = null,Object? header = null,Object? subject = null,Object? blocks = null,Object? measurements = null,Object? addenda = null,Object? amendmentReason = null,Object? isCritical = null,Object? signature = null,Object? translation = null,Object? watermark = null,Object? footer = null,Object? generatedAtLabel = null,}) {
  return _then(_ReportPdfInput(
locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,viewerRole: null == viewerRole ? _self.viewerRole : viewerRole // ignore: cast_nullable_to_non_nullable
as String,header: null == header ? _self.header : header // ignore: cast_nullable_to_non_nullable
as PdfHeader,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as PdfSubject,blocks: null == blocks ? _self._blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<PdfBlock>,measurements: null == measurements ? _self._measurements : measurements // ignore: cast_nullable_to_non_nullable
as List<String>,addenda: null == addenda ? _self._addenda : addenda // ignore: cast_nullable_to_non_nullable
as List<String>,amendmentReason: null == amendmentReason ? _self.amendmentReason : amendmentReason // ignore: cast_nullable_to_non_nullable
as String,isCritical: null == isCritical ? _self.isCritical : isCritical // ignore: cast_nullable_to_non_nullable
as bool,signature: null == signature ? _self.signature : signature // ignore: cast_nullable_to_non_nullable
as PdfSignature,translation: null == translation ? _self._translation : translation // ignore: cast_nullable_to_non_nullable
as Map<String, String>,watermark: null == watermark ? _self.watermark : watermark // ignore: cast_nullable_to_non_nullable
as String,footer: null == footer ? _self.footer : footer // ignore: cast_nullable_to_non_nullable
as PdfFooter,generatedAtLabel: null == generatedAtLabel ? _self.generatedAtLabel : generatedAtLabel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of ReportPdfInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PdfHeaderCopyWith<$Res> get header {
  
  return $PdfHeaderCopyWith<$Res>(_self.header, (value) {
    return _then(_self.copyWith(header: value));
  });
}/// Create a copy of ReportPdfInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PdfSubjectCopyWith<$Res> get subject {
  
  return $PdfSubjectCopyWith<$Res>(_self.subject, (value) {
    return _then(_self.copyWith(subject: value));
  });
}/// Create a copy of ReportPdfInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PdfSignatureCopyWith<$Res> get signature {
  
  return $PdfSignatureCopyWith<$Res>(_self.signature, (value) {
    return _then(_self.copyWith(signature: value));
  });
}/// Create a copy of ReportPdfInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PdfFooterCopyWith<$Res> get footer {
  
  return $PdfFooterCopyWith<$Res>(_self.footer, (value) {
    return _then(_self.copyWith(footer: value));
  });
}
}

// dart format on
