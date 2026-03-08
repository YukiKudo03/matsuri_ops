defmodule MatsuriOps.BudgetsTest do
  use MatsuriOps.DataCase, async: true

  alias MatsuriOps.Budgets
  alias MatsuriOps.Budgets.{BudgetCategory, Expense, Income}

  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.BudgetsFixtures

  describe "budget_categories" do
    setup do
      user = user_fixture()
      festival = festival_fixture(user)
      %{user: user, festival: festival}
    end

    test "list_budget_categories/1 returns all categories for a festival", %{festival: festival} do
      category = budget_category_fixture(festival)
      assert Budgets.list_budget_categories(festival.id) == [category]
    end

    test "list_budget_categories/1 returns categories ordered by sort_order", %{
      festival: festival
    } do
      cat1 = budget_category_fixture(festival, %{sort_order: 2, name: "カテゴリ2"})
      cat2 = budget_category_fixture(festival, %{sort_order: 1, name: "カテゴリ1"})

      result = Budgets.list_budget_categories(festival.id)
      assert [first, second] = result
      assert first.id == cat2.id
      assert second.id == cat1.id
    end

    test "get_budget_category!/1 returns the category", %{festival: festival} do
      category = budget_category_fixture(festival)
      assert Budgets.get_budget_category!(category.id) == category
    end

    test "create_budget_category/1 with valid data creates a category", %{festival: festival} do
      attrs = %{
        name: "新規予算カテゴリ",
        festival_id: festival.id,
        budget_amount: Decimal.new("200000"),
        sort_order: 0
      }

      assert {:ok, %BudgetCategory{} = category} = Budgets.create_budget_category(attrs)
      assert category.name == "新規予算カテゴリ"
      assert Decimal.equal?(category.budget_amount, Decimal.new("200000"))
    end

    test "create_budget_category/1 with invalid data returns error", %{festival: festival} do
      attrs = %{name: nil, festival_id: festival.id}
      assert {:error, %Ecto.Changeset{}} = Budgets.create_budget_category(attrs)
    end

    test "update_budget_category/2 updates the category", %{festival: festival} do
      category = budget_category_fixture(festival)

      assert {:ok, %BudgetCategory{} = updated} =
               Budgets.update_budget_category(category, %{name: "更新されたカテゴリ"})

      assert updated.name == "更新されたカテゴリ"
    end

    test "delete_budget_category/1 deletes the category", %{festival: festival} do
      category = budget_category_fixture(festival)
      assert {:ok, %BudgetCategory{}} = Budgets.delete_budget_category(category)
      assert_raise Ecto.NoResultsError, fn -> Budgets.get_budget_category!(category.id) end
    end

    test "change_budget_category/1 returns a changeset", %{festival: festival} do
      category = budget_category_fixture(festival)
      assert %Ecto.Changeset{} = Budgets.change_budget_category(category)
    end
  end

  describe "expenses" do
    setup do
      user = user_fixture()
      festival = festival_fixture(user)
      category = budget_category_fixture(festival)
      %{user: user, festival: festival, category: category}
    end

    test "list_expenses/1 returns all expenses for a festival", %{festival: festival} do
      expense = expense_fixture(festival)
      expenses = Budgets.list_expenses(festival.id)
      assert length(expenses) == 1
      assert hd(expenses).id == expense.id
    end

    test "list_expenses_by_category/2 returns expenses for a specific category", %{
      festival: festival,
      category: category
    } do
      expense1 = expense_fixture(festival, %{category_id: category.id})
      _expense2 = expense_fixture(festival, %{category_id: nil})

      result = Budgets.list_expenses_by_category(festival.id, category.id)
      assert length(result) == 1
      assert hd(result).id == expense1.id
    end

    test "list_expenses_by_status/2 returns expenses with given status", %{festival: festival} do
      pending = expense_fixture(festival, %{status: "pending"})
      _approved = expense_fixture(festival, %{status: "approved"})

      result = Budgets.list_expenses_by_status(festival.id, "pending")
      assert length(result) == 1
      assert hd(result).id == pending.id
    end

    test "get_expense!/1 returns the expense", %{festival: festival} do
      expense = expense_fixture(festival)
      assert Budgets.get_expense!(expense.id).id == expense.id
    end

    test "create_expense/1 with valid data creates an expense", %{festival: festival} do
      attrs = %{
        title: "新規経費",
        festival_id: festival.id,
        amount: Decimal.new("10000"),
        status: "pending",
        expense_date: Date.utc_today()
      }

      assert {:ok, %Expense{} = expense} = Budgets.create_expense(attrs)
      assert expense.title == "新規経費"
      assert Decimal.equal?(expense.amount, Decimal.new("10000"))
    end

    test "create_expense/1 with invalid data returns error", %{festival: festival} do
      attrs = %{title: nil, festival_id: festival.id}
      assert {:error, %Ecto.Changeset{}} = Budgets.create_expense(attrs)
    end

    test "update_expense/2 updates the expense", %{festival: festival} do
      expense = expense_fixture(festival)

      assert {:ok, %Expense{} = updated} =
               Budgets.update_expense(expense, %{title: "更新された経費"})

      assert updated.title == "更新された経費"
    end

    test "approve_expense/2 approves the expense", %{festival: festival, user: user} do
      expense = expense_fixture(festival, %{status: "pending"})

      assert {:ok, %Expense{} = approved} = Budgets.approve_expense(expense, user.id)
      assert approved.status == "approved"
      assert approved.approved_by_id == user.id
    end

    test "reject_expense/2 rejects the expense", %{festival: festival, user: user} do
      expense = expense_fixture(festival, %{status: "pending"})

      assert {:ok, %Expense{} = rejected} = Budgets.reject_expense(expense, user.id)
      assert rejected.status == "rejected"
      assert rejected.approved_by_id == user.id
    end

    test "delete_expense/1 deletes the expense", %{festival: festival} do
      expense = expense_fixture(festival)
      assert {:ok, %Expense{}} = Budgets.delete_expense(expense)
      assert_raise Ecto.NoResultsError, fn -> Budgets.get_expense!(expense.id) end
    end

    test "change_expense/1 returns a changeset", %{festival: festival} do
      expense = expense_fixture(festival)
      assert %Ecto.Changeset{} = Budgets.change_expense(expense)
    end

    test "total_expenses/1 returns sum of approved and paid expenses", %{festival: festival} do
      _pending = expense_fixture(festival, %{status: "pending", amount: Decimal.new("1000")})
      _approved = expense_fixture(festival, %{status: "approved", amount: Decimal.new("2000")})
      _paid = expense_fixture(festival, %{status: "paid", amount: Decimal.new("3000")})

      result = Budgets.total_expenses(festival.id)
      assert Decimal.equal?(result, Decimal.new("5000"))
    end

    test "total_expenses/1 returns zero when no expenses", %{user: user} do
      other_festival = festival_fixture(user)
      result = Budgets.total_expenses(other_festival.id)
      assert Decimal.equal?(result, Decimal.new("0"))
    end

    test "total_expenses_by_category/1 returns expenses grouped by category", %{
      festival: festival,
      category: category
    } do
      _expense1 =
        expense_fixture(festival, %{
          category_id: category.id,
          status: "approved",
          amount: Decimal.new("1000")
        })

      _expense2 =
        expense_fixture(festival, %{
          category_id: category.id,
          status: "paid",
          amount: Decimal.new("2000")
        })

      result = Budgets.total_expenses_by_category(festival.id)
      assert Decimal.equal?(Map.get(result, category.id), Decimal.new("3000"))
    end
  end

  describe "incomes" do
    setup do
      user = user_fixture()
      festival = festival_fixture(user)
      %{user: user, festival: festival}
    end

    test "list_incomes/1 returns all incomes for a festival", %{festival: festival} do
      income = income_fixture(festival)
      incomes = Budgets.list_incomes(festival.id)
      assert length(incomes) == 1
      assert hd(incomes).id == income.id
    end

    test "list_incomes_by_status/2 returns incomes with given status", %{festival: festival} do
      expected = income_fixture(festival, %{status: "expected"})
      _received = income_fixture(festival, %{status: "received"})

      result = Budgets.list_incomes_by_status(festival.id, "expected")
      assert length(result) == 1
      assert hd(result).id == expected.id
    end

    test "get_income!/1 returns the income", %{festival: festival} do
      income = income_fixture(festival)
      assert Budgets.get_income!(income.id).id == income.id
    end

    test "create_income/1 with valid data creates an income", %{festival: festival} do
      attrs = %{
        title: "新規収入",
        festival_id: festival.id,
        amount: Decimal.new("100000"),
        status: "expected",
        received_date: Date.utc_today()
      }

      assert {:ok, %Income{} = income} = Budgets.create_income(attrs)
      assert income.title == "新規収入"
      assert Decimal.equal?(income.amount, Decimal.new("100000"))
    end

    test "create_income/1 with invalid data returns error", %{festival: festival} do
      attrs = %{title: nil, festival_id: festival.id}
      assert {:error, %Ecto.Changeset{}} = Budgets.create_income(attrs)
    end

    test "update_income/2 updates the income", %{festival: festival} do
      income = income_fixture(festival)

      assert {:ok, %Income{} = updated} = Budgets.update_income(income, %{title: "更新された収入"})
      assert updated.title == "更新された収入"
    end

    test "delete_income/1 deletes the income", %{festival: festival} do
      income = income_fixture(festival)
      assert {:ok, %Income{}} = Budgets.delete_income(income)
      assert_raise Ecto.NoResultsError, fn -> Budgets.get_income!(income.id) end
    end

    test "change_income/1 returns a changeset", %{festival: festival} do
      income = income_fixture(festival)
      assert %Ecto.Changeset{} = Budgets.change_income(income)
    end

    test "total_income/1 returns sum of received incomes only", %{festival: festival} do
      _expected = income_fixture(festival, %{status: "expected", amount: Decimal.new("10000")})
      _received = income_fixture(festival, %{status: "received", amount: Decimal.new("50000")})
      _confirmed = income_fixture(festival, %{status: "confirmed", amount: Decimal.new("20000")})

      result = Budgets.total_income(festival.id)
      assert Decimal.equal?(result, Decimal.new("50000"))
    end

    test "total_income/1 returns zero when no received income", %{user: user} do
      other_festival = festival_fixture(user)
      result = Budgets.total_income(other_festival.id)
      assert Decimal.equal?(result, Decimal.new("0"))
    end
  end

  describe "budget_summary" do
    setup do
      user = user_fixture()
      festival = festival_fixture(user)
      %{user: user, festival: festival}
    end

    test "budget_summary/1 returns comprehensive budget overview", %{festival: festival} do
      # Create budget categories
      cat1 =
        budget_category_fixture(festival, %{name: "設備", budget_amount: Decimal.new("100000")})

      cat2 =
        budget_category_fixture(festival, %{name: "人件費", budget_amount: Decimal.new("200000")})

      # Create expenses
      _expense1 =
        expense_fixture(festival, %{
          category_id: cat1.id,
          status: "approved",
          amount: Decimal.new("30000")
        })

      _expense2 =
        expense_fixture(festival, %{
          category_id: cat2.id,
          status: "paid",
          amount: Decimal.new("50000")
        })

      # Create income
      _income = income_fixture(festival, %{status: "received", amount: Decimal.new("150000")})

      result = Budgets.budget_summary(festival.id)

      assert Decimal.equal?(result.total_budget, Decimal.new("300000"))
      assert Decimal.equal?(result.total_spent, Decimal.new("80000"))
      assert Decimal.equal?(result.total_income, Decimal.new("150000"))
      assert Decimal.equal?(result.remaining_budget, Decimal.new("220000"))

      assert length(result.categories) == 2

      cat1_summary = Enum.find(result.categories, &(&1.id == cat1.id))
      assert cat1_summary.name == "設備"
      assert Decimal.equal?(cat1_summary.budget, Decimal.new("100000"))
      assert Decimal.equal?(cat1_summary.spent, Decimal.new("30000"))
      assert Decimal.equal?(cat1_summary.remaining, Decimal.new("70000"))
    end

    test "budget_summary/1 handles empty budget", %{user: user} do
      empty_festival = festival_fixture(user)

      result = Budgets.budget_summary(empty_festival.id)

      assert Decimal.equal?(result.total_budget, Decimal.new("0"))
      assert Decimal.equal?(result.total_spent, Decimal.new("0"))
      assert Decimal.equal?(result.total_income, Decimal.new("0"))
      assert Decimal.equal?(result.remaining_budget, Decimal.new("0"))
      assert result.categories == []
    end
  end
end
