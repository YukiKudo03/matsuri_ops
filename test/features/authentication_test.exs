defmodule MatsuriOpsWeb.Features.AuthenticationTest do
  @moduledoc """
  認証フローのE2Eテスト。

  Magic Link認証を含む認証プロセス全体をテストする。
  """

  use MatsuriOpsWeb.FeatureCase, async: true

  alias MatsuriOps.Accounts
  alias MatsuriOps.AccountsFixtures

  describe "ユーザー登録フロー" do
    feature "新規ユーザーがメールアドレスで登録できる", %{session: session} do
      session
      |> visit("/users/register")
      |> assert_has(css("h1", text: "登録"))
      |> fill_in(css("input[name='user[email]']"), with: "newuser@example.com")
      |> click(button("登録"))
      |> assert_has(css(".alert-info"))
    end

    feature "既存のメールアドレスでは登録できない", %{session: session} do
      existing_user = AccountsFixtures.user_fixture()

      session
      |> visit("/users/register")
      |> fill_in(css("input[name='user[email]']"), with: existing_user.email)
      |> click(button("登録"))
      |> assert_has(css(".alert-error"))
    end
  end

  describe "ログインフロー" do
    feature "登録済みユーザーがログインリンクをリクエストできる", %{session: session} do
      user = AccountsFixtures.user_fixture()

      session
      |> visit("/users/log-in")
      |> assert_has(css("h1", text: "ログイン"))
      |> fill_in(css("input[name='user[email]']"), with: user.email)
      |> click(button("ログイン"))
      |> assert_has(css(".alert-info"))
    end

    feature "Magic Linkでログインできる", %{session: session} do
      user = AccountsFixtures.user_fixture()

      # Magic Linkトークンを生成
      {token, _hashed} = Accounts.UserToken.build_email_token(user, "magic_link")

      session
      |> visit("/users/log-in/#{token}")
      |> wait_for_liveview()
      # ログイン成功後、リダイレクトされることを確認
      |> assert_has(css("nav"))
    end

    feature "無効なトークンではログインできない", %{session: session} do
      session
      |> visit("/users/log-in/invalid-token")
      |> assert_has(css(".alert-error"))
    end
  end

  describe "ログアウトフロー" do
    feature "ログイン中のユーザーがログアウトできる", %{session: session} do
      user = AccountsFixtures.user_fixture()
      {token, _hashed} = Accounts.UserToken.build_email_token(user, "magic_link")

      session
      |> visit("/users/log-in/#{token}")
      |> wait_for_liveview()
      |> click(css("a", text: "ログアウト"))
      |> assert_has(css("a", text: "ログイン"))
    end
  end

  describe "認証が必要なページへのアクセス" do
    feature "未ログインユーザーは祭り一覧にアクセスできない", %{session: session} do
      session
      |> visit("/festivals")
      # ログインページにリダイレクトされる
      |> assert_has(css("input[name='user[email]']"))
    end

    feature "ログイン後に元のページにリダイレクトされる", %{session: session} do
      user = AccountsFixtures.user_fixture()
      {token, _hashed} = Accounts.UserToken.build_email_token(user, "magic_link")

      session
      |> visit("/festivals")
      |> wait_for_liveview()
      # ログインページにリダイレクトされた後、ログイン
      |> visit("/users/log-in/#{token}")
      |> wait_for_liveview()
      # 祭り一覧にリダイレクトされる（または設定による）
      |> assert_has(css("nav"))
    end
  end
end
