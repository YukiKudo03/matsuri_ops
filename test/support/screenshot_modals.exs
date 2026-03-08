# モーダル・チャット画面スクリーンショット取得スクリプト
#
# 使用方法:
#   MIX_ENV=test mix run test/support/screenshot_modals.exs
#
# 前提条件:
#   - ChromeDriverがインストールされていること
#   - 事前にscreenshot_capture.exsを実行して祭りが作成されていること

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

# Endpointを起動
case MatsuriOpsWeb.Endpoint.start_link() do
  {:ok, _} -> :ok
  {:error, {:already_started, _}} -> :ok
end

defmodule ScreenshotModals do
  @moduledoc """
  モーダル・チャット画面のスクリーンショット取得モジュール。
  """

  import Wallaby.Query
  import Ecto.Query

  @output_dir "docs/images"

  def run do
    IO.puts("\n📸 モーダル・チャット画面スクリーンショット取得を開始します...\n")
    IO.puts("出力先: #{@output_dir}\n")

    # 出力ディレクトリ作成
    File.mkdir_p!(@output_dir)

    # Wallabyセッション開始
    {:ok, session} = Wallaby.start_session()

    try do
      # 祭りIDを取得（既存の祭りを使用）
      festival_id = get_festival_id()
      IO.puts("使用する祭りID: #{festival_id}\n")

      # ユーザー登録（認証用）
      session = register_user(session)

      # 各モーダルのスクリーンショット
      IO.puts("=== モーダル画面 ===\n")

      capture_task_form(session, festival_id)
      capture_expense_form(session, festival_id)
      capture_incident_form(session, festival_id)

      # チャットルームのスクリーンショット
      IO.puts("\n=== チャット画面 ===\n")
      capture_chat_room(session, festival_id)

      IO.puts("\n✅ 完了しました！\n")
    after
      Wallaby.end_session(session)
    end
  end

  defp get_festival_id do
    # 既存の祭りを検索
    case MatsuriOps.Repo.one(
           from f in MatsuriOps.Festivals.Festival,
           order_by: [desc: f.inserted_at],
           limit: 1,
           select: f.id
         ) do
      nil ->
        # 祭りがない場合は作成
        {:ok, festival} =
          MatsuriOps.Festivals.create_festival(%{
            name: "モーダルテスト祭り",
            start_date: ~D[2026-08-15],
            end_date: ~D[2026-08-16],
            status: "planning"
          })
        festival.id

      id ->
        id
    end
  end

  defp register_user(session) do
    email = "modal_test_#{System.system_time(:second)}@example.com"
    IO.puts("テストユーザー作成: #{email}")

    session
    |> Wallaby.Browser.visit("/users/register")
    |> wait(1500)

    # 登録試行（失敗してもログインページに遷移するだけ）
    try do
      session
      |> Wallaby.Browser.fill_in(css("input[type='email']"), with: email)
      |> Wallaby.Browser.click(css("button[type='submit']"))
      |> wait(1500)
    rescue
      _ -> session
    end
  end

  defp capture_task_form(session, festival_id) do
    IO.write("  ss_task_form: タスク作成フォーム... ")

    try do
      # 直接モーダルを開くURLに遷移
      session =
        session
        |> Wallaby.Browser.visit("/festivals/#{festival_id}/tasks/new")
        |> wait(2000)

      # スクリーンショット取得
      save_screenshot(session, "ss_task_form")
      IO.puts("✓")
    rescue
      e ->
        IO.puts("✗")
        IO.puts("    エラー: #{inspect(e)}")
    end

    session
  end

  defp capture_expense_form(session, festival_id) do
    IO.write("  ss_expense_form: 経費登録フォーム... ")

    try do
      # 直接モーダルを開くURLに遷移
      session =
        session
        |> Wallaby.Browser.visit("/festivals/#{festival_id}/budgets/expenses/new")
        |> wait(2000)

      # スクリーンショット取得
      save_screenshot(session, "ss_expense_form")
      IO.puts("✓")
    rescue
      e ->
        IO.puts("✗")
        IO.puts("    エラー: #{inspect(e)}")
    end

    session
  end

  defp capture_incident_form(session, festival_id) do
    IO.write("  ss_incident_form: インシデント報告フォーム... ")

    try do
      # 直接モーダルを開くURLに遷移
      session =
        session
        |> Wallaby.Browser.visit("/festivals/#{festival_id}/operations/incidents/new")
        |> wait(2000)

      # スクリーンショット取得
      save_screenshot(session, "ss_incident_form")
      IO.puts("✓")
    rescue
      e ->
        IO.puts("✗")
        IO.puts("    エラー: #{inspect(e)}")
    end

    session
  end

  defp capture_chat_room(session, festival_id) do
    IO.write("  ss_chat_room: チャットルーム... ")

    try do
      # まずチャットルーム一覧へ
      session =
        session
        |> Wallaby.Browser.visit("/festivals/#{festival_id}/chat")
        |> wait(1500)

      # 既存のルームがあればクリック、なければ作成
      session =
        try do
          # 最初のルームカードをクリック
          session
          |> Wallaby.Browser.click(css("a[href*='/chat/']"))
          |> wait(1000)
        rescue
          _ ->
            # ルームがない場合は作成
            create_and_enter_chat_room(session, festival_id)
        end

      # チャットルーム画面のスクリーンショット
      save_screenshot(session, "ss_chat_room")
      IO.puts("✓")
    rescue
      e ->
        IO.puts("✗")
        IO.puts("    エラー: #{inspect(e)}")
    end

    session
  end

  defp create_and_enter_chat_room(session, festival_id) do
    # チャットルームを直接DBに作成
    {:ok, room} =
      MatsuriOps.Chat.create_chat_room(%{
        name: "一般",
        room_type: "general",
        festival_id: festival_id
      })

    # ルームに移動
    session
    |> Wallaby.Browser.visit("/festivals/#{festival_id}/chat/#{room.id}")
    |> wait(1500)
  end

  defp save_screenshot(session, name) do
    # Wallabyのスクリーンショットパスを直接指定
    path = Path.join(@output_dir, "#{name}.png")

    # 一時ファイルに保存してから移動
    temp_name = "temp_#{name}_#{System.system_time(:millisecond)}"
    Wallaby.Browser.take_screenshot(session, name: temp_name)

    # Wallabyのデフォルト出力先から移動
    wallaby_path = "tmp/wallaby_screenshots/#{temp_name}.png"

    if File.exists?(wallaby_path) do
      File.cp!(wallaby_path, path)
      File.rm(wallaby_path)
    end
  end

  defp wait(session, ms) do
    Process.sleep(ms)
    session
  end
end

# 実行
ScreenshotModals.run()
