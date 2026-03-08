defmodule MatsuriOps.Budgets do
  @moduledoc """
  The Budgets context.
  """

  import Ecto.Query, warn: false
  alias MatsuriOps.Repo
  alias MatsuriOps.Budgets.{BudgetCategory, Expense, Income}

  ## Budget Categories

  def list_budget_categories(festival_id) do
    BudgetCategory
    |> where([bc], bc.festival_id == ^festival_id)
    |> order_by([bc], asc: bc.sort_order)
    |> Repo.all()
  end

  def get_budget_category!(id), do: Repo.get!(BudgetCategory, id)

  def create_budget_category(attrs \\ %{}) do
    %BudgetCategory{}
    |> BudgetCategory.changeset(attrs)
    |> Repo.insert()
  end

  def update_budget_category(%BudgetCategory{} = budget_category, attrs) do
    budget_category
    |> BudgetCategory.changeset(attrs)
    |> Repo.update()
  end

  def delete_budget_category(%BudgetCategory{} = budget_category) do
    Repo.delete(budget_category)
  end

  def change_budget_category(%BudgetCategory{} = budget_category, attrs \\ %{}) do
    BudgetCategory.changeset(budget_category, attrs)
  end

  ## Expenses

  def list_expenses(festival_id) do
    Expense
    |> where([e], e.festival_id == ^festival_id)
    |> order_by([e], desc: e.expense_date)
    |> preload([:category, :submitted_by])
    |> Repo.all()
  end

  def list_expenses_by_category(festival_id, category_id) do
    Expense
    |> where([e], e.festival_id == ^festival_id and e.category_id == ^category_id)
    |> order_by([e], desc: e.expense_date)
    |> Repo.all()
  end

  def list_expenses_by_status(festival_id, status) do
    Expense
    |> where([e], e.festival_id == ^festival_id and e.status == ^status)
    |> order_by([e], desc: e.expense_date)
    |> Repo.all()
  end

  def get_expense!(id), do: Repo.get!(Expense, id)

  def create_expense(attrs \\ %{}) do
    %Expense{}
    |> Expense.changeset(attrs)
    |> Repo.insert()
  end

  def update_expense(%Expense{} = expense, attrs) do
    expense
    |> Expense.changeset(attrs)
    |> Repo.update()
  end

  def approve_expense(%Expense{} = expense, user_id) do
    expense
    |> Expense.approval_changeset(%{status: "approved", approved_by_id: user_id})
    |> Repo.update()
  end

  def reject_expense(%Expense{} = expense, user_id) do
    expense
    |> Expense.approval_changeset(%{status: "rejected", approved_by_id: user_id})
    |> Repo.update()
  end

  def delete_expense(%Expense{} = expense) do
    Repo.delete(expense)
  end

  def change_expense(%Expense{} = expense, attrs \\ %{}) do
    Expense.changeset(expense, attrs)
  end

  def total_expenses(festival_id) do
    Expense
    |> where([e], e.festival_id == ^festival_id and e.status in ["approved", "paid"])
    |> select([e], sum(e.amount))
    |> Repo.one()
    |> Kernel.||(Decimal.new(0))
  end

  def total_expenses_by_category(festival_id) do
    Expense
    |> where([e], e.festival_id == ^festival_id and e.status in ["approved", "paid"])
    |> group_by([e], e.category_id)
    |> select([e], {e.category_id, sum(e.amount)})
    |> Repo.all()
    |> Map.new()
  end

  ## Incomes

  def list_incomes(festival_id) do
    Income
    |> where([i], i.festival_id == ^festival_id)
    |> order_by([i], desc: i.received_date)
    |> Repo.all()
  end

  def list_incomes_by_status(festival_id, status) do
    Income
    |> where([i], i.festival_id == ^festival_id and i.status == ^status)
    |> order_by([i], desc: i.received_date)
    |> Repo.all()
  end

  def get_income!(id), do: Repo.get!(Income, id)

  def create_income(attrs \\ %{}) do
    %Income{}
    |> Income.changeset(attrs)
    |> Repo.insert()
  end

  def update_income(%Income{} = income, attrs) do
    income
    |> Income.changeset(attrs)
    |> Repo.update()
  end

  def delete_income(%Income{} = income) do
    Repo.delete(income)
  end

  def change_income(%Income{} = income, attrs \\ %{}) do
    Income.changeset(income, attrs)
  end

  def total_income(festival_id) do
    Income
    |> where([i], i.festival_id == ^festival_id and i.status == "received")
    |> select([i], sum(i.amount))
    |> Repo.one()
    |> Kernel.||(Decimal.new(0))
  end

  ## Budget Summary

  def budget_summary(festival_id) do
    categories = list_budget_categories(festival_id)
    expenses_by_category = total_expenses_by_category(festival_id)

    total_budget =
      categories
      |> Enum.map(& &1.budget_amount)
      |> Enum.reduce(Decimal.new(0), &Decimal.add/2)

    total_spent = total_expenses(festival_id)
    total_received = total_income(festival_id)

    %{
      total_budget: total_budget,
      total_spent: total_spent,
      total_income: total_received,
      remaining_budget: Decimal.sub(total_budget, total_spent),
      categories:
        Enum.map(categories, fn cat ->
          spent = Map.get(expenses_by_category, cat.id, Decimal.new(0))

          %{
            id: cat.id,
            name: cat.name,
            budget: cat.budget_amount,
            spent: spent,
            remaining: Decimal.sub(cat.budget_amount, spent)
          }
        end)
    }
  end
end
