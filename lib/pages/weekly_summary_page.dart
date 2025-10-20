import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet.dart';
import '../models/care_log.dart';
import '../data/repositories/care_log_repository.dart';

class WeeklySummaryPage extends ConsumerWidget {
  const WeeklySummaryPage({super.key, required this.pet});
  final Pet pet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(petLogsProvider(pet.id));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('週間サマリー'),
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text('週間サマリーの取得に失敗しました\n${error.toString()}', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.invalidate(petLogsProvider(pet.id)),
                  child: const Text('再試行'),
                ),
              ],
            ),
          ),
        ),
        data: (allLogs) {
          // Get logs from the last 7 days
          final now = DateTime.now();
          final sevenDaysAgo = now.subtract(const Duration(days: 6));
          final startOfDay = DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day);
          
          final weekLogs = allLogs.where((log) {
            final logDate = log.at.toLocal();
            return logDate.isAfter(startOfDay) || logDate.isAtSameMomentAs(startOfDay);
          }).toList();

          if (weekLogs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('過去7日間の記録がありません'),
                    SizedBox(height: 8),
                    Text('ログを追加すると週間サマリーが表示されます', 
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            );
          }

          // Group logs by day
          final logsByDay = <DateTime, List<CareLog>>{};
          for (final log in weekLogs) {
            final date = DateTime(
              log.at.toLocal().year,
              log.at.toLocal().month,
              log.at.toLocal().day,
            );
            logsByDay.putIfAbsent(date, () => []).add(log);
          }

          // Create list of last 7 days
          final days = List.generate(7, (index) {
            final date = now.subtract(Duration(days: 6 - index));
            return DateTime(date.year, date.month, date.day);
          });

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _WeeklySummaryCard(
                weekLogs: weekLogs,
                days: days,
              ),
              const SizedBox(height: 16),
              ...days.reversed.map((day) {
                final logs = logsByDay[day] ?? [];
                return _DayCard(
                  date: day,
                  logs: logs,
                  isToday: _isSameDay(day, now),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _WeeklySummaryCard extends StatelessWidget {
  const _WeeklySummaryCard({
    required this.weekLogs,
    required this.days,
  });

  final List<CareLog> weekLogs;
  final List<DateTime> days;

  @override
  Widget build(BuildContext context) {
    final walkCount = weekLogs.where((l) => l.type == CareLogType.walk).length;
    final feedCount = weekLogs.where((l) => l.type == CareLogType.feed).length;
    final clinicCount = weekLogs.where((l) => l.type == CareLogType.clinic).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '過去7日間の概要',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _CountBadge(
                  icon: Icons.directions_walk,
                  label: '散歩',
                  count: walkCount,
                  color: Colors.blue,
                ),
                _CountBadge(
                  icon: Icons.restaurant,
                  label: 'ごはん',
                  count: feedCount,
                  color: Colors.orange,
                ),
                _CountBadge(
                  icon: Icons.local_hospital,
                  label: '病院',
                  count: clinicCount,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          '$count回',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.date,
    required this.logs,
    required this.isToday,
  });

  final DateTime date;
  final List<CareLog> logs;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final walkCount = logs.where((l) => l.type == CareLogType.walk).length;
    final feedCount = logs.where((l) => l.type == CareLogType.feed).length;
    final clinicCount = logs.where((l) => l.type == CareLogType.clinic).length;

    final weekdayNames = ['月', '火', '水', '木', '金', '土', '日'];
    final weekday = weekdayNames[date.weekday - 1];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${date.month}/${date.day}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '$weekday${isToday ? "（今日）" : ""}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isToday ? Theme.of(context).colorScheme.primary : Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: logs.isEmpty
                  ? const Text(
                      '記録なし',
                      style: TextStyle(color: Colors.grey),
                    )
                  : Wrap(
                      spacing: 12,
                      children: [
                        if (walkCount > 0)
                          _LogTypeChip(
                            icon: Icons.directions_walk,
                            count: walkCount,
                            color: Colors.blue,
                          ),
                        if (feedCount > 0)
                          _LogTypeChip(
                            icon: Icons.restaurant,
                            count: feedCount,
                            color: Colors.orange,
                          ),
                        if (clinicCount > 0)
                          _LogTypeChip(
                            icon: Icons.local_hospital,
                            count: clinicCount,
                            color: Colors.red,
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogTypeChip extends StatelessWidget {
  const _LogTypeChip({
    required this.icon,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text('$count'),
      labelStyle: const TextStyle(fontSize: 12),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
