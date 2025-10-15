import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet.dart';
import '../models/care_log.dart';
import '../data/repositories/care_log_repository.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:image_picker/image_picker.dart';

class PetDetailPage extends ConsumerStatefulWidget {
  const PetDetailPage({super.key, required this.pet});
  final Pet pet;

  @override
  ConsumerState<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends ConsumerState<PetDetailPage> {
  Set<CareLogType> _selectedTypes = {};
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(petLogsProvider(widget.pet.id));
    return Scaffold(
      appBar: AppBar(title: Text(widget.pet.name)),
      body: Column(
        children: [
          _PetHeader(pet: widget.pet),
          _FilterBar(
            selectedTypes: _selectedTypes,
            range: _dateRange,
            onTypesChanged: (s) => setState(() => _selectedTypes = s),
            onRangeChanged: (r) => setState(() => _dateRange = r),
          ),
          const Divider(height: 0),
          Expanded(
            child: logsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => _ErrorView(error: e, onRetry: () => ref.invalidate(petLogsProvider(widget.pet.id))),
              data: (logs) {
                // クライアントサイドフィルター
                var filtered = logs;
                if (_selectedTypes.isNotEmpty) {
                  filtered = filtered.where((l) => _selectedTypes.contains(l.type)).toList();
                }
                if (_dateRange != null) {
                  final start = DateTime(_dateRange!.start.year, _dateRange!.start.month, _dateRange!.start.day);
                  final end = DateTime(_dateRange!.end.year, _dateRange!.end.month, _dateRange!.end.day, 23, 59, 59, 999);
                  filtered = filtered.where((l) {
                    final t = l.at.toLocal();
                    return !t.isBefore(start) && !t.isAfter(end);
                  }).toList();
                }
                if (filtered.isEmpty) return const _EmptyLogsView();
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (context, index) {
                    final log = filtered[index];
                    return ListTile(
                      leading: (log.photoUrl != null && log.photoUrl!.isNotEmpty)
                          ? CircleAvatar(backgroundImage: NetworkImage(log.photoUrl!))
                          : CircleAvatar(child: Icon(_iconOf(log.type))),
                      title: Text(_labelOf(log.type)),
                      subtitle: Text(_formatDateTime(log.at.toLocal()) + (log.note != null && log.note!.isNotEmpty ? "\n" + log.note! : "")),
                      isThreeLine: (log.note != null && log.note!.isNotEmpty),
                      trailing: PopupMenuButton<_LogAction>(
                        onSelected: (action) async {
                          switch (action) {
                            case _LogAction.edit:
                              await _showEditLogDialog(context, ref, widget.pet.id, log);
                              break;
                            case _LogAction.delete:
                              await _confirmDeleteLog(context, ref, widget.pet.id, log);
                              break;
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: _LogAction.edit, child: Text('編集')),
                          PopupMenuItem(value: _LogAction.delete, child: Text('削除')),
                        ],
                      ),
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
        onPressed: () => _showAddLogDialog(context, ref, widget.pet.id),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.selectedTypes,
    required this.range,
    required this.onTypesChanged,
    required this.onRangeChanged,
  });
  final Set<CareLogType> selectedTypes;
  final DateTimeRange? range;
  final ValueChanged<Set<CareLogType>> onTypesChanged;
  final ValueChanged<DateTimeRange?> onRangeChanged;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Wrap(
            spacing: 8,
            children: CareLogType.values.map((t) {
              final on = selectedTypes.contains(t);
              return FilterChip(
                label: Text(_labelOf(t)),
                selected: on,
                onSelected: (v) {
                  final set = <CareLogType>{...selectedTypes};
                  if (v) {
                    set.add(t);
                  } else {
                    set.remove(t);
                  }
                  onTypesChanged(set);
                },
              );
            }).toList(),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () async {
              final initial = range ?? DateTimeRange(start: DateTime.now().subtract(const Duration(days: 7)), end: DateTime.now());
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDateRange: initial,
              );
              if (picked != null) {
                onRangeChanged(picked);
              }
            },
            icon: const Icon(Icons.filter_list),
      label: Text(range == null
        ? '期間'
        : '${range!.start.month}/${range!.start.day} - ${range!.end.month}/${range!.end.day}'),
          ),
        ],
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
  Uint8List? pickedImageBytes;

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
              String? photoUrl;
              final logId = await repo.generateLogId(petId);
              if (pickedImageBytes != null) {
                photoUrl = await repo
                    .uploadLogPhoto(petId: petId, logId: logId, bytes: pickedImageBytes!)
                    .timeout(const Duration(seconds: 30));
              }
              await repo
                  .addLogWithId(
                    petId: petId,
                    id: logId,
                    type: type!,
                    at: at,
                    note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                    photoUrl: photoUrl,
                  )
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: loading
                            ? null
                            : () async {
                                final picked = await ImagePicker().pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 1600,
                                  imageQuality: 85,
                                );
                                if (picked != null) {
                                  pickedImageBytes = await picked.readAsBytes();
                                  setState(() {});
                                }
                              },
                        icon: const Icon(Icons.photo),
                        label: const Text('画像を選択'),
                      ),
                      const SizedBox(width: 12),
                      if (pickedImageBytes != null)
                        const Text('画像が選択されました', style: TextStyle(color: Colors.green)),
                    ],
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

enum _LogAction { edit, delete }

Future<void> _showEditLogDialog(BuildContext context, WidgetRef ref, String petId, CareLog log) async {
  final formKey = GlobalKey<FormState>();
  CareLogType? type = log.type;
  DateTime at = log.at.toLocal();
  final noteController = TextEditingController(text: log.note ?? '');
  bool loading = false;
  Uint8List? newImageBytes;
  bool removePhoto = false;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final repo = ref.read(careLogRepositoryProvider);
      return StatefulBuilder(builder: (context, setState) {
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

        Future<void> doUpdate() async {
          if (!formKey.currentState!.validate() || type == null) return;
          setState(() => loading = true);
          try {
            String? photoUrl;
            bool shouldRemove = removePhoto;
            if (newImageBytes != null) {
              if (log.photoUrl != null && log.photoUrl!.isNotEmpty) {
                try {
                  await repo.deleteLogPhoto(petId: petId, logId: log.id).timeout(const Duration(seconds: 15));
                } catch (_) {}
              }
              photoUrl = await repo
                  .uploadLogPhoto(petId: petId, logId: log.id, bytes: newImageBytes!)
                  .timeout(const Duration(seconds: 30));
              shouldRemove = false;
            }
            if (shouldRemove) {
              try {
                await repo.deleteLogPhoto(petId: petId, logId: log.id).timeout(const Duration(seconds: 15));
              } catch (_) {}
            }
            await repo
                .updateLog(
                  petId,
                  log,
                  type: type,
                  at: at,
                  note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                  photoUrl: photoUrl,
                  removePhoto: shouldRemove,
                )
                .timeout(const Duration(seconds: 15));
            if (dialogContext.mounted) Navigator.of(dialogContext).pop();
          } on TimeoutException {
            if (!dialogContext.mounted) return;
            ScaffoldMessenger.of(dialogContext).showSnackBar(
              const SnackBar(content: Text('更新がタイムアウトしました。ネットワーク接続や Firestore の状態を確認してください。')),
            );
            setState(() => loading = false);
          } on FirebaseException catch (e) {
            if (!dialogContext.mounted) return;
            var msg = '更新に失敗しました: ${e.message ?? e.code}';
            switch (e.code) {
              case 'permission-denied':
                msg = '更新に失敗しました: 権限がありません（Firestore ルールを確認してください）';
                break;
              case 'failed-precondition':
                msg = '更新に失敗しました: Firestore がまだ有効化されていない可能性があります（Firebase コンソールで作成してください）';
                break;
              case 'unavailable':
                msg = '更新に失敗しました: サービスに接続できません（回線状況を確認してください）';
                break;
            }
            ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(msg)));
            setState(() => loading = false);
          } catch (e) {
            if (!dialogContext.mounted) return;
            ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('更新に失敗しました: $e')));
            setState(() => loading = false);
          }
        }

