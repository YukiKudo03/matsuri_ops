# MatsuriOps テストレポート

**生成日時**: 2026-03-08 16:42:36
**Elixir/Phoenix バージョン**: Phoenix 1.8.5 / Elixir 1.18
**テスト実行時間**: 5.7秒

---

## サマリー

| 項目 | 値 | 前回比 |
|------|-----|--------|
| **総テスト数** | 629 | +110 |
| **成功** | 629 | - |
| **失敗** | 0 | - |
| **除外** | 8 | - |
| **テストファイル数** | 54 | +5 |
| **カバレッジ** | 51.86% | +5.04% |

---

## テストカテゴリ別内訳

### 1. ビジネスロジックテスト (`test/matsuri_ops/`)

| ファイル | 対象モジュール | 説明 | テスト数 |
|----------|---------------|------|---------|
| `accounts_test.exs` | MatsuriOps.Accounts | ユーザー認証・アカウント管理 | - |
| `advertising_test.exs` | MatsuriOps.Advertising | 広告バナー管理 | - |
| `analytics_test.exs` | MatsuriOps.Analytics | 分析・統計機能 | - |
| `budgets_test.exs` | MatsuriOps.Budgets | 予算・経費・収入管理 | 37 |
| `cameras_test.exs` | MatsuriOps.Cameras | ライブカメラ連携 | - |
| `chat_test.exs` | MatsuriOps.Chat | チャット機能 | - |
| `documents_test.exs` | MatsuriOps.Documents | ドキュメント管理 | - |
| `error_test.exs` | MatsuriOps.Error | エラーハンドリング | - |
| `festivals_test.exs` | MatsuriOps.Festivals | 祭り・メンバー管理 | 23 |
| `gallery_test.exs` | MatsuriOps.Gallery | フォトギャラリー | - |
| `gantt_test.exs` | MatsuriOps.Gantt | ガントチャート | - |
| `locations_test.exs` | MatsuriOps.Locations | 位置情報管理 | - |
| `logger_test.exs` | MatsuriOps.Logger | ロギング機能 | - |
| `native_test.exs` | MatsuriOps.Native | ネイティブ連携 | - |
| `notifications_test.exs` | MatsuriOps.Notifications | 通知機能 | - |
| `qr_codes_test.exs` | MatsuriOps.QRCodes | QRコード管理 | - |
| `reports_test.exs` | MatsuriOps.Reports | レポート生成 | - |
| `reports/pdf_export_test.exs` | MatsuriOps.Reports.PdfExport | PDF出力 | - |
| `shifts_test.exs` | MatsuriOps.Shifts | シフト管理 | - |
| `social_media_test.exs` | MatsuriOps.SocialMedia | SNS投稿管理 | - |
| `sponsorships_test.exs` | MatsuriOps.Sponsorships | 協賛金管理 | - |
| `tasks_test.exs` | MatsuriOps.Tasks | タスク・チェックリスト管理 | 29 |
| `templates_test.exs` | MatsuriOps.Templates | テンプレート機能 | - |

### 2. Web層テスト (`test/matsuri_ops_web/`)

#### コントローラーテスト

| ファイル | 対象 | 説明 |
|----------|------|------|
| `error_html_test.exs` | ErrorHTML | HTMLエラーページ |
| `error_json_test.exs` | ErrorJSON | JSONエラーレスポンス |
| `page_controller_test.exs` | PageController | 静的ページ |
| `user_session_controller_test.exs` | UserSessionController | セッション管理 |

#### ヘルパーテスト

| ファイル | 対象 | 説明 |
|----------|------|------|
| `formatting_helpers_test.exs` | FormattingHelpers | 表示フォーマット |
| `locale_config_test.exs` | LocaleConfig | ロケール設定 |
| `i18n_test.exs` | I18n | 国際化 |

#### LiveViewテスト

| ファイル | 対象ページ | テスト数 |
|----------|-----------|---------|
| `announcement_live/index_test.exs` | お知らせ一覧 | - |
| `chat_live/index_test.exs` | チャット一覧 | - |
| `document_live/index_test.exs` | ドキュメント一覧 | - |
| `festival_live/form_component_test.exs` | 祭りフォーム | 10 |
| `festival_live/show_test.exs` | 祭り詳細 | 13 |
| `gantt_live/index_test.exs` | ガントチャート | - |
| `help_live/index_test.exs` | ヘルプトップ | 12 |
| `help_live/quickstart_test.exs` | クイックスタート | 13 |
| `help_live/admin_test.exs` | 管理者マニュアル | 15 |
| `help_live/staff_test.exs` | スタッフマニュアル | 18 |
| `help_live/external_test.exs` | 外部ユーザーガイド | 18 |
| `location_live/index_test.exs` | 位置情報一覧 | - |
| `report_live/index_test.exs` | レポート一覧 | - |
| `shift_live/index_test.exs` | シフト一覧 | - |
| `template_live/index_test.exs` | テンプレート一覧 | - |
| `user_live/confirmation_test.exs` | アカウント確認 | - |
| `user_live/login_test.exs` | ログイン | - |
| `user_live/registration_test.exs` | ユーザー登録 | - |
| `user_live/settings_test.exs` | 設定 | - |

