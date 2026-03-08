defmodule MatsuriOpsWeb.AnnouncementLive.Index do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.Notifications
  alias MatsuriOps.Notifications.Announcement
  alias MatsuriOps.Festivals

  @impl true
  def mount(%{"festival_id" => festival_id}, _session, socket) do
    festival = Festivals.get_festival!(festival_id)

    if connected?(socket) do
      Notifications.subscribe_announcements(festival_id)
    end

    announcements = Notifications.list_announcements(festival_id)

    {:ok,
     socket
     |> assign(:festival, festival)
     |> assign(:page_title, "お知らせ")
     |> assign(:has_announcements, length(announcements) > 0)
     |> stream(:announcements, announcements)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "お知らせを編集")
    |> assign(:announcement, Notifications.get_announcement!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "新しいお知らせ")
    |> assign(:announcement, %Announcement{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "お知らせ")
    |> assign(:announcement, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    announcement = Notifications.get_announcement!(id)
    {:ok, _} = Notifications.delete_announcement(announcement)

    {:noreply, stream_delete(socket, :announcements, announcement)}
  end

  @impl true
  def handle_info({MatsuriOpsWeb.AnnouncementLive.FormComponent, {:saved, announcement}}, socket) do
    {:noreply,
     socket
     |> assign(:has_announcements, true)
     |> stream_insert(socket, :announcements, announcement)}
  end

  def handle_info({:new_announcement, announcement}, socket) do
    {:noreply,
     socket
     |> assign(:has_announcements, true)
     |> stream_insert(:announcements, announcement, at: 0)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <.header>
        お知らせ
        <:subtitle>{@festival.name}のお知らせ</:subtitle>
        <:actions>
          <.link patch={~p"/festivals/#{@festival}/announcements/new"}>
            <.button>新規お知らせ</.button>
          </.link>
        </:actions>
      </.header>

      <div :if={not @has_announcements} class="text-center py-8 text-gray-500">
        お知らせがありません
      </div>

      <div :if={@has_announcements} class="space-y-4" id="announcements" phx-update="stream">
        <div
          :for={{dom_id, announcement} <- @streams.announcements}
          id={dom_id}
          class={"rounded-lg p-4 shadow #{priority_class(announcement.priority)}"}
        >
          <div class="flex justify-between items-start">
            <div>
              <div class="flex items-center gap-2">
                <span class={"px-2 py-1 text-xs rounded #{priority_badge(announcement.priority)}"}>
                  {format_priority(announcement.priority)}
                </span>
                <h3 class="font-medium">{announcement.title}</h3>
              </div>
              <p class="mt-2 text-gray-600">{announcement.content}</p>
              <p class="mt-2 text-sm text-gray-400">
                {format_date(announcement.inserted_at)}
              </p>
            </div>
            <div class="flex gap-2">
              <.link patch={~p"/festivals/#{@festival}/announcements/#{announcement}/edit"}>
                <.button class="text-sm">編集</.button>
              </.link>
              <.button
                class="text-sm"
                phx-click="delete"
                phx-value-id={announcement.id}
                data-confirm="本当に削除しますか？"
              >
                削除
              </.button>
            </div>
          </div>
        </div>
      </div>

      <.modal :if={@live_action in [:new, :edit]} id="announcement-modal" show on_cancel={JS.patch(~p"/festivals/#{@festival}/announcements")}>
        <.live_component
          module={MatsuriOpsWeb.AnnouncementLive.FormComponent}
          id={@announcement.id || :new}
          title={@page_title}
          action={@live_action}
          announcement={@announcement}
          festival={@festival}
          current_user={@current_scope.user}
          patch={~p"/festivals/#{@festival}/announcements"}
        />
      </.modal>
    </div>
    """
  end

  defp priority_class("urgent"), do: "bg-red-50 border-l-4 border-red-500"
  defp priority_class("high"), do: "bg-orange-50 border-l-4 border-orange-500"
  defp priority_class("normal"), do: "bg-white border"
  defp priority_class(_), do: "bg-gray-50 border"

  defp priority_badge("urgent"), do: "bg-red-100 text-red-800"
  defp priority_badge("high"), do: "bg-orange-100 text-orange-800"
  defp priority_badge("normal"), do: "bg-blue-100 text-blue-800"
  defp priority_badge(_), do: "bg-gray-100 text-gray-800"

  defp format_priority("urgent"), do: "緊急"
  defp format_priority("high"), do: "重要"
  defp format_priority("normal"), do: "通常"
  defp format_priority(_), do: "低"

  defp format_date(datetime) do
    Calendar.strftime(datetime, "%Y/%m/%d %H:%M")
  end
end
