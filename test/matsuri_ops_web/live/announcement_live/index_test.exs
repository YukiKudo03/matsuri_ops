defmodule MatsuriOpsWeb.AnnouncementLive.IndexTest do
  use MatsuriOpsWeb.ConnCase

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures

  alias MatsuriOps.Festivals
  alias MatsuriOps.Notifications

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

  defp create_announcement(festival, user, attrs \\ %{}) do
    {:ok, announcement} =
      attrs
      |> Enum.into(%{
        title: "テストお知らせ",
        content: "テスト内容",
        priority: "normal",
        target_audience: "all",
        festival_id: festival.id,
        created_by_id: user.id
      })
      |> Notifications.create_announcement()

    announcement
  end

  describe "Index" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = create_festival(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "lists all announcements for festival", %{conn: conn, festival: festival, user: user} do
      announcement = create_announcement(festival, user, %{title: "重要なお知らせ"})
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival.id}/announcements")

      assert html =~ "お知らせ"
      assert html =~ announcement.title
    end

    test "shows empty state when no announcements", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival.id}/announcements")

      assert html =~ "お知らせがありません"
    end

    test "can create new announcement", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival.id}/announcements/new")

      assert render(view) =~ "新しいお知らせ"
    end
  end
end
