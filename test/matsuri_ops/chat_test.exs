defmodule MatsuriOps.ChatTest do
  @moduledoc """
  チャット機能のテスト。

  TDDフェーズ: 🔴 RED → 🟢 GREEN
  """

  use MatsuriOps.DataCase

  alias MatsuriOps.Chat
  alias MatsuriOps.Festivals

  import MatsuriOps.AccountsFixtures

  defp create_festival(user) do
    {:ok, festival} =
      Festivals.create_festival(user, %{
        name: "テスト祭り",
        start_date: Date.new!(2025, 8, 1),
        end_date: Date.new!(2025, 8, 2),
        scale: "medium",
        status: "planning"
      })

    festival
  end

  describe "ChatRoom" do
    test "チャットルームを作成できる" do
      user = user_fixture()
      festival = create_festival(user)

      {:ok, room} =
        Chat.create_chat_room(%{
          festival_id: festival.id,
          name: "運営チャット",
          room_type: "general"
        })

      assert room.name == "運営チャット"
      assert room.room_type == "general"
      assert room.festival_id == festival.id
    end

    test "無効なルームタイプはエラーになる" do
      user = user_fixture()
      festival = create_festival(user)

      {:error, changeset} =
        Chat.create_chat_room(%{
          festival_id: festival.id,
          name: "テスト",
          room_type: "invalid_type"
        })

      assert "is invalid" in errors_on(changeset).room_type
    end

    test "祭りのチャットルーム一覧を取得できる" do
      user = user_fixture()
      festival = create_festival(user)

      {:ok, _room1} = Chat.create_chat_room(%{festival_id: festival.id, name: "運営", room_type: "general"})
      {:ok, _room2} = Chat.create_chat_room(%{festival_id: festival.id, name: "緊急", room_type: "emergency"})

      rooms = Chat.list_chat_rooms(festival.id)
      assert length(rooms) == 2
    end
  end

  describe "Message" do
    setup do
      user = user_fixture()
      festival = create_festival(user)
      {:ok, room} = Chat.create_chat_room(%{festival_id: festival.id, name: "テスト", room_type: "general"})
      %{user: user, festival: festival, room: room}
    end

    test "メッセージを送信できる", %{user: user, room: room} do
      {:ok, message} =
        Chat.create_message(%{
          chat_room_id: room.id,
          user_id: user.id,
          content: "こんにちは！"
        })

      assert message.content == "こんにちは！"
      assert message.user_id == user.id
      assert message.chat_room_id == room.id
    end

    test "空のメッセージは送信できない", %{user: user, room: room} do
      {:error, changeset} =
        Chat.create_message(%{
          chat_room_id: room.id,
          user_id: user.id,
          content: ""
        })

      assert "can't be blank" in errors_on(changeset).content
    end

    test "ルームのメッセージ一覧を取得できる", %{user: user, room: room} do
      {:ok, _msg1} = Chat.create_message(%{chat_room_id: room.id, user_id: user.id, content: "1つ目"})
      {:ok, _msg2} = Chat.create_message(%{chat_room_id: room.id, user_id: user.id, content: "2つ目"})

      messages = Chat.list_messages(room.id)
      assert length(messages) == 2
    end

    test "メッセージは時系列順で取得される", %{user: user, room: room} do
      {:ok, _msg1} = Chat.create_message(%{chat_room_id: room.id, user_id: user.id, content: "最初"})
      {:ok, _msg2} = Chat.create_message(%{chat_room_id: room.id, user_id: user.id, content: "次"})

      messages = Chat.list_messages(room.id)
      assert Enum.at(messages, 0).content == "最初"
      assert Enum.at(messages, 1).content == "次"
    end
  end

  describe "ReadStatus (既読管理)" do
    setup do
      user1 = user_fixture()
      user2 = user_fixture()
      festival = create_festival(user1)
      {:ok, room} = Chat.create_chat_room(%{festival_id: festival.id, name: "テスト", room_type: "general"})
      {:ok, message} = Chat.create_message(%{chat_room_id: room.id, user_id: user1.id, content: "テスト"})
      %{user1: user1, user2: user2, room: room, message: message}
    end

    test "メッセージを既読にできる", %{user2: user2, message: message} do
      {:ok, read_status} = Chat.mark_as_read(message.id, user2.id)

      assert read_status.message_id == message.id
      assert read_status.user_id == user2.id
      assert read_status.read_at
    end

    test "未読メッセージ数を取得できる", %{user1: user1, user2: user2, room: room} do
      {:ok, _msg2} = Chat.create_message(%{chat_room_id: room.id, user_id: user1.id, content: "2つ目"})
      {:ok, _msg3} = Chat.create_message(%{chat_room_id: room.id, user_id: user1.id, content: "3つ目"})

      unread_count = Chat.unread_count(room.id, user2.id)
      assert unread_count == 3
    end

    test "既読後は未読数が減る", %{user1: user1, user2: user2, room: room, message: message} do
      Chat.mark_as_read(message.id, user2.id)

      {:ok, msg2} = Chat.create_message(%{chat_room_id: room.id, user_id: user1.id, content: "2つ目"})
      Chat.mark_as_read(msg2.id, user2.id)

      unread_count = Chat.unread_count(room.id, user2.id)
      assert unread_count == 0
    end
  end

  describe "broadcast (リアルタイム通知)" do
    setup do
      user = user_fixture()
      festival = create_festival(user)
      {:ok, room} = Chat.create_chat_room(%{festival_id: festival.id, name: "テスト", room_type: "general"})
      %{user: user, room: room}
    end

    test "メッセージ送信時にPubSubでブロードキャストされる", %{user: user, room: room} do
      Chat.subscribe(room.id)

      {:ok, message} = Chat.create_message(%{chat_room_id: room.id, user_id: user.id, content: "テスト"})

      assert_receive {:new_message, ^message}
    end
  end
end
