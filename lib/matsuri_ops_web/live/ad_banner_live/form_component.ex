defmodule MatsuriOpsWeb.AdBannerLive.FormComponent do
  use MatsuriOpsWeb, :live_component

  alias MatsuriOps.Advertising
  alias MatsuriOps.Advertising.AdBanner

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>広告バナーを作成・編集します</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="ad-banner-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="名前" placeholder="例: メインスポンサーバナー" />

        <.input
          field={@form[:sponsor_id]}
          type="select"
          label="スポンサー"
          options={[{"（指定なし）", nil} | sponsor_options(@sponsors)]}
        />

        <.input
          field={@form[:position]}
          type="select"
          label="表示位置"
          options={position_options()}
        />

        <.input
          field={@form[:image_url]}
          type="url"
          label="画像URL"
          placeholder="https://example.com/banner.jpg"
        />

        <.input
          field={@form[:link_url]}
          type="url"
          label="リンク先URL"
          placeholder="https://example.com/"
        />

        <div class="grid grid-cols-2 gap-4">
          <.input field={@form[:start_date]} type="date" label="表示開始日" />
          <.input field={@form[:end_date]} type="date" label="表示終了日" />
        </div>

        <.input
          field={@form[:display_weight]}
          type="number"
          label="表示優先度"
          min="1"
          max="100"
          placeholder="1-100"
        />

        <.input field={@form[:is_active]} type="checkbox" label="有効にする" />

        <div :if={@preview_url} class="mt-4">
          <p class="text-sm font-medium text-gray-700 mb-2">プレビュー</p>
          <div class="w-64 h-32 bg-gray-100 rounded overflow-hidden border">
            <img src={@preview_url} alt="プレビュー" class="w-full h-full object-cover" />
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
  def update(%{ad_banner: ad_banner} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:preview_url, ad_banner.image_url)
     |> assign_new(:form, fn ->
       to_form(Advertising.change_ad_banner(ad_banner))
     end)}
  end

  @impl true
  def handle_event("validate", %{"ad_banner" => ad_banner_params}, socket) do
    changeset =
      socket.assigns.ad_banner
      |> Advertising.change_ad_banner(ad_banner_params)
      |> Map.put(:action, :validate)

    preview_url = ad_banner_params["image_url"]

    {:noreply,
     socket
     |> assign(:preview_url, preview_url)
     |> assign(form: to_form(changeset))}
  end

  def handle_event("save", %{"ad_banner" => ad_banner_params}, socket) do
    save_ad_banner(socket, socket.assigns.action, ad_banner_params)
  end

  defp save_ad_banner(socket, :edit, ad_banner_params) do
    case Advertising.update_ad_banner(socket.assigns.ad_banner, ad_banner_params) do
      {:ok, ad_banner} ->
        ad_banner = MatsuriOps.Repo.preload(ad_banner, :sponsor)
        notify_parent({:saved, ad_banner})

        {:noreply,
         socket
         |> put_flash(:info, "広告バナーを更新しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_ad_banner(socket, :new, ad_banner_params) do
    ad_banner_params = Map.put(ad_banner_params, "festival_id", socket.assigns.festival.id)

    case Advertising.create_ad_banner(ad_banner_params) do
      {:ok, ad_banner} ->
        ad_banner = MatsuriOps.Repo.preload(ad_banner, :sponsor)
        notify_parent({:saved, ad_banner})

        {:noreply,
         socket
         |> put_flash(:info, "広告バナーを作成しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp position_options do
    AdBanner.positions()
    |> Enum.map(fn position -> {AdBanner.position_label(position), position} end)
  end

  defp sponsor_options(sponsors) do
    Enum.map(sponsors, fn sponsor -> {sponsor.name, sponsor.id} end)
  end
end
