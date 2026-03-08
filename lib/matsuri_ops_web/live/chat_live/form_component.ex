defmodule MatsuriOpsWeb.ChatLive.FormComponent do
  @moduledoc """
  チャットルーム作成・編集用のフォームコンポーネント。
  """

  use MatsuriOpsWeb, :live_component

  alias MatsuriOps.Chat

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.simple_form
        for={@form}
        id="room-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="ルーム名" />
        <.input
          field={@form[:room_type]}
          type="select"
          label="ルームタイプ"
          options={[
            {"一般", "general"},
            {"緊急連絡", "emergency"},
            {"スタッフ", "staff"},
            {"出店者", "vendor"}
          ]}
        />
        <.input field={@form[:description]} type="textarea" label="説明" />

        <:actions>
          <.button phx-disable-with="保存中...">保存</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{chat_room: chat_room} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Chat.change_chat_room(chat_room))
     end)}
  end

  @impl true
  def handle_event("validate", %{"chat_room" => room_params}, socket) do
    changeset = Chat.change_chat_room(socket.assigns.chat_room, room_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"chat_room" => room_params}, socket) do
    save_room(socket, socket.assigns.action, room_params)
  end

  defp save_room(socket, :edit, room_params) do
    case Chat.update_chat_room(socket.assigns.chat_room, room_params) do
      {:ok, room} ->
        notify_parent({:saved, room})

        {:noreply,
         socket
         |> put_flash(:info, "ルームを更新しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_room(socket, :new, room_params) do
    room_params = Map.put(room_params, "festival_id", socket.assigns.festival.id)

    case Chat.create_chat_room(room_params) do
      {:ok, room} ->
        notify_parent({:saved, room})

        {:noreply,
         socket
         |> put_flash(:info, "ルームを作成しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
