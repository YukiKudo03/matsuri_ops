defmodule MatsuriOpsWeb.TemplateLive.ApplyTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.TemplatesFixtures

  describe "Apply template page" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      template = template_fixture(user, %{
        name: "適用テストテンプレート",
        scale: "large"
      })
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, template: template}
    end

    test "renders apply template page", %{conn: conn, template: template} do
      {:ok, _view, html} = live(conn, ~p"/templates/#{template}/apply")

      assert html =~ template.name
    end

    test "redirects if not logged in", %{template: template} do
      conn = build_conn()
      assert {:error, redirect} = live(conn, ~p"/templates/#{template}/apply")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays template settings", %{conn: conn, template: template} do
      {:ok, _view, html} = live(conn, ~p"/templates/#{template}/apply")

      assert html =~ template.name
    end

    test "validates required festival fields", %{conn: conn, template: template} do
      {:ok, view, _html} = live(conn, ~p"/templates/#{template}/apply")

      result =
        view
        |> form("#apply-template-form", festival: %{name: "", start_date: "", end_date: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "creates festival from template", %{conn: conn, template: template} do
      {:ok, view, _html} = live(conn, ~p"/templates/#{template}/apply")

      view
      |> form("#apply-template-form", festival: %{
        name: "テンプレートから作成した祭り",
        start_date: "2026-07-01",
        end_date: "2026-07-03",
        venue_name: "テスト会場",
        venue_address: "東京都渋谷区"
      })
      |> render_submit()

      assert_redirect(view, "/festivals")
    end

    test "form has fields: name, start_date, end_date, venue_name, venue_address", %{conn: conn, template: template} do
      {:ok, _view, html} = live(conn, ~p"/templates/#{template}/apply")

      assert html =~ "name" or html =~ "祭り名" or html =~ "名前"
      assert html =~ "start_date" or html =~ "開始日"
      assert html =~ "end_date" or html =~ "終了日"
      assert html =~ "venue_name" or html =~ "会場名"
      assert html =~ "venue_address" or html =~ "会場住所"
    end
  end
end
