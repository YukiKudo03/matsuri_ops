defmodule MatsuriOpsWeb.SocialMediaLive.Show do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.SocialMedia
  alias MatsuriOps.SocialMedia.SocialPost
  alias MatsuriOps.Festivals

  @impl true
  def mount(%{"festival_id" => festival_id, "id" => id}, _session, socket) do
    festival = Festivals.get_festival!(festival_id)
    social_post = SocialMedia.get_social_post!(id)

    {:ok,
     socket
     |> assign(:festival, festival)
     |> assign(:social_post, social_post)
     |> assign(:page_title, "投稿詳細")}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("post_now", _params, socket) do
    social_post = socket.assigns.social_post

    # 実際のSNS投稿は外部APIが必要だが、ここではシミュレーション
    external_ids =
      Enum.into(social_post.platforms, %{}, fn platform ->
        {platform, "simulated_#{platform}_#{:rand.uniform(1_000_000)}"}
      end)

    {:ok, updated} = SocialMedia.mark_as_posted(social_post, external_ids)

    {:noreply,
     socket
     |> assign(:social_post, updated)
     |> put_flash(:info, "投稿を実行しました（シミュレーション）")}
  end

  @impl true
  def handle_event("schedule", %{"scheduled_at" => scheduled_at}, socket) do
    case DateTime.from_iso8601(scheduled_at <> ":00Z") do
      {:ok, datetime, _} ->
        {:ok, updated} = SocialMedia.schedule_post(socket.assigns.social_post, datetime)

        {:noreply,
         socket
         |> assign(:social_post, updated)
         |> put_flash(:info, "投稿を予約しました")}

      _ ->
        {:noreply, put_flash(socket, :error, "無効な日時です")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <.header>
        投稿詳細
        <:subtitle>
          <span class={"px-2 py-1 text-xs rounded #{status_class(@social_post.status)}"}>
            {SocialPost.status_label(@social_post.status)}
          </span>
        </:subtitle>
        <:actions>
          <.button
            :if={@social_post.status in ["draft", "scheduled"]}
            phx-click="post_now"
            class="bg-green-600 hover:bg-green-700"
          >
            今すぐ投稿
          </.button>
          <.link patch={~p"/festivals/#{@festival}/social/#{@social_post}/edit"}>
            <.button>編集</.button>
          </.link>
          <.link navigate={~p"/festivals/#{@festival}/social"}>
            <.button class="bg-gray-200 text-gray-700 hover:bg-gray-300">一覧へ戻る</.button>
          </.link>
        </:actions>
      </.header>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div class="lg:col-span-2 space-y-6">
          <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-medium mb-4">投稿内容</h3>
            <div class="whitespace-pre-wrap text-gray-800 bg-gray-50 rounded p-4">
              {@social_post.content}
            </div>

            <div :if={@social_post.hashtags != []} class="mt-4">
              <h4 class="text-sm font-medium text-gray-500 mb-2">ハッシュタグ</h4>
              <div class="flex flex-wrap gap-2">
                <span
                  :for={hashtag <- @social_post.hashtags}
                  class="px-2 py-1 text-sm bg-blue-100 text-blue-700 rounded"
                >
                  {hashtag}
                </span>
              </div>
            </div>
          </div>

          <div :if={@social_post.media_urls != []} class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-medium mb-4">添付メディア</h3>
            <div class="grid grid-cols-2 gap-4">
              <img
                :for={url <- @social_post.media_urls}
                src={url}
                alt="添付画像"
                class="rounded-lg object-cover w-full h-48"
              />
            </div>
          </div>

          <div :if={@social_post.status == "draft"} class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-medium mb-4">予約投稿</h3>
            <form phx-submit="schedule" class="flex gap-4">
              <input
                type="datetime-local"
                name="scheduled_at"
                class="flex-1 rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              />
              <.button type="submit" class="bg-yellow-500 hover:bg-yellow-600">
                予約する
              </.button>
            </form>
          </div>
        </div>

        <div class="space-y-4">
          <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-medium mb-4">投稿情報</h3>
            <dl class="space-y-3">
              <div>
                <dt class="text-sm text-gray-500">投稿先</dt>
                <dd class="mt-1 flex gap-2">
                  <span
                    :for={platform <- @social_post.platforms}
                    class="px-2 py-1 text-xs rounded text-white bg-gray-700"
                  >
                    {platform_label(platform)}
                  </span>
                </dd>
              </div>
              <div :if={@social_post.scheduled_at}>
                <dt class="text-sm text-gray-500">予約日時</dt>
                <dd class="mt-1">{format_datetime(@social_post.scheduled_at)}</dd>
              </div>
              <div :if={@social_post.posted_at}>
                <dt class="text-sm text-gray-500">投稿日時</dt>
                <dd class="mt-1">{format_datetime(@social_post.posted_at)}</dd>
              </div>
              <div :if={@social_post.created_by}>
                <dt class="text-sm text-gray-500">作成者</dt>
                <dd class="mt-1">{@social_post.created_by.email}</dd>
              </div>
              <div>
                <dt class="text-sm text-gray-500">作成日</dt>
                <dd class="mt-1">{format_datetime(@social_post.inserted_at)}</dd>
              </div>
            </dl>
          </div>

          <div :if={@social_post.status == "posted"} class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-medium mb-4">エンゲージメント</h3>
            <div class="grid grid-cols-2 gap-4 text-center">
              <div>
                <p class="text-2xl font-bold text-pink-600">{@social_post.likes_count}</p>
                <p class="text-sm text-gray-500">いいね</p>
              </div>
              <div>
                <p class="text-2xl font-bold text-green-600">{@social_post.shares_count}</p>
                <p class="text-sm text-gray-500">シェア</p>
              </div>
              <div>
                <p class="text-2xl font-bold text-blue-600">{@social_post.comments_count}</p>
                <p class="text-sm text-gray-500">コメント</p>
              </div>
              <div>
                <p class="text-2xl font-bold text-purple-600">{@social_post.reach_count}</p>
                <p class="text-sm text-gray-500">リーチ</p>
              </div>
            </div>
          </div>

          <div :if={@social_post.external_ids != %{}} class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-medium mb-4">外部投稿ID</h3>
            <dl class="space-y-2 text-sm">
              <div :for={{platform, id} <- @social_post.external_ids}>
                <dt class="text-gray-500">{platform_label(platform)}</dt>
                <dd class="font-mono text-xs">{id}</dd>
              </div>
            </dl>
          </div>

          <div :if={@social_post.error_message} class="bg-red-50 rounded-lg p-4">
            <h4 class="font-medium text-red-900 mb-2">エラー</h4>
            <p class="text-sm text-red-800">{@social_post.error_message}</p>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp format_datetime(nil), do: "-"
  defp format_datetime(datetime), do: Calendar.strftime(datetime, "%Y/%m/%d %H:%M")

  defp status_class("draft"), do: "bg-gray-100 text-gray-700"
  defp status_class("scheduled"), do: "bg-yellow-100 text-yellow-700"
  defp status_class("posting"), do: "bg-blue-100 text-blue-700"
  defp status_class("posted"), do: "bg-green-100 text-green-700"
  defp status_class("failed"), do: "bg-red-100 text-red-700"
  defp status_class(_), do: "bg-gray-100 text-gray-500"

  defp platform_label("twitter"), do: "X (Twitter)"
  defp platform_label("instagram"), do: "Instagram"
  defp platform_label("facebook"), do: "Facebook"
  defp platform_label(other), do: other
end
