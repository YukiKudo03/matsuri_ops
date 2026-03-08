# タスク表

## 地域祭り運営支援Webアプリケーション「MatsuriOps」

| 項目 | 内容 |
|------|------|
| 文書名 | タスク表 |
| バージョン | 6.0 |
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
| Phase 2: 拡張機能 | ✅ 完了 | 80%以上 |
| Phase 3: 将来拡張 | ✅ 完了 | 80%以上 |

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
| T-TPL-001 | Templateスキーマテスト作成 | 🔴 RED | ✅ 完了 | changeset, validation |
| I-TPL-001 | Templateスキーマ実装 | 🟢 GREEN | ✅ 完了 | |
| T-TPL-002 | テンプレート作成機能テスト | 🔴 RED | ✅ 完了 | create, copy |
| I-TPL-002 | テンプレート作成機能実装 | 🟢 GREEN | ✅ 完了 | |
| T-TPL-003 | テンプレートから祭り作成テスト | 🔴 RED | ✅ 完了 | apply_template |
| I-TPL-003 | テンプレートから祭り作成実装 | 🟢 GREEN | ✅ 完了 | |
| T-TPL-004 | テンプレート管理LiveViewテスト | 🔴 RED | ✅ 完了 | |
| I-TPL-004 | テンプレート管理LiveView実装 | 🟢 GREEN | ✅ 完了 | |
| R-TPL-001 | テンプレート管理リファクタリング | 🔵 REFACTOR | ✅ 完了 | 未使用alias削除 |

### 4.2 決算報告・年度比較 (#2)

| ID | タスク | TDDフェーズ | 状態 | 備考 |
|----|--------|-------------|------|------|
| T-RPT-001 | 決算サマリー計算テスト | 🔴 RED | ✅ 完了 | 集計ロジック |
| I-RPT-001 | 決算サマリー計算実装 | 🟢 GREEN | ✅ 完了 | |
| T-RPT-002 | 年度比較ロジックテスト | 🔴 RED | ✅ 完了 | 差分計算 |
| I-RPT-002 | 年度比較ロジック実装 | 🟢 GREEN | ✅ 完了 | |
| T-RPT-003 | PDF出力テスト | 🔴 RED | ✅ 完了 | |
| I-RPT-003 | PDF出力実装 | 🟢 GREEN | ✅ 完了 | HTMLベース、chromic_pdf等で拡張可 |
| T-RPT-004 | レポートLiveViewテスト | 🔴 RED | ✅ 完了 | |
| I-RPT-004 | レポートLiveView実装 | 🟢 GREEN | ✅ 完了 | |
| R-RPT-001 | 決算報告リファクタリング | 🔵 REFACTOR | ✅ 完了 | FormattingHelpers抽出 |

### 4.3 グループチャット (#3)

| ID | タスク | TDDフェーズ | 状態 | 備考 |
|----|--------|-------------|------|------|
| T-CHAT-001 | Message/ChatRoomスキーマテスト | 🔴 RED | ✅ 完了 | |
| I-CHAT-001 | Message/ChatRoomスキーマ実装 | 🟢 GREEN | ✅ 完了 | |
| T-CHAT-002 | PubSubリアルタイム通知テスト | 🔴 RED | ✅ 完了 | broadcast |
| I-CHAT-002 | PubSubリアルタイム通知実装 | 🟢 GREEN | ✅ 完了 | |
| T-CHAT-003 | 既読管理テスト | 🔴 RED | ✅ 完了 | |
| I-CHAT-003 | 既読管理実装 | 🟢 GREEN | ✅ 完了 | |
| T-CHAT-004 | チャットLiveViewテスト | 🔴 RED | ✅ 完了 | |
| I-CHAT-004 | チャットLiveView実装 | 🟢 GREEN | ✅ 完了 | |
| R-CHAT-001 | チャットリファクタリング | 🔵 REFACTOR | ✅ 完了 | FormattingHelpers統合 |

### 4.4 スタッフ位置表示 (#4)

