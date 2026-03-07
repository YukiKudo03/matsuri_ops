defmodule MatsuriOpsWeb.BudgetLive.CategoryFormComponent do
  use MatsuriOpsWeb, :live_component

  alias MatsuriOps.Budgets

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.simple_form
        for={@form}
        id="category-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="カテゴリ名" required />
        <.input field={@form[:description]} type="textarea" label="説明" />
        <.input field={@form[:budget_amount]} type="number" step="1" label="予算額" required />
        <.input field={@form[:sort_order]} type="number" label="表示順" />
        <:actions>
          <.button phx-disable-with="保存中...">保存</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{budget_category: budget_category} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Budgets.change_budget_category(budget_category))
     end)}
  end

  @impl true
  def handle_event("validate", %{"budget_category" => category_params}, socket) do
    changeset = Budgets.change_budget_category(socket.assigns.budget_category, category_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"budget_category" => category_params}, socket) do
    category_params = Map.put(category_params, "festival_id", socket.assigns.festival.id)
    save_category(socket, socket.assigns.action, category_params)
  end

  defp save_category(socket, :edit_category, category_params) do
    case Budgets.update_budget_category(socket.assigns.budget_category, category_params) do
      {:ok, category} ->
        notify_parent({:saved, category})

        {:noreply,
         socket
         |> put_flash(:info, "カテゴリを更新しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_category(socket, :new_category, category_params) do
    case Budgets.create_budget_category(category_params) do
      {:ok, category} ->
        notify_parent({:saved, category})

        {:noreply,
         socket
         |> put_flash(:info, "カテゴリを追加しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
