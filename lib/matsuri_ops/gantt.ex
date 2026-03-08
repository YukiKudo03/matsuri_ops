defmodule MatsuriOps.Gantt do
  @moduledoc """
  ガントチャート機能モジュール。

  タスクのガントチャートデータ変換、依存関係計算、
  クリティカルパス分析を提供する。
  """

  import Ecto.Query, warn: false
  alias MatsuriOps.Repo
  alias MatsuriOps.Tasks
  alias MatsuriOps.Tasks.{Task, TaskDependency}

  @doc """
  祭りのガントチャートデータを取得する。
  """
  def get_gantt_data(festival_id) do
    Tasks.list_tasks(festival_id)
    |> convert_tasks_to_gantt_data()
  end

  @doc """
  タスクリストをガントチャート形式に変換する。
  """
  def convert_tasks_to_gantt_data(tasks) do
    tasks
    |> Enum.filter(&has_valid_dates?/1)
    |> Enum.map(&task_to_gantt_item/1)
  end

  defp has_valid_dates?(task) do
    task.start_date != nil && task.due_date != nil
  end

  defp task_to_gantt_item(task) do
    %{
      id: task.id,
      name: task.title,
      start: task.start_date,
      end: task.due_date,
      progress: task.progress_percent || 0,
      status: task.status,
      parent_id: task.parent_id,
      category_id: task.category_id
    }
  end

  @doc """
  祭りのタスク依存関係を取得する。
  """
  def get_task_dependencies(festival_id) do
    TaskDependency
    |> join(:inner, [d], t in Task, on: d.successor_id == t.id)
    |> where([d, t], t.festival_id == ^festival_id)
    |> select([d, t], %{
      from: d.predecessor_id,
      to: d.successor_id,
      type: d.dependency_type
    })
    |> Repo.all()
  end

  @doc """
  クリティカルパスを計算する。

  クリティカルパス上のタスクは、遅延すると
  プロジェクト全体の完了日に影響するタスク。
  """
  def calculate_critical_path(festival_id) do
    tasks = Tasks.list_tasks(festival_id)
    dependencies = get_task_dependencies(festival_id)

    tasks
    |> Enum.filter(&has_valid_dates?/1)
    |> calculate_early_times(dependencies)
    |> calculate_late_times(dependencies)
    |> Enum.filter(&is_critical?/1)
    |> Enum.map(& &1.task)
  end

  defp calculate_early_times(tasks, _dependencies) do
    # Simplified: assign early start/finish based on task dates
    Enum.map(tasks, fn task ->
      duration = Date.diff(task.due_date, task.start_date)
      %{
        task: task,
        early_start: task.start_date,
        early_finish: task.due_date,
        duration: duration,
        late_start: nil,
        late_finish: nil,
        slack: 0
      }
    end)
  end

  defp calculate_late_times(task_data, _dependencies) do
    # Find the project end date
    project_end =
      task_data
      |> Enum.map(& &1.early_finish)
      |> Enum.max(Date)

    # Calculate late times (simplified backward pass)
    Enum.map(task_data, fn item ->
      late_finish = project_end
      late_start = Date.add(late_finish, -item.duration)
      slack = Date.diff(late_start, item.early_start)

      %{item | late_start: late_start, late_finish: late_finish, slack: slack}
    end)
  end

  defp is_critical?(task_data) do
    task_data.slack == 0
  end

  @doc """
  タイムライン範囲を計算する。
  """
  def calculate_timeline_range(festival_id) do
    tasks = Tasks.list_tasks(festival_id)
    valid_tasks = Enum.filter(tasks, &has_valid_dates?/1)

    if Enum.empty?(valid_tasks) do
      nil
    else
      start_date =
        valid_tasks
        |> Enum.map(& &1.start_date)
        |> Enum.min(Date)

      end_date =
        valid_tasks
        |> Enum.map(& &1.due_date)
        |> Enum.max(Date)

      {start_date, end_date}
    end
  end

  @doc """
  ガントチャートのカラム（日付）を生成する。
  """
  def generate_date_columns(start_date, end_date) do
    Date.range(start_date, end_date)
    |> Enum.to_list()
  end

  @doc """
  タスクのバー位置（開始位置と幅）を計算する。
  """
  def calculate_bar_position(task, timeline_start, total_days) when total_days > 0 do
    start_offset = Date.diff(task.start, timeline_start)
    duration = Date.diff(task.end, task.start) + 1

    %{
      left_percent: start_offset / total_days * 100,
      width_percent: duration / total_days * 100
    }
  end

  def calculate_bar_position(_task, _timeline_start, _total_days) do
    %{left_percent: 0, width_percent: 0}
  end
end
