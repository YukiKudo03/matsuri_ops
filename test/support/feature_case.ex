defmodule MatsuriOpsWeb.FeatureCase do
  @moduledoc """
  E2Eテスト用のテストケースモジュール。

  Wallabyを使用したブラウザベースのE2Eテストをサポートします。

  ## 注意事項

  WallabyのEctoサンドボックス制限により、テストプロセスで作成したデータは
  ブラウザセッションからは直接アクセスできません。そのため、E2Eテストでは
  以下のいずれかの方法を使用してください：

  1. UIを通じてデータを作成するテスト
  2. 公開ページのテスト（認証不要なページ）
  3. エラー状態のテスト（無効なトークンなど）

  ## 使用例

      use MatsuriOpsWeb.FeatureCase

      feature "ユーザーが登録できる", %{session: session} do
        session
        |> visit("/users/register")
        |> fill_in(css("input[name='user[email]']"), with: "test@example.com")
        |> click(button("Create an account"))
        |> assert_has(css("h1", text: "Log in"))
      end
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.Feature

      alias MatsuriOps.Repo
      alias MatsuriOpsWeb.Endpoint

      # Note: Ecto.Query is NOT imported to avoid conflicts with Wallaby.Query
      import Wallaby.Query
      import MatsuriOpsWeb.FeatureCase.Helpers

      @endpoint MatsuriOpsWeb.Endpoint
    end
  end

  setup _tags do
    # E2Eテストは非同期実行しない
    # サンドボックスは使用しない（ブラウザからアクセスできないため）
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MatsuriOps.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(MatsuriOps.Repo, {:shared, self()})

    {:ok, session} = Wallaby.start_session()

    on_exit(fn ->
      Wallaby.end_session(session)
    end)

    {:ok, session: session}
  end

  defmodule Helpers do
    @moduledoc """
    E2Eテスト用のヘルパー関数。
    """

    import Wallaby.Query

    @doc """
    テキストフィールドを取得するクエリ。
    """
    def text_field(label) do
      css("[aria-label='#{label}'], input[placeholder='#{label}'], label:has-text('#{label}') + input, label:has-text('#{label}') input")
    end

    @doc """
    データテストIDでの要素取得。
    """
    def test_id(id) do
      css("[data-testid='#{id}']")
    end

    @doc """
    ナビゲーションリンクの取得。
    """
    def nav_link(text) do
      css("nav a", text: text)
    end

    @doc """
    モーダルが表示されるまで待機。
    """
    def wait_for_modal(session) do
      session
      |> Wallaby.Browser.find(css(".modal", visible: true), fn modal ->
        modal
      end)
    end

    @doc """
    LiveViewの更新を待機。
    """
    def wait_for_liveview(session, timeout \\ 500) do
      Process.sleep(timeout)
      session
    end

    @doc """
    フラッシュメッセージのセレクタを返す。
    テスト内で assert_has(flash_selector(:info, "メッセージ")) のように使用。
    """
    def flash_selector(type, text \\ nil) do
      selector = case type do
        :info -> ".alert-info"
        :error -> ".alert-error"
        :success -> ".alert-success"
        _ -> ".alert"
      end

      if text do
        css(selector, text: text)
      else
        css(selector)
      end
    end

    @doc """
    セレクトボックスでオプションを選択する。
    Ecto.Query.selectとの競合を避けるためのヘルパー。
    """
    def select_option(session, select_query, option_text) do
      session
      |> Wallaby.Browser.find(select_query, fn select_element ->
        select_element
        |> Wallaby.Browser.click(Wallaby.Query.option(option_text))
      end)
    end
  end
end
