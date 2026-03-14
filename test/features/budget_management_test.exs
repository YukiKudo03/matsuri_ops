defmodule MatsuriOpsWeb.Features.BudgetManagementTest do
  @moduledoc """
  予算管理機能のE2Eテスト (Suite 6: B-01〜B-13)
  """

  use MatsuriOpsWeb.FeatureCase, async: false

  setup %{session: session} do
    {session, user} = register_and_login(session)
    {session, festival_id} = create_festival_in_db(session, user, %{name: "予算テスト祭り"})
    {:ok, session: session, user: user, festival_id: festival_id}
  end

  # カテゴリ追加モーダルを開く
  defp open_new_category_modal(session, festival_id) do
    session
    |> visit("/festivals/#{festival_id}/budgets")
    |> wait_for_liveview()
    |> click(link("カテゴリ追加"))
    |> wait_for_liveview(800)
  end

  # 経費登録モーダルを開く
  defp open_new_expense_modal(session, festival_id) do
    session
    |> visit("/festivals/#{festival_id}/budgets")
    |> wait_for_liveview()
    |> click(link("経費登録"))
    |> wait_for_liveview(800)
  end

  describe "予算ダッシュボード" do
    # B-01: 予算ダッシュボード表示
    feature "予算管理ダッシュボードを表示できる", %{session: session, festival_id: festival_id} do
      session
      |> visit("/festivals/#{festival_id}/budgets")
      |> wait_for_liveview()
      |> assert_has(css("h1", text: "予算・経費管理"))
    end
  end

  describe "カテゴリ管理" do
    # B-02: カテゴリ作成
    feature "予算カテゴリを作成できる", %{session: session, festival_id: festival_id} do
      session
      |> open_new_category_modal(festival_id)
      |> fill_in(css("#category-form input[name='budget_category[name]']"), with: "会場費")
      |> fill_in(css("#category-form input[name='budget_category[budget_amount]']"), with: "500000")
      |> click(button("保存"))
      |> wait_for_liveview(800)
      |> visit("/festivals/#{festival_id}/budgets")
      |> wait_for_liveview()
      |> assert_has(css("h4", text: "会場費"))
    end

    # B-03: カテゴリ編集
    feature "予算カテゴリを編集できる", %{session: session, festival_id: festival_id} do
      # カテゴリを作成
      session =
        session
        |> open_new_category_modal(festival_id)
        |> fill_in(css("#category-form input[name='budget_category[name]']"), with: "食費")
        |> fill_in(css("#category-form input[name='budget_category[budget_amount]']"), with: "200000")
        |> click(button("保存"))
        |> wait_for_liveview(800)

      # ページ再読み込みしてカテゴリの編集リンクをクリック
      session
      |> visit("/festivals/#{festival_id}/budgets")
      |> wait_for_liveview()
      |> click(css("a", text: "編集", count: :any, at: 0))
      |> wait_for_liveview(800)
      |> fill_in(css("#category-form input[name='budget_category[budget_amount]']"), with: "300000")
      |> click(button("保存"))
      |> wait_for_liveview(1000)
      |> visit("/festivals/#{festival_id}/budgets")
      |> wait_for_liveview()
      |> assert_has(css(".stat-value", text: "300,000", count: :any, at: 0))
    end
  end

  describe "経費管理" do
    # B-04: 経費登録
    feature "経費を登録できる", %{session: session, festival_id: festival_id} do
      session
      |> open_new_expense_modal(festival_id)
      |> fill_in(css("#expense-form input[name='expense[title]']"), with: "テント購入")
      |> fill_in(css("#expense-form input[name='expense[amount]']"), with: "50000")
      |> click(button("保存"))
      |> wait_for_liveview(800)
      |> assert_has(css("td", text: "テント購入"))
    end

    # B-05: 経費バリデーション
    feature "金額未入力で保存するとエラー", %{session: session, festival_id: festival_id} do
      session
      |> open_new_expense_modal(festival_id)
      |> fill_in(css("#expense-form input[name='expense[title]']"), with: "テスト経費")
      |> click(button("保存"))
      |> wait_for_liveview()
      |> assert_has(css("#expense-form"))
    end

    # B-07: 経費編集
    feature "経費を編集できる", %{session: session, festival_id: festival_id} do
      # 経費を作成
      session =
        session
        |> open_new_expense_modal(festival_id)
        |> fill_in(css("#expense-form input[name='expense[title]']"), with: "編集前経費")
        |> fill_in(css("#expense-form input[name='expense[amount]']"), with: "10000")
        |> click(button("保存"))
        |> wait_for_liveview(800)

      # 経費行クリックで編集モーダルを開く（row_click）
      session
      |> visit("/festivals/#{festival_id}/budgets")
      |> wait_for_liveview()
      |> click(css("td", text: "編集前経費"))
      |> wait_for_liveview(800)
      |> fill_in(css("#expense-form input[name='expense[title]']"), with: "編集後経費")
      |> fill_in(css("#expense-form input[name='expense[amount]']"), with: "20000")
      |> click(button("保存"))
      |> wait_for_liveview(1000)
      |> visit("/festivals/#{festival_id}/budgets")
      |> wait_for_liveview()
      |> assert_has(css("td", text: "編集後経費"))
    end

    # B-08: 経費承認
    feature "管理者が経費を承認できる", %{session: session, festival_id: festival_id} do
      # 経費を作成（pending状態）
      session =
        session
        |> open_new_expense_modal(festival_id)
        |> fill_in(css("#expense-form input[name='expense[title]']"), with: "承認テスト経費")
        |> fill_in(css("#expense-form input[name='expense[amount]']"), with: "30000")
        |> click(button("保存"))
        |> wait_for_liveview(800)

      # ページ再読み込みして承認ボタンをクリック
      session
      |> visit("/festivals/#{festival_id}/budgets")
      |> wait_for_liveview()
      |> assert_has(css("span", text: "申請中"))
      |> click(css("a", text: "承認"))
      |> wait_for_liveview()
      |> assert_has(css("span", text: "承認済"))
    end

    # B-10: 経費削除
    feature "経費を削除できる", %{session: session, festival_id: festival_id} do
      expense_title = "削除テスト経費#{System.unique_integer([:positive])}"

      # 経費を作成
      session =
        session
        |> open_new_expense_modal(festival_id)
        |> fill_in(css("#expense-form input[name='expense[title]']"), with: expense_title)
        |> fill_in(css("#expense-form input[name='expense[amount]']"), with: "5000")
        |> click(button("保存"))
        |> wait_for_liveview(800)

      # ページ再読み込みして削除
      session =
        session
        |> visit("/festivals/#{festival_id}/budgets")
        |> wait_for_liveview()
        |> assert_has(css("td", text: expense_title))

      _dialog_text = accept_confirm(session, fn s ->
        click(s, css("a", text: "削除", count: :any, at: 0))
      end)

      session
      |> wait_for_liveview(1000)
      |> refute_has(css("td", text: expense_title))
    end
  end

  describe "予算サマリー" do
    # B-12: 予算残高確認
    feature "予算サマリーが正しく表示される", %{session: session, festival_id: festival_id} do
      # カテゴリを作成
      session =
        session
        |> open_new_category_modal(festival_id)
        |> fill_in(css("#category-form input[name='budget_category[name]']"), with: "装飾費")
        |> fill_in(css("#category-form input[name='budget_category[budget_amount]']"), with: "100000")
        |> click(button("保存"))
        |> wait_for_liveview(800)

      # サマリーに総予算が表示される
      session
      |> visit("/festivals/#{festival_id}/budgets")
      |> wait_for_liveview()
      |> assert_has(css(".stat-title", text: "総予算"))
      # stat-valueは複数あるため、テキストマッチで確認
      |> assert_has(css(".stat-value", text: "100,000", count: :any, at: 0))
    end
  end
end
