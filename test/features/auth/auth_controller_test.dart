import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sample/features/auth/auth_controller.dart';
import 'package:sample/features/auth/auth_service.dart';

class FakeAuthService implements AuthService {
  FakeAuthService({this.signInResult, this.registerResult});

  Object? signInResult;
  Object? registerResult;

  @override
  User? get currentUser => null;

  @override
  Future<UserCredential> signInWithEmail(String email, String password) async {
    final res = signInResult;
    if (res is Exception) throw res;
    if (res is FirebaseAuthException) throw res;
    return Future.value(FakeUserCredential());
  }

  @override
  Future<UserCredential> registerWithEmail(String email, String password) async {
    final res = registerResult;
    if (res is Exception) throw res;
    if (res is FirebaseAuthException) throw res;
    return Future.value(FakeUserCredential());
  }

  @override
  Future<void> signOut() async {}
}

class FakeUserCredential implements UserCredential {
  @override
  // ignore: overridden_fields
  final AdditionalUserInfo? additionalUserInfo = null;
  @override
  // ignore: overridden_fields
  final AuthCredential? credential = null;
  @override
  // ignore: overridden_fields
  final User? user = null;
}

void main() {
  group('AuthController', () {
    test('signIn success clears loading and error', () async {
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWith((ref) => FakeAuthService()),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(authControllerProvider.notifier);
      final result = await controller.signIn('a@b.com', 'pass');

      final state = container.read(authControllerProvider);
      expect(result, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('signIn maps FirebaseAuthException codes', () async {
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWith((ref) => FakeAuthService(
                signInResult: FirebaseAuthException(code: 'wrong-password'),
              )),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(authControllerProvider.notifier);
      final result = await controller.signIn('a@b.com', 'x');

      final state = container.read(authControllerProvider);
      expect(result, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, 'メールまたはパスワードが違います');
    });

    test('register maps FirebaseAuthException codes', () async {
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWith((ref) => FakeAuthService(
                registerResult: FirebaseAuthException(code: 'email-already-in-use'),
              )),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(authControllerProvider.notifier);
      final result = await controller.register('a@b.com', 'x');

      final state = container.read(authControllerProvider);
      expect(result, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, 'このメールアドレスは既に使用されています');
    });
  });
}
