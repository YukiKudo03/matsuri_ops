defmodule MatsuriOps.ChatFixtures do
  @moduledoc """
  Test fixtures for Chat context.
  """

  alias MatsuriOps.Chat

  def valid_chat_room_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: "テストチャットルーム#{System.unique_integer([:positive])}",
      room_type: "general"
    })
  end

  def chat_room_fixture(festival, attrs \\ %{}) do
    attrs =
      attrs
      |> valid_chat_room_attributes()
      |> Map.put(:festival_id, festival.id)

    {:ok, chat_room} = Chat.create_chat_room(attrs)
    chat_room
  end

  def valid_message_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      content: "テストメッセージ#{System.unique_integer([:positive])}"
    })
  end

  def message_fixture(chat_room, user, attrs \\ %{}) do
    attrs =
      attrs
      |> valid_message_attributes()
      |> Map.put(:chat_room_id, chat_room.id)
      |> Map.put(:user_id, user.id)

    {:ok, message} = Chat.create_message(attrs)
    message
  end
end
