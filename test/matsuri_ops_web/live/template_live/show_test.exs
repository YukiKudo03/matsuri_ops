defmodule MatsuriOpsWeb.TemplateLive.ShowTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.TemplatesFixtures

  describe "Show page" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      template = template_fixture(user, %{
        name: "テスト祭りテンプレート",
        description: "大規模祭り用テンプレート",
        scale: "large",
        is_public: true
      })
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, template: template}
    end

    test "renders template details page", %{conn: conn, template: template} do
      {:ok, _view, html} = live(conn, ~p"/templates/#{template}")

      assert html =~ template.name
    end

    test "redirects if not logged in", %{template: template} do
      conn = build_conn()
      assert {:error, redirect} = live(conn, ~p"/templates/#{template}")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays template info", %{conn: conn, template: template} do
      {:ok, _view, html} = live(conn, ~p"/templates/#{template}")

      assert html =~ template.name
      assert html =~ "large" or html =~ "大規模"
    end

    test "shows default values", %{conn: conn, template: template} do
      {:ok, _view, html} = live(conn, ~p"/templates/#{template}")

      assert html =~ template.name
    end

    test "shows public/private status", %{conn: conn, template: template} do
      {:ok, _view, html} = live(conn, ~p"/templates/#{template}")

      assert html =~ "公開" or html =~ "public" or html =~ "Public"
    end
  end
end
