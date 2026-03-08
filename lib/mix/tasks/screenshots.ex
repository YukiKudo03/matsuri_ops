defmodule Mix.Tasks.Screenshots do
  @moduledoc """
  ドキュメント用のスクリーンショットを自動取得するMixタスク。

  ## 使用方法

      # 全スクリーンショット取得
      mix screenshots

      # 特定のスクリーンショットのみ
      mix screenshots --only login,register

      # 出力ディレクトリ指定
      mix screenshots --output docs/images

  ## 前提条件

  - ChromeDriver がインストールされていること
  - アプリケーションが起動可能な状態であること
  """

  use Mix.Task

  @shortdoc "ドキュメント用スクリーンショットを取得"

  @screenshots [
    # 認証関連
    {:ss_login, "/users/log_in", "ログイン画面", :public},
    {:ss_register, "/users/register", "新規登録画面", :public},
    {:ss_settings, "/users/settings", "設定画面", :authenticated},

    # 祭り管理
    {:ss_festival_list, "/festivals", "祭り一覧", :authenticated},
    {:ss_festival_form, "/festivals", "祭り作成フォーム", :modal},
    {:ss_festival_show, "/festivals/:id", "祭り詳細", :authenticated},

    # タスク管理
    {:ss_task_list, "/festivals/:id/tasks", "タスク一覧", :authenticated},
    {:ss_task_form, "/festivals/:id/tasks", "タスク作成フォーム", :modal},

    # 予算管理
    {:ss_budget_dashboard, "/festivals/:id/budgets", "予算ダッシュボード", :authenticated},
    {:ss_expense_form, "/festivals/:id/budgets", "経費登録フォーム", :modal},

    # スタッフ・シフト
    {:ss_staff_list, "/festivals/:id/staff", "スタッフ一覧", :authenticated},
    {:ss_shift_list, "/festivals/:id/shifts", "シフト一覧", :authenticated},

    # 当日運営
    {:ss_operations, "/festivals/:id/operations", "運営ダッシュボード", :authenticated},
    {:ss_incident_form, "/festivals/:id/operations", "インシデント報告フォーム", :modal},

    # コミュニケーション
    {:ss_chat_room, "/festivals/:id/chat", "チャットルーム", :authenticated},
    {:ss_announcements, "/festivals/:id/announcements", "お知らせ一覧", :authenticated},

    # その他
    {:ss_report, "/festivals/:id/reports", "レポート画面", :authenticated},
    {:ss_gantt, "/festivals/:id/gantt", "ガントチャート", :authenticated}
  ]

  @impl Mix.Task
  def run(args) do
    {opts, _, _} = OptionParser.parse(args,
      switches: [output: :string, only: :string, help: :boolean],
      aliases: [o: :output, h: :help]
    )

    if opts[:help] do
      print_help()
    else
      output_dir = opts[:output] || "docs/images"
      only = parse_only(opts[:only])

      Mix.shell().info("スクリーンショット取得を開始します...")
      Mix.shell().info("出力先: #{output_dir}")

      # 必要な依存関係を起動
      Application.ensure_all_started(:wallaby)

      # 出力ディレクトリ作成
      File.mkdir_p!(output_dir)

      # スクリーンショット取得
      results = capture_screenshots(output_dir, only)

      # 結果表示
      print_results(results)
    end
  end

  defp parse_only(nil), do: nil
  defp parse_only(str) do
    str
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_atom/1)
  end

  defp capture_screenshots(output_dir, only) do
    screenshots = filter_screenshots(only)

    Mix.shell().info("\n取得対象: #{length(screenshots)} 枚\n")

    # Wallabyセッション開始
    {:ok, session} = Wallaby.start_session()

    try do
      # テストユーザー作成とログイン
      session = setup_test_user(session)

      # 祭りIDを取得（認証後）
      festival_id = get_or_create_festival(session)

      # 各スクリーンショットを取得
      Enum.map(screenshots, fn {name, path, desc, type} ->
        actual_path = String.replace(path, ":id", to_string(festival_id))
        capture_one(session, name, actual_path, desc, type, output_dir)
      end)
    after
      Wallaby.end_session(session)
    end
  end

  defp filter_screenshots(nil), do: @screenshots
  defp filter_screenshots(only) do
    Enum.filter(@screenshots, fn {name, _, _, _} -> name in only end)
  end

  defp setup_test_user(session) do
    import Wallaby.Query

    # 登録ページへ
    session = Wallaby.Browser.visit(session, "/users/register")
    Process.sleep(500)

    email = "screenshot_user_#{:rand.uniform(100_000)}@example.com"

    session
    |> Wallaby.Browser.fill_in(css("input[name='user[email]']"), with: email)
    |> Wallaby.Browser.click(css("button[type='submit']"))
    |> wait_for_page_load()
  end

  defp get_or_create_festival(session) do
    import Wallaby.Query

    # 祭り一覧ページへ
    session = Wallaby.Browser.visit(session, "/festivals")
    Process.sleep(500)

    # 既存の祭りがあればそのIDを使用、なければ作成
    case Wallaby.Browser.find(session, css("a[href*='/festivals/']"), &(&1)) do
      {:ok, element} ->
        href = Wallaby.Element.attr(element, "href")
        extract_festival_id(href)

      _ ->
        create_festival(session)
    end
  rescue
    _ -> create_festival(session)
  end

  defp extract_festival_id(href) do
    case Regex.run(~r/\/festivals\/([^\/]+)/, href) do
      [_, id] -> id
      _ -> nil
    end
  end

  defp create_festival(session) do
    import Wallaby.Query

    # 新規作成ボタンをクリック
    session
    |> Wallaby.Browser.click(css("button", text: "新規作成"))
    |> wait_for_page_load()

    # フォーム入力
    session
    |> Wallaby.Browser.fill_in(css("input[name='festival[name]']"), with: "テスト祭り")
    |> Wallaby.Browser.fill_in(css("input[name='festival[start_date]']"), with: "2026-08-01")
    |> Wallaby.Browser.fill_in(css("input[name='festival[end_date]']"), with: "2026-08-02")
    |> Wallaby.Browser.click(css("button[type='submit']"))
    |> wait_for_page_load()

    # 作成された祭りのIDを取得
    url = Wallaby.Browser.current_url(session)
    extract_festival_id(url) || "1"
  end

  defp capture_one(session, name, path, desc, type, output_dir) do
    import Wallaby.Query

    Mix.shell().info("  #{name}: #{desc}...")

    try do
      # ページへ移動
      session = Wallaby.Browser.visit(session, path)
      Process.sleep(800)

      # モーダルの場合は開く
      session = case type do
        :modal -> open_modal(session, name)
        _ -> session
      end

      Process.sleep(300)

      # スクリーンショット取得
      output_path = Path.join(output_dir, "#{name}.png")

      Wallaby.Browser.take_screenshot(session, name: output_path)

      Mix.shell().info("    ✓ #{output_path}")
      {:ok, name, output_path}
    rescue
      e ->
        Mix.shell().error("    ✗ エラー: #{inspect(e)}")
        {:error, name, e}
    end
  end

  defp open_modal(session, name) do
    import Wallaby.Query

    button_text = case name do
      :ss_festival_form -> "新規作成"
      :ss_task_form -> "新規タスク"
      :ss_expense_form -> "経費登録"
      :ss_incident_form -> "インシデント報告"
      _ -> nil
    end

    if button_text do
      session
      |> Wallaby.Browser.click(css("button", text: button_text))
      |> wait_for_page_load()
    else
      session
    end
  rescue
    _ -> session
  end

  defp wait_for_page_load(session) do
    Process.sleep(500)
    session
  end

  defp print_results(results) do
    {success, errors} = Enum.split_with(results, fn
      {:ok, _, _} -> true
      _ -> false
    end)

    Mix.shell().info("\n" <> String.duplicate("=", 50))
    Mix.shell().info("結果: #{length(success)} 成功 / #{length(errors)} 失敗")

    if length(errors) > 0 do
      Mix.shell().info("\n失敗:")
      Enum.each(errors, fn {:error, name, _} ->
        Mix.shell().info("  - #{name}")
      end)
    end

    Mix.shell().info(String.duplicate("=", 50))
  end

  defp print_help do
    Mix.shell().info("""
    ドキュメント用スクリーンショット取得

    使用方法:
      mix screenshots [オプション]

    オプション:
      --output, -o   出力ディレクトリ（デフォルト: docs/images）
      --only         取得するスクリーンショット（カンマ区切り）
      --help, -h     ヘルプ表示

    例:
      mix screenshots
      mix screenshots --output priv/static/images
      mix screenshots --only ss_login,ss_register

    取得可能なスクリーンショット:
    #{format_screenshot_list()}
    """)
  end

  defp format_screenshot_list do
    @screenshots
    |> Enum.map(fn {name, path, desc, _} ->
      "  #{name}\n    #{path} - #{desc}"
    end)
    |> Enum.join("\n")
  end
end
