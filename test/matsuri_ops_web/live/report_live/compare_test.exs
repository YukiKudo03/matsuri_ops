defmodule MatsuriOpsWeb.ReportLive.CompareTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures

  describe "Compare page" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "renders compare page", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/reports/compare")

      assert html =~ "年度比較" or html =~ "比較"
    end

    test "redirects if not logged in" do
      conn = build_conn()
      assert {:error, redirect} = live(conn, ~p"/reports/compare")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays festival selection form", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/reports/compare")

      assert has_element?(view, "#compare-form")
    end

    test "shows comparison results after selecting festivals", %{conn: conn, user: user} do
      festival_a = festival_fixture(user, %{name: "2024年祭りA"})
      festival_b = festival_fixture(user, %{name: "2025年祭りB"})

      {:ok, view, _html} = live(conn, ~p"/reports/compare")

      html =
        view
        |> form("#compare-form", %{"festival_ids" => [festival_a.id, festival_b.id]})
        |> render_submit()

      assert html =~ "2024年祭りA" or html =~ "2025年祭りB"
    end
  end
end
