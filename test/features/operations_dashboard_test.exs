defmodule MatsuriOpsWeb.Features.OperationsDashboardTest do
  @moduledoc """
  当日運営ダッシュボードのE2Eテスト (Suite 8: O-01〜O-11)
  """

  use MatsuriOpsWeb.FeatureCase, async: false

  setup %{session: session} do
    {session, user} = register_and_login(session)
    {session, festival_id} = create_festival_in_db(session, user, %{name: "運営テスト祭り"})
    {:ok, session: session, user: user, festival_id: festival_id}
  end

  describe "ダッシュボード表示" do
    # O-01: ダッシュボード表示
    feature "運営ダッシュボードを表示できる", %{session: session, festival_id: festival_id} do
      session
      |> visit("/festivals/#{festival_id}/operations")
      |> wait_for_liveview()
      |> assert_has(css("h1", text: "運営ダッシュボード"))
    end
  end

  describe "インシデント管理" do
    # O-02: インシデント報告
    feature "インシデントを報告できる", %{session: session, festival_id: festival_id} do
      session
      |> visit("/festivals/#{festival_id}/operations/incidents/new")
      |> wait_for_liveview()
      |> fill_in(css("#incident-form input[name='incident[title]']"), with: "迷子の報告")
      |> fill_in(css("#incident-form textarea[name='incident[description]']"), with: "5歳男児、Aエリア付近")
      |> click(button("保存"))
      |> wait_for_liveview(1500)
      # 保存後はダッシュボードにパッチされ、PubSubで新しいインシデントが表示される
      |> visit("/festivals/#{festival_id}/operations")
      |> wait_for_liveview()
      |> assert_has(css("h4", text: "迷子の報告"))
    end

    # O-05: インシデント解決
    feature "インシデントを解決できる", %{session: session, festival_id: festival_id} do
      # インシデント作成
      session =
        session
        |> visit("/festivals/#{festival_id}/operations/incidents/new")
        |> wait_for_liveview()
        |> fill_in(css("#incident-form input[name='incident[title]']"), with: "解決テスト")
        |> click(button("保存"))
        |> wait_for_liveview(1500)

      # ページ再読み込みして確認
      session =
        session
        |> visit("/festivals/#{festival_id}/operations")
        |> wait_for_liveview()
        |> assert_has(css("h4", text: "解決テスト"))

      # インシデントカードをクリックして編集モーダルを開く
      # インシデントカードのphx-clickはJS.patchでedit_incidentアクションに遷移
      import Ecto.Query, only: [from: 2]

      incident =
        from(i in MatsuriOps.Operations.Incident,
          where: i.title == "解決テスト",
          limit: 1
        )
        |> MatsuriOps.Repo.one!()

      session
      |> visit("/festivals/#{festival_id}/operations/incidents/#{incident.id}/edit")
      |> wait_for_liveview()
      |> select_option(css("#incident-form select[name='incident[status]']"), "resolved")
      |> click(button("保存"))
      |> wait_for_liveview(1500)
      # 解決済みのインシデントは対応中リストから消える
      |> visit("/festivals/#{festival_id}/operations")
      |> wait_for_liveview()
      |> refute_has(css("h4", text: "解決テスト"))
    end
  end

  describe "エリア管理" do
    # O-07: エリア状況作成
    feature "エリアを追加できる", %{session: session, festival_id: festival_id} do
      session
      |> visit("/festivals/#{festival_id}/operations/areas/new")
      |> wait_for_liveview()
      |> fill_in(css("#area-form input[name='area_status[name]']"), with: "メインステージ")
      |> click(button("保存"))
      |> wait_for_liveview(1500)
      # 保存後はダッシュボードにパッチされ、PubSubでエリアが表示される
      |> visit("/festivals/#{festival_id}/operations")
      |> wait_for_liveview()
      |> assert_has(css("h4", text: "メインステージ"))
    end
  end
end
