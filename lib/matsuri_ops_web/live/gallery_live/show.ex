defmodule MatsuriOpsWeb.GalleryLive.Show do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.Gallery
  alias MatsuriOps.Gallery.GalleryImage
  alias MatsuriOps.Festivals

  @impl true
  def mount(%{"festival_id" => festival_id, "id" => id}, _session, socket) do
    festival = Festivals.get_festival!(festival_id)
    gallery_image = Gallery.get_gallery_image!(id)

    # 閲覧数をインクリメント
    Gallery.increment_view_count(gallery_image)
    gallery_image = Gallery.get_gallery_image!(id)

    {:ok,
     socket
     |> assign(:festival, festival)
     |> assign(:gallery_image, gallery_image)
     |> assign(:page_title, gallery_image.title || "画像詳細")}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("like", _params, socket) do
    {:ok, updated} = Gallery.increment_like_count(socket.assigns.gallery_image)
    {:noreply, assign(socket, :gallery_image, updated)}
  end

  @impl true
  def handle_event("toggle_featured", _params, socket) do
    {:ok, updated} = Gallery.toggle_featured(socket.assigns.gallery_image)
    {:noreply, assign(socket, :gallery_image, updated)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <.header>
        {@gallery_image.title || "無題の画像"}
        <:subtitle>
          <span class={"px-2 py-1 text-xs rounded #{status_class(@gallery_image.status)}"}>
            {GalleryImage.status_label(@gallery_image.status)}
          </span>
          <span :if={@gallery_image.featured} class="ml-2 px-2 py-1 text-xs rounded bg-yellow-100 text-yellow-700">
            注目
          </span>
        </:subtitle>
        <:actions>
          <.button phx-click="like" class="bg-pink-500 hover:bg-pink-600">
            ♥ いいね ({@gallery_image.like_count})
          </.button>
          <.button
            phx-click="toggle_featured"
            class={if @gallery_image.featured, do: "bg-yellow-500 hover:bg-yellow-600", else: "bg-gray-500 hover:bg-gray-600"}
          >
            {if @gallery_image.featured, do: "注目解除", else: "注目に設定"}
          </.button>
          <.link navigate={~p"/festivals/#{@festival}/gallery"}>
            <.button class="bg-gray-200 text-gray-700 hover:bg-gray-300">一覧へ戻る</.button>
          </.link>
        </:actions>
      </.header>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div class="lg:col-span-2">
          <div class="bg-black rounded-lg overflow-hidden">
            <img
              src={@gallery_image.image_url}
              alt={@gallery_image.title || "ギャラリー画像"}
              class="w-full max-h-[600px] object-contain"
            />
          </div>

          <div :if={@gallery_image.description} class="mt-4 bg-white rounded-lg shadow p-4">
            <h3 class="font-medium mb-2">説明</h3>
            <p class="text-gray-600 whitespace-pre-wrap">{@gallery_image.description}</p>
          </div>
        </div>

        <div class="space-y-4">
          <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-medium mb-4">詳細情報</h3>
            <dl class="space-y-3">
              <div>
                <dt class="text-sm text-gray-500">投稿者</dt>
                <dd class="mt-1">{@gallery_image.contributor_name || "匿名"}</dd>
              </div>
              <div :if={@gallery_image.contributor_email}>
                <dt class="text-sm text-gray-500">メールアドレス</dt>
                <dd class="mt-1">{@gallery_image.contributor_email}</dd>
              </div>
              <div>
                <dt class="text-sm text-gray-500">閲覧数</dt>
                <dd class="mt-1 text-lg font-semibold">{@gallery_image.view_count}</dd>
              </div>
              <div>
                <dt class="text-sm text-gray-500">いいね数</dt>
                <dd class="mt-1 text-lg font-semibold text-pink-600">{@gallery_image.like_count}</dd>
              </div>
              <div>
                <dt class="text-sm text-gray-500">投稿日</dt>
                <dd class="mt-1">{format_datetime(@gallery_image.inserted_at)}</dd>
              </div>
              <div :if={@gallery_image.approved_at}>
                <dt class="text-sm text-gray-500">承認日</dt>
                <dd class="mt-1">{format_datetime(@gallery_image.approved_at)}</dd>
              </div>
              <div :if={@gallery_image.approved_by}>
                <dt class="text-sm text-gray-500">承認者</dt>
                <dd class="mt-1">{@gallery_image.approved_by.email}</dd>
              </div>
            </dl>
          </div>

          <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-medium mb-4">共有</h3>
            <div class="flex gap-2">
              <a
                href={"https://twitter.com/intent/tweet?url=#{URI.encode(@gallery_image.image_url)}&text=#{URI.encode((@gallery_image.title || "祭りの写真") <> " #" <> @festival.name)}"}
                target="_blank"
                class="flex-1 bg-blue-400 text-white text-center py-2 rounded hover:bg-blue-500"
              >
                X/Twitter
              </a>
              <a
                href={@gallery_image.image_url}
                download={(@gallery_image.title || "gallery_image") <> ".jpg"}
                class="flex-1 bg-green-600 text-white text-center py-2 rounded hover:bg-green-700"
              >
                ダウンロード
              </a>
            </div>
          </div>

          <div class="bg-blue-50 rounded-lg p-4">
            <h4 class="font-medium text-blue-900 mb-2">埋め込みコード</h4>
            <pre class="bg-blue-100 rounded p-2 text-xs overflow-x-auto">&lt;img src="{@gallery_image.image_url}" alt="{@gallery_image.title || "ギャラリー画像"}"&gt;</pre>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%Y/%m/%d %H:%M")
  end

  defp status_class("pending"), do: "bg-yellow-100 text-yellow-700"
  defp status_class("approved"), do: "bg-green-100 text-green-700"
  defp status_class("rejected"), do: "bg-red-100 text-red-700"
  defp status_class(_), do: "bg-gray-100 text-gray-500"
end
