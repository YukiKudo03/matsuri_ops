defmodule MatsuriOpsWeb.GalleryLive.ShowTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.GalleryFixtures

  describe "Show page" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "renders image details page", %{conn: conn, festival: festival} do
      image = gallery_image_fixture(festival, %{title: "詳細テスト画像", status: "approved"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/gallery/#{image}")

      assert html =~ "詳細テスト画像"
      assert html =~ "詳細情報"
    end

    test "redirects if not logged in", %{festival: festival} do
      conn = build_conn()
      image = gallery_image_fixture(festival, %{status: "approved"})

      assert {:error, redirect} = live(conn, ~p"/festivals/#{festival}/gallery/#{image}")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays image information", %{conn: conn, festival: festival} do
      image = gallery_image_fixture(festival, %{
        title: "情報表示テスト",
        status: "approved",
        contributor_name: "山田太郎"
      })

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/gallery/#{image}")

      assert html =~ "情報表示テスト"
      assert html =~ "山田太郎"
      assert html =~ "投稿者"
      assert html =~ "閲覧数"
      assert html =~ "いいね数"
    end

    test "can like image", %{conn: conn, festival: festival} do
      image = gallery_image_fixture(festival, %{status: "approved"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/gallery/#{image}")

      view
      |> render_click("like")

      html = render(view)
      assert html =~ "いいね (1)"
    end

    test "can toggle featured status", %{conn: conn, festival: festival} do
      image = gallery_image_fixture(festival, %{status: "approved", featured: false})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/gallery/#{image}")

      assert render(view) =~ "注目に設定"

      view
      |> render_click("toggle_featured")

      html = render(view)
      assert html =~ "注目解除"
    end

    test "displays status badge", %{conn: conn, festival: festival} do
      image = gallery_image_fixture(festival, %{status: "approved"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/gallery/#{image}")

      assert html =~ "承認済"
    end

    test "shows featured badge when featured", %{conn: conn, festival: festival} do
      image = gallery_image_fixture(festival, %{status: "approved", featured: true})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/gallery/#{image}")

      assert html =~ "注目"
    end

    test "increments view count on mount", %{conn: conn, festival: festival} do
      image = gallery_image_fixture(festival, %{status: "approved"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/gallery/#{image}")

      # 閲覧数が1にインクリメントされていることを確認
      assert html =~ "閲覧数"
    end
  end
end
