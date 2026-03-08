defmodule MatsuriOpsWeb.GalleryLive.Index do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.Gallery
  alias MatsuriOps.Gallery.GalleryImage
  alias MatsuriOps.Festivals

  @impl true
  def mount(%{"festival_id" => festival_id}, _session, socket) do
    festival = Festivals.get_festival!(festival_id)
    gallery_images = Gallery.list_approved_images(festival_id)
    statistics = Gallery.get_statistics(festival_id)

    {:ok,
     socket
     |> assign(:festival, festival)
     |> assign(:page_title, "フォトギャラリー")
     |> assign(:statistics, statistics)
     |> assign(:filter_status, "approved")
     |> assign(:view_mode, "grid")
     |> stream(:gallery_images, gallery_images)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "画像を編集")
    |> assign(:gallery_image, Gallery.get_gallery_image!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "新しい画像を投稿")
    |> assign(:gallery_image, %GalleryImage{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "フォトギャラリー")
    |> assign(:gallery_image, nil)
  end

  @impl true
  def handle_event("filter", %{"status" => status}, socket) do
    festival_id = socket.assigns.festival.id

    gallery_images =
      if status == "all" do
        Gallery.list_gallery_images(festival_id)
      else
        Gallery.list_images_by_status(festival_id, status)
      end

    {:noreply,
     socket
     |> assign(:filter_status, status)
     |> stream(:gallery_images, gallery_images, reset: true)}
  end

  @impl true
  def handle_event("toggle_view", %{"mode" => mode}, socket) do
    {:noreply, assign(socket, :view_mode, mode)}
  end

  @impl true
  def handle_event("toggle_featured", %{"id" => id}, socket) do
    gallery_image = Gallery.get_gallery_image!(id)
    {:ok, updated} = Gallery.toggle_featured(gallery_image)

    {:noreply, stream_insert(socket, :gallery_images, updated)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    gallery_image = Gallery.get_gallery_image!(id)
    {:ok, _} = Gallery.delete_gallery_image(gallery_image)

    {:noreply, stream_delete(socket, :gallery_images, gallery_image)}
  end

  @impl true
  def handle_info({MatsuriOpsWeb.GalleryLive.FormComponent, {:saved, gallery_image}}, socket) do
    {:noreply, stream_insert(socket, :gallery_images, gallery_image)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <.header>
        フォトギャラリー
        <:subtitle>{@festival.name}の写真</:subtitle>
        <:actions>
          <.link patch={~p"/festivals/#{@festival}/gallery/new"}>
            <.button>写真を投稿</.button>
          </.link>
          <.link navigate={~p"/festivals/#{@festival}/gallery/moderation"}>
            <.button class="bg-orange-500 hover:bg-orange-600">
              審査 ({@statistics.pending_count})
            </.button>
          </.link>
          <.link navigate={~p"/festivals/#{@festival}"}>
            <.button class="bg-gray-200 text-gray-700 hover:bg-gray-300">祭り詳細へ</.button>
          </.link>
        </:actions>
      </.header>

      <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div class="bg-blue-50 rounded-lg p-4">
          <p class="text-sm text-gray-600">総画像数</p>
          <p class="text-2xl font-bold text-blue-600">{@statistics.total_count}</p>
        </div>
        <div class="bg-green-50 rounded-lg p-4">
          <p class="text-sm text-gray-600">承認済</p>
          <p class="text-2xl font-bold text-green-600">{@statistics.approved_count}</p>
        </div>
        <div class="bg-purple-50 rounded-lg p-4">
          <p class="text-sm text-gray-600">総いいね</p>
          <p class="text-2xl font-bold text-purple-600">{@statistics.total_likes}</p>
        </div>
        <div class="bg-orange-50 rounded-lg p-4">
          <p class="text-sm text-gray-600">総閲覧数</p>
          <p class="text-2xl font-bold text-orange-600">{@statistics.total_views}</p>
        </div>
      </div>

      <div class="flex justify-between items-center">
        <div class="flex gap-2">
          <.button
            phx-click="filter"
            phx-value-status="approved"
            class={if @filter_status == "approved", do: "bg-blue-600", else: "bg-gray-300 text-gray-700"}
          >
            承認済
          </.button>
          <.button
            phx-click="filter"
            phx-value-status="all"
            class={if @filter_status == "all", do: "bg-blue-600", else: "bg-gray-300 text-gray-700"}
          >
            すべて
          </.button>
        </div>

        <div class="flex gap-2">
          <button
            phx-click="toggle_view"
            phx-value-mode="grid"
            class={"p-2 rounded #{if @view_mode == "grid", do: "bg-blue-100 text-blue-600", else: "bg-gray-100"}"}
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z" />
            </svg>
          </button>
          <button
            phx-click="toggle_view"
            phx-value-mode="list"
            class={"p-2 rounded #{if @view_mode == "list", do: "bg-blue-100 text-blue-600", else: "bg-gray-100"}"}
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 10h16M4 14h16M4 18h16" />
            </svg>
          </button>
        </div>
      </div>

      <div :if={@view_mode == "grid"} class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
        <div
          :for={{id, gallery_image} <- @streams.gallery_images}
          id={id}
          class="relative group cursor-pointer"
          phx-click={JS.navigate(~p"/festivals/#{@festival}/gallery/#{gallery_image}")}
        >
          <div class="aspect-square bg-gray-100 rounded-lg overflow-hidden">
            <img
              src={gallery_image.thumbnail_url || gallery_image.image_url}
              alt={gallery_image.title || "ギャラリー画像"}
              class="w-full h-full object-cover transition-transform group-hover:scale-105"
            />
          </div>
          <div :if={gallery_image.featured} class="absolute top-2 left-2 bg-yellow-400 text-yellow-900 text-xs px-2 py-1 rounded">
            注目
          </div>
          <div class="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/60 to-transparent p-2 opacity-0 group-hover:opacity-100 transition-opacity">
            <p class="text-white text-sm truncate">{gallery_image.title || "無題"}</p>
            <div class="flex gap-2 text-white/80 text-xs">
              <span>{gallery_image.like_count} いいね</span>
              <span>{gallery_image.view_count} 閲覧</span>
            </div>
          </div>
        </div>
      </div>

      <.table
        :if={@view_mode == "list"}
        id="gallery_images"
        rows={@streams.gallery_images}
        row_click={fn {_id, gallery_image} -> JS.navigate(~p"/festivals/#{@festival}/gallery/#{gallery_image}") end}
      >
        <:col :let={{_id, gallery_image}} label="画像">
          <div class="w-16 h-16 bg-gray-100 rounded overflow-hidden">
            <img
              src={gallery_image.thumbnail_url || gallery_image.image_url}
              alt={gallery_image.title || "ギャラリー画像"}
              class="w-full h-full object-cover"
            />
          </div>
        </:col>
        <:col :let={{_id, gallery_image}} label="タイトル">{gallery_image.title || "無題"}</:col>
        <:col :let={{_id, gallery_image}} label="投稿者">{gallery_image.contributor_name || "-"}</:col>
        <:col :let={{_id, gallery_image}} label="ステータス">
          <span class={"px-2 py-1 text-xs rounded #{status_class(gallery_image.status)}"}>
            {GalleryImage.status_label(gallery_image.status)}
          </span>
        </:col>
        <:col :let={{_id, gallery_image}} label="いいね/閲覧">
          <span class="font-mono text-sm">{gallery_image.like_count} / {gallery_image.view_count}</span>
        </:col>
        <:action :let={{_id, gallery_image}}>
          <.link
            phx-click="toggle_featured"
            phx-value-id={gallery_image.id}
          >
            {if gallery_image.featured, do: "注目解除", else: "注目に設定"}
          </.link>
        </:action>
        <:action :let={{_id, gallery_image}}>
          <.link patch={~p"/festivals/#{@festival}/gallery/#{gallery_image}/edit"}>編集</.link>
        </:action>
        <:action :let={{id, gallery_image}}>
          <.link
            phx-click={JS.push("delete", value: %{id: gallery_image.id}) |> hide("##{id}")}
            data-confirm="本当に削除しますか？"
          >
            削除
          </.link>
        </:action>
      </.table>

      <.modal :if={@live_action in [:new, :edit]} id="gallery-image-modal" show on_cancel={JS.patch(~p"/festivals/#{@festival}/gallery")}>
        <.live_component
          module={MatsuriOpsWeb.GalleryLive.FormComponent}
          id={@gallery_image.id || :new}
          title={@page_title}
          action={@live_action}
          gallery_image={@gallery_image}
          festival={@festival}
          patch={~p"/festivals/#{@festival}/gallery"}
        />
      </.modal>
    </div>
    """
  end

  defp status_class("pending"), do: "bg-yellow-100 text-yellow-700"
  defp status_class("approved"), do: "bg-green-100 text-green-700"
  defp status_class("rejected"), do: "bg-red-100 text-red-700"
  defp status_class(_), do: "bg-gray-100 text-gray-500"
end
