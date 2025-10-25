<h1 align="center">Pettime（名称：ペットタイム）</h1>

ペットの散歩・食事・通院の記録を残すアプリです。<br>
過去の特定の期間の記録を検索することが可能です。

参考画像: Pettime - スプラッシュ・ホーム画像
<img width="2222" height="2295" alt="Pettime_Splash-HomeImages" src="https://github.com/user-attachments/assets/4d83469a-8da3-4406-beb9-3cae602c42db" />


## ディレクトリ

- `lib/data/` : Firestore, Riverpodなど
- `lib/features/` : 認証コントローラー
- `lib/models/` : サーバーサイド
- `lib/pages/` : クライアントサイド

### 説明
- Pages: 画面（サインイン/ホーム/詳細/週間サマリー/検索）
- Providers: Riverpod による状態/非同期データ（Auth 状態、ペット一覧、ログ一覧、統計など）
- Repositories: Firebase へのアクセスを集約（AuthService, PetRepository, CareLogRepository）
- Firebase Auth: メール/パスワード（将来的に Google Sign-In 追加）
- Cloud Firestore: `pets` コレクションと `pets/{petId}/logs` サブコレクション
- FCM: 通知（今後追加予定）

## データフロー（例：ログ表示）

```mermaid
sequenceDiagram
	participant User as ユーザー
	participant Page as HomePage/PetDetail
	participant Prov as Riverpod Provider
	participant Repo as CareLogRepository/PetRepository
	participant FS as Cloud Firestore

	User->>Page: 画面表示
	Page->>Prov: petLogsProvider / myPetsStreamProvider を watch
	Prov->>Repo: ログ/ペットの取得を要求
	Repo->>FS: クエリ（orderBy/where/limit）
	FS-->>Repo: スナップショット（Stream）
	Repo-->>Prov: List<モデル> を返却
	Prov-->>Page: AsyncValue.data(...) で UI 更新
	Page-->>User: リスト表示/ガイド表示
```
