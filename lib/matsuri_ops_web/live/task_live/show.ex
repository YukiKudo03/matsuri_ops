defmodule MatsuriOpsWeb.TaskLive.Show do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.Festivals
  alias MatsuriOps.Tasks

  @impl true
  def mount(%{"festival_id" => festival_id}, _session, socket) do
    festival = Festivals.get_festival!(festival_id)

    {:ok, assign(socket, :festival, festival)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    task = Tasks.get_task_with_children!(id)
    checklist_items = Tasks.list_checklist_items(id)

    {:noreply,
     socket
     |> assign(:page_title, task.title)
     |> assign(:task, task)
     |> assign(:checklist_items, checklist_items)}
  end

  @impl true
  def handle_event("toggle_checklist", %{"id" => id}, socket) do
    item = Tasks.get_checklist_item!(id)
    user_id = socket.assigns.current_scope.user.id
    {:ok, _} = Tasks.toggle_checklist_item(item, user_id)

    checklist_items = Tasks.list_checklist_items(socket.assigns.task.id)
    {:noreply, assign(socket, :checklist_items, checklist_items)}
  end

  @impl true
  def handle_event("update_progress", %{"progress" => progress}, socket) do
    {:ok, task} = Tasks.update_task(socket.assigns.task, %{progress_percent: progress})
    {:noreply, assign(socket, :task, task)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <div class="flex items-center gap-2">
        <span :if={@task.is_milestone} class="text-yellow-500 text-2xl">⭐</span>
        {@task.title}
      </div>
      <:subtitle>{@task.description}</:subtitle>
      <:actions>
        <.link patch={~p"/festivals/#{@festival}/tasks/#{@task}/show/edit"} phx-click={JS.push_focus()}>
          <.button>編集</.button>
        </.link>
      </:actions>
    </.header>

    <div class="mt-8 grid grid-cols-1 gap-6 lg:grid-cols-2">
      <div>
        <.list>
          <:item title="状態">
            <.status_badge status={@task.status} />
          </:item>
          <:item title="優先度">
            <.priority_badge priority={@task.priority} />
          </:item>
          <:item title="進捗">
            <div class="flex items-center gap-4">
              <div class="flex-1 bg-gray-200 rounded-full h-2">
                <div class="bg-blue-600 h-2 rounded-full" style={"width: #{@task.progress_percent}%"}></div>
              </div>
              <span>{@task.progress_percent}%</span>
            </div>
          </:item>
          <:item title="開始日">{@task.start_date || "未設定"}</:item>
          <:item title="期限">{@task.due_date || "未設定"}</:item>
          <:item title="見積工数">{@task.estimated_hours || "未設定"} 時間</:item>
          <:item title="実績工数">{@task.actual_hours || "未設定"} 時間</:item>
          <:item title="担当者">{if @task.assignee, do: @task.assignee.email, else: "未割当"}</:item>
        </.list>
      </div>

      <div>
        <h3 class="text-lg font-semibold mb-4">チェックリスト</h3>
        <ul class="space-y-2">
          <li :for={item <- @checklist_items} class="flex items-center gap-3 p-2 bg-gray-50 rounded">
            <input
              type="checkbox"
              checked={item.is_completed}
              phx-click="toggle_checklist"
              phx-value-id={item.id}
              class="h-4 w-4 rounded border-gray-300"
            />
            <span class={if item.is_completed, do: "line-through text-gray-500", else: ""}>
              {item.content}
            </span>
          </li>
          <li :if={@checklist_items == []} class="text-gray-500">
            チェックリストがありません
          </li>
        </ul>
      </div>
    </div>

    <div :if={@task.children != []} class="mt-8">
      <h3 class="text-lg font-semibold mb-4">サブタスク</h3>
      <ul class="space-y-2">
        <li :for={child <- @task.children} class="p-3 bg-gray-50 rounded flex justify-between items-center">
          <.link navigate={~p"/festivals/#{@festival}/tasks/#{child}"} class="hover:underline">
            {child.title}
          </.link>
          <.status_badge status={child.status} />
        </li>
      </ul>
    </div>

    <.back navigate={~p"/festivals/#{@festival}/tasks"}>タスク一覧へ戻る</.back>

    <.modal :if={@live_action == :edit} id="task-modal" show on_cancel={JS.patch(~p"/festivals/#{@festival}/tasks/#{@task}")}>
      <.live_component
        module={MatsuriOpsWeb.TaskLive.FormComponent}
        id={@task.id}
        title="タスク編集"
        action={@live_action}
        task={@task}
        festival={@festival}
        categories={[]}
        patch={~p"/festivals/#{@festival}/tasks/#{@task}"}
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
