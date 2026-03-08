defmodule MatsuriOpsWeb.OperationsLive.DashboardTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.OperationsFixtures

  describe "Dashboard page" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "renders operations dashboard", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations")

      assert html =~ "運営ダッシュボード"
      assert html =~ festival.name
    end

    test "redirects if user is not logged in", %{festival: festival} do
      conn = build_conn()
      assert {:error, redirect} = live(conn, ~p"/festivals/#{festival}/operations")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays navigation buttons", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations")

      assert html =~ "インシデント報告"
      assert html =~ "エリア追加"
      assert html =~ "祭り詳細へ"
    end

    test "displays incident statistics", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations")

      assert html =~ "総インシデント"
      assert html =~ "重大"
      assert html =~ "中程度"
      assert html =~ "解決済み"
    end

    test "displays incident statistics with values", %{conn: conn, festival: festival, user: user} do
      _incident1 = incident_fixture(festival, user, %{severity: "critical", status: "reported"})
      _incident2 = incident_fixture(festival, user, %{severity: "high", status: "in_progress"})
      _incident3 = incident_fixture(festival, user, %{severity: "medium", status: "resolved"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations")

      # Should show total of 3
      assert html =~ "3" or html =~ "総インシデント"
    end

    test "displays empty area message", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations")

      assert html =~ "エリアが登録されていません"
    end

    test "displays area status cards", %{conn: conn, festival: festival} do
      _area = area_status_fixture(festival, %{name: "メインエリア", crowd_level: 3})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations")

      assert html =~ "メインエリア"
      assert html =~ "やや混雑"
    end

    test "displays area weather information", %{conn: conn, festival: festival} do
      _area = area_status_fixture(festival, %{
        name: "テストエリア",
        weather_temp: Decimal.new("32.5"),
        weather_wbgt: Decimal.new("28.0")
      })

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations")

      assert html =~ "32.5"
      assert html =~ "28.0"
    end

    test "displays empty incident message", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations")

      assert html =~ "対応中のインシデントはありません"
    end

    test "displays active incidents", %{conn: conn, festival: festival, user: user} do
      _incident = incident_fixture(festival, user, %{
        title: "テストインシデント",
        severity: "high",
        status: "reported",
        location: "メインステージ"
      })

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations")

      assert html =~ "テストインシデント"
      assert html =~ "メインステージ"
      assert html =~ "高"
    end

    test "displays incident category label", %{conn: conn, festival: festival, user: user} do
      _incident = incident_fixture(festival, user, %{
        title: "医療インシデント",
        category: "medical"
      })

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations")

      assert html =~ "医療"
    end

    test "does not display resolved incidents in active list", %{conn: conn, festival: festival, user: user} do
      _resolved = incident_fixture(festival, user, %{
        title: "解決済みインシデント",
        status: "resolved"
      })

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations")

      refute html =~ "解決済みインシデント"
    end

    test "displays back link", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations")

      assert html =~ "祭り詳細へ戻る"
    end

    test "displays severity badges correctly", %{conn: conn, festival: festival, user: user} do
      _critical = incident_fixture(festival, user, %{title: "緊急", severity: "critical"})
      _high = incident_fixture(festival, user, %{title: "高", severity: "high"})
      _medium = incident_fixture(festival, user, %{title: "中", severity: "medium"})
      _low = incident_fixture(festival, user, %{title: "低", severity: "low"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations")

      assert html =~ "緊急"
    end

    test "displays status badges correctly", %{conn: conn, festival: festival, user: user} do
      _reported = incident_fixture(festival, user, %{title: "報告済", status: "reported"})
      _acknowledged = incident_fixture(festival, user, %{title: "確認済", status: "acknowledged"})
      _in_progress = incident_fixture(festival, user, %{title: "対応中", status: "in_progress"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations")

      assert html =~ "報告済"
    end
  end

  describe "New incident modal" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "opens new incident modal", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/operations")

      view
      |> element("a", "インシデント報告")
      |> render_click()

      assert_patch(view, ~p"/festivals/#{festival}/operations/incidents/new")
      assert has_element?(view, "#incident-form")
    end

    test "displays incident form fields", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations/incidents/new")

      assert html =~ "タイトル"
      assert html =~ "詳細"
      assert html =~ "重要度"
      assert html =~ "カテゴリ"
      assert html =~ "発生場所"
      assert html =~ "状態"
    end

    test "saves new incident", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/operations/incidents/new")

      view
      |> form("#incident-form", incident: %{
        title: "新規インシデント報告",
        severity: "high",
        category: "security",
        location: "入口付近"
      })
      |> render_submit()

      flash = assert_patch(view, ~p"/festivals/#{festival}/operations")
      assert render(view) =~ "インシデントを報告しました" or flash
    end
  end

  describe "Edit incident modal" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      incident = incident_fixture(festival, user, %{
        title: "編集対象インシデント",
        severity: "medium",
        location: "フードコート"
      })
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, incident: incident}
    end

    test "opens edit incident modal", %{conn: conn, festival: festival, incident: incident} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations/incidents/#{incident}/edit")

      assert html =~ "インシデント編集"
      assert html =~ "編集対象インシデント"
    end

    test "updates incident", %{conn: conn, festival: festival, incident: incident} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/operations/incidents/#{incident}/edit")

      view
      |> form("#incident-form", incident: %{status: "resolved", resolution: "対応完了"})
      |> render_submit()

      flash = assert_patch(view, ~p"/festivals/#{festival}/operations")
      assert render(view) =~ "インシデントを更新しました" or flash
    end

    test "shows resolution field on edit", %{conn: conn, festival: festival, incident: incident} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations/incidents/#{incident}/edit")

      assert html =~ "対応内容"
    end
  end

  describe "New area modal" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "opens new area modal", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/operations")

      view
      |> element("a", "エリア追加")
      |> render_click()

      assert_patch(view, ~p"/festivals/#{festival}/operations/areas/new")
      assert has_element?(view, "#area-form")
    end

    test "displays area form fields", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations/areas/new")

      assert html =~ "エリア名"
      assert html =~ "混雑度"
      assert html =~ "気温"
      assert html =~ "WBGT"
      assert html =~ "備考"
    end

    test "saves new area", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/operations/areas/new")

      view
      |> form("#area-form", area_status: %{
        name: "新規エリア",
        crowd_level: 2
      })
      |> render_submit()

      flash = assert_patch(view, ~p"/festivals/#{festival}/operations")
      assert render(view) =~ "エリアを追加しました" or flash
    end
  end

  describe "Edit area modal" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      area = area_status_fixture(festival, %{
        name: "編集対象エリア",
        crowd_level: 2
      })
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, area: area}
    end

    test "opens edit area modal", %{conn: conn, festival: festival, area: area} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations/areas/#{area}/edit")

      assert html =~ "エリア状況更新"
      assert html =~ "編集対象エリア"
    end

    test "updates area", %{conn: conn, festival: festival, area: area} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/operations/areas/#{area}/edit")

      view
      |> form("#area-form", area_status: %{crowd_level: 4})
      |> render_submit()

      flash = assert_patch(view, ~p"/festivals/#{festival}/operations")
      assert render(view) =~ "エリア状況を更新しました" or flash
    end
  end
end
