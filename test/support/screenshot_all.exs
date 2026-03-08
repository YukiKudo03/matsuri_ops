# 全スクリーンショット自動取得スクリプト
#
# 使用方法:
#   MIX_ENV=test mix run test/support/screenshot_all.exs
#

IO.puts("🚀 アプリケーション起動中...")

# HTTPクライアント起動
:inets.start()
:ssl.start()

# MatsuriOpsアプリケーション全体を起動
IO.puts("  MatsuriOpsアプリケーション起動...")
{:ok, _} = Application.ensure_all_started(:matsuri_ops)

# サーバーが起動するまで待機
IO.puts("  サーバー起動待機中...")
Process.sleep(3000)

# サーバー起動確認
IO.puts("📡 サーバー接続確認中...")

defmodule ServerCheck do
  def check(retries \\ 10)
  def check(0), do: {:error, :max_retries}
  def check(retries) do
    case :httpc.request(:get, {~c"http://127.0.0.1:4000/users/log-in", []}, [{:timeout, 5000}], []) do
      {:ok, {{_, code, _}, _, body}} when code in [200, 302] ->
        {:ok, code, body}
      {:ok, {{_, code, _}, _, _}} ->
        {:ok, code, nil}
      {:error, reason} ->
        IO.puts("    リトライ中... (#{retries}) #{inspect(reason)}")
        Process.sleep(1000)
        check(retries - 1)
    end
  end
end

case ServerCheck.check() do
  {:ok, code, _body} ->
    IO.puts("✓ サーバー起動確認完了 (HTTP #{code})")
  {:error, :max_retries} ->
    IO.puts("✗ サーバー接続エラー: 最大リトライ回数超過")
    # ポート確認
    IO.puts("  ポート4000の状態を確認中...")
    {result, _} = System.cmd("lsof", ["-i", ":4000"], stderr_to_stdout: true)
    IO.puts("  #{result}")
    IO.puts("スクリプトを終了します。")
    System.halt(1)
end

# Wallaby起動
Application.put_env(:wallaby, :base_url, "http://127.0.0.1:4000")
{:ok, _} = Application.ensure_all_started(:wallaby)
IO.puts("✓ Wallaby起動完了")

