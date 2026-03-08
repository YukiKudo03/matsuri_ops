defmodule MatsuriOpsWeb.FestivalLive.ShowTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.TasksFixtures

  describe "Show page" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user, %{
        name: "テスト祭り詳細",
        description: "詳細テスト用の祭り",
        venue_name: "テスト会場",
        venue_address: "東京都渋谷区1-1-1",
        scale: "medium",
        status: "planning",
        expected_visitors: 5000,
        expected_vendors: 100
      })
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "renders festival details page", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}")

      assert html =~ festival.name
      assert html =~ "詳細テスト用の祭り"
    end

    test "redirects if user is not logged in", %{festival: festival} do
      conn = build_conn()
      assert {:error, redirect} = live(conn, ~p"/festivals/#{festival}")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays festival information", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}")

      assert html =~ "テスト会場"
      assert html =~ "東京都渋谷区1-1-1"
      assert html =~ "5000"
      assert html =~ "100"
      assert html =~ "企画中"
      assert html =~ "中規模"
    end

    test "displays navigation buttons", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}")

      assert html =~ "編集"
      assert html =~ "タスク管理"
      assert html =~ "予算管理"
      assert html =~ "スタッフ管理"
      assert html =~ "運営ダッシュボード"
    end

    test "displays member list when members exist", %{conn: conn, festival: festival} do
      member_user = user_fixture()
      _member = festival_member_fixture(festival, member_user, %{role: "leader"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}")

      assert html =~ member_user.email
      assert html =~ "leader"
      assert html =~ "1名"
    end

    test "displays empty message when no members", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}")

      assert html =~ "メンバーが登録されていません"
    end

    test "displays task categories when they exist", %{conn: conn, festival: festival} do
      _category = task_category_fixture(festival, %{name: "設営", description: "会場設営タスク"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}")

      assert html =~ "設営"
      assert html =~ "会場設営タスク"
    end

    test "displays empty message when no task categories", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}")

      assert html =~ "タスクカテゴリが設定されていません"
    end

    test "has back link to festivals list", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}")

      assert html =~ "戻る"
      assert html =~ ~s(href="/festivals")
    end

    test "displays scale correctly for small festival", %{conn: conn, user: user} do
      small_festival = festival_fixture(user, %{scale: "small"})
      {:ok, _view, html} = live(conn, ~p"/festivals/#{small_festival}")

      assert html =~ "小規模"
    end

    test "displays scale correctly for large festival", %{conn: conn, user: user} do
      large_festival = festival_fixture(user, %{scale: "large"})
      {:ok, _view, html} = live(conn, ~p"/festivals/#{large_festival}")

      assert html =~ "大規模"
    end

    test "displays different statuses correctly", %{conn: conn, user: user} do
      active_festival = festival_fixture(user, %{status: "active"})
      {:ok, _view, html} = live(conn, ~p"/festivals/#{active_festival}")

      assert html =~ "開催中"
    end
  end
end
