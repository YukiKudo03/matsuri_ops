defmodule MatsuriOpsWeb.TaskLive.ShowTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.TasksFixtures

  describe "Show page" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      task = task_fixture(festival, %{
        title: "詳細テストタスク",
        description: "タスクの詳細説明",
        status: "in_progress",
        priority: "high",
        progress_percent: 50,
        start_date: ~D[2025-08-01],
        due_date: ~D[2025-08-15],
        estimated_hours: Decimal.new("16.5")
      })
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, task: task}
    end

    test "renders task detail page", %{conn: conn, festival: festival, task: task} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}")

      assert html =~ "詳細テストタスク"
      assert html =~ "タスクの詳細説明"
    end

    test "redirects if user is not logged in", %{festival: festival, task: task} do
      conn = build_conn()
      assert {:error, redirect} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays task status", %{conn: conn, festival: festival, task: task} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}")

      assert html =~ "進行中"
    end

    test "displays task priority", %{conn: conn, festival: festival, task: task} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}")

      assert html =~ "高"
    end

    test "displays progress bar", %{conn: conn, festival: festival, task: task} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}")

      assert html =~ "50%"
      assert html =~ "width: 50%"
    end

    test "displays dates", %{conn: conn, festival: festival, task: task} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}")

      assert html =~ "2025-08-01"
      assert html =~ "2025-08-15"
    end

    test "displays estimated hours", %{conn: conn, festival: festival, task: task} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}")

      assert html =~ "16.5"
      assert html =~ "時間"
    end

    test "displays milestone indicator when applicable", %{conn: conn, festival: festival, user: _user} do
      milestone_task = task_fixture(festival, %{title: "マイルストーン", is_milestone: true})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks/#{milestone_task}")

      assert html =~ "⭐"
    end

    test "displays edit button", %{conn: conn, festival: festival, task: task} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}")

      assert html =~ "編集"
    end

    test "displays back link", %{conn: conn, festival: festival, task: task} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}")

      assert html =~ "タスク一覧へ戻る"
    end

    test "displays unassigned message when no assignee", %{conn: conn, festival: festival, task: task} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}")

      assert html =~ "未割当"
    end
  end

  describe "Checklist" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      task = task_fixture(festival, %{title: "チェックリストタスク"})
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, task: task}
    end

    test "displays empty checklist message", %{conn: conn, festival: festival, task: task} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}")

      assert html =~ "チェックリストがありません"
    end

    test "displays checklist items", %{conn: conn, festival: festival, task: task} do
      _item1 = checklist_item_fixture(task, %{content: "チェック項目1"})
      _item2 = checklist_item_fixture(task, %{content: "チェック項目2"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}")

      assert html =~ "チェック項目1"
      assert html =~ "チェック項目2"
    end

    test "can toggle checklist item", %{conn: conn, festival: festival, task: task} do
      item = checklist_item_fixture(task, %{content: "トグル項目", is_completed: false})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}")

      view
      |> element("[phx-click='toggle_checklist'][phx-value-id='#{item.id}']")
      |> render_click()

      html = render(view)
      assert html =~ "line-through"
    end

    test "displays completed item with strikethrough", %{conn: conn, festival: festival, task: task} do
      _item = checklist_item_fixture(task, %{content: "完了項目", is_completed: true})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}")

      assert html =~ "line-through"
    end
  end

  describe "Subtasks" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      parent_task = task_fixture(festival, %{title: "親タスク"})
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, parent_task: parent_task}
    end

    test "displays subtasks when they exist", %{conn: conn, festival: festival, parent_task: parent_task} do
      _child1 = task_fixture(festival, %{title: "サブタスク1", parent_id: parent_task.id})
      _child2 = task_fixture(festival, %{title: "サブタスク2", parent_id: parent_task.id})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks/#{parent_task}")

      assert html =~ "サブタスク"
      assert html =~ "サブタスク1"
      assert html =~ "サブタスク2"
    end

    test "displays subtask status", %{conn: conn, festival: festival, parent_task: parent_task} do
      _child = task_fixture(festival, %{
        title: "完了サブタスク",
        parent_id: parent_task.id,
        status: "completed"
      })

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks/#{parent_task}")

      assert html =~ "完了"
    end

    test "subtask links navigate to subtask detail", %{conn: conn, festival: festival, parent_task: parent_task} do
      child = task_fixture(festival, %{title: "リンクテストサブタスク", parent_id: parent_task.id})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks/#{parent_task}")

      assert html =~ ~s(href="/festivals/#{festival.id}/tasks/#{child.id}")
    end
  end

  describe "Edit modal from show page" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      task = task_fixture(festival, %{title: "編集テストタスク"})
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, task: task}
    end

    test "opens edit modal", %{conn: conn, festival: festival, task: task} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}")

      view
      |> element("a", "編集")
      |> render_click()

      assert_patch(view, ~p"/festivals/#{festival}/tasks/#{task}/show/edit")
      assert has_element?(view, "#task-form")
    end

    test "updates task from show page", %{conn: conn, festival: festival, task: task} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}/show/edit")

      view
      |> form("#task-form", task: %{title: "ショーページから更新"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/tasks/#{task}")
      assert render(view) =~ "ショーページから更新"
    end
  end

  describe "Progress update" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      task = task_fixture(festival, %{title: "進捗更新タスク", progress_percent: 25})
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, task: task}
    end

    test "displays current progress", %{conn: conn, festival: festival, task: task} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}")

      assert html =~ "25%"
    end
  end
end
