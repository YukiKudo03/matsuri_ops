defmodule MatsuriOpsWeb.GalleryLive.ModerationTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.GalleryFixtures

  describe "Moderation page" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "renders moderation page", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/gallery/moderation")

      assert html =~ "画像審査"
      assert html =~ festival.name
    end

    test "redirects if not logged in", %{festival: festival} do
      conn = build_conn()
      assert {:error, redirect} = live(conn, ~p"/festivals/#{festival}/gallery/moderation")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays pending images", %{conn: conn, festival: festival} do
      image = gallery_image_fixture(festival, %{
        title: "審査待ち画像",
        status: "pending",
        contributor_name: "テスト投稿者"
      })

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/gallery/moderation")

      assert html =~ "審査待ち画像"
      assert html =~ "テスト投稿者"
      assert html =~ image.image_url
    end

    test "displays moderation statistics", %{conn: conn, festival: festival} do
      _pending = gallery_image_fixture(festival, %{status: "pending"})
      _approved = gallery_image_fixture(festival, %{status: "approved"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/gallery/moderation")

      assert html =~ "審査待ち"
      assert html =~ "承認済"
      assert html =~ "却下"
    end

    test "can approve image", %{conn: conn, festival: festival} do
      image = gallery_image_fixture(festival, %{title: "承認対象画像", status: "pending"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/gallery/moderation")

      view
      |> render_click("approve", %{"id" => to_string(image.id)})

      html = render(view)
      refute html =~ "承認対象画像"
    end

    test "can reject image", %{conn: conn, festival: festival} do
      image = gallery_image_fixture(festival, %{title: "却下対象画像", status: "pending"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/gallery/moderation")

      view
      |> render_click("reject", %{"id" => to_string(image.id)})

      html = render(view)
      refute html =~ "却下対象画像"
    end

    test "can approve all pending", %{conn: conn, festival: festival} do
      _image1 = gallery_image_fixture(festival, %{status: "pending"})
      _image2 = gallery_image_fixture(festival, %{status: "pending"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/gallery/moderation")

      view
      |> render_click("approve_all")

      html = render(view)
      assert html =~ "審査待ちの画像はありません"
    end

    test "shows empty state when no pending images", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/gallery/moderation")

      assert html =~ "審査待ちの画像はありません"
      assert html =~ "すべての画像が審査済みです"
    end
  end
end
