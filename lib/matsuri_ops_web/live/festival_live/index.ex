defmodule MatsuriOpsWeb.FestivalLive.Index do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.Festivals
  alias MatsuriOps.Festivals.Festival

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :festivals, Festivals.list_festivals())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "祭り編集")
    |> assign(:festival, Festivals.get_festival!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "新規祭り作成")
    |> assign(:festival, %Festival{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "祭り一覧")
    |> assign(:festival, nil)
  end

  @impl true
  def handle_info({MatsuriOpsWeb.FestivalLive.FormComponent, {:saved, festival}}, socket) do
    {:noreply, stream_insert(socket, :festivals, festival)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    festival = Festivals.get_festival!(id)
    {:ok, _} = Festivals.delete_festival(festival)

    {:noreply, stream_delete(socket, :festivals, festival)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      祭り一覧
      <:actions>
        <.link patch={~p"/festivals/new"}>
          <.button>新規作成</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="festivals"
      rows={@streams.festivals}
      row_click={fn {_id, festival} -> JS.navigate(~p"/festivals/#{festival}") end}
    >
      <:col :let={{_id, festival}} label="名前">{festival.name}</:col>
      <:col :let={{_id, festival}} label="開催日">{festival.start_date}</:col>
      <:col :let={{_id, festival}} label="規模">{festival.scale}</:col>
      <:col :let={{_id, festival}} label="状態">{festival.status}</:col>
      <:action :let={{_id, festival}}>
        <div class="sr-only">
          <.link navigate={~p"/festivals/#{festival}"}>表示</.link>
        </div>
        <.link patch={~p"/festivals/#{festival}/edit"}>編集</.link>
      </:action>
      <:action :let={{id, festival}}>
        <.link
          phx-click={JS.push("delete", value: %{id: festival.id}) |> hide("##{id}")}
          data-confirm="本当に削除しますか？"
        >
          削除
        </.link>
      </:action>
    </.table>

    <.modal :if={@live_action in [:new, :edit]} id="festival-modal" show on_cancel={JS.patch(~p"/festivals")}>
      <.live_component
        module={MatsuriOpsWeb.FestivalLive.FormComponent}
        id={@festival.id || :new}
        title={@page_title}
        action={@live_action}
        festival={@festival}
        patch={~p"/festivals"}
      />
    </.modal>
    """
  end
end
