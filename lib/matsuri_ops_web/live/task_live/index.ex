defmodule MatsuriOpsWeb.TaskLive.Index do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.Festivals
  alias MatsuriOps.Tasks
  alias MatsuriOps.Tasks.Task

  @impl true
  def mount(%{"festival_id" => festival_id}, _session, socket) do
    festival = Festivals.get_festival!(festival_id)
    categories = Tasks.list_task_categories(festival_id)
    tasks = Tasks.list_tasks(festival_id)

    {:ok,
     socket
     |> assign(:festival, festival)
     |> assign(:categories, categories)
     |> stream(:tasks, tasks)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "タスク編集")
    |> assign(:task, Tasks.get_task!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "新規タスク")
    |> assign(:task, %Task{festival_id: socket.assigns.festival.id})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "タスク一覧 - #{socket.assigns.festival.name}")
    |> assign(:task, nil)
  end

  @impl true
  def handle_info({MatsuriOpsWeb.TaskLive.FormComponent, {:saved, task}}, socket) do
    {:noreply, stream_insert(socket, :tasks, task)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    {:ok, _} = Tasks.delete_task(task)

    {:noreply, stream_delete(socket, :tasks, task)}
  end

  @impl true
  def handle_event("update_status", %{"id" => id, "status" => status}, socket) do
    task = Tasks.get_task!(id)
    {:ok, updated_task} = Tasks.update_task(task, %{status: status})

    {:noreply, stream_insert(socket, :tasks, updated_task)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      {@festival.name} - タスク一覧
      <:actions>
        <.link patch={~p"/festivals/#{@festival}/tasks/new"}>
          <.button>新規タスク</.button>
        </.link>
        <.link navigate={~p"/festivals/#{@festival}"}>
          <.button variant="outline">祭り詳細へ</.button>
        </.link>
      </:actions>
    </.header>

    <div class="mt-6 flex gap-2 flex-wrap">
      <span class="inline-flex items-center px-2 py-1 text-xs rounded bg-gray-100">
        全て: {Enum.count(@streams.tasks.inserts)}
      </span>
    </div>

    <.table
      id="tasks"
      rows={@streams.tasks}
      row_click={fn {_id, task} -> JS.navigate(~p"/festivals/#{@festival}/tasks/#{task}") end}
    >
      <:col :let={{_id, task}} label="タイトル">
        <div class="flex items-center gap-2">
          <span :if={task.is_milestone} class="text-yellow-500">⭐</span>
          {task.title}
        </div>
      </:col>
      <:col :let={{_id, task}} label="状態">
        <.status_badge status={task.status} />
      </:col>
      <:col :let={{_id, task}} label="優先度">
        <.priority_badge priority={task.priority} />
      </:col>
      <:col :let={{_id, task}} label="進捗">{task.progress_percent}%</:col>
      <:col :let={{_id, task}} label="期限">{task.due_date}</:col>
      <:action :let={{_id, task}}>
        <.link patch={~p"/festivals/#{@festival}/tasks/#{task}/edit"}>編集</.link>
      </:action>
      <:action :let={{id, task}}>
        <.link
          phx-click={JS.push("delete", value: %{id: task.id}) |> hide("##{id}")}
          data-confirm="本当に削除しますか？"
        >
          削除
        </.link>
      </:action>
    </.table>

    <.modal :if={@live_action in [:new, :edit]} id="task-modal" show on_cancel={JS.patch(~p"/festivals/#{@festival}/tasks")}>
      <.live_component
        module={MatsuriOpsWeb.TaskLive.FormComponent}
        id={@task.id || :new}
        title={@page_title}
        action={@live_action}
        task={@task}
        festival={@festival}
        categories={@categories}
        patch={~p"/festivals/#{@festival}/tasks"}
      />
    </.modal>
    """
  end

  defp status_badge(assigns) do
    {bg_color, text} =
      case assigns.status do
        "pending" -> {"bg-gray-100 text-gray-700", "未着手"}
        "in_progress" -> {"bg-blue-100 text-blue-700", "進行中"}
        "completed" -> {"bg-green-100 text-green-700", "完了"}
        "cancelled" -> {"bg-red-100 text-red-700", "キャンセル"}
        "blocked" -> {"bg-yellow-100 text-yellow-700", "ブロック"}
        _ -> {"bg-gray-100 text-gray-700", assigns.status}
      end

    assigns = assign(assigns, :bg_color, bg_color)
    assigns = assign(assigns, :text, text)

    ~H"""
    <span class={"inline-flex items-center px-2 py-1 text-xs rounded #{@bg_color}"}>
      {@text}
    </span>
    """
  end

  defp priority_badge(assigns) do
    {bg_color, text} =
      case assigns.priority do
        "low" -> {"bg-gray-100 text-gray-700", "低"}
        "medium" -> {"bg-blue-100 text-blue-700", "中"}
        "high" -> {"bg-orange-100 text-orange-700", "高"}
        "urgent" -> {"bg-red-100 text-red-700", "緊急"}
        _ -> {"bg-gray-100 text-gray-700", assigns.priority}
      end

    assigns = assign(assigns, :bg_color, bg_color)
    assigns = assign(assigns, :text, text)

    ~H"""
    <span class={"inline-flex items-center px-2 py-1 text-xs rounded #{@bg_color}"}>
      {@text}
    </span>
    """
  end
end
