defmodule MatsuriOpsWeb.AdBannerLive.IndexTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.AdvertisingFixtures

  describe "Index page" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "renders ad banner page", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/ad-banners")

      assert html =~ "広告バナー管理"
    end

    test "redirects if not logged in", %{festival: festival} do
      conn = build_conn()
      assert {:error, redirect} = live(conn, ~p"/festivals/#{festival}/ad-banners")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays statistics", %{conn: conn, festival: festival} do
      _banner = ad_banner_fixture(festival, %{name: "統計テストバナー", is_active: true})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/ad-banners")

      assert html =~ "total_count" or html =~ "合計" or html =~ "バナー数"
      assert html =~ "active_count" or html =~ "有効" or html =~ "アクティブ"
      assert html =~ "total_clicks" or html =~ "クリック"
      assert html =~ "total_impressions" or html =~ "表示回数" or html =~ "インプレッション"
    end

    test "displays ad banners in table", %{conn: conn, festival: festival} do
      banner = ad_banner_fixture(festival, %{name: "テーブル表示バナー"})

      {:ok, view, html} = live(conn, ~p"/festivals/#{festival}/ad-banners")

      assert html =~ "テーブル表示バナー"
      assert has_element?(view, "#ad_banners")
      assert has_element?(view, "#ad_banners-#{banner.id}")
    end

    test "can filter by position", %{conn: conn, festival: festival} do
      _sidebar = ad_banner_fixture(festival, %{name: "サイドバナー", position: "sidebar"})
      _header = ad_banner_fixture(festival, %{name: "ヘッダーバナー", position: "header"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/ad-banners")

      html =
        view
        |> render_click("filter", %{"position" => "sidebar"})

      assert html =~ "サイドバナー"
    end

    test "can toggle active status", %{conn: conn, festival: festival} do
      banner = ad_banner_fixture(festival, %{name: "トグルバナー", is_active: true})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/ad-banners")

      view
      |> render_click("toggle_active", %{"id" => to_string(banner.id)})

      html = render(view)
      assert html =~ "トグルバナー"
    end

    test "can delete banner", %{conn: conn, festival: festival} do
      banner = ad_banner_fixture(festival, %{name: "削除バナー"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/ad-banners")

      assert has_element?(view, "#ad_banners-#{banner.id}")

      view
      |> render_click("delete", %{"id" => to_string(banner.id)})

      refute has_element?(view, "#ad_banners-#{banner.id}")
    end
  end

  describe "New banner modal" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "opens new banner modal", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/ad-banners")

      view
      |> element("a", "新規広告バナー")
      |> render_click()

      assert_patch(view, ~p"/festivals/#{festival}/ad-banners/new")
      assert has_element?(view, "#ad-banner-form")
    end

    test "saves new banner", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/ad-banners/new")

      view
      |> form("#ad-banner-form", ad_banner: %{
        name: "新規広告バナー",
        position: "sidebar",
        image_url: "https://example.com/ad.jpg",
        link_url: "https://example.com",
        start_date: Date.utc_today(),
        end_date: Date.utc_today() |> Date.add(30),
        display_weight: 1,
        is_active: true
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/ad-banners")
      assert render(view) =~ "新規広告バナー"
    end
  end

  describe "Edit banner modal" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      banner = ad_banner_fixture(festival, %{name: "編集対象バナー"})
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, banner: banner}
    end

    test "opens edit modal", %{conn: conn, festival: festival, banner: banner} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/ad-banners/#{banner}/edit")

      assert html =~ "編集対象バナー"
    end

    test "updates banner", %{conn: conn, festival: festival, banner: banner} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/ad-banners/#{banner}/edit")

      view
      |> form("#ad-banner-form", ad_banner: %{name: "更新済みバナー"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/ad-banners")
      assert render(view) =~ "更新済みバナー"
    end
  end
end
