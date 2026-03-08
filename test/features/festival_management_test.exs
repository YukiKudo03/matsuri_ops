defmodule MatsuriOpsWeb.Features.FestivalManagementTest do
  @moduledoc """
  祭り管理機能のE2Eテスト。

  注意: Wallabyのサンドボックス制限により、ログインが必要なテストは
  現在スキップしています。認証が完了したUIフローのテストは、
  サンドボックス設定が解決された後に有効化します。
  """

  use MatsuriOpsWeb.FeatureCase, async: false

  describe "認証が必要なページ" do
    feature "未ログインユーザーは祭り一覧にリダイレクトされる", %{session: session} do
      session
      |> visit("/festivals")
      |> wait_for_liveview()
      # ログインページにリダイレクトされる
      |> assert_has(css("h1", text: "Log in"))
    end

    feature "未ログインユーザーは祭り詳細にアクセスできない", %{session: session} do
      session
      |> visit("/festivals/1")
      |> wait_for_liveview()
      # ログインページにリダイレクトされる
      |> assert_has(css("h1", text: "Log in"))
    end
  end
end
