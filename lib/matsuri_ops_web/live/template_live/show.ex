defmodule MatsuriOpsWeb.TemplateLive.Show do
  @moduledoc """
  テンプレート詳細表示のLiveView。
  """

  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.Templates

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    template = Templates.get_template!(id)

    {:noreply,
     socket
     |> assign(:page_title, "テンプレート詳細")
     |> assign(:template, template)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@template.name}
        <:subtitle>テンプレート詳細</:subtitle>
        <:actions>
          <.link patch={~p"/templates/#{@template}/edit"}>
            <.button>編集</.button>
          </.link>
          <.link navigate={~p"/templates/#{@template}/apply"}>
            <.button variant="success">このテンプレートで祭りを作成</.button>
          </.link>
        </:actions>
      </.header>

      <.list>
        <:item title="名前">{@template.name}</:item>
        <:item title="説明">{@template.description || "（なし）"}</:item>
        <:item title="規模">{scale_label(@template.scale)}</:item>
        <:item title="想定来場者数">{@template.default_expected_visitors || "（未設定）"}</:item>
        <:item title="想定出店数">{@template.default_expected_vendors || "（未設定）"}</:item>
        <:item title="公開状態">{if @template.is_public, do: "公開", else: "非公開"}</:item>
      </.list>

      <.back navigate={~p"/templates"}>テンプレート一覧に戻る</.back>
    </Layouts.app>
    """
  end

  defp scale_label("small"), do: "小規模"
  defp scale_label("medium"), do: "中規模"
  defp scale_label("large"), do: "大規模"
  defp scale_label(_), do: "不明"
end
