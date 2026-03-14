defmodule MatsuriOpsWeb.FestivalLive.IndexTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures

  describe "Index page" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "renders festivals page", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/festivals")

      assert html =~ "祭り一覧"
    end

    test "redirects if not logged in" do
      conn = build_conn()
      assert {:error, redirect} = live(conn, ~p"/festivals")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays festivals in table", %{conn: conn, festival: festival} do
      {:ok, view, html} = live(conn, ~p"/festivals")

      assert has_element?(view, "#festivals")
      assert html =~ festival.name
    end

    test "can delete festival", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals")

      assert has_element?(view, "#festivals-#{festival.id}")

      view
      |> render_click("delete", %{"id" => to_string(festival.id)})

      refute has_element?(view, "#festivals-#{festival.id}")
    end

    test "opens new festival modal", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/festivals")

      view
      |> element("a", "新規作成")
      |> render_click()

      assert_patch(view, ~p"/festivals/new")
      assert has_element?(view, "#festival-form")
    end

    test "opens edit festival modal", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/edit")

      assert html =~ "祭り編集" or html =~ festival.name
      assert html =~ "festival-form" or html =~ "festival[name]"
    end
  end
end
