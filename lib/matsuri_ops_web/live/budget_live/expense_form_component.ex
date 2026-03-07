defmodule MatsuriOpsWeb.BudgetLive.ExpenseFormComponent do
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
        id="expense-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="項目名" required />
        <.input field={@form[:description]} type="textarea" label="説明" />
        <.input
          field={@form[:category_id]}
          type="select"
          label="カテゴリ"
          options={[{"未分類", nil}] ++ Enum.map(@categories, &{&1.name, &1.id})}
        />
        <.input field={@form[:amount]} type="number" step="1" label="金額" required />
        <.input field={@form[:quantity]} type="number" label="数量" />
        <.input field={@form[:unit_price]} type="number" step="1" label="単価" />
        <.input field={@form[:expense_date]} type="date" label="支出日" />
        <.input
          field={@form[:payment_method]}
          type="select"
          label="支払方法"
          options={[{"未選択", nil}, {"現金", "cash"}, {"銀行振込", "bank_transfer"}, {"クレジットカード", "credit_card"}, {"その他", "other"}]}
        />
        <.input field={@form[:receipt_number]} type="text" label="領収書番号" />
        <.input field={@form[:notes]} type="textarea" label="備考" />
        <:actions>
          <.button phx-disable-with="保存中...">保存</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{expense: expense} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Budgets.change_expense(expense))
     end)}
  end

  @impl true
  def handle_event("validate", %{"expense" => expense_params}, socket) do
    changeset = Budgets.change_expense(socket.assigns.expense, expense_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"expense" => expense_params}, socket) do
    expense_params = Map.put(expense_params, "festival_id", socket.assigns.festival.id)

    expense_params =
      if socket.assigns.expense.id == nil do
        Map.put(expense_params, "submitted_by_id", socket.assigns.current_scope.user.id)
      else
        expense_params
      end

    save_expense(socket, socket.assigns.action, expense_params)
  end

  defp save_expense(socket, :edit_expense, expense_params) do
    case Budgets.update_expense(socket.assigns.expense, expense_params) do
      {:ok, expense} ->
        notify_parent({:saved, expense})

        {:noreply,
         socket
         |> put_flash(:info, "経費を更新しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_expense(socket, :new_expense, expense_params) do
    case Budgets.create_expense(expense_params) do
      {:ok, expense} ->
        notify_parent({:saved, expense})

        {:noreply,
         socket
         |> put_flash(:info, "経費を登録しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
