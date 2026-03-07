# タスク表

## 地域祭り運営支援Webアプリケーション「MatsuriOps」

| 項目 | 内容 |
|------|------|
| 文書名 | タスク表 |
| バージョン | 2.0 |
| 作成日 | 2026年3月7日 |
| 最終更新日 | 2026年3月8日 |
| 開発手法 | TDD (Test-Driven Development) |

---

## 1. TDD開発フロー

### Red-Green-Refactorサイクル

```
┌─────────────────────────────────────────────────────────┐
│  🔴 RED: テスト作成（失敗するテストを書く）              │
│    ↓                                                    │
│  🟢 GREEN: 実装（テストを通す最小限のコードを書く）      │
│    ↓                                                    │
│  🔵 REFACTOR: リファクタリング（コードを改善する）       │
│    ↓                                                    │
│  ✅ DONE: 完了（次の機能へ）                            │
└─────────────────────────────────────────────────────────┘
```

### タスク命名規則

| プレフィックス | 意味 |
|---------------|------|
| `T-` | テスト作成タスク (Test) |
| `I-` | 実装タスク (Implementation) |
| `R-` | リファクタリングタスク (Refactor) |

---

## 2. 開発フェーズ概要

| フェーズ | 状態 | テストカバレッジ目標 |
|----------|------|---------------------|
| Phase 1: MVP | ✅ 完了 | 80%以上 |
| Phase 2: 拡張機能 | 🔲 未着手 | 80%以上 |
| Phase 3: 将来拡張 | 🔲 未着手 | 80%以上 |

---

## 3. Phase 1: MVP（完了）

### 3.1 基盤構築

| ID | タスク | TDDフェーズ | 状態 |
|----|--------|-------------|------|
| P1-001 | Elixir/Phoenix環境構築 | - | ✅ 完了 |
| P1-002 | PostgreSQL設定 | - | ✅ 完了 |
| P1-003 | プロジェクト初期化 | - | ✅ 完了 |
| T-AUTH-001 | 認証システムテスト作成 | 🔴 RED | ✅ 完了 |
| I-AUTH-001 | 認証システム実装 | 🟢 GREEN | ✅ 完了 |
| R-AUTH-001 | 認証システムリファクタリング | 🔵 REFACTOR | ✅ 完了 |
| T-ROLE-001 | ユーザーロールテスト作成 | 🔴 RED | ✅ 完了 |
| I-ROLE-001 | ユーザーロール実装 | 🟢 GREEN | ✅ 完了 |

### 3.2 祭り管理モジュール

| ID | タスク | TDDフェーズ | 状態 |
|----|--------|-------------|------|
| T-FEST-001 | Festivalスキーマテスト | 🔴 RED | ✅ 完了 |
| I-FEST-001 | Festivalスキーマ実装 | 🟢 GREEN | ✅ 完了 |
| T-FEST-002 | FestivalMemberスキーマテスト | 🔴 RED | ✅ 完了 |
| I-FEST-002 | FestivalMemberスキーマ実装 | 🟢 GREEN | ✅ 完了 |
| T-FEST-003 | Festivalsコンテキストテスト | 🔴 RED | ✅ 完了 |
| I-FEST-003 | Festivalsコンテキスト実装 | 🟢 GREEN | ✅ 完了 |
| T-FEST-004 | 祭りLiveViewテスト | 🔴 RED | ✅ 完了 |
| I-FEST-004 | 祭りLiveView実装 | 🟢 GREEN | ✅ 完了 |
| R-FEST-001 | 祭り管理リファクタリング | 🔵 REFACTOR | ✅ 完了 |

### 3.3 タスク管理モジュール

| ID | タスク | TDDフェーズ | 状態 |
|----|--------|-------------|------|
| T-TASK-001 | TaskCategoryスキーマテスト | 🔴 RED | ✅ 完了 |
| I-TASK-001 | TaskCategoryスキーマ実装 | 🟢 GREEN | ✅ 完了 |
| T-TASK-002 | Taskスキーマテスト（WBS階層） | 🔴 RED | ✅ 完了 |
| I-TASK-002 | Taskスキーマ実装 | 🟢 GREEN | ✅ 完了 |
| T-TASK-003 | TaskDependencyテスト | 🔴 RED | ✅ 完了 |
| I-TASK-003 | TaskDependency実装 | 🟢 GREEN | ✅ 完了 |
| T-TASK-004 | Tasksコンテキストテスト | 🔴 RED | ✅ 完了 |
| I-TASK-004 | Tasksコンテキスト実装 | 🟢 GREEN | ✅ 完了 |
| T-TASK-005 | タスクLiveViewテスト | 🔴 RED | ✅ 完了 |
| I-TASK-005 | タスクLiveView実装 | 🟢 GREEN | ✅ 完了 |
| R-TASK-001 | タスク管理リファクタリング | 🔵 REFACTOR | ✅ 完了 |

