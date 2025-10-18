import 'care_log.dart';

/// Statistics calculated from pet care logs
class PetStatistics {
  const PetStatistics({
    required this.totalLogs,
    required this.walkCount,
    required this.feedCount,
    required this.clinicCount,
    this.lastWalk,
    this.lastFeed,
    this.lastClinic,
    this.oldestLog,
    this.newestLog,
  });

  final int totalLogs;
  final int walkCount;
  final int feedCount;
  final int clinicCount;
  final DateTime? lastWalk;
  final DateTime? lastFeed;
  final DateTime? lastClinic;
  final DateTime? oldestLog;
  final DateTime? newestLog;

  /// Calculate statistics from a list of care logs
  factory PetStatistics.fromLogs(List<CareLog> logs) {
    if (logs.isEmpty) {
      return const PetStatistics(
        totalLogs: 0,
        walkCount: 0,
        feedCount: 0,
        clinicCount: 0,
      );
    }

    int walkCount = 0;
    int feedCount = 0;
    int clinicCount = 0;
    DateTime? lastWalk;
    DateTime? lastFeed;
    DateTime? lastClinic;

    for (final log in logs) {
      switch (log.type) {
        case CareLogType.walk:
          walkCount++;
          if (lastWalk == null || log.at.isAfter(lastWalk)) {
            lastWalk = log.at;
          }
          break;
        case CareLogType.feed:
          feedCount++;
          if (lastFeed == null || log.at.isAfter(lastFeed)) {
            lastFeed = log.at;
          }
          break;
        case CareLogType.clinic:
          clinicCount++;
          if (lastClinic == null || log.at.isAfter(lastClinic)) {
            lastClinic = log.at;
          }
          break;
      }
    }

    // Find oldest and newest logs
    final sorted = [...logs]..sort((a, b) => a.at.compareTo(b.at));
    final oldest = sorted.first.at;
    final newest = sorted.last.at;

    return PetStatistics(
      totalLogs: logs.length,
      walkCount: walkCount,
      feedCount: feedCount,
      clinicCount: clinicCount,
      lastWalk: lastWalk,
      lastFeed: lastFeed,
      lastClinic: lastClinic,
      oldestLog: oldest,
      newestLog: newest,
    );
  }

  /// Get count for a specific log type
  int getCountForType(CareLogType type) {
    switch (type) {
      case CareLogType.walk:
        return walkCount;
      case CareLogType.feed:
        return feedCount;
      case CareLogType.clinic:
        return clinicCount;
    }
  }

  /// Get last date for a specific log type
  DateTime? getLastDateForType(CareLogType type) {
    switch (type) {
      case CareLogType.walk:
        return lastWalk;
      case CareLogType.feed:
        return lastFeed;
      case CareLogType.clinic:
        return lastClinic;
    }
  }
}