        return AlertDialog(
          title: const Text('ログを編集'),
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
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: loading
                          ? null
                          : () async {
                              final picked = await ImagePicker().pickImage(
                                source: ImageSource.gallery,
                                maxWidth: 1600,
                                imageQuality: 85,
                              );
                              if (picked != null) {
                                newImageBytes = await picked.readAsBytes();
                                setState(() => removePhoto = false);
                              }
                            },
                      icon: const Icon(Icons.photo),
                      label: const Text('画像を選択'),
                    ),
                    const SizedBox(width: 12),
                    if (newImageBytes != null)
                      const Text('新しい画像が選択されました', style: TextStyle(color: Colors.green))
                    else if (log.photoUrl != null && log.photoUrl!.isNotEmpty && !removePhoto)
                      const Text('既存の画像があります'),
                    const Spacer(),
                    if ((log.photoUrl != null && log.photoUrl!.isNotEmpty) || newImageBytes != null)
                      TextButton.icon(
                        onPressed: loading
                            ? null
                            : () {
                                newImageBytes = null;
                                setState(() => removePhoto = true);
                              },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('画像を削除'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.of(dialogContext).pop(),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: loading ? null : doUpdate,
              child: loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('保存'),
            ),
          ],
        );
      });
    },
  );
}

Future<void> _confirmDeleteLog(BuildContext context, WidgetRef ref, String petId, CareLog log) async {
  bool loading = false;
  final repo = ref.read(careLogRepositoryProvider);
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> doDelete() async {
            setState(() => loading = true);
            try {
              await repo.deleteLog(petId, log).timeout(const Duration(seconds: 15));
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ログを削除しました')),
                );
              }
            } on TimeoutException {
              if (!dialogContext.mounted) return;
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(content: Text('削除がタイムアウトしました。ネットワーク接続や Firestore の状態を確認してください。')),
              );
              setState(() => loading = false);
            } on FirebaseException catch (e) {
              if (!dialogContext.mounted) return;
              var msg = '削除に失敗しました: ${e.message ?? e.code}';
              switch (e.code) {
                case 'permission-denied':
                  msg = '削除に失敗しました: 権限がありません（Firestore ルールを確認してください）';
                  break;
                case 'failed-precondition':
                  msg = '削除に失敗しました: Firestore がまだ有効化されていない可能性があります（Firebase コンソールで作成してください）';
                  break;
                case 'unavailable':
                  msg = '削除に失敗しました: サービスに接続できません（回線状況を確認してください）';
                  break;
              }
              ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(msg)));
              setState(() => loading = false);
            } catch (e) {
              if (!dialogContext.mounted) return;
              ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('削除に失敗しました: $e')));
              setState(() => loading = false);
            }
          }

          return AlertDialog(
            title: const Text('ログを削除しますか？'),
            content: const Text('この操作は取り消せません。'),
            actions: [
              TextButton(
                onPressed: loading ? null : () => Navigator.of(dialogContext).pop(),
                child: const Text('キャンセル'),
              ),
              FilledButton.tonal(
                onPressed: loading ? null : doDelete,
                child: loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('削除'),
              ),
            ],
          );
        },
      );
    },
  );
}
