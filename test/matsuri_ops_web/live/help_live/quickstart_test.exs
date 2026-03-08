defmodule MatsuriOpsWeb.HelpLive.QuickstartTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures

  describe "Quickstart page" do
    test "renders quickstart page when logged in", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/quickstart")

      assert html =~ "クイックスタートガイド"
      assert html =~ "5分で始められる基本操作ガイド"
    end

    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/help/quickstart")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays MatsuriOps introduction section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/quickstart")

      assert html =~ "MatsuriOpsとは"
      assert html =~ "祭り情報の一元管理"
      assert html =~ "タスク・スケジュール管理"
      assert html =~ "予算・経費管理"
    end

    test "displays supported environments", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/quickstart")

      assert html =~ "Chrome"
      assert html =~ "Safari"
      assert html =~ "Firefox"
      assert html =~ "Edge"
      assert html =~ "スマートフォン"
    end

    test "displays Step 1: Account registration", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/quickstart")

      assert html =~ "Step 1: アカウント登録"
      assert html =~ "登録画面へアクセス"
      assert html =~ "メールアドレスを入力"
      assert html =~ "確認メールからログイン"
    end

    test "displays Step 2: Profile settings", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/quickstart")

      assert html =~ "Step 2: プロフィール設定"
      assert html =~ "設定画面へ移動"
      assert html =~ "基本情報を入力"
    end

    test "displays Step 3: Festival participation", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/quickstart")

      assert html =~ "Step 3: 祭りに参加/作成"
      assert html =~ "祭り一覧を確認"
      assert html =~ "既存の祭りに参加する場合"
      assert html =~ "新しい祭りを作成する場合"
    end

    test "displays next steps with role-based guides", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/quickstart")

      assert html =~ "次のステップ"
      assert html =~ "ロール別ガイド"
      assert html =~ "管理者マニュアル"
      assert html =~ "スタッフマニュアル"
      assert html =~ "外部ユーザーガイド"
    end

    test "displays troubleshooting section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/quickstart")

      assert html =~ "トラブルシューティング"
      assert html =~ "ログインできない"
      assert html =~ "画面が正しく表示されない"
    end

    test "displays PWA installation instructions", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/quickstart")

      assert html =~ "PWAとしてインストール"
      assert html =~ "iPhoneの場合"
      assert html =~ "Androidの場合"
    end

    test "has back link to help index", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/quickstart")

      assert html =~ "ヘルプトップに戻る"
      assert html =~ ~s(href="/help")
    end

    test "has links to other manuals", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/quickstart")

      assert html =~ ~s(href="/help/admin")
      assert html =~ ~s(href="/help/staff")
      assert html =~ ~s(href="/help/external")
    end

    test "can navigate back to help index", %{conn: conn} do
      user = user_fixture()
      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/help/quickstart")

      assert {:error, {:live_redirect, %{to: "/help"}}} =
        view
        |> element("a", "ヘルプトップに戻る")
        |> render_click()

      # Verify the target page renders correctly
      {:ok, _view, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/help")

      assert html =~ "ヘルプ &amp; サポート"
    end
  end
end
