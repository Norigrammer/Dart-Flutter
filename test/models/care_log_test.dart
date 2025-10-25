import 'package:flutter_test/flutter_test.dart';
import 'package:sample/models/care_log.dart';

void main() {
  group('CareLog model', () {
    test('JSON roundtrip preserves fields', () {
      final now = DateTime.utc(2025, 1, 2, 3, 4, 5);
      final log = CareLog(
        id: 'l1',
        petId: 'p1',
        type: CareLogType.walk,
        note: 'evening walk',
        photoUrl: null,
        at: now,
        createdBy: 'u1',
        createdAt: now,
      );

      final json = log.toJson();
      final from = CareLog.fromJson(json);

      expect(from.id, 'l1');
      expect(from.petId, 'p1');
      expect(from.type, CareLogType.walk);
      expect(from.note, 'evening walk');
      expect(from.photoUrl, isNull);
      expect(from.at.toUtc(), now);
      expect(from.createdBy, 'u1');
      expect(from.createdAt.toUtc(), now);
    });
  });
}
