defmodule MatsuriOpsWeb.HelpLive.ExternalTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures

  describe "External User Guide page" do
    test "renders external user guide page when logged in", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/external")

      assert html =~ "出店者・来場者ガイド"
      assert html =~ "外部ユーザー向けの簡易ガイド"
    end

    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/help/external")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays table of contents", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/external")

      assert html =~ "アカウント登録"
      assert html =~ "祭り情報の確認"
      assert html =~ "お知らせの受信"
      assert html =~ "連絡先・問い合わせ"
      assert html =~ "出店者向け情報"
      assert html =~ "スマートフォンでの利用"
    end

    test "displays account registration section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/external")

      assert html =~ "1. アカウント登録"
      assert html =~ "登録方法"
      assert html =~ "ログイン"
      assert html =~ "プロフィール設定"
    end

    test "displays festival info section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/external")

      assert html =~ "2. 祭り情報の確認"
      assert html =~ "祭り一覧"
      assert html =~ "祭り詳細"
      assert html =~ "開催日程"
      assert html =~ "開催場所"
    end

    test "displays notification section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/external")

      assert html =~ "3. お知らせの受信"
      assert html =~ "お知らせの確認"
      assert html =~ "お知らせの種類"
      assert html =~ "プッシュ通知の設定"
    end

    test "displays priority levels", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/external")

      assert html =~ "緊急"
      assert html =~ "すぐに確認してください"
    end

    test "displays contact section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/external")

      assert html =~ "4. 連絡先・問い合わせ"
      assert html =~ "チャットでの連絡"
      assert html =~ "お問い合わせ"
      assert html =~ "出店者チャットルーム"
      assert html =~ "緊急チャットルーム"
    end

    test "displays FAQ section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/external")

      assert html =~ "よくある質問"
      assert html =~ "ログインできません"
      assert html =~ "お知らせが見られません"
      assert html =~ "通知が届きません"
    end

    test "displays vendor information section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/external")

      assert html =~ "出店者向け情報"
      assert html =~ "出店準備"
      assert html =~ "当日の流れ"
      assert html =~ "緊急時の対応"
    end

    test "displays vendor preparation steps", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/external")

      assert html =~ "出店に関するお知らせを確認"
      assert html =~ "必要なドキュメント"
      assert html =~ "不明点はチャットで質問"
    end

    test "displays mobile usage section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/external")

      assert html =~ "スマートフォンでの利用"
      assert html =~ "PWAインストール方法"
      assert html =~ "iPhoneの場合"
      assert html =~ "Androidの場合"
    end

    test "displays PWA benefits", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/external")

      assert html =~ "PWAの利点"
      assert html =~ "アプリのようにすぐにアクセス"
      assert html =~ "プッシュ通知を受け取れる"
      assert html =~ "オフラインでも一部の機能が使える"
    end

    test "has back link to help index", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/external")

      assert html =~ "ヘルプトップに戻る"
      assert html =~ ~s(href="/help")
    end

    test "can navigate back to help index", %{conn: conn} do
      user = user_fixture()
      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/help/external")

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
