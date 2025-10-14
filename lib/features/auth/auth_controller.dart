import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

// 認証状態 + 進行状況/エラー
class AuthState {
  const AuthState({this.isLoading = false, this.errorMessage});
  final bool isLoading;
  final String? errorMessage;

  AuthState copyWith({bool? isLoading, String? errorMessage}) =>
      AuthState(isLoading: isLoading ?? this.isLoading, errorMessage: errorMessage);
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService(FirebaseAuth.instance));

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  late final AuthService _service;

  @override
  AuthState build() {
    _service = ref.read(authServiceProvider);
    return const AuthState();
  }

  Stream<User?> authStateChanges() => FirebaseAuth.instance.authStateChanges();

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _service.signInWithEmail(email, password);
      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _mapError(e));
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '不明なエラー: $e');
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _service.registerWithEmail(email, password);
      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _mapError(e));
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '不明なエラー: $e');
      return false;
    }
  }

  Future<void> signOut() => _service.signOut();

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'メールアドレスの形式が正しくありません';
      case 'user-disabled':
        return 'このユーザーは無効化されています';
      case 'user-not-found':
      case 'wrong-password':
        return 'メールまたはパスワードが違います';
      case 'email-already-in-use':
        return 'このメールアドレスは既に使用されています';
      case 'weak-password':
        return 'パスワードが弱すぎます（6文字以上にしてください）';
      case 'operation-not-allowed':
        return '現在この操作は許可されていません';
      default:
        return 'エラー: ${e.message ?? e.code}';
    }
  }
}

