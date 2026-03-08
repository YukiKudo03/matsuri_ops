defmodule MatsuriOpsWeb.DocumentLive.FormComponent do
  use MatsuriOpsWeb, :live_component

  alias MatsuriOps.Documents

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>文書情報を入力してください</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="document-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="タイトル" />
        <.input field={@form[:description]} type="textarea" label="説明" />
        <.input
          field={@form[:category]}
          type="select"
          label="カテゴリ"
          options={[
            {"マニュアル", "manual"},
            {"予算", "budget"},
            {"企画", "plan"},
            {"報告書", "report"},
            {"契約書", "contract"},
            {"その他", "other"}
          ]}
        />
        <.input field={@form[:file_name]} type="text" label="ファイル名" />
        <.input field={@form[:file_path]} type="text" label="ファイルパス" />
        <.input field={@form[:file_size]} type="number" label="ファイルサイズ (bytes)" />
        <.input
          field={@form[:content_type]}
          type="select"
          label="ファイル形式"
          options={[
            {"PDF", "application/pdf"},
            {"Word", "application/msword"},
            {"Excel", "application/vnd.ms-excel"},
            {"画像", "image/jpeg"},
            {"テキスト", "text/plain"}
          ]}
        />

        <:actions>
          <.button phx-disable-with="保存中...">保存</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{document: document} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Documents.change_document(document))
     end)}
  end

  @impl true
  def handle_event("validate", %{"document" => document_params}, socket) do
    changeset = Documents.change_document(socket.assigns.document, document_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"document" => document_params}, socket) do
    save_document(socket, socket.assigns.action, document_params)
  end

  defp save_document(socket, :edit, document_params) do
    case Documents.update_document(socket.assigns.document, document_params) do
      {:ok, document} ->
        notify_parent({:saved, document})

        {:noreply,
         socket
         |> put_flash(:info, "文書を更新しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_document(socket, :new, document_params) do
    document_params =
      document_params
      |> Map.put("festival_id", socket.assigns.festival.id)
      |> Map.put("uploaded_by_id", socket.assigns.current_user.id)

    case Documents.create_document(document_params) do
      {:ok, document} ->
        notify_parent({:saved, document})

        {:noreply,
         socket
         |> put_flash(:info, "文書を作成しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