### 3.4 予算・経費管理モジュール

| ID | タスク | TDDフェーズ | 状態 |
|----|--------|-------------|------|
| T-BUD-001 | BudgetCategoryスキーマテスト | 🔴 RED | ✅ 完了 |
| I-BUD-001 | BudgetCategoryスキーマ実装 | 🟢 GREEN | ✅ 完了 |
| T-BUD-002 | Expense/Incomeスキーマテスト | 🔴 RED | ✅ 完了 |
| I-BUD-002 | Expense/Incomeスキーマ実装 | 🟢 GREEN | ✅ 完了 |
| T-BUD-003 | Budgetsコンテキストテスト | 🔴 RED | ✅ 完了 |
| I-BUD-003 | Budgetsコンテキスト実装 | 🟢 GREEN | ✅ 完了 |
| T-BUD-004 | 予算管理LiveViewテスト | 🔴 RED | ✅ 完了 |
| I-BUD-004 | 予算管理LiveView実装 | 🟢 GREEN | ✅ 完了 |
| R-BUD-001 | 予算管理リファクタリング | 🔵 REFACTOR | ✅ 完了 |

### 3.5 当日運営支援モジュール

| ID | タスク | TDDフェーズ | 状態 |
|----|--------|-------------|------|
| T-OPS-001 | Incident/AreaStatusスキーマテスト | 🔴 RED | ✅ 完了 |
| I-OPS-001 | Incident/AreaStatusスキーマ実装 | 🟢 GREEN | ✅ 完了 |
| T-OPS-002 | Operationsコンテキストテスト | 🔴 RED | ✅ 完了 |
| I-OPS-002 | Operationsコンテキスト実装 | 🟢 GREEN | ✅ 完了 |
| T-OPS-003 | PubSubリアルタイム更新テスト | 🔴 RED | ✅ 完了 |
| I-OPS-003 | PubSubリアルタイム更新実装 | 🟢 GREEN | ✅ 完了 |
| T-OPS-004 | 運営ダッシュボードLiveViewテスト | 🔴 RED | ✅ 完了 |
| I-OPS-004 | 運営ダッシュボードLiveView実装 | 🟢 GREEN | ✅ 完了 |
| R-OPS-001 | 運営支援リファクタリング | 🔵 REFACTOR | ✅ 完了 |

---

## 4. Phase 2: 拡張機能

### 4.1 テンプレート管理 (#1)

| ID | タスク | TDDフェーズ | 状態 | 備考 |
|----|--------|-------------|------|------|
| T-TPL-001 | Templateスキーマテスト作成 | 🔴 RED | 🔲 未着手 | changeset, validation |
| I-TPL-001 | Templateスキーマ実装 | 🟢 GREEN | 🔲 未着手 | |
| T-TPL-002 | テンプレート作成機能テスト | 🔴 RED | 🔲 未着手 | create, copy |
| I-TPL-002 | テンプレート作成機能実装 | 🟢 GREEN | 🔲 未着手 | |
| T-TPL-003 | テンプレートから祭り作成テスト | 🔴 RED | 🔲 未着手 | apply_template |
| I-TPL-003 | テンプレートから祭り作成実装 | 🟢 GREEN | 🔲 未着手 | |
| T-TPL-004 | テンプレート管理LiveViewテスト | 🔴 RED | 🔲 未着手 | |
| I-TPL-004 | テンプレート管理LiveView実装 | 🟢 GREEN | 🔲 未着手 | |
| R-TPL-001 | テンプレート管理リファクタリング | 🔵 REFACTOR | 🔲 未着手 | |

### 4.2 決算報告・年度比較 (#2)

