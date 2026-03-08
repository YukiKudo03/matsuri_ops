defmodule MatsuriOpsWeb.GalleryLive.Moderation do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.Gallery
  alias MatsuriOps.Festivals

  @impl true
  def mount(%{"festival_id" => festival_id}, _session, socket) do
    festival = Festivals.get_festival!(festival_id)
    pending_images = Gallery.list_pending_images(festival_id)
    statistics = Gallery.get_statistics(festival_id)

    {:ok,
     socket
     |> assign(:festival, festival)
     |> assign(:page_title, "画像審査")
     |> assign(:statistics, statistics)
     |> stream(:pending_images, pending_images)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("approve", %{"id" => id}, socket) do
    gallery_image = Gallery.get_gallery_image!(id)
    user_id = socket.assigns.current_scope.user.id

    {:ok, _updated} = Gallery.approve_image(gallery_image, user_id)

    statistics = Gallery.get_statistics(socket.assigns.festival.id)

    {:noreply,
     socket
     |> stream_delete(:pending_images, gallery_image)
     |> assign(:statistics, statistics)
     |> put_flash(:info, "画像を承認しました")}
  end

  @impl true
  def handle_event("reject", %{"id" => id}, socket) do
    gallery_image = Gallery.get_gallery_image!(id)
    {:ok, _updated} = Gallery.reject_image(gallery_image)

    statistics = Gallery.get_statistics(socket.assigns.festival.id)

    {:noreply,
     socket
     |> stream_delete(:pending_images, gallery_image)
     |> assign(:statistics, statistics)
     |> put_flash(:info, "画像を却下しました")}
  end

  @impl true
  def handle_event("approve_all", _params, socket) do
    user_id = socket.assigns.current_scope.user.id
    {count, _} = Gallery.approve_all_pending(socket.assigns.festival.id, user_id)

    pending_images = Gallery.list_pending_images(socket.assigns.festival.id)
    statistics = Gallery.get_statistics(socket.assigns.festival.id)

    {:noreply,
     socket
     |> stream(:pending_images, pending_images, reset: true)
     |> assign(:statistics, statistics)
     |> put_flash(:info, "#{count}件の画像を一括承認しました")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <.header>
        画像審査
        <:subtitle>
          {@festival.name}の投稿画像を審査します
        </:subtitle>
        <:actions>
          <.button
            :if={@statistics.pending_count > 0}
            phx-click="approve_all"
            data-confirm="すべての審査待ち画像を承認しますか？"
            class="bg-green-600 hover:bg-green-700"
          >
            すべて承認 ({@statistics.pending_count})
          </.button>
          <.link navigate={~p"/festivals/#{@festival}/gallery"}>
            <.button class="bg-gray-200 text-gray-700 hover:bg-gray-300">ギャラリーへ戻る</.button>
          </.link>
        </:actions>
      </.header>

      <div class="grid grid-cols-3 gap-4">
        <div class="bg-yellow-50 rounded-lg p-4">
          <p class="text-sm text-gray-600">審査待ち</p>
          <p class="text-2xl font-bold text-yellow-600">{@statistics.pending_count}</p>
        </div>
        <div class="bg-green-50 rounded-lg p-4">
          <p class="text-sm text-gray-600">承認済</p>
          <p class="text-2xl font-bold text-green-600">{@statistics.approved_count}</p>
        </div>
        <div class="bg-red-50 rounded-lg p-4">
          <p class="text-sm text-gray-600">却下</p>
          <p class="text-2xl font-bold text-red-600">{@statistics.rejected_count}</p>
        </div>
      </div>

      <div :if={@statistics.pending_count == 0} class="text-center py-12 bg-gray-50 rounded-lg">
        <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <h3 class="mt-2 text-lg font-medium text-gray-900">審査待ちの画像はありません</h3>
        <p class="mt-1 text-sm text-gray-500">すべての画像が審査済みです</p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div
          :for={{id, gallery_image} <- @streams.pending_images}
          id={id}
          class="bg-white rounded-lg shadow overflow-hidden"
        >
          <div class="aspect-video bg-gray-100">
            <img
              src={gallery_image.thumbnail_url || gallery_image.image_url}
              alt={gallery_image.title || "審査待ち画像"}
              class="w-full h-full object-cover"
            />
          </div>

          <div class="p-4">
            <h3 class="font-medium">{gallery_image.title || "無題"}</h3>
            <p :if={gallery_image.description} class="text-sm text-gray-500 mt-1 line-clamp-2">
              {gallery_image.description}
            </p>

            <div class="mt-3 text-sm text-gray-500">
              <p>投稿者: {gallery_image.contributor_name || "匿名"}</p>
              <p>投稿日: {format_datetime(gallery_image.inserted_at)}</p>
            </div>

            <div class="mt-4 flex gap-2">
              <.button
                phx-click="approve"
                phx-value-id={gallery_image.id}
                class="flex-1 bg-green-600 hover:bg-green-700"
              >
                承認
              </.button>
              <.button
                phx-click="reject"
                phx-value-id={gallery_image.id}
                class="flex-1 bg-red-500 hover:bg-red-600"
              >
                却下
              </.button>
            </div>

            <div class="mt-2">
              <a
                href={gallery_image.image_url}
                target="_blank"
                class="text-sm text-blue-600 hover:underline"
              >
                フルサイズで確認 →
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%Y/%m/%d %H:%M")
  end
end
