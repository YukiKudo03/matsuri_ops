defmodule MatsuriOpsWeb.StaffLive.Index do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.Festivals
  alias MatsuriOps.Festivals.FestivalMember
  alias MatsuriOps.Accounts

  @impl true
  def mount(%{"festival_id" => festival_id}, _session, socket) do
    festival = Festivals.get_festival_with_members!(festival_id)
    all_users = Accounts.list_users()

    {:ok,
     socket
     |> assign(:festival, festival)
     |> assign(:all_users, all_users)
     |> stream(:members, festival.festival_members)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "メンバー編集")
    |> assign(:festival_member, Festivals.get_festival_member!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "メンバー追加")
    |> assign(:festival_member, %FestivalMember{festival_id: socket.assigns.festival.id})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "スタッフ管理 - #{socket.assigns.festival.name}")
    |> assign(:festival_member, nil)
  end

  @impl true
  def handle_info({MatsuriOpsWeb.StaffLive.FormComponent, {:saved, member}}, socket) do
    member = Festivals.get_festival_member!(member.id) |> MatsuriOps.Repo.preload(:user)
    {:noreply, stream_insert(socket, :members, member)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    member = Festivals.get_festival_member!(id)
    {:ok, _} = Festivals.remove_member_from_festival(member)

    {:noreply, stream_delete(socket, :members, member)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      {@festival.name} - スタッフ管理
      <:actions>
        <.link patch={~p"/festivals/#{@festival}/staff/new"}>
          <.button>メンバー追加</.button>
        </.link>
        <.link navigate={~p"/festivals/#{@festival}"}>
          <.button variant="outline">祭り詳細へ</.button>
        </.link>
      </:actions>
    </.header>

    <div class="mt-6 grid grid-cols-2 sm:grid-cols-4 gap-4">
      <div class="stat bg-base-200 rounded-lg">
        <div class="stat-title">総スタッフ数</div>
        <div class="stat-value text-lg">{count_members(@streams.members)} 名</div>
      </div>
      <div class="stat bg-base-200 rounded-lg">
        <div class="stat-title">リーダー</div>
        <div class="stat-value text-lg">{count_by_role(@streams.members, "leader")} 名</div>
      </div>
      <div class="stat bg-base-200 rounded-lg">
        <div class="stat-title">スタッフ</div>
        <div class="stat-value text-lg">{count_by_role(@streams.members, "staff")} 名</div>
      </div>
      <div class="stat bg-base-200 rounded-lg">
        <div class="stat-title">ボランティア</div>
        <div class="stat-value text-lg">{count_by_role(@streams.members, "volunteer")} 名</div>
      </div>
    </div>

    <.table
      id="members"
      rows={@streams.members}
      row_click={fn {_id, member} -> JS.patch(~p"/festivals/#{@festival}/staff/#{member}/edit") end}
    >
      <:col :let={{_id, member}} label="名前">
        {member.user.name || member.user.email}
      </:col>
      <:col :let={{_id, member}} label="メール">{member.user.email}</:col>
      <:col :let={{_id, member}} label="役割">
        <.role_badge role={member.role} />
      </:col>
      <:col :let={{_id, member}} label="担当エリア">{member.assigned_area || "-"}</:col>
      <:col :let={{_id, member}} label="連絡先">{member.user.phone || "-"}</:col>
      <:action :let={{_id, member}}>
        <.link patch={~p"/festivals/#{@festival}/staff/#{member}/edit"}>編集</.link>
      </:action>
      <:action :let={{id, member}}>
        <.link
          phx-click={JS.push("delete", value: %{id: member.id}) |> hide("##{id}")}
          data-confirm="本当に削除しますか？"
        >
          削除
        </.link>
      </:action>
    </.table>

    <.back navigate={~p"/festivals/#{@festival}"}>祭り詳細へ戻る</.back>

    <.modal :if={@live_action in [:new, :edit]} id="member-modal" show on_cancel={JS.patch(~p"/festivals/#{@festival}/staff")}>
      <.live_component
        module={MatsuriOpsWeb.StaffLive.FormComponent}
        id={@festival_member.id || :new}
        title={@page_title}
        action={@live_action}
        festival_member={@festival_member}
        festival={@festival}
        all_users={@all_users}
        patch={~p"/festivals/#{@festival}/staff"}
      />
    </.modal>
    """
  end

  defp count_members(%Phoenix.LiveView.LiveStream{inserts: inserts}) do
    length(inserts)
  end

  defp count_by_role(%Phoenix.LiveView.LiveStream{inserts: inserts}, role) do
    Enum.count(inserts, fn {_dom_id, _order, member} -> member.role == role end)
  end

  defp role_badge(assigns) do
    {bg_color, text} =
      case assigns.role do
        "system_admin" -> {"bg-purple-100 text-purple-700", "システム管理者"}
        "executive" -> {"bg-red-100 text-red-700", "実行委員"}
        "admin" -> {"bg-orange-100 text-orange-700", "事務局"}
        "leader" -> {"bg-blue-100 text-blue-700", "リーダー"}
        "staff" -> {"bg-green-100 text-green-700", "スタッフ"}
        "volunteer" -> {"bg-gray-100 text-gray-700", "ボランティア"}
        "vendor" -> {"bg-yellow-100 text-yellow-700", "出店者"}
        "visitor" -> {"bg-gray-100 text-gray-500", "来場者"}
        _ -> {"bg-gray-100 text-gray-700", assigns.role}
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
