defmodule MatsuriOpsWeb.HelpLive.AdminTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures

  describe "Admin Manual page" do
    test "renders admin manual page when logged in", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/admin")

      assert html =~ "管理者マニュアル"
      assert html =~ "システム管理者・実行委員・事務局向け"
    end

    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/help/admin")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays table of contents", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/admin")

      assert html =~ "システム概要"
      assert html =~ "ユーザー管理"
      assert html =~ "祭り管理"
      assert html =~ "タスク管理"
      assert html =~ "予算管理"
      assert html =~ "シフト管理"
      assert html =~ "当日運営"
      assert html =~ "レポート・分析"
      assert html =~ "その他の機能"
    end

    test "displays system overview section with user roles", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/admin")

      assert html =~ "1. システム概要"
      assert html =~ "ユーザーロール"
      assert html =~ "システム管理者"
      assert html =~ "実行委員"
      assert html =~ "事務局"
      assert html =~ "リーダー"
      assert html =~ "スタッフ"
      assert html =~ "ボランティア"
      assert html =~ "出店者"
      assert html =~ "来場者"
    end

    test "displays user management section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/admin")

      assert html =~ "2. ユーザー管理"
      assert html =~ "スタッフの追加"
      assert html =~ "ロールの変更"
      assert html =~ "スタッフの削除"
    end

    test "displays festival management section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/admin")

      assert html =~ "3. 祭り管理"
      assert html =~ "祭りの作成"
      assert html =~ "祭りのステータス"
      assert html =~ "テンプレートの活用"
    end

    test "displays task management section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/admin")

      assert html =~ "4. タスク管理"
      assert html =~ "タスク一覧"
      assert html =~ "タスクの作成"
      assert html =~ "ガントチャート"
    end

    test "displays budget management section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/admin")

      assert html =~ "5. 予算管理"
      assert html =~ "予算ダッシュボード"
      assert html =~ "予算カテゴリの設定"
      assert html =~ "経費の登録"
      assert html =~ "経費の承認"
    end

    test "displays shift management section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/admin")

      assert html =~ "6. シフト管理"
      assert html =~ "シフト一覧"
      assert html =~ "シフトの作成"
    end

    test "displays operations section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/admin")

      assert html =~ "7. 当日運営"
      assert html =~ "運営ダッシュボード"
      assert html =~ "エリアの追加"
      assert html =~ "インシデント報告"
      assert html =~ "インシデント対応"
    end

    test "displays reports section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/admin")

      assert html =~ "8. レポート・分析"
      assert html =~ "決算報告書"
      assert html =~ "年度比較"
      assert html =~ "PDF出力"
    end

    test "displays other features section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/admin")

      assert html =~ "9. その他の機能"
      assert html =~ "チャット"
      assert html =~ "お知らせ"
      assert html =~ "ドキュメント"
      assert html =~ "位置情報"
    end

    test "displays troubleshooting section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/admin")

      assert html =~ "トラブルシューティング"
      assert html =~ "よくある問題"
      assert html =~ "経費が承認できない"
      assert html =~ "タスクが表示されない"
    end

    test "has back link to help index", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/admin")

      assert html =~ "ヘルプトップに戻る"
      assert html =~ ~s(href="/help")
    end

    test "can navigate back to help index", %{conn: conn} do
      user = user_fixture()
      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/help/admin")

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
