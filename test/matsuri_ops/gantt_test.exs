defmodule MatsuriOps.GanttTest do
  @moduledoc """
  ガントチャート機能のテスト。

  TDDフェーズ: 🔴 RED → 🟢 GREEN
  """

  use MatsuriOps.DataCase

  alias MatsuriOps.Gantt
  alias MatsuriOps.Tasks
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

  defp create_task(festival, attrs) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        title: "テストタスク#{System.unique_integer()}",
        festival_id: festival.id
      })
      |> Tasks.create_task()

    task
  end

  describe "gantt chart data conversion" do
    setup do
      user = user_fixture()
      festival = create_festival(user)
      %{user: user, festival: festival}
    end

    test "convert_tasks_to_gantt_data/1 converts tasks to gantt format", %{festival: festival} do
      task = create_task(festival, %{
        title: "会場設営",
        start_date: ~D[2025-07-28],
        due_date: ~D[2025-07-30],
        status: "in_progress",
        progress_percent: 50
      })

      [gantt_item] = Gantt.convert_tasks_to_gantt_data([task])

      assert gantt_item.id == task.id
      assert gantt_item.name == "会場設営"
      assert gantt_item.start == ~D[2025-07-28]
      assert gantt_item.end == ~D[2025-07-30]
      assert gantt_item.progress == 50
    end

    test "convert_tasks_to_gantt_data/1 handles tasks without dates", %{festival: festival} do
      task = create_task(festival, %{
        title: "日程未定タスク",
        start_date: nil,
        due_date: nil
      })

      data = Gantt.convert_tasks_to_gantt_data([task])
      assert data == []
    end

    test "get_gantt_data/1 returns formatted gantt data for festival", %{festival: festival} do
      _task1 = create_task(festival, %{
        title: "タスク1",
        start_date: ~D[2025-07-28],
        due_date: ~D[2025-07-30]
      })
      _task2 = create_task(festival, %{
        title: "タスク2",
        start_date: ~D[2025-07-29],
        due_date: ~D[2025-08-01]
      })

      data = Gantt.get_gantt_data(festival.id)
      assert length(data) == 2
    end
  end

  describe "dependency calculations" do
    setup do
      user = user_fixture()
      festival = create_festival(user)
      %{user: user, festival: festival}
    end

    test "calculate_critical_path/1 identifies tasks with no slack", %{festival: festival} do
      _task1 = create_task(festival, %{
        title: "準備",
        start_date: ~D[2025-07-28],
        due_date: ~D[2025-07-29]
      })
      task2 = create_task(festival, %{
        title: "実施",
        start_date: ~D[2025-07-29],
        due_date: ~D[2025-07-30]
      })

      critical_tasks = Gantt.calculate_critical_path(festival.id)
      assert is_list(critical_tasks)
      # The task with the latest due date should be on critical path
      assert Enum.any?(critical_tasks, fn t -> t.id == task2.id end)
    end

    test "get_task_dependencies/1 returns task dependencies", %{festival: festival} do
      task1 = create_task(festival, %{
        title: "前提タスク",
        start_date: ~D[2025-07-28],
        due_date: ~D[2025-07-29]
      })
      task2 = create_task(festival, %{
        title: "依存タスク",
        start_date: ~D[2025-07-29],
        due_date: ~D[2025-07-30]
      })

      # Create dependency
      {:ok, _} = Tasks.create_task_dependency(%{
        successor_id: task2.id,
        predecessor_id: task1.id,
        dependency_type: "finish_to_start"
      })

      deps = Gantt.get_task_dependencies(festival.id)
      assert length(deps) == 1
      assert hd(deps).from == task1.id
      assert hd(deps).to == task2.id
    end
  end

  describe "timeline calculations" do
    setup do
      user = user_fixture()
      festival = create_festival(user)
      %{user: user, festival: festival}
    end

    test "calculate_timeline_range/1 returns the date range", %{festival: festival} do
      _task1 = create_task(festival, %{
        title: "最初のタスク",
        start_date: ~D[2025-07-20],
        due_date: ~D[2025-07-25]
      })
      _task2 = create_task(festival, %{
        title: "最後のタスク",
        start_date: ~D[2025-08-01],
        due_date: ~D[2025-08-05]
      })

      {start_date, end_date} = Gantt.calculate_timeline_range(festival.id)

      assert start_date == ~D[2025-07-20]
      assert end_date == ~D[2025-08-05]
    end

    test "calculate_timeline_range/1 returns nil for no tasks", %{festival: festival} do
      assert Gantt.calculate_timeline_range(festival.id) == nil
    end
  end
end
