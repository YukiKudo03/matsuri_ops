defmodule MatsuriOps.BudgetsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MatsuriOps.Budgets` context.
  """

  alias MatsuriOps.Budgets

  def valid_budget_category_attributes(festival, attrs \\ %{}) do
    Enum.into(attrs, %{
      name: "予算カテゴリ#{System.unique_integer()}",
      festival_id: festival.id,
      budget_amount: Decimal.new("100000"),
      sort_order: 0
    })
  end

  def budget_category_fixture(festival, attrs \\ %{}) do
    attrs = valid_budget_category_attributes(festival, attrs)

    {:ok, category} = Budgets.create_budget_category(attrs)
    category
  end

  def valid_expense_attributes(festival, attrs \\ %{}) do
    Enum.into(attrs, %{
      title: "経費#{System.unique_integer()}",
      description: "テスト経費の説明",
      festival_id: festival.id,
      amount: Decimal.new("5000"),
      status: "pending",
      expense_date: Date.utc_today()
    })
  end

  def expense_fixture(festival, attrs \\ %{}) do
    attrs = valid_expense_attributes(festival, attrs)

    {:ok, expense} = Budgets.create_expense(attrs)
    expense
  end

  def valid_income_attributes(festival, attrs \\ %{}) do
    Enum.into(attrs, %{
      title: "収入#{System.unique_integer()}",
      description: "テスト収入の説明",
      festival_id: festival.id,
      amount: Decimal.new("50000"),
      status: "expected",
      received_date: Date.utc_today()
    })
  end

  def income_fixture(festival, attrs \\ %{}) do
    attrs = valid_income_attributes(festival, attrs)

    {:ok, income} = Budgets.create_income(attrs)
    income
  end
end
