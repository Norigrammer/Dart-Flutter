import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/auth_controller.dart';
import '../data/repositories/pet_repository.dart';
import 'package:go_router/go_router.dart';
import '../models/pet.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.read(authControllerProvider.notifier);
    final petsAsync = ref.watch(myPetsStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('ペット一覧'),
        actions: [
          IconButton(
            tooltip: 'サインアウト',
            onPressed: () async {
              await auth.signOut();
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: petsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text('読み込みでエラーが発生しました\n${e.toString()}', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.invalidate(myPetsStreamProvider),
                  child: const Text('再試行'),
                )
              ],
            ),
          ),
        ),
        data: (pets) {
          if (pets.isEmpty) {
            return const _EmptyPetsView();
          }
            return ListView.separated(
              itemCount: pets.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (context, index) {
                final pet = pets[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.pets)),
                  title: Text(pet.name),
                  subtitle: Text('メンバー: ${pet.members.length}人'),
                  onTap: () {
                    context.push('/pets/${pet.id}', extra: pet);
                  },
                  trailing: PopupMenuButton<_PetAction>(
                    onSelected: (action) async {
                      switch (action) {
                        case _PetAction.edit:
                          await _showEditPetDialog(context, ref, pet);
                          break;
                        case _PetAction.delete:
                          await _confirmDeletePet(context, ref, pet);
                          break;
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: _PetAction.edit, child: Text('名前を編集')),
                      const PopupMenuItem(value: _PetAction.delete, child: Text('削除')),
                    ],
                  ),
                );
              },
            );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'ペットを追加',
        onPressed: () async {
          await _showAddPetDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyPetsView extends StatelessWidget {
  const _EmptyPetsView();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            const Text('まだペットが登録されていません'),
            const SizedBox(height: 8),
            const Text('右下の + ボタンから追加できます', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

enum _PetAction { edit, delete }

Future<void> _showAddPetDialog(BuildContext context, WidgetRef ref) async {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  bool loading = false;

  await showDialog<void>(
    context: context,
    builder: (context) {
      final repo = ref.read(petRepositoryProvider);
      return StatefulBuilder(builder: (context, setState) {
        Future<void> doCreate() async {
          if (!formKey.currentState!.validate()) return;
          setState(() => loading = true);
          try {
            await repo
                .createPet(name: nameController.text.trim())
                .timeout(const Duration(seconds: 15));
            if (context.mounted) Navigator.of(context).pop();
          } on TimeoutException {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('作成がタイムアウトしました。ネットワーク接続や Firestore が有効化されているか確認してください。')),
            );
            setState(() => loading = false);
          } on FirebaseException catch (e) {
            if (!context.mounted) return;
            var msg = '作成に失敗しました: ${e.message ?? e.code}';
            switch (e.code) {
              case 'permission-denied':
                msg = '作成に失敗しました: 権限がありません（Firestore ルールを確認してください）';
                break;
              case 'failed-precondition':
                msg = '作成に失敗しました: Firestore がまだ有効化されていない可能性があります（Firebase コンソールで作成してください）';
                break;
              case 'unavailable':
                msg = '作成に失敗しました: サービスに接続できません（回線状況を確認してください）';
                break;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg)),
            );
            setState(() => loading = false);
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('作成に失敗しました: $e')),
            );
            setState(() => loading = false);
          }
        }
        return AlertDialog(
          title: const Text('ペットを追加'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              enabled: !loading,
              decoration: const InputDecoration(
                labelText: '名前',
                hintText: '例: ポチ',
              ),
              autofillHints: const [AutofillHints.name],
              enableSuggestions: false,
              autocorrect: false,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return '名前を入力してください';
                if (v.trim().length > 30) return '30文字以内で入力してください';
                return null;
              },
              autofocus: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: loading ? null : doCreate,
              child: loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('追加'),
            ),
          ],
        );
      });
    },
  );
}

Future<void> _showEditPetDialog(BuildContext context, WidgetRef ref, Pet pet) async {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: pet.name);
  bool loading = false;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final repo = ref.read(petRepositoryProvider);
      return StatefulBuilder(builder: (context, setState) {
        Future<void> doUpdate() async {
          if (!formKey.currentState!.validate()) return;
          setState(() => loading = true);
          final newName = nameController.text.trim();
          try {
            await repo
                .updatePet(pet, name: newName)
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
            ScaffoldMessenger.of(dialogContext).showSnackBar(
              SnackBar(content: Text(msg)),
            );
            setState(() => loading = false);
          } catch (e) {
            if (!dialogContext.mounted) return;
            ScaffoldMessenger.of(dialogContext).showSnackBar(
              SnackBar(content: Text('更新に失敗しました: $e')),
            );
            setState(() => loading = false);
          }
        }

        return AlertDialog(
          title: const Text('名前を編集'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              enabled: !loading,
              decoration: const InputDecoration(
                labelText: '名前',
                hintText: '例: ポチ',
              ),
              autofillHints: const [AutofillHints.name],
              enableSuggestions: false,
              autocorrect: false,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return '名前を入力してください';
                if (v.trim().length > 30) return '30文字以内で入力してください';
                return null;
              },
              autofocus: true,
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

Future<void> _confirmDeletePet(BuildContext context, WidgetRef ref, Pet pet) async {
  bool loading = false;
  final repo = ref.read(petRepositoryProvider);
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> doDelete() async {
            setState(() => loading = true);
            try {
              await repo.deletePet(pet).timeout(const Duration(seconds: 15));
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('「${pet.name}」を削除しました')),
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
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(content: Text(msg)),
              );
              setState(() => loading = false);
            } catch (e) {
              if (!dialogContext.mounted) return;
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(content: Text('削除に失敗しました: $e')),
              );
              setState(() => loading = false);
            }
          }

          return AlertDialog(
            title: const Text('ペットを削除しますか？'),
            content: const Text('この操作は取り消せません。ログなどのサブコレクションは残る場合があります。'),
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
