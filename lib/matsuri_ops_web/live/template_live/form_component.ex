defmodule MatsuriOpsWeb.TemplateLive.FormComponent do
  @moduledoc """
  テンプレート作成・編集用のフォームコンポーネント。
  """

  use MatsuriOpsWeb, :live_component

  alias MatsuriOps.Templates

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.simple_form
        for={@form}
        id="template-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="名前" />
        <.input field={@form[:description]} type="textarea" label="説明" />
        <.input
          field={@form[:scale]}
          type="select"
          label="規模"
          options={[{"小規模", "small"}, {"中規模", "medium"}, {"大規模", "large"}]}
        />
        <.input field={@form[:default_expected_visitors]} type="number" label="想定来場者数" />
        <.input field={@form[:default_expected_vendors]} type="number" label="想定出店数" />
        <.input field={@form[:is_public]} type="checkbox" label="公開する" />

        <:actions>
          <.button phx-disable-with="保存中...">保存</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{template: template} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Templates.change_template(template))
     end)}
  end

  @impl true
  def handle_event("validate", %{"template" => template_params}, socket) do
    changeset = Templates.change_template(socket.assigns.template, template_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"template" => template_params}, socket) do
    save_template(socket, socket.assigns.action, template_params)
  end

  defp save_template(socket, :edit, template_params) do
    case Templates.update_template(socket.assigns.template, template_params) do
      {:ok, template} ->
        notify_parent({:saved, template})

        {:noreply,
         socket
         |> put_flash(:info, "テンプレートを更新しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_template(socket, :new, template_params) do
    case Templates.create_template(socket.assigns.current_user, template_params) do
      {:ok, template} ->
        notify_parent({:saved, template})

        {:noreply,
         socket
         |> put_flash(:info, "テンプレートを作成しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
