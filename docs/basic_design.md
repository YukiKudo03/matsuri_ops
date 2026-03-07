# 基本設計書

## 地域祭り運営支援Webアプリケーション「MatsuriOps」

| 項目 | 内容 |
|------|------|
| 文書名 | 基本設計書 |
| バージョン | 1.0 |
| 作成日 | 2026年3月7日 |
| 最終更新日 | 2026年3月7日 |

---

## 1. システム構成

### 1.1 技術スタック

| レイヤー | 技術 | バージョン | 選定理由 |
|---------|------|-----------|---------|
| 言語 | Elixir | ~> 1.15 | 高並行処理、耐障害性 |
| フレームワーク | Phoenix | ~> 1.8.5 | リアルタイム通信、生産性 |
| フロントエンド | Phoenix LiveView | ~> 1.1.0 | サーバーサイドレンダリング |
| CSS | Tailwind CSS | 4.1.12 | ユーティリティファースト |
| UIコンポーネント | daisyUI | - | Tailwind拡張 |
| データベース | PostgreSQL | 16 | 信頼性、JSON対応 |
| ORM | Ecto | ~> 3.13 | Phoenix標準 |
| 認証 | phx.gen.auth | - | 組み込み認証 |
| リアルタイム | Phoenix Channels/PubSub | - | WebSocket通信 |
| メール | Swoosh | ~> 1.17 | Elixirネイティブ |
| Webサーバー | Bandit | ~> 1.5 | Phoenix 1.8標準 |

### 1.2 システムアーキテクチャ

```
┌─────────────────────────────────────────────────────────────┐
│                        クライアント                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │     PC      │  │  タブレット  │  │ スマートフォン │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ HTTPS / WebSocket
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     Phoenix Application                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    Endpoint                          │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │   Router    │  │  LiveView   │  │  Channels   │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                              │                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    Contexts                          │   │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌───────────┐ │   │
│  │  │Accounts │ │Festivals│ │  Tasks  │ │  Budgets  │ │   │
│  │  └─────────┘ └─────────┘ └─────────┘ └───────────┘ │   │
│  │  ┌───────────┐                                      │   │
│  │  │Operations │                                      │   │
│  │  └───────────┘                                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                              │                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   Ecto / Repo                        │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      PostgreSQL                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. データベース設計

### 2.1 ER図

```
┌──────────────┐       ┌──────────────────┐       ┌──────────────┐
│    users     │       │ festival_members │       │  festivals   │
├──────────────┤       ├──────────────────┤       ├──────────────┤
│ id           │──┐    │ id               │    ┌──│ id           │
│ email        │  │    │ festival_id      │────┤  │ name         │
│ name         │  └────│ user_id          │    │  │ description  │
│ phone        │       │ role             │    │  │ scale        │
│ role         │       │ assigned_area    │    │  │ start_date   │
│ organization │       │ notes            │    │  │ end_date     │
│ skills[]     │       └──────────────────┘    │  │ venue_name   │
│ hashed_pwd   │                               │  │ status       │
└──────────────┘                               │  │ organizer_id │
       │                                       │  └──────────────┘
       │                                       │         │
       │       ┌───────────────────────────────┼─────────┘
       │       │                               │
       ▼       ▼                               ▼
┌──────────────────┐    ┌──────────────────┐  ┌──────────────────┐
│ task_categories  │    │      tasks       │  │ budget_categories│
├──────────────────┤    ├──────────────────┤  ├──────────────────┤
│ id               │    │ id               │  │ id               │
│ festival_id      │────│ festival_id      │  │ festival_id      │
│ name             │    │ category_id      │──│ name             │
│ description      │    │ parent_id        │  │ budget_amount    │
│ sort_order       │    │ title            │  └──────────────────┘
└──────────────────┘    │ status           │           │
                        │ priority         │           ▼
                        │ due_date         │  ┌──────────────────┐
                        │ progress_percent │  │     expenses     │
                        │ assignee_id      │  ├──────────────────┤
                        └──────────────────┘  │ id               │
                               │              │ festival_id      │
                               ▼              │ category_id      │
                        ┌──────────────────┐  │ title            │
                        │ checklist_items  │  │ amount           │
                        ├──────────────────┤  │ status           │
                        │ id               │  │ approved_by_id   │
                        │ task_id          │  └──────────────────┘
                        │ content          │
                        │ is_completed     │  ┌──────────────────┐
                        │ completed_by_id  │  │     incomes      │
                        └──────────────────┘  ├──────────────────┤
                                              │ id               │
