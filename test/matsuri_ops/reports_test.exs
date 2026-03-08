defmodule MatsuriOps.ReportsTest do
  @moduledoc """
  決算報告・年度比較機能のテスト。

  TDDフェーズ: 🔴 RED
  - T-RPT-001: 決算サマリー計算テスト
  - T-RPT-002: 年度比較ロジックテスト
  """

  use MatsuriOps.DataCase

  alias MatsuriOps.Reports
  alias MatsuriOps.Festivals
  alias MatsuriOps.Budgets

  import MatsuriOps.AccountsFixtures

  defp create_festival_with_budget(user, name, year) do
    {:ok, festival} =
      Festivals.create_festival(user, %{
        name: name,
        start_date: Date.new!(year, 8, 1),
        end_date: Date.new!(year, 8, 2),
        scale: "medium",
        status: "completed"
      })

    festival
  end

  defp add_budget_category(festival_id, name, budget_amount) do
    {:ok, category} =
      Budgets.create_budget_category(%{
        festival_id: festival_id,
        name: name,
        budget_amount: Decimal.new(budget_amount)
      })

    category
  end

  defp add_expense(festival_id, category_id, title, amount, status \\ "paid") do
    {:ok, expense} =
      Budgets.create_expense(%{
        festival_id: festival_id,
        category_id: category_id,
        title: title,
        amount: Decimal.new(amount),
        status: status,
        expense_date: Date.utc_today()
      })

    expense
  end

  defp add_income(festival_id, title, amount, source_type, status \\ "received") do
    {:ok, income} =
      Budgets.create_income(%{
        festival_id: festival_id,
        title: title,
        amount: Decimal.new(amount),
        source_type: source_type,
        status: status,
        received_date: Date.utc_today()
      })

    income
  end

  describe "settlement_report/1 (決算報告)" do
    test "祭りの決算サマリーを取得できる" do
      user = user_fixture()
      festival = create_festival_with_budget(user, "2025年玄蕃まつり", 2025)

      # 予算カテゴリ設定
      cat1 = add_budget_category(festival.id, "会場設営", 100_000)
      cat2 = add_budget_category(festival.id, "広報", 50_000)

      # 経費登録
      add_expense(festival.id, cat1.id, "テント設営", 80_000)
      add_expense(festival.id, cat2.id, "チラシ印刷", 30_000)

      # 収入登録
      add_income(festival.id, "協賛金A社", 200_000, "sponsorship")
      add_income(festival.id, "出店料", 100_000, "vendor_fees")

      report = Reports.settlement_report(festival.id)

      assert Decimal.eq?(report.total_budget, Decimal.new(150_000))
      assert Decimal.eq?(report.total_expenses, Decimal.new(110_000))
      assert Decimal.eq?(report.total_income, Decimal.new(300_000))
      assert Decimal.eq?(report.balance, Decimal.new(190_000))
    end

    test "カテゴリ別の支出内訳を含む" do
      user = user_fixture()
      festival = create_festival_with_budget(user, "2025年玄蕃まつり", 2025)

      cat1 = add_budget_category(festival.id, "会場設営", 100_000)
      cat2 = add_budget_category(festival.id, "広報", 50_000)

      add_expense(festival.id, cat1.id, "テント", 50_000)
      add_expense(festival.id, cat1.id, "照明", 30_000)
      add_expense(festival.id, cat2.id, "チラシ", 20_000)

      report = Reports.settlement_report(festival.id)

      assert length(report.expenses_by_category) == 2

      venue_cat = Enum.find(report.expenses_by_category, &(&1.name == "会場設営"))
      assert Decimal.eq?(venue_cat.total, Decimal.new(80_000))
      assert Decimal.eq?(venue_cat.budget, Decimal.new(100_000))
      assert venue_cat.execution_rate == 80.0
    end

    test "収入源別の内訳を含む" do
      user = user_fixture()
      festival = create_festival_with_budget(user, "2025年玄蕃まつり", 2025)

      add_income(festival.id, "A社協賛", 100_000, "sponsorship")
      add_income(festival.id, "B社協賛", 50_000, "sponsorship")
      add_income(festival.id, "出店料", 80_000, "vendor_fees")
      add_income(festival.id, "市補助金", 200_000, "grant")

      report = Reports.settlement_report(festival.id)

      assert length(report.income_by_source) == 3

      sponsorship = Enum.find(report.income_by_source, &(&1.source_type == "sponsorship"))
      assert Decimal.eq?(sponsorship.total, Decimal.new(150_000))
    end

    test "未確定の収入・支出は含まない" do
      user = user_fixture()
      festival = create_festival_with_budget(user, "2025年玄蕃まつり", 2025)

      cat = add_budget_category(festival.id, "会場設営", 100_000)

      # 支払済み
      add_expense(festival.id, cat.id, "支払済み経費", 50_000, "paid")
      # 承認済み
      add_expense(festival.id, cat.id, "承認済み経費", 30_000, "approved")
      # 保留中（含まない）
      add_expense(festival.id, cat.id, "保留中経費", 20_000, "pending")

      # 入金済み
      add_income(festival.id, "入金済み", 100_000, "sponsorship", "received")
      # 予定（含まない）
      add_income(festival.id, "予定", 50_000, "sponsorship", "expected")

      report = Reports.settlement_report(festival.id)

      assert Decimal.eq?(report.total_expenses, Decimal.new(80_000))
      assert Decimal.eq?(report.total_income, Decimal.new(100_000))
    end

    test "支出がない場合はゼロを返す" do
      user = user_fixture()
      festival = create_festival_with_budget(user, "2025年玄蕃まつり", 2025)

      report = Reports.settlement_report(festival.id)

      assert Decimal.eq?(report.total_expenses, Decimal.new(0))
      assert Decimal.eq?(report.total_income, Decimal.new(0))
      assert Decimal.eq?(report.balance, Decimal.new(0))
    end
  end

  describe "compare_festivals/1 (年度比較)" do
    test "複数の祭りを比較できる" do
      user = user_fixture()

      festival_2024 = create_festival_with_budget(user, "2024年玄蕃まつり", 2024)
      festival_2025 = create_festival_with_budget(user, "2025年玄蕃まつり", 2025)

      cat_2024 = add_budget_category(festival_2024.id, "会場", 100_000)
      cat_2025 = add_budget_category(festival_2025.id, "会場", 120_000)

      add_expense(festival_2024.id, cat_2024.id, "設営", 80_000)
      add_expense(festival_2025.id, cat_2025.id, "設営", 100_000)

      add_income(festival_2024.id, "協賛金", 200_000, "sponsorship")
      add_income(festival_2025.id, "協賛金", 250_000, "sponsorship")

      comparison = Reports.compare_festivals([festival_2024.id, festival_2025.id])

      assert length(comparison.festivals) == 2
      assert comparison.festivals |> Enum.at(0) |> Map.get(:name) == "2024年玄蕃まつり"
      assert comparison.festivals |> Enum.at(1) |> Map.get(:name) == "2025年玄蕃まつり"
    end

    test "年度間の差分を計算する" do
      user = user_fixture()

      festival_2024 = create_festival_with_budget(user, "2024年玄蕃まつり", 2024)
      festival_2025 = create_festival_with_budget(user, "2025年玄蕃まつり", 2025)

      cat_2024 = add_budget_category(festival_2024.id, "会場", 100_000)
      cat_2025 = add_budget_category(festival_2025.id, "会場", 100_000)

      add_expense(festival_2024.id, cat_2024.id, "設営", 80_000)
      add_expense(festival_2025.id, cat_2025.id, "設営", 100_000)

      add_income(festival_2024.id, "協賛金", 200_000, "sponsorship")
      add_income(festival_2025.id, "協賛金", 250_000, "sponsorship")

      comparison = Reports.compare_festivals([festival_2024.id, festival_2025.id])

      # 支出変化: 100,000 - 80,000 = 20,000 (25% 増)
      assert Decimal.eq?(comparison.expense_change, Decimal.new(20_000))
      assert comparison.expense_change_rate == 25.0

      # 収入変化: 250,000 - 200,000 = 50,000 (25% 増)
      assert Decimal.eq?(comparison.income_change, Decimal.new(50_000))
      assert comparison.income_change_rate == 25.0
    end

    test "単一の祭りの場合は比較データなし" do
      user = user_fixture()
      festival = create_festival_with_budget(user, "2025年玄蕃まつり", 2025)

      cat = add_budget_category(festival.id, "会場", 100_000)
      add_expense(festival.id, cat.id, "設営", 80_000)

      comparison = Reports.compare_festivals([festival.id])

      assert length(comparison.festivals) == 1
      assert is_nil(comparison.expense_change)
      assert is_nil(comparison.income_change)
    end

    test "カテゴリ別の年度比較" do
      user = user_fixture()

      festival_2024 = create_festival_with_budget(user, "2024年玄蕃まつり", 2024)
      festival_2025 = create_festival_with_budget(user, "2025年玄蕃まつり", 2025)

      cat_venue_2024 = add_budget_category(festival_2024.id, "会場設営", 100_000)
      cat_pr_2024 = add_budget_category(festival_2024.id, "広報", 50_000)
      cat_venue_2025 = add_budget_category(festival_2025.id, "会場設営", 120_000)
      cat_pr_2025 = add_budget_category(festival_2025.id, "広報", 60_000)

      add_expense(festival_2024.id, cat_venue_2024.id, "テント", 80_000)
      add_expense(festival_2024.id, cat_pr_2024.id, "チラシ", 40_000)
      add_expense(festival_2025.id, cat_venue_2025.id, "テント", 100_000)
      add_expense(festival_2025.id, cat_pr_2025.id, "チラシ", 45_000)

      comparison = Reports.compare_festivals([festival_2024.id, festival_2025.id])

      venue_comparison = Enum.find(comparison.category_comparison, &(&1.name == "会場設営"))
      assert Decimal.eq?(venue_comparison.previous, Decimal.new(80_000))
      assert Decimal.eq?(venue_comparison.current, Decimal.new(100_000))
      assert venue_comparison.change_rate == 25.0
    end
  end

  describe "generate_report_data/2" do
    test "レポートデータを構造化して返す" do
      user = user_fixture()
      festival = create_festival_with_budget(user, "2025年玄蕃まつり", 2025)

      cat = add_budget_category(festival.id, "会場設営", 100_000)
      add_expense(festival.id, cat.id, "テント", 80_000)
      add_income(festival.id, "協賛金", 200_000, "sponsorship")

      report_data = Reports.generate_report_data(festival.id, :settlement)

      assert report_data.festival_name == "2025年玄蕃まつり"
      assert report_data.report_type == :settlement
      assert report_data.generated_at
      assert report_data.summary
      assert report_data.details
    end
  end
end
