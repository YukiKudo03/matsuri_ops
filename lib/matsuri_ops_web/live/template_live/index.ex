defmodule MatsuriOpsWeb.TemplateLive.Index do
  @moduledoc """
  テンプレート一覧・管理のLiveView。
  """

  use MatsuriOpsWeb, :live_view

  alias MatsuriOps.Templates
  alias MatsuriOps.Templates.Template

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    templates = Templates.list_templates(user)

    {:ok, stream(socket, :templates, templates)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "テンプレート編集")
    |> assign(:template, Templates.get_template!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "新規テンプレート")
    |> assign(:template, %Template{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "テンプレート一覧")
    |> assign(:template, nil)
  end

  @impl true
  def handle_info({MatsuriOpsWeb.TemplateLive.FormComponent, {:saved, template}}, socket) do
    {:noreply, stream_insert(socket, :templates, template)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    template = Templates.get_template!(id)
    {:ok, _} = Templates.delete_template(template)

    {:noreply, stream_delete(socket, :templates, template)}
  end

  @impl true
  def handle_event("copy", %{"id" => id}, socket) do
    user = socket.assigns.current_scope.user
    template = Templates.get_template!(id)
    {:ok, copy} = Templates.copy_template(template, user)

    socket =
      socket
      |> stream_insert(:templates, copy)
      |> put_flash(:info, "テンプレートをコピーしました")

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        テンプレート一覧
        <:actions>
          <.link patch={~p"/templates/new"}>
            <.button>新規作成</.button>
          </.link>
        </:actions>
      </.header>

      <.table
        id="templates"
        rows={@streams.templates}
        row_click={fn {_id, template} -> JS.navigate(~p"/templates/#{template}") end}
      >
        <:col :let={{_id, template}} label="名前">{template.name}</:col>
        <:col :let={{_id, template}} label="規模">{template.scale}</:col>
        <:col :let={{_id, template}} label="公開">
          {if template.is_public, do: "公開", else: "非公開"}
        </:col>
        <:action :let={{_id, template}}>
          <.link navigate={~p"/templates/#{template}"}>表示</.link>
        </:action>
        <:action :let={{_id, template}}>
          <.link patch={~p"/templates/#{template}/edit"}>編集</.link>
        </:action>
        <:action :let={{_id, template}}>
          <.link navigate={~p"/templates/#{template}/apply"}>適用</.link>
        </:action>
        <:action :let={{_id, template}}>
          <.link
            phx-click="copy"
            phx-value-id={template.id}
          >
            コピー
          </.link>
        </:action>
        <:action :let={{id, template}}>
          <.link
            phx-click={JS.push("delete", value: %{id: template.id}) |> hide("##{id}")}
            data-confirm="本当に削除しますか？"
          >
            削除
          </.link>
        </:action>
      </.table>

      <.modal :if={@live_action in [:new, :edit]} id="template-modal" show on_cancel={JS.patch(~p"/templates")}>
        <.live_component
          module={MatsuriOpsWeb.TemplateLive.FormComponent}
          id={@template.id || :new}
          title={@page_title}
          action={@live_action}
          template={@template}
          current_user={@current_scope.user}
          patch={~p"/templates"}
        />
      </.modal>
    </Layouts.app>
    """
  end
end
