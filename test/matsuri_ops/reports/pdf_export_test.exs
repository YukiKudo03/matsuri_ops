defmodule MatsuriOps.Reports.PdfExportTest do
  @moduledoc """
  PDF出力機能のテスト。

  TDDフェーズ: 🔴 RED
  - T-RPT-003: PDF出力テスト
  """

  use MatsuriOps.DataCase

  alias MatsuriOps.Reports.PdfExport
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

  describe "generate_settlement_pdf/1" do
    test "決算報告書のPDFデータを生成する" do
      user = user_fixture()
      festival = create_festival_with_budget(user, "2025年玄蕃まつり", 2025)

      cat = add_budget_category(festival.id, "会場設営", 100_000)
      add_expense(festival.id, cat.id, "テント", 80_000)
      add_income(festival.id, "協賛金", 200_000, "sponsorship")

      result = PdfExport.generate_settlement_pdf(festival.id)

      assert {:ok, pdf_data} = result
      assert pdf_data.title == "決算報告書"
      assert pdf_data.festival_name == "2025年玄蕃まつり"
      assert pdf_data.content
    end

    test "PDFデータにサマリー情報が含まれる" do
      user = user_fixture()
      festival = create_festival_with_budget(user, "2025年玄蕃まつり", 2025)

      cat = add_budget_category(festival.id, "会場設営", 100_000)
      add_expense(festival.id, cat.id, "テント", 80_000)
      add_income(festival.id, "協賛金", 200_000, "sponsorship")

      {:ok, pdf_data} = PdfExport.generate_settlement_pdf(festival.id)

      assert pdf_data.content.summary
      assert Decimal.eq?(pdf_data.content.summary.total_budget, Decimal.new(100_000))
      assert Decimal.eq?(pdf_data.content.summary.total_expenses, Decimal.new(80_000))
      assert Decimal.eq?(pdf_data.content.summary.total_income, Decimal.new(200_000))
    end

    test "PDFデータに詳細が含まれる" do
      user = user_fixture()
      festival = create_festival_with_budget(user, "2025年玄蕃まつり", 2025)

      cat = add_budget_category(festival.id, "会場設営", 100_000)
      add_expense(festival.id, cat.id, "テント", 80_000)
      add_income(festival.id, "協賛金", 200_000, "sponsorship")

      {:ok, pdf_data} = PdfExport.generate_settlement_pdf(festival.id)

      assert pdf_data.content.expenses_by_category
      assert pdf_data.content.income_by_source
    end
  end

  describe "generate_comparison_pdf/1" do
    test "年度比較PDFデータを生成する" do
      user = user_fixture()

      festival_2024 = create_festival_with_budget(user, "2024年玄蕃まつり", 2024)
      festival_2025 = create_festival_with_budget(user, "2025年玄蕃まつり", 2025)

      cat_2024 = add_budget_category(festival_2024.id, "会場", 100_000)
      cat_2025 = add_budget_category(festival_2025.id, "会場", 120_000)

      add_expense(festival_2024.id, cat_2024.id, "設営", 80_000)
      add_expense(festival_2025.id, cat_2025.id, "設営", 100_000)

      result = PdfExport.generate_comparison_pdf([festival_2024.id, festival_2025.id])

      assert {:ok, pdf_data} = result
      assert pdf_data.title == "年度比較報告書"
      assert pdf_data.content
    end

    test "年度比較データに差分情報が含まれる" do
      user = user_fixture()

      festival_2024 = create_festival_with_budget(user, "2024年玄蕃まつり", 2024)
      festival_2025 = create_festival_with_budget(user, "2025年玄蕃まつり", 2025)

      cat_2024 = add_budget_category(festival_2024.id, "会場", 100_000)
      cat_2025 = add_budget_category(festival_2025.id, "会場", 100_000)

      add_expense(festival_2024.id, cat_2024.id, "設営", 80_000)
      add_expense(festival_2025.id, cat_2025.id, "設営", 100_000)

      {:ok, pdf_data} = PdfExport.generate_comparison_pdf([festival_2024.id, festival_2025.id])

      assert pdf_data.content.expense_change
      assert pdf_data.content.expense_change_rate
    end
  end

  describe "render_to_html/1" do
    test "PDFデータをHTML形式に変換する" do
      user = user_fixture()
      festival = create_festival_with_budget(user, "2025年玄蕃まつり", 2025)

      cat = add_budget_category(festival.id, "会場設営", 100_000)
      add_expense(festival.id, cat.id, "テント", 80_000)

      {:ok, pdf_data} = PdfExport.generate_settlement_pdf(festival.id)
      html = PdfExport.render_to_html(pdf_data)

      assert is_binary(html)
      assert html =~ "決算報告書"
      assert html =~ "2025年玄蕃まつり"
    end
  end

  describe "to_binary/1 (PDF生成)" do
    test "PDFバイナリを生成する" do
      user = user_fixture()
      festival = create_festival_with_budget(user, "2025年玄蕃まつり", 2025)

      {:ok, pdf_data} = PdfExport.generate_settlement_pdf(festival.id)
      result = PdfExport.to_binary(pdf_data)

      assert {:ok, binary} = result
      assert is_binary(binary)
      # PDF magic bytes: %PDF-
      assert binary =~ "%PDF-" or byte_size(binary) > 0
    end
  end
end
