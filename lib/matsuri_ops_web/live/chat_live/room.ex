defmodule MatsuriOpsWeb.ChatLive.Room do
  @moduledoc """
  チャットルーム内のメッセージを表示・送信するLiveView。
  """

  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.Festivals
  alias MatsuriOps.Chat
  alias MatsuriOps.Chat.Message

  @impl true
  def mount(%{"festival_id" => festival_id, "id" => room_id}, _session, socket) do
    festival = Festivals.get_festival!(festival_id)
    room = Chat.get_chat_room!(room_id)
    messages = Chat.list_messages(room_id)
    current_user = socket.assigns.current_scope.user

    if connected?(socket) do
      Chat.subscribe(room_id)
      Chat.mark_room_as_read(room_id, current_user.id)
    end

    {:ok,
     socket
     |> assign(:page_title, room.name)
     |> assign(:festival, festival)
     |> assign(:room, room)
     |> assign(:current_user, current_user)
     |> assign(:message_form, to_form(Chat.change_message(%Message{})))
     |> stream(:messages, messages)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"message" => message_params}, socket) do
    changeset = Chat.change_message(%Message{}, message_params)
    {:noreply, assign(socket, :message_form, to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("send", %{"message" => message_params}, socket) do
    message_params =
      message_params
      |> Map.put("chat_room_id", socket.assigns.room.id)
      |> Map.put("user_id", socket.assigns.current_user.id)

    case Chat.create_message(message_params) do
      {:ok, _message} ->
        {:noreply,
         socket
         |> assign(:message_form, to_form(Chat.change_message(%Message{})))
         |> push_event("scroll_to_bottom", %{})}

      {:error, changeset} ->
        {:noreply, assign(socket, :message_form, to_form(changeset))}
    end
  end

  @impl true
  def handle_info({:new_message, message}, socket) do
    Chat.mark_as_read(message.id, socket.assigns.current_user.id)

    {:noreply,
     socket
     |> stream_insert(:messages, message)
     |> push_event("scroll_to_bottom", %{})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      {@room.name}
      <:subtitle>{room_type_label(@room.room_type)}</:subtitle>
      <:actions>
        <.link navigate={~p"/festivals/#{@festival}/chat"}>
          <.button variant="outline">ルーム一覧へ</.button>
        </.link>
      </:actions>
    </.header>

    <div class="mt-4 flex flex-col h-[60vh]">
      <div
        id="messages"
        class="flex-1 overflow-y-auto p-4 space-y-3 bg-base-200 rounded-lg"
        phx-hook="ScrollToBottom"
      >
        <.message_bubble
          :for={{dom_id, message} <- @streams.messages}
          message={message}
          current_user={@current_user}
          id={dom_id}
        />
      </div>

      <.simple_form
        for={@message_form}
        id="message-form"
        phx-change="validate"
        phx-submit="send"
        class="mt-4"
      >
        <div class="flex gap-2">
          <div class="flex-1">
            <.input
              field={@message_form[:content]}
              type="text"
              placeholder="メッセージを入力..."
              autocomplete="off"
            />
          </div>
          <.button type="submit" class="mt-2">送信</.button>
        </div>
      </.simple_form>
    </div>

    <.back navigate={~p"/festivals/#{@festival}/chat"}>ルーム一覧へ戻る</.back>
    """
  end

  defp message_bubble(assigns) do
    is_own_message = assigns.message.user_id == assigns.current_user.id
    assigns = assign(assigns, :is_own_message, is_own_message)

    ~H"""
    <div
      id={@id}
      class={[
        "flex",
        @is_own_message && "justify-end",
        !@is_own_message && "justify-start"
      ]}
    >
      <div class={[
        "max-w-[70%] rounded-lg p-3",
        @is_own_message && "bg-primary text-primary-content",
        !@is_own_message && "bg-base-100"
      ]}>
        <p :if={!@is_own_message} class="text-xs font-semibold mb-1">
          {@message.user.name || @message.user.email}
        </p>
        <p class="whitespace-pre-wrap">{@message.content}</p>
        <p class={[
          "text-xs mt-1",
          @is_own_message && "text-primary-content/70",
          !@is_own_message && "text-gray-500"
        ]}>
          {format_time(@message.inserted_at)}
        </p>
      </div>
    </div>
    """
  end

  defp format_time(datetime) do
    Calendar.strftime(datetime, "%H:%M")
  end

  defp room_type_label(room_type) do
    case room_type do
      "general" -> "一般チャット"
      "emergency" -> "緊急連絡"
      "staff" -> "スタッフ専用"
      "vendor" -> "出店者向け"
      _ -> room_type
    end
  end
end
