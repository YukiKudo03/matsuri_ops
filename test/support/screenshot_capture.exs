# スクリーンショット自動取得スクリプト
#
# 使用方法:
#   MIX_ENV=test mix run test/support/screenshot_capture.exs
#
# 前提条件:
#   - ChromeDriverがインストールされていること
#   - データベースがセットアップされていること

# 必要なアプリケーションを起動
Application.ensure_all_started(:postgrex)
Application.ensure_all_started(:ecto_sql)

# Wallabyの設定と起動
Application.put_env(:wallaby, :driver, Wallaby.Chrome)
Application.put_env(:wallaby, :chromedriver, [
  path: System.get_env("HOME") <> "/.local/bin/chromedriver",
  headless: true
])
Application.put_env(:wallaby, :base_url, "http://localhost:4002")
{:ok, _} = Application.ensure_all_started(:wallaby)

# Repoを起動
case MatsuriOps.Repo.start_link() do
  {:ok, _} -> :ok
  {:error, {:already_started, _}} -> :ok
end

# Endpointを起動（テスト用サーバー）
case MatsuriOpsWeb.Endpoint.start_link() do
  {:ok, _} -> :ok
  {:error, {:already_started, _}} -> :ok
end

defmodule ScreenshotCapture do
  @moduledoc """
  ドキュメント用スクリーンショット自動取得モジュール。
  """

  import Wallaby.Query

  @output_dir "docs/images"

  @screenshots [
    # 認証関連（公開ページ）
    {:ss_login, "/users/log_in", "ログイン画面"},
    {:ss_register, "/users/register", "新規登録画面"}
  ]

  @authenticated_screenshots [
    # 設定
    {:ss_settings, "/users/settings", "設定画面"},

    # 祭り管理
    {:ss_festival_list, "/festivals", "祭り一覧"},
    {:ss_festival_show, "/festivals/:id", "祭り詳細"},

    # タスク管理
    {:ss_task_list, "/festivals/:id/tasks", "タスク一覧"},

    # 予算管理
    {:ss_budget_dashboard, "/festivals/:id/budgets", "予算ダッシュボード"},

    # スタッフ・シフト
    {:ss_staff_list, "/festivals/:id/staff", "スタッフ一覧"},
    {:ss_shift_list, "/festivals/:id/shifts", "シフト一覧"},

    # 当日運営
    {:ss_operations, "/festivals/:id/operations", "運営ダッシュボード"},

    # コミュニケーション
    {:ss_announcements, "/festivals/:id/announcements", "お知らせ一覧"},

    # その他
    {:ss_report, "/festivals/:id/reports", "レポート画面"},
    {:ss_gantt, "/festivals/:id/gantt", "ガントチャート"}
  ]

  def run do
    IO.puts("\n📸 スクリーンショット自動取得を開始します...\n")
    IO.puts("出力先: #{@output_dir}\n")

    # 出力ディレクトリ作成
    File.mkdir_p!(@output_dir)

    # Wallaby起動
    Application.ensure_all_started(:wallaby)
    {:ok, session} = Wallaby.start_session()

    try do
      # 公開ページのスクリーンショット
      IO.puts("=== 公開ページ ===\n")
      capture_public_pages(session)

      # ユーザー登録・ログイン
      IO.puts("\n=== ユーザー認証 ===\n")
      {session, _user} = register_and_login(session)

      # 祭り作成
      IO.puts("\n=== 祭り作成 ===\n")
      {session, festival_id} = create_festival(session)

      # 認証後のページ
      IO.puts("\n=== 認証後ページ ===\n")
      capture_authenticated_pages(session, festival_id)

      # モーダルのスクリーンショット
      IO.puts("\n=== モーダル ===\n")
      capture_modals(session, festival_id)

      IO.puts("\n✅ 完了しました！\n")
    after
      Wallaby.end_session(session)
    end
  end

  defp capture_public_pages(session) do
    Enum.each(@screenshots, fn {name, path, desc} ->
      capture(session, name, path, desc)
    end)
  end

  defp capture_authenticated_pages(session, festival_id) do
    Enum.each(@authenticated_screenshots, fn {name, path, desc} ->
      actual_path = String.replace(path, ":id", to_string(festival_id))
      capture(session, name, actual_path, desc)
    end)
  end

  defp capture(session, name, path, desc) do
    IO.write("  #{name}: #{desc}... ")

    try do
      session
      |> Wallaby.Browser.visit(path)
      |> wait(800)
      |> Wallaby.Browser.take_screenshot(name: Path.join(@output_dir, "#{name}.png"))

      IO.puts("✓")
    rescue
      e ->
        IO.puts("✗ (#{inspect(e)})")
    end

    session
  end

  defp register_and_login(session) do
    email = "screenshot_#{System.system_time(:second)}@example.com"

    IO.puts("  テストユーザー作成: #{email}")

    # 登録ページへ移動
    session =
      session
      |> Wallaby.Browser.visit("/users/register")
      |> wait(2000)

    # フォームが表示されるまで待機してから入力
    session =
      try do
        session
        |> Wallaby.Browser.fill_in(css("#registration_form input[type='email']"), with: email)
        |> Wallaby.Browser.click(css("#registration_form button[type='submit']"))
        |> wait(2000)
      rescue
        e1 ->
          IO.puts("    (フォームセレクタ1失敗: #{inspect(e1)})")
          try do
            session
            |> Wallaby.Browser.fill_in(css("form input[type='email']"), with: email)
            |> Wallaby.Browser.click(css("form button"))
            |> wait(2000)
          rescue
            e2 ->
              IO.puts("    (フォームセレクタ2失敗: #{inspect(e2)})")
              # 認証なしで続行
              session
          end
      end

    IO.puts("  ✓ 登録試行完了")

    {session, %{email: email}}
  end

  defp create_festival(session) do
    IO.puts("  テスト祭りを作成中...")

    session =
      session
      |> Wallaby.Browser.visit("/festivals")
      |> wait(1000)

    # 新規作成ボタンをクリック
    session =
      try do
        session
        |> Wallaby.Browser.click(css("button", text: "新規作成"))
        |> wait(800)
      rescue
        _ ->
          try do
            session
            |> Wallaby.Browser.click(css("a", text: "新規作成"))
            |> wait(800)
          rescue
            _ -> session
          end
      end

    # フォーム入力
    session =
      try do
        session
        |> Wallaby.Browser.fill_in(css("input#festival_name, input[name*='name']"), with: "スクリーンショット用テスト祭り")
        |> Wallaby.Browser.fill_in(css("input#festival_start_date, input[name*='start_date']"), with: "2026-08-15")
        |> Wallaby.Browser.fill_in(css("input#festival_end_date, input[name*='end_date']"), with: "2026-08-16")
      rescue
        _ -> session
      end

    # ss_festival_form のスクリーンショット（モーダルが開いている場合）
    try do
      Wallaby.Browser.take_screenshot(session, name: Path.join(@output_dir, "ss_festival_form.png"))
      IO.puts("  ss_festival_form: 祭り作成フォーム... ✓")
    rescue
      _ -> IO.puts("  ss_festival_form: 祭り作成フォーム... ✗")
    end

    # 送信
    session =
      try do
        session
        |> Wallaby.Browser.click(css("button[type='submit']"))
        |> wait(1500)
      rescue
        _ -> session
      end

    # 祭りIDを取得
    url = Wallaby.Browser.current_url(session)
    festival_id = extract_festival_id(url) || "1"

    IO.puts("  ✓ 祭り作成完了 (ID: #{festival_id})")

    {session, festival_id}
  end

  defp capture_modals(session, festival_id) do
    modals = [
      {:ss_task_form, "/festivals/#{festival_id}/tasks", "新規タスク", "タスク作成フォーム"},
      {:ss_expense_form, "/festivals/#{festival_id}/budgets", "経費登録", "経費登録フォーム"},
      {:ss_incident_form, "/festivals/#{festival_id}/operations", "インシデント報告", "インシデント報告フォーム"}
    ]

    Enum.each(modals, fn {name, path, button_text, desc} ->
      capture_modal(session, name, path, button_text, desc)
    end)
  end

  defp capture_modal(session, name, path, button_text, desc) do
    IO.write("  #{name}: #{desc}... ")

    try do
      session
      |> Wallaby.Browser.visit(path)
      |> wait(800)
      |> Wallaby.Browser.click(css("button", text: button_text))
      |> wait(500)
      |> Wallaby.Browser.take_screenshot(name: Path.join(@output_dir, "#{name}.png"))

      IO.puts("✓")
    rescue
      _ ->
        IO.puts("✗ (モーダルを開けませんでした)")
    end
  end

  defp extract_festival_id(url) do
    case Regex.run(~r/\/festivals\/([^\/]+)/, url) do
      [_, id] -> id
      _ -> nil
    end
  end

  defp wait(session, ms) do
    Process.sleep(ms)
    session
  end
end

# 実行
ScreenshotCapture.run()