| ID | タスク | TDDフェーズ | 状態 | 備考 |
|----|--------|-------------|------|------|
| T-RPT-001 | 決算サマリー計算テスト | 🔴 RED | 🔲 未着手 | 集計ロジック |
| I-RPT-001 | 決算サマリー計算実装 | 🟢 GREEN | 🔲 未着手 | |
| T-RPT-002 | 年度比較ロジックテスト | 🔴 RED | 🔲 未着手 | 差分計算 |
| I-RPT-002 | 年度比較ロジック実装 | 🟢 GREEN | 🔲 未着手 | |
| T-RPT-003 | PDF出力テスト | 🔴 RED | 🔲 未着手 | |
| I-RPT-003 | PDF出力実装 | 🟢 GREEN | 🔲 未着手 | |
| T-RPT-004 | レポートLiveViewテスト | 🔴 RED | 🔲 未着手 | |
| I-RPT-004 | レポートLiveView実装 | 🟢 GREEN | 🔲 未着手 | |
| R-RPT-001 | 決算報告リファクタリング | 🔵 REFACTOR | 🔲 未着手 | |

### 4.3 グループチャット (#3)

| ID | タスク | TDDフェーズ | 状態 | 備考 |
|----|--------|-------------|------|------|
| T-CHAT-001 | Message/ChatRoomスキーマテスト | 🔴 RED | 🔲 未着手 | |
| I-CHAT-001 | Message/ChatRoomスキーマ実装 | 🟢 GREEN | 🔲 未着手 | |
| T-CHAT-002 | Phoenix Channelsテスト | 🔴 RED | 🔲 未着手 | join, broadcast |
| I-CHAT-002 | Phoenix Channels実装 | 🟢 GREEN | 🔲 未着手 | |
| T-CHAT-003 | 既読管理テスト | 🔴 RED | 🔲 未着手 | |
| I-CHAT-003 | 既読管理実装 | 🟢 GREEN | 🔲 未着手 | |
| T-CHAT-004 | チャットLiveViewテスト | 🔴 RED | 🔲 未着手 | |
| I-CHAT-004 | チャットLiveView実装 | 🟢 GREEN | 🔲 未着手 | |
| R-CHAT-001 | チャットリファクタリング | 🔵 REFACTOR | 🔲 未着手 | |

### 4.4 スタッフ位置表示 (#4)

| ID | タスク | TDDフェーズ | 状態 | 備考 |
|----|--------|-------------|------|------|
| T-LOC-001 | 位置情報スキーマテスト | 🔴 RED | 🔲 未着手 | |
| I-LOC-001 | 位置情報スキーマ実装 | 🟢 GREEN | 🔲 未着手 | |
| T-LOC-002 | Geolocation API連携テスト | 🔴 RED | 🔲 未着手 | モック使用 |
| I-LOC-002 | Geolocation API連携実装 | 🟢 GREEN | 🔲 未着手 | |
| T-LOC-003 | リアルタイム位置更新テスト | 🔴 RED | 🔲 未着手 | PubSub |
| I-LOC-003 | リアルタイム位置更新実装 | 🟢 GREEN | 🔲 未着手 | |
| T-LOC-004 | 会場マップLiveViewテスト | 🔴 RED | 🔲 未着手 | |
| I-LOC-004 | 会場マップLiveView実装 | 🟢 GREEN | 🔲 未着手 | |
| R-LOC-001 | 位置表示リファクタリング | 🔵 REFACTOR | 🔲 未着手 | |

### 4.5 ベトナム語対応 (#5)

| ID | タスク | TDDフェーズ | 状態 | 備考 |
|----|--------|-------------|------|------|
| T-I18N-001 | Gettext設定テスト | 🔴 RED | 🔲 未着手 | ロケール切替 |
| I-I18N-001 | Gettext設定実装 | 🟢 GREEN | 🔲 未着手 | |
| T-I18N-002 | 翻訳ヘルパーテスト | 🔴 RED | 🔲 未着手 | |
| I-I18N-002 | 翻訳ファイル作成 | 🟢 GREEN | 🔲 未着手 | ja, vi |
| T-I18N-003 | 言語切替UIテスト | 🔴 RED | 🔲 未着手 | |
| I-I18N-003 | 言語切替UI実装 | 🟢 GREEN | 🔲 未着手 | |
| R-I18N-001 | 国際化リファクタリング | 🔵 REFACTOR | 🔲 未着手 | |

---

## 5. MVP Backlog

### 5.1 文書管理モジュール (#6)

