defmodule MatsuriOpsWeb.OperationsLive.IncidentFormComponent do
  use MatsuriOpsWeb, :live_component

  alias MatsuriOps.Operations

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.simple_form
        for={@form}
        id="incident-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="タイトル" required />
        <.input field={@form[:description]} type="textarea" label="詳細" />
        <.input
          field={@form[:severity]}
          type="select"
          label="重要度"
          options={[{"低", "low"}, {"中", "medium"}, {"高", "high"}, {"緊急", "critical"}]}
        />
        <.input
          field={@form[:category]}
          type="select"
          label="カテゴリ"
          options={[{"未分類", nil}, {"医療", "medical"}, {"警備", "security"}, {"落とし物", "lost_item"}, {"天候", "weather"}, {"設備", "equipment"}, {"その他", "other"}]}
        />
        <.input field={@form[:location]} type="text" label="発生場所" />
        <.input
          field={@form[:status]}
          type="select"
          label="状態"
          options={[{"報告済", "reported"}, {"確認済", "acknowledged"}, {"対応中", "in_progress"}, {"解決済", "resolved"}, {"クローズ", "closed"}]}
        />
        <.input :if={@action == :edit_incident} field={@form[:resolution]} type="textarea" label="対応内容" />
        <:actions>
          <.button phx-disable-with="保存中...">保存</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{incident: incident} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Operations.change_incident(incident))
     end)}
  end

  @impl true
  def handle_event("validate", %{"incident" => incident_params}, socket) do
    changeset = Operations.change_incident(socket.assigns.incident, incident_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"incident" => incident_params}, socket) do
    incident_params = Map.put(incident_params, "festival_id", socket.assigns.festival.id)

    incident_params =
      if socket.assigns.incident.id == nil do
        Map.put(incident_params, "reported_by_id", socket.assigns.current_user.id)
      else
        incident_params
      end

    save_incident(socket, socket.assigns.action, incident_params)
  end

  defp save_incident(socket, :edit_incident, incident_params) do
    case Operations.update_incident(socket.assigns.incident, incident_params) do
      {:ok, incident} ->
        notify_parent({:saved, incident})

        {:noreply,
         socket
         |> put_flash(:info, "インシデントを更新しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_incident(socket, :new_incident, incident_params) do
    case Operations.create_incident(incident_params) do
      {:ok, incident} ->
        notify_parent({:saved, incident})

        {:noreply,
         socket
         |> put_flash(:info, "インシデントを報告しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
