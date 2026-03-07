defmodule MatsuriOpsWeb.OperationsLive.AreaFormComponent do
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
        id="area-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="エリア名" required />
        <.input
          field={@form[:crowd_level]}
          type="select"
          label="混雑度"
          options={[{"閑散 (0)", "0"}, {"やや空き (1)", "1"}, {"通常 (2)", "2"}, {"やや混雑 (3)", "3"}, {"混雑 (4)", "4"}, {"非常に混雑 (5)", "5"}]}
        />
        <.input field={@form[:weather_temp]} type="number" step="0.1" label="気温 (°C)" />
        <.input field={@form[:weather_wbgt]} type="number" step="0.1" label="WBGT" />
        <.input field={@form[:notes]} type="textarea" label="備考" />
        <:actions>
          <.button phx-disable-with="保存中...">保存</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{area_status: area_status} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Operations.change_area_status(area_status))
     end)}
  end

  @impl true
  def handle_event("validate", %{"area_status" => area_params}, socket) do
    changeset = Operations.change_area_status(socket.assigns.area_status, area_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"area_status" => area_params}, socket) do
    area_params =
      area_params
      |> Map.put("festival_id", socket.assigns.festival.id)
      |> Map.put("updated_by_id", socket.assigns.current_user.id)

    save_area(socket, socket.assigns.action, area_params)
  end

  defp save_area(socket, :edit_area, area_params) do
    case Operations.update_area_status(socket.assigns.area_status, area_params) do
      {:ok, area} ->
        notify_parent({:saved, area})

        {:noreply,
         socket
         |> put_flash(:info, "エリア状況を更新しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_area(socket, :new_area, area_params) do
    case Operations.create_area_status(area_params) do
      {:ok, area} ->
        notify_parent({:saved, area})

        {:noreply,
         socket
         |> put_flash(:info, "エリアを追加しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
