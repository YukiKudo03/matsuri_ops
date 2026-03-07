defmodule MatsuriOpsWeb.FeatureCase do
  @moduledoc """
  E2Eテスト用のテストケースモジュール。

  Wallabyを使用したブラウザベースのE2Eテストをサポートします。

  ## 使用例

      use MatsuriOpsWeb.FeatureCase

      feature "ユーザーがログインできる", %{session: session} do
        session
        |> visit("/users/log-in")
        |> fill_in(text_field("email"), with: "test@example.com")
        |> click(button("ログイン"))
        |> assert_has(text("ログインリンクを送信しました"))
      end
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.Feature

      alias MatsuriOps.Repo
      alias MatsuriOpsWeb.Endpoint

      import Ecto.Query
      import Wallaby.Query
      import MatsuriOpsWeb.FeatureCase.Helpers

      @endpoint MatsuriOpsWeb.Endpoint
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(MatsuriOps.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)

    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(MatsuriOps.Repo, pid)
    {:ok, session} = Wallaby.start_session(metadata: metadata)

    {:ok, session: session}
  end

  defmodule Helpers do
    @moduledoc """
    E2Eテスト用のヘルパー関数。
    """

    import Wallaby.Query

    @doc """
    ユーザーを作成してログインセッションを開始する。
    Magic Link認証をシミュレートする。
    """
    def create_and_login_user(session, attrs \\ %{}) do
      user = MatsuriOps.AccountsFixtures.user_fixture(attrs)
      token = MatsuriOps.Accounts.generate_user_session_token(user)

      # Magic Linkトークンを作成
      {login_token, _hashed} = MatsuriOps.Accounts.UserToken.build_email_token(user, "magic_link")

      # ログインページにアクセスしてトークンでログイン
      session
      |> Wallaby.Browser.visit("/users/log-in/#{login_token}")

      {session, user}
    end

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
    フラッシュメッセージを確認。
    """
    def assert_flash(session, type, text) do
      selector = case type do
        :info -> ".alert-info"
        :error -> ".alert-error"
        :success -> ".alert-success"
        _ -> ".alert"
      end

      Wallaby.Browser.assert_has(session, css(selector, text: text))
    end
  end
end
