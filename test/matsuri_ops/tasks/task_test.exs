defmodule MatsuriOps.Tasks.TaskTest do
  use MatsuriOps.DataCase, async: true

  alias MatsuriOps.Tasks.Task

  describe "changeset/2" do
    test "valid changeset with required fields" do
      changeset = Task.changeset(%Task{}, %{
        title: "テストタスク",
        festival_id: 1
      })

      assert changeset.valid?
    end

    test "invalid changeset without title" do
      changeset = Task.changeset(%Task{}, %{festival_id: 1})
      refute changeset.valid?
      assert %{title: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset without festival_id" do
      changeset = Task.changeset(%Task{}, %{title: "タスク"})
      refute changeset.valid?
      assert %{festival_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset with invalid status" do
      changeset = Task.changeset(%Task{}, %{
        title: "タスク",
        festival_id: 1,
        status: "invalid"
      })

      refute changeset.valid?
      assert %{status: ["is invalid"]} = errors_on(changeset)
    end

    test "invalid changeset with invalid priority" do
      changeset = Task.changeset(%Task{}, %{
        title: "タスク",
        festival_id: 1,
        priority: "invalid"
      })

      refute changeset.valid?
      assert %{priority: ["is invalid"]} = errors_on(changeset)
    end

    test "invalid changeset with progress_percent out of range" do
      changeset = Task.changeset(%Task{}, %{
        title: "タスク",
        festival_id: 1,
        progress_percent: 101
      })

      refute changeset.valid?
    end

    test "invalid changeset with negative progress_percent" do
      changeset = Task.changeset(%Task{}, %{
        title: "タスク",
        festival_id: 1,
        progress_percent: -1
      })

      refute changeset.valid?
    end

    test "valid changeset with all optional fields" do
      changeset = Task.changeset(%Task{}, %{
        title: "テストタスク",
        description: "説明文",
        status: "in_progress",
        priority: "high",
        due_date: ~D[2026-08-20],
        start_date: ~D[2026-08-15],
        estimated_hours: Decimal.new("5.0"),
        actual_hours: Decimal.new("3.5"),
        progress_percent: 50,
        is_milestone: true,
        sort_order: 1,
        festival_id: 1
      })

      assert changeset.valid?
    end
  end

  describe "statuses/0" do
    test "returns all valid statuses" do
      statuses = Task.statuses()
      assert "pending" in statuses
      assert "in_progress" in statuses
      assert "completed" in statuses
      assert "cancelled" in statuses
      assert "blocked" in statuses
    end
  end

  describe "priorities/0" do
    test "returns all valid priorities" do
      priorities = Task.priorities()
      assert "low" in priorities
      assert "medium" in priorities
      assert "high" in priorities
      assert "urgent" in priorities
    end
  end
end
