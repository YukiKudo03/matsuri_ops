# MatsuriOps ドキュメント

> 祭り運営管理システム MatsuriOps の公式ドキュメント

---

## ドキュメント一覧

### ユーザーガイド

| ドキュメント | 対象ユーザー | 説明 |
|-------------|-------------|------|
| [クイックスタートガイド](quickstart.md) | 全ユーザー | 5分で始められる基本操作ガイド |
| [管理者マニュアル](manual_admin.md) | システム管理者・実行委員・事務局 | 全機能の詳細操作マニュアル |
| [スタッフマニュアル](manual_staff.md) | リーダー・スタッフ・ボランティア | 担当業務に必要な操作方法 |
| [外部ユーザーガイド](manual_external.md) | 出店者・来場者 | 情報確認・コミュニケーション機能 |

### 開発者向け

| ドキュメント | 説明 |
|-------------|------|
| [要件定義書](requirements.md) | システム要件・機能要件 |
| [基本設計書](basic_design.md) | アーキテクチャ・データベース設計 |
| [タスク管理](tasks.md) | 開発タスクの進捗管理 |
| [テストレポート](TEST_REPORT.md) | テスト実行結果・カバレッジ |
| [E2Eテスト計画](e2e_test_plan.md) | E2Eフィーチャーテストの仕様 |
| [セッションログ](session_log.md) | 開発セッションの記録 |

### コードマップ

| ドキュメント | 説明 |
|-------------|------|
| [CODEMAPS/architecture.md](CODEMAPS/architecture.md) | システム全体構成・レイヤー図・ドメイン一覧 |
| [CODEMAPS/backend.md](CODEMAPS/backend.md) | ルーティング・コンテキスト・認証フロー |
| [CODEMAPS/frontend.md](CODEMAPS/frontend.md) | コンポーネント階層・デザインシステム・JS |
| [CODEMAPS/data.md](CODEMAPS/data.md) | ER図・テーブル定義・ステータスワークフロー |
| [CODEMAPS/dependencies.md](CODEMAPS/dependencies.md) | 外部依存・サービス統合 |

### 画像リソース

| ディレクトリ | 説明 |
|-------------|------|
| [images/](images/) | スクリーンショット・画像ファイル |
| [images/SCREENSHOT_GUIDE.md](images/SCREENSHOT_GUIDE.md) | スクリーンショット取得ガイド |

---

## ユーザーロール

MatsuriOpsは8種類のユーザーロールをサポートしています：

| ロール | 日本語名 | 権限レベル |
|--------|---------|-----------|
| system_admin | システム管理者 | 最高 |
| executive | 実行委員 | 高 |
| admin | 事務局 | 高 |
| leader | リーダー | 中 |
| staff | スタッフ | 低 |
| volunteer | ボランティア | 低 |
| vendor | 出店者 | 限定 |
| visitor | 来場者 | 限定 |

---

## クイックリンク

### 初めての方
1. [クイックスタートガイド](quickstart.md) - まずはこちらから

### 機能別
- **タスク管理**: [管理者](manual_admin.md#4-タスク管理) / [スタッフ](manual_staff.md#2-自分のタスク確認)
- **シフト管理**: [管理者](manual_admin.md#6-シフト管理) / [スタッフ](manual_staff.md#3-シフト確認)
- **予算管理**: [管理者](manual_admin.md#5-予算管理)
- **当日運営**: [管理者](manual_admin.md#7-当日運営) / [スタッフ](manual_staff.md#4-当日の操作)
- **チャット**: [管理者](manual_admin.md#91-チャット) / [スタッフ](manual_staff.md#5-チャット連絡)
- **お知らせ**: [管理者](manual_admin.md#92-お知らせ) / [スタッフ](manual_staff.md#6-お知らせ確認) / [外部](manual_external.md#3-お知らせの受信)

---

## 動作環境

| 環境 | 対応状況 |
|------|---------|
| Chrome（推奨） | ✅ |
| Safari | ✅ |
| Firefox | ✅ |
| Edge | ✅ |
| スマートフォン（PWA） | ✅ |

---

## サポート

問題が発生した場合は、各マニュアルのトラブルシューティングセクションを参照してください。

---

*最終更新: 2026年3月*
