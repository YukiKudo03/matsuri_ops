defmodule MatsuriOpsWeb.TaskLive.FormComponent do
  use MatsuriOpsWeb, :live_component

  alias MatsuriOps.Tasks

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.simple_form
        for={@form}
        id="task-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="タイトル" required />
        <.input field={@form[:description]} type="textarea" label="説明" />
        <.input
          field={@form[:category_id]}
          type="select"
          label="カテゴリ"
          options={[{"なし", nil}] ++ Enum.map(@categories, &{&1.name, &1.id})}
        />
        <.input
          field={@form[:status]}
          type="select"
          label="状態"
          options={[{"未着手", "pending"}, {"進行中", "in_progress"}, {"完了", "completed"}, {"ブロック", "blocked"}, {"キャンセル", "cancelled"}]}
        />
        <.input
          field={@form[:priority]}
          type="select"
          label="優先度"
          options={[{"低", "low"}, {"中", "medium"}, {"高", "high"}, {"緊急", "urgent"}]}
        />
        <.input field={@form[:start_date]} type="date" label="開始日" />
        <.input field={@form[:due_date]} type="date" label="期限" />
        <.input field={@form[:estimated_hours]} type="number" step="0.5" label="見積工数（時間）" />
        <.input field={@form[:progress_percent]} type="number" min="0" max="100" label="進捗（%）" />
        <.input field={@form[:is_milestone]} type="checkbox" label="マイルストーン" />
        <:actions>
          <.button phx-disable-with="保存中...">保存</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{task: task} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Tasks.change_task(task))
     end)}
  end

  @impl true
  def handle_event("validate", %{"task" => task_params}, socket) do
    changeset = Tasks.change_task(socket.assigns.task, task_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"task" => task_params}, socket) do
    task_params = Map.put(task_params, "festival_id", socket.assigns.festival.id)
    save_task(socket, socket.assigns.action, task_params)
  end

  defp save_task(socket, :edit, task_params) do
    case Tasks.update_task(socket.assigns.task, task_params) do
      {:ok, task} ->
        notify_parent({:saved, task})

        {:noreply,
         socket
         |> put_flash(:info, "タスクを更新しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_task(socket, :new, task_params) do
    case Tasks.create_task(task_params) do
      {:ok, task} ->
        notify_parent({:saved, task})

        {:noreply,
         socket
         |> put_flash(:info, "タスクを作成しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
