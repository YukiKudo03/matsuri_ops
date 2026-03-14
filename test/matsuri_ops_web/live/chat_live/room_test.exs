defmodule MatsuriOpsWeb.ChatLive.RoomTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.ChatFixtures

  describe "Room page" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      chat_room = chat_room_fixture(festival)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, chat_room: chat_room}
    end

    test "renders chat room page", %{conn: conn, festival: festival, chat_room: chat_room} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/chat/#{chat_room}")

      assert html =~ chat_room.name
    end

    test "redirects if not logged in", %{festival: festival, chat_room: chat_room} do
      conn = build_conn()
      assert {:error, redirect} = live(conn, ~p"/festivals/#{festival}/chat/#{chat_room}")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays room name", %{conn: conn, festival: festival, chat_room: chat_room} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/chat/#{chat_room}")

      assert html =~ chat_room.name
    end

    test "can send message", %{conn: conn, festival: festival, chat_room: chat_room} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/chat/#{chat_room}")

      view
      |> form("#message-form", message: %{content: "こんにちは"})
      |> render_submit()

      html = render(view)
      assert html =~ "こんにちは"
    end

    test "displays messages in stream", %{conn: conn, user: user, festival: festival, chat_room: chat_room} do
      message = message_fixture(chat_room, user, %{content: "ストリームテストメッセージ"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/chat/#{chat_room}")

      assert html =~ "ストリームテストメッセージ"
    end
  end
end
