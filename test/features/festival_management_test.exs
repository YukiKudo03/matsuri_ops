defmodule MatsuriOpsWeb.Features.FestivalManagementTest do
  @moduledoc """
  祭り管理機能のE2Eテスト。

  祭りの作成、編集、削除、詳細表示をテストする。
  """

  use MatsuriOpsWeb.FeatureCase, async: true

  alias MatsuriOps.Accounts
  alias MatsuriOps.AccountsFixtures

  setup %{session: session} do
    # テスト用ユーザーを作成してログイン
    user = AccountsFixtures.user_fixture()
    {token, _hashed} = Accounts.UserToken.build_email_token(user, "magic_link")

    session =
      session
      |> visit("/users/log-in/#{token}")
      |> wait_for_liveview()

    {:ok, session: session, user: user}
  end

  describe "祭り一覧" do
    feature "祭り一覧ページが表示される", %{session: session} do
      session
      |> visit("/festivals")
      |> assert_has(css("h1", text: "祭り"))
    end

    feature "新規祭り作成ボタンが表示される", %{session: session} do
      session
      |> visit("/festivals")
      |> assert_has(css("a", text: "新規作成"))
    end
  end

  describe "祭り作成" do
    feature "新規祭りを作成できる", %{session: session} do
      session
      |> visit("/festivals/new")
      |> assert_has(css("h2", text: "新規祭り"))
      |> fill_in(css("input[name='festival[name]']"), with: "テスト祭り2024")
      |> fill_in(css("textarea[name='festival[description]']"), with: "テスト用の祭りです")
      |> fill_in(css("input[name='festival[start_date]']"), with: "2024-08-15")
      |> fill_in(css("input[name='festival[end_date]']"), with: "2024-08-16")
      |> click(button("保存"))
      |> wait_for_liveview()
      |> assert_has(css(".alert-info", text: "作成"))
    end

    feature "必須項目が空の場合はエラーが表示される", %{session: session} do
      session
      |> visit("/festivals/new")
      |> click(button("保存"))
      |> wait_for_liveview()
      |> assert_has(css("[phx-feedback-for]"))
    end
  end

  describe "祭り詳細" do
    setup %{session: session, user: user} do
      # テスト用の祭りを作成
      {:ok, festival} = MatsuriOps.Festivals.create_festival(%{
        name: "詳細テスト祭り",
        description: "詳細表示テスト用",
        start_date: ~D[2024-08-15],
        end_date: ~D[2024-08-16]
      })

      {:ok, session: session, user: user, festival: festival}
    end

    feature "祭りの詳細ページが表示される", %{session: session, festival: festival} do
      session
      |> visit("/festivals/#{festival.id}")
      |> assert_has(css("h1", text: festival.name))
    end

    feature "祭り詳細からタスク管理に移動できる", %{session: session, festival: festival} do
      session
      |> visit("/festivals/#{festival.id}")
      |> click(css("a", text: "タスク"))
      |> wait_for_liveview()
      |> assert_has(css("h1", text: "タスク"))
    end

    feature "祭り詳細から予算管理に移動できる", %{session: session, festival: festival} do
      session
      |> visit("/festivals/#{festival.id}")
      |> click(css("a", text: "予算"))
      |> wait_for_liveview()
      |> assert_has(css("h1", text: "予算"))
    end

    feature "祭り詳細からスタッフ管理に移動できる", %{session: session, festival: festival} do
      session
      |> visit("/festivals/#{festival.id}")
      |> click(css("a", text: "スタッフ"))
      |> wait_for_liveview()
      |> assert_has(css("h1", text: "スタッフ"))
    end

    feature "祭り詳細から運営ダッシュボードに移動できる", %{session: session, festival: festival} do
      session
      |> visit("/festivals/#{festival.id}")
      |> click(css("a", text: "運営"))
      |> wait_for_liveview()
      |> assert_has(css("h1", text: "運営"))
    end
  end

  describe "祭り編集" do
    setup %{session: session, user: user} do
      {:ok, festival} = MatsuriOps.Festivals.create_festival(%{
        name: "編集テスト祭り",
        description: "編集テスト用",
        start_date: ~D[2024-08-15],
        end_date: ~D[2024-08-16]
      })

      {:ok, session: session, user: user, festival: festival}
    end

    feature "祭り情報を編集できる", %{session: session, festival: festival} do
      session
      |> visit("/festivals/#{festival.id}/edit")
      |> assert_has(css("h2", text: "編集"))
      |> fill_in(css("input[name='festival[name]']"), with: "更新された祭り名")
      |> click(button("保存"))
      |> wait_for_liveview()
      |> assert_has(css(".alert-info", text: "更新"))
    end
  end

  describe "祭り削除" do
    setup %{session: session, user: user} do
      {:ok, festival} = MatsuriOps.Festivals.create_festival(%{
        name: "削除テスト祭り",
        description: "削除テスト用",
        start_date: ~D[2024-08-15],
        end_date: ~D[2024-08-16]
      })

      {:ok, session: session, user: user, festival: festival}
    end

    feature "祭りを削除できる", %{session: session, festival: festival} do
      session
      |> visit("/festivals")
      |> click(css("[data-confirm]", text: "削除"))
      |> Wallaby.Browser.accept_confirm()
      |> wait_for_liveview()
      |> refute_has(css("td", text: festival.name))
    end
  end
end