┌──────────────────┐    ┌──────────────────┐  │ festival_id      │
│    incidents     │    │   area_status    │  │ title            │
├──────────────────┤    ├──────────────────┤  │ amount           │
│ id               │    │ id               │  │ source_type      │
│ festival_id      │    │ festival_id      │  │ status           │
│ title            │    │ name             │  └──────────────────┘
│ severity         │    │ crowd_level      │
│ category         │    │ weather_temp     │
│ status           │    │ weather_wbgt     │
│ reported_by_id   │    │ updated_by_id    │
│ assigned_to_id   │    └──────────────────┘
└──────────────────┘
```

### 2.2 テーブル定義

#### 2.2.1 users（ユーザー）

| カラム名 | 型 | NULL | デフォルト | 説明 |
|----------|-----|------|-----------|------|
| id | bigint | NO | - | 主キー |
| email | varchar | NO | - | メールアドレス（ユニーク） |
| hashed_password | varchar | YES | - | ハッシュ化パスワード |
| confirmed_at | timestamp | YES | - | メール確認日時 |
| name | varchar | YES | - | 氏名 |
| phone | varchar | YES | - | 電話番号 |
| role | varchar | NO | 'volunteer' | システムロール |
| organization | varchar | YES | - | 所属組織 |
| emergency_contact | varchar | YES | - | 緊急連絡先 |
| skills | varchar[] | NO | [] | スキル一覧 |
| inserted_at | timestamp | NO | - | 作成日時 |
| updated_at | timestamp | NO | - | 更新日時 |

**roleの値**: system_admin, executive, admin, leader, staff, volunteer, vendor, visitor

#### 2.2.2 festivals（祭り）

| カラム名 | 型 | NULL | デフォルト | 説明 |
|----------|-----|------|-----------|------|
| id | bigint | NO | - | 主キー |
| name | varchar | NO | - | 祭り名 |
| description | text | YES | - | 説明 |
| scale | varchar | NO | 'medium' | 規模 |
| start_date | date | NO | - | 開始日 |
| end_date | date | NO | - | 終了日 |
| venue_name | varchar | YES | - | 会場名 |
| venue_address | varchar | YES | - | 会場住所 |
| expected_visitors | integer | YES | - | 予想来場者数 |
| expected_vendors | integer | YES | - | 予想出店数 |
| status | varchar | NO | 'planning' | ステータス |
| organizer_id | bigint | YES | - | 主催者ID |
| inserted_at | timestamp | NO | - | 作成日時 |
| updated_at | timestamp | NO | - | 更新日時 |

**scaleの値**: small, medium, large
**statusの値**: planning, preparation, active, completed, cancelled

#### 2.2.3 tasks（タスク）

| カラム名 | 型 | NULL | デフォルト | 説明 |
|----------|-----|------|-----------|------|
| id | bigint | NO | - | 主キー |
| festival_id | bigint | NO | - | 祭りID |
| category_id | bigint | YES | - | カテゴリID |
| parent_id | bigint | YES | - | 親タスクID |
| title | varchar | NO | - | タイトル |
| description | text | YES | - | 説明 |
| status | varchar | NO | 'pending' | ステータス |
| priority | varchar | NO | 'medium' | 優先度 |
| due_date | date | YES | - | 期限 |
| start_date | date | YES | - | 開始日 |
| estimated_hours | decimal | YES | - | 見積工数 |
| actual_hours | decimal | YES | - | 実績工数 |
| progress_percent | integer | NO | 0 | 進捗率 |
| is_milestone | boolean | NO | false | マイルストーンフラグ |
| sort_order | integer | NO | 0 | 表示順 |
| assignee_id | bigint | YES | - | 担当者ID |
| created_by_id | bigint | YES | - | 作成者ID |
| inserted_at | timestamp | NO | - | 作成日時 |
| updated_at | timestamp | NO | - | 更新日時 |

**statusの値**: pending, in_progress, completed, cancelled, blocked
**priorityの値**: low, medium, high, urgent

#### 2.2.4 incidents（インシデント）

| カラム名 | 型 | NULL | デフォルト | 説明 |
|----------|-----|------|-----------|------|
| id | bigint | NO | - | 主キー |
| festival_id | bigint | NO | - | 祭りID |
| title | varchar | NO | - | タイトル |
| description | text | YES | - | 説明 |
| severity | varchar | NO | 'low' | 重要度 |
| category | varchar | YES | - | カテゴリ |
| location | varchar | YES | - | 発生場所 |
| status | varchar | NO | 'reported' | ステータス |
| resolution | text | YES | - | 対応内容 |
| reported_at | timestamp | YES | - | 報告日時 |
| resolved_at | timestamp | YES | - | 解決日時 |
| reported_by_id | bigint | YES | - | 報告者ID |
| assigned_to_id | bigint | YES | - | 担当者ID |
| resolved_by_id | bigint | YES | - | 解決者ID |
| inserted_at | timestamp | NO | - | 作成日時 |
| updated_at | timestamp | NO | - | 更新日時 |

**severityの値**: low, medium, high, critical
**categoryの値**: medical, security, lost_item, weather, equipment, other
**statusの値**: reported, acknowledged, in_progress, resolved, closed

---

## 3. モジュール設計

### 3.1 コンテキスト構成

```
lib/matsuri_ops/
├── accounts.ex              # 認証・ユーザー管理
├── accounts/
│   ├── user.ex              # ユーザースキーマ
│   ├── user_token.ex        # トークンスキーマ
│   ├── user_notifier.ex     # メール通知
│   └── scope.ex             # アクセススコープ
├── festivals.ex             # 祭り管理コンテキスト
├── festivals/
│   ├── festival.ex          # 祭りスキーマ
│   └── festival_member.ex   # メンバースキーマ
├── tasks.ex                 # タスク管理コンテキスト
├── tasks/
│   ├── task.ex              # タスクスキーマ
│   ├── task_category.ex     # カテゴリスキーマ
│   ├── task_dependency.ex   # 依存関係スキーマ
│   └── checklist_item.ex    # チェックリストスキーマ
├── budgets.ex               # 予算管理コンテキスト
├── budgets/
│   ├── budget_category.ex   # 予算カテゴリスキーマ
│   ├── expense.ex           # 経費スキーマ
│   └── income.ex            # 収入スキーマ
├── operations.ex            # 当日運営コンテキスト
├── operations/
│   ├── incident.ex          # インシデントスキーマ
│   └── area_status.ex       # エリア状況スキーマ
├── mailer.ex                # メール送信
└── repo.ex                  # データベース接続
```

### 3.2 LiveView構成

```
lib/matsuri_ops_web/live/
├── user_live/               # ユーザー関連
│   ├── login.ex
│   ├── registration.ex
│   ├── settings.ex
│   └── confirmation.ex
├── festival_live/           # 祭り管理
│   ├── index.ex             # 一覧
│   ├── show.ex              # 詳細
│   └── form_component.ex    # フォーム
├── task_live/               # タスク管理
│   ├── index.ex             # 一覧
│   ├── show.ex              # 詳細
│   └── form_component.ex    # フォーム
├── budget_live/             # 予算管理
│   ├── index.ex             # 一覧・予実表示
│   ├── expense_form_component.ex
│   └── category_form_component.ex
├── staff_live/              # スタッフ管理
│   ├── index.ex             # 一覧
│   └── form_component.ex    # フォーム
└── operations_live/         # 当日運営
    ├── dashboard.ex         # ダッシュボード
    ├── incident_form_component.ex
    └── area_form_component.ex
