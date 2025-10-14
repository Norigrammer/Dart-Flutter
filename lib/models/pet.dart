import 'package:freezed_annotation/freezed_annotation.dart';
import 'converters.dart';

part 'pet.freezed.dart';
part 'pet.g.dart';

@freezed
abstract class Pet with _$Pet {
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
// TimestampConverter は converters.dart へ抽出
