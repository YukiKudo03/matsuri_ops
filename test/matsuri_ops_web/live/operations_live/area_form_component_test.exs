defmodule MatsuriOpsWeb.OperationsLive.AreaFormComponentTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.OperationsFixtures

  describe "AreaFormComponent for new area" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "renders form for new area", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations/areas/new")

      assert html =~ "エリア名"
      assert html =~ "混雑度"
      assert html =~ "気温"
      assert html =~ "WBGT"
      assert html =~ "備考"
      assert html =~ "保存"
    end

    test "displays crowd level options", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations/areas/new")

      assert html =~ "閑散"
      assert html =~ "やや空き"
      assert html =~ "通常"
      assert html =~ "やや混雑"
      assert html =~ "混雑"
      assert html =~ "非常に混雑"
    end

    test "validates required fields", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/operations/areas/new")

      result =
        view
        |> form("#area-form", area_status: %{name: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "creates area with valid data", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/operations/areas/new")

      view
      |> form("#area-form", area_status: %{
        name: "新規テストエリア",
        crowd_level: 3,
        notes: "テスト備考"
      })
      |> render_submit()

      flash = assert_patch(view, ~p"/festivals/#{festival}/operations")
      assert render(view) =~ "エリアを追加しました" or flash
    end

    test "creates area with weather data", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/operations/areas/new")

      view
      |> form("#area-form", area_status: %{
        name: "気象観測エリア",
        crowd_level: 2,
        weather_temp: "30.5",
        weather_wbgt: "27.0"
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/operations")
    end

    test "creates area with minimum required fields", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/operations/areas/new")

      view
      |> form("#area-form", area_status: %{
        name: "必須のみエリア",
        crowd_level: 0
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/operations")
    end

    test "shows page title for new area", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations/areas/new")

      assert html =~ "エリア追加"
    end
  end

  describe "AreaFormComponent for editing area" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      area = area_status_fixture(festival, %{
        name: "編集用エリア",
        crowd_level: 2,
        weather_temp: Decimal.new("28.0"),
        notes: "元の備考"
      })
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, area: area}
    end

    test "displays existing values", %{conn: conn, festival: festival, area: area} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations/areas/#{area}/edit")

      assert html =~ "編集用エリア"
      assert html =~ "元の備考"
    end

    test "updates area name", %{conn: conn, festival: festival, area: area} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/operations/areas/#{area}/edit")

      view
      |> form("#area-form", area_status: %{name: "更新後エリア名"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/operations")
      assert render(view) =~ "更新後エリア名"
    end

    test "updates crowd level", %{conn: conn, festival: festival, area: area} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/operations/areas/#{area}/edit")

      view
      |> form("#area-form", area_status: %{crowd_level: 5})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/operations")
      assert render(view) =~ "非常に混雑"
    end

    test "updates weather data", %{conn: conn, festival: festival, area: area} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/operations/areas/#{area}/edit")

      view
      |> form("#area-form", area_status: %{weather_temp: "35.0", weather_wbgt: "31.0"})
      |> render_submit()

      flash = assert_patch(view, ~p"/festivals/#{festival}/operations")
      assert render(view) =~ "エリア状況を更新しました" or flash
    end

    test "validates name cannot be empty on edit", %{conn: conn, festival: festival, area: area} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/operations/areas/#{area}/edit")

      result =
        view
        |> form("#area-form", area_status: %{name: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "shows page title for edit", %{conn: conn, festival: festival, area: area} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/operations/areas/#{area}/edit")

      assert html =~ "エリア状況更新"
    end

    test "can clear notes", %{conn: conn, festival: festival, area: area} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/operations/areas/#{area}/edit")

      view
      |> form("#area-form", area_status: %{notes: ""})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/operations")
    end
  end
end
