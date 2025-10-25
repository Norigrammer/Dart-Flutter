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

## ペット一覧 & 追加ダイアログ (実装済)

ホーム画面で以下の状態遷移を行います:

- ローディング: 円形プログレスを中央表示
- エラー: メッセージ + 再試行ボタン
- データなし: 「まだペットが登録されていません」ガイド表示
- データあり: ListView (アイコン / 名前 / メンバー数)

右下の + FAB を押すとペット追加ダイアログが開き、名前(必須, 30字以内)を入力して「追加」で Firestore `pets` にドキュメントを作成します。作成後は自動で一覧へ反映されます。

## ペット詳細 & ログ管理 (実装済)

ペット一覧からペットをタップすると詳細画面に遷移します:

- ログ一覧表示（散歩・ごはん・病院の記録）
- ログの種類・期間でのフィルタリング
- ログの追加・編集・削除
- 画像添付は現在未対応（Storage 非利用方針）

## 統計情報 (実装済)

ペット詳細画面の右上の統計アイコンから統計情報ページへアクセスできます:

- 総記録数と記録期間の表示
- 各ケアタイプ（散歩・ごはん・病院）ごとの記録数
- 各ケアタイプの最終記録日時の表示
- データがない場合のガイド表示

## 週間サマリー (実装済)

ペット詳細画面の右上のカレンダーアイコンから週間サマリーページへアクセスできます:

- 過去7日間のケア記録の概要表示
- 各ケアタイプの合計回数をバッジで表示
- 日ごとのケア記録をカード形式で一覧表示
- 今日の記録をハイライト表示

## ログ検索 (実装済)

ペット詳細画面の右上の検索アイコンからログ検索ページへアクセスできます:

- メモの内容からログを検索
- リアルタイム検索（入力と同時に結果を更新）
- 検索結果件数の表示
- 検索にヒットしたログの一覧表示

## 次のステップ候補

- ~~統計情報画面: ケアログの記録数・最終記録日などの可視化~~ (実装済)
- 画像アップロード（Storage）: 非対応（コスト/プラン要件のため）
- グラフ表示: 週次・月次のケアログ推移をチャート表示
- Cloud Functions: ペット削除時に logs サブコレクション一括削除
- 通知（FCM）: 散歩リマインダー等
- Google サインイン追加
- カレンダー表示: ログをカレンダー形式で表示
- エクスポート機能: ログをPDFやCSVで出力


## セキュリティルール（Firestore）

このプロジェクトでは、以下の場所にルールファイルを配置しています。

- Firestore: `firestore.rules`

Storage は現在使用しません。`storage.rules` は参考用に残っている場合がありますが、デプロイ不要です。

### デプロイ手順（Firebase CLI）

事前に Firebase CLI ログインとプロジェクト選択を済ませてください。

```powershell
firebase.cmd login --no-localhost
firebase.cmd use pet-time-7398c

# Firestore ルールのみデプロイ
firebase.cmd deploy --only firestore:rules
```

メモ: PowerShell では実行ポリシーにより `firebase.ps1` がブロックされる場合があります。その場合は `firebase.cmd` を利用してください。


