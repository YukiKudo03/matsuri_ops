defmodule MatsuriOpsWeb.QRCodeLive.FormComponent do
  use MatsuriOpsWeb, :live_component

  alias MatsuriOps.QRCodes
  alias MatsuriOps.QRCodes.QRCode

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>QRコードを作成・編集します</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="qr-code-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="名前" placeholder="例: 入場チケットQR" />

        <.input
          field={@form[:code_type]}
          type="select"
          label="タイプ"
          options={code_type_options()}
        />

        <.input
          field={@form[:target_url]}
          type="url"
          label="リンク先URL"
          placeholder="https://example.com/..."
        />

        <div :if={@preview_svg} class="mt-4">
          <p class="text-sm font-medium text-gray-700 mb-2">プレビュー</p>
          <div class="w-32 h-32 bg-white border rounded p-2">
            {raw(@preview_svg)}
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
  def update(%{qr_code: qr_code} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:preview_svg, qr_code.svg_data)
     |> assign_new(:form, fn ->
       to_form(QRCodes.change_qr_code(qr_code))
     end)}
  end

  @impl true
  def handle_event("validate", %{"qr_code" => qr_code_params}, socket) do
    changeset =
      socket.assigns.qr_code
      |> QRCodes.change_qr_code(qr_code_params)
      |> Map.put(:action, :validate)

    # URLが有効な場合はプレビューを生成
    preview_svg =
      case qr_code_params["target_url"] do
        url when is_binary(url) and byte_size(url) > 0 ->
          if String.starts_with?(url, "http") do
            QRCodes.generate_qr_svg(url)
          else
            nil
          end
        _ ->
          nil
      end

    {:noreply,
     socket
     |> assign(:preview_svg, preview_svg)
     |> assign(form: to_form(changeset))}
  end

  def handle_event("save", %{"qr_code" => qr_code_params}, socket) do
    save_qr_code(socket, socket.assigns.action, qr_code_params)
  end

  defp save_qr_code(socket, :edit, qr_code_params) do
    case QRCodes.update_qr_code(socket.assigns.qr_code, qr_code_params) do
      {:ok, qr_code} ->
        notify_parent({:saved, qr_code})

        {:noreply,
         socket
         |> put_flash(:info, "QRコードを更新しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_qr_code(socket, :new, qr_code_params) do
    qr_code_params = Map.put(qr_code_params, "festival_id", socket.assigns.festival.id)

    case QRCodes.create_qr_code(qr_code_params) do
      {:ok, qr_code} ->
        notify_parent({:saved, qr_code})

        {:noreply,
         socket
         |> put_flash(:info, "QRコードを作成しました")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp code_type_options do
    QRCode.code_types()
    |> Enum.map(fn type -> {QRCode.code_type_label(type), type} end)
  end
end
