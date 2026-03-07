defmodule MatsuriOpsWeb.FestivalLive.FormComponent do
  use MatsuriOpsWeb, :live_component

  alias MatsuriOps.Festivals

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.simple_form
        for={@form}
        id="festival-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="祭り名" required />
        <.input field={@form[:description]} type="textarea" label="概要" />
        <.input
          field={@form[:scale]}
          type="select"
          label="規模"
          options={[{"小規模 (~2,000人)", "small"}, {"中規模 (2,000~10,000人)", "medium"}, {"大規模 (10,000人~)", "large"}]}
        />
        <.input field={@form[:start_date]} type="date" label="開始日" required />
        <.input field={@form[:end_date]} type="date" label="終了日" required />
        <.input field={@form[:venue_name]} type="text" label="会場名" />
        <.input field={@form[:venue_address]} type="text" label="会場住所" />
        <.input field={@form[:expected_visitors]} type="number" label="予想来場者数" />
        <.input field={@form[:expected_vendors]} type="number" label="予想出店数" />
        <.input
          field={@form[:status]}
          type="select"
          label="状態"
          options={[{"企画中", "planning"}, {"準備中", "preparation"}, {"開催中", "active"}, {"終了", "completed"}, {"中止", "cancelled"}]}
        />
        <:actions>
          <.button phx-disable-with="保存中...">保存</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{festival: festival} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Festivals.change_festival(festival))
     end)}
  end

  @impl true
  def handle_event("validate", %{"festival" => festival_params}, socket) do
    changeset = Festivals.change_festival(socket.assigns.festival, festival_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"festival" => festival_params}, socket) do
    save_festival(socket, socket.assigns.action, festival_params)
  end

  defp save_festival(socket, :edit, festival_params) do
    case Festivals.update_festival(socket.assigns.festival, festival_params) do
      {:ok, festival} ->
        notify_parent({:saved, festival})

        {:noreply,
         socket
         |> put_flash(:info, "祭り情報を更新しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_festival(socket, :new, festival_params) do
    case Festivals.create_festival(festival_params) do
      {:ok, festival} ->
        notify_parent({:saved, festival})

        {:noreply,
         socket
         |> put_flash(:info, "祭りを作成しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
