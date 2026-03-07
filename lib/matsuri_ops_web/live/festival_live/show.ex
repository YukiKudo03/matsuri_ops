defmodule MatsuriOpsWeb.FestivalLive.Show do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.Festivals
  alias MatsuriOps.Tasks

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    festival = Festivals.get_festival_with_members!(id)
    task_categories = Tasks.list_task_categories(id)
    tasks = Tasks.list_root_tasks(id)

    {:noreply,
     socket
     |> assign(:page_title, festival.name)
     |> assign(:festival, festival)
     |> assign(:task_categories, task_categories)
     |> assign(:tasks, tasks)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      {@festival.name}
      <:subtitle>{@festival.description}</:subtitle>
      <:actions>
        <.link patch={~p"/festivals/#{@festival}/edit"} phx-click={JS.push_focus()}>
          <.button>編集</.button>
        </.link>
        <.link navigate={~p"/festivals/#{@festival}/tasks"}>
          <.button>タスク管理</.button>
        </.link>
        <.link navigate={~p"/festivals/#{@festival}/budgets"}>
          <.button>予算管理</.button>
        </.link>
        <.link navigate={~p"/festivals/#{@festival}/staff"}>
          <.button>スタッフ管理</.button>
        </.link>
        <.link navigate={~p"/festivals/#{@festival}/operations"}>
          <.button variant="primary">運営ダッシュボード</.button>
        </.link>
      </:actions>
    </.header>

    <div class="mt-8 grid grid-cols-1 gap-6 lg:grid-cols-2">
      <.list>
        <:item title="開催期間">{@festival.start_date} 〜 {@festival.end_date}</:item>
        <:item title="会場">{@festival.venue_name || "未設定"}</:item>
        <:item title="住所">{@festival.venue_address || "未設定"}</:item>
        <:item title="規模">
          <%= case @festival.scale do
            "small" -> "小規模 (~2,000人)"
            "medium" -> "中規模 (2,000~10,000人)"
            "large" -> "大規模 (10,000人~)"
          end %>
        </:item>
        <:item title="予想来場者数">{@festival.expected_visitors || "未設定"} 人</:item>
        <:item title="予想出店数">{@festival.expected_vendors || "未設定"} 店</:item>
        <:item title="状態">
          <%= case @festival.status do
            "planning" -> "企画中"
            "preparation" -> "準備中"
            "active" -> "開催中"
            "completed" -> "終了"
            "cancelled" -> "中止"
          end %>
        </:item>
      </.list>

      <div>
        <h3 class="text-lg font-semibold mb-4">メンバー ({length(@festival.festival_members)}名)</h3>
        <ul class="space-y-2">
          <li :for={member <- @festival.festival_members} class="flex items-center justify-between p-2 bg-gray-50 rounded">
            <span>{member.user.email}</span>
            <span class="text-sm text-gray-600">{member.role}</span>
          </li>
          <li :if={@festival.festival_members == []} class="text-gray-500">
            メンバーが登録されていません
          </li>
        </ul>
      </div>
    </div>

    <div class="mt-8">
      <h3 class="text-lg font-semibold mb-4">タスク概要</h3>
      <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <div :for={category <- @task_categories} class="p-4 bg-gray-50 rounded-lg">
          <h4 class="font-medium">{category.name}</h4>
          <p class="text-sm text-gray-600">{category.description}</p>
        </div>
        <div :if={@task_categories == []} class="text-gray-500 col-span-full">
          タスクカテゴリが設定されていません
        </div>
      </div>
    </div>

    <.back navigate={~p"/festivals"}>戻る</.back>

    <.modal :if={@live_action == :edit} id="festival-modal" show on_cancel={JS.patch(~p"/festivals/#{@festival}")}>
      <.live_component
        module={MatsuriOpsWeb.FestivalLive.FormComponent}
        id={@festival.id}
        title="祭り編集"
        action={@live_action}
        festival={@festival}
        patch={~p"/festivals/#{@festival}"}
      />
    </.modal>
    """
  end
end
