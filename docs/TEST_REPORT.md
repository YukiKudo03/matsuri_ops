# MatsuriOps テストレポート

**生成日時**: 2026-03-08 16:25:56
**Elixir/Phoenix バージョン**: Phoenix 1.8.5 / Elixir 1.18
**テスト実行時間**: 4.3秒

---

## サマリー

| 項目 | 値 |
|------|-----|
| **総テスト数** | 519 |
| **成功** | 519 |
| **失敗** | 0 |
| **除外** | 8 |
| **テストファイル数** | 49 |
| **カバレッジ** | 46.82% |

---

## テストカテゴリ別内訳

### 1. ビジネスロジックテスト (`test/matsuri_ops/`)

| ファイル | 対象モジュール | 説明 |
|----------|---------------|------|
| `accounts_test.exs` | MatsuriOps.Accounts | ユーザー認証・アカウント管理 |
| `advertising_test.exs` | MatsuriOps.Advertising | 広告バナー管理 |
| `analytics_test.exs` | MatsuriOps.Analytics | 分析・統計機能 |
| `cameras_test.exs` | MatsuriOps.Cameras | ライブカメラ連携 |
| `chat_test.exs` | MatsuriOps.Chat | チャット機能 |
| `documents_test.exs` | MatsuriOps.Documents | ドキュメント管理 |
| `error_test.exs` | MatsuriOps.Error | エラーハンドリング |
| `gallery_test.exs` | MatsuriOps.Gallery | フォトギャラリー |
| `gantt_test.exs` | MatsuriOps.Gantt | ガントチャート |
| `locations_test.exs` | MatsuriOps.Locations | 位置情報管理 |
| `logger_test.exs` | MatsuriOps.Logger | ロギング機能 |
| `native_test.exs` | MatsuriOps.Native | ネイティブ連携 |
| `notifications_test.exs` | MatsuriOps.Notifications | 通知機能 |
| `qr_codes_test.exs` | MatsuriOps.QRCodes | QRコード管理 |
| `reports_test.exs` | MatsuriOps.Reports | レポート生成 |
| `reports/pdf_export_test.exs` | MatsuriOps.Reports.PdfExport | PDF出力 |
| `shifts_test.exs` | MatsuriOps.Shifts | シフト管理 |
| `social_media_test.exs` | MatsuriOps.SocialMedia | SNS投稿管理 |
| `sponsorships_test.exs` | MatsuriOps.Sponsorships | 協賛金管理 |
| `templates_test.exs` | MatsuriOps.Templates | テンプレート機能 |

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

---

## カバレッジ詳細

### 100%カバレッジモジュール

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
| MatsuriOpsWeb.PageController | 100.00% |
| MatsuriOpsWeb.UserSessionController | 100.00% |
| MatsuriOpsWeb.ErrorJSON | 100.00% |
| MatsuriOps.Accounts.UserNotifier | 100.00% |
| MatsuriOps.Templates | 100.00% |
| MatsuriOps.Reports | 100.00% |

### 改善が必要なモジュール（50%未満）

| モジュール | カバレッジ |
|-----------|-----------|
| MatsuriOpsWeb.FestivalLive.FormComponent | 4.30% |
| MatsuriOpsWeb.Presence | 7.69% |
| MatsuriOps.Tasks | 9.65% |
| MatsuriOpsWeb.FestivalLive.Show | 11.11% |
| MatsuriOps.Festivals | 14.35% |
| MatsuriOps.Budgets | 21.53% |

---

## ヘルプページテスト詳細

### HelpLive.Index（12テスト）

- [x] ログイン時にヘルプトップページが表示される
- [x] 未ログイン時にログインページへリダイレクトされる
- [x] 全カテゴリカードが表示される
- [x] FAQセクションが表示される
- [x] サポートセクションが表示される
- [x] 祭り一覧へのナビゲーションリンクがある
- [x] 全サブページへのリンクがある
- [x] クイックスタートページへ遷移できる
- [x] 管理者マニュアルページへ遷移できる
- [x] スタッフマニュアルページへ遷移できる
- [x] 外部ユーザーガイドページへ遷移できる

