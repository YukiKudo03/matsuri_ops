defmodule MatsuriOpsWeb.GalleryLive.FormComponent do
  use MatsuriOpsWeb, :live_component

  alias MatsuriOps.Gallery

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>写真を投稿・編集します</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="gallery-image-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:image_url]}
          type="url"
          label="画像URL"
          placeholder="https://example.com/image.jpg"
        />

        <.input field={@form[:title]} type="text" label="タイトル" placeholder="例: 盆踊り大会の様子" />

        <.input field={@form[:description]} type="textarea" label="説明" placeholder="写真の説明..." />

        <.input
          field={@form[:thumbnail_url]}
          type="url"
          label="サムネイルURL（任意）"
          placeholder="https://example.com/thumb.jpg"
        />

        <div class="border-t pt-4 mt-4">
          <p class="text-sm font-medium text-gray-700 mb-2">投稿者情報</p>
        </div>

        <.input field={@form[:contributor_name]} type="text" label="投稿者名" placeholder="例: 山田太郎" />

        <.input field={@form[:contributor_email]} type="email" label="メールアドレス" placeholder="例: taro@example.com" />

        <div :if={@preview_url} class="mt-4">
          <p class="text-sm font-medium text-gray-700 mb-2">プレビュー</p>
          <div class="w-64 h-48 bg-gray-100 rounded overflow-hidden">
            <img src={@preview_url} alt="プレビュー" class="w-full h-full object-cover" />
          </div>
        </div>

        <:actions>
          <.button phx-disable-with="保存中...">投稿</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{gallery_image: gallery_image} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:preview_url, gallery_image.image_url)
     |> assign_new(:form, fn ->
       to_form(Gallery.change_gallery_image(gallery_image))
     end)}
  end

  @impl true
  def handle_event("validate", %{"gallery_image" => gallery_image_params}, socket) do
    changeset =
      socket.assigns.gallery_image
      |> Gallery.change_gallery_image(gallery_image_params)
      |> Map.put(:action, :validate)

    preview_url = gallery_image_params["image_url"]

    {:noreply,
     socket
     |> assign(:preview_url, preview_url)
     |> assign(form: to_form(changeset))}
  end

  def handle_event("save", %{"gallery_image" => gallery_image_params}, socket) do
    save_gallery_image(socket, socket.assigns.action, gallery_image_params)
  end

  defp save_gallery_image(socket, :edit, gallery_image_params) do
    case Gallery.update_gallery_image(socket.assigns.gallery_image, gallery_image_params) do
      {:ok, gallery_image} ->
        notify_parent({:saved, gallery_image})

        {:noreply,
         socket
         |> put_flash(:info, "画像を更新しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_gallery_image(socket, :new, gallery_image_params) do
    gallery_image_params = Map.put(gallery_image_params, "festival_id", socket.assigns.festival.id)

    case Gallery.create_gallery_image(gallery_image_params) do
      {:ok, gallery_image} ->
        notify_parent({:saved, gallery_image})

        {:noreply,
         socket
         |> put_flash(:info, "画像を投稿しました。審査後に公開されます。")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
