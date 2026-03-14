defmodule MatsuriOpsWeb.SocialMediaLive.IndexTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.SocialMediaFixtures

  describe "Index page" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "renders social media page", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/social")

      assert html =~ "SNS投稿管理"
      assert html =~ festival.name
    end

    test "redirects if not logged in", %{festival: festival} do
      conn = build_conn()
      assert {:error, redirect} = live(conn, ~p"/festivals/#{festival}/social")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays social media statistics", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/social")

      assert html =~ "総投稿数"
      assert html =~ "投稿済"
      assert html =~ "総いいね"
      assert html =~ "総リーチ"
    end

    test "displays social posts in table", %{conn: conn, user: user, festival: festival} do
      _post = social_post_fixture(festival, user, %{content: "テスト投稿内容"})

      {:ok, view, html} = live(conn, ~p"/festivals/#{festival}/social")

      assert html =~ "テスト投稿内容"
      assert has_element?(view, "#social_posts")
    end

    test "can filter posts by status", %{conn: conn, user: user, festival: festival} do
      _post = social_post_fixture(festival, user, %{content: "フィルタテスト投稿"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/social")

      # フィルタイベントを発火
      view
      |> render_click("filter", %{"status" => "draft"})

      html = render(view)
      assert html =~ "SNS投稿管理"
    end

    test "can delete post", %{conn: conn, user: user, festival: festival} do
      post = social_post_fixture(festival, user, %{content: "削除対象投稿"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/social")

      # 削除イベントを発火
      view
      |> render_click("delete", %{"id" => to_string(post.id)})

      refute render(view) =~ "削除対象投稿"
    end

    test "can duplicate post", %{conn: conn, user: user, festival: festival} do
      post = social_post_fixture(festival, user, %{content: "コピー対象投稿"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/social")

      # コピーイベントを発火
      view
      |> render_click("duplicate", %{"id" => to_string(post.id)})

      assert render(view) =~ "コピー対象投稿"
    end

    test "opens new post modal", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/social")

      view
      |> element("a", "新規投稿")
      |> render_click()

      assert_patch(view, ~p"/festivals/#{festival}/social/new")
      assert has_element?(view, "#social-post-form")
    end

    test "saves new post", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/social/new")

      view
      |> form("#social-post-form", %{
        "social_post" => %{
          "content" => "新規テスト投稿",
          "platforms" => ["twitter"]
        }
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/social")
      assert render(view) =~ "新規テスト投稿"
    end

    test "opens edit post modal", %{conn: conn, user: user, festival: festival} do
      post = social_post_fixture(festival, user, %{content: "編集対象投稿"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/social/#{post}/edit")

      assert html =~ "投稿を編集"
      assert html =~ "編集対象投稿"
    end

    test "updates post", %{conn: conn, user: user, festival: festival} do
      post = social_post_fixture(festival, user, %{content: "更新前投稿"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/social/#{post}/edit")

      view
      |> form("#social-post-form", social_post: %{content: "更新後投稿"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/social")
      assert render(view) =~ "更新後投稿"
    end
  end
end
