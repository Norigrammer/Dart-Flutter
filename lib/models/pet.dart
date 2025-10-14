import 'package:freezed_annotation/freezed_annotation.dart';

part 'pet.freezed.dart';
part 'pet.g.dart';

@freezed
class Pet with _$Pet {
  const factory Pet({
    required String id,
    required String name,
    @Default([]) List<String> members, // user uids
    String? photoUrl,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _Pet;

  factory Pet.fromJson(Map<String, dynamic> json) => _$PetFromJson(json);
}

/// Firestore Timestamp <-> DateTime 変換
class TimestampConverter implements JsonConverter<DateTime, Object?> {
  const TimestampConverter();
  @override
  DateTime fromJson(Object? json) {
    if (json == null) return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    if (json is DateTime) return json.toUtc();
    // Firestore Timestamp は package:cloud_firestore の型だが直接依存避けるため dynamic として処理
    final dynamic v = json;
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
