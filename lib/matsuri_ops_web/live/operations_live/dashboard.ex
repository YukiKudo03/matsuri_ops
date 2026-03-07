defmodule MatsuriOpsWeb.OperationsLive.Dashboard do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.Festivals
  alias MatsuriOps.Operations
  alias MatsuriOps.Operations.{Incident, AreaStatus}

  @impl true
  def mount(%{"festival_id" => festival_id}, _session, socket) do
    festival = Festivals.get_festival!(festival_id)

    if connected?(socket) do
      Operations.subscribe(festival_id)
    end

    incidents = Operations.list_active_incidents(festival_id)
    areas = Operations.list_area_status(festival_id)
    stats = Operations.incident_stats(festival_id)

    {:ok,
     socket
     |> assign(:festival, festival)
     |> assign(:stats, stats)
     |> stream(:incidents, incidents)
     |> stream(:areas, areas)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new_incident, _params) do
    socket
    |> assign(:page_title, "インシデント報告")
    |> assign(:incident, %Incident{festival_id: socket.assigns.festival.id})
  end

  defp apply_action(socket, :edit_incident, %{"id" => id}) do
    socket
    |> assign(:page_title, "インシデント編集")
    |> assign(:incident, Operations.get_incident!(id))
  end

  defp apply_action(socket, :new_area, _params) do
    socket
    |> assign(:page_title, "エリア追加")
    |> assign(:area_status, %AreaStatus{festival_id: socket.assigns.festival.id})
  end

  defp apply_action(socket, :edit_area, %{"id" => id}) do
    socket
    |> assign(:page_title, "エリア状況更新")
    |> assign(:area_status, Operations.get_area_status!(id))
  end

  defp apply_action(socket, :dashboard, _params) do
    socket
    |> assign(:page_title, "運営ダッシュボード - #{socket.assigns.festival.name}")
    |> assign(:incident, nil)
    |> assign(:area_status, nil)
  end

  @impl true
  def handle_info({:incident_created, incident}, socket) do
    incident = Operations.get_incident!(incident.id)
    stats = Operations.incident_stats(socket.assigns.festival.id)

    {:noreply,
     socket
     |> assign(:stats, stats)
     |> stream_insert(:incidents, incident, at: 0)}
  end

  @impl true
  def handle_info({:incident_updated, incident}, socket) do
    incident = Operations.get_incident!(incident.id)
    stats = Operations.incident_stats(socket.assigns.festival.id)

    if incident.status in ["resolved", "closed"] do
      {:noreply,
       socket
       |> assign(:stats, stats)
       |> stream_delete(:incidents, incident)}
    else
      {:noreply,
       socket
       |> assign(:stats, stats)
       |> stream_insert(:incidents, incident)}
    end
  end

  @impl true
  def handle_info({:area_updated, area}, socket) do
    {:noreply, stream_insert(socket, :areas, area)}
  end

  @impl true
  def handle_info({MatsuriOpsWeb.OperationsLive.IncidentFormComponent, {:saved, _incident}}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({MatsuriOpsWeb.OperationsLive.AreaFormComponent, {:saved, _area}}, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      {@festival.name} - 運営ダッシュボード
      <:actions>
        <.link patch={~p"/festivals/#{@festival}/operations/incidents/new"}>
          <.button variant="primary">インシデント報告</.button>
        </.link>
        <.link patch={~p"/festivals/#{@festival}/operations/areas/new"}>
          <.button variant="outline">エリア追加</.button>
        </.link>
        <.link navigate={~p"/festivals/#{@festival}"}>
          <.button variant="outline">祭り詳細へ</.button>
        </.link>
      </:actions>
    </.header>

    <div class="mt-6 grid grid-cols-2 sm:grid-cols-4 gap-4">
      <div class="stat bg-base-200 rounded-lg">
        <div class="stat-title">総インシデント</div>
        <div class="stat-value text-lg">{@stats.total}</div>
      </div>
      <div class="stat bg-red-100 rounded-lg">
        <div class="stat-title">重大（対応中）</div>
        <div class="stat-value text-lg text-red-600">{Map.get(@stats.active_by_severity, "critical", 0) + Map.get(@stats.active_by_severity, "high", 0)}</div>
      </div>
      <div class="stat bg-yellow-100 rounded-lg">
        <div class="stat-title">中程度（対応中）</div>
        <div class="stat-value text-lg text-yellow-600">{Map.get(@stats.active_by_severity, "medium", 0)}</div>
      </div>
      <div class="stat bg-green-100 rounded-lg">
        <div class="stat-title">解決済み</div>
        <div class="stat-value text-lg text-green-600">{Map.get(@stats.by_status, "resolved", 0) + Map.get(@stats.by_status, "closed", 0)}</div>
      </div>
    </div>

    <div class="mt-8">
      <h3 class="text-lg font-semibold mb-4">エリア混雑状況</h3>
      <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4">
        <div
          :for={{dom_id, area} <- @streams.areas}
          id={dom_id}
          class={["p-4 rounded-lg cursor-pointer hover:shadow-md transition-shadow", area_bg_color(area.crowd_level)]}
          phx-click={JS.patch(~p"/festivals/#{@festival}/operations/areas/#{area}/edit")}
        >
          <h4 class="font-medium">{area.name}</h4>
          <div class="text-2xl font-bold mt-2">{crowd_level_label(area.crowd_level)}</div>
          <div :if={area.weather_temp} class="text-sm mt-1">
            気温: {area.weather_temp}°C
            <span :if={area.weather_wbgt}> / WBGT: {area.weather_wbgt}</span>
          </div>
          <div class="text-xs text-gray-500 mt-1">
            更新: {format_datetime(area.updated_at)}
          </div>
        </div>
        <div :if={Enum.empty?(@streams.areas.inserts)} class="text-gray-500 col-span-full">
          エリアが登録されていません。「エリア追加」から追加してください。
        </div>
      </div>
    </div>

    <div class="mt-8">
      <h3 class="text-lg font-semibold mb-4">対応中インシデント</h3>
      <div class="space-y-4">
        <div
          :for={{dom_id, incident} <- @streams.incidents}
          id={dom_id}
          class={["p-4 rounded-lg border-l-4", incident_border_color(incident.severity)]}
          phx-click={JS.patch(~p"/festivals/#{@festival}/operations/incidents/#{incident}/edit")}
        >
          <div class="flex justify-between items-start">
            <div>
              <div class="flex items-center gap-2">
                <.severity_badge severity={incident.severity} />
                <.status_badge status={incident.status} />
                <span :if={incident.category} class="text-xs text-gray-500">{category_label(incident.category)}</span>
              </div>
              <h4 class="font-medium mt-1">{incident.title}</h4>
              <p :if={incident.location} class="text-sm text-gray-600">場所: {incident.location}</p>
            </div>
            <div class="text-xs text-gray-500 text-right">
              <div>報告: {format_datetime(incident.reported_at)}</div>
              <div :if={incident.assigned_to}>担当: {incident.assigned_to.name || incident.assigned_to.email}</div>
            </div>
          </div>
          <p :if={incident.description} class="mt-2 text-sm text-gray-700">{incident.description}</p>
        </div>
        <div :if={Enum.empty?(@streams.incidents.inserts)} class="text-gray-500 text-center py-8">
          対応中のインシデントはありません
        </div>
      </div>
    </div>

    <.back navigate={~p"/festivals/#{@festival}"}>祭り詳細へ戻る</.back>

    <.modal :if={@live_action in [:new_incident, :edit_incident]} id="incident-modal" show on_cancel={JS.patch(~p"/festivals/#{@festival}/operations")}>
      <.live_component
        module={MatsuriOpsWeb.OperationsLive.IncidentFormComponent}
        id={@incident.id || :new}
        title={@page_title}
        action={@live_action}
        incident={@incident}
        festival={@festival}
        current_user={@current_scope.user}
        patch={~p"/festivals/#{@festival}/operations"}
      />
    </.modal>

    <.modal :if={@live_action in [:new_area, :edit_area]} id="area-modal" show on_cancel={JS.patch(~p"/festivals/#{@festival}/operations")}>
      <.live_component
        module={MatsuriOpsWeb.OperationsLive.AreaFormComponent}
        id={@area_status.id || :new}
        title={@page_title}
        action={@live_action}
        area_status={@area_status}
        festival={@festival}
        current_user={@current_scope.user}
        patch={~p"/festivals/#{@festival}/operations"}
      />
    </.modal>
    """
  end

  defp area_bg_color(level) do
    case level do
      0 -> "bg-green-100"
      1 -> "bg-green-200"
      2 -> "bg-yellow-100"
      3 -> "bg-yellow-200"
      4 -> "bg-orange-200"
      5 -> "bg-red-200"
      _ -> "bg-gray-100"
    end
  end

  defp crowd_level_label(level) do
    MatsuriOps.Operations.AreaStatus.crowd_level_label(level)
  end

  defp incident_border_color(severity) do
    case severity do
      "critical" -> "border-red-500 bg-red-50"
      "high" -> "border-orange-500 bg-orange-50"
      "medium" -> "border-yellow-500 bg-yellow-50"
      "low" -> "border-blue-500 bg-blue-50"
      _ -> "border-gray-300 bg-gray-50"
    end
  end

  defp severity_badge(assigns) do
    {bg_color, text} =
      case assigns.severity do
        "critical" -> {"bg-red-500 text-white", "緊急"}
        "high" -> {"bg-orange-500 text-white", "高"}
        "medium" -> {"bg-yellow-500 text-white", "中"}
        "low" -> {"bg-blue-500 text-white", "低"}
        _ -> {"bg-gray-500 text-white", assigns.severity}
      end

    assigns = assign(assigns, :bg_color, bg_color)
    assigns = assign(assigns, :text, text)

    ~H"""
    <span class={"inline-flex items-center px-2 py-0.5 text-xs font-semibold rounded #{@bg_color}"}>
      {@text}
    </span>
    """
  end

  defp status_badge(assigns) do
    {bg_color, text} =
      case assigns.status do
        "reported" -> {"bg-gray-100 text-gray-700", "報告済"}
        "acknowledged" -> {"bg-blue-100 text-blue-700", "確認済"}
        "in_progress" -> {"bg-yellow-100 text-yellow-700", "対応中"}
        "resolved" -> {"bg-green-100 text-green-700", "解決済"}
        "closed" -> {"bg-gray-100 text-gray-500", "クローズ"}
        _ -> {"bg-gray-100 text-gray-700", assigns.status}
      end

    assigns = assign(assigns, :bg_color, bg_color)
    assigns = assign(assigns, :text, text)

    ~H"""
    <span class={"inline-flex items-center px-2 py-0.5 text-xs rounded #{@bg_color}"}>
      {@text}
    </span>
    """
  end

  defp category_label(category) do
    case category do
      "medical" -> "医療"
      "security" -> "警備"
      "lost_item" -> "落とし物"
      "weather" -> "天候"
      "equipment" -> "設備"
      "other" -> "その他"
      _ -> category
    end
  end

  defp format_datetime(nil), do: "-"
  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%H:%M")
  end
end
