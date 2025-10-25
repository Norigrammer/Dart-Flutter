import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet.dart';
import '../models/care_log.dart';
import '../data/repositories/care_log_repository.dart';

class LogSearchPage extends ConsumerStatefulWidget {
  const LogSearchPage({super.key, required this.pet});
  final Pet pet;

  @override
  ConsumerState<LogSearchPage> createState() => _LogSearchPageState();
}

class _LogSearchPageState extends ConsumerState<LogSearchPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(petLogsProvider(widget.pet.id));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'メモを検索...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase().trim();
            });
          },
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'クリア',
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
        ],
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
                Text('ログの取得に失敗しました\n${error.toString()}', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.invalidate(petLogsProvider(widget.pet.id)),
                  child: const Text('再試行'),
                ),
              ],
            ),
          ),
        ),
        data: (allLogs) {
          if (_searchQuery.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('検索ワードを入力してください'),
                    SizedBox(height: 8),
                    Text('メモの内容から検索できます', 
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            );
          }

          // Filter logs based on search query
          final filteredLogs = allLogs.where((log) {
            if (log.note == null || log.note!.isEmpty) return false;
            return log.note!.toLowerCase().contains(_searchQuery);
          }).toList();

          if (filteredLogs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('「$_searchQuery」に一致する記録が見つかりませんでした'),
                    const SizedBox(height: 8),
                    const Text('別のキーワードで試してください', 
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '${filteredLogs.length}件の記録が見つかりました',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: filteredLogs.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (context, index) {
                    final log = filteredLogs[index];
                    return ListTile(
                      leading: CircleAvatar(child: Icon(_iconOf(log.type))),
                      title: Text(_labelOf(log.type)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_formatDateTime(log.at.toLocal())),
                          if (log.note != null && log.note!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                log.note!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.normal),
                              ),
                            ),
                        ],
                      ),
                      isThreeLine: true,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}/${two(dt.month)}/${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }

  IconData _iconOf(CareLogType type) {
    switch (type) {
      case CareLogType.walk:
        return Icons.directions_walk;
      case CareLogType.feed:
        return Icons.restaurant;
      case CareLogType.clinic:
        return Icons.local_hospital;
    }
  }

  String _labelOf(CareLogType type) {
    switch (type) {
      case CareLogType.walk:
        return '散歩';
      case CareLogType.feed:
        return 'ごはん';
      case CareLogType.clinic:
        return '病院';
    }
  }
}
