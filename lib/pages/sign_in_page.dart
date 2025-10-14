import 'package:flutter/material.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('サインイン')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ペットケア記録にサインイン'),
            const SizedBox(height: 24),
            SizedBox(
              width: 280,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Googleでサインイン'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Googleサインインは後で有効化します')),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 280,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.mail_outline),
                label: const Text('メール/パスワードで登録'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('メール認証は後で有効化します')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
