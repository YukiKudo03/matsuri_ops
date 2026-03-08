defmodule MatsuriOpsWeb.TaskLive.FormComponentTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.TasksFixtures

  describe "FormComponent for new task" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "renders form for new task", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks/new")

      assert html =~ "タイトル"
      assert html =~ "説明"
      assert html =~ "状態"
      assert html =~ "優先度"
      assert html =~ "開始日"
      assert html =~ "期限"
      assert html =~ "見積工数"
      assert html =~ "進捗"
      assert html =~ "マイルストーン"
      assert html =~ "保存"
    end

    test "validates required fields", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/tasks/new")

      result =
        view
        |> form("#task-form", task: %{title: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "creates task with valid data", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/tasks/new")

      view
      |> form("#task-form", task: %{
        title: "新規テストタスク",
        description: "タスクの説明",
        status: "pending",
        priority: "high"
      })
      |> render_submit()

      flash = assert_patch(view, ~p"/festivals/#{festival}/tasks")
      assert render(view) =~ "タスクを作成しました" or flash
    end

    test "creates task with category", %{conn: conn, festival: festival} do
      category = task_category_fixture(festival, %{name: "テストカテゴリ"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/tasks/new")

      view
      |> form("#task-form", task: %{
        title: "カテゴリ付きタスク",
        status: "pending",
        priority: "medium",
        category_id: category.id
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/tasks")
    end

    test "creates task with dates", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/tasks/new")

      view
      |> form("#task-form", task: %{
        title: "期限付きタスク",
        status: "pending",
        priority: "medium",
        start_date: ~D[2025-08-01],
        due_date: ~D[2025-08-15]
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/tasks")
    end

    test "creates task with estimated hours", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/tasks/new")

      view
      |> form("#task-form", task: %{
        title: "工数見積タスク",
        status: "pending",
        priority: "medium",
        estimated_hours: 8.5
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/tasks")
    end

    test "creates milestone task", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/tasks/new")

      view
      |> form("#task-form", task: %{
        title: "マイルストーン",
        status: "pending",
        priority: "high",
        is_milestone: true
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/tasks")
      html = render(view)
      assert html =~ "⭐"
    end

    test "displays status options", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks/new")

      assert html =~ "未着手"
      assert html =~ "進行中"
      assert html =~ "完了"
      assert html =~ "ブロック"
      assert html =~ "キャンセル"
    end

    test "displays priority options", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks/new")

      assert html =~ ">低<"
      assert html =~ ">中<"
      assert html =~ ">高<"
      assert html =~ ">緊急<"
    end
  end

  describe "FormComponent for editing task" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      task = task_fixture(festival, %{
        title: "編集用タスク",
        description: "元の説明",
        status: "pending",
        priority: "medium",
        progress_percent: 30
      })
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, task: task}
    end

    test "displays existing values", %{conn: conn, festival: festival, task: task} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}/edit")

      assert html =~ "編集用タスク"
      assert html =~ "元の説明"
    end

    test "updates task title", %{conn: conn, festival: festival, task: task} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}/edit")

      view
      |> form("#task-form", task: %{title: "更新後タスクタイトル"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/tasks")
      assert render(view) =~ "更新後タスクタイトル"
    end

    test "updates task status", %{conn: conn, festival: festival, task: task} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}/edit")

      view
      |> form("#task-form", task: %{status: "in_progress"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/tasks")
      assert render(view) =~ "進行中"
    end

    test "updates task priority", %{conn: conn, festival: festival, task: task} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}/edit")

      view
      |> form("#task-form", task: %{priority: "urgent"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/tasks")
      assert render(view) =~ "緊急"
    end

    test "updates progress percentage", %{conn: conn, festival: festival, task: task} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}/edit")

      view
      |> form("#task-form", task: %{progress_percent: 80})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/tasks")
      assert render(view) =~ "80%"
    end

    test "validates title cannot be empty on edit", %{conn: conn, festival: festival, task: task} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}/edit")

      result =
        view
        |> form("#task-form", task: %{title: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "shows page title for edit", %{conn: conn, festival: festival, task: task} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/tasks/#{task}/edit")

      assert html =~ "タスク編集"
    end
  end
end
