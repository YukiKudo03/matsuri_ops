defmodule MatsuriOpsWeb.ChatLive.IndexTest do
  use MatsuriOpsWeb.ConnCase

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures

  alias MatsuriOps.Festivals
  alias MatsuriOps.Chat

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

  describe "チャット一覧ページ" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = create_festival(user)
      {:ok, room} = Chat.create_chat_room(%{festival_id: festival.id, name: "運営チャット", room_type: "general"})
      %{conn: log_in_user(conn, user), user: user, festival: festival, room: room}
    end

    test "チャットルーム一覧を表示できる", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/chat")

      assert html =~ "チャット"
      assert html =~ "運営チャット"
    end

    test "チャットルームを作成できる", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/chat")

      view
      |> element("a", "ルーム作成")
      |> render_click()

      assert_patch(view, ~p"/festivals/#{festival}/chat/new")

      view
      |> form("#room-form", chat_room: %{name: "緊急連絡", room_type: "emergency"})
      |> render_submit()

      html = render(view)
      assert html =~ "緊急連絡"
    end
  end

  describe "チャットルームページ" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = create_festival(user)
      {:ok, room} = Chat.create_chat_room(%{festival_id: festival.id, name: "運営チャット", room_type: "general"})
      %{conn: log_in_user(conn, user), user: user, festival: festival, room: room}
    end

    test "チャットルームを表示できる", %{conn: conn, festival: festival, room: room} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/chat/#{room}")

      assert html =~ "運営チャット"
    end

    test "メッセージを送信できる", %{conn: conn, festival: festival, room: room} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/chat/#{room}")

      view
      |> form("#message-form", message: %{content: "こんにちは！"})
      |> render_submit()

      html = render(view)
      assert html =~ "こんにちは！"
    end

    test "他のユーザーのメッセージが表示される", %{conn: conn, festival: festival, room: room, user: user} do
      {:ok, _msg} = Chat.create_message(%{chat_room_id: room.id, user_id: user.id, content: "最初のメッセージ"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/chat/#{room}")

      assert html =~ "最初のメッセージ"
    end
  end
end
