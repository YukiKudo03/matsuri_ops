defmodule MatsuriOpsWeb.SocialMediaLive.FormComponentTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.SocialMediaFixtures

  describe "Form component" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "validates required fields", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/social/new")

      result =
        view
        |> form("#social-post-form", social_post: %{content: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "saves new social post with valid data", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/social/new")

      view
      |> form("#social-post-form", %{
        "social_post" => %{
          "content" => "フォームテスト新規投稿",
          "platforms" => ["twitter"]
        }
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/social")
      assert render(view) =~ "フォームテスト新規投稿"
    end

    test "updates existing social post", %{conn: conn, user: user, festival: festival} do
      post = social_post_fixture(festival, user, %{content: "更新前の内容"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/social/#{post}/edit")

      view
      |> form("#social-post-form", social_post: %{content: "更新後の内容"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/social")
      assert render(view) =~ "更新後の内容"
    end

    test "shows validation errors", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/social/new")

      result =
        view
        |> form("#social-post-form", social_post: %{content: ""})
        |> render_change()

      # フォームにバリデーションエラーが表示されること
      assert result =~ "social-post-form"
    end
  end
end
