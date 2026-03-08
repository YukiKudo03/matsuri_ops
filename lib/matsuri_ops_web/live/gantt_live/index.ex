defmodule MatsuriOpsWeb.GanttLive.Index do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.Gantt
  alias MatsuriOps.Festivals

  @impl true
  def mount(%{"festival_id" => festival_id}, _session, socket) do
    festival = Festivals.get_festival!(festival_id)
    gantt_data = Gantt.get_gantt_data(festival_id)
    dependencies = Gantt.get_task_dependencies(festival_id)
    timeline_range = Gantt.calculate_timeline_range(festival_id)

    {:ok,
     socket
     |> assign(:festival, festival)
     |> assign(:page_title, "ガントチャート")
     |> assign(:gantt_data, gantt_data)
     |> assign(:dependencies, dependencies)
     |> assign(:timeline_range, timeline_range)
     |> assign(:date_columns, generate_date_columns(timeline_range))}
  end

  defp generate_date_columns(nil), do: []
  defp generate_date_columns({start_date, end_date}) do
    Gantt.generate_date_columns(start_date, end_date)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <.header>
        ガントチャート
        <:subtitle>{@festival.name}のタスクスケジュール</:subtitle>
        <:actions>
          <.link navigate={~p"/festivals/#{@festival}/tasks"}>
            <.button>タスク一覧</.button>
          </.link>
        </:actions>
      </.header>

      <div :if={@timeline_range == nil} class="text-center py-8 text-gray-500">
        表示するタスクがありません。タスクに日付を設定してください。
      </div>

      <div :if={@timeline_range != nil} class="overflow-x-auto">
        <div class="min-w-[800px]">
          <!-- Timeline Header -->
          <div class="flex border-b border-gray-300 bg-gray-100">
            <div class="w-48 flex-shrink-0 p-2 font-medium border-r">タスク名</div>
            <div class="flex-1 flex">
              <div
                :for={date <- @date_columns}
                class={"flex-1 text-center text-xs p-1 border-r #{weekend_class(date)}"}
              >
                {Calendar.strftime(date, "%m/%d")}
              </div>
            </div>
          </div>

          <!-- Task Rows -->
          <div :for={task <- @gantt_data} class="flex border-b border-gray-200 hover:bg-gray-50">
            <div class="w-48 flex-shrink-0 p-2 truncate border-r" title={task.name}>
              {task.name}
            </div>
            <div class="flex-1 relative h-10">
              <div
                class={"absolute top-1 h-8 rounded #{status_color(task.status)}"}
                style={bar_style(task, @timeline_range)}
              >
                <div
                  class="h-full bg-green-600 rounded-l"
                  style={"width: #{task.progress}%"}
                >
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Legend -->
      <div :if={@timeline_range != nil} class="flex gap-4 text-sm">
        <div class="flex items-center gap-2">
          <div class="w-4 h-4 bg-blue-200 rounded"></div>
          <span>未着手</span>
        </div>
        <div class="flex items-center gap-2">
          <div class="w-4 h-4 bg-yellow-200 rounded"></div>
          <span>進行中</span>
        </div>
        <div class="flex items-center gap-2">
          <div class="w-4 h-4 bg-green-200 rounded"></div>
          <span>完了</span>
        </div>
        <div class="flex items-center gap-2">
          <div class="w-4 h-2 bg-green-600 rounded"></div>
          <span>進捗</span>
        </div>
      </div>
    </div>
    """
  end

  defp weekend_class(date) do
    day_of_week = Date.day_of_week(date)
    if day_of_week in [6, 7], do: "bg-gray-200", else: ""
  end

  defp status_color("completed"), do: "bg-green-200"
  defp status_color("in_progress"), do: "bg-yellow-200"
  defp status_color(_), do: "bg-blue-200"

  defp bar_style(task, {start_date, end_date}) do
    total_days = Date.diff(end_date, start_date) + 1
    position = Gantt.calculate_bar_position(task, start_date, total_days)

    "left: #{position.left_percent}%; width: #{position.width_percent}%"
  end
end
