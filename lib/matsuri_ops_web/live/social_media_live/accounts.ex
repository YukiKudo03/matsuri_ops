defmodule MatsuriOpsWeb.SocialMediaLive.Accounts do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.SocialMedia
  alias MatsuriOps.SocialMedia.SocialAccount
  alias MatsuriOps.Festivals

  @impl true
  def mount(%{"festival_id" => festival_id}, _session, socket) do
    festival = Festivals.get_festival!(festival_id)
    social_accounts = SocialMedia.list_social_accounts(festival_id)

    {:ok,
     socket
     |> assign(:festival, festival)
     |> assign(:page_title, "SNSアカウント設定")
     |> assign(:editing_account, nil)
     |> stream(:social_accounts, social_accounts)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("add_account", %{"platform" => platform}, socket) do
    # 実際の実装ではOAuth認証フローを開始する
    attrs = %{
      platform: platform,
      account_name: "#{platform}_demo_account",
      account_id: "demo_#{:rand.uniform(1_000_000)}",
      festival_id: socket.assigns.festival.id,
      is_active: true
    }

    case SocialMedia.create_social_account(attrs) do
      {:ok, account} ->
        {:noreply,
         socket
         |> stream_insert(:social_accounts, account)
         |> put_flash(:info, "#{SocialAccount.platform_label(platform)}アカウントを追加しました（デモ）")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "アカウントの追加に失敗しました")}
    end
  end

  @impl true
  def handle_event("toggle_active", %{"id" => id}, socket) do
    account = SocialMedia.get_social_account!(id)
    {:ok, updated} = SocialMedia.update_social_account(account, %{is_active: !account.is_active})

    {:noreply, stream_insert(socket, :social_accounts, updated)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    account = SocialMedia.get_social_account!(id)
    {:ok, _} = SocialMedia.delete_social_account(account)

    {:noreply,
     socket
     |> stream_delete(:social_accounts, account)
     |> put_flash(:info, "アカウントを削除しました")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <.header>
        SNSアカウント設定
        <:subtitle>{@festival.name}のSNSアカウント</:subtitle>
        <:actions>
          <.link navigate={~p"/festivals/#{@festival}/social"}>
            <.button class="bg-gray-200 text-gray-700 hover:bg-gray-300">投稿一覧へ</.button>
          </.link>
        </:actions>
      </.header>

      <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-6">
        <h4 class="font-medium text-yellow-900 mb-2">デモモード</h4>
        <p class="text-sm text-yellow-800">
          現在、SNS連携はデモモードで動作しています。実際のSNSアカウントを連携するには、
          各プラットフォームのAPI設定が必要です。
        </p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div
          :for={platform <- SocialAccount.platforms()}
          class="bg-white rounded-lg shadow p-6"
        >
          <div class="flex items-center gap-4 mb-4">
            <div class={"w-12 h-12 rounded-full flex items-center justify-center text-white #{platform_bg(platform)}"}>
              {platform_icon(platform)}
            </div>
            <div>
              <h3 class="font-medium">{SocialAccount.platform_label(platform)}</h3>
              <p class="text-sm text-gray-500">{platform_description(platform)}</p>
            </div>
          </div>

          <.button
            phx-click="add_account"
            phx-value-platform={platform}
            class="w-full bg-blue-600 hover:bg-blue-700"
          >
            アカウントを追加
          </.button>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow">
        <div class="px-6 py-4 border-b">
          <h3 class="text-lg font-medium">連携済みアカウント</h3>
        </div>

        <.table
          id="social_accounts"
          rows={@streams.social_accounts}
        >
          <:col :let={{_id, account}} label="プラットフォーム">
            <div class="flex items-center gap-2">
              <div class={"w-8 h-8 rounded-full flex items-center justify-center text-white text-xs #{platform_bg(account.platform)}"}>
                {platform_icon(account.platform)}
              </div>
              <span>{SocialAccount.platform_label(account.platform)}</span>
            </div>
          </:col>
          <:col :let={{_id, account}} label="アカウント名">{account.account_name}</:col>
          <:col :let={{_id, account}} label="状態">
            <span class={"px-2 py-1 text-xs rounded #{if account.is_active, do: "bg-green-100 text-green-700", else: "bg-gray-100 text-gray-500"}"}>
              {if account.is_active, do: "有効", else: "無効"}
            </span>
          </:col>
          <:col :let={{_id, account}} label="トークン状態">
            <span class={"px-2 py-1 text-xs rounded #{if SocialAccount.token_valid?(account), do: "bg-green-100 text-green-700", else: "bg-red-100 text-red-700"}"}>
              {if SocialAccount.token_valid?(account), do: "有効", else: "期限切れ"}
            </span>
          </:col>
          <:action :let={{_id, account}}>
            <.link
              phx-click="toggle_active"
              phx-value-id={account.id}
            >
              {if account.is_active, do: "無効化", else: "有効化"}
            </.link>
          </:action>
          <:action :let={{id, account}}>
            <.link
              phx-click={JS.push("delete", value: %{id: account.id}) |> hide("##{id}")}
              data-confirm="本当に削除しますか？"
            >
              削除
            </.link>
          </:action>
        </.table>
      </div>
    </div>
    """
  end

  defp platform_bg("twitter"), do: "bg-black"
  defp platform_bg("instagram"), do: "bg-gradient-to-br from-purple-500 to-pink-500"
  defp platform_bg("facebook"), do: "bg-blue-600"
  defp platform_bg(_), do: "bg-gray-500"

  defp platform_icon("twitter"), do: "X"
  defp platform_icon("instagram"), do: "IG"
  defp platform_icon("facebook"), do: "FB"
  defp platform_icon(_), do: "?"

  defp platform_description("twitter"), do: "ツイートで情報を発信"
  defp platform_description("instagram"), do: "写真や動画で祭りの魅力を伝える"
  defp platform_description("facebook"), do: "イベント情報やコミュニティ運営"
  defp platform_description(_), do: ""
end