#### その他

| ファイル | 対象 | 説明 |
|----------|------|------|
| `pwa_test.exs` | PWA | Progressive Web App |
| `user_auth_test.exs` | UserAuth | 認証プラグ |

### 3. フィーチャーテスト (`test/features/`)

| ファイル | シナリオ | 説明 |
|----------|---------|------|
| `authentication_test.exs` | 認証フロー | ログイン・ログアウト |
| `festival_management_test.exs` | 祭り管理 | 作成・編集・削除 |
| `operations_dashboard_test.exs` | 運営ダッシュボード | 当日運営 |

### 4. テストフィクスチャ (`test/support/fixtures/`)

| ファイル | 提供関数 |
|----------|---------|
| `accounts_fixtures.ex` | user_fixture, user_scope_fixture |
| `budgets_fixtures.ex` | budget_category_fixture, expense_fixture, income_fixture |
| `festivals_fixtures.ex` | festival_fixture, festival_member_fixture |
| `tasks_fixtures.ex` | task_category_fixture, task_fixture, checklist_item_fixture |

---

## カバレッジ詳細

### 高カバレッジモジュール（90%以上）

| モジュール | カバレッジ |
|-----------|-----------|
| MatsuriOpsWeb.HelpLive.Index | 100.00% |
| MatsuriOpsWeb.HelpLive.Quickstart | 100.00% |
| MatsuriOpsWeb.HelpLive.Admin | 100.00% |
| MatsuriOpsWeb.HelpLive.Staff | 100.00% |
| MatsuriOpsWeb.HelpLive.External | 100.00% |
| MatsuriOpsWeb.UserLive.Login | 100.00% |
| MatsuriOpsWeb.UserLive.Registration | 100.00% |
| MatsuriOpsWeb.UserLive.Settings | 100.00% |
| MatsuriOpsWeb.UserLive.Confirmation | 100.00% |
| MatsuriOpsWeb.TemplateLive.Index | 100.00% |
| MatsuriOps.Accounts.UserNotifier | 100.00% |
| MatsuriOps.Templates | 100.00% |
| MatsuriOps.Reports | 100.00% |
| MatsuriOpsWeb.FestivalLive.Show | 94.64% |
| MatsuriOps.Budgets | 94.44% |
| MatsuriOpsWeb.GanttLive.Index | 94.12% |
| MatsuriOps.Festivals | 93.10% |
| MatsuriOps.Notifications | 91.30% |
| MatsuriOps.Tasks | 90.91% |
| MatsuriOps.QRCodes | 90.00% |

### 今回改善されたモジュール

| モジュール | 変更前 | 変更後 | 改善 |
|-----------|--------|--------|------|
| MatsuriOps.Tasks | 9.65% | 90.91% | +81.26% |
| MatsuriOps.Festivals | 14.35% | 93.10% | +78.75% |
| MatsuriOps.Budgets | 21.53% | 94.44% | +72.91% |
| FestivalLive.Show | 11.11% | 94.64% | +83.53% |
| FestivalLive.FormComponent | 4.30% | 81.58% | +77.28% |

### 改善が必要なモジュール（50%未満）

| モジュール | カバレッジ |
|-----------|-----------|
| MatsuriOps.Operations | 0.00% |
| MatsuriOpsWeb.BudgetLive.Index | 0.00% |
| MatsuriOpsWeb.TaskLive.Index | 0.00% |
| MatsuriOpsWeb.StaffLive.Index | 0.00% |
| MatsuriOpsWeb.OperationsLive.Dashboard | 0.00% |
| MatsuriOpsWeb.Router | 42.68% |
| MatsuriOps.QRCodes.QRCode | 46.67% |

---

## 新規追加テスト詳細

### MatsuriOps.Festivals テスト（23テスト）

**祭り管理**
- [x] list_festivals/0 で全祭りを取得
- [x] list_festivals_by_status/1 でステータス別取得
- [x] list_user_festivals/1 でユーザー別取得
- [x] get_festival!/1 でID指定取得
- [x] get_festival/1 でnil対応取得
- [x] get_festival_with_members!/1 でメンバー付き取得
- [x] create_festival/1 で祭り作成
- [x] create_festival/2 でorganizer付き作成
- [x] update_festival/2 で祭り更新
- [x] delete_festival/1 で祭り削除
- [x] change_festival/1 でchangeset取得

**メンバー管理**
- [x] list_festival_members/1 でメンバー一覧取得
- [x] get_festival_member!/1 でメンバー取得
- [x] get_festival_member/2 で祭り・ユーザー指定取得
- [x] add_member_to_festival/1 でメンバー追加
- [x] update_festival_member/2 でメンバー更新
- [x] remove_member_from_festival/1 でメンバー削除
- [x] member_of_festival?/2 でメンバー確認

