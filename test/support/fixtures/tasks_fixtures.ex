defmodule MatsuriOps.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MatsuriOps.Tasks` context.
  """

  alias MatsuriOps.Tasks

  def valid_task_category_attributes(festival, attrs \\ %{}) do
    Enum.into(attrs, %{
      name: "テストカテゴリ#{System.unique_integer()}",
      festival_id: festival.id,
      sort_order: 0
    })
  end

  def task_category_fixture(festival, attrs \\ %{}) do
    attrs = valid_task_category_attributes(festival, attrs)

    {:ok, category} = Tasks.create_task_category(attrs)
    category
  end

  def valid_task_attributes(festival, attrs \\ %{}) do
    Enum.into(attrs, %{
      title: "テストタスク#{System.unique_integer()}",
      description: "テストタスクの説明",
      festival_id: festival.id,
      status: "pending",
      priority: "medium",
      sort_order: 0
    })
  end

  def task_fixture(festival, attrs \\ %{}) do
    attrs = valid_task_attributes(festival, attrs)

    {:ok, task} = Tasks.create_task(attrs)
    task
  end

  def valid_checklist_item_attributes(task, attrs \\ %{}) do
    Enum.into(attrs, %{
      content: "チェックリスト項目#{System.unique_integer()}",
      task_id: task.id,
      is_completed: false,
      sort_order: 0
    })
  end

  def checklist_item_fixture(task, attrs \\ %{}) do
    attrs = valid_checklist_item_attributes(task, attrs)

    {:ok, item} = Tasks.create_checklist_item(attrs)
    item
  end

  def task_dependency_fixture(predecessor, successor) do
    {:ok, dependency} =
      Tasks.create_task_dependency(%{
        predecessor_id: predecessor.id,
        successor_id: successor.id
      })

    dependency
  end
end
