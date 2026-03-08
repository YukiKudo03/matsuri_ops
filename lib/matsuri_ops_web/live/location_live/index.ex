defmodule MatsuriOpsWeb.LocationLive.Index do
  @moduledoc """
  スタッフ位置表示のLiveView。
  """

  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.Festivals
  alias MatsuriOps.Locations

  @impl true
  def mount(%{"festival_id" => festival_id}, _session, socket) do
    festival = Festivals.get_festival!(festival_id)
    current_user = socket.assigns.current_scope.user
    locations = Locations.list_staff_locations(festival_id, within_minutes: 30)
    my_location = Locations.get_staff_location(festival_id, current_user.id)

    if connected?(socket) do
      Locations.subscribe(festival_id)
    end

    {:ok,
     socket
     |> assign(:page_title, "スタッフ位置 - #{festival.name}")
     |> assign(:festival, festival)
     |> assign(:current_user, current_user)
     |> assign(:my_location, my_location)
     |> stream(:locations, locations)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("update_location", params, socket) do
    attrs = %{
      user_id: socket.assigns.current_user.id,
      festival_id: socket.assigns.festival.id,
      latitude: params["latitude"],
      longitude: params["longitude"],
      accuracy: params["accuracy"],
      heading: params["heading"],
      speed: params["speed"]
    }

    case Locations.update_staff_location(attrs) do
      {:ok, location} ->
        {:noreply,
         socket
         |> assign(:my_location, location)
         |> put_flash(:info, "位置を更新しました")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "位置の更新に失敗しました")}
    end
  end

  @impl true
  def handle_info({:location_updated, location}, socket) do
    {:noreply, stream_insert(socket, :locations, location)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      {@festival.name} - スタッフ位置
      <:actions>
        <.link navigate={~p"/festivals/#{@festival}"}>
          <.button variant="outline">祭り詳細へ</.button>
        </.link>
      </:actions>
    </.header>

    <div class="mt-6 grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div class="lg:col-span-2">
        <div
          id="map"
          class="w-full h-[400px] bg-base-200 rounded-lg flex items-center justify-center"
          phx-hook="LocationMap"
          data-locations={Jason.encode!(format_locations_for_map(@streams.locations))}
        >
          <p class="text-gray-500">会場マップ</p>
        </div>

        <div class="mt-4 flex gap-2">
          <.button phx-click={JS.dispatch("request-location")}>
            現在位置を取得
          </.button>
          <p :if={@my_location} class="text-sm text-gray-500 flex items-center">
            最終更新: {format_time(@my_location.updated_at)}
          </p>
        </div>
      </div>

      <div>
        <h2 class="text-lg font-semibold mb-4">スタッフ一覧</h2>
        <div class="space-y-2">
          <.staff_card :for={{dom_id, location} <- @streams.locations} location={location} id={dom_id} />
        </div>
        <p :if={Enum.empty?(@streams.locations.inserts)} class="text-gray-500 text-sm">
          位置情報を共有しているスタッフはいません
        </p>
      </div>
    </div>

    <.back navigate={~p"/festivals/#{@festival}"}>祭り詳細へ戻る</.back>
    """
  end

  defp staff_card(assigns) do
    ~H"""
    <div id={@id} class="p-3 bg-base-200 rounded-lg">
      <div class="flex items-center justify-between">
        <div>
          <p class="font-medium">{@location.user.name || @location.user.email}</p>
          <p class="text-xs text-gray-500">
            {format_coordinates(@location.latitude, @location.longitude)}
          </p>
        </div>
        <span class="text-xs text-gray-500">{format_time(@location.updated_at)}</span>
      </div>
    </div>
    """
  end

  defp format_coordinates(lat, lng) do
    "#{Float.round(lat, 4)}, #{Float.round(lng, 4)}"
  end

  defp format_time(datetime) do
    Calendar.strftime(datetime, "%H:%M")
  end

  defp format_locations_for_map(%Phoenix.LiveView.LiveStream{inserts: inserts}) do
    Enum.map(inserts, fn tuple ->
      # Handle different tuple sizes (3 or 5 elements)
      location = elem(tuple, 2)
      %{
        id: location.id,
        latitude: location.latitude,
        longitude: location.longitude,
        name: location.user.name || location.user.email
      }
    end)
  end
end