| ID | タスク | TDDフェーズ | 状態 | 備考 |
|----|--------|-------------|------|------|
| T-DOC-001 | Documentスキーマテスト | 🔴 RED | 🔲 未着手 | |
| I-DOC-001 | Documentスキーマ実装 | 🟢 GREEN | 🔲 未着手 | |
| T-DOC-002 | ファイルアップロードテスト | 🔴 RED | 🔲 未着手 | |
| I-DOC-002 | ファイルアップロード実装 | 🟢 GREEN | 🔲 未着手 | |
| T-DOC-003 | バージョン管理テスト | 🔴 RED | 🔲 未着手 | |
| I-DOC-003 | バージョン管理実装 | 🟢 GREEN | 🔲 未着手 | |
| T-DOC-004 | 検索機能テスト | 🔴 RED | 🔲 未着手 | |
| I-DOC-004 | 検索機能実装 | 🟢 GREEN | 🔲 未着手 | |
| T-DOC-005 | 文書管理LiveViewテスト | 🔴 RED | 🔲 未着手 | |
| I-DOC-005 | 文書管理LiveView実装 | 🟢 GREEN | 🔲 未着手 | |
| R-DOC-001 | 文書管理リファクタリング | 🔵 REFACTOR | 🔲 未着手 | |

### 5.2 プッシュ通知・お知らせ (#7)

| ID | タスク | TDDフェーズ | 状態 | 備考 |
|----|--------|-------------|------|------|
| T-NOTIF-001 | Announcementスキーマテスト | 🔴 RED | 🔲 未着手 | |
| I-NOTIF-001 | Announcementスキーマ実装 | 🟢 GREEN | 🔲 未着手 | |
| T-NOTIF-002 | Service Workerテスト | 🔴 RED | 🔲 未着手 | |
| I-NOTIF-002 | Service Worker実装 | 🟢 GREEN | 🔲 未着手 | |
| T-NOTIF-003 | Web Push APIテスト | 🔴 RED | 🔲 未着手 | |
| I-NOTIF-003 | Web Push API実装 | 🟢 GREEN | 🔲 未着手 | |
| T-NOTIF-004 | お知らせLiveViewテスト | 🔴 RED | 🔲 未着手 | |
| I-NOTIF-004 | お知らせLiveView実装 | 🟢 GREEN | 🔲 未着手 | |
| R-NOTIF-001 | 通知リファクタリング | 🔵 REFACTOR | 🔲 未着手 | |

### 5.3 シフト管理・配置図 (#8)

| ID | タスク | TDDフェーズ | 状態 | 備考 |
|----|--------|-------------|------|------|
| T-SHIFT-001 | Shiftスキーマテスト | 🔴 RED | 🔲 未着手 | |
| I-SHIFT-001 | Shiftスキーマ実装 | 🟢 GREEN | 🔲 未着手 | |
| T-SHIFT-002 | シフト割当ロジックテスト | 🔴 RED | 🔲 未着手 | 重複チェック |
| I-SHIFT-002 | シフト割当ロジック実装 | 🟢 GREEN | 🔲 未着手 | |
| T-SHIFT-003 | シフト表LiveViewテスト | 🔴 RED | 🔲 未着手 | |
| I-SHIFT-003 | シフト表LiveView実装 | 🟢 GREEN | 🔲 未着手 | |
| T-SHIFT-004 | 配置図エディタテスト | 🔴 RED | 🔲 未着手 | |
| I-SHIFT-004 | 配置図エディタ実装 | 🟢 GREEN | 🔲 未着手 | |
| R-SHIFT-001 | シフト管理リファクタリング | 🔵 REFACTOR | 🔲 未着手 | |

### 5.4 ガントチャート表示 (#9)

| ID | タスク | TDDフェーズ | 状態 | 備考 |
|----|--------|-------------|------|------|
| T-GANTT-001 | ガントチャートデータ変換テスト | 🔴 RED | 🔲 未着手 | |
| I-GANTT-001 | ガントチャートデータ変換実装 | 🟢 GREEN | 🔲 未着手 | |
| T-GANTT-002 | 依存関係計算テスト | 🔴 RED | 🔲 未着手 | クリティカルパス |
| I-GANTT-002 | 依存関係計算実装 | 🟢 GREEN | 🔲 未着手 | |
| T-GANTT-003 | ガントチャートLiveViewテスト | 🔴 RED | 🔲 未着手 | |
| I-GANTT-003 | ガントチャートLiveView実装 | 🟢 GREEN | 🔲 未着手 | |
| R-GANTT-001 | ガントチャートリファクタリング | 🔵 REFACTOR | 🔲 未着手 | |

### 5.5 PWA対応 (#10)

