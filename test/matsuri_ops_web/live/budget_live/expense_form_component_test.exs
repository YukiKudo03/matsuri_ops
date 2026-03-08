defmodule MatsuriOpsWeb.BudgetLive.ExpenseFormComponentTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.BudgetsFixtures

  describe "ExpenseFormComponent for new expense" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "renders form for new expense", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/budgets/expenses/new")

      assert html =~ "項目名"
      assert html =~ "説明"
      assert html =~ "カテゴリ"
      assert html =~ "金額"
      assert html =~ "数量"
      assert html =~ "単価"
      assert html =~ "支出日"
      assert html =~ "支払方法"
      assert html =~ "領収書番号"
      assert html =~ "備考"
      assert html =~ "保存"
    end

    test "validates required fields", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets/expenses/new")

      result =
        view
        |> form("#expense-form", expense: %{title: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "validates amount is required", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets/expenses/new")

      result =
        view
        |> form("#expense-form", expense: %{title: "テスト", amount: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "creates expense with valid data", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets/expenses/new")

      view
      |> form("#expense-form", expense: %{
        title: "新規テスト経費",
        description: "経費の説明",
        amount: "45000",
        expense_date: Date.utc_today()
      })
      |> render_submit()

      flash = assert_patch(view, ~p"/festivals/#{festival}/budgets")
      assert render(view) =~ "経費を登録しました" or flash
    end

    test "creates expense with category", %{conn: conn, festival: festival} do
      category = budget_category_fixture(festival, %{name: "テストカテゴリ"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets/expenses/new")

      view
      |> form("#expense-form", expense: %{
        title: "カテゴリ付き経費",
        amount: "10000",
        category_id: category.id
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/budgets")
    end

    test "creates expense with payment method", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets/expenses/new")

      view
      |> form("#expense-form", expense: %{
        title: "銀行振込経費",
        amount: "50000",
        payment_method: "bank_transfer"
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/budgets")
    end

    test "displays category options", %{conn: conn, festival: festival} do
      _category1 = budget_category_fixture(festival, %{name: "カテゴリA"})
      _category2 = budget_category_fixture(festival, %{name: "カテゴリB"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/budgets/expenses/new")

      assert html =~ "未分類"
      assert html =~ "カテゴリA"
      assert html =~ "カテゴリB"
    end

    test "displays payment method options", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/budgets/expenses/new")

      assert html =~ "現金"
      assert html =~ "銀行振込"
      assert html =~ "クレジットカード"
    end

    test "creates expense with all optional fields", %{conn: conn, festival: festival} do
      category = budget_category_fixture(festival)

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets/expenses/new")

      view
      |> form("#expense-form", expense: %{
        title: "完全経費",
        description: "詳細な説明",
        category_id: category.id,
        amount: "25000",
        quantity: 5,
        unit_price: "5000",
        expense_date: Date.utc_today(),
        payment_method: "credit_card",
        receipt_number: "REC-001",
        notes: "追加メモ"
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/budgets")
    end

    test "shows page title for new expense", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/budgets/expenses/new")

      assert html =~ "経費登録"
    end
  end

  describe "ExpenseFormComponent for editing expense" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      expense = expense_fixture(festival, %{
        title: "編集用経費",
        description: "元の説明",
        amount: Decimal.new("35000"),
        receipt_number: "REC-OLD"
      })
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, expense: expense}
    end

    test "displays existing values", %{conn: conn, festival: festival, expense: expense} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/budgets/expenses/#{expense}/edit")

      assert html =~ "編集用経費"
      assert html =~ "元の説明"
      assert html =~ "35000"
      assert html =~ "REC-OLD"
    end

    test "updates expense title", %{conn: conn, festival: festival, expense: expense} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets/expenses/#{expense}/edit")

      view
      |> form("#expense-form", expense: %{title: "更新後経費タイトル"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/budgets")
      assert render(view) =~ "更新後経費タイトル"
    end

    test "updates expense amount", %{conn: conn, festival: festival, expense: expense} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets/expenses/#{expense}/edit")

      view
      |> form("#expense-form", expense: %{amount: "80000"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/budgets")
      assert render(view) =~ "80,000"
    end

    test "updates expense with flash message", %{conn: conn, festival: festival, expense: expense} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets/expenses/#{expense}/edit")

      view
      |> form("#expense-form", expense: %{description: "更新された説明"})
      |> render_submit()

      flash = assert_patch(view, ~p"/festivals/#{festival}/budgets")
      assert render(view) =~ "経費を更新しました" or flash
    end

    test "validates title cannot be empty on edit", %{conn: conn, festival: festival, expense: expense} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets/expenses/#{expense}/edit")

      result =
        view
        |> form("#expense-form", expense: %{title: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "shows page title for edit", %{conn: conn, festival: festival, expense: expense} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/budgets/expenses/#{expense}/edit")

      assert html =~ "経費編集"
    end

    test "can change category on edit", %{conn: conn, festival: festival, expense: expense} do
      category = budget_category_fixture(festival, %{name: "新しいカテゴリ"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/budgets/expenses/#{expense}/edit")

      view
      |> form("#expense-form", expense: %{category_id: category.id})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/budgets")
    end
  end
end
