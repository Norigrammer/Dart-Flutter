import 'package:flutter_test/flutter_test.dart';
import 'package:sample/models/pet.dart';

void main() {
  group('Pet model', () {
    test('JSON roundtrip preserves fields', () {
      final now = DateTime.utc(2025, 1, 2, 3, 4, 5);
      final pet = Pet(
        id: 'p1',
        name: 'ポチ',
        members: const ['u1', 'u2'],
        photoUrl: null,
        createdAt: now,
        updatedAt: now,
      );

      final json = pet.toJson();
      final from = Pet.fromJson(json);

      expect(from.id, 'p1');
      expect(from.name, 'ポチ');
      expect(from.members, ['u1', 'u2']);
      expect(from.photoUrl, isNull);
      expect(from.createdAt.toUtc(), now);
      expect(from.updatedAt.toUtc(), now);
    });
  });
}
