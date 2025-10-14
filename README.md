# ペットケア記録（家族共有）

Flutter + Firebase のスケルトン。Authゲート、ルーター、ページの雛形を含みます。

## セットアップ

1) Firebase プロジェクトの紐付け

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

これで `lib/firebase_options.dart` が生成されます。`main.dart` の TODO を解除して

```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

を有効化してください。

2) 依存解決と起動

```powershell
dart pub get
flutter run
```

## ディレクトリ

- `lib/pages/` サインイン・ホームのページ
- `lib/features/auth/` 認証コントローラ
- `lib/data/repositories/` Firestore連携のリポジトリ（スタブ）

## TODO（今後）

- Google/メール認証の実装
- Firestore スキーマ: users/{uid}, pets/{petId}, pets/{petId}/logs/{logId}
- 画像アップロード（Firebase Storage）
- 通知（FCM）
