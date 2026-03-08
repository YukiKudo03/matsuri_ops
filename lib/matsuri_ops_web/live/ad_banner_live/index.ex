defmodule MatsuriOpsWeb.AdBannerLive.Index do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.Advertising
  alias MatsuriOps.Advertising.AdBanner
  alias MatsuriOps.Festivals
  alias MatsuriOps.Sponsorships

  @impl true
  def mount(%{"festival_id" => festival_id}, _session, socket) do
    festival = Festivals.get_festival!(festival_id)
    ad_banners = Advertising.list_ad_banners(festival_id)
    statistics = Advertising.get_statistics(festival_id)
    sponsors = Sponsorships.list_sponsors()

    {:ok,
     socket
     |> assign(:festival, festival)
     |> assign(:page_title, "広告バナー管理")
     |> assign(:statistics, statistics)
     |> assign(:sponsors, sponsors)
     |> assign(:filter_position, "all")
     |> stream(:ad_banners, ad_banners)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "広告バナーを編集")
    |> assign(:ad_banner, Advertising.get_ad_banner!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "新しい広告バナー")
    |> assign(:ad_banner, %AdBanner{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "広告バナー管理")
    |> assign(:ad_banner, nil)
  end

  @impl true
  def handle_event("filter", %{"position" => position}, socket) do
    festival_id = socket.assigns.festival.id

    ad_banners =
      if position == "all" do
        Advertising.list_ad_banners(festival_id)
      else
        Advertising.list_ad_banners(festival_id)
        |> Enum.filter(&(&1.position == position))
      end

    {:noreply,
     socket
     |> assign(:filter_position, position)
     |> stream(:ad_banners, ad_banners, reset: true)}
  end

  @impl true
  def handle_event("toggle_active", %{"id" => id}, socket) do
    ad_banner = Advertising.get_ad_banner!(id)
    {:ok, updated} = Advertising.toggle_active(ad_banner)

    {:noreply, stream_insert(socket, :ad_banners, updated)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    ad_banner = Advertising.get_ad_banner!(id)
    {:ok, _} = Advertising.delete_ad_banner(ad_banner)

    {:noreply, stream_delete(socket, :ad_banners, ad_banner)}
  end

  @impl true
  def handle_info({MatsuriOpsWeb.AdBannerLive.FormComponent, {:saved, ad_banner}}, socket) do
    {:noreply, stream_insert(socket, :ad_banners, ad_banner)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <.header>
        広告バナー管理
        <:subtitle>{@festival.name}の広告バナー</:subtitle>
        <:actions>
          <.link patch={~p"/festivals/#{@festival}/ad-banners/new"}>
            <.button>新規広告バナー</.button>
          </.link>
          <.link navigate={~p"/festivals/#{@festival}"}>
            <.button class="bg-gray-200 text-gray-700 hover:bg-gray-300">祭り詳細へ</.button>
          </.link>
        </:actions>
      </.header>

      <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div class="bg-blue-50 rounded-lg p-4">
          <p class="text-sm text-gray-600">総バナー数</p>
          <p class="text-2xl font-bold text-blue-600">{@statistics.total_count}</p>
        </div>
        <div class="bg-green-50 rounded-lg p-4">
          <p class="text-sm text-gray-600">アクティブ</p>
          <p class="text-2xl font-bold text-green-600">{@statistics.active_count}</p>
        </div>
        <div class="bg-purple-50 rounded-lg p-4">
          <p class="text-sm text-gray-600">総クリック数</p>
          <p class="text-2xl font-bold text-purple-600">{@statistics.total_clicks}</p>
        </div>
        <div class="bg-orange-50 rounded-lg p-4">
          <p class="text-sm text-gray-600">総インプレッション</p>
          <p class="text-2xl font-bold text-orange-600">{@statistics.total_impressions}</p>
        </div>
      </div>

      <div class="flex gap-2">
        <.button
          phx-click="filter"
          phx-value-position="all"
          class={if @filter_position == "all", do: "bg-blue-600", else: "bg-gray-300 text-gray-700"}
        >
          すべて
        </.button>
        <.button
          :for={position <- AdBanner.positions()}
          phx-click="filter"
          phx-value-position={position}
          class={if @filter_position == position, do: "bg-blue-600", else: "bg-gray-300 text-gray-700"}
        >
          {AdBanner.position_label(position)}
        </.button>
      </div>

      <.table
        id="ad_banners"
        rows={@streams.ad_banners}
        row_click={fn {_id, ad_banner} -> JS.navigate(~p"/festivals/#{@festival}/ad-banners/#{ad_banner}") end}
      >
        <:col :let={{_id, ad_banner}} label="プレビュー">
          <div class="w-20 h-12 bg-gray-100 rounded overflow-hidden">
            <img
              :if={ad_banner.image_url}
              src={ad_banner.image_url}
              alt={ad_banner.name}
              class="w-full h-full object-cover"
            />
            <div :if={!ad_banner.image_url} class="w-full h-full flex items-center justify-center text-gray-400 text-xs">
              画像なし
            </div>
          </div>
        </:col>
        <:col :let={{_id, ad_banner}} label="名前">{ad_banner.name}</:col>
        <:col :let={{_id, ad_banner}} label="スポンサー">
          <span :if={ad_banner.sponsor}>{ad_banner.sponsor.name}</span>
          <span :if={!ad_banner.sponsor} class="text-gray-400">-</span>
        </:col>
        <:col :let={{_id, ad_banner}} label="位置">
          <span class="px-2 py-1 text-xs rounded bg-gray-100">
            {AdBanner.position_label(ad_banner.position)}
          </span>
        </:col>
        <:col :let={{_id, ad_banner}} label="状態">
          <span
            class={"px-2 py-1 text-xs rounded #{if ad_banner.is_active, do: "bg-green-100 text-green-700", else: "bg-gray-100 text-gray-500"}"}
          >
            {if ad_banner.is_active, do: "有効", else: "無効"}
          </span>
        </:col>
        <:col :let={{_id, ad_banner}} label="クリック/表示">
          <span class="font-mono text-sm">{ad_banner.click_count} / {ad_banner.impression_count}</span>
        </:col>
        <:action :let={{_id, ad_banner}}>
          <.link
            phx-click="toggle_active"
            phx-value-id={ad_banner.id}
          >
            {if ad_banner.is_active, do: "無効化", else: "有効化"}
          </.link>
        </:action>
        <:action :let={{_id, ad_banner}}>
          <.link patch={~p"/festivals/#{@festival}/ad-banners/#{ad_banner}/edit"}>編集</.link>
        </:action>
        <:action :let={{id, ad_banner}}>
          <.link
            phx-click={JS.push("delete", value: %{id: ad_banner.id}) |> hide("##{id}")}
            data-confirm="本当に削除しますか？"
          >
            削除
          </.link>
        </:action>
      </.table>

      <.modal :if={@live_action in [:new, :edit]} id="ad-banner-modal" show on_cancel={JS.patch(~p"/festivals/#{@festival}/ad-banners")}>
        <.live_component
          module={MatsuriOpsWeb.AdBannerLive.FormComponent}
          id={@ad_banner.id || :new}
          title={@page_title}
          action={@live_action}
          ad_banner={@ad_banner}
          festival={@festival}
          sponsors={@sponsors}
          patch={~p"/festivals/#{@festival}/ad-banners"}
        />
      </.modal>
    </div>
    """
  end
end
