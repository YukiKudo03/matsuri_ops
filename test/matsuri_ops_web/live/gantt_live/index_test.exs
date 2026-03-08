defmodule MatsuriOpsWeb.GanttLive.IndexTest do
  use MatsuriOpsWeb.ConnCase

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures

  alias MatsuriOps.Festivals
  alias MatsuriOps.Tasks

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

  defp create_task(festival, attrs) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        title: "テストタスク",
        festival_id: festival.id
      })
      |> Tasks.create_task()

    task
  end

  describe "Index" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = create_festival(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "displays gantt chart with tasks", %{conn: conn, festival: festival} do
      _task = create_task(festival, %{
        title: "会場設営",
        start_date: ~D[2025-07-28],
        due_date: ~D[2025-07-30]
      })

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival.id}/gantt")

      assert html =~ "ガントチャート"
      assert html =~ "会場設営"
    end

    test "shows empty state when no tasks with dates", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival.id}/gantt")

      assert html =~ "表示するタスクがありません"
    end

    test "displays legend", %{conn: conn, festival: festival} do
      _task = create_task(festival, %{
        title: "タスク",
        start_date: ~D[2025-07-28],
        due_date: ~D[2025-07-30]
      })

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival.id}/gantt")

      assert html =~ "未着手"
      assert html =~ "進行中"
      assert html =~ "完了"
    end
  end
end
