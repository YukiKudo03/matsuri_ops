defmodule MatsuriOpsWeb.ShiftLive.IndexTest do
  use MatsuriOpsWeb.ConnCase

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures

  alias MatsuriOps.Festivals
  alias MatsuriOps.Shifts

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

  defp create_shift(festival, attrs \\ %{}) do
    {:ok, shift} =
      attrs
      |> Enum.into(%{
        name: "テストシフト",
        start_time: ~U[2025-08-01 09:00:00Z],
        end_time: ~U[2025-08-01 13:00:00Z],
        location: "正門",
        required_staff: 3,
        festival_id: festival.id
      })
      |> Shifts.create_shift()

    shift
  end

  describe "Index" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = create_festival(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "lists all shifts for festival", %{conn: conn, festival: festival} do
      shift = create_shift(festival, %{name: "朝シフト"})
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival.id}/shifts")

      assert html =~ "シフト管理"
      assert html =~ shift.name
    end

    test "shows empty state when no shifts", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival.id}/shifts")

      assert html =~ "シフトがありません"
    end

    test "displays shift time and location", %{conn: conn, festival: festival} do
      _shift = create_shift(festival, %{name: "朝シフト", location: "正門"})
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival.id}/shifts")

      assert html =~ "正門"
    end
  end
end
