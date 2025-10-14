// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'care_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CareLog {

 String get id; String get petId; CareLogType get type; String? get note; String? get photoUrl;@TimestampConverter() DateTime get at; String get createdBy;// uid
@TimestampConverter() DateTime get createdAt;
/// Create a copy of CareLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CareLogCopyWith<CareLog> get copyWith => _$CareLogCopyWithImpl<CareLog>(this as CareLog, _$identity);

  /// Serializes this CareLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CareLog&&(identical(other.id, id) || other.id == id)&&(identical(other.petId, petId) || other.petId == petId)&&(identical(other.type, type) || other.type == type)&&(identical(other.note, note) || other.note == note)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.at, at) || other.at == at)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,petId,type,note,photoUrl,at,createdBy,createdAt);

@override
String toString() {
  return 'CareLog(id: $id, petId: $petId, type: $type, note: $note, photoUrl: $photoUrl, at: $at, createdBy: $createdBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CareLogCopyWith<$Res>  {
  factory $CareLogCopyWith(CareLog value, $Res Function(CareLog) _then) = _$CareLogCopyWithImpl;
@useResult
$Res call({
 String id, String petId, CareLogType type, String? note, String? photoUrl,@TimestampConverter() DateTime at, String createdBy,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$CareLogCopyWithImpl<$Res>
    implements $CareLogCopyWith<$Res> {
  _$CareLogCopyWithImpl(this._self, this._then);

  final CareLog _self;
  final $Res Function(CareLog) _then;

/// Create a copy of CareLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? petId = null,Object? type = null,Object? note = freezed,Object? photoUrl = freezed,Object? at = null,Object? createdBy = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,petId: null == petId ? _self.petId : petId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CareLogType,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CareLog].
extension CareLogPatterns on CareLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CareLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CareLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CareLog value)  $default,){
final _that = this;
switch (_that) {
case _CareLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CareLog value)?  $default,){
final _that = this;
switch (_that) {
case _CareLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String petId,  CareLogType type,  String? note,  String? photoUrl, @TimestampConverter()  DateTime at,  String createdBy, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CareLog() when $default != null:
return $default(_that.id,_that.petId,_that.type,_that.note,_that.photoUrl,_that.at,_that.createdBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String petId,  CareLogType type,  String? note,  String? photoUrl, @TimestampConverter()  DateTime at,  String createdBy, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _CareLog():
return $default(_that.id,_that.petId,_that.type,_that.note,_that.photoUrl,_that.at,_that.createdBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String petId,  CareLogType type,  String? note,  String? photoUrl, @TimestampConverter()  DateTime at,  String createdBy, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CareLog() when $default != null:
return $default(_that.id,_that.petId,_that.type,_that.note,_that.photoUrl,_that.at,_that.createdBy,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CareLog implements CareLog {
  const _CareLog({required this.id, required this.petId, required this.type, this.note, this.photoUrl, @TimestampConverter() required this.at, required this.createdBy, @TimestampConverter() required this.createdAt});
  factory _CareLog.fromJson(Map<String, dynamic> json) => _$CareLogFromJson(json);

@override final  String id;
@override final  String petId;
@override final  CareLogType type;
@override final  String? note;
@override final  String? photoUrl;
@override@TimestampConverter() final  DateTime at;
@override final  String createdBy;
// uid
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of CareLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CareLogCopyWith<_CareLog> get copyWith => __$CareLogCopyWithImpl<_CareLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CareLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CareLog&&(identical(other.id, id) || other.id == id)&&(identical(other.petId, petId) || other.petId == petId)&&(identical(other.type, type) || other.type == type)&&(identical(other.note, note) || other.note == note)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.at, at) || other.at == at)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,petId,type,note,photoUrl,at,createdBy,createdAt);

@override
String toString() {
  return 'CareLog(id: $id, petId: $petId, type: $type, note: $note, photoUrl: $photoUrl, at: $at, createdBy: $createdBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CareLogCopyWith<$Res> implements $CareLogCopyWith<$Res> {
  factory _$CareLogCopyWith(_CareLog value, $Res Function(_CareLog) _then) = __$CareLogCopyWithImpl;
@override @useResult
$Res call({
 String id, String petId, CareLogType type, String? note, String? photoUrl,@TimestampConverter() DateTime at, String createdBy,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$CareLogCopyWithImpl<$Res>
    implements _$CareLogCopyWith<$Res> {
  __$CareLogCopyWithImpl(this._self, this._then);

  final _CareLog _self;
  final $Res Function(_CareLog) _then;

/// Create a copy of CareLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? petId = null,Object? type = null,Object? note = freezed,Object? photoUrl = freezed,Object? at = null,Object? createdBy = null,Object? createdAt = null,}) {
  return _then(_CareLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,petId: null == petId ? _self.petId : petId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CareLogType,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