| ID | タスク | TDDフェーズ | 状態 | 備考 |
|----|--------|-------------|------|------|
| T-LOC-001 | 位置情報スキーマテスト | 🔴 RED | ✅ 完了 | |
| I-LOC-001 | 位置情報スキーマ実装 | 🟢 GREEN | ✅ 完了 | |
| T-LOC-002 | Geolocation API連携テスト | 🔴 RED | ✅ 完了 | モック使用 |
| I-LOC-002 | Geolocation API連携実装 | 🟢 GREEN | ✅ 完了 | |
| T-LOC-003 | リアルタイム位置更新テスト | 🔴 RED | ✅ 完了 | PubSub |
| I-LOC-003 | リアルタイム位置更新実装 | 🟢 GREEN | ✅ 完了 | |
| T-LOC-004 | 会場マップLiveViewテスト | 🔴 RED | ✅ 完了 | |
| I-LOC-004 | 会場マップLiveView実装 | 🟢 GREEN | ✅ 完了 | |
| R-LOC-001 | 位置表示リファクタリング | 🔵 REFACTOR | ✅ 完了 | 分析完了 |

### 4.5 ベトナム語対応 (#5)

| ID | タスク | TDDフェーズ | 状態 | 備考 |
|----|--------|-------------|------|------|
| T-I18N-001 | Gettext設定テスト | 🔴 RED | ✅ 完了 | ロケール切替 |
| I-I18N-001 | Gettext設定実装 | 🟢 GREEN | ✅ 完了 | |
| T-I18N-002 | 翻訳ヘルパーテスト | 🔴 RED | ✅ 完了 | |
| I-I18N-002 | 翻訳ファイル作成 | 🟢 GREEN | ✅ 完了 | ja, vi |
| T-I18N-003 | 言語切替UIテスト | 🔴 RED | ✅ 完了 | |
| I-I18N-003 | 言語切替UI実装 | 🟢 GREEN | ✅ 完了 | |
| R-I18N-001 | 国際化リファクタリング | 🔵 REFACTOR | ✅ 完了 | LocaleConfig抽出 |

---

## 5. MVP Backlog

### 5.1 文書管理モジュール (#6)

| ID | タスク | TDDフェーズ | 状態 | 備考 |
|----|--------|-------------|------|------|
| T-DOC-001 | Documentスキーマテスト | 🔴 RED | ✅ 完了 | |
| I-DOC-001 | Documentスキーマ実装 | 🟢 GREEN | ✅ 完了 | |
| T-DOC-002 | ファイルアップロードテスト | 🔴 RED | ✅ 完了 | |
| I-DOC-002 | ファイルアップロード実装 | 🟢 GREEN | ✅ 完了 | |
| T-DOC-003 | バージョン管理テスト | 🔴 RED | ✅ 完了 | |
| I-DOC-003 | バージョン管理実装 | 🟢 GREEN | ✅ 完了 | |
| T-DOC-004 | 検索機能テスト | 🔴 RED | ✅ 完了 | |
| I-DOC-004 | 検索機能実装 | 🟢 GREEN | ✅ 完了 | |
| T-DOC-005 | 文書管理LiveViewテスト | 🔴 RED | ✅ 完了 | |
| I-DOC-005 | 文書管理LiveView実装 | 🟢 GREEN | ✅ 完了 | |
| R-DOC-001 | 文書管理リファクタリング | 🔵 REFACTOR | ✅ 完了 | FormattingHelpers統合 |

### 5.2 プッシュ通知・お知らせ (#7)

| ID | タスク | TDDフェーズ | 状態 | 備考 |
|----|--------|-------------|------|------|
| T-NOTIF-001 | Announcementスキーマテスト | 🔴 RED | ✅ 完了 | |
| I-NOTIF-001 | Announcementスキーマ実装 | 🟢 GREEN | ✅ 完了 | |
| T-NOTIF-002 | Service Workerテスト | 🔴 RED | ✅ 完了 | |
| I-NOTIF-002 | Service Worker実装 | 🟢 GREEN | ✅ 完了 | |
| T-NOTIF-003 | Web Push APIテスト | 🔴 RED | ✅ 完了 | |
| I-NOTIF-003 | Web Push API実装 | 🟢 GREEN | ✅ 完了 | |
| T-NOTIF-004 | お知らせLiveViewテスト | 🔴 RED | ✅ 完了 | |
| I-NOTIF-004 | お知らせLiveView実装 | 🟢 GREEN | ✅ 完了 | |
| R-NOTIF-001 | 通知リファクタリング | 🔵 REFACTOR | ✅ 完了 | 分析完了 |

### 5.3 シフト管理・配置図 (#8)

