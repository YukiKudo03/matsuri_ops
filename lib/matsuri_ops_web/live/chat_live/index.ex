defmodule MatsuriOpsWeb.ChatLive.Index do
  @moduledoc """
  チャットルーム一覧を表示するLiveView。
  """

  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.Festivals
  alias MatsuriOps.Chat
  alias MatsuriOps.Chat.ChatRoom

  @impl true
  def mount(%{"festival_id" => festival_id}, _session, socket) do
    festival = Festivals.get_festival!(festival_id)
    rooms = Chat.list_chat_rooms(festival_id)

    {:ok,
     socket
     |> assign(:page_title, "チャット - #{festival.name}")
     |> assign(:festival, festival)
     |> stream(:rooms, rooms)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "ルーム作成")
    |> assign(:chat_room, %ChatRoom{festival_id: socket.assigns.festival.id})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "ルーム編集")
    |> assign(:chat_room, Chat.get_chat_room!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "チャット - #{socket.assigns.festival.name}")
    |> assign(:chat_room, nil)
  end

  @impl true
  def handle_info({MatsuriOpsWeb.ChatLive.FormComponent, {:saved, room}}, socket) do
    {:noreply, stream_insert(socket, :rooms, room)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    room = Chat.get_chat_room!(id)
    {:ok, _} = Chat.delete_chat_room(room)

    {:noreply, stream_delete(socket, :rooms, room)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      {@festival.name} - チャット
      <:actions>
        <.link patch={~p"/festivals/#{@festival}/chat/new"}>
          <.button>ルーム作成</.button>
        </.link>
        <.link navigate={~p"/festivals/#{@festival}"}>
          <.button variant="outline">祭り詳細へ</.button>
        </.link>
      </:actions>
    </.header>

    <div class="mt-6 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <.room_card :for={{dom_id, room} <- @streams.rooms} room={room} festival={@festival} id={dom_id} />
    </div>

    <.back navigate={~p"/festivals/#{@festival}"}>祭り詳細へ戻る</.back>

    <.modal :if={@live_action in [:new, :edit]} id="room-modal" show on_cancel={JS.patch(~p"/festivals/#{@festival}/chat")}>
      <.live_component
        module={MatsuriOpsWeb.ChatLive.FormComponent}
        id={@chat_room.id || :new}
        title={@page_title}
        action={@live_action}
        chat_room={@chat_room}
        festival={@festival}
        patch={~p"/festivals/#{@festival}/chat"}
      />
    </.modal>
    """
  end

  defp room_card(assigns) do
    ~H"""
    <.link
      navigate={~p"/festivals/#{@festival}/chat/#{@room}"}
      class="block p-4 bg-base-200 rounded-lg hover:bg-base-300 transition"
      id={@id}
    >
      <div class="flex items-center justify-between">
        <div>
          <h3 class="font-semibold">{@room.name}</h3>
          <p class="text-sm text-gray-500">{room_type_label(@room.room_type)}</p>
        </div>
        <.room_type_icon room_type={@room.room_type} />
      </div>
    </.link>
    """
  end

  defp room_type_icon(assigns) do
    icon_class = case assigns.room_type do
      "emergency" -> "text-red-500"
      "staff" -> "text-blue-500"
      "vendor" -> "text-yellow-500"
      _ -> "text-gray-500"
    end

    assigns = assign(assigns, :icon_class, icon_class)

    ~H"""
    <span class={"text-xl #{@icon_class}"}>
      <%= case @room_type do %>
        <% "emergency" -> %>💨
        <% "staff" -> %>👥
        <% "vendor" -> %>🏪
        <% _ -> %>💬
      <% end %>
    </span>
    """
  end

  defp room_type_label(room_type) do
    case room_type do
      "general" -> "一般"
      "emergency" -> "緊急"
      "staff" -> "スタッフ"
      "vendor" -> "出店者"
      _ -> room_type
    end
  end
end