```

### 3.3 ルーティング設計

| パス | LiveView | アクション | 認証 |
|------|----------|----------|------|
| / | PageController | :home | 不要 |
| /users/register | UserLive.Registration | :new | 不要 |
| /users/log-in | UserLive.Login | :new | 不要 |
| /users/settings | UserLive.Settings | :edit | 必要 |
| /festivals | FestivalLive.Index | :index | 必要 |
| /festivals/new | FestivalLive.Index | :new | 必要 |
| /festivals/:id | FestivalLive.Show | :show | 必要 |
| /festivals/:id/tasks | TaskLive.Index | :index | 必要 |
| /festivals/:id/tasks/:task_id | TaskLive.Show | :show | 必要 |
| /festivals/:id/budgets | BudgetLive.Index | :index | 必要 |
| /festivals/:id/staff | StaffLive.Index | :index | 必要 |
| /festivals/:id/operations | OperationsLive.Dashboard | :dashboard | 必要 |

---

## 4. 画面設計

### 4.1 画面一覧

| 画面ID | 画面名 | 概要 |
|--------|--------|------|
| SCR-001 | ログイン | Magic Link認証 |
| SCR-002 | ユーザー登録 | 新規ユーザー登録 |
| SCR-003 | 祭り一覧 | 祭り一覧表示・検索 |
| SCR-004 | 祭り詳細 | 祭り情報・各機能へのナビ |
| SCR-005 | タスク一覧 | タスク一覧・フィルター |
| SCR-006 | タスク詳細 | タスク詳細・チェックリスト |
| SCR-007 | 予算管理 | 予算カテゴリ・経費一覧 |
| SCR-008 | スタッフ管理 | メンバー一覧・役割管理 |
| SCR-009 | 運営ダッシュボード | リアルタイム状況表示 |

### 4.2 画面遷移図

```
┌─────────────┐
│   ログイン   │
└──────┬──────┘
       │ 認証成功
       ▼
