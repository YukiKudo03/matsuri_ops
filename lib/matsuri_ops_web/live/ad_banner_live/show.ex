defmodule MatsuriOpsWeb.AdBannerLive.Show do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.Advertising
  alias MatsuriOps.Advertising.AdBanner
  alias MatsuriOps.Festivals

  @impl true
  def mount(%{"festival_id" => festival_id, "id" => id}, _session, socket) do
    festival = Festivals.get_festival!(festival_id)
    ad_banner = Advertising.get_ad_banner!(id)

    {:ok,
     socket
     |> assign(:festival, festival)
     |> assign(:ad_banner, ad_banner)
     |> assign(:page_title, ad_banner.name)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_active", _params, socket) do
    ad_banner = socket.assigns.ad_banner
    {:ok, updated} = Advertising.toggle_active(ad_banner)

    {:noreply, assign(socket, :ad_banner, updated)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <.header>
        {@ad_banner.name}
        <:subtitle>
          <span class={"px-2 py-1 text-xs rounded #{if @ad_banner.is_active, do: "bg-green-100 text-green-700", else: "bg-gray-100 text-gray-500"}"}>
            {if @ad_banner.is_active, do: "有効", else: "無効"}
          </span>
          <span class="ml-2 px-2 py-1 text-xs rounded bg-gray-100">
            {AdBanner.position_label(@ad_banner.position)}
          </span>
        </:subtitle>
        <:actions>
          <.link patch={~p"/festivals/#{@festival}/ad-banners/#{@ad_banner}/edit"}>
            <.button>編集</.button>
          </.link>
          <.button
            phx-click="toggle_active"
            class={if @ad_banner.is_active, do: "bg-orange-500 hover:bg-orange-600", else: "bg-green-600 hover:bg-green-700"}
          >
            {if @ad_banner.is_active, do: "無効化", else: "有効化"}
          </.button>
          <.link navigate={~p"/festivals/#{@festival}/ad-banners"}>
            <.button class="bg-gray-200 text-gray-700 hover:bg-gray-300">一覧へ戻る</.button>
          </.link>
        </:actions>
      </.header>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
        <div class="bg-white rounded-lg shadow p-6">
          <h3 class="text-lg font-medium mb-4">バナープレビュー</h3>
          <div class="bg-gray-100 rounded-lg p-4 flex items-center justify-center min-h-48">
            <img
              :if={@ad_banner.image_url}
              src={@ad_banner.image_url}
              alt={@ad_banner.name}
              class="max-w-full max-h-64 object-contain rounded"
            />
            <div :if={!@ad_banner.image_url} class="text-gray-400">
              画像が設定されていません
            </div>
          </div>
          <div :if={@ad_banner.link_url} class="mt-4">
            <p class="text-sm text-gray-500">リンク先:</p>
            <a
              href={@ad_banner.link_url}
              target="_blank"
              class="text-blue-600 hover:underline break-all text-sm"
            >
              {@ad_banner.link_url}
            </a>
          </div>
        </div>

        <div class="space-y-4">
          <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-medium mb-4">詳細情報</h3>
            <dl class="space-y-3">
              <div>
                <dt class="text-sm text-gray-500">スポンサー</dt>
                <dd class="mt-1">
                  {if @ad_banner.sponsor, do: @ad_banner.sponsor.name, else: "（指定なし）"}
                </dd>
              </div>
              <div>
                <dt class="text-sm text-gray-500">表示位置</dt>
                <dd class="mt-1">{AdBanner.position_label(@ad_banner.position)}</dd>
              </div>
              <div>
                <dt class="text-sm text-gray-500">表示優先度</dt>
                <dd class="mt-1">{@ad_banner.display_weight}</dd>
              </div>
              <div>
                <dt class="text-sm text-gray-500">表示期間</dt>
                <dd class="mt-1">
                  {format_period(@ad_banner.start_date, @ad_banner.end_date)}
                </dd>
              </div>
              <div>
                <dt class="text-sm text-gray-500">作成日</dt>
                <dd class="mt-1">{format_datetime(@ad_banner.inserted_at)}</dd>
              </div>
              <div>
                <dt class="text-sm text-gray-500">更新日</dt>
                <dd class="mt-1">{format_datetime(@ad_banner.updated_at)}</dd>
              </div>
            </dl>
          </div>

          <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-medium mb-4">パフォーマンス</h3>
            <div class="grid grid-cols-3 gap-4 text-center">
              <div>
                <p class="text-2xl font-bold text-blue-600">{@ad_banner.impression_count}</p>
                <p class="text-sm text-gray-500">インプレッション</p>
              </div>
              <div>
                <p class="text-2xl font-bold text-green-600">{@ad_banner.click_count}</p>
                <p class="text-sm text-gray-500">クリック</p>
              </div>
              <div>
                <p class="text-2xl font-bold text-purple-600">{calculate_ctr(@ad_banner)}%</p>
                <p class="text-sm text-gray-500">CTR</p>
              </div>
            </div>
          </div>

          <div class="bg-blue-50 rounded-lg p-4">
            <h4 class="font-medium text-blue-900 mb-2">埋め込みコード</h4>
            <p class="text-sm text-blue-800 mb-2">
              このバナーをWebサイトに埋め込む場合は、以下のHTMLを使用してください。
            </p>
            <pre class="bg-blue-100 rounded p-2 text-xs overflow-x-auto">&lt;a href="{@ad_banner.link_url}" target="_blank"&gt;&lt;img src="{@ad_banner.image_url}" alt="{@ad_banner.name}"&gt;&lt;/a&gt;</pre>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%Y/%m/%d %H:%M")
  end

  defp format_period(nil, nil), do: "期間指定なし（常時表示）"
  defp format_period(start_date, nil), do: "#{Date.to_string(start_date)} 〜 無期限"
  defp format_period(nil, end_date), do: "〜 #{Date.to_string(end_date)}"
  defp format_period(start_date, end_date), do: "#{Date.to_string(start_date)} 〜 #{Date.to_string(end_date)}"

  defp calculate_ctr(ad_banner) do
    Advertising.calculate_ctr(ad_banner)
  end
end
