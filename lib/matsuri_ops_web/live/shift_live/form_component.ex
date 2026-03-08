defmodule MatsuriOpsWeb.ShiftLive.FormComponent do
  use MatsuriOpsWeb, :live_component

  alias MatsuriOps.Shifts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>シフト情報を入力してください</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="shift-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="シフト名" />
        <.input field={@form[:start_time]} type="datetime-local" label="開始時間" />
        <.input field={@form[:end_time]} type="datetime-local" label="終了時間" />
        <.input field={@form[:location]} type="text" label="場所" />
        <.input field={@form[:required_staff]} type="number" label="必要人数" min="1" />
        <.input field={@form[:description]} type="textarea" label="説明（任意）" />

        <:actions>
          <.button phx-disable-with="保存中...">保存</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{shift: shift} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Shifts.change_shift(shift))
     end)}
  end

  @impl true
  def handle_event("validate", %{"shift" => shift_params}, socket) do
    changeset = Shifts.change_shift(socket.assigns.shift, shift_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"shift" => shift_params}, socket) do
    save_shift(socket, socket.assigns.action, shift_params)
  end

  defp save_shift(socket, :edit, shift_params) do
    case Shifts.update_shift(socket.assigns.shift, shift_params) do
      {:ok, shift} ->
        notify_parent({:saved, shift})

        {:noreply,
         socket
         |> put_flash(:info, "シフトを更新しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_shift(socket, :new, shift_params) do
    shift_params = Map.put(shift_params, "festival_id", socket.assigns.festival.id)

    case Shifts.create_shift(shift_params) do
      {:ok, shift} ->
        notify_parent({:saved, shift})

        {:noreply,
         socket
         |> put_flash(:info, "シフトを作成しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
