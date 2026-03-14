defmodule MatsuriOpsWeb.Features.AuthenticationTest do
  @moduledoc """
  認証フローのE2Eテスト (Suite 1: A-01〜A-09)
  """

  use MatsuriOpsWeb.FeatureCase, async: false

  alias MatsuriOps.AccountsFixtures

  describe "ユーザー登録フロー" do
    # A-01: 新規ユーザー登録
    feature "新規ユーザーがメールアドレスで登録できる", %{session: session} do
      email = "newuser#{System.unique_integer([:positive])}@example.com"

      session
      |> visit("/users/register")
      |> assert_has(css("h1", text: "Register for an account"))
      |> fill_in(css("#registration_form input[name='user[email]']"), with: email)
      |> click(button("Create an account"))
      |> wait_for_liveview()
      |> assert_has(css("h1", text: "Log in"))
    end

    # A-02: 登録ページ表示確認
    feature "登録ページの表示を確認", %{session: session} do
      session
      |> visit("/users/register")
      |> assert_has(css("h1", text: "Register for an account"))
      |> assert_has(css("#registration_form"))
      |> assert_has(button("Create an account"))
    end

    # A-03: 重複メール登録
    feature "既存メールで登録するとエラーが表示される", %{session: session} do
      user = AccountsFixtures.user_fixture()

      session
      |> visit("/users/register")
      |> fill_in(css("#registration_form input[name='user[email]']"), with: user.email)
      |> click(button("Create an account"))
      |> wait_for_liveview()
      # バリデーションエラーが表示される
      |> assert_has(css("p", text: "has already been taken"))
    end
  end

  describe "ログインフロー" do
    # A-04: ログインページ表示
    feature "ログインページが表示される", %{session: session} do
      session
      |> visit("/users/log-in")
      |> assert_has(css("h1", text: "Log in"))
      |> assert_has(css("#login_form_magic"))
      |> assert_has(button("Log in with email"))
    end

    # A-05: Magic Linkログイン
    feature "Magic Linkトークンでログインできる", %{session: session} do
      user = AccountsFixtures.user_fixture()
      {encoded_token, _} = AccountsFixtures.generate_user_magic_link_token(user)

      session
      |> visit("/users/log-in/#{encoded_token}")
      |> wait_for_liveview(1000)
      |> click(button("Keep me logged in on this device"))
      |> wait_for_liveview(1000)
      # ログイン後、祭り一覧等にアクセス可能
      |> visit("/festivals")
      |> wait_for_liveview()
      |> refute_has(css("h1", text: "Log in"))
    end

    # A-06: 無効トークンログイン
    feature "無効なトークンではログインできない", %{session: session} do
      session
      |> visit("/users/log-in/invalid-token")
      |> wait_for_liveview()
      |> assert_has(css("h1", text: "Log in"))
      |> assert_has(css(".alert-error"))
    end
  end

  describe "認証が必要なページへのアクセス" do
    # A-07: 未認証リダイレクト
    feature "未ログインユーザーは祭り一覧にアクセスできない", %{session: session} do
      session
      |> visit("/festivals")
      |> wait_for_liveview()
      |> assert_has(css("h1", text: "Log in"))
    end

    # A-07b: 複数の認証必須ページ
    feature "未ログインユーザーはテンプレートにアクセスできない", %{session: session} do
      session
      |> visit("/templates")
      |> wait_for_liveview()
      |> assert_has(css("h1", text: "Log in"))
    end

    # A-07c: ヘルプページも認証必須
    feature "未ログインユーザーはヘルプにアクセスできない", %{session: session} do
      session
      |> visit("/help")
      |> wait_for_liveview()
      |> assert_has(css("h1", text: "Log in"))
    end
  end

  describe "ログアウト" do
    # A-08: ログアウト
    feature "ログアウトできる", %{session: session} do
      {session, _user} = register_and_login(session)

      session
      |> visit("/festivals")
      |> wait_for_liveview()
      |> click(css("a", text: "Log out"))
      |> wait_for_liveview()
      # ログアウト後、認証ページにアクセスできなくなる
      |> visit("/festivals")
      |> wait_for_liveview()
      |> assert_has(css("h1", text: "Log in"))
    end
  end

  describe "セッション維持" do
    # A-09: セッション維持
    feature "ログイン状態でページ遷移しても維持される", %{session: session} do
      {session, _user} = register_and_login(session)

      session
      |> visit("/festivals")
      |> wait_for_liveview()
      |> refute_has(css("h1", text: "Log in"))
      |> visit("/help")
      |> wait_for_liveview()
      |> refute_has(css("h1", text: "Log in"))
      |> visit("/festivals")
      |> wait_for_liveview()
      |> refute_has(css("h1", text: "Log in"))
    end
  end
end
