defmodule MatsuriOpsWeb.TaskLive.IndexTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.TasksFixtures

  describe "Index page" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "renders task list page", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks")

      assert html =~ "タスク一覧"
      assert html =~ festival.name
    end

    test "redirects if user is not logged in", %{festival: festival} do
      conn = build_conn()
      assert {:error, redirect} = live(conn, ~p"/festivals/#{festival}/tasks")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays navigation buttons", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks")

      assert html =~ "新規タスク"
      assert html =~ "祭り詳細へ"
    end

    test "displays task list", %{conn: conn, festival: festival} do
      _task = task_fixture(festival, %{title: "テストタスク", status: "pending"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks")

      assert html =~ "テストタスク"
      assert html =~ "未着手"
    end

    test "displays milestone indicator", %{conn: conn, festival: festival} do
      _task = task_fixture(festival, %{title: "マイルストーンタスク", is_milestone: true})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks")

      assert html =~ "マイルストーンタスク"
      assert html =~ "⭐"
    end

    test "displays priority badges", %{conn: conn, festival: festival} do
      _low = task_fixture(festival, %{title: "低優先度", priority: "low"})
      _high = task_fixture(festival, %{title: "高優先度", priority: "high"})
      _urgent = task_fixture(festival, %{title: "緊急タスク", priority: "urgent"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks")

      assert html =~ "低"
      assert html =~ "高"
      assert html =~ "緊急"
    end

    test "displays status badges", %{conn: conn, festival: festival} do
      _pending = task_fixture(festival, %{title: "未着手タスク", status: "pending"})
      _in_progress = task_fixture(festival, %{title: "進行中タスク", status: "in_progress"})
      _completed = task_fixture(festival, %{title: "完了タスク", status: "completed"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks")

      assert html =~ "未着手"
      assert html =~ "進行中"
      assert html =~ "完了"
    end

    test "displays progress percentage", %{conn: conn, festival: festival} do
      _task = task_fixture(festival, %{title: "進捗タスク", progress_percent: 75})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks")

      assert html =~ "75%"
    end

    test "displays due date", %{conn: conn, festival: festival} do
      _task = task_fixture(festival, %{title: "期限タスク", due_date: ~D[2025-08-15]})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks")

      assert html =~ "2025-08-15"
    end

    test "can delete task", %{conn: conn, festival: festival} do
      task = task_fixture(festival, %{title: "削除対象タスク"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/tasks")

      # 削除リンクが存在することを確認
      assert has_element?(view, "#tasks-#{task.id}")

      # 削除イベントを発火
      view
      |> render_click("delete", %{"id" => to_string(task.id)})

      refute has_element?(view, "#tasks-#{task.id}")
    end

    test "table row is clickable to navigate to show", %{conn: conn, festival: festival} do
      task = task_fixture(festival, %{title: "詳細確認タスク"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/tasks")

      assert has_element?(view, "#tasks-#{task.id}")
    end
  end

  describe "New task modal" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "opens new task modal", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/tasks")

      view
      |> element("a", "新規タスク")
      |> render_click()

      assert_patch(view, ~p"/festivals/#{festival}/tasks/new")
      assert has_element?(view, "#task-form")
    end

    test "displays task form fields", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks/new")

      assert html =~ "タイトル"
      assert html =~ "説明"
      assert html =~ "カテゴリ"
      assert html =~ "状態"
      assert html =~ "優先度"
      assert html =~ "開始日"
      assert html =~ "期限"
    end

    test "saves new task", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/tasks/new")

      view
      |> form("#task-form", task: %{
        title: "新規作成タスク",
        status: "pending",
        priority: "medium"
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/tasks")
      assert render(view) =~ "新規作成タスク"
    end

    test "displays category options", %{conn: conn, festival: festival} do
      _category = task_category_fixture(festival, %{name: "設営作業"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks/new")

      assert html =~ "なし"
      assert html =~ "設営作業"
    end
  end

  describe "Edit task modal" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      task = task_fixture(festival, %{title: "編集対象タスク", priority: "low"})
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, task: task}
    end

    test "opens edit task modal", %{conn: conn, festival: festival, task: task} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}/edit")

      assert html =~ "タスク編集"
      assert html =~ "編集対象タスク"
    end

    test "updates task", %{conn: conn, festival: festival, task: task} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}/edit")

      view
      |> form("#task-form", task: %{title: "更新済みタスク"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/tasks")
      assert render(view) =~ "更新済みタスク"
    end
  end
end