### MatsuriOps.Tasks テスト（29テスト）

**タスクカテゴリ**
- [x] list_task_categories/1 でカテゴリ一覧取得
- [x] get_task_category!/1 でカテゴリ取得
- [x] create_task_category/1 でカテゴリ作成
- [x] update_task_category/2 でカテゴリ更新
- [x] delete_task_category/1 でカテゴリ削除

**タスク**
- [x] list_tasks/1 でタスク一覧取得
- [x] list_tasks_by_category/2 でカテゴリ別取得
- [x] list_tasks_by_assignee/2 で担当者別取得
- [x] list_root_tasks/1 でルートタスク取得
- [x] get_task!/1 でタスク取得
- [x] get_task_with_children!/1 で子タスク付き取得
- [x] create_task/1 でタスク作成
- [x] update_task/2 でタスク更新
- [x] delete_task/1 でタスク削除

**タスク依存関係**
- [x] list_task_dependencies/1 で依存関係取得
- [x] create_task_dependency/1 で依存関係作成
- [x] delete_task_dependency/1 で依存関係削除

**チェックリスト**
- [x] list_checklist_items/1 でアイテム一覧取得
- [x] get_checklist_item!/1 でアイテム取得
- [x] create_checklist_item/1 でアイテム作成
- [x] update_checklist_item/2 でアイテム更新
- [x] delete_checklist_item/1 でアイテム削除
- [x] toggle_checklist_item/2 で完了トグル（true）
- [x] toggle_checklist_item/2 で完了トグル（false）

### MatsuriOps.Budgets テスト（37テスト）

**予算カテゴリ**
- [x] list_budget_categories/1 でカテゴリ一覧取得
- [x] get_budget_category!/1 でカテゴリ取得
- [x] create_budget_category/1 でカテゴリ作成
- [x] update_budget_category/2 でカテゴリ更新
- [x] delete_budget_category/1 でカテゴリ削除

**経費**
- [x] list_expenses/1 で経費一覧取得
- [x] list_expenses_by_category/2 でカテゴリ別取得
- [x] list_expenses_by_status/2 でステータス別取得
- [x] get_expense!/1 で経費取得
- [x] create_expense/1 で経費作成
- [x] update_expense/2 で経費更新
- [x] approve_expense/2 で経費承認
- [x] reject_expense/2 で経費却下
- [x] delete_expense/1 で経費削除
- [x] total_expenses/1 で承認済み経費合計
- [x] total_expenses_by_category/1 でカテゴリ別合計

**収入**
- [x] list_incomes/1 で収入一覧取得
- [x] list_incomes_by_status/2 でステータス別取得
- [x] get_income!/1 で収入取得
- [x] create_income/1 で収入作成
- [x] update_income/2 で収入更新
- [x] delete_income/1 で収入削除
- [x] total_income/1 で受領済み収入合計

**予算サマリー**
- [x] budget_summary/1 で予算概要取得
- [x] budget_summary/1 で空予算対応

### FestivalLive テスト（23テスト）

**Show ページ（13テスト）**
- [x] 祭り詳細ページの表示
- [x] 未ログイン時のリダイレクト
- [x] 祭り情報の表示
- [x] ナビゲーションボタンの表示
- [x] メンバーリストの表示
- [x] メンバーなし時のメッセージ
- [x] タスクカテゴリの表示
- [x] カテゴリなし時のメッセージ
- [x] 戻るリンクの表示
- [x] 各スケール表示の確認

**FormComponent（10テスト）**
- [x] 編集フォームの表示
- [x] 既存値の表示
- [x] バリデーションの確認
- [x] 保存処理の確認
- [x] 日本語ラベルの表示
- [x] スケール選択肢の表示
- [x] ステータス選択肢の表示
- [x] モーダル閉じる機能

---

## テスト実行コマンド

```bash
# 全テスト実行
mix test

# カバレッジ付きで実行
mix test --cover

# 特定ファイルのテスト
mix test test/matsuri_ops/festivals_test.exs
mix test test/matsuri_ops/tasks_test.exs
mix test test/matsuri_ops/budgets_test.exs

# LiveViewテスト
mix test test/matsuri_ops_web/live/festival_live/

# 詳細出力
mix test --trace

# フィーチャーテスト含む
mix test --include feature
```

---

## 除外されたテスト

8件のフィーチャーテストが `@tag :feature` により除外されています。
これらは統合テスト環境でのみ実行されます。

```bash
# フィーチャーテストを含めて実行
mix test --include feature
```

---

## 関連ドキュメント

- [クイックスタートガイド](/help/quickstart)
- [管理者マニュアル](/help/admin)
- [スタッフマニュアル](/help/staff)
- [外部ユーザーガイド](/help/external)

---

**生成**: Claude Code
**最終更新**: 2026-03-08
