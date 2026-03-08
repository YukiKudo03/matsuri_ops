defmodule MatsuriOpsWeb.BudgetLive.IndexTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.BudgetsFixtures

  describe "Index page" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "renders budget page", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/budgets")

      assert html =~ "予算・経費管理"
      assert html =~ festival.name
    end

    test "redirects if user is not logged in", %{festival: festival} do
      conn = build_conn()
      assert {:error, redirect} = live(conn, ~p"/festivals/#{festival}/budgets")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays budget summary with zeros for empty budget", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/budgets")

      assert html =~ "総予算"
      assert html =~ "支出済み"
      assert html =~ "残り予算"
    end

    test "displays budget summary with actual values", %{conn: conn, festival: festival} do
      _category = budget_category_fixture(festival, %{
        name: "設備費",
        budget_amount: Decimal.new("100000")
      })
      _expense = expense_fixture(festival, %{
        title: "テスト経費",
        amount: Decimal.new("30000"),
        status: "approved"
      })

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/budgets")

      assert html =~ "100,000"
      assert html =~ "30,000"
    end

    test "displays empty message when no categories", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/budgets")

      assert html =~ "予算カテゴリがありません"
    end

    test "displays budget categories", %{conn: conn, festival: festival} do
      _category = budget_category_fixture(festival, %{
        name: "テストカテゴリ",
        budget_amount: Decimal.new("50000")
      })

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/budgets")

      assert html =~ "テストカテゴリ"
      assert html =~ "50,000"
    end

    test "displays navigation buttons", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/budgets")

      assert html =~ "カテゴリ追加"
      assert html =~ "経費登録"
      assert html =~ "祭り詳細へ"
    end

    test "displays expense list", %{conn: conn, festival: festival} do
      _expense = expense_fixture(festival, %{
        title: "経費テスト項目",
        amount: Decimal.new("15000"),
        status: "pending"
      })

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/budgets")

      assert html =~ "経費テスト項目"
      assert html =~ "15,000"
      assert html =~ "申請中"
    end

    test "displays expense status badges correctly", %{conn: conn, festival: festival} do
      _pending = expense_fixture(festival, %{title: "申請中経費", status: "pending"})
      _approved = expense_fixture(festival, %{title: "承認済経費", status: "approved"})
      _paid = expense_fixture(festival, %{title: "支払済経費", status: "paid"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/budgets")

      assert html =~ "申請中"
      assert html =~ "承認済"
      assert html =~ "支払済"
    end

    test "can delete expense", %{conn: conn, festival: festival} do
      expense = expense_fixture(festival, %{title: "削除対象経費"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets")

      # 経費が存在することを確認
      assert has_element?(view, "#expenses-#{expense.id}")

      # 削除イベントを発火
      view
      |> render_click("delete_expense", %{"id" => to_string(expense.id)})

      refute has_element?(view, "#expenses-#{expense.id}")
    end

    test "can approve pending expense", %{conn: conn, festival: festival} do
      expense = expense_fixture(festival, %{title: "承認対象経費", status: "pending"})

      {:ok, view, html} = live(conn, ~p"/festivals/#{festival}/budgets")

      assert html =~ "承認"

      # 承認イベントを発火
      view
      |> render_click("approve_expense", %{"id" => to_string(expense.id)})

      html = render(view)
      assert html =~ "承認済"
    end

    test "approve button not shown for non-pending expenses", %{conn: conn, festival: festival} do
      _expense = expense_fixture(festival, %{title: "承認済経費", status: "approved"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/budgets")

      refute html =~ "phx-click=\"approve_expense\""
    end
  end

  describe "New expense modal" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "opens new expense modal", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets")

      view
      |> element("a", "経費登録")
      |> render_click()

      assert_patch(view, ~p"/festivals/#{festival}/budgets/expenses/new")
      assert has_element?(view, "#expense-form")
    end

    test "displays expense form fields", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/budgets/expenses/new")

      assert html =~ "項目名"
      assert html =~ "説明"
      assert html =~ "カテゴリ"
      assert html =~ "金額"
      assert html =~ "支出日"
      assert html =~ "支払方法"
    end

    test "validates expense form", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets/expenses/new")

      result =
        view
        |> form("#expense-form", expense: %{title: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "saves new expense", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets/expenses/new")

      view
      |> form("#expense-form", expense: %{
        title: "新規経費",
        amount: "25000",
        expense_date: Date.utc_today()
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/budgets")
      assert render(view) =~ "新規経費"
    end

    test "displays category options in expense form", %{conn: conn, festival: festival} do
      _category = budget_category_fixture(festival, %{name: "選択可能カテゴリ"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/budgets/expenses/new")

      assert html =~ "選択可能カテゴリ"
      assert html =~ "未分類"
    end
  end

  describe "Edit expense modal" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      expense = expense_fixture(festival, %{title: "編集対象経費", amount: Decimal.new("10000")})
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, expense: expense}
    end

    test "opens edit expense modal", %{conn: conn, festival: festival, expense: expense} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/budgets/expenses/#{expense}/edit")

      assert html =~ "経費編集"
      assert html =~ "編集対象経費"
    end

    test "updates expense", %{conn: conn, festival: festival, expense: expense} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets/expenses/#{expense}/edit")

      view
      |> form("#expense-form", expense: %{title: "更新済み経費"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/budgets")
      assert render(view) =~ "更新済み経費"
    end
  end

  describe "New category modal" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "opens new category modal", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets")

      view
      |> element("a", "カテゴリ追加")
      |> render_click()

      assert_patch(view, ~p"/festivals/#{festival}/budgets/categories/new")
      assert has_element?(view, "#category-form")
    end

    test "displays category form fields", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/budgets/categories/new")

      assert html =~ "カテゴリ名"
      assert html =~ "説明"
      assert html =~ "予算額"
      assert html =~ "表示順"
    end

    test "saves new category", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets/categories/new")

      view
      |> form("#category-form", budget_category: %{
        name: "新規カテゴリ",
        budget_amount: "200000",
        sort_order: 1
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/budgets")
      assert render(view) =~ "新規カテゴリ"
    end
  end

  describe "Edit category modal" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      category = budget_category_fixture(festival, %{
        name: "編集対象カテゴリ",
        budget_amount: Decimal.new("150000")
      })
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, category: category}
    end

    test "opens edit category modal", %{conn: conn, festival: festival, category: category} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/budgets/categories/#{category}/edit")

      assert html =~ "予算カテゴリ編集"
      assert html =~ "編集対象カテゴリ"
    end

    test "updates category", %{conn: conn, festival: festival, category: category} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets/categories/#{category}/edit")

      view
      |> form("#category-form", budget_category: %{name: "更新済みカテゴリ"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/budgets")
      assert render(view) =~ "更新済みカテゴリ"
    end
  end
end