┌─────────────┐     ┌─────────────┐
│  祭り一覧   │────▶│  祭り詳細   │
└─────────────┘     └──────┬──────┘
                          │
       ┌──────────────────┼──────────────────┐
       │                  │                  │
       ▼                  ▼                  ▼
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│ タスク管理  │   │  予算管理   │   │スタッフ管理 │
└─────────────┘   └─────────────┘   └─────────────┘
                          │
                          ▼
                  ┌─────────────┐
                  │運営ダッシュ │
                  │   ボード    │
                  └─────────────┘
```

---

## 5. リアルタイム通信設計

### 5.1 PubSub トピック

| トピック | 用途 | イベント |
|----------|------|----------|
| operations:{festival_id} | 当日運営 | incident_created, incident_updated, area_updated |

### 5.2 イベントフロー

```
[インシデント報告]
     │
     ▼
Operations.create_incident()
     │
     ▼
Phoenix.PubSub.broadcast("operations:{festival_id}", {:incident_created, incident})
     │
     ├──▶ Dashboard LiveView (handle_info)
     │         │
     │         ▼
     │    stream_insert(:incidents, incident)
     │
     └──▶ 他の接続中クライアント
```

---

## 6. セキュリティ設計

### 6.1 認証フロー

```
1. ユーザーがメールアドレスを入力
2. サーバーがMagic Linkトークンを生成
3. メールでMagic Linkを送信
4. ユーザーがリンクをクリック
5. トークン検証＆セッション発行
6. ログイン完了
```

### 6.2 認可チェック

```elixir
# ルーターレベル
pipe_through [:browser, :require_authenticated_user]

# LiveViewレベル
on_mount: [{MatsuriOpsWeb.UserAuth, :require_authenticated}]

# コンテキストレベル
def admin?(%User{role: role}) when role in ["system_admin", "executive", "admin"], do: true
def admin?(_), do: false
```

---

## 7. デプロイメント設計

### 7.1 推奨環境

| 環境 | サービス | 用途 |
|------|----------|------|
| 本番 | Fly.io / Gigalixir | アプリケーションホスティング |
| DB | Fly Postgres / Supabase | PostgreSQLデータベース |
| メール | Resend / SendGrid | トランザクションメール |

### 7.2 環境変数

| 変数名 | 説明 |
|--------|------|
| DATABASE_URL | PostgreSQL接続文字列 |
| SECRET_KEY_BASE | Phoenix暗号化キー |
| PHX_HOST | 本番ホスト名 |
| SWOOSH_API_KEY | メールサービスAPIキー |

---

## 8. 参照文書

- 要件定義書（docs/requirements.md）
- タスク表（docs/tasks.md）
- Phoenix Framework ドキュメント
- Ecto ドキュメント