### HelpLive.Quickstart（13テスト）

- [x] ログイン時にクイックスタートページが表示される
- [x] 未ログイン時にログインページへリダイレクトされる
- [x] MatsuriOps紹介セクションが表示される
- [x] 対応環境が表示される
- [x] Step 1: アカウント登録が表示される
- [x] Step 2: プロフィール設定が表示される
- [x] Step 3: 祭りに参加/作成が表示される
- [x] 次のステップ（ロール別ガイド）が表示される
- [x] トラブルシューティングセクションが表示される
- [x] PWAインストール手順が表示される
- [x] ヘルプトップへの戻るリンクがある
- [x] 他マニュアルへのリンクがある
- [x] ヘルプトップへ戻れる

### HelpLive.Admin（15テスト）

- [x] ログイン時に管理者マニュアルページが表示される
- [x] 未ログイン時にログインページへリダイレクトされる
- [x] 目次が表示される
- [x] システム概要セクション（ユーザーロール）が表示される
- [x] ユーザー管理セクションが表示される
- [x] 祭り管理セクションが表示される
- [x] タスク管理セクションが表示される
- [x] 予算管理セクションが表示される
- [x] シフト管理セクションが表示される
- [x] 当日運営セクションが表示される
- [x] レポート・分析セクションが表示される
- [x] その他の機能セクションが表示される
- [x] トラブルシューティングセクションが表示される
- [x] ヘルプトップへの戻るリンクがある
- [x] ヘルプトップへ戻れる

### HelpLive.Staff（18テスト）

- [x] ログイン時にスタッフマニュアルページが表示される
- [x] 未ログイン時にログインページへリダイレクトされる
- [x] 目次が表示される
- [x] ログインセクションが表示される
- [x] タスクセクション（ステータス説明）が表示される
- [x] 優先度の説明が表示される
- [x] シフトセクションが表示される
- [x] 当日操作セクションが表示される
- [x] インシデント重大度ガイドが表示される
- [x] 混雑度ガイドが表示される
- [x] チャットセクションが表示される
- [x] お知らせセクションが表示される
- [x] ドキュメントセクションが表示される
- [x] FAQセクションが表示される
- [x] 緊急連絡先セクションが表示される
- [x] ヘルプトップへの戻るリンクがある
- [x] ヘルプトップへ戻れる

### HelpLive.External（18テスト）

- [x] ログイン時に外部ユーザーガイドページが表示される
- [x] 未ログイン時にログインページへリダイレクトされる
- [x] 目次が表示される
- [x] アカウント登録セクションが表示される
- [x] 祭り情報セクションが表示される
- [x] お知らせ受信セクションが表示される
- [x] 優先度レベルが表示される
- [x] 連絡先セクションが表示される
- [x] FAQセクションが表示される
- [x] 出店者向け情報セクションが表示される
- [x] 出店者準備ステップが表示される
- [x] スマートフォン利用セクションが表示される
- [x] PWAの利点が表示される
- [x] ヘルプトップへの戻るリンクがある
- [x] ヘルプトップへ戻れる

---

## テスト実行コマンド

```bash
# 全テスト実行
mix test

# カバレッジ付きで実行
mix test --cover

# 特定ファイルのテスト
mix test test/matsuri_ops_web/live/help_live/

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

## 警告事項

テスト実行時に以下の警告が出力されます（機能には影響なし）：

1. `unused variable` - 未使用変数（3件）
2. `default values never used` - 未使用デフォルト値（3件）

---

## 関連ドキュメント

- [クイックスタートガイド](/help/quickstart)
- [管理者マニュアル](/help/admin)
- [スタッフマニュアル](/help/staff)
- [外部ユーザーガイド](/help/external)

---

**生成**: Claude Code
**最終更新**: 2026-03-08
