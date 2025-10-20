import 'package:flutter_test/flutter_test.dart';
import 'package:sample/models/pet_statistics.dart';
import 'package:sample/models/care_log.dart';

void main() {
  group('PetStatistics', () {
    test('should return empty statistics for empty logs list', () {
      final stats = PetStatistics.fromLogs([]);
      
      expect(stats.totalLogs, 0);
      expect(stats.walkCount, 0);
      expect(stats.feedCount, 0);
      expect(stats.clinicCount, 0);
      expect(stats.lastWalk, isNull);
      expect(stats.lastFeed, isNull);
      expect(stats.lastClinic, isNull);
      expect(stats.oldestLog, isNull);
      expect(stats.newestLog, isNull);
    });

    test('should calculate correct counts for different log types', () {
      final now = DateTime.now();
      final logs = [
        CareLog(
          id: '1',
          petId: 'pet1',
          type: CareLogType.walk,
          at: now.subtract(const Duration(days: 3)),
          createdBy: 'user1',
          createdAt: now,
        ),
        CareLog(
          id: '2',
          petId: 'pet1',
          type: CareLogType.walk,
          at: now.subtract(const Duration(days: 2)),
          createdBy: 'user1',
          createdAt: now,
        ),
        CareLog(
          id: '3',
          petId: 'pet1',
          type: CareLogType.feed,
          at: now.subtract(const Duration(days: 1)),
          createdBy: 'user1',
          createdAt: now,
        ),
        CareLog(
          id: '4',
          petId: 'pet1',
          type: CareLogType.clinic,
          at: now,
          createdBy: 'user1',
          createdAt: now,
        ),
      ];

      final stats = PetStatistics.fromLogs(logs);

      expect(stats.totalLogs, 4);
      expect(stats.walkCount, 2);
      expect(stats.feedCount, 1);
      expect(stats.clinicCount, 1);
    });

    test('should identify correct last dates for each log type', () {
      final now = DateTime.now();
      final oldWalkDate = now.subtract(const Duration(days: 5));
      final recentWalkDate = now.subtract(const Duration(days: 1));
      final feedDate = now.subtract(const Duration(days: 2));
      final clinicDate = now.subtract(const Duration(days: 3));

      final logs = [
        CareLog(
          id: '1',
          petId: 'pet1',
          type: CareLogType.walk,
          at: oldWalkDate,
          createdBy: 'user1',
          createdAt: now,
        ),
        CareLog(
          id: '2',
          petId: 'pet1',
          type: CareLogType.walk,
          at: recentWalkDate,
          createdBy: 'user1',
          createdAt: now,
        ),
        CareLog(
          id: '3',
          petId: 'pet1',
          type: CareLogType.feed,
          at: feedDate,
          createdBy: 'user1',
          createdAt: now,
        ),
        CareLog(
          id: '4',
          petId: 'pet1',
          type: CareLogType.clinic,
          at: clinicDate,
          createdBy: 'user1',
          createdAt: now,
        ),
      ];

      final stats = PetStatistics.fromLogs(logs);

      expect(stats.lastWalk, recentWalkDate);
      expect(stats.lastFeed, feedDate);
      expect(stats.lastClinic, clinicDate);
    });

    test('should identify oldest and newest logs', () {
      final now = DateTime.now();
      final oldest = now.subtract(const Duration(days: 10));
      final newest = now;

      final logs = [
        CareLog(
          id: '1',
          petId: 'pet1',
          type: CareLogType.walk,
          at: now.subtract(const Duration(days: 5)),
          createdBy: 'user1',
          createdAt: now,
        ),
        CareLog(
          id: '2',
          petId: 'pet1',
          type: CareLogType.feed,
          at: oldest,
          createdBy: 'user1',
          createdAt: now,
        ),
        CareLog(
          id: '3',
          petId: 'pet1',
          type: CareLogType.clinic,
          at: newest,
          createdBy: 'user1',
          createdAt: now,
        ),
      ];

      final stats = PetStatistics.fromLogs(logs);

      expect(stats.oldestLog, oldest);
      expect(stats.newestLog, newest);
    });

    test('getCountForType should return correct counts', () {
      final now = DateTime.now();
      final logs = [
        CareLog(
          id: '1',
          petId: 'pet1',
          type: CareLogType.walk,
          at: now,
          createdBy: 'user1',
          createdAt: now,
        ),
        CareLog(
          id: '2',
          petId: 'pet1',
          type: CareLogType.walk,
          at: now,
          createdBy: 'user1',
          createdAt: now,
        ),
        CareLog(
          id: '3',
          petId: 'pet1',
          type: CareLogType.feed,
          at: now,
          createdBy: 'user1',
          createdAt: now,
        ),
      ];

      final stats = PetStatistics.fromLogs(logs);

      expect(stats.getCountForType(CareLogType.walk), 2);
      expect(stats.getCountForType(CareLogType.feed), 1);
      expect(stats.getCountForType(CareLogType.clinic), 0);
    });

    test('getLastDateForType should return correct dates', () {
      final now = DateTime.now();
      final walkDate = now.subtract(const Duration(days: 1));
      final feedDate = now.subtract(const Duration(days: 2));

      final logs = [
        CareLog(
          id: '1',
          petId: 'pet1',
          type: CareLogType.walk,
          at: walkDate,
          createdBy: 'user1',
          createdAt: now,
        ),
        CareLog(
          id: '2',
          petId: 'pet1',
          type: CareLogType.feed,
          at: feedDate,
          createdBy: 'user1',
          createdAt: now,
        ),
      ];

      final stats = PetStatistics.fromLogs(logs);

      expect(stats.getLastDateForType(CareLogType.walk), walkDate);
      expect(stats.getLastDateForType(CareLogType.feed), feedDate);
      expect(stats.getLastDateForType(CareLogType.clinic), isNull);
    });
  });
}
