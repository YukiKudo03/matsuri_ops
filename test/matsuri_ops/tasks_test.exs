defmodule MatsuriOps.TasksTest do
  use MatsuriOps.DataCase, async: true

  alias MatsuriOps.Tasks
  alias MatsuriOps.Tasks.{Task, TaskCategory, TaskDependency, ChecklistItem}

  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.TasksFixtures

  describe "task_categories" do
    setup do
      user = user_fixture()
      festival = festival_fixture(user)
      %{user: user, festival: festival}
    end

    test "list_task_categories/1 returns all categories for a festival", %{festival: festival} do
      category = task_category_fixture(festival)
      assert Tasks.list_task_categories(festival.id) == [category]
    end

    test "list_task_categories/1 returns categories ordered by sort_order", %{festival: festival} do
      cat1 = task_category_fixture(festival, %{sort_order: 2, name: "カテゴリ2"})
      cat2 = task_category_fixture(festival, %{sort_order: 1, name: "カテゴリ1"})

      result = Tasks.list_task_categories(festival.id)
      assert [first, second] = result
      assert first.id == cat2.id
      assert second.id == cat1.id
    end

    test "get_task_category!/1 returns the category", %{festival: festival} do
      category = task_category_fixture(festival)
      assert Tasks.get_task_category!(category.id) == category
    end

    test "create_task_category/1 with valid data creates a category", %{festival: festival} do
      attrs = %{name: "新規カテゴリ", festival_id: festival.id, sort_order: 0}

      assert {:ok, %TaskCategory{} = category} = Tasks.create_task_category(attrs)
      assert category.name == "新規カテゴリ"
    end

    test "create_task_category/1 with invalid data returns error", %{festival: festival} do
      attrs = %{name: nil, festival_id: festival.id}
      assert {:error, %Ecto.Changeset{}} = Tasks.create_task_category(attrs)
    end

    test "update_task_category/2 updates the category", %{festival: festival} do
      category = task_category_fixture(festival)

      assert {:ok, %TaskCategory{} = updated} =
               Tasks.update_task_category(category, %{name: "更新されたカテゴリ"})

      assert updated.name == "更新されたカテゴリ"
    end

    test "delete_task_category/1 deletes the category", %{festival: festival} do
      category = task_category_fixture(festival)
      assert {:ok, %TaskCategory{}} = Tasks.delete_task_category(category)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_task_category!(category.id) end
    end

    test "change_task_category/1 returns a changeset", %{festival: festival} do
      category = task_category_fixture(festival)
      assert %Ecto.Changeset{} = Tasks.change_task_category(category)
    end
  end

  describe "tasks" do
    setup do
      user = user_fixture()
      festival = festival_fixture(user)
      category = task_category_fixture(festival)
      %{user: user, festival: festival, category: category}
    end

    test "list_tasks/1 returns all tasks for a festival", %{festival: festival} do
      task = task_fixture(festival)
      tasks = Tasks.list_tasks(festival.id)
      assert length(tasks) == 1
      assert hd(tasks).id == task.id
    end

    test "list_tasks_by_category/2 returns tasks for a specific category", %{
      festival: festival,
      category: category
    } do
      task1 = task_fixture(festival, %{category_id: category.id})
      _task2 = task_fixture(festival, %{category_id: nil})

      result = Tasks.list_tasks_by_category(festival.id, category.id)
      assert length(result) == 1
      assert hd(result).id == task1.id
    end

    test "list_tasks_by_assignee/2 returns tasks for a specific user", %{
      festival: festival,
      user: user
    } do
      task1 = task_fixture(festival, %{assignee_id: user.id})
      other_user = user_fixture()
      _task2 = task_fixture(festival, %{assignee_id: other_user.id})

      result = Tasks.list_tasks_by_assignee(festival.id, user.id)
      assert length(result) == 1
      assert hd(result).id == task1.id
    end

    test "list_root_tasks/1 returns only root tasks (no parent)", %{festival: festival} do
      parent = task_fixture(festival)
      _child = task_fixture(festival, %{parent_id: parent.id})

      result = Tasks.list_root_tasks(festival.id)
      assert length(result) == 1
      assert hd(result).id == parent.id
    end

    test "get_task!/1 returns the task", %{festival: festival} do
      task = task_fixture(festival)
      assert Tasks.get_task!(task.id).id == task.id
    end

    test "get_task_with_children!/1 returns task with preloaded associations", %{
      festival: festival,
      user: user
    } do
      parent = task_fixture(festival, %{assignee_id: user.id})
      _child = task_fixture(festival, %{parent_id: parent.id})
      _checklist = checklist_item_fixture(parent)

      result = Tasks.get_task_with_children!(parent.id)
      assert length(result.children) == 1
      assert length(result.checklist_items) == 1
      assert result.assignee.id == user.id
    end

    test "create_task/1 with valid data creates a task", %{festival: festival} do
      attrs = %{title: "新規タスク", festival_id: festival.id, status: "pending", priority: "high"}

      assert {:ok, %Task{} = task} = Tasks.create_task(attrs)
      assert task.title == "新規タスク"
      assert task.priority == "high"
    end

    test "create_task/1 with invalid data returns error", %{festival: festival} do
      attrs = %{title: nil, festival_id: festival.id}
      assert {:error, %Ecto.Changeset{}} = Tasks.create_task(attrs)
    end

    test "update_task/2 updates the task", %{festival: festival} do
      task = task_fixture(festival)

      assert {:ok, %Task{} = updated} = Tasks.update_task(task, %{title: "更新されたタスク"})
      assert updated.title == "更新されたタスク"
    end

    test "delete_task/1 deletes the task", %{festival: festival} do
      task = task_fixture(festival)
      assert {:ok, %Task{}} = Tasks.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_task!(task.id) end
    end

    test "change_task/1 returns a changeset", %{festival: festival} do
      task = task_fixture(festival)
      assert %Ecto.Changeset{} = Tasks.change_task(task)
    end
  end

  describe "task_dependencies" do
    setup do
      user = user_fixture()
      festival = festival_fixture(user)
      %{festival: festival}
    end

    test "list_task_dependencies/1 returns dependencies for a task", %{festival: festival} do
      predecessor = task_fixture(festival)
      successor = task_fixture(festival)
      _dependency = task_dependency_fixture(predecessor, successor)

      result = Tasks.list_task_dependencies(successor.id)
      assert length(result) == 1
      assert hd(result).predecessor.id == predecessor.id
    end

    test "create_task_dependency/1 creates a dependency", %{festival: festival} do
      predecessor = task_fixture(festival)
      successor = task_fixture(festival)

      attrs = %{predecessor_id: predecessor.id, successor_id: successor.id}
      assert {:ok, %TaskDependency{}} = Tasks.create_task_dependency(attrs)
    end

    test "delete_task_dependency/1 deletes the dependency", %{festival: festival} do
      predecessor = task_fixture(festival)
      successor = task_fixture(festival)
      dependency = task_dependency_fixture(predecessor, successor)

      assert {:ok, %TaskDependency{}} = Tasks.delete_task_dependency(dependency)
      assert Tasks.list_task_dependencies(successor.id) == []
    end
  end

  describe "checklist_items" do
    setup do
      user = user_fixture()
      festival = festival_fixture(user)
      task = task_fixture(festival)
      %{user: user, festival: festival, task: task}
    end

    test "list_checklist_items/1 returns items for a task", %{task: task} do
      item = checklist_item_fixture(task)
      assert Tasks.list_checklist_items(task.id) == [item]
    end

    test "list_checklist_items/1 returns items ordered by sort_order", %{task: task} do
      item1 = checklist_item_fixture(task, %{sort_order: 2, content: "項目2"})
      item2 = checklist_item_fixture(task, %{sort_order: 1, content: "項目1"})

      result = Tasks.list_checklist_items(task.id)
      assert [first, second] = result
      assert first.id == item2.id
      assert second.id == item1.id
    end

    test "get_checklist_item!/1 returns the item", %{task: task} do
      item = checklist_item_fixture(task)
      assert Tasks.get_checklist_item!(item.id) == item
    end

    test "create_checklist_item/1 with valid data creates an item", %{task: task} do
      attrs = %{content: "新規項目", task_id: task.id, is_completed: false, sort_order: 0}

      assert {:ok, %ChecklistItem{} = item} = Tasks.create_checklist_item(attrs)
      assert item.content == "新規項目"
    end

    test "create_checklist_item/1 with invalid data returns error", %{task: task} do
      attrs = %{content: nil, task_id: task.id}
      assert {:error, %Ecto.Changeset{}} = Tasks.create_checklist_item(attrs)
    end

    test "update_checklist_item/2 updates the item", %{task: task} do
      item = checklist_item_fixture(task)

      assert {:ok, %ChecklistItem{} = updated} =
               Tasks.update_checklist_item(item, %{content: "更新された項目"})

      assert updated.content == "更新された項目"
    end

    test "delete_checklist_item/1 deletes the item", %{task: task} do
      item = checklist_item_fixture(task)
      assert {:ok, %ChecklistItem{}} = Tasks.delete_checklist_item(item)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_checklist_item!(item.id) end
    end

    test "toggle_checklist_item/2 toggles completion to true", %{task: task, user: user} do
      item = checklist_item_fixture(task, %{is_completed: false})

      assert {:ok, %ChecklistItem{} = toggled} = Tasks.toggle_checklist_item(item, user.id)
      assert toggled.is_completed == true
      assert toggled.completed_by_id == user.id
    end

    test "toggle_checklist_item/2 toggles completion to false", %{task: task, user: user} do
      item = checklist_item_fixture(task, %{is_completed: true, completed_by_id: user.id})

      assert {:ok, %ChecklistItem{} = toggled} = Tasks.toggle_checklist_item(item, user.id)
      assert toggled.is_completed == false
    end

    test "change_checklist_item/1 returns a changeset", %{task: task} do
      item = checklist_item_fixture(task)
      assert %Ecto.Changeset{} = Tasks.change_checklist_item(item)
    end
  end
end