| ID | タスク | TDDフェーズ | 状態 | 備考 |
|----|--------|-------------|------|------|
| T-SHIFT-001 | Shiftスキーマテスト | 🔴 RED | ✅ 完了 | |
| I-SHIFT-001 | Shiftスキーマ実装 | 🟢 GREEN | ✅ 完了 | |
| T-SHIFT-002 | シフト割当ロジックテスト | 🔴 RED | ✅ 完了 | 重複チェック |
| I-SHIFT-002 | シフト割当ロジック実装 | 🟢 GREEN | ✅ 完了 | |
| T-SHIFT-003 | シフト表LiveViewテスト | 🔴 RED | ✅ 完了 | |
| I-SHIFT-003 | シフト表LiveView実装 | 🟢 GREEN | ✅ 完了 | |
| T-SHIFT-004 | 配置図エディタテスト | 🔴 RED | ✅ 完了 | |
| I-SHIFT-004 | 配置図エディタ実装 | 🟢 GREEN | ✅ 完了 | |
| R-SHIFT-001 | シフト管理リファクタリング | 🔵 REFACTOR | ✅ 完了 | N+1最適化済 |

### 5.4 ガントチャート表示 (#9)

| ID | タスク | TDDフェーズ | 状態 | 備考 |
|----|--------|-------------|------|------|
| T-GANTT-001 | ガントチャートデータ変換テスト | 🔴 RED | ✅ 完了 | |
| I-GANTT-001 | ガントチャートデータ変換実装 | 🟢 GREEN | ✅ 完了 | |
| T-GANTT-002 | 依存関係計算テスト | 🔴 RED | ✅ 完了 | クリティカルパス |
| I-GANTT-002 | 依存関係計算実装 | 🟢 GREEN | ✅ 完了 | |
| T-GANTT-003 | ガントチャートLiveViewテスト | 🔴 RED | ✅ 完了 | |
| I-GANTT-003 | ガントチャートLiveView実装 | 🟢 GREEN | ✅ 完了 | |
| R-GANTT-001 | ガントチャートリファクタリング | 🔵 REFACTOR | ✅ 完了 | 分析完了 |

### 5.5 PWA対応 (#10)

| ID | タスク | TDDフェーズ | 状態 | 備考 |
|----|--------|-------------|------|------|
| T-PWA-001 | Service Worker登録テスト | 🔴 RED | ✅ 完了 | |
| I-PWA-001 | Service Worker登録実装 | 🟢 GREEN | ✅ 完了 | |
| T-PWA-002 | オフラインキャッシュテスト | 🔴 RED | ✅ 完了 | |
| I-PWA-002 | オフラインキャッシュ実装 | 🟢 GREEN | ✅ 完了 | |
| T-PWA-003 | マニフェストテスト | 🔴 RED | ✅ 完了 | |
| I-PWA-003 | マニフェスト実装 | 🟢 GREEN | ✅ 完了 | |
| T-PWA-004 | Background Syncテスト | 🔴 RED | ✅ 完了 | |
| I-PWA-004 | Background Sync実装 | 🟢 GREEN | ✅ 完了 | |
| R-PWA-001 | PWAリファクタリング | 🔵 REFACTOR | ✅ 完了 | 分析完了 |

---

## 6. Phase 3: 将来拡張（完了）

### 6.1 ネイティブアプリ対応 (#12)

| ID | タスク | TDDフェーズ | 状態 | 備考 |
|----|--------|-------------|------|------|
| T-P3-001 | プラットフォーム検出テスト | 🔴 RED | ✅ 完了 | iOS/Android/Web |
| I-P3-001 | プラットフォーム検出実装 | 🟢 GREEN | ✅ 完了 | |
| T-P3-002 | ネイティブ機能テスト | 🔴 RED | ✅ 完了 | capabilities |
| I-P3-002 | ネイティブ機能実装 | 🟢 GREEN | ✅ 完了 | |
| T-P3-003 | ディープリンクテスト | 🔴 RED | ✅ 完了 | deep_link, universal_link |
| I-P3-003 | ディープリンク実装 | 🟢 GREEN | ✅ 完了 | |
| R-P3-001 | ネイティブ対応リファクタリング | 🔵 REFACTOR | ✅ 完了 | 分析完了 |

### 6.2 ライブカメラ連携 (#13)

