import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/home_page.dart';
import 'pages/sign_in_page.dart';
import 'main.dart';
import 'pages/pet_detail_page.dart';
import 'models/pet.dart';

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => const _AuthGate(),
      routes: [
        GoRoute(
          path: 'home',
          builder: (BuildContext context, GoRouterState state) => const HomePage(),
        ),
        GoRoute(
          path: 'pets/:id',
          builder: (BuildContext context, GoRouterState state) {
            final pet = state.extra as Pet?;
            if (pet == null) {
              return const Scaffold(body: Center(child: Text('ペット情報が見つかりません')));
            }
            return PetDetailPage(pet: pet);
          },
        ),
        GoRoute(
          path: 'signin',
          builder: (BuildContext context, GoRouterState state) => const SignInPage(),
        ),
      ],
    ),
  ],
);

class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    return auth.when(
      data: (user) {
        if (user == null) {
          return const SignInPage();
        } else {
          return const HomePage();
        }
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Auth error: $e'))),
    );
  }
}
