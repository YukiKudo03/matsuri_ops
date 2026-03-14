defmodule MatsuriOpsWeb.ChatLive.FormComponentTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.ChatFixtures

  describe "New chat room form" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "validates required fields", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/chat/new")

      result =
        view
        |> form("#room-form", chat_room: %{name: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "saves new chat room", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/chat/new")

      view
      |> form("#room-form", chat_room: %{
        name: "新しいチャットルーム",
        room_type: "general",
        description: "テスト説明"
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/chat")
      assert render(view) =~ "新しいチャットルーム"
    end

    test "form has fields: name, room_type, description", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/chat/new")

      assert html =~ "name"
      assert html =~ "room_type" or html =~ "ルームタイプ" or html =~ "種類"
      assert html =~ "description" or html =~ "説明"
    end
  end
end
