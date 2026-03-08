defmodule MatsuriOpsWeb.HelpLive.StaffTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures

  describe "Staff Manual page" do
    test "renders staff manual page when logged in", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/staff")

      assert html =~ "スタッフマニュアル"
      assert html =~ "リーダー・スタッフ・ボランティア向け"
    end

    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/help/staff")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays table of contents", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/staff")

      assert html =~ "ログインと基本操作"
      assert html =~ "自分のタスク確認"
      assert html =~ "シフト確認"
      assert html =~ "当日の操作"
      assert html =~ "チャット・連絡"
      assert html =~ "お知らせ確認"
      assert html =~ "ドキュメント閲覧"
    end

    test "displays login section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/staff")

      assert html =~ "1. ログインと基本操作"
      assert html =~ "ログイン方法"
      assert html =~ "ホーム画面"
      assert html =~ "祭り詳細画面"
    end

    test "displays task section with status explanations", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/staff")

      assert html =~ "2. 自分のタスク確認"
      assert html =~ "タスク一覧を開く"
      assert html =~ "タスクの見方"
      assert html =~ "未着手"
      assert html =~ "進行中"
      assert html =~ "完了"
      assert html =~ "保留"
    end

    test "displays priority explanations", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/staff")

      assert html =~ "優先度"
      assert html =~ "緊急"
      assert html =~ "最優先で対応"
    end

    test "displays shift section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/staff")

      assert html =~ "3. シフト確認"
      assert html =~ "シフト一覧を開く"
      assert html =~ "シフトの見方"
      assert html =~ "自分のシフトを確認"
    end

    test "displays operations section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/staff")

      assert html =~ "4. 当日の操作"
      assert html =~ "運営ダッシュボード"
      assert html =~ "インシデント報告"
      assert html =~ "位置情報の共有"
      assert html =~ "エリア状況の確認"
    end

    test "displays incident severity guide", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/staff")

      assert html =~ "重大度の目安"
      assert html =~ "救急対応が必要"
      assert html =~ "けが人発生"
      assert html =~ "遺失物"
    end

    test "displays crowding level guide", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/staff")

      assert html =~ "混雑度"
      assert html =~ "空き"
      assert html =~ "閑散"
      assert html =~ "混雑"
      assert html =~ "過密"
    end

    test "displays chat section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/staff")

      assert html =~ "5. チャット・連絡"
      assert html =~ "チャットルームの種類"
      assert html =~ "一般"
      assert html =~ "緊急"
      assert html =~ "スタッフ"
    end

    test "displays announcement section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/staff")

      assert html =~ "6. お知らせ確認"
      assert html =~ "お知らせを開く"
      assert html =~ "お知らせの見方"
      assert html =~ "プッシュ通知"
    end

    test "displays document section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/staff")

      assert html =~ "7. ドキュメント閲覧"
      assert html =~ "ドキュメントを開く"
      assert html =~ "ドキュメントの種類"
      assert html =~ "マニュアル"
      assert html =~ "テンプレート"
    end

    test "displays FAQ section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/staff")

      assert html =~ "よくある質問"
      assert html =~ "パスワードを忘れました"
      assert html =~ "シフトを変更してほしい"
      assert html =~ "インシデント報告を間違えました"
      assert html =~ "通知が届きません"
    end

    test "displays emergency contacts section", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/staff")

      assert html =~ "緊急連絡先"
      assert html =~ "運営に関する問題"
      assert html =~ "システムに関する問題"
      assert html =~ "緊急事態"
    end

    test "has back link to help index", %{conn: conn} do
      {:ok, _view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/help/staff")

      assert html =~ "ヘルプトップに戻る"
      assert html =~ ~s(href="/help")
    end

    test "can navigate back to help index", %{conn: conn} do
      user = user_fixture()
      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/help/staff")

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