| ID | タスク | TDDフェーズ | 状態 | 備考 |
|----|--------|-------------|------|------|
| T-PWA-001 | Service Worker登録テスト | 🔴 RED | 🔲 未着手 | |
| I-PWA-001 | Service Worker登録実装 | 🟢 GREEN | 🔲 未着手 | |
| T-PWA-002 | オフラインキャッシュテスト | 🔴 RED | 🔲 未着手 | |
| I-PWA-002 | オフラインキャッシュ実装 | 🟢 GREEN | 🔲 未着手 | |
| T-PWA-003 | マニフェストテスト | 🔴 RED | 🔲 未着手 | |
| I-PWA-003 | マニフェスト実装 | 🟢 GREEN | 🔲 未着手 | |
| T-PWA-004 | Background Syncテスト | 🔴 RED | 🔲 未着手 | |
| I-PWA-004 | Background Sync実装 | 🟢 GREEN | 🔲 未着手 | |
| R-PWA-001 | PWAリファクタリング | 🔵 REFACTOR | 🔲 未着手 | |

---

## 6. Phase 3: 将来拡張

| ID | タスク | TDDフェーズ | 状態 | 備考 |
|----|--------|-------------|------|------|
| T-P3-001 | ネイティブアプリテスト設計 | 🔴 RED | 🔲 未着手 | LiveView Native |
| I-P3-001 | ネイティブアプリ実装 | 🟢 GREEN | 🔲 未着手 | |
| T-P3-002 | ライブカメラ連携テスト | 🔴 RED | 🔲 未着手 | |
| I-P3-002 | ライブカメラ連携実装 | 🟢 GREEN | 🔲 未着手 | |
| T-P3-003 | 予測分析テスト | 🔴 RED | 🔲 未着手 | |
| I-P3-003 | 予測分析実装 | 🟢 GREEN | 🔲 未着手 | |
| T-P3-004 | 協賛金管理テスト | 🔴 RED | 🔲 未着手 | |
| I-P3-004 | 協賛金管理実装 | 🟢 GREEN | 🔲 未着手 | |

---

## 7. 技術的負債・品質改善

| ID | タスク | TDDフェーズ | 優先度 | 状態 | 備考 |
|----|--------|-------------|--------|------|------|
| TD-001 | 未使用aliasの削除 | 🔵 REFACTOR | 低 | 🔲 未着手 | コンパイル警告対応 |
| T-TD-002 | 既存コードのテスト追加 | 🔴 RED | 高 | 🔲 未着手 | カバレッジ80%目標 |
| T-TD-003 | E2Eテスト追加 | 🔴 RED | 中 | 🔲 未着手 | Wallaby検討 |
| I-TD-003 | E2Eテスト環境構築 | 🟢 GREEN | 中 | 🔲 未着手 | |
| TD-004 | パフォーマンス最適化 | 🔵 REFACTOR | 低 | 🔲 未着手 | N+1クエリ対策 |
| T-TD-005 | アクセシビリティテスト | 🔴 RED | 中 | 🔲 未着手 | WCAG 2.1 AA |
| I-TD-005 | アクセシビリティ対応 | 🟢 GREEN | 中 | 🔲 未着手 | |
| TD-006 | エラーハンドリング強化 | 🔵 REFACTOR | 中 | 🔲 未着手 | |
| TD-007 | ログ出力整備 | 🔵 REFACTOR | 低 | 🔲 未着手 | |

---

## 8. テスト実行コマンド

```bash
# 全テスト実行
mix test

# 特定ファイルのテスト
mix test test/matsuri_ops/festivals_test.exs

# カバレッジ付き実行
mix test --cover

# 失敗したテストのみ再実行
mix test --failed

# ウォッチモード（ファイル変更時に自動実行）
mix test.watch
```

---

## 9. 凡例

### 状態

| 記号 | 意味 |
|------|------|
| ✅ | 完了 |
| 🔄 | 進行中 |
| 🔲 | 未着手 |
| ⏸️ | 保留 |
| ❌ | 中止 |

### TDDフェーズ

| 記号 | フェーズ | 説明 |
|------|----------|------|
| 🔴 RED | テスト作成 | 失敗するテストを書く |
| 🟢 GREEN | 実装 | テストを通す最小限のコードを書く |
| 🔵 REFACTOR | リファクタリング | コードを改善する |

---

## 10. 参照

- 要件定義書（docs/requirements.md）
- 基本設計書（docs/basic_design.md）
- GitHub Issues: https://github.com/YukiKudo03/matsuri_ops/issues
- [ExUnit Documentation](https://hexdocs.pm/ex_unit/ExUnit.html)
- [Phoenix Testing Guide](https://hexdocs.pm/phoenix/testing.html)