| ID | タスク | TDDフェーズ | 状態 | 備考 |
|----|--------|-------------|------|------|
| T-CAM-001 | Cameraスキーマテスト | 🔴 RED | ✅ 完了 | |
| I-CAM-001 | Cameraスキーマ実装 | 🟢 GREEN | ✅ 完了 | HLS/RTSP/WebRTC/MJPEG |
| T-CAM-002 | 録画管理テスト | 🔴 RED | ✅ 完了 | CameraRecording |
| I-CAM-002 | 録画管理実装 | 🟢 GREEN | ✅ 完了 | |
| T-CAM-003 | カメラステータステスト | 🔴 RED | ✅ 完了 | online/offline |
| I-CAM-003 | カメラステータス実装 | 🟢 GREEN | ✅ 完了 | PubSub連携 |
| R-CAM-001 | カメラ連携リファクタリング | 🔵 REFACTOR | ✅ 完了 | 分析完了 |

### 6.3 予測分析機能 (#14)

| ID | タスク | TDDフェーズ | 状態 | 備考 |
|----|--------|-------------|------|------|
| T-ANA-001 | 来場者予測テスト | 🔴 RED | ✅ 完了 | 線形回帰 |
| I-ANA-001 | 来場者予測実装 | 🟢 GREEN | ✅ 完了 | |
| T-ANA-002 | 予算予測テスト | 🔴 RED | ✅ 完了 | カテゴリ別 |
| I-ANA-002 | 予算予測実装 | 🟢 GREEN | ✅ 完了 | |
| T-ANA-003 | トレンド分析テスト | 🔴 RED | ✅ 完了 | 増加/減少/安定 |
| I-ANA-003 | トレンド分析実装 | 🟢 GREEN | ✅ 完了 | |
| T-ANA-004 | 異常検出テスト | 🔴 RED | ✅ 完了 | 標準偏差ベース |
| I-ANA-004 | 異常検出実装 | 🟢 GREEN | ✅ 完了 | |
| T-ANA-005 | 改善提案テスト | 🔴 RED | ✅ 完了 | recommendations |
| I-ANA-005 | 改善提案実装 | 🟢 GREEN | ✅ 完了 | |
| R-ANA-001 | 予測分析リファクタリング | 🔵 REFACTOR | ✅ 完了 | 分析完了 |

### 6.4 協賛金管理機能 (#15)

| ID | タスク | TDDフェーズ | 状態 | 備考 |
|----|--------|-------------|------|------|
| T-SPO-001 | Sponsorスキーマテスト | 🔴 RED | ✅ 完了 | |
| I-SPO-001 | Sponsorスキーマ実装 | 🟢 GREEN | ✅ 完了 | |
| T-SPO-002 | Sponsorshipスキーマテスト | 🔴 RED | ✅ 完了 | ティア管理 |
| I-SPO-002 | Sponsorshipスキーマ実装 | 🟢 GREEN | ✅ 完了 | platinum/gold/silver/bronze/supporter |
| T-SPO-003 | 特典管理テスト | 🔴 RED | ✅ 完了 | SponsorBenefit |
| I-SPO-003 | 特典管理実装 | 🟢 GREEN | ✅ 完了 | |
| T-SPO-004 | 統計・サマリーテスト | 🔴 RED | ✅ 完了 | |
| I-SPO-004 | 統計・サマリー実装 | 🟢 GREEN | ✅ 完了 | |
| R-SPO-001 | 協賛金管理リファクタリング | 🔵 REFACTOR | ✅ 完了 | 分析完了 |

---

## 7. ドキュメント整備 (#17)

| ID | タスク | 状態 | 備考 |
|----|--------|------|------|
| DOC-001 | クイックスタートガイド作成 | ✅ 完了 | docs/quickstart.md |
| DOC-002 | 管理者マニュアル作成 | ✅ 完了 | docs/manual_admin.md |
| DOC-003 | スタッフマニュアル作成 | ✅ 完了 | docs/manual_staff.md |
| DOC-004 | 外部ユーザーガイド作成 | ✅ 完了 | docs/manual_external.md |
| DOC-005 | スクリーンショット自動取得 | ✅ 完了 | Wallaby使用、18画面 |
| DOC-006 | スクリーンショットガイド作成 | ✅ 完了 | docs/images/SCREENSHOT_GUIDE.md |

### スクリーンショット一覧

