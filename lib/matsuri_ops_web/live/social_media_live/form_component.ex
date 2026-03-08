defmodule MatsuriOpsWeb.SocialMediaLive.FormComponent do
  use MatsuriOpsWeb, :live_component

  alias MatsuriOps.SocialMedia
  alias MatsuriOps.SocialMedia.SocialPost

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>SNS投稿を作成・編集します</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="social-post-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:content]}
          type="textarea"
          label="投稿内容"
          placeholder="投稿内容を入力..."
          rows="5"
        />

        <div class="flex gap-2 text-sm text-gray-500">
          <span :for={platform <- @selected_platforms}>
            {platform}: {@char_counts[platform] || 0} / {SocialPost.character_limit(platform)}
          </span>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            投稿先プラットフォーム
          </label>
          <div class="flex gap-4">
            <label :for={platform <- SocialPost.available_platforms()} class="flex items-center gap-2">
              <input
                type="checkbox"
                name="social_post[platforms][]"
                value={platform}
                checked={platform in @selected_platforms}
                class="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
              />
              <span>{platform_label(platform)}</span>
            </label>
          </div>
        </div>

        <.input
          field={@form[:scheduled_at]}
          type="datetime-local"
          label="予約投稿日時（空欄の場合は即時投稿）"
        />

        <div :if={@preview_hashtags != []} class="mt-4">
          <p class="text-sm font-medium text-gray-700 mb-2">検出されたハッシュタグ</p>
          <div class="flex flex-wrap gap-2">
            <span
              :for={hashtag <- @preview_hashtags}
              class="px-2 py-1 text-sm bg-blue-100 text-blue-700 rounded"
            >
              {hashtag}
            </span>
          </div>
        </div>

        <:actions>
          <.button phx-disable-with="保存中...">保存</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{social_post: social_post} = assigns, socket) do
    content = social_post.content || ""
    platforms = social_post.platforms || []

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:selected_platforms, platforms)
     |> assign(:char_counts, calculate_char_counts(content, platforms))
     |> assign(:preview_hashtags, SocialPost.extract_hashtags(content))
     |> assign_new(:form, fn ->
       to_form(SocialMedia.change_social_post(social_post))
     end)}
  end

  @impl true
  def handle_event("validate", %{"social_post" => social_post_params}, socket) do
    platforms = Map.get(social_post_params, "platforms", [])
    content = Map.get(social_post_params, "content", "")

    changeset =
      socket.assigns.social_post
      |> SocialMedia.change_social_post(social_post_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:selected_platforms, platforms)
     |> assign(:char_counts, calculate_char_counts(content, platforms))
     |> assign(:preview_hashtags, SocialPost.extract_hashtags(content))
     |> assign(form: to_form(changeset))}
  end

  def handle_event("save", %{"social_post" => social_post_params}, socket) do
    save_social_post(socket, socket.assigns.action, social_post_params)
  end

  defp save_social_post(socket, :edit, social_post_params) do
    case SocialMedia.update_social_post(socket.assigns.social_post, social_post_params) do
      {:ok, social_post} ->
        social_post = MatsuriOps.Repo.preload(social_post, :created_by)
        notify_parent({:saved, social_post})

        {:noreply,
         socket
         |> put_flash(:info, "投稿を更新しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_social_post(socket, :new, social_post_params) do
    social_post_params =
      social_post_params
      |> Map.put("festival_id", socket.assigns.festival.id)
      |> Map.put("created_by_id", socket.assigns.current_user.id)

    case SocialMedia.create_social_post(social_post_params) do
      {:ok, social_post} ->
        social_post = MatsuriOps.Repo.preload(social_post, :created_by)
        notify_parent({:saved, social_post})

        {:noreply,
         socket
         |> put_flash(:info, "投稿を作成しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp platform_label("twitter"), do: "X (Twitter)"
  defp platform_label("instagram"), do: "Instagram"
  defp platform_label("facebook"), do: "Facebook"
  defp platform_label(other), do: other

  defp calculate_char_counts(content, platforms) do
    Enum.into(platforms, %{}, fn platform ->
      {platform, SocialPost.character_count(content, platform)}
    end)
  end
end
