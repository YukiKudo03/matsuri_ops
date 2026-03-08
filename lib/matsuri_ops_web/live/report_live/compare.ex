defmodule MatsuriOpsWeb.ReportLive.Compare do
  @moduledoc """
  年度比較レポートを表示するLiveView。
  """

  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.Festivals
  alias MatsuriOps.Reports

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_scope.user
    festivals = Festivals.list_user_festivals(current_user)

    {:ok,
     socket
     |> assign(:page_title, "年度比較")
     |> assign(:festivals, festivals)
     |> assign(:selected_ids, [])
     |> assign(:comparison, nil)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"festival_ids" => festival_ids}, socket) do
    selected_ids = parse_festival_ids(festival_ids)
    {:noreply, assign(socket, :selected_ids, selected_ids)}
  end

  @impl true
  def handle_event("compare", %{"festival_ids" => festival_ids}, socket) do
    selected_ids = parse_festival_ids(festival_ids)

    comparison =
      if length(selected_ids) >= 1 do
        Reports.compare_festivals(selected_ids)
      else
        nil
      end

    {:noreply,
     socket
     |> assign(:selected_ids, selected_ids)
     |> assign(:comparison, comparison)}
  end

  defp parse_festival_ids(festival_ids) when is_list(festival_ids) do
    festival_ids
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.to_integer/1)
  end

  defp parse_festival_ids(_), do: []

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      年度比較
    </.header>

    <div class="mt-6">
      <form id="compare-form" phx-change="validate" phx-submit="compare">
        <div class="space-y-4">
          <label class="block text-sm font-medium">比較対象の祭りを選択</label>
          <select
            name="festival_ids[]"
            multiple
            class="select select-bordered w-full max-w-md"
            size="5"
          >
            <option :for={festival <- @festivals} value={festival.id}>
              {festival.name} ({format_date(festival.start_date)})
            </option>
          </select>
          <p class="text-sm text-gray-500">Ctrlキーを押しながらクリックで複数選択</p>
          <.button type="submit">比較する</.button>
        </div>
      </form>
    </div>

    <div :if={@comparison} class="mt-8 space-y-8">
      <section>
        <h2 class="text-lg font-semibold mb-4">比較サマリー</h2>
        <div :if={@comparison.expense_change} class="grid grid-cols-2 gap-4">
          <.change_card
            label="支出変化"
            value={format_currency(@comparison.expense_change)}
            rate={@comparison.expense_change_rate}
          />
          <.change_card
            label="収入変化"
            value={format_currency(@comparison.income_change)}
            rate={@comparison.income_change_rate}
          />
        </div>
        <p :if={is_nil(@comparison.expense_change)} class="text-gray-500">
          2つ以上の祭りを選択すると比較データが表示されます
        </p>
      </section>

      <section>
        <h2 class="text-lg font-semibold mb-4">年度別データ</h2>
        <.table id="festivals-comparison" rows={@comparison.festivals}>
          <:col :let={festival} label="祭り名">{festival.name}</:col>
          <:col :let={festival} label="支出">
            <span class="text-right block">{format_currency(festival.total_expenses)}</span>
          </:col>
          <:col :let={festival} label="収入">
            <span class="text-right block">{format_currency(festival.total_income)}</span>
          </:col>
        </.table>
      </section>

      <section :if={@comparison.category_comparison}>
        <h2 class="text-lg font-semibold mb-4">カテゴリ別比較</h2>
        <.table id="category-comparison" rows={@comparison.category_comparison}>
          <:col :let={cat} label="カテゴリ">{cat.name}</:col>
          <:col :let={cat} label="前年度">
            <span class="text-right block">{format_currency(cat.previous)}</span>
          </:col>
          <:col :let={cat} label="今年度">
            <span class="text-right block">{format_currency(cat.current)}</span>
          </:col>
          <:col :let={cat} label="変化率">
            <span class={"text-right block " <> change_rate_class(cat.change_rate)}>
              {format_rate(cat.change_rate)}
            </span>
          </:col>
        </.table>
      </section>
    </div>

    <.back navigate={~p"/festivals"}>祭り一覧へ戻る</.back>
    """
  end

  defp change_card(assigns) do
    ~H"""
    <div class="stat bg-base-200 rounded-lg p-4">
      <div class="stat-title text-sm text-gray-500">{@label}</div>
      <div class="stat-value text-lg font-semibold">{@value}</div>
      <div class={"stat-desc #{change_rate_class(@rate)}"}>
        {format_rate(@rate)}
      </div>
    </div>
    """
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
  defp format_rate(rate) when rate > 0, do: "+#{rate}%"
  defp format_rate(rate), do: "#{rate}%"

  defp format_date(date) do
    Calendar.strftime(date, "%Y年%m月%d日")
  end

  defp change_rate_class(nil), do: ""
  defp change_rate_class(rate) when rate > 0, do: "text-red-600"
  defp change_rate_class(rate) when rate < 0, do: "text-green-600"
  defp change_rate_class(_), do: ""
end