| ファイル | 画面 |
|----------|------|
| ss_login.png | ログイン画面 |
| ss_register.png | 新規登録画面 |
| ss_settings.png | 設定画面 |
| ss_festival_list.png | 祭り一覧 |
| ss_festival_form.png | 祭り作成フォーム |
| ss_festival_show.png | 祭り詳細 |
| ss_task_list.png | タスク一覧 |
| ss_task_form.png | タスク作成フォーム |
| ss_budget_dashboard.png | 予算ダッシュボード |
| ss_expense_form.png | 経費登録フォーム |
| ss_staff_list.png | スタッフ一覧 |
| ss_shift_list.png | シフト一覧 |
| ss_operations.png | 運営ダッシュボード |
| ss_incident_form.png | インシデント報告フォーム |
| ss_chat_room.png | チャットルーム |
| ss_announcements.png | お知らせ一覧 |
| ss_report.png | レポート画面 |
| ss_gantt.png | ガントチャート |

---

## 8. 技術的負債・品質改善

| ID | タスク | TDDフェーズ | 優先度 | 状態 | 備考 |
|----|--------|-------------|--------|------|------|
| TD-001 | 未使用aliasの削除 | 🔵 REFACTOR | 低 | ✅ 完了 | 警告なし確認 |
| T-TD-002 | 既存コードのテスト追加 | 🔴 RED | 高 | ✅ 完了 | 325件テスト通過 |
| T-TD-003 | E2Eテスト追加 | 🔴 RED | 中 | ✅ 完了 | Wallaby導入 |
| I-TD-003 | E2Eテスト環境構築 | 🟢 GREEN | 中 | ✅ 完了 | feature_case.ex作成 |
| TD-004 | パフォーマンス最適化 | 🔵 REFACTOR | 低 | ✅ 完了 | tasks/budgets/shiftsにpreload追加 |
| T-TD-005 | アクセシビリティテスト | 🔴 RED | 中 | ✅ 完了 | WCAG 2.1 AA |
| I-TD-005 | アクセシビリティ対応 | 🟢 GREEN | 中 | ✅ 完了 | モーダルaria属性追加 |
| TD-006 | エラーハンドリング強化 | 🔵 REFACTOR | 中 | ✅ 完了 | MatsuriOps.Error作成 |
| TD-007 | ログ出力整備 | 🔵 REFACTOR | 低 | ✅ 完了 | MatsuriOps.Logger作成 |

---

## 9. テスト実行コマンド

### 9.1 ユニットテスト・統合テスト

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

### 9.2 E2Eテスト

**前提条件**: ChromeDriverがインストールされていること

```bash
# ChromeDriverインストール（macOS）
brew install chromedriver

# E2Eテストのみ実行
mix test test/features/

# 特定のE2Eテスト実行
mix test test/features/authentication_test.exs

# ヘッドレスモード無効（ブラウザ表示）
# config/test.exs の chromedriver.headless を false に変更

# スクリーンショット確認
ls tmp/wallaby_screenshots/
```

### 9.3 E2Eテスト構成

| ファイル | テスト対象 |
|----------|-----------|
| `test/features/authentication_test.exs` | 認証フロー（登録、ログイン、ログアウト） |
| `test/features/festival_management_test.exs` | 祭り管理（CRUD、ナビゲーション） |
| `test/features/operations_dashboard_test.exs` | 運営ダッシュボード（インシデント、エリア、リアルタイム） |

### 9.4 E2Eテスト作成ガイド

```elixir
# test/features/example_test.exs
defmodule MatsuriOpsWeb.Features.ExampleTest do
  use MatsuriOpsWeb.FeatureCase, async: true

  feature "ユーザーが操作を完了できる", %{session: session} do
    session
    |> visit("/path")
    |> fill_in(css("input[name='field']"), with: "値")
    |> click(button("ボタン"))
    |> wait_for_liveview()
    |> assert_has(css(".success", text: "完了"))
  end
end
```

---

## 10. 凡例

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

## 11. 参照

- 要件定義書（docs/requirements.md）
- 基本設計書（docs/basic_design.md）
- クイックスタートガイド（docs/quickstart.md）
- 管理者マニュアル（docs/manual_admin.md）
- スタッフマニュアル（docs/manual_staff.md）
- 外部ユーザーガイド（docs/manual_external.md）
- GitHub Issues: https://github.com/YukiKudo03/matsuri_ops/issues
- [ExUnit Documentation](https://hexdocs.pm/ex_unit/ExUnit.html)
- [Phoenix Testing Guide](https://hexdocs.pm/phoenix/testing.html)
- [Wallaby E2E Testing](https://hexdocs.pm/wallaby/readme.html)
