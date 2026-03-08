defmodule MatsuriOpsWeb.DocumentLive.Show do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.Documents
  alias MatsuriOps.Festivals

  @impl true
  def mount(%{"festival_id" => festival_id, "id" => id}, _session, socket) do
    festival = Festivals.get_festival!(festival_id)
    document = Documents.get_document!(id)
    versions = Documents.list_document_versions(id)

    {:ok,
     socket
     |> assign(:festival, festival)
     |> assign(:document, document)
     |> assign(:versions, versions)
     |> assign(:page_title, document.title)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <.header>
        {@document.title}
        <:subtitle>{format_category(@document.category)}</:subtitle>
        <:actions>
          <.link patch={~p"/festivals/#{@festival}/documents/#{@document}/edit"}>
            <.button>編集</.button>
          </.link>
          <.link navigate={~p"/festivals/#{@festival}/documents"}>
            <.button variant="outline">一覧に戻る</.button>
          </.link>
        </:actions>
      </.header>

      <div class="bg-white shadow rounded-lg p-6">
        <dl class="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <div>
            <dt class="text-sm font-medium text-gray-500">説明</dt>
            <dd class="mt-1 text-sm text-gray-900">{@document.description || "なし"}</dd>
          </div>
          <div>
            <dt class="text-sm font-medium text-gray-500">ファイル名</dt>
            <dd class="mt-1 text-sm text-gray-900">{@document.file_name}</dd>
          </div>
          <div>
            <dt class="text-sm font-medium text-gray-500">ファイルサイズ</dt>
            <dd class="mt-1 text-sm text-gray-900">{format_file_size(@document.file_size)}</dd>
          </div>
          <div>
            <dt class="text-sm font-medium text-gray-500">ファイル形式</dt>
            <dd class="mt-1 text-sm text-gray-900">{@document.content_type}</dd>
          </div>
          <div>
            <dt class="text-sm font-medium text-gray-500">作成日</dt>
            <dd class="mt-1 text-sm text-gray-900">{format_date(@document.inserted_at)}</dd>
          </div>
          <div>
            <dt class="text-sm font-medium text-gray-500">更新日</dt>
            <dd class="mt-1 text-sm text-gray-900">{format_date(@document.updated_at)}</dd>
          </div>
        </dl>
      </div>

      <div class="bg-white shadow rounded-lg p-6">
        <h3 class="text-lg font-medium text-gray-900 mb-4">バージョン履歴</h3>
        <div :if={@versions == []} class="text-gray-500">
          バージョン履歴がありません
        </div>
        <ul :if={@versions != []} class="divide-y divide-gray-200">
          <li :for={version <- @versions} class="py-3">
            <div class="flex justify-between">
              <div>
                <span class="font-medium">v{version.version_number}</span>
                <span class="text-gray-500 ml-2">{version.change_notes || "変更メモなし"}</span>
              </div>
              <div class="text-sm text-gray-500">
                {format_date(version.inserted_at)}
              </div>
            </div>
          </li>
        </ul>
      </div>
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
    Calendar.strftime(datetime, "%Y/%m/%d %H:%M")
  end
end
