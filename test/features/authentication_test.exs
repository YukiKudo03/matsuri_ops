defmodule MatsuriOpsWeb.Features.AuthenticationTest do
  @moduledoc """
  認証フローのE2Eテスト。

  Magic Link認証を含む認証プロセス全体をテストする。
  注意: Wallabyのサンドボックス制限により、テストプロセスで作成したデータは
  ブラウザから見えない。そのため、UIを通じてデータを作成するテストのみ実行。
  """

  use MatsuriOpsWeb.FeatureCase, async: false

  describe "ユーザー登録フロー" do
    feature "新規ユーザーがメールアドレスで登録できる", %{session: session} do
      # ユニークなメールアドレスを生成
      email = "newuser#{System.unique_integer([:positive])}@example.com"

      session
      |> visit("/users/register")
      |> assert_has(css("h1", text: "Register for an account"))
      |> fill_in(css("#registration_form input[name='user[email]']"), with: email)
      |> click(button("Create an account"))
      |> wait_for_liveview()
      # 登録後、ログインページにリダイレクトされフラッシュメッセージが表示される
      |> assert_has(css("h1", text: "Log in"))
    end

    feature "登録ページの表示を確認", %{session: session} do
      session
      |> visit("/users/register")
      |> assert_has(css("h1", text: "Register for an account"))
      |> assert_has(css("#registration_form"))
      |> assert_has(button("Create an account"))
    end
  end

  describe "ログインフロー" do
    feature "ログインページが表示される", %{session: session} do
      session
      |> visit("/users/log-in")
      |> assert_has(css("h1", text: "Log in"))
      # Magic Linkログインフォームが表示される
      |> assert_has(css("#login_form_magic"))
      |> assert_has(button("Log in with email"))
    end

    feature "無効なトークンではログインできない", %{session: session} do
      session
      |> visit("/users/log-in/invalid-token")
      |> wait_for_liveview()
      # エラーフラッシュが表示されてログインページにリダイレクト
      |> assert_has(css("h1", text: "Log in"))
      # エラーアラートが表示される (alert-errorクラス)
      |> assert_has(css(".alert-error"))
    end
  end

  describe "認証が必要なページへのアクセス" do
    feature "未ログインユーザーは祭り一覧にアクセスできない", %{session: session} do
      session
      |> visit("/festivals")
      |> wait_for_liveview()
      # ログインページにリダイレクトされる
      |> assert_has(css("h1", text: "Log in"))
    end
  end
end
