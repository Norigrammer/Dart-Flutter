# ペットケア記録（家族共有）

Flutter + Firebase のスケルトン。Auth（メール/パスワード）、ルーター、Firestore リポジトリ（pets/logs）を含みます。

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

## Firestore コレクション構造 (現状実装)

```
pets/{petId}
	name: string
	members: string[] (UID array)
	photoUrl?: string
	createdAt: Timestamp
	updatedAt: Timestamp

pets/{petId}/logs/{logId}
	type: 'walk' | 'feed' | 'clinic'
	note?: string
	photoUrl?: string
	at: Timestamp   (記録日時)
	createdBy: string (UID)
	createdAt: Timestamp (作成時刻)
```

将来的に `users/{uid}` プロファイルや通知設定などを追加予定。

## 推奨 Firestore セキュリティルール（例）

以下は概念例です。実運用では追加でバリデーション（配列長・文字数制限など）を行ってください。

```js
rules_version = '2';
service cloud.firestore {
	match /databases/{database}/documents {
		function isSignedIn() { return request.auth != null; }
		function uid() { return request.auth.uid; }

		match /pets/{petId} {
			allow read: if isSignedIn() && (uid() in resource.data.members);
			allow create: if isSignedIn() && request.resource.data.members.hasOnly([uid()]) &&
				request.resource.data.name is string && request.resource.data.members is list;
			allow update, delete: if isSignedIn() && (uid() in resource.data.members);

			match /logs/{logId} {
				allow read: if isSignedIn() && (uid() in get(/databases/$(database)/documents/pets/$(petId)).data.members);
				allow create: if isSignedIn() && (uid() in get(/databases/$(database)/documents/pets/$(petId)).data.members);
				allow update, delete: if isSignedIn() && (uid() == resource.data.createdBy);
			}
		}
	}
}
```

## インデックス（必要になり得るもの）

- `pets` コレクション: members の array-contains クエリ（自動）
- `pets/{petId}/logs` コレクション: orderBy at desc + limit（単一フィールドは自動）

複合クエリを追加した際にエラーメッセージからリンク経由で作成してください。

## メール/パスワード認証の利用方法

1. Firebaseコンソール Authentication で Email/Password を有効化
2. アプリ起動 → フォームにメール & 6文字以上のパスワード → 新規登録
3. 成功後ホーム（サインアウトは右上ボタン）
4. ログインは同フォームで「既にアカウントがあります」をクリック

## 次のステップ候補

- 画像アップロード（Storage）: ペット写真やケアログ写真
- Cloud Functions: ペット削除時に logs サブコレクション一括削除
- 通知（FCM）: 散歩リマインダー等
- Google サインイン追加
- UI: ペット一覧画面 / ログ一覧・追加ダイアログ / カレンダー表示

