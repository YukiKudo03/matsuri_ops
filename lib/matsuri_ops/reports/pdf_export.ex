defmodule MatsuriOps.Reports.PdfExport do
  @moduledoc """
  PDF出力機能を提供するモジュール。

  決算報告書や年度比較報告書のPDFデータ生成、HTML変換、PDFバイナリ生成を行う。
  """

  alias MatsuriOps.Reports
  alias MatsuriOps.Repo
  alias MatsuriOps.Festivals.Festival

  @doc """
  決算報告書のPDFデータを生成する。
  """
  def generate_settlement_pdf(festival_id) do
    festival = Repo.get!(Festival, festival_id)
    report = Reports.settlement_report(festival_id)

    pdf_data = %{
      type: :settlement,
      title: "決算報告書",
      festival_id: festival_id,
      festival_name: festival.name,
      generated_at: DateTime.utc_now(),
      content: %{
        summary: %{
          total_budget: report.total_budget,
          total_expenses: report.total_expenses,
          total_income: report.total_income,
          balance: report.balance
        },
        expenses_by_category: report.expenses_by_category,
        income_by_source: report.income_by_source
      }
    }

    {:ok, pdf_data}
  end

  @doc """
  年度比較報告書のPDFデータを生成する。
  """
  def generate_comparison_pdf(festival_ids) when is_list(festival_ids) do
    comparison = Reports.compare_festivals(festival_ids)

    festival_names =
      comparison.festivals
      |> Enum.map(& &1.name)
      |> Enum.join(" vs ")

    pdf_data = %{
      type: :comparison,
      title: "年度比較報告書",
      festival_ids: festival_ids,
      festival_names: festival_names,
      generated_at: DateTime.utc_now(),
      content: %{
        festivals: comparison.festivals,
        expense_change: comparison.expense_change,
        expense_change_rate: comparison.expense_change_rate,
        income_change: comparison.income_change,
        income_change_rate: comparison.income_change_rate,
        category_comparison: comparison.category_comparison
      }
    }

    {:ok, pdf_data}
  end

  @doc """
  PDFデータをHTML形式に変換する。
  """
  def render_to_html(%{type: :settlement} = pdf_data) do
    """
    <!DOCTYPE html>
    <html lang="ja">
    <head>
      <meta charset="UTF-8">
      <title>#{pdf_data.title}</title>
      <style>
        body { font-family: "Hiragino Sans", "Yu Gothic", sans-serif; margin: 40px; }
        h1 { color: #333; border-bottom: 2px solid #f97316; padding-bottom: 10px; }
        h2 { color: #666; margin-top: 30px; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #f8f8f8; }
        .summary { background-color: #fff7ed; padding: 20px; border-radius: 8px; margin: 20px 0; }
        .amount { text-align: right; font-family: monospace; }
        .positive { color: #16a34a; }
        .negative { color: #dc2626; }
      </style>
    </head>
    <body>
      <h1>#{pdf_data.title}</h1>
      <p>祭り名: #{pdf_data.festival_name}</p>
      <p>出力日時: #{format_datetime(pdf_data.generated_at)}</p>

      <div class="summary">
        <h2>サマリー</h2>
        <table>
          <tr><th>項目</th><th class="amount">金額</th></tr>
          <tr><td>総予算</td><td class="amount">#{format_currency(pdf_data.content.summary.total_budget)}</td></tr>
          <tr><td>総支出</td><td class="amount">#{format_currency(pdf_data.content.summary.total_expenses)}</td></tr>
          <tr><td>総収入</td><td class="amount">#{format_currency(pdf_data.content.summary.total_income)}</td></tr>
          <tr><td>収支</td><td class="amount #{balance_class(pdf_data.content.summary.balance)}">#{format_currency(pdf_data.content.summary.balance)}</td></tr>
        </table>
      </div>

      <h2>カテゴリ別支出</h2>
      <table>
        <tr><th>カテゴリ</th><th class="amount">予算</th><th class="amount">支出</th><th class="amount">執行率</th></tr>
        #{render_expenses_by_category(pdf_data.content.expenses_by_category)}
      </table>

      <h2>収入源別内訳</h2>
      <table>
        <tr><th>収入源</th><th class="amount">金額</th></tr>
        #{render_income_by_source(pdf_data.content.income_by_source)}
      </table>
    </body>
    </html>
    """
  end

  def render_to_html(%{type: :comparison} = pdf_data) do
    """
    <!DOCTYPE html>
    <html lang="ja">
    <head>
      <meta charset="UTF-8">
      <title>#{pdf_data.title}</title>
      <style>
        body { font-family: "Hiragino Sans", "Yu Gothic", sans-serif; margin: 40px; }
        h1 { color: #333; border-bottom: 2px solid #3b82f6; padding-bottom: 10px; }
        h2 { color: #666; margin-top: 30px; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #f8f8f8; }
        .amount { text-align: right; font-family: monospace; }
        .positive { color: #16a34a; }
        .negative { color: #dc2626; }
      </style>
    </head>
    <body>
      <h1>#{pdf_data.title}</h1>
      <p>比較対象: #{pdf_data.festival_names}</p>
      <p>出力日時: #{format_datetime(pdf_data.generated_at)}</p>

      <h2>変化サマリー</h2>
      <table>
        <tr><th>項目</th><th class="amount">変化額</th><th class="amount">変化率</th></tr>
        <tr>
          <td>支出</td>
          <td class="amount">#{format_currency(pdf_data.content.expense_change)}</td>
          <td class="amount">#{format_rate(pdf_data.content.expense_change_rate)}</td>
        </tr>
        <tr>
          <td>収入</td>
          <td class="amount">#{format_currency(pdf_data.content.income_change)}</td>
          <td class="amount">#{format_rate(pdf_data.content.income_change_rate)}</td>
        </tr>
      </table>

      <h2>年度別データ</h2>
      <table>
        <tr><th>祭り</th><th class="amount">支出</th><th class="amount">収入</th></tr>
        #{render_festivals_comparison(pdf_data.content.festivals)}
      </table>
    </body>
    </html>
    """
  end

  @doc """
  PDFデータをPDFバイナリに変換する。

  注意: 現在はシンプルなPDF形式で出力します。
  本格的なPDF出力には、chromic_pdfやpdf_generator等のライブラリの追加が必要です。
  """
  def to_binary(pdf_data) do
    html = render_to_html(pdf_data)

    # シンプルなPDF形式でHTMLコンテンツをラップ
    # 実際のPDF生成にはchromic_pdfやwkhtmltopdfが必要
    pdf_content = generate_simple_pdf(html, pdf_data.title)

    {:ok, pdf_content}
  end

  # Private functions

  defp generate_simple_pdf(_html_content, title) do
    # 最小限のPDF構造を生成
    # 本番環境ではchromic_pdf等を使用してHTMLからPDFを生成
    content_stream = """
    BT
    /F1 24 Tf
    100 700 Td
    (#{title}) Tj
    ET
    """

    objects = [
      "1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj",
      "2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj",
      "3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>\nendobj",
      "4 0 obj\n<< /Length #{byte_size(content_stream)} >>\nstream\n#{content_stream}endstream\nendobj",
      "5 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj"
    ]

    body = Enum.join(objects, "\n")
    xref_offset = byte_size("%PDF-1.4\n") + byte_size(body) + 1

    """
    %PDF-1.4
    #{body}
    xref
    0 6
    0000000000 65535 f
    0000000009 00000 n
    0000000058 00000 n
    0000000115 00000 n
    0000000266 00000 n
    0000000340 00000 n
    trailer
    << /Size 6 /Root 1 0 R >>
    startxref
    #{xref_offset}
    %%EOF
    """
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%Y年%m月%d日 %H:%M")
  end

  defp format_currency(nil), do: "-"

  defp format_currency(amount) do
    amount
    |> Decimal.round(0)
    |> Decimal.to_integer()
    |> Integer.to_string()
    |> add_thousand_separator()
    |> Kernel.<>("円")
  end

  defp add_thousand_separator(str) do
    str
    |> String.reverse()
    |> String.graphemes()
    |> Enum.chunk_every(3)
    |> Enum.join(",")
    |> String.reverse()
  end

  defp format_rate(nil), do: "-"
  defp format_rate(rate), do: "#{rate}%"

  defp balance_class(balance) do
    cond do
      Decimal.gt?(balance, Decimal.new(0)) -> "positive"
      Decimal.lt?(balance, Decimal.new(0)) -> "negative"
      true -> ""
    end
  end

  defp render_expenses_by_category(categories) do
    categories
    |> Enum.map(fn cat ->
      """
      <tr>
        <td>#{cat.name}</td>
        <td class="amount">#{format_currency(cat.budget)}</td>
        <td class="amount">#{format_currency(cat.total)}</td>
        <td class="amount">#{cat.execution_rate}%</td>
      </tr>
      """
    end)
    |> Enum.join("")
  end

  defp render_income_by_source(sources) do
    sources
    |> Enum.map(fn src ->
      """
      <tr>
        <td>#{translate_source_type(src.source_type)}</td>
        <td class="amount">#{format_currency(src.total)}</td>
      </tr>
      """
    end)
    |> Enum.join("")
  end

  defp render_festivals_comparison(festivals) do
    festivals
    |> Enum.map(fn f ->
      """
      <tr>
        <td>#{f.name}</td>
        <td class="amount">#{format_currency(f.total_expenses)}</td>
        <td class="amount">#{format_currency(f.total_income)}</td>
      </tr>
      """
    end)
    |> Enum.join("")
  end

  defp translate_source_type(source_type) do
    case source_type do
      "sponsorship" -> "協賛金"
      "vendor_fees" -> "出店料"
      "grant" -> "補助金"
      "donation" -> "寄付"
      "ticket_sales" -> "チケット売上"
      "other" -> "その他"
      _ -> source_type
    end
  end
end
