defmodule MatsuriOpsWeb.AdBannerLive.FormComponentTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.AdvertisingFixtures

  describe "FormComponent for new banner" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "validates required fields", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/ad-banners/new")

      result =
        view
        |> form("#ad-banner-form", ad_banner: %{name: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "saves new banner with valid data", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/ad-banners/new")

      view
      |> form("#ad-banner-form", ad_banner: %{
        name: "フォームテストバナー",
        position: "sidebar",
        image_url: "https://example.com/banner.jpg",
        link_url: "https://example.com",
        start_date: Date.utc_today(),
        end_date: Date.utc_today() |> Date.add(30),
        display_weight: 1,
        is_active: true
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/ad-banners")
      assert render(view) =~ "フォームテストバナー"
    end

    test "shows validation errors", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/ad-banners/new")

      result =
        view
        |> form("#ad-banner-form", ad_banner: %{name: "", image_url: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "form has expected fields", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/ad-banners/new")

      assert has_field?(html, "name") or html =~ "バナー名" or html =~ "名前"
      assert has_field?(html, "position") or html =~ "表示位置" or html =~ "ポジション"
      assert has_field?(html, "image_url") or html =~ "画像URL" or html =~ "画像"
      assert has_field?(html, "link_url") or html =~ "リンクURL" or html =~ "リンク"
      assert has_field?(html, "start_date") or html =~ "開始日"
      assert has_field?(html, "end_date") or html =~ "終了日"
      assert has_field?(html, "display_weight") or html =~ "表示重み" or html =~ "優先度"
      assert has_field?(html, "is_active") or html =~ "有効" or html =~ "ステータス"
    end

    test "form id is ad-banner-form", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/ad-banners/new")

      assert has_element?(view, "#ad-banner-form")
    end
  end

  describe "FormComponent for editing banner" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      banner = ad_banner_fixture(festival, %{name: "編集フォームバナー"})
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, banner: banner}
    end

    test "updates existing banner", %{conn: conn, festival: festival, banner: banner} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/ad-banners/#{banner}/edit")

      view
      |> form("#ad-banner-form", ad_banner: %{name: "更新フォームバナー"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/ad-banners")
      assert render(view) =~ "更新フォームバナー"
    end
  end

  # Helper to check if form has a field by name
  defp has_field?(html, field_name) do
    html =~ "ad_banner[#{field_name}]" or html =~ "ad_banner_#{field_name}"
  end
end
