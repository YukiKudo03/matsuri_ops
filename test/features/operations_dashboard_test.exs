defmodule MatsuriOpsWeb.Features.OperationsDashboardTest do
  @moduledoc """
  当日運営ダッシュボードのE2Eテスト。

  インシデント管理、エリア状況更新、リアルタイム更新をテストする。
  """

  use MatsuriOpsWeb.FeatureCase, async: false  # PubSub使用のため非同期無効

  alias MatsuriOps.Accounts
  alias MatsuriOps.AccountsFixtures
  alias MatsuriOps.Festivals

  setup %{session: session} do
    # テスト用ユーザーを作成してログイン
    user = AccountsFixtures.user_fixture()
    {token, _hashed} = Accounts.UserToken.build_email_token(user, "magic_link")

    # テスト用の祭りを作成
    {:ok, festival} = Festivals.create_festival(%{
      name: "運営テスト祭り",
      description: "運営ダッシュボードテスト用",
      start_date: Date.utc_today(),
      end_date: Date.utc_today() |> Date.add(1)
    })

    session =
      session
      |> visit("/users/log-in/#{token}")
      |> wait_for_liveview()

    {:ok, session: session, user: user, festival: festival}
  end

  describe "運営ダッシュボード表示" do
    feature "運営ダッシュボードが表示される", %{session: session, festival: festival} do
      session
      |> visit("/festivals/#{festival.id}/operations")
      |> assert_has(css("h1", text: "運営"))
    end

    feature "インシデント一覧セクションが表示される", %{session: session, festival: festival} do
      session
      |> visit("/festivals/#{festival.id}/operations")
      |> assert_has(css("[data-section='incidents']"))
    end

    feature "エリア状況セクションが表示される", %{session: session, festival: festival} do
      session
      |> visit("/festivals/#{festival.id}/operations")
      |> assert_has(css("[data-section='areas']"))
    end
  end

  describe "インシデント管理" do
    feature "新規インシデントを報告できる", %{session: session, festival: festival} do
      session
      |> visit("/festivals/#{festival.id}/operations/incidents/new")
      |> assert_has(css("h2", text: "インシデント"))
      |> fill_in(css("input[name='incident[title]']"), with: "テスト緊急事態")
      |> fill_in(css("textarea[name='incident[description]']"), with: "テスト用のインシデント詳細")
      |> select(css("select[name='incident[severity]']"), option: "中")
      |> select(css("select[name='incident[status]']"), option: "対応中")
      |> click(button("保存"))
      |> wait_for_liveview()
      |> assert_has(css(".alert-info", text: "作成"))
    end

    feature "インシデントの状態を更新できる", %{session: session, festival: festival} do
      # テスト用インシデントを作成
      {:ok, incident} = MatsuriOps.Operations.create_incident(festival.id, %{
        title: "状態更新テスト",
        description: "状態更新テスト用",
        severity: "high",
        status: "open"
      })

      session
      |> visit("/festivals/#{festival.id}/operations/incidents/#{incident.id}/edit")
      |> select(css("select[name='incident[status]']"), option: "解決済み")
      |> click(button("保存"))
      |> wait_for_liveview()
      |> assert_has(css(".alert-info", text: "更新"))
    end

    feature "インシデント一覧でフィルタリングできる", %{session: session, festival: festival} do
      # 複数のインシデントを作成
      {:ok, _} = MatsuriOps.Operations.create_incident(festival.id, %{
        title: "高優先度インシデント",
        description: "高優先度",
        severity: "high",
        status: "open"
      })

      {:ok, _} = MatsuriOps.Operations.create_incident(festival.id, %{
        title: "低優先度インシデント",
        description: "低優先度",
        severity: "low",
        status: "resolved"
      })

      session
      |> visit("/festivals/#{festival.id}/operations")
      |> click(css("[data-filter='severity-high']"))
      |> wait_for_liveview()
      |> assert_has(css("td", text: "高優先度インシデント"))
      |> refute_has(css("td", text: "低優先度インシデント"))
    end
  end

  describe "エリア状況管理" do
    feature "新規エリアを追加できる", %{session: session, festival: festival} do
      session
      |> visit("/festivals/#{festival.id}/operations/areas/new")
      |> assert_has(css("h2", text: "エリア"))
      |> fill_in(css("input[name='area_status[name]']"), with: "メインステージ")
      |> fill_in(css("input[name='area_status[current_count]']"), with: "150")
      |> fill_in(css("input[name='area_status[max_capacity]']"), with: "500")
      |> select(css("select[name='area_status[status]']"), option: "正常")
      |> click(button("保存"))
      |> wait_for_liveview()
      |> assert_has(css(".alert-info", text: "作成"))
    end

    feature "エリア状況を更新できる", %{session: session, festival: festival} do
      # テスト用エリアを作成
      {:ok, area} = MatsuriOps.Operations.create_area_status(festival.id, %{
        name: "フードコート",
        current_count: 100,
        max_capacity: 200,
        status: "normal"
      })

      session
      |> visit("/festivals/#{festival.id}/operations/areas/#{area.id}/edit")
      |> fill_in(css("input[name='area_status[current_count]']"), with: "180")
      |> select(css("select[name='area_status[status]']"), option: "混雑")
      |> click(button("保存"))
      |> wait_for_liveview()
      |> assert_has(css(".alert-info", text: "更新"))
    end

    feature "混雑度に応じた視覚的表示がされる", %{session: session, festival: festival} do
      # 混雑エリアを作成
      {:ok, _} = MatsuriOps.Operations.create_area_status(festival.id, %{
        name: "混雑エリア",
        current_count: 450,
        max_capacity: 500,
        status: "crowded"
      })

      session
      |> visit("/festivals/#{festival.id}/operations")
      |> assert_has(css("[data-status='crowded']"))
    end
  end

  describe "リアルタイム更新" do
    feature "PubSub経由でインシデント更新が反映される", %{session: session, festival: festival} do
      session
      |> visit("/festivals/#{festival.id}/operations")
      |> wait_for_liveview()

      # 別プロセスでインシデントを作成（PubSubで通知）
      {:ok, _incident} = MatsuriOps.Operations.create_incident(festival.id, %{
        title: "リアルタイム通知テスト",
        description: "PubSubテスト",
        severity: "high",
        status: "open"
      })

      # LiveViewの更新を待機
      session
      |> wait_for_liveview(1000)
      |> assert_has(css("td", text: "リアルタイム通知テスト"))
    end

    feature "PubSub経由でエリア状況更新が反映される", %{session: session, festival: festival} do
      # 事前にエリアを作成
      {:ok, area} = MatsuriOps.Operations.create_area_status(festival.id, %{
        name: "リアルタイムエリア",
        current_count: 100,
        max_capacity: 500,
        status: "normal"
      })

      session
      |> visit("/festivals/#{festival.id}/operations")
      |> wait_for_liveview()

      # 別プロセスでエリア状況を更新
      MatsuriOps.Operations.update_area_status(area, %{
        current_count: 480,
        status: "crowded"
      })

      # LiveViewの更新を待機
      session
      |> wait_for_liveview(1000)
      |> assert_has(css("[data-status='crowded']"))
    end
  end

  describe "モバイル対応" do
    feature "モバイル表示でもダッシュボードが操作できる", %{session: session, festival: festival} do
      session
      |> Wallaby.Browser.resize_window(375, 667)  # iPhone SE サイズ
      |> visit("/festivals/#{festival.id}/operations")
      |> assert_has(css("h1", text: "運営"))
      # モバイルメニューが表示される
      |> assert_has(css("[data-mobile-menu]"))
    end
  end
end
