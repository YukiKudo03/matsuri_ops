defmodule MatsuriOpsWeb.QRCodeLive.Index do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.QRCodes
  alias MatsuriOps.QRCodes.QRCode
  alias MatsuriOps.Festivals

  @impl true
  def mount(%{"festival_id" => festival_id}, _session, socket) do
    festival = Festivals.get_festival!(festival_id)
    qr_codes = QRCodes.list_qr_codes(festival_id)
    statistics = QRCodes.get_statistics(festival_id)

    {:ok,
     socket
     |> assign(:festival, festival)
     |> assign(:page_title, "QRコード管理")
     |> assign(:statistics, statistics)
     |> assign(:filter_type, "all")
     |> stream(:qr_codes, qr_codes)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "QRコードを編集")
    |> assign(:qr_code, QRCodes.get_qr_code!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "新しいQRコード")
    |> assign(:qr_code, %QRCode{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "QRコード管理")
    |> assign(:qr_code, nil)
  end

  @impl true
  def handle_event("filter", %{"type" => type}, socket) do
    festival_id = socket.assigns.festival.id

    qr_codes =
      if type == "all" do
        QRCodes.list_qr_codes(festival_id)
      else
        QRCodes.list_qr_codes_by_type(festival_id, type)
      end

    {:noreply,
     socket
     |> assign(:filter_type, type)
     |> stream(:qr_codes, qr_codes, reset: true)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    qr_code = QRCodes.get_qr_code!(id)
    {:ok, _} = QRCodes.delete_qr_code(qr_code)

    {:noreply, stream_delete(socket, :qr_codes, qr_code)}
  end

  @impl true
  def handle_info({MatsuriOpsWeb.QRCodeLive.FormComponent, {:saved, qr_code}}, socket) do
    {:noreply, stream_insert(socket, :qr_codes, qr_code)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <.header>
        QRコード管理
        <:subtitle>{@festival.name}のQRコード</:subtitle>
        <:actions>
          <.link patch={~p"/festivals/#{@festival}/qr-codes/new"}>
            <.button>新規QRコード</.button>
          </.link>
          <.link navigate={~p"/festivals/#{@festival}"}>
            <.button class="bg-gray-200 text-gray-700 hover:bg-gray-300">祭り詳細へ</.button>
          </.link>
        </:actions>
      </.header>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div class="bg-blue-50 rounded-lg p-4">
          <p class="text-sm text-gray-600">総QRコード数</p>
          <p class="text-2xl font-bold text-blue-600">{@statistics.total_count}</p>
        </div>
        <div class="bg-green-50 rounded-lg p-4">
          <p class="text-sm text-gray-600">総スキャン数</p>
          <p class="text-2xl font-bold text-green-600">{@statistics.total_scans}</p>
        </div>
        <div class="bg-purple-50 rounded-lg p-4">
          <p class="text-sm text-gray-600">タイプ別</p>
          <div class="flex flex-wrap gap-2 mt-1">
            <span :for={{type, count} <- @statistics.by_type} class="text-xs bg-purple-100 text-purple-700 px-2 py-1 rounded">
              {QRCode.code_type_label(type)}: {count}
            </span>
          </div>
        </div>
      </div>

      <div class="flex gap-2">
        <.button
          phx-click="filter"
          phx-value-type="all"
          class={if @filter_type == "all", do: "bg-blue-600", else: "bg-gray-300 text-gray-700"}
        >
          すべて
        </.button>
        <.button
          :for={type <- QRCode.code_types()}
          phx-click="filter"
          phx-value-type={type}
          class={if @filter_type == type, do: "bg-blue-600", else: "bg-gray-300 text-gray-700"}
        >
          {QRCode.code_type_label(type)}
        </.button>
      </div>

      <.table
        id="qr_codes"
        rows={@streams.qr_codes}
        row_click={fn {_id, qr_code} -> JS.navigate(~p"/festivals/#{@festival}/qr-codes/#{qr_code}") end}
      >
        <:col :let={{_id, qr_code}} label="プレビュー">
          <div class="w-12 h-12 bg-white border rounded p-1">
            {raw(qr_code.svg_data || "<span class='text-gray-400 text-xs'>未生成</span>")}
          </div>
        </:col>
        <:col :let={{_id, qr_code}} label="名前">{qr_code.name}</:col>
        <:col :let={{_id, qr_code}} label="タイプ">
          <span class="px-2 py-1 text-xs rounded bg-gray-100">
            {QRCode.code_type_label(qr_code.code_type)}
          </span>
        </:col>
        <:col :let={{_id, qr_code}} label="スキャン数">
          <span class="font-mono">{qr_code.scan_count}</span>
        </:col>
        <:col :let={{_id, qr_code}} label="作成日">{format_date(qr_code.inserted_at)}</:col>
        <:action :let={{_id, qr_code}}>
          <.link patch={~p"/festivals/#{@festival}/qr-codes/#{qr_code}/edit"}>編集</.link>
        </:action>
        <:action :let={{id, qr_code}}>
          <.link
            phx-click={JS.push("delete", value: %{id: qr_code.id}) |> hide("##{id}")}
            data-confirm="本当に削除しますか？"
          >
            削除
          </.link>
        </:action>
      </.table>

      <.modal :if={@live_action in [:new, :edit]} id="qr-code-modal" show on_cancel={JS.patch(~p"/festivals/#{@festival}/qr-codes")}>
        <.live_component
          module={MatsuriOpsWeb.QRCodeLive.FormComponent}
          id={@qr_code.id || :new}
          title={@page_title}
          action={@live_action}
          qr_code={@qr_code}
          festival={@festival}
          patch={~p"/festivals/#{@festival}/qr-codes"}
        />
      </.modal>
    </div>
    """
  end

  defp format_date(datetime) do
    Calendar.strftime(datetime, "%Y/%m/%d")
  end
end
