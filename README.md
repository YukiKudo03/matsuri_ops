# MatsuriOps

祭り運営管理システム - 地域の祭りやイベントの運営を効率化するWebアプリケーション

## 主な機能

- 祭り情報の一元管理（作成・編集・テンプレート）
- タスク・スケジュール管理（ガントチャート対応）
- 予算・経費・収入管理
- スタッフ配置・シフト管理
- 当日運営支援（インシデント対応、エリア監視）
- リアルタイムチャット
- QRコード・広告バナー・フォトギャラリー
- PWA対応

## 技術スタック

- **言語**: Elixir 1.17
- **フレームワーク**: Phoenix 1.8.5 / Phoenix LiveView 1.1
- **データベース**: PostgreSQL 16
- **フロントエンド**: Tailwind CSS, esbuild
- **テスト**: ExUnit, Wallaby (E2E)

## セットアップ

### ローカル開発

```bash
mix setup           # 依存関係インストール + DB作成 + アセットビルド
mix phx.server      # サーバー起動 → http://localhost:4000
```

### Docker開発

```bash
docker compose up   # app + db を起動 → http://localhost:4000
```

<!-- AUTO-GENERATED: commands -->
## コマンドリファレンス

| コマンド | 説明 |
|---------|------|
| `mix setup` | 依存関係取得 + DB作成/マイグレーション + アセットビルド |
| `mix phx.server` | 開発サーバー起動 (port 4000) |
| `mix test` | ユニットテスト実行（E2Eフィーチャーテスト除外） |
| `mix test --include feature` | E2Eフィーチャーテスト含む全テスト実行 |
| `mix test --cover` | カバレッジ付きテスト実行 |
| `mix ecto.setup` | DB作成 + マイグレーション + シードデータ |
| `mix ecto.reset` | DBドロップ + 再セットアップ |
| `mix precommit` | コンパイル(warnings-as-errors) + format + test |
| `mix assets.build` | Tailwind + esbuild ビルド |
| `mix assets.deploy` | 本番用アセットビルド（minify + digest） |
<!-- AUTO-GENERATED: commands:end -->

<!-- AUTO-GENERATED: docker -->
## Docker サービス

| サービス | Dockerfile | 用途 | ポート |
|---------|-----------|------|-------|
| `db` | postgres:16-alpine | PostgreSQLデータベース | 5432 |
| `app` | Dockerfile.dev | 開発サーバー | 4000 |
| `test` | Dockerfile.test | E2Eテスト (Chrome内蔵) | - |

```bash
# 開発環境
docker compose up

# E2Eテスト実行
docker compose --profile test run --rm test

# ユニットテスト実行
docker compose run --rm -e MIX_ENV=test -e DATABASE_HOST=db app mix test
```
<!-- AUTO-GENERATED: docker:end -->

<!-- AUTO-GENERATED: env -->
## 環境変数

### 本番環境（必須）

| 変数 | 説明 | 例 |
|------|------|-----|
| `DATABASE_URL` | PostgreSQL接続文字列 | `ecto://USER:PASS@HOST/DATABASE` |
| `SECRET_KEY_BASE` | Cookie署名用秘密鍵（`mix phx.gen.secret`で生成） | 64文字以上のランダム文字列 |
| `PHX_HOST` | アプリケーションホスト名 | `example.com` |

### 本番環境（オプション）

| 変数 | 説明 | デフォルト |
|------|------|-----------|
| `PORT` | HTTPポート | `4000` |
| `PHX_SERVER` | サーバー自動起動 | 未設定 |
| `POOL_SIZE` | DBコネクションプールサイズ | `10` |
| `ECTO_IPV6` | IPv6有効化 | 未設定 |
| `DNS_CLUSTER_QUERY` | DNSクラスタクエリ | 未設定 |

### 開発/テスト環境

| 変数 | 説明 | デフォルト |
|------|------|-----------|
| `DATABASE_HOST` | DBホスト名 | `localhost` |
| `MIX_TEST_PARTITION` | テストパーティション（CI用） | 未設定 |
<!-- AUTO-GENERATED: env:end -->

## ドキュメント

詳細は [docs/](docs/README.md) を参照してください。
