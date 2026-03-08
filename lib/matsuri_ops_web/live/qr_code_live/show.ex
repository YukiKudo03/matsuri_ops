defmodule MatsuriOpsWeb.QRCodeLive.Show do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.QRCodes
  alias MatsuriOps.QRCodes.QRCode
  alias MatsuriOps.Festivals

  @impl true
  def mount(%{"festival_id" => festival_id, "id" => id}, _session, socket) do
    festival = Festivals.get_festival!(festival_id)
    qr_code = QRCodes.get_qr_code!(id)

    {:ok,
     socket
     |> assign(:festival, festival)
     |> assign(:qr_code, qr_code)
     |> assign(:page_title, qr_code.name)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <.header>
        {@qr_code.name}
        <:subtitle>
          <span class="px-2 py-1 text-xs rounded bg-gray-100">
            {QRCode.code_type_label(@qr_code.code_type)}
          </span>
        </:subtitle>
        <:actions>
          <.link patch={~p"/festivals/#{@festival}/qr-codes/#{@qr_code}/edit"}>
            <.button>編集</.button>
          </.link>
          <.link navigate={~p"/festivals/#{@festival}/qr-codes"}>
            <.button class="bg-gray-200 text-gray-700 hover:bg-gray-300">一覧へ戻る</.button>
          </.link>
        </:actions>
      </.header>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
        <div class="bg-white rounded-lg shadow p-6 flex flex-col items-center">
          <h3 class="text-lg font-medium mb-4">QRコード</h3>
          <div class="w-64 h-64 bg-white border-2 border-gray-200 rounded-lg p-4 mb-4">
            {raw(@qr_code.svg_data || "<p class='text-gray-400 text-center'>未生成</p>")}
          </div>
          <div class="flex gap-2">
            <.button phx-click="download_svg" class="bg-green-600 hover:bg-green-700">
              SVGダウンロード
            </.button>
            <.button phx-click="download_png" class="bg-blue-600 hover:bg-blue-700">
              PNGダウンロード
            </.button>
          </div>
        </div>

        <div class="space-y-4">
          <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-medium mb-4">詳細情報</h3>
            <dl class="space-y-3">
              <div>
                <dt class="text-sm text-gray-500">リンク先URL</dt>
                <dd class="mt-1">
                  <a href={@qr_code.target_url} target="_blank" class="text-blue-600 hover:underline break-all">
                    {@qr_code.target_url}
                  </a>
                </dd>
              </div>
              <div>
                <dt class="text-sm text-gray-500">スキャン回数</dt>
                <dd class="mt-1 text-2xl font-bold text-green-600">{@qr_code.scan_count}</dd>
              </div>
              <div>
                <dt class="text-sm text-gray-500">作成日</dt>
                <dd class="mt-1">{format_datetime(@qr_code.inserted_at)}</dd>
              </div>
              <div>
                <dt class="text-sm text-gray-500">更新日</dt>
                <dd class="mt-1">{format_datetime(@qr_code.updated_at)}</dd>
              </div>
            </dl>
          </div>

          <div class="bg-blue-50 rounded-lg p-4">
            <h4 class="font-medium text-blue-900 mb-2">使用方法</h4>
            <p class="text-sm text-blue-800">
              このQRコードを印刷物やデジタルサイネージに配置してください。
              スキャンされた回数は自動的に記録されます。
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("download_svg", _params, socket) do
    qr_code = socket.assigns.qr_code
    svg_data = qr_code.svg_data || ""

    # SVGダウンロード用のデータURIを生成
    data_uri = "data:image/svg+xml;base64,#{Base.encode64(svg_data)}"

    {:noreply,
     push_event(socket, "download", %{
       data: data_uri,
       filename: "#{qr_code.name}.svg"
     })}
  end

  @impl true
  def handle_event("download_png", _params, socket) do
    qr_code = socket.assigns.qr_code

    case QRCodes.generate_qr_png(qr_code.target_url) do
      {:ok, png_data} ->
        data_uri = "data:image/png;base64,#{Base.encode64(png_data)}"

        {:noreply,
         push_event(socket, "download", %{
           data: data_uri,
           filename: "#{qr_code.name}.png"
         })}

      _ ->
        {:noreply, put_flash(socket, :error, "PNG生成に失敗しました")}
    end
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%Y/%m/%d %H:%M")
  end
end
