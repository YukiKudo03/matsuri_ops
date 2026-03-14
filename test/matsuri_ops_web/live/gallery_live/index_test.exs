defmodule MatsuriOpsWeb.GalleryLive.IndexTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.GalleryFixtures

  describe "Index page" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "renders gallery page", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/gallery")

      assert html =~ "フォトギャラリー"
      assert html =~ festival.name
    end

    test "redirects if user is not logged in", %{festival: festival} do
      conn = build_conn()
      assert {:error, redirect} = live(conn, ~p"/festivals/#{festival}/gallery")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays gallery statistics", %{conn: conn, festival: festival} do
      _image = gallery_image_fixture(festival, %{status: "approved"})
      _image2 = gallery_image_fixture(festival, %{status: "pending"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/gallery")

      assert html =~ "総画像数"
      assert html =~ "承認済"
      assert html =~ "総いいね"
      assert html =~ "総閲覧数"
    end

    test "displays gallery images in grid view", %{conn: conn, festival: festival} do
      image = gallery_image_fixture(festival, %{status: "approved", title: "テスト写真"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/gallery")

      assert html =~ "テスト写真"
    end

    test "can filter images by status", %{conn: conn, festival: festival} do
      _approved = gallery_image_fixture(festival, %{status: "approved", title: "承認画像"})
      _pending = gallery_image_fixture(festival, %{status: "pending", title: "保留画像"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/gallery")

      # フィルタを「すべて」に切り替え
      html =
        view
        |> render_click("filter", %{"status" => "all"})

      assert html =~ "承認画像"
      assert html =~ "保留画像"
    end

    test "can toggle view mode", %{conn: conn, festival: festival} do
      _image = gallery_image_fixture(festival, %{status: "approved"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/gallery")

      # リストビューに切り替え
      html =
        view
        |> render_click("toggle_view", %{"mode" => "list"})

      assert html =~ "gallery_images"
    end

    test "can toggle featured status", %{conn: conn, festival: festival} do
      image = gallery_image_fixture(festival, %{status: "approved", featured: false})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/gallery")

      # リストビューに切り替えてアクションを表示
      view |> render_click("toggle_view", %{"mode" => "list"})

      view
      |> render_click("toggle_featured", %{"id" => to_string(image.id)})

      html = render(view)
      assert html =~ "注目解除"
    end

    test "can delete image", %{conn: conn, festival: festival} do
      image = gallery_image_fixture(festival, %{status: "approved", title: "削除対象"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/gallery")

      view
      |> render_click("delete", %{"id" => to_string(image.id)})

      html = render(view)
      refute html =~ "削除対象"
    end
  end

  describe "New image modal" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "opens new image modal", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/gallery")

      view
      |> element("a", "写真を投稿")
      |> render_click()

      assert_patch(view, ~p"/festivals/#{festival}/gallery/new")
      assert has_element?(view, "#gallery-image-form")
    end

    test "displays image form fields", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/gallery/new")

      assert html =~ "画像URL"
      assert html =~ "タイトル"
      assert html =~ "説明"
      assert html =~ "投稿者名"
      assert html =~ "メールアドレス"
    end

    test "validates image form", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/gallery/new")

      result =
        view
        |> form("#gallery-image-form", gallery_image: %{image_url: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "saves new image", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/gallery/new")

      view
      |> form("#gallery-image-form", gallery_image: %{
        image_url: "https://example.com/new-test.jpg",
        title: "新規テスト画像",
        description: "テストの説明",
        contributor_name: "テスト太郎"
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/gallery")

      html = render(view)
      assert html =~ "新規テスト画像"
    end
  end

  describe "Edit image modal" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      image = gallery_image_fixture(festival, %{
        title: "編集対象画像",
        status: "approved"
      })
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, image: image}
    end

    test "opens edit image modal", %{conn: conn, festival: festival, image: image} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/gallery/#{image}/edit")

      assert html =~ "画像を編集"
      assert html =~ "編集対象画像"
    end

    test "updates image", %{conn: conn, festival: festival, image: image} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/gallery/#{image}/edit")

      view
      |> form("#gallery-image-form", gallery_image: %{title: "更新済み画像"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/gallery")

      html = render(view)
      assert html =~ "更新済み画像"
    end
  end
end
