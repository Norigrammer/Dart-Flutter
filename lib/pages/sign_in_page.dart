import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/auth_controller.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isRegisterMode = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = ref.read(authControllerProvider.notifier);
    final email = _emailCtrl.text.trim();
    final pass = _passwordCtrl.text.trim();
    bool ok;
    if (_isRegisterMode) {
      ok = await auth.register(email, pass);
    } else {
      ok = await auth.signIn(email, pass);
    }
    final state = ref.read(authControllerProvider);
    if (!ok && state.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegisterMode ? 'アカウント登録' : 'サインイン'),
      ),
      body: Stack(
        children: [
          // Background PNG matching HomePage style
          Positioned.fill(
            child: IgnorePointer(
              child: Image.asset(
                Theme.of(context).brightness == Brightness.dark
                    ? 'assets/backgrounds/home_bg_dark.png'
                    : 'assets/backgrounds/home_bg_light.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ペットケア記録',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'メールアドレス'),
                      autofillHints: const [AutofillHints.username, AutofillHints.email],
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return '入力してください';
                        if (!v.contains('@')) return '形式が不正です';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordCtrl,
                      decoration: const InputDecoration(labelText: 'パスワード'),
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      validator: (v) {
                        if (v == null || v.isEmpty) return '入力してください';
                        if (v.length < 6) return '6文字以上にしてください';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : _submit,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: state.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(_isRegisterMode ? '登録' : 'ログイン'),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: state.isLoading
                          ? null
                          : () => setState(() => _isRegisterMode = !_isRegisterMode),
                      child: Text(_isRegisterMode ? '既にアカウントがあります (ログイン)' : '初めての利用ですか？ 新規登録'),
                    ),
                    if (state.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          state.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
        ],
      ),
    );
  }
}
