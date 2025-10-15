import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet.dart';
import '../models/care_log.dart';
import '../data/repositories/care_log_repository.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseException;

class PetDetailPage extends ConsumerWidget {
  const PetDetailPage({super.key, required this.pet});
  final Pet pet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(petLogsProvider(pet.id));
    return Scaffold(
      appBar: AppBar(title: Text(pet.name)),
      body: Column(
        children: [
          _PetHeader(pet: pet),
          const Divider(height: 0),
          Expanded(
            child: logsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => _ErrorView(error: e, onRetry: () => ref.invalidate(petLogsProvider(pet.id))),
              data: (logs) {
                if (logs.isEmpty) return const _EmptyLogsView();
                return ListView.separated(
                  itemCount: logs.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return ListTile(
                      leading: CircleAvatar(child: Icon(_iconOf(log.type))),
                      title: Text(_labelOf(log.type)),
                      subtitle: Text(_formatDateTime(log.at.toLocal()) + (log.note != null && log.note!.isNotEmpty ? "\n" + log.note! : "")),
                      isThreeLine: (log.note != null && log.note!.isNotEmpty),
                      // onTap: () { // 編集などは後続で }
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'ログを追加',
        onPressed: () => _showAddLogDialog(context, ref, pet.id),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PetHeader extends StatelessWidget {
  const _PetHeader({required this.pet});
  final Pet pet;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.pets)),
      title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('メンバー: ${pet.members.length}人'),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final Object error;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            Text('ログの取得に失敗しました\n${error.toString()}', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: onRetry, child: const Text('再試行')),
          ],
        ),
      ),
    );
  }
}

class _EmptyLogsView extends StatelessWidget {
  const _EmptyLogsView();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.note_add, size: 64),
            SizedBox(height: 16),
            Text('まだログがありません'),
            SizedBox(height: 8),
            Text('右下の + から追加できます', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

Future<void> _showAddLogDialog(BuildContext context, WidgetRef ref, String petId) async {
  final formKey = GlobalKey<FormState>();
  CareLogType? type = CareLogType.walk;
  DateTime at = DateTime.now();
  final noteController = TextEditingController();
  bool loading = false;

  await showDialog<void>(
    context: context,
    builder: (context) {
      final repo = ref.read(careLogRepositoryProvider);
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> pickDateTime() async {
            final date = await showDatePicker(
              context: context,
              initialDate: at,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date == null) return;
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(at),
            );
            if (time == null) return;
            setState(() {
              at = DateTime(date.year, date.month, date.day, time.hour, time.minute);
            });
          }

          Future<void> doAdd() async {
            if (!formKey.currentState!.validate() || type == null) return;
            setState(() => loading = true);
            try {
              await repo
                  .addLog(petId: petId, type: type!, at: at, note: noteController.text.trim().isEmpty ? null : noteController.text.trim())
                  .timeout(const Duration(seconds: 15));
              if (context.mounted) Navigator.of(context).pop();
            } on TimeoutException {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('追加がタイムアウトしました。ネットワーク接続や Firestore の状態を確認してください。')),
              );
              setState(() => loading = false);
            } on FirebaseException catch (e) {
              if (!context.mounted) return;
              var msg = '追加に失敗しました: ${e.message ?? e.code}';
              switch (e.code) {
                case 'permission-denied':
                  msg = '追加に失敗しました: 権限がありません（Firestore ルールを確認してください）';
                  break;
                case 'failed-precondition':
                  msg = '追加に失敗しました: Firestore がまだ有効化されていない可能性があります（Firebase コンソールで作成してください）';
                  break;
                case 'unavailable':
                  msg = '追加に失敗しました: サービスに接続できません（回線状況を確認してください）';
                  break;
              }
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
              setState(() => loading = false);
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('追加に失敗しました: $e')));
              setState(() => loading = false);
            }
          }

          return AlertDialog(
            title: const Text('ログを追加'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<CareLogType>(
                    value: type,
                    items: CareLogType.values
                        .map((t) => DropdownMenuItem(value: t, child: Text(_labelOf(t))))
                        .toList(),
                    onChanged: loading ? null : (v) => setState(() => type = v),
                    decoration: const InputDecoration(labelText: '種類'),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: loading ? null : pickDateTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: '日時'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDateTime(at)),
                          const Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: noteController,
                    enabled: !loading,
                    decoration: const InputDecoration(labelText: 'メモ（任意）'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: loading ? null : () => Navigator.of(context).pop(),
                child: const Text('キャンセル'),
              ),
              FilledButton(
                onPressed: loading ? null : doAdd,
                child: loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('追加'),
              ),
            ],
          );
        },
      );
    },
  );
}

String _formatDateTime(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
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
