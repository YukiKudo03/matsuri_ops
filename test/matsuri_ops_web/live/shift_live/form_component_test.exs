defmodule MatsuriOpsWeb.ShiftLive.FormComponentTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.ShiftsFixtures

  describe "New shift form" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "renders new shift form", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/shifts/new")

      assert has_element?(view, "#shift-form")
      assert has_element?(view, "input[name='shift[name]']")
      assert has_element?(view, "input[name='shift[start_time]']")
      assert has_element?(view, "input[name='shift[end_time]']")
    end

    test "displays all form fields", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/shifts/new")

      assert html =~ "name" or html =~ "シフト名"
      assert html =~ "start_time" or html =~ "開始時間"
      assert html =~ "end_time" or html =~ "終了時間"
      assert html =~ "location" or html =~ "場所"
      assert html =~ "required_staff" or html =~ "必要人数"
      assert html =~ "description" or html =~ "説明"
    end

    test "validates required fields", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/shifts/new")

      result =
        view
        |> form("#shift-form", shift: %{name: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "saves new shift", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/shifts/new")

      view
      |> form("#shift-form", shift: %{
        name: "朝シフト",
        start_time: "2025-08-01T09:00",
        end_time: "2025-08-01T13:00",
        location: "正門",
        required_staff: 3
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/shifts")
      assert render(view) =~ "朝シフト"
    end
  end

  describe "Edit shift form" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      shift = shift_fixture(festival, %{name: "編集対象シフト"})
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, shift: shift}
    end

    test "renders edit form with existing values", %{conn: conn, festival: festival, shift: shift} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/shifts/#{shift}/edit")

      assert html =~ "編集対象シフト"
    end

    test "updates existing shift", %{conn: conn, festival: festival, shift: shift} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/shifts/#{shift}/edit")

      view
      |> form("#shift-form", shift: %{name: "更新済みシフト"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/shifts")
      assert render(view) =~ "更新済みシフト"
    end
  end
end