defmodule ScreenshotAll do
  @moduledoc """
  全スクリーンショット取得モジュール
  """

  import Wallaby.Query
  import Ecto.Query

  @output_dir "docs/images"

  def run do
    IO.puts("\n📸 スクリーンショット取得を開始します...")
    IO.puts("出力先: #{@output_dir}\n")

    # 出力ディレクトリ作成・クリーンアップ
    File.mkdir_p!(@output_dir)
    cleanup_old_screenshots()

    # Wallabyセッション開始
    {:ok, session} = Wallaby.start_session()

    results = try do
      # 公開ページ
      IO.puts("=== 公開ページ ===\n")
      r1 = capture_public_pages(session)

      # 祭りとユーザーを準備
      IO.puts("\n=== データ準備 ===\n")
      {festival_id, user, password} = setup_data()
      IO.puts("  祭りID: #{festival_id}")
      IO.puts("  ユーザー: #{user.email}")

      # ユーザーログイン（セッション用）
      session = register_user(session, user.email, password)

      # 認証後ページ
      IO.puts("\n=== 認証後ページ ===\n")
      r2 = capture_authenticated_pages(session, festival_id)

      # モーダルページ
      IO.puts("\n=== モーダル ===\n")
      r3 = capture_modal_pages(session, festival_id)

      # チャットルーム
      IO.puts("\n=== チャット ===\n")
      r4 = capture_chat_room(session, festival_id)

      r1 ++ r2 ++ r3 ++ r4
    after
      Wallaby.end_session(session)
    end

    # 結果サマリー
    print_summary(results)
  end

  defp cleanup_old_screenshots do
    Path.wildcard(Path.join(@output_dir, "ss_*.png"))
    |> Enum.each(&File.rm/1)
  end

  defp setup_data do
    # 祭りを作成
    {:ok, festival} = MatsuriOps.Festivals.create_festival(%{
      name: "スクリーンショット用祭り #{System.system_time(:second)}",
      start_date: ~D[2026-08-15],
      end_date: ~D[2026-08-16],
      status: "planning"
    })

    # ユーザーを作成（パスワード付き）
    email = "ss_user_#{System.system_time(:second)}@example.com"
    password = "TestPassword123!"

    {:ok, user} = MatsuriOps.Accounts.register_user(%{email: email})

    # パスワードを設定し確認済みにする
    user
    |> Ecto.Changeset.change(%{
      hashed_password: Bcrypt.hash_pwd_salt(password),
      confirmed_at: DateTime.utc_now() |> DateTime.truncate(:second)
    })
    |> MatsuriOps.Repo.update!()

    # チャットルームを作成
    {:ok, _room} = MatsuriOps.Chat.create_chat_room(%{
      name: "一般チャット",
      room_type: "general",
      festival_id: festival.id
    })

    {festival.id, %{user | email: email}, password}
  end

  defp register_user(session, email, password) do
    IO.puts("  ユーザー認証: #{email}")

    # ログインページへ移動
    session =
      session
      |> Wallaby.Browser.visit("/users/log-in")
      |> wait(1500)

    # パスワードログインフォームに入力
    session =
      try do
        # 2つ目のemailフィールド（パスワードログイン用）を探す
        session
        |> Wallaby.Browser.fill_in(css("input[name='user[email]']:last-of-type, #login_form_email"), with: email)
        |> Wallaby.Browser.fill_in(css("input[name='user[password]']"), with: password)
        |> Wallaby.Browser.click(css("button", text: "Log in"))
        |> wait(2000)
      rescue
        e1 ->
          IO.puts("  フォーム1失敗: #{Exception.message(e1)}")
          try do
            # 代替セレクタを試す
            session
            |> Wallaby.Browser.execute_script("""
              const forms = document.querySelectorAll('form');
              const passwordForm = Array.from(forms).find(f => f.querySelector('input[type="password"]'));
              if (passwordForm) {
                const emailInput = passwordForm.querySelector('input[type="email"]');
                const passInput = passwordForm.querySelector('input[type="password"]');
                if (emailInput) emailInput.value = '#{email}';
                if (passInput) passInput.value = '#{password}';
                passwordForm.submit();
              }
            """)
            |> wait(2000)
          rescue
            _ -> session
          end
      end

    # 認証確認
    current_url = Wallaby.Browser.current_url(session)
    IO.puts("  現在のURL: #{current_url}")

    if String.contains?(current_url, "log-in") do
      IO.puts("  ⚠ 認証に失敗した可能性があります")
    else
      IO.puts("  ✓ 認証完了")
    end

    session
  end

  defp capture_public_pages(session) do
    pages = [
      {:ss_login, "/users/log-in", "ログイン画面"},
      {:ss_register, "/users/register", "新規登録画面"}
    ]

    Enum.map(pages, fn {name, path, desc} ->
      capture_page(session, name, path, desc)
    end)
  end

  defp capture_authenticated_pages(session, festival_id) do
    pages = [
      {:ss_settings, "/users/settings", "設定画面"},
      {:ss_festival_list, "/festivals", "祭り一覧"},
      {:ss_festival_show, "/festivals/#{festival_id}", "祭り詳細"},
      {:ss_task_list, "/festivals/#{festival_id}/tasks", "タスク一覧"},
      {:ss_budget_dashboard, "/festivals/#{festival_id}/budgets", "予算ダッシュボード"},
      {:ss_staff_list, "/festivals/#{festival_id}/staff", "スタッフ一覧"},
      {:ss_shift_list, "/festivals/#{festival_id}/shifts", "シフト一覧"},
      {:ss_operations, "/festivals/#{festival_id}/operations", "運営ダッシュボード"},
      {:ss_announcements, "/festivals/#{festival_id}/announcements", "お知らせ一覧"},
      {:ss_report, "/festivals/#{festival_id}/reports", "レポート画面"},
      {:ss_gantt, "/festivals/#{festival_id}/gantt", "ガントチャート"}
    ]

    Enum.map(pages, fn {name, path, desc} ->
      capture_page(session, name, path, desc)
    end)
  end

  defp capture_modal_pages(session, festival_id) do
    pages = [
      {:ss_festival_form, "/festivals/new", "祭り作成フォーム"},
      {:ss_task_form, "/festivals/#{festival_id}/tasks/new", "タスク作成フォーム"},
      {:ss_expense_form, "/festivals/#{festival_id}/budgets/expenses/new", "経費登録フォーム"},
      {:ss_incident_form, "/festivals/#{festival_id}/operations/incidents/new", "インシデント報告フォーム"}
    ]

    Enum.map(pages, fn {name, path, desc} ->
      capture_page(session, name, path, desc)
    end)
  end

  defp capture_chat_room(session, festival_id) do
    # チャットルームを取得
    room = MatsuriOps.Repo.one(
      from r in MatsuriOps.Chat.ChatRoom,
      where: r.festival_id == ^festival_id,
      limit: 1
    )

    if room do
      [capture_page(session, :ss_chat_room, "/festivals/#{festival_id}/chat/#{room.id}", "チャットルーム")]
    else
      IO.puts("  ss_chat_room: チャットルームが見つかりません")
      [{:error, :ss_chat_room, "チャットルームなし"}]
    end
  end

  defp capture_page(session, name, path, desc) do
    IO.write("  #{name}: #{desc}... ")

    try do
      session
      |> Wallaby.Browser.visit(path)
      |> wait(1500)

      # ページ内容を確認（接続エラーチェック）
      html = Wallaby.Browser.page_source(session)

      if String.contains?(html, "connection") and String.contains?(html, "refused") do
        IO.puts("✗ (接続拒否)")
        {:error, name, "接続拒否"}
      else
        # スクリーンショット保存
        output_path = Path.join(@output_dir, "#{name}.png")
        Wallaby.Browser.take_screenshot(session, name: "#{name}")

        # Wallabyのデフォルト出力先から移動
        wallaby_path = "tmp/wallaby_screenshots/#{name}.png"
        if File.exists?(wallaby_path) do
          File.cp!(wallaby_path, output_path)
        end

        IO.puts("✓")
        {:ok, name, output_path}
      end
    rescue
      e ->
        IO.puts("✗")
        IO.puts("    エラー: #{Exception.message(e)}")
        {:error, name, Exception.message(e)}
    end
  end

  defp wait(session, ms) do
    Process.sleep(ms)
    session
  end

  defp print_summary(results) do
    {success, errors} = Enum.split_with(results, fn
      {:ok, _, _} -> true
      _ -> false
    end)

    IO.puts("\n" <> String.duplicate("=", 50))
    IO.puts("📊 結果サマリー")
    IO.puts(String.duplicate("=", 50))
    IO.puts("成功: #{length(success)}")
    IO.puts("失敗: #{length(errors)}")

    if length(errors) > 0 do
      IO.puts("\n失敗した画面:")
      Enum.each(errors, fn {:error, name, reason} ->
        IO.puts("  - #{name}: #{reason}")
      end)
    end

    IO.puts(String.duplicate("=", 50))

    # 画像ファイル確認
    IO.puts("\n📁 保存されたファイル:")
    Path.wildcard(Path.join(@output_dir, "ss_*.png"))
    |> Enum.sort()
    |> Enum.each(fn path ->
      size = File.stat!(path).size
      IO.puts("  #{Path.basename(path)} (#{div(size, 1024)}KB)")
    end)
  end
end

# 実行
ScreenshotAll.run()
