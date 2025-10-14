import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_router.dart';

// TODO: flutterfire configure 実行後に生成されるファイル
// import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: BootstrapApp()));
}

class BootstrapApp extends ConsumerWidget {
  const BootstrapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            debugShowCheckedModeBanner: false,
          );
        }
        if (snap.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Firebaseの初期化に失敗しました。\n"flutterfire configure" を実行し、firebase_options.dart を生成してください。\n\nError: ${snap.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            debugShowCheckedModeBanner: false,
          );
        }
        final theme = ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal));
        return MaterialApp.router(
          title: 'ペットケア記録',
          theme: theme,
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

/// シンプルなAuthゲート: ログインしていなければサインイン画面に、していればホームに遷移
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

