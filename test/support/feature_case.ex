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
    import Wallaby.Browser

    alias MatsuriOps.AccountsFixtures
    alias MatsuriOps.FestivalsFixtures

    @doc """
    確認済みユーザーを作成し、Magic Linkでブラウザログインする。
    ロールを指定可能（デフォルト: admin）。

    返り値: {session, user}
    """
    def register_and_login(session, opts \\ []) do
      role = Keyword.get(opts, :role, "admin")

      # 確認済みユーザーを作成
      user = AccountsFixtures.user_fixture()

      # ロールを設定
      user
      |> Ecto.Changeset.change(%{role: role})
      |> MatsuriOps.Repo.update!()

      user = MatsuriOps.Repo.get!(MatsuriOps.Accounts.User, user.id)

      # Magic Linkトークンを生成してブラウザでログイン
      {encoded_token, _raw_token} = AccountsFixtures.generate_user_magic_link_token(user)

      session =
        session
        |> visit("/users/log-in/#{encoded_token}")
        |> wait_for_liveview(1000)
        |> click(Wallaby.Query.button("Keep me logged in on this device"))
        |> wait_for_liveview(1000)

      {session, user}
    end

    @doc """
    祭りをDBに直接作成してIDを返す。
    Ectoサンドボックスが共有モードなのでブラウザからも参照可能。

    返り値: {session, festival_id}
    """
    def create_festival_in_db(session, user, attrs \\ %{}) do
      festival = FestivalsFixtures.festival_fixture(user, attrs)
      {session, Integer.to_string(festival.id)}
    end

    @doc """
    UIを通じて祭りを作成してIDを返す。ログイン済みセッションが必要。
    作成後は祭り一覧ページに戻る。

    返り値: {session, festival_id}
    """
    def create_festival_via_ui(session, attrs \\ %{}) do
      name = Map.get(attrs, :name, "テスト祭り#{System.unique_integer([:positive])}")
      start_date = Map.get(attrs, :start_date, "2026-08-01")
      end_date = Map.get(attrs, :end_date, "2026-08-03")

      session =
        session
        |> visit("/festivals")
        |> wait_for_liveview()
        |> click(Wallaby.Query.link("新規作成"))
        |> wait_for_liveview(800)
        |> fill_in(css("#festival-form input[name='festival[name]']"), with: name)
        |> set_date_input("#festival-form input[name='festival[start_date]']", start_date)
        |> set_date_input("#festival-form input[name='festival[end_date]']", end_date)
        |> click(Wallaby.Query.button("保存"))
        |> wait_for_liveview(1000)

      # 作成後は一覧ページに戻るので、DBから最新の祭りIDを取得
      import Ecto.Query, only: [from: 2]
      festival =
        from(f in MatsuriOps.Festivals.Festival,
          where: f.name == ^name,
          order_by: [desc: f.inserted_at],
          limit: 1
        )
        |> MatsuriOps.Repo.one()

      festival_id = if festival, do: Integer.to_string(festival.id), else: nil

      {session, festival_id}
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
    JavaScriptでフォームのsubmitイベントを発火してフォーム送信する。
    <dialog>内のボタンクリックがWallabyで動作しない場合の代替手段。
    LiveViewのphx-submitハンドラを正しくトリガーするため、
    requestSubmitを使用する。送信後にdialogを閉じる。
    """
    def submit_form_via_js(session, form_selector) do
      # LiveViewのphx-submitはボタンのクリックイベントからトリガーされる
      # requestSubmitではなく、submitボタンに対するMouseEventをdispatchする
      session
      |> Wallaby.Browser.execute_script(
        "var b=document.querySelector(arguments[0]+' button[type=submit],'+arguments[0]+' button:not([type])');if(b){b.dispatchEvent(new MouseEvent('click',{bubbles:true,cancelable:true}));}",
        [form_selector]
      )
    end

    @doc """
    開いている<dialog>を全て閉じて非表示にする。
    LiveViewのpush_patchが<dialog>を自動で閉じない場合に使用。
    """
    def close_all_dialogs(session) do
      session
      |> Wallaby.Browser.execute_script(
        "document.querySelectorAll('dialog').forEach(function(d){d.close();d.style.display='none';d.removeAttribute('open');});"
      )
    end

    @doc """
    日付入力フィールドにJavaScriptで値を設定する。
    Chrome/Chromiumの<input type="date">はWallabyのfill_inで
    値を設定できない場合があるため、JSで直接設定する。
    """
    def set_date_input(session, selector, date_string) do
      session
      |> Wallaby.Browser.execute_script(
        "var el=document.querySelector(arguments[0]);if(el){var nativeSetter=Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,'value').set;nativeSetter.call(el,arguments[1]);el.dispatchEvent(new Event('input',{bubbles:true}));el.dispatchEvent(new Event('change',{bubbles:true}));}",
        [selector, date_string]
      )
    end

    @doc """
    セレクトボックスでオプションを選択する。
    Ecto.Query.selectとの競合を避けるためのヘルパー。
    value引数にはoption要素のvalue属性値を指定する。
    """
    def select_option(session, select_query, value) do
      # CSSセレクタからname属性を抽出
      %{selector: selector} = select_query
      session
      |> Wallaby.Browser.execute_script(
        "var sel=document.querySelector(arguments[0]);sel.value=arguments[1];sel.dispatchEvent(new Event('input',{bubbles:true}));sel.dispatchEvent(new Event('change',{bubbles:true}));",
        [selector, value]
      )
      |> wait_for_liveview(300)
    end

    @doc """
    LiveViewのイベントをJavaScript経由で直接Pushする。
    data-confirmダイアログがWallabyで正常に動作しない場合の代替手段。
    """
    def push_liveview_event(session, event, value) do
      session
      |> Wallaby.Browser.execute_script(
        """
        var main = document.querySelector('[data-phx-main]');
        var view = window.liveSocket.getViewByEl(main);
        view.pushEvent('click', main, null, arguments[0], arguments[1]);
        """,
        [event, value]
      )
    end
  end
end
