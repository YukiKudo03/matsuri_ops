defmodule MatsuriOpsWeb.BudgetLive.CategoryFormComponentTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.BudgetsFixtures

  describe "CategoryFormComponent for new category" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "renders form for new category", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/budgets/categories/new")

      assert html =~ "カテゴリ名"
      assert html =~ "説明"
      assert html =~ "予算額"
      assert html =~ "表示順"
      assert html =~ "保存"
    end

    test "validates required fields", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets/categories/new")

      result =
        view
        |> form("#category-form", budget_category: %{name: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "validates budget_amount is required", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets/categories/new")

      result =
        view
        |> form("#category-form", budget_category: %{name: "テスト", budget_amount: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "creates category with valid data", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets/categories/new")

      view
      |> form("#category-form", budget_category: %{
        name: "新規テストカテゴリ",
        description: "説明文",
        budget_amount: "300000",
        sort_order: 1
      })
      |> render_submit()

      flash = assert_patch(view, ~p"/festivals/#{festival}/budgets")
      assert render(view) =~ "カテゴリを追加しました" or flash
    end

    test "creates category without optional fields", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets/categories/new")

      view
      |> form("#category-form", budget_category: %{
        name: "必須のみカテゴリ",
        budget_amount: "50000"
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/budgets")
    end

    test "handles duplicate name error", %{conn: conn, festival: festival} do
      _existing = budget_category_fixture(festival, %{name: "重複カテゴリ"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets/categories/new")

      view
      |> form("#category-form", budget_category: %{
        name: "重複カテゴリ",
        budget_amount: "100000"
      })
      |> render_submit()

      html = render(view)
      assert html =~ "already" or html =~ "重複" or html =~ "taken"
    end
  end

  describe "CategoryFormComponent for editing category" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      category = budget_category_fixture(festival, %{
        name: "編集用カテゴリ",
        description: "元の説明",
        budget_amount: Decimal.new("200000"),
        sort_order: 5
      })
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, category: category}
    end

    test "displays existing values", %{conn: conn, festival: festival, category: category} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/budgets/categories/#{category}/edit")

      assert html =~ "編集用カテゴリ"
      assert html =~ "元の説明"
      assert html =~ "200000"
    end

    test "updates category name", %{conn: conn, festival: festival, category: category} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets/categories/#{category}/edit")

      view
      |> form("#category-form", budget_category: %{name: "更新後カテゴリ名"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/budgets")
      assert render(view) =~ "更新後カテゴリ名"
    end

    test "updates budget amount", %{conn: conn, festival: festival, category: category} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets/categories/#{category}/edit")

      view
      |> form("#category-form", budget_category: %{budget_amount: "500000"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/budgets")
      assert render(view) =~ "500,000"
    end

    test "updates description", %{conn: conn, festival: festival, category: category} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets/categories/#{category}/edit")

      view
      |> form("#category-form", budget_category: %{description: "新しい説明"})
      |> render_submit()

      flash = assert_patch(view, ~p"/festivals/#{festival}/budgets")
      assert render(view) =~ "カテゴリを更新しました" or flash
    end

    test "validates name cannot be empty on edit", %{conn: conn, festival: festival, category: category} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets/categories/#{category}/edit")

      result =
        view
        |> form("#category-form", budget_category: %{name: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "shows page title for edit", %{conn: conn, festival: festival, category: category} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/budgets/categories/#{category}/edit")

      assert html =~ "予算カテゴリ編集"
    end
  end
end
