// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'care_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CareLog _$CareLogFromJson(Map<String, dynamic> json) => _CareLog(
  id: json['id'] as String,
  petId: json['petId'] as String,
  type: $enumDecode(_$CareLogTypeEnumMap, json['type']),
  note: json['note'] as String?,
  photoUrl: json['photoUrl'] as String?,
  at: const TimestampConverter().fromJson(json['at']),
  createdBy: json['createdBy'] as String,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$CareLogToJson(_CareLog instance) => <String, dynamic>{
  'id': instance.id,
  'petId': instance.petId,
  'type': _$CareLogTypeEnumMap[instance.type]!,
  'note': instance.note,
  'photoUrl': instance.photoUrl,
  'at': const TimestampConverter().toJson(instance.at),
  'createdBy': instance.createdBy,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
};

const _$CareLogTypeEnumMap = {
  CareLogType.walk: 'walk',
  CareLogType.feed: 'feed',
  CareLogType.clinic: 'clinic',
};
