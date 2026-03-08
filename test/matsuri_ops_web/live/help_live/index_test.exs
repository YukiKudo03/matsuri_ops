defmodule MatsuriOpsWeb.HelpLive.IndexTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures

  describe "Help Index page" do
    test "renders help index page when logged in", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help")

      assert html =~ "ヘルプ &amp; サポート"
      assert html =~ "MatsuriOpsの使い方ガイド"
    end

    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/help")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays all help category cards", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help")

      assert html =~ "クイックスタート"
      assert html =~ "管理者マニュアル"
      assert html =~ "スタッフマニュアル"
      assert html =~ "外部ユーザーガイド"
    end

    test "displays FAQ section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help")

      assert html =~ "よくある質問"
      assert html =~ "ログインできません"
      assert html =~ "タスクを確認したい"
      assert html =~ "シフトを確認したい"
    end

    test "displays support section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help")

      assert html =~ "サポート"
      assert html =~ "チャットで運営スタッフに連絡"
    end

    test "has navigation link to festivals", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help")

      assert html =~ "祭り一覧に戻る"
      assert html =~ ~s(href="/festivals")
    end

    test "has links to all help subpages", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help")

      assert html =~ ~s(href="/help/quickstart")
      assert html =~ ~s(href="/help/admin")
      assert html =~ ~s(href="/help/staff")
      assert html =~ ~s(href="/help/external")
    end

    test "can navigate to quickstart page", %{conn: conn} do
      user = user_fixture()
      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/help")

      assert {:error, {:live_redirect, %{to: "/help/quickstart"}}} =
        view
        |> element("a", "クイックスタート")
        |> render_click()

      # Verify the target page renders correctly
      {:ok, _view, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/help/quickstart")

      assert html =~ "クイックスタートガイド"
    end

    test "can navigate to admin manual page", %{conn: conn} do
      user = user_fixture()
      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/help")

      assert {:error, {:live_redirect, %{to: "/help/admin"}}} =
        view
        |> element("a", "管理者マニュアル")
        |> render_click()

      # Verify the target page renders correctly
      {:ok, _view, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/help/admin")

      assert html =~ "管理者マニュアル"
    end

    test "can navigate to staff manual page", %{conn: conn} do
      user = user_fixture()
      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/help")

      assert {:error, {:live_redirect, %{to: "/help/staff"}}} =
        view
        |> element("a", "スタッフマニュアル")
        |> render_click()

      # Verify the target page renders correctly
      {:ok, _view, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/help/staff")

      assert html =~ "スタッフマニュアル"
    end

    test "can navigate to external user guide page", %{conn: conn} do
      user = user_fixture()
      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/help")

      assert {:error, {:live_redirect, %{to: "/help/external"}}} =
        view
        |> element("a", "外部ユーザーガイド")
        |> render_click()

      # Verify the target page renders correctly
      {:ok, _view, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/help/external")

      assert html =~ "出店者・来場者ガイド"
    end
  end
end
