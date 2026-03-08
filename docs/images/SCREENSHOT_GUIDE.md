# スクリーンショット取得ガイド

このガイドに従って、ドキュメント用のスクリーンショットを取得してください。

---

## 自動取得（Wallaby使用）

Wallabyを使用した自動取得が可能です。

### 前提条件

1. **ローカル環境**での実行が必要（Docker内では不可）
2. ChromeDriverがインストールされていること
3. Elixir/Erlangがインストールされていること

### ChromeDriverのインストール

```bash
# macOS
brew install chromedriver

# Ubuntu/Debian
sudo apt-get install chromium-chromedriver
```

### 実行方法

```bash
# 1. 依存関係をインストール
mix deps.get

# 2. データベースセットアップ（Docker経由）
docker compose up -d db
export DATABASE_URL="ecto://postgres:postgres@localhost:5432/matsuri_ops_test"

# 3. スクリーンショット取得スクリプト実行
MIX_ENV=test mix run test/support/screenshot_capture.exs
```

### 出力

スクリーンショットは `docs/images/` に自動保存されます。

### トラブルシューティング

- **ChromeDriverエラー**: `brew upgrade chromedriver` でバージョンを更新
- **接続エラー**: Dockerのdbコンテナが起動しているか確認

---

## 手動取得

自動取得がうまくいかない場合は、手動で取得してください。

### 準備

1. Docker環境が起動していることを確認

   ```bash
   docker compose up -d
   ```

2. ブラウザで <http://localhost:4000> にアクセス

3. テストユーザーを作成してログイン

### 取得方法

- **macOS**: Cmd + Shift + 4 で範囲選択スクリーンショット
- **Windows**: Win + Shift + S でSnipping Tool
- **ブラウザ**: 開発者ツール → Device Toolbarでモバイル表示も可能

### 推奨サイズ

- 幅: 1200px
- ブラウザのURLバーは除外
- 余白は最小限に

---

## スクリーンショット一覧

### 認証関連

| ファイル名 | URL | 説明 |
| ---------- | --- | ---- |
| `ss_login.png` | `/users/log-in` | ログイン画面 |
| `ss_register.png` | `/users/register` | 新規登録画面 |
| `ss_settings.png` | `/users/settings` | 設定画面（ログイン後） |

### 祭り管理

| ファイル名 | URL | 説明 |
| ---------- | --- | ---- |
| `ss_festival_list.png` | `/festivals` | 祭り一覧画面 |
| `ss_festival_form.png` | `/festivals/new` | 祭り作成フォーム（モーダル） |
| `ss_festival_show.png` | `/festivals/{id}` | 祭り詳細画面 |

### タスク管理

| ファイル名 | URL | 説明 |
| ---------- | --- | ---- |
| `ss_task_list.png` | `/festivals/{id}/tasks` | タスク一覧 |
| `ss_task_form.png` | `/festivals/{id}/tasks` → 新規作成 | タスク作成フォーム（モーダル） |

### 予算管理

| ファイル名 | URL | 説明 |
| ---------- | --- | ---- |
| `ss_budget_dashboard.png` | `/festivals/{id}/budgets` | 予算ダッシュボード |
| `ss_expense_form.png` | `/festivals/{id}/budgets` → 経費登録 | 経費登録フォーム（モーダル） |

### スタッフ・シフト

| ファイル名 | URL | 説明 |
| ---------- | --- | ---- |
| `ss_staff_list.png` | `/festivals/{id}/staff` | スタッフ一覧 |
| `ss_shift_list.png` | `/festivals/{id}/shifts` | シフト一覧 |

### 当日運営

| ファイル名 | URL | 説明 |
| ---------- | --- | ---- |
| `ss_operations.png` | `/festivals/{id}/operations` | 運営ダッシュボード |
| `ss_incident_form.png` | `/festivals/{id}/operations` → インシデント報告 | インシデント報告フォーム |

### コミュニケーション

| ファイル名 | URL | 説明 |
| ---------- | --- | ---- |
| `ss_chat_room.png` | `/festivals/{id}/chat/{room_id}` | チャットルーム |
| `ss_announcements.png` | `/festivals/{id}/announcements` | お知らせ一覧 |

### その他

| ファイル名 | URL | 説明 |
| ---------- | --- | ---- |
| `ss_report.png` | `/festivals/{id}/reports` | レポート画面 |
| `ss_gantt.png` | `/festivals/{id}/gantt` | ガントチャート |

---

## チェックリスト

取得したらチェックしてください：

- [ ] ss_login.png
- [ ] ss_register.png
- [ ] ss_settings.png
- [ ] ss_festival_list.png
- [ ] ss_festival_form.png
- [ ] ss_festival_show.png
- [ ] ss_task_list.png
- [ ] ss_task_form.png
- [ ] ss_budget_dashboard.png
- [ ] ss_expense_form.png
- [ ] ss_staff_list.png
- [ ] ss_shift_list.png
- [ ] ss_operations.png
- [ ] ss_incident_form.png
- [ ] ss_chat_room.png
- [ ] ss_announcements.png
- [ ] ss_report.png
- [ ] ss_gantt.png

---

## 注意事項

1. **個人情報**: テストデータには架空の情報を使用
2. **日本語UI**: 日本語で表示されていることを確認
3. **ファイル形式**: PNG形式で保存
4. **ファイルサイズ**: 大きすぎる場合は圧縮（目安: 200KB以下）
