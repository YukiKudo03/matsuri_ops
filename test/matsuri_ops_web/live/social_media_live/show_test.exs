defmodule MatsuriOpsWeb.SocialMediaLive.ShowTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.SocialMediaFixtures

  describe "Show page" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "renders post details", %{conn: conn, user: user, festival: festival} do
      post = social_post_fixture(festival, user, %{content: "詳細表示テスト投稿"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/social/#{post}")

      assert html =~ "投稿詳細"
      assert html =~ "詳細表示テスト投稿"
    end

    test "redirects if not logged in", %{user: user, festival: festival} do
      post = social_post_fixture(festival, user, %{content: "ログインテスト"})
      conn = build_conn()

      assert {:error, redirect} = live(conn, ~p"/festivals/#{festival}/social/#{post}")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays post content and platforms", %{conn: conn, user: user, festival: festival} do
      post = social_post_fixture(festival, user, %{
        content: "プラットフォーム表示テスト",
        platforms: ["twitter"]
      })

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/social/#{post}")

      assert html =~ "プラットフォーム表示テスト"
      assert html =~ "投稿内容"
      assert html =~ "投稿先"
    end

    test "displays hashtags when present", %{conn: conn, user: user, festival: festival} do
      post = social_post_fixture(festival, user, %{
        content: "ハッシュタグテスト #祭り #テスト"
      })

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/social/#{post}")

      assert html =~ "ハッシュタグ"
      assert html =~ "#祭り"
      assert html =~ "#テスト"
    end

    test "can post now", %{conn: conn, user: user, festival: festival} do
      post = social_post_fixture(festival, user, %{content: "即時投稿テスト"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/social/#{post}")

      # 今すぐ投稿イベントを発火
      view
      |> render_click("post_now")

      html = render(view)
      assert html =~ "投稿済"
    end

    test "can schedule post", %{conn: conn, user: user, festival: festival} do
      post = social_post_fixture(festival, user, %{content: "予約投稿テスト"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/social/#{post}")

      # 予約投稿イベントを発火
      view
      |> render_click("schedule", %{"scheduled_at" => "2026-12-25T10:00"})

      html = render(view)
      assert html =~ "予約済"
    end
  end
end
