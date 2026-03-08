defmodule MatsuriOpsWeb.ReportLive.Index do
  @moduledoc """
  祭りの決算報告を表示するLiveView。
  """

  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.Festivals
  alias MatsuriOps.Reports
  alias MatsuriOps.Reports.PdfExport

  @impl true
  def mount(%{"festival_id" => festival_id}, _session, socket) do
    festival = Festivals.get_festival!(festival_id)
    report = Reports.settlement_report(festival_id)

    {:ok,
     socket
     |> assign(:page_title, "レポート - #{festival.name}")
     |> assign(:festival, festival)
     |> assign(:report, report)
     |> assign(:show_pdf_preview, false)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("preview_pdf", _params, socket) do
    {:noreply, assign(socket, :show_pdf_preview, true)}
  end

  @impl true
  def handle_event("close_preview", _params, socket) do
    {:noreply, assign(socket, :show_pdf_preview, false)}
  end

  @impl true
  def handle_event("download_pdf", _params, socket) do
    {:ok, pdf_data} = PdfExport.generate_settlement_pdf(socket.assigns.festival.id)
    {:ok, binary} = PdfExport.to_binary(pdf_data)

    filename = "決算報告書_#{socket.assigns.festival.name}.pdf"

    {:noreply,
     socket
     |> push_event("download", %{
       content: Base.encode64(binary),
       filename: filename,
       content_type: "application/pdf"
     })}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      {@festival.name} - レポート
      <:actions>
        <.link phx-click="preview_pdf">
          <.button>PDF出力</.button>
        </.link>
        <.link navigate={~p"/festivals/#{@festival}"}>
          <.button variant="outline">祭り詳細へ</.button>
        </.link>
      </:actions>
    </.header>

    <div class="mt-8 space-y-8">
      <section>
        <h2 class="text-lg font-semibold mb-4">決算サマリー</h2>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
          <.summary_card label="総予算" value={format_currency(@report.total_budget)} />
          <.summary_card label="総支出" value={format_currency(@report.total_expenses)} />
          <.summary_card label="総収入" value={format_currency(@report.total_income)} />
          <.summary_card
            label="収支"
            value={format_currency(@report.balance)}
            class={balance_class(@report.balance)}
          />
        </div>
      </section>

      <section>
        <h2 class="text-lg font-semibold mb-4">カテゴリ別支出</h2>
        <.table id="expenses-by-category" rows={@report.expenses_by_category}>
          <:col :let={category} label="カテゴリ">{category.name}</:col>
          <:col :let={category} label="予算">
            <span class="text-right block">{format_currency(category.budget)}</span>
          </:col>
          <:col :let={category} label="支出">
            <span class="text-right block">{format_currency(category.total)}</span>
          </:col>
          <:col :let={category} label="執行率">
            <span class="text-right block">{category.execution_rate}%</span>
          </:col>
          <:col :let={category} label="進捗">
            <div class="w-full bg-gray-200 rounded-full h-2">
              <div
                class="bg-primary h-2 rounded-full"
                style={"width: #{min(category.execution_rate, 100)}%"}
              >
              </div>
            </div>
          </:col>
        </.table>
      </section>

      <section>
        <h2 class="text-lg font-semibold mb-4">収入源別内訳</h2>
        <.table id="income-by-source" rows={@report.income_by_source}>
          <:col :let={source} label="収入源">
            {translate_source_type(source.source_type)}
          </:col>
          <:col :let={source} label="金額">
            <span class="text-right block">{format_currency(source.total)}</span>
          </:col>
        </.table>
      </section>
    </div>

    <.modal
      :if={@show_pdf_preview}
      id="pdf-preview-modal"
      show
      on_cancel={JS.push("close_preview")}
    >
      <div class="space-y-4">
        <h3 class="text-lg font-semibold">PDF出力プレビュー</h3>
        <p>決算報告書をダウンロードしますか？</p>
        <div class="flex gap-4 justify-end">
          <.button variant="outline" phx-click="close_preview">キャンセル</.button>
          <.button phx-click="download_pdf">ダウンロード</.button>
        </div>
      </div>
    </.modal>

    <.back navigate={~p"/festivals/#{@festival}"}>祭り詳細へ戻る</.back>
    """
  end

  defp summary_card(assigns) do
    assigns = assign_new(assigns, :class, fn -> "" end)

    ~H"""
    <div class="stat bg-base-200 rounded-lg p-4">
      <div class="stat-title text-sm text-gray-500">{@label}</div>
      <div class={"stat-value text-lg font-semibold #{@class}"}>{@value}</div>
    </div>
    """
  end

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

  defp balance_class(balance) do
    cond do
      Decimal.gt?(balance, Decimal.new(0)) -> "text-green-600"
      Decimal.lt?(balance, Decimal.new(0)) -> "text-red-600"
      true -> ""
    end
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
