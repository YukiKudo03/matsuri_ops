defmodule MatsuriOpsWeb.StaffLive.FormComponent do
  use MatsuriOpsWeb, :live_component

  alias MatsuriOps.Festivals
  alias MatsuriOps.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.simple_form
        for={@form}
        id="member-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          :if={@action == :new}
          field={@form[:user_id]}
          type="select"
          label="ユーザー"
          options={Enum.map(@all_users, &{&1.name || &1.email, &1.id})}
          required
        />
        <.input
          field={@form[:role]}
          type="select"
          label="役割"
          options={[
            {"実行委員", "executive"},
            {"事務局", "admin"},
            {"リーダー", "leader"},
            {"スタッフ", "staff"},
            {"ボランティア", "volunteer"},
            {"出店者", "vendor"}
          ]}
          required
        />
        <.input field={@form[:assigned_area]} type="text" label="担当エリア" />
        <.input field={@form[:notes]} type="textarea" label="備考" />
        <:actions>
          <.button phx-disable-with="保存中...">保存</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{festival_member: festival_member} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Festivals.change_festival_member(festival_member))
     end)}
  end

  @impl true
  def handle_event("validate", %{"festival_member" => member_params}, socket) do
    changeset = Festivals.change_festival_member(socket.assigns.festival_member, member_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"festival_member" => member_params}, socket) do
    member_params = Map.put(member_params, "festival_id", socket.assigns.festival.id)
    save_member(socket, socket.assigns.action, member_params)
  end

  defp save_member(socket, :edit, member_params) do
    case Festivals.update_festival_member(socket.assigns.festival_member, member_params) do
      {:ok, member} ->
        notify_parent({:saved, member})

        {:noreply,
         socket
         |> put_flash(:info, "メンバー情報を更新しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_member(socket, :new, member_params) do
    case Festivals.add_member_to_festival(member_params) do
      {:ok, member} ->
        notify_parent({:saved, member})

        {:noreply,
         socket
         |> put_flash(:info, "メンバーを追加しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
