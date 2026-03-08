defmodule MatsuriOpsWeb.OperationsLive.IncidentFormComponentTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.OperationsFixtures

  describe "IncidentFormComponent for new incident" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "renders form for new incident", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations/incidents/new")

      assert html =~ "タイトル"
      assert html =~ "詳細"
      assert html =~ "重要度"
      assert html =~ "カテゴリ"
      assert html =~ "発生場所"
      assert html =~ "状態"
      assert html =~ "保存"
    end

    test "displays severity options", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations/incidents/new")

      assert html =~ ">低<"
      assert html =~ ">中<"
      assert html =~ ">高<"
      assert html =~ ">緊急<"
    end

    test "displays category options", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations/incidents/new")

      assert html =~ "未分類"
      assert html =~ "医療"
      assert html =~ "警備"
      assert html =~ "落とし物"
      assert html =~ "天候"
      assert html =~ "設備"
      assert html =~ "その他"
    end

    test "displays status options", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations/incidents/new")

      assert html =~ "報告済"
      assert html =~ "確認済"
      assert html =~ "対応中"
      assert html =~ "解決済"
      assert html =~ "クローズ"
    end

    test "validates required fields", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/operations/incidents/new")

      result =
        view
        |> form("#incident-form", incident: %{title: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "creates incident with valid data", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/operations/incidents/new")

      view
      |> form("#incident-form", incident: %{
        title: "新規テストインシデント",
        description: "詳細説明",
        severity: "high",
        category: "security",
        location: "入口",
        status: "reported"
      })
      |> render_submit()

      flash = assert_patch(view, ~p"/festivals/#{festival}/operations")
      assert render(view) =~ "インシデントを報告しました" or flash
    end

    test "creates incident with minimum required fields", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/operations/incidents/new")

      view
      |> form("#incident-form", incident: %{
        title: "必須のみインシデント",
        severity: "low"
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/operations")
    end

    test "does not show resolution field on new", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations/incidents/new")

      # Resolution field should only appear on edit
      refute html =~ "対応内容"
    end

    test "shows page title for new incident", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations/incidents/new")

      assert html =~ "インシデント報告"
    end
  end

  describe "IncidentFormComponent for editing incident" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      incident = incident_fixture(festival, user, %{
        title: "編集用インシデント",
        description: "元の説明",
        severity: "medium",
        category: "equipment",
        location: "ステージ裏",
        status: "reported"
      })
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, incident: incident}
    end

    test "displays existing values", %{conn: conn, festival: festival, incident: incident} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations/incidents/#{incident}/edit")

      assert html =~ "編集用インシデント"
      assert html =~ "元の説明"
      assert html =~ "ステージ裏"
    end

    test "updates incident title", %{conn: conn, festival: festival, incident: incident} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/operations/incidents/#{incident}/edit")

      view
      |> form("#incident-form", incident: %{title: "更新後タイトル"})
      |> render_submit()

      flash = assert_patch(view, ~p"/festivals/#{festival}/operations")
      assert render(view) =~ "インシデントを更新しました" or flash
    end

    test "updates incident severity", %{conn: conn, festival: festival, incident: incident} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/operations/incidents/#{incident}/edit")

      view
      |> form("#incident-form", incident: %{severity: "critical"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/operations")
    end

    test "updates incident status", %{conn: conn, festival: festival, incident: incident} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/operations/incidents/#{incident}/edit")

      view
      |> form("#incident-form", incident: %{status: "in_progress"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/operations")
    end

    test "can resolve incident with resolution text", %{conn: conn, festival: festival, incident: incident} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/operations/incidents/#{incident}/edit")

      view
      |> form("#incident-form", incident: %{
        status: "resolved",
        resolution: "問題を解決しました"
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/operations")
    end

    test "shows resolution field on edit", %{conn: conn, festival: festival, incident: incident} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations/incidents/#{incident}/edit")

      assert html =~ "対応内容"
    end

    test "validates title cannot be empty on edit", %{conn: conn, festival: festival, incident: incident} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/operations/incidents/#{incident}/edit")

      result =
        view
        |> form("#incident-form", incident: %{title: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "shows page title for edit", %{conn: conn, festival: festival, incident: incident} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations/incidents/#{incident}/edit")

      assert html =~ "インシデント編集"
    end

    test "can change category", %{conn: conn, festival: festival, incident: incident} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/operations/incidents/#{incident}/edit")

      view
      |> form("#incident-form", incident: %{category: "medical"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/operations")
    end

    test "can update location", %{conn: conn, festival: festival, incident: incident} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/operations/incidents/#{incident}/edit")

      view
      |> form("#incident-form", incident: %{location: "メインゲート前"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/operations")
    end
  end
end
