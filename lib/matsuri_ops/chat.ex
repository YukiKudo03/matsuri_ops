defmodule MatsuriOps.Chat do
  @moduledoc """
  チャット機能を提供するコンテキスト。

  チャットルーム管理、メッセージ送受信、既読管理、リアルタイム通知を行う。
  """

  import Ecto.Query
  alias MatsuriOps.Repo
  alias MatsuriOps.Chat.{ChatRoom, Message, ReadStatus}

  @pubsub MatsuriOps.PubSub

  ## ChatRoom

  def list_chat_rooms(festival_id) do
    ChatRoom
    |> where([r], r.festival_id == ^festival_id)
    |> order_by([r], asc: r.name)
    |> Repo.all()
  end

  def get_chat_room!(id), do: Repo.get!(ChatRoom, id)

  def create_chat_room(attrs \\ %{}) do
    %ChatRoom{}
    |> ChatRoom.changeset(attrs)
    |> Repo.insert()
  end

  def update_chat_room(%ChatRoom{} = chat_room, attrs) do
    chat_room
    |> ChatRoom.changeset(attrs)
    |> Repo.update()
  end

  def delete_chat_room(%ChatRoom{} = chat_room) do
    Repo.delete(chat_room)
  end

  ## Message

  def list_messages(chat_room_id, opts \\ []) do
    limit = Keyword.get(opts, :limit, 100)

    Message
    |> where([m], m.chat_room_id == ^chat_room_id)
    |> order_by([m], asc: m.inserted_at)
    |> limit(^limit)
    |> preload(:user)
    |> Repo.all()
  end

  def get_message!(id), do: Repo.get!(Message, id)

  def create_message(attrs \\ %{}) do
    result =
      %Message{}
      |> Message.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, message} ->
        message = Repo.preload(message, :user)
        broadcast_message(message)
        {:ok, message}

      error ->
        error
    end
  end

  ## ReadStatus

  def mark_as_read(message_id, user_id) do
    attrs = %{
      message_id: message_id,
      user_id: user_id,
      read_at: DateTime.utc_now()
    }

    %ReadStatus{}
    |> ReadStatus.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing)
  end

  def mark_room_as_read(chat_room_id, user_id) do
    messages = list_messages(chat_room_id)

    Enum.each(messages, fn message ->
      mark_as_read(message.id, user_id)
    end)

    :ok
  end

  def unread_count(chat_room_id, user_id) do
    read_message_ids =
      ReadStatus
      |> where([rs], rs.user_id == ^user_id)
      |> select([rs], rs.message_id)

    Message
    |> where([m], m.chat_room_id == ^chat_room_id)
    |> where([m], m.id not in subquery(read_message_ids))
    |> where([m], m.user_id != ^user_id)
    |> Repo.aggregate(:count)
  end

  ## PubSub

  def subscribe(chat_room_id) do
    Phoenix.PubSub.subscribe(@pubsub, topic(chat_room_id))
  end

  def unsubscribe(chat_room_id) do
    Phoenix.PubSub.unsubscribe(@pubsub, topic(chat_room_id))
  end

  defp broadcast_message(message) do
    Phoenix.PubSub.broadcast(@pubsub, topic(message.chat_room_id), {:new_message, message})
  end

  defp topic(chat_room_id), do: "chat_room:#{chat_room_id}"

  ## Changeset

  def change_chat_room(%ChatRoom{} = chat_room, attrs \\ %{}) do
    ChatRoom.changeset(chat_room, attrs)
  end

  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end
end
