import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_router.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: BootstrapApp()));
}

class BootstrapApp extends ConsumerWidget {
  const BootstrapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
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
        final lightColorScheme = ColorScheme.fromSeed(seedColor: Colors.teal);
        final darkColorScheme = ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark);
        final lightTheme = ThemeData(
          colorScheme: lightColorScheme,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFFE0B2), // 薄い橙（全画面で共通）
            foregroundColor: Colors.black87,
            elevation: 0.5,
            surfaceTintColor: Colors.transparent,
            shadowColor: Color(0x4D000000), // alpha約0.3の黒
          ),
        );
        final darkTheme = ThemeData(
          colorScheme: darkColorScheme,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF3A544B), // ダーク時に馴染む深い色
            foregroundColor: Colors.white,
            elevation: 0.5,
            surfaceTintColor: Colors.transparent,
            shadowColor: Color(0x4D000000),
          ),
        );
        return MaterialApp.router(
          title: 'ペットケア記録',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
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

// テスト互換用のラッパー（widget_test.dart が MyApp を参照しているため）
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: BootstrapApp());
  }
}

