import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/auth_controller.dart';
import '../data/repositories/pet_repository.dart';

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
                    // TODO: ペット詳細 / ログ画面へ遷移（後続実装）
                  },
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
            await repo.createPet(name: nameController.text.trim());
            if (context.mounted) Navigator.of(context).pop();
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
