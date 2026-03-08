defmodule MatsuriOpsWeb.Features.OperationsDashboardTest do
  @moduledoc """
  当日運営ダッシュボードのE2Eテスト。

  注意: Wallabyのサンドボックス制限により、ログインが必要なテストは
  現在スキップしています。認証が完了したUIフローのテストは、
  サンドボックス設定が解決された後に有効化します。
  """

  use MatsuriOpsWeb.FeatureCase, async: false

  describe "認証が必要なページ" do
    feature "未ログインユーザーは運営ダッシュボードにアクセスできない", %{session: session} do
      session
      |> visit("/festivals/1/operations")
      |> wait_for_liveview()
      # ログインページにリダイレクトされる
      |> assert_has(css("h1", text: "Log in"))
    end
  end
end
