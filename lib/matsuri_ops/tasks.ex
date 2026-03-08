defmodule MatsuriOps.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias MatsuriOps.Repo
  alias MatsuriOps.Tasks.{Task, TaskCategory, TaskDependency, ChecklistItem}

  ## Task Categories

  def list_task_categories(festival_id) do
    TaskCategory
    |> where([tc], tc.festival_id == ^festival_id)
    |> order_by([tc], asc: tc.sort_order)
    |> Repo.all()
  end

  def get_task_category!(id), do: Repo.get!(TaskCategory, id)

  def create_task_category(attrs \\ %{}) do
    %TaskCategory{}
    |> TaskCategory.changeset(attrs)
    |> Repo.insert()
  end

  def update_task_category(%TaskCategory{} = task_category, attrs) do
    task_category
    |> TaskCategory.changeset(attrs)
    |> Repo.update()
  end

  def delete_task_category(%TaskCategory{} = task_category) do
    Repo.delete(task_category)
  end

  def change_task_category(%TaskCategory{} = task_category, attrs \\ %{}) do
    TaskCategory.changeset(task_category, attrs)
  end

  ## Tasks

  def list_tasks(festival_id) do
    Task
    |> where([t], t.festival_id == ^festival_id)
    |> order_by([t], [asc: t.sort_order, asc: t.inserted_at])
    |> preload([:category, :assignee])
    |> Repo.all()
  end

  def list_tasks_by_category(festival_id, category_id) do
    Task
    |> where([t], t.festival_id == ^festival_id and t.category_id == ^category_id)
    |> order_by([t], asc: t.sort_order)
    |> Repo.all()
  end

  def list_tasks_by_assignee(festival_id, user_id) do
    Task
    |> where([t], t.festival_id == ^festival_id and t.assignee_id == ^user_id)
    |> order_by([t], [asc: t.due_date, asc: t.priority])
    |> Repo.all()
  end

  def list_root_tasks(festival_id) do
    Task
    |> where([t], t.festival_id == ^festival_id and is_nil(t.parent_id))
    |> order_by([t], asc: t.sort_order)
    |> Repo.all()
  end

  def get_task!(id), do: Repo.get!(Task, id)

  def get_task_with_children!(id) do
    Task
    |> Repo.get!(id)
    |> Repo.preload([:children, :checklist_items, :assignee])
  end

  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  ## Task Dependencies

  def list_task_dependencies(task_id) do
    TaskDependency
    |> where([td], td.successor_id == ^task_id)
    |> preload(:predecessor)
    |> Repo.all()
  end

  def create_task_dependency(attrs \\ %{}) do
    %TaskDependency{}
    |> TaskDependency.changeset(attrs)
    |> Repo.insert()
  end

  def delete_task_dependency(%TaskDependency{} = task_dependency) do
    Repo.delete(task_dependency)
  end

  ## Checklist Items

  def list_checklist_items(task_id) do
    ChecklistItem
    |> where([ci], ci.task_id == ^task_id)
    |> order_by([ci], asc: ci.sort_order)
    |> Repo.all()
  end

  def get_checklist_item!(id), do: Repo.get!(ChecklistItem, id)

  def create_checklist_item(attrs \\ %{}) do
    %ChecklistItem{}
    |> ChecklistItem.changeset(attrs)
    |> Repo.insert()
  end

  def update_checklist_item(%ChecklistItem{} = checklist_item, attrs) do
    checklist_item
    |> ChecklistItem.changeset(attrs)
    |> Repo.update()
  end

  def delete_checklist_item(%ChecklistItem{} = checklist_item) do
    Repo.delete(checklist_item)
  end

  def toggle_checklist_item(%ChecklistItem{} = checklist_item, user_id) do
    attrs =
      if checklist_item.is_completed do
        %{is_completed: false}
      else
        %{is_completed: true, completed_by_id: user_id}
      end

    update_checklist_item(checklist_item, attrs)
  end

  def change_checklist_item(%ChecklistItem{} = checklist_item, attrs \\ %{}) do
    ChecklistItem.changeset(checklist_item, attrs)
  end
end
