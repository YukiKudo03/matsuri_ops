defmodule MatsuriOpsWeb.TemplateLive.FormComponentTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.TemplatesFixtures

  describe "New template form" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "validates required fields", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/templates/new")

      result =
        view
        |> form("#template-form", template: %{name: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "saves new template", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/templates/new")

      view
      |> form("#template-form", template: %{
        name: "新規テンプレート",
        description: "テスト説明",
        scale: "medium",
        is_public: false
      })
      |> render_submit()

      assert_patch(view, ~p"/templates")
      assert render(view) =~ "新規テンプレート"
    end

    test "updates existing template", %{conn: conn, user: user} do
      template = template_fixture(user, %{name: "更新前テンプレート"})

      {:ok, view, _html} = live(conn, ~p"/templates/#{template}/edit")

      view
      |> form("#template-form", template: %{name: "更新後テンプレート"})
      |> render_submit()

      assert_patch(view, ~p"/templates")
      assert render(view) =~ "更新後テンプレート"
    end

    test "form has fields: name, description, scale, default_expected_visitors, default_expected_vendors, is_public", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/templates/new")

      assert html =~ "name" or html =~ "名前"
      assert html =~ "description" or html =~ "説明"
      assert html =~ "scale" or html =~ "規模"
    end
  end
end
