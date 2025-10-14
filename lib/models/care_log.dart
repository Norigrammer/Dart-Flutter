import 'package:freezed_annotation/freezed_annotation.dart';
import 'converters.dart';

part 'care_log.freezed.dart';
part 'care_log.g.dart';

enum CareLogType { walk, feed, clinic }

@freezed
abstract class CareLog with _$CareLog {
  const factory CareLog({
    required String id,
    required String petId,
    required CareLogType type,
    String? note,
    String? photoUrl,
    @TimestampConverter() required DateTime at,
    required String createdBy, // uid
    @TimestampConverter() required DateTime createdAt,
  }) = _CareLog;

  factory CareLog.fromJson(Map<String, dynamic> json) => _$CareLogFromJson(json);
}
