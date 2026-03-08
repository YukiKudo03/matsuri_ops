defmodule MatsuriOpsWeb.TemplateLive.Apply do
  @moduledoc """
  テンプレートを適用して祭りを作成するLiveView。
  """

  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.Templates
  alias MatsuriOps.Festivals.Festival

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    template = Templates.get_template!(id)

    festival = %Festival{
      scale: template.scale,
      expected_visitors: template.default_expected_visitors,
      expected_vendors: template.default_expected_vendors
    }

    changeset = MatsuriOps.Festivals.change_festival(festival)

    {:noreply,
     socket
     |> assign(:page_title, "テンプレートから祭りを作成")
     |> assign(:template, template)
     |> assign(:festival, festival)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"festival" => festival_params}, socket) do
    changeset =
      socket.assigns.festival
      |> MatsuriOps.Festivals.change_festival(festival_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"festival" => festival_params}, socket) do
    user = socket.assigns.current_scope.user
    template = socket.assigns.template

    case Templates.apply_template(template, user, festival_params) do
      {:ok, _festival} ->
        {:noreply,
         socket
         |> put_flash(:info, "祭りを作成しました")
         |> push_navigate(to: ~p"/festivals")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        テンプレートから祭りを作成
        <:subtitle>テンプレート: {@template.name}</:subtitle>
      </.header>

      <div class="mt-4 p-4 bg-base-200 rounded-lg">
        <h3 class="font-semibold mb-2">テンプレート設定値</h3>
        <ul class="text-sm space-y-1">
          <li>規模: {scale_label(@template.scale)}</li>
          <li :if={@template.default_expected_visitors}>想定来場者数: {@template.default_expected_visitors}人</li>
          <li :if={@template.default_expected_vendors}>想定出店数: {@template.default_expected_vendors}店</li>
        </ul>
      </div>

      <.simple_form
        for={@form}
        id="apply-template-form"
        phx-change="validate"
        phx-submit="save"
        class="mt-6"
      >
        <.input field={@form[:name]} type="text" label="祭り名" required />
        <.input field={@form[:start_date]} type="date" label="開始日" required />
        <.input field={@form[:end_date]} type="date" label="終了日" required />
        <.input field={@form[:venue_name]} type="text" label="会場名" />
        <.input field={@form[:venue_address]} type="text" label="会場住所" />

        <div class="divider">詳細設定（テンプレートの値を上書き）</div>

        <.input
          field={@form[:scale]}
          type="select"
          label="規模"
          options={[{"小規模", "small"}, {"中規模", "medium"}, {"大規模", "large"}]}
        />
        <.input field={@form[:expected_visitors]} type="number" label="想定来場者数" />
        <.input field={@form[:expected_vendors]} type="number" label="想定出店数" />

        <:actions>
          <.link navigate={~p"/templates/#{@template}"}>
            <.button type="button" variant="outline">キャンセル</.button>
          </.link>
          <.button phx-disable-with="作成中...">祭りを作成</.button>
        </:actions>
      </.simple_form>
    </Layouts.app>
    """
  end

  defp scale_label("small"), do: "小規模"
  defp scale_label("medium"), do: "中規模"
  defp scale_label("large"), do: "大規模"
  defp scale_label(_), do: "不明"
end
