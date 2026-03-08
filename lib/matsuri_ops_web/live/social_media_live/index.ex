defmodule MatsuriOpsWeb.SocialMediaLive.Index do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.SocialMedia
  alias MatsuriOps.SocialMedia.SocialPost
  alias MatsuriOps.Festivals

  @impl true
  def mount(%{"festival_id" => festival_id}, _session, socket) do
    festival = Festivals.get_festival!(festival_id)
    social_posts = SocialMedia.list_social_posts(festival_id)
    statistics = SocialMedia.get_statistics(festival_id)

    {:ok,
     socket
     |> assign(:festival, festival)
     |> assign(:page_title, "SNS投稿管理")
     |> assign(:statistics, statistics)
     |> assign(:filter_status, "all")
     |> stream(:social_posts, social_posts)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "投稿を編集")
    |> assign(:social_post, SocialMedia.get_social_post!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "新しい投稿")
    |> assign(:social_post, %SocialPost{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "SNS投稿管理")
    |> assign(:social_post, nil)
  end

  @impl true
  def handle_event("filter", %{"status" => status}, socket) do
    festival_id = socket.assigns.festival.id

    social_posts =
      if status == "all" do
        SocialMedia.list_social_posts(festival_id)
      else
        SocialMedia.list_posts_by_status(festival_id, status)
      end

    {:noreply,
     socket
     |> assign(:filter_status, status)
     |> stream(:social_posts, social_posts, reset: true)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    social_post = SocialMedia.get_social_post!(id)
    {:ok, _} = SocialMedia.delete_social_post(social_post)

    {:noreply, stream_delete(socket, :social_posts, social_post)}
  end

  @impl true
  def handle_event("duplicate", %{"id" => id}, socket) do
    social_post = SocialMedia.get_social_post!(id)
    {:ok, new_post} = SocialMedia.duplicate_post(social_post)

    {:noreply,
     socket
     |> stream_insert(:social_posts, new_post, at: 0)
     |> put_flash(:info, "投稿をコピーしました")}
  end

  @impl true
  def handle_info({MatsuriOpsWeb.SocialMediaLive.FormComponent, {:saved, social_post}}, socket) do
    {:noreply, stream_insert(socket, :social_posts, social_post)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <.header>
        SNS投稿管理
        <:subtitle>{@festival.name}のSNS投稿</:subtitle>
        <:actions>
          <.link patch={~p"/festivals/#{@festival}/social/new"}>
            <.button>新規投稿</.button>
          </.link>
          <.link navigate={~p"/festivals/#{@festival}/social/accounts"}>
            <.button class="bg-purple-600 hover:bg-purple-700">
              アカウント設定 ({@statistics.connected_accounts})
            </.button>
          </.link>
          <.link navigate={~p"/festivals/#{@festival}"}>
            <.button class="bg-gray-200 text-gray-700 hover:bg-gray-300">祭り詳細へ</.button>
          </.link>
        </:actions>
      </.header>

      <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div class="bg-blue-50 rounded-lg p-4">
          <p class="text-sm text-gray-600">総投稿数</p>
          <p class="text-2xl font-bold text-blue-600">{@statistics.total_posts}</p>
        </div>
        <div class="bg-green-50 rounded-lg p-4">
          <p class="text-sm text-gray-600">投稿済</p>
          <p class="text-2xl font-bold text-green-600">{@statistics.posted_count}</p>
        </div>
        <div class="bg-purple-50 rounded-lg p-4">
          <p class="text-sm text-gray-600">総いいね</p>
          <p class="text-2xl font-bold text-purple-600">{@statistics.total_likes}</p>
        </div>
        <div class="bg-orange-50 rounded-lg p-4">
          <p class="text-sm text-gray-600">総リーチ</p>
          <p class="text-2xl font-bold text-orange-600">{@statistics.total_reach}</p>
        </div>
      </div>

      <div class="flex gap-2">
        <.button
          phx-click="filter"
          phx-value-status="all"
          class={if @filter_status == "all", do: "bg-blue-600", else: "bg-gray-300 text-gray-700"}
        >
          すべて
        </.button>
        <.button
          :for={status <- SocialPost.statuses()}
          phx-click="filter"
          phx-value-status={status}
          class={if @filter_status == status, do: "bg-blue-600", else: "bg-gray-300 text-gray-700"}
        >
          {SocialPost.status_label(status)}
        </.button>
      </div>

      <.table
        id="social_posts"
        rows={@streams.social_posts}
        row_click={fn {_id, social_post} -> JS.navigate(~p"/festivals/#{@festival}/social/#{social_post}") end}
      >
        <:col :let={{_id, social_post}} label="内容">
          <div class="max-w-md truncate">{social_post.content}</div>
        </:col>
        <:col :let={{_id, social_post}} label="プラットフォーム">
          <div class="flex gap-1">
            <span
              :for={platform <- social_post.platforms}
              class="px-2 py-1 text-xs rounded text-white bg-gray-700"
            >
              {platform_icon(platform)}
            </span>
          </div>
        </:col>
        <:col :let={{_id, social_post}} label="ステータス">
          <span class={"px-2 py-1 text-xs rounded #{status_class(social_post.status)}"}>
            {SocialPost.status_label(social_post.status)}
          </span>
        </:col>
        <:col :let={{_id, social_post}} label="予約日時">
          {format_datetime(social_post.scheduled_at)}
        </:col>
        <:col :let={{_id, social_post}} label="エンゲージメント">
          <span class="font-mono text-sm">
            ♥{social_post.likes_count} 🔄{social_post.shares_count}
          </span>
        </:col>
        <:action :let={{_id, social_post}}>
          <.link
            phx-click="duplicate"
            phx-value-id={social_post.id}
          >
            コピー
          </.link>
        </:action>
        <:action :let={{_id, social_post}}>
          <.link patch={~p"/festivals/#{@festival}/social/#{social_post}/edit"}>編集</.link>
        </:action>
        <:action :let={{id, social_post}}>
          <.link
            phx-click={JS.push("delete", value: %{id: social_post.id}) |> hide("##{id}")}
            data-confirm="本当に削除しますか？"
          >
            削除
          </.link>
        </:action>
      </.table>

      <.modal :if={@live_action in [:new, :edit]} id="social-post-modal" show on_cancel={JS.patch(~p"/festivals/#{@festival}/social")}>
        <.live_component
          module={MatsuriOpsWeb.SocialMediaLive.FormComponent}
          id={@social_post.id || :new}
          title={@page_title}
          action={@live_action}
          social_post={@social_post}
          festival={@festival}
          current_user={@current_scope.user}
          patch={~p"/festivals/#{@festival}/social"}
        />
      </.modal>
    </div>
    """
  end

  defp status_class("draft"), do: "bg-gray-100 text-gray-700"
  defp status_class("scheduled"), do: "bg-yellow-100 text-yellow-700"
  defp status_class("posting"), do: "bg-blue-100 text-blue-700"
  defp status_class("posted"), do: "bg-green-100 text-green-700"
  defp status_class("failed"), do: "bg-red-100 text-red-700"
  defp status_class(_), do: "bg-gray-100 text-gray-500"

  defp platform_icon("twitter"), do: "X"
  defp platform_icon("instagram"), do: "IG"
  defp platform_icon("facebook"), do: "FB"
  defp platform_icon(other), do: other

  defp format_datetime(nil), do: "-"
  defp format_datetime(datetime), do: Calendar.strftime(datetime, "%Y/%m/%d %H:%M")
end
