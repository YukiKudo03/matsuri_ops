defmodule MatsuriOpsWeb.AnnouncementLive.FormComponent do
  use MatsuriOpsWeb, :live_component

  alias MatsuriOps.Notifications

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>お知らせの内容を入力してください</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="announcement-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="タイトル" />
        <.input field={@form[:content]} type="textarea" label="内容" />
        <.input
          field={@form[:priority]}
          type="select"
          label="優先度"
          options={[
            {"緊急", "urgent"},
            {"重要", "high"},
            {"通常", "normal"},
            {"低", "low"}
          ]}
        />
        <.input
          field={@form[:target_audience]}
          type="select"
          label="対象者"
          options={[
            {"全員", "all"},
            {"スタッフのみ", "staff"},
            {"管理者のみ", "admin"}
          ]}
        />
        <.input field={@form[:expires_at]} type="datetime-local" label="有効期限（任意）" />

        <:actions>
          <.button phx-disable-with="保存中...">保存</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{announcement: announcement} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Notifications.change_announcement(announcement))
     end)}
  end

  @impl true
  def handle_event("validate", %{"announcement" => announcement_params}, socket) do
    changeset = Notifications.change_announcement(socket.assigns.announcement, announcement_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"announcement" => announcement_params}, socket) do
    save_announcement(socket, socket.assigns.action, announcement_params)
  end

  defp save_announcement(socket, :edit, announcement_params) do
    case Notifications.update_announcement(socket.assigns.announcement, announcement_params) do
      {:ok, announcement} ->
        notify_parent({:saved, announcement})

        {:noreply,
         socket
         |> put_flash(:info, "お知らせを更新しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_announcement(socket, :new, announcement_params) do
    announcement_params =
      announcement_params
      |> Map.put("festival_id", socket.assigns.festival.id)
      |> Map.put("created_by_id", socket.assigns.current_user.id)

    case Notifications.create_announcement(announcement_params) do
      {:ok, announcement} ->
        notify_parent({:saved, announcement})

        {:noreply,
         socket
         |> put_flash(:info, "お知らせを作成しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
