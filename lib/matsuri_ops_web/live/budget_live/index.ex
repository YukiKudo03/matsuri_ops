defmodule MatsuriOpsWeb.BudgetLive.Index do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.Festivals
  alias MatsuriOps.Budgets
  alias MatsuriOps.Budgets.{BudgetCategory, Expense}

  @impl true
  def mount(%{"festival_id" => festival_id}, _session, socket) do
    festival = Festivals.get_festival!(festival_id)
    budget_summary = Budgets.budget_summary(festival_id)
    categories = Budgets.list_budget_categories(festival_id)
    expenses = Budgets.list_expenses(festival_id)

    {:ok,
     socket
     |> assign(:festival, festival)
     |> assign(:budget_summary, budget_summary)
     |> assign(:categories, categories)
     |> stream(:expenses, expenses)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit_expense, %{"id" => id}) do
    socket
    |> assign(:page_title, "経費編集")
    |> assign(:expense, Budgets.get_expense!(id))
    |> assign(:budget_category, nil)
  end

  defp apply_action(socket, :new_expense, _params) do
    socket
    |> assign(:page_title, "経費登録")
    |> assign(:expense, %Expense{festival_id: socket.assigns.festival.id})
    |> assign(:budget_category, nil)
  end

  defp apply_action(socket, :edit_category, %{"id" => id}) do
    socket
    |> assign(:page_title, "予算カテゴリ編集")
    |> assign(:budget_category, Budgets.get_budget_category!(id))
    |> assign(:expense, nil)
  end

  defp apply_action(socket, :new_category, _params) do
    socket
    |> assign(:page_title, "予算カテゴリ追加")
    |> assign(:budget_category, %BudgetCategory{festival_id: socket.assigns.festival.id})
    |> assign(:expense, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "予算・経費管理 - #{socket.assigns.festival.name}")
    |> assign(:expense, nil)
    |> assign(:budget_category, nil)
  end

  @impl true
  def handle_info({MatsuriOpsWeb.BudgetLive.ExpenseFormComponent, {:saved, expense}}, socket) do
    budget_summary = Budgets.budget_summary(socket.assigns.festival.id)

    {:noreply,
     socket
     |> assign(:budget_summary, budget_summary)
     |> stream_insert(:expenses, expense)}
  end

  @impl true
  def handle_info({MatsuriOpsWeb.BudgetLive.CategoryFormComponent, {:saved, _category}}, socket) do
    categories = Budgets.list_budget_categories(socket.assigns.festival.id)
    budget_summary = Budgets.budget_summary(socket.assigns.festival.id)

    {:noreply,
     socket
     |> assign(:categories, categories)
     |> assign(:budget_summary, budget_summary)}
  end

  @impl true
  def handle_event("delete_expense", %{"id" => id}, socket) do
    expense = Budgets.get_expense!(id)
    {:ok, _} = Budgets.delete_expense(expense)
    budget_summary = Budgets.budget_summary(socket.assigns.festival.id)

    {:noreply,
     socket
     |> assign(:budget_summary, budget_summary)
     |> stream_delete(:expenses, expense)}
  end

  @impl true
  def handle_event("approve_expense", %{"id" => id}, socket) do
    expense = Budgets.get_expense!(id)
    user_id = socket.assigns.current_scope.user.id
    {:ok, updated_expense} = Budgets.approve_expense(expense, user_id)
    budget_summary = Budgets.budget_summary(socket.assigns.festival.id)

    {:noreply,
     socket
     |> assign(:budget_summary, budget_summary)
     |> stream_insert(:expenses, updated_expense)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      {@festival.name} - 予算・経費管理
      <:actions>
        <.link patch={~p"/festivals/#{@festival}/budgets/categories/new"}>
          <.button variant="outline">カテゴリ追加</.button>
        </.link>
        <.link patch={~p"/festivals/#{@festival}/budgets/expenses/new"}>
          <.button>経費登録</.button>
        </.link>
        <.link navigate={~p"/festivals/#{@festival}"}>
          <.button variant="outline">祭り詳細へ</.button>
        </.link>
      </:actions>
    </.header>

    <div class="mt-6 grid grid-cols-1 gap-4 sm:grid-cols-3">
      <div class="stat bg-base-200 rounded-lg">
        <div class="stat-title">総予算</div>
        <div class="stat-value text-lg">¥{format_amount(@budget_summary.total_budget)}</div>
      </div>
      <div class="stat bg-base-200 rounded-lg">
        <div class="stat-title">支出済み</div>
        <div class="stat-value text-lg text-error">¥{format_amount(@budget_summary.total_spent)}</div>
      </div>
      <div class="stat bg-base-200 rounded-lg">
        <div class="stat-title">残り予算</div>
        <div class="stat-value text-lg text-success">¥{format_amount(@budget_summary.remaining_budget)}</div>
      </div>
    </div>

    <div class="mt-8">
      <h3 class="text-lg font-semibold mb-4">予算カテゴリ</h3>
      <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <div :for={cat <- @budget_summary.categories} class="p-4 bg-gray-50 rounded-lg">
          <div class="flex justify-between items-start">
            <h4 class="font-medium">{cat.name}</h4>
            <.link patch={~p"/festivals/#{@festival}/budgets/categories/#{cat.id}/edit"} class="text-sm text-blue-600 hover:underline">
              編集
            </.link>
          </div>
          <div class="mt-2">
            <div class="flex justify-between text-sm">
              <span>予算: ¥{format_amount(cat.budget)}</span>
              <span>支出: ¥{format_amount(cat.spent)}</span>
            </div>
            <div class="mt-1 bg-gray-200 rounded-full h-2">
              <div
                class={["h-2 rounded-full", budget_bar_color(cat.budget, cat.spent)]}
                style={"width: #{min(budget_percentage(cat.budget, cat.spent), 100)}%"}
              ></div>
            </div>
            <div class="text-xs text-gray-500 mt-1">
              残り: ¥{format_amount(cat.remaining)}
            </div>
          </div>
        </div>
        <div :if={@budget_summary.categories == []} class="text-gray-500 col-span-full">
          予算カテゴリがありません。「カテゴリ追加」から追加してください。
        </div>
      </div>
    </div>

    <div class="mt-8">
      <h3 class="text-lg font-semibold mb-4">経費一覧</h3>
      <.table
        id="expenses"
        rows={@streams.expenses}
        row_click={fn {_id, expense} -> JS.patch(~p"/festivals/#{@festival}/budgets/expenses/#{expense}/edit") end}
      >
        <:col :let={{_id, expense}} label="項目">{expense.title}</:col>
        <:col :let={{_id, expense}} label="金額">¥{format_amount(expense.amount)}</:col>
        <:col :let={{_id, expense}} label="日付">{expense.expense_date}</:col>
        <:col :let={{_id, expense}} label="状態">
          <.expense_status_badge status={expense.status} />
        </:col>
        <:action :let={{_id, expense}}>
          <.link
            :if={expense.status == "pending"}
            phx-click="approve_expense"
            phx-value-id={expense.id}
            class="text-green-600 hover:underline"
          >
            承認
          </.link>
        </:action>
        <:action :let={{id, expense}}>
          <.link
            phx-click={JS.push("delete_expense", value: %{id: expense.id}) |> hide("##{id}")}
            data-confirm="本当に削除しますか？"
          >
            削除
          </.link>
        </:action>
      </.table>
    </div>

    <.back navigate={~p"/festivals/#{@festival}"}>祭り詳細へ戻る</.back>

    <.modal :if={@live_action in [:new_expense, :edit_expense]} id="expense-modal" show on_cancel={JS.patch(~p"/festivals/#{@festival}/budgets")}>
      <.live_component
        module={MatsuriOpsWeb.BudgetLive.ExpenseFormComponent}
        id={@expense.id || :new}
        title={@page_title}
        action={@live_action}
        expense={@expense}
        festival={@festival}
        categories={@categories}
        patch={~p"/festivals/#{@festival}/budgets"}
      />
    </.modal>

    <.modal :if={@live_action in [:new_category, :edit_category]} id="category-modal" show on_cancel={JS.patch(~p"/festivals/#{@festival}/budgets")}>
      <.live_component
        module={MatsuriOpsWeb.BudgetLive.CategoryFormComponent}
        id={@budget_category.id || :new}
        title={@page_title}
        action={@live_action}
        budget_category={@budget_category}
        festival={@festival}
        patch={~p"/festivals/#{@festival}/budgets"}
      />
    </.modal>
    """
  end

  defp format_amount(amount) do
    amount
    |> Decimal.round(0)
    |> Decimal.to_integer()
    |> Integer.to_string()
    |> String.reverse()
    |> String.replace(~r/(\d{3})(?=\d)/, "\\1,")
    |> String.reverse()
  end

  defp budget_percentage(budget, spent) do
    if Decimal.compare(budget, 0) == :gt do
      Decimal.div(spent, budget)
      |> Decimal.mult(100)
      |> Decimal.round(0)
      |> Decimal.to_integer()
    else
      0
    end
  end

  defp budget_bar_color(budget, spent) do
    percentage = budget_percentage(budget, spent)

    cond do
      percentage >= 100 -> "bg-red-500"
      percentage >= 80 -> "bg-yellow-500"
      true -> "bg-green-500"
    end
  end

  defp expense_status_badge(assigns) do
    {bg_color, text} =
      case assigns.status do
        "pending" -> {"bg-gray-100 text-gray-700", "申請中"}
        "submitted" -> {"bg-blue-100 text-blue-700", "提出済"}
        "approved" -> {"bg-green-100 text-green-700", "承認済"}
        "rejected" -> {"bg-red-100 text-red-700", "却下"}
        "paid" -> {"bg-purple-100 text-purple-700", "支払済"}
        _ -> {"bg-gray-100 text-gray-700", assigns.status}
      end

    assigns = assign(assigns, :bg_color, bg_color)
    assigns = assign(assigns, :text, text)

    ~H"""
    <span class={"inline-flex items-center px-2 py-1 text-xs rounded #{@bg_color}"}>
      {@text}
    </span>
    """
  end
end
