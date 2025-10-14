import 'package:freezed_annotation/freezed_annotation.dart';

/// Firestore Timestamp <-> DateTime 変換
class TimestampConverter implements JsonConverter<DateTime, Object?> {
  const TimestampConverter();
  @override
  DateTime fromJson(Object? json) {
    if (json == null) return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    if (json is DateTime) return json.toUtc();
    final dynamic v = json; // Firestore Timestamp / Map / String など
    if (v is Map && v['_seconds'] != null) {
      final seconds = v['_seconds'] as int; // emulator serialization fallback
      final nanos = (v['_nanoseconds'] as int?) ?? 0;
      return DateTime.fromMillisecondsSinceEpoch(seconds * 1000 + nanos ~/ 1000000, isUtc: true);
    }
    return DateTime.tryParse(v.toString()) ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
  @override
  Object toJson(DateTime date) => date.toUtc();
}
