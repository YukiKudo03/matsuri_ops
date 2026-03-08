defmodule MatsuriOps.Reports do
  @moduledoc """
  決算報告・年度比較機能を提供するコンテキスト。

  祭りの決算サマリー、年度間比較、レポートデータ生成を行う。
  """

  import Ecto.Query
  alias MatsuriOps.Repo
  alias MatsuriOps.Festivals.Festival
  alias MatsuriOps.Budgets.{BudgetCategory, Expense, Income}

  @doc """
  祭りの決算サマリーを取得する。

  ## 返り値
  - total_budget: 総予算
  - total_expenses: 総支出（paid/approved のみ）
  - total_income: 総収入（received のみ）
  - balance: 収支（収入 - 支出）
  - expenses_by_category: カテゴリ別支出
  - income_by_source: 収入源別内訳
  """
  def settlement_report(festival_id) do
    total_budget = calculate_total_budget(festival_id)
    total_expenses = calculate_total_expenses(festival_id)
    total_income = calculate_total_income(festival_id)
    balance = Decimal.sub(total_income, total_expenses)

    expenses_by_category = get_expenses_by_category(festival_id)
    income_by_source = get_income_by_source(festival_id)

    %{
      festival_id: festival_id,
      total_budget: total_budget,
      total_expenses: total_expenses,
      total_income: total_income,
      balance: balance,
      expenses_by_category: expenses_by_category,
      income_by_source: income_by_source
    }
  end

  @doc """
  複数の祭りを比較する。

  年度順（start_dateの昇順）でソートし、最後の2つの祭りを比較対象とする。
  単一の祭りの場合は比較データはnilになる。
  """
  def compare_festivals(festival_ids) when is_list(festival_ids) do
    festivals =
      Festival
      |> where([f], f.id in ^festival_ids)
      |> order_by([f], asc: f.start_date)
      |> Repo.all()

    festival_data =
      Enum.map(festivals, fn festival ->
        report = settlement_report(festival.id)

        %{
          id: festival.id,
          name: festival.name,
          start_date: festival.start_date,
          total_expenses: report.total_expenses,
          total_income: report.total_income,
          expenses_by_category: report.expenses_by_category
        }
      end)

    case length(festival_data) do
      1 ->
        %{
          festivals: festival_data,
          expense_change: nil,
          expense_change_rate: nil,
          income_change: nil,
          income_change_rate: nil,
          category_comparison: nil
        }

      _ ->
        [previous | rest] = festival_data
        current = List.last(rest) || previous

        expense_change = Decimal.sub(current.total_expenses, previous.total_expenses)

        expense_change_rate =
          calculate_change_rate(previous.total_expenses, current.total_expenses)

        income_change = Decimal.sub(current.total_income, previous.total_income)
        income_change_rate = calculate_change_rate(previous.total_income, current.total_income)

        category_comparison = build_category_comparison(previous, current)

        %{
          festivals: festival_data,
          expense_change: expense_change,
          expense_change_rate: expense_change_rate,
          income_change: income_change,
          income_change_rate: income_change_rate,
          category_comparison: category_comparison
        }
    end
  end

  @doc """
  レポートデータを構造化して返す。
  """
  def generate_report_data(festival_id, report_type) do
    festival = Repo.get!(Festival, festival_id)
    report = settlement_report(festival_id)

    %{
      festival_id: festival_id,
      festival_name: festival.name,
      report_type: report_type,
      generated_at: DateTime.utc_now(),
      summary: %{
        total_budget: report.total_budget,
        total_expenses: report.total_expenses,
        total_income: report.total_income,
        balance: report.balance
      },
      details: %{
        expenses_by_category: report.expenses_by_category,
        income_by_source: report.income_by_source
      }
    }
  end

  # Private functions

  defp calculate_total_budget(festival_id) do
    BudgetCategory
    |> where([c], c.festival_id == ^festival_id)
    |> select([c], coalesce(sum(c.budget_amount), 0))
    |> Repo.one()
    |> Decimal.new()
  end

  defp calculate_total_expenses(festival_id) do
    Expense
    |> where([e], e.festival_id == ^festival_id)
    |> where([e], e.status in ["paid", "approved"])
    |> select([e], coalesce(sum(e.amount), 0))
    |> Repo.one()
    |> Decimal.new()
  end

  defp calculate_total_income(festival_id) do
    Income
    |> where([i], i.festival_id == ^festival_id)
    |> where([i], i.status == "received")
    |> select([i], coalesce(sum(i.amount), 0))
    |> Repo.one()
    |> Decimal.new()
  end

  defp get_expenses_by_category(festival_id) do
    categories =
      BudgetCategory
      |> where([c], c.festival_id == ^festival_id)
      |> Repo.all()

    Enum.map(categories, fn category ->
      total =
        Expense
        |> where([e], e.category_id == ^category.id)
        |> where([e], e.status in ["paid", "approved"])
        |> select([e], coalesce(sum(e.amount), 0))
        |> Repo.one()
        |> Decimal.new()

      execution_rate =
        if Decimal.gt?(category.budget_amount, Decimal.new(0)) do
          Decimal.div(total, category.budget_amount)
          |> Decimal.mult(Decimal.new(100))
          |> Decimal.round(1)
          |> Decimal.to_float()
        else
          0.0
        end

      %{
        id: category.id,
        name: category.name,
        budget: category.budget_amount,
        total: total,
        execution_rate: execution_rate
      }
    end)
  end

  defp get_income_by_source(festival_id) do
    Income
    |> where([i], i.festival_id == ^festival_id)
    |> where([i], i.status == "received")
    |> group_by([i], i.source_type)
    |> select([i], %{source_type: i.source_type, total: sum(i.amount)})
    |> Repo.all()
  end

  defp calculate_change_rate(previous, current) do
    if Decimal.gt?(previous, Decimal.new(0)) do
      change = Decimal.sub(current, previous)

      Decimal.div(change, previous)
      |> Decimal.mult(Decimal.new(100))
      |> Decimal.round(1)
      |> Decimal.to_float()
    else
      0.0
    end
  end

  defp build_category_comparison(previous, current) do
    previous_categories = Map.new(previous.expenses_by_category, &{&1.name, &1.total})
    current_categories = Map.new(current.expenses_by_category, &{&1.name, &1.total})

    all_names =
      MapSet.union(
        MapSet.new(Map.keys(previous_categories)),
        MapSet.new(Map.keys(current_categories))
      )

    Enum.map(all_names, fn name ->
      prev_total = Map.get(previous_categories, name, Decimal.new(0))
      curr_total = Map.get(current_categories, name, Decimal.new(0))
      change_rate = calculate_change_rate(prev_total, curr_total)

      %{
        name: name,
        previous: prev_total,
        current: curr_total,
        change_rate: change_rate
      }
    end)
  end
end
