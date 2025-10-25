import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet.dart';
import '../data/providers/statistics_provider.dart';

class PetStatisticsPage extends ConsumerWidget {
  const PetStatisticsPage({super.key, required this.pet});
  final Pet pet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(petStatisticsProvider(pet.id));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('統計情報'),
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text('統計情報の取得に失敗しました\n${error.toString()}', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.invalidate(petStatisticsProvider(pet.id)),
                  child: const Text('再試行'),
                ),
              ],
            ),
          ),
        ),
        data: (statistics) {
          if (statistics.totalLogs == 0) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('まだ記録がありません'),
                    SizedBox(height: 8),
                    Text('ログを追加すると統計情報が表示されます', 
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryCard(
                title: '記録の概要',
                items: [
                  _SummaryItem(label: '総記録数', value: '${statistics.totalLogs}件'),
                  if (statistics.oldestLog != null && statistics.newestLog != null)
                    _SummaryItem(
                      label: '記録期間',
                      value: '${_formatDate(statistics.oldestLog!)} 〜 ${_formatDate(statistics.newestLog!)}',
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTypeStatisticsCard(
                context,
                '散歩',
                Icons.directions_walk,
                Colors.blue,
                statistics.walkCount,
                statistics.lastWalk,
              ),
              const SizedBox(height: 12),
              _buildTypeStatisticsCard(
                context,
                'ごはん',
                Icons.restaurant,
                Colors.orange,
                statistics.feedCount,
                statistics.lastFeed,
              ),
              const SizedBox(height: 12),
              _buildTypeStatisticsCard(
                context,
                '病院',
                Icons.local_hospital,
                Colors.red,
                statistics.clinicCount,
                statistics.lastClinic,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTypeStatisticsCard(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    int count,
    DateTime? lastDate,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '記録数: $count回',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (lastDate != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '最終記録: ${_formatDateTime(lastDate.toLocal())}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ] else ...[
                    const SizedBox(height: 2),
                    Text(
                      '記録なし',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}/${dt.month}/${dt.day}';
  }

  String _formatDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}/${two(dt.month)}/${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.items,
  });

  final String title;
  final List<_SummaryItem> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    item.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem {
  const _SummaryItem({required this.label, required this.value});
  final String label;
  final String value;
}
