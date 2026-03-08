defmodule MatsuriOpsWeb.ShiftLive.Index do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.Shifts
  alias MatsuriOps.Shifts.Shift
  alias MatsuriOps.Festivals

  @impl true
  def mount(%{"festival_id" => festival_id}, _session, socket) do
    festival = Festivals.get_festival!(festival_id)
    shifts_by_date = Shifts.list_shifts_by_date(festival_id)
    shifts = Shifts.list_shifts(festival_id)

    {:ok,
     socket
     |> assign(:festival, festival)
     |> assign(:page_title, "シフト管理")
     |> assign(:shifts_by_date, shifts_by_date)
     |> assign(:has_shifts, length(shifts) > 0)
     |> stream(:shifts, shifts)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "シフトを編集")
    |> assign(:shift, Shifts.get_shift!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "新しいシフト")
    |> assign(:shift, %Shift{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "シフト管理")
    |> assign(:shift, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    shift = Shifts.get_shift!(id)
    {:ok, _} = Shifts.delete_shift(shift)

    shifts = Shifts.list_shifts(socket.assigns.festival.id)
    shifts_by_date = Shifts.list_shifts_by_date(socket.assigns.festival.id)

    {:noreply,
     socket
     |> assign(:shifts_by_date, shifts_by_date)
     |> assign(:has_shifts, length(shifts) > 0)
     |> stream_delete(:shifts, shift)}
  end

  @impl true
  def handle_info({MatsuriOpsWeb.ShiftLive.FormComponent, {:saved, _shift}}, socket) do
    shifts = Shifts.list_shifts(socket.assigns.festival.id)
    shifts_by_date = Shifts.list_shifts_by_date(socket.assigns.festival.id)

    {:noreply,
     socket
     |> assign(:shifts_by_date, shifts_by_date)
     |> assign(:has_shifts, length(shifts) > 0)
     |> stream(:shifts, shifts, reset: true)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <.header>
        シフト管理
        <:subtitle>{@festival.name}のシフト</:subtitle>
        <:actions>
          <.link patch={~p"/festivals/#{@festival}/shifts/new"}>
            <.button>新規シフト</.button>
          </.link>
        </:actions>
      </.header>

      <div :if={not @has_shifts} class="text-center py-8 text-gray-500">
        シフトがありません
      </div>

      <div :if={@has_shifts} class="space-y-6">
        <div :for={{date, shifts} <- Enum.sort(@shifts_by_date)} class="bg-white rounded-lg shadow p-4">
          <h3 class="text-lg font-medium mb-4">{format_date(date)}</h3>
          <div class="grid gap-4">
            <div :for={shift <- shifts} class="border rounded-lg p-4 hover:bg-gray-50">
              <div class="flex justify-between items-start">
                <div>
                  <h4 class="font-medium">{shift.name}</h4>
                  <p class="text-sm text-gray-600">
                    {format_time(shift.start_time)} - {format_time(shift.end_time)}
                  </p>
                  <p :if={shift.location} class="text-sm text-gray-500">
                    📍 {shift.location}
                  </p>
                  <p class="text-sm text-gray-500 mt-1">
                    必要人数: {shift.required_staff}人
                  </p>
                </div>
                <div class="flex gap-2">
                  <.link patch={~p"/festivals/#{@festival}/shifts/#{shift}/edit"}>
                    <.button class="text-sm">編集</.button>
                  </.link>
                  <.button
                    class="text-sm"
                    phx-click="delete"
                    phx-value-id={shift.id}
                    data-confirm="本当に削除しますか？"
                  >
                    削除
                  </.button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <.modal :if={@live_action in [:new, :edit]} id="shift-modal" show on_cancel={JS.patch(~p"/festivals/#{@festival}/shifts")}>
        <.live_component
          module={MatsuriOpsWeb.ShiftLive.FormComponent}
          id={@shift.id || :new}
          title={@page_title}
          action={@live_action}
          shift={@shift}
          festival={@festival}
          patch={~p"/festivals/#{@festival}/shifts"}
        />
      </.modal>
    </div>
    """
  end

  defp format_date(date) do
    Calendar.strftime(date, "%Y年%m月%d日 (%a)")
  end

  defp format_time(datetime) do
    Calendar.strftime(datetime, "%H:%M")
  end
end
