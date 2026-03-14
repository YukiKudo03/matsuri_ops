defmodule MatsuriOpsWeb.GalleryLive.FormComponentTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.GalleryFixtures

  describe "Form component through Index LiveView" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "validates required fields", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/gallery/new")

      result =
        view
        |> form("#gallery-image-form", gallery_image: %{image_url: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "saves new gallery image with valid data", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/gallery/new")

      view
      |> form("#gallery-image-form", gallery_image: %{
        image_url: "https://example.com/valid-image.jpg",
        title: "フォームテスト画像",
        description: "フォームコンポーネントのテスト",
        contributor_name: "テスト投稿者",
        contributor_email: "form-test@example.com"
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/gallery")

      html = render(view)
      assert html =~ "フォームテスト画像"
    end

    test "updates existing gallery image", %{conn: conn, festival: festival} do
      image = gallery_image_fixture(festival, %{
        title: "更新前タイトル",
        status: "approved"
      })

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/gallery/#{image}/edit")

      view
      |> form("#gallery-image-form", gallery_image: %{
        title: "更新後タイトル",
        description: "更新後の説明"
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/gallery")

      html = render(view)
      assert html =~ "更新後タイトル"
    end

    test "shows validation errors for invalid data", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/gallery/new")

      result =
        view
        |> form("#gallery-image-form", gallery_image: %{
          image_url: "",
          title: ""
        })
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end
  end
end
