defmodule MatsuriOpsWeb.DocumentLive.Index do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.Documents
  alias MatsuriOps.Documents.Document
  alias MatsuriOps.Festivals

  @impl true
  def mount(%{"festival_id" => festival_id}, _session, socket) do
    festival = Festivals.get_festival!(festival_id)
    documents = Documents.list_documents(festival_id)

    {:ok,
     socket
     |> assign(:festival, festival)
     |> assign(:page_title, "文書管理")
     |> assign(:search_query, "")
     |> assign(:has_documents, length(documents) > 0)
     |> stream(:documents, documents)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "文書を編集")
    |> assign(:document, Documents.get_document!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "新しい文書")
    |> assign(:document, %Document{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "文書管理")
    |> assign(:document, nil)
  end

  @impl true
  def handle_event("search", %{"search" => query}, socket) do
    festival_id = socket.assigns.festival.id
    documents = Documents.search_documents(festival_id, query)

    {:noreply,
     socket
     |> assign(:search_query, query)
     |> assign(:has_documents, length(documents) > 0)
     |> stream(:documents, documents, reset: true)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    document = Documents.get_document!(id)
    {:ok, _} = Documents.delete_document(document)

    {:noreply, stream_delete(socket, :documents, document)}
  end

  @impl true
  def handle_info({MatsuriOpsWeb.DocumentLive.FormComponent, {:saved, document}}, socket) do
    {:noreply, stream_insert(socket, :documents, document)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <.header>
        文書管理
        <:subtitle>{@festival.name}の文書</:subtitle>
        <:actions>
          <.link patch={~p"/festivals/#{@festival}/documents/new"}>
            <.button>新規文書</.button>
          </.link>
        </:actions>
      </.header>

      <form id="search-form" phx-submit="search" class="flex gap-4">
        <.input
          name="search"
          value={@search_query}
          placeholder="文書を検索..."
          class="flex-1"
        />
        <.button type="submit">検索</.button>
      </form>

      <.table
        id="documents"
        rows={@streams.documents}
        row_click={fn {_id, document} -> JS.navigate(~p"/festivals/#{@festival}/documents/#{document}") end}
      >
        <:col :let={{_id, document}} label="タイトル">{document.title}</:col>
        <:col :let={{_id, document}} label="カテゴリ">{format_category(document.category)}</:col>
        <:col :let={{_id, document}} label="ファイル名">{document.file_name}</:col>
        <:col :let={{_id, document}} label="サイズ">{format_file_size(document.file_size)}</:col>
        <:col :let={{_id, document}} label="更新日">{format_date(document.updated_at)}</:col>
        <:action :let={{_id, document}}>
          <.link patch={~p"/festivals/#{@festival}/documents/#{document}/edit"}>編集</.link>
        </:action>
        <:action :let={{id, document}}>
          <.link
            phx-click={JS.push("delete", value: %{id: document.id}) |> hide("##{id}")}
            data-confirm="本当に削除しますか？"
          >
            削除
          </.link>
        </:action>
      </.table>

      <div :if={not @has_documents} class="text-center py-8 text-gray-500">
        文書がありません
      </div>

      <.modal :if={@live_action in [:new, :edit]} id="document-modal" show on_cancel={JS.patch(~p"/festivals/#{@festival}/documents")}>
        <.live_component
          module={MatsuriOpsWeb.DocumentLive.FormComponent}
          id={@document.id || :new}
          title={@page_title}
          action={@live_action}
          document={@document}
          festival={@festival}
          current_user={@current_scope.user}
          patch={~p"/festivals/#{@festival}/documents"}
        />
      </.modal>
    </div>
    """
  end

  defp format_category("manual"), do: "マニュアル"
  defp format_category("budget"), do: "予算"
  defp format_category("plan"), do: "企画"
  defp format_category("report"), do: "報告書"
  defp format_category("contract"), do: "契約書"
  defp format_category(_), do: "その他"

  defp format_file_size(bytes) when bytes < 1024, do: "#{bytes} B"
  defp format_file_size(bytes) when bytes < 1_048_576, do: "#{Float.round(bytes / 1024, 1)} KB"
  defp format_file_size(bytes), do: "#{Float.round(bytes / 1_048_576, 1)} MB"

  defp format_date(datetime) do
    Calendar.strftime(datetime, "%Y/%m/%d")
  end
end
