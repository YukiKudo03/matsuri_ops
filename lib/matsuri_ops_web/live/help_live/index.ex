defmodule MatsuriOpsWeb.HelpLive.Index do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOpsWeb.Layouts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-4xl mx-auto">
        <.header>
          ヘルプ & サポート
          <:subtitle>MatsuriOpsの使い方ガイド</:subtitle>
        </.header>

        <div class="mt-8 grid gap-6 md:grid-cols-2">
          <.help_card
            title="クイックスタート"
            description="5分で始められる基本操作ガイド。初めての方はこちらから。"
            href={~p"/help/quickstart"}
            icon="rocket-launch"
          />

          <.help_card
            title="管理者マニュアル"
            description="システム管理者・実行委員・事務局向けの詳細ガイド。"
            href={~p"/help/admin"}
            icon="cog-6-tooth"
          />

          <.help_card
            title="スタッフマニュアル"
            description="リーダー・スタッフ・ボランティア向けの操作ガイド。"
            href={~p"/help/staff"}
            icon="user-group"
          />

          <.help_card
            title="外部ユーザーガイド"
            description="出店者・来場者向けの簡易ガイド。"
            href={~p"/help/external"}
            icon="building-storefront"
          />
        </div>

        <div class="mt-12">
          <h2 class="text-xl font-semibold mb-4">よくある質問</h2>
          <div class="space-y-4">
            <.faq_item
              question="ログインできません"
              answer="メールアドレスが正しいか確認してください。確認メールが届かない場合は、迷惑メールフォルダをご確認ください。"
            />
            <.faq_item
              question="タスクを確認したい"
              answer="祭り詳細画面から「タスク管理」をクリックしてください。"
            />
            <.faq_item
              question="シフトを確認したい"
              answer="祭り詳細画面から「シフト管理」をクリックしてください。"
            />
            <.faq_item
              question="画面が正しく表示されない"
              answer="ブラウザを最新版に更新し、キャッシュをクリア（Ctrl+Shift+R または Cmd+Shift+R）してください。"
            />
          </div>
        </div>

        <div class="mt-12">
          <h2 class="text-xl font-semibold mb-4">サポート</h2>
          <div class="bg-base-200 rounded-lg p-6">
            <p class="mb-4">問題が解決しない場合は、以下にお問い合わせください：</p>
            <ul class="space-y-2">
              <li class="flex items-center gap-2">
                <.icon name="hero-chat-bubble-left-right" class="w-5 h-5" />
                <span>チャットで運営スタッフに連絡</span>
              </li>
              <li class="flex items-center gap-2">
                <.icon name="hero-user" class="w-5 h-5" />
                <span>リーダーまたは事務局に相談</span>
              </li>
            </ul>
          </div>
        </div>

        <.back navigate={~p"/festivals"}>祭り一覧に戻る</.back>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  defp help_card(assigns) do
    ~H"""
    <.link
      navigate={@href}
      class="block p-6 bg-base-200 rounded-lg hover:bg-base-300 transition-colors"
    >
      <div class="flex items-start gap-4">
        <div class="p-3 bg-primary/10 rounded-lg">
          <.icon name={"hero-#{@icon}"} class="w-6 h-6 text-primary" />
        </div>
        <div>
          <h3 class="font-semibold text-lg">{@title}</h3>
          <p class="text-base-content/70 mt-1">{@description}</p>
        </div>
      </div>
    </.link>
    """
  end

  defp faq_item(assigns) do
    ~H"""
    <div class="collapse collapse-arrow bg-base-200">
      <input type="checkbox" />
      <div class="collapse-title font-medium">
        {@question}
      </div>
      <div class="collapse-content">
        <p>{@answer}</p>
      </div>
    </div>
    """
  end
end
