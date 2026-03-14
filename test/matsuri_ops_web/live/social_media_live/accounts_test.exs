defmodule MatsuriOpsWeb.SocialMediaLive.AccountsTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.SocialMediaFixtures

  describe "Accounts page" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "renders accounts page", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/social/accounts")

      assert html =~ "SNSアカウント設定"
      assert html =~ festival.name
    end

    test "redirects if not logged in", %{festival: festival} do
      conn = build_conn()
      assert {:error, redirect} = live(conn, ~p"/festivals/#{festival}/social/accounts")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays demo mode warning", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/social/accounts")

      assert html =~ "デモモード"
      assert html =~ "SNS連携はデモモードで動作しています"
    end

    test "displays platform cards", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/social/accounts")

      assert html =~ "アカウントを追加"
    end

    test "can add account", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/social/accounts")

      # アカウント追加イベントを発火
      view
      |> render_click("add_account", %{"platform" => "twitter"})

      html = render(view)
      assert html =~ "twitter_demo_account"
    end

    test "can toggle account active status", %{conn: conn, festival: festival} do
      account = social_account_fixture(festival, %{platform: "twitter", account_name: "test_toggle"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/social/accounts")

      # 有効/無効切り替えイベントを発火
      view
      |> render_click("toggle_active", %{"id" => to_string(account.id)})

      html = render(view)
      # トグル後もページが正常に表示されること
      assert html =~ "SNSアカウント設定"
    end

    test "can delete account", %{conn: conn, festival: festival} do
      account = social_account_fixture(festival, %{platform: "twitter", account_name: "delete_target"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/social/accounts")

      # 削除イベントを発火
      view
      |> render_click("delete", %{"id" => to_string(account.id)})

      refute render(view) =~ "delete_target"
    end

    test "displays accounts in table", %{conn: conn, festival: festival} do
      _account = social_account_fixture(festival, %{platform: "twitter", account_name: "table_test_account"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/social/accounts")

      assert html =~ "table_test_account"
      assert html =~ "連携済みアカウント"
    end
  end
end
