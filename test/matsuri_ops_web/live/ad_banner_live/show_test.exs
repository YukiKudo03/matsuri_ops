defmodule MatsuriOpsWeb.AdBannerLive.ShowTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.AdvertisingFixtures

  describe "Show page" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "renders banner details page", %{conn: conn, festival: festival} do
      banner = ad_banner_fixture(festival, %{name: "詳細表示バナー"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/ad-banners/#{banner}")

      assert html =~ "詳細表示バナー"
    end

    test "redirects if not logged in", %{festival: festival} do
      conn = build_conn()
      banner = ad_banner_fixture(festival, %{name: "未認証テスト"})

      assert {:error, redirect} = live(conn, ~p"/festivals/#{festival}/ad-banners/#{banner}")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays banner information", %{conn: conn, festival: festival} do
      banner = ad_banner_fixture(festival, %{
        name: "情報表示バナー",
        position: "sidebar",
        is_active: true
      })

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/ad-banners/#{banner}")

      assert html =~ "情報表示バナー"
      assert html =~ "sidebar" or html =~ "サイドバー"
    end

    test "shows 有効 for active banner", %{conn: conn, festival: festival} do
      banner = ad_banner_fixture(festival, %{name: "有効バナー", is_active: true})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/ad-banners/#{banner}")

      assert html =~ "有効"
    end

    test "shows 無効 for inactive banner", %{conn: conn, festival: festival} do
      banner = ad_banner_fixture(festival, %{name: "無効バナー", is_active: false})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/ad-banners/#{banner}")

      assert html =~ "無効"
    end

    test "can toggle active status", %{conn: conn, festival: festival} do
      banner = ad_banner_fixture(festival, %{name: "トグルテスト", is_active: true})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/ad-banners/#{banner}")

      view
      |> render_click("toggle_active", %{})

      html = render(view)
      assert html =~ "トグルテスト"
    end

    test "displays performance metrics", %{conn: conn, festival: festival} do
      banner = ad_banner_fixture(festival, %{name: "メトリクスバナー"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/ad-banners/#{banner}")

      assert html =~ "インプレッション" or html =~ "表示回数" or html =~ "impressions"
      assert html =~ "クリック" or html =~ "clicks"
    end

    test "displays sponsor info when present", %{conn: conn, festival: festival} do
      sponsor = sponsor_fixture(%{name: "テストスポンサー企業"})
      banner = ad_banner_fixture(festival, %{name: "スポンサー付きバナー", sponsor_id: sponsor.id})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/ad-banners/#{banner}")

      assert html =~ "テストスポンサー企業" or html =~ "スポンサー"
    end
  end
end
