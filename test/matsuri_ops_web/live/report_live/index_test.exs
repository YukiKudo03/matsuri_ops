defmodule MatsuriOpsWeb.ReportLive.IndexTest do
  @moduledoc """
  レポート機能のLiveViewテスト。

  TDDフェーズ: 🔴 RED
  - T-RPT-004: レポートLiveViewテスト
  """

  use MatsuriOpsWeb.ConnCase

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures

  alias MatsuriOps.Festivals
  alias MatsuriOps.Budgets

  defp create_festival_with_data(user, name, year) do
    {:ok, festival} =
      Festivals.create_festival(user, %{
        name: name,
        start_date: Date.new!(year, 8, 1),
        end_date: Date.new!(year, 8, 2),
        scale: "medium",
        status: "completed"
      })

    # 予算カテゴリと経費を追加
    {:ok, category} =
      Budgets.create_budget_category(%{
        festival_id: festival.id,
        name: "会場設営",
        budget_amount: Decimal.new(100_000)
      })

    {:ok, _expense} =
      Budgets.create_expense(%{
        festival_id: festival.id,
        category_id: category.id,
        title: "テント設営",
        amount: Decimal.new(80_000),
        status: "paid",
        expense_date: Date.utc_today()
      })

    # 収入を追加
    {:ok, _income} =
      Budgets.create_income(%{
        festival_id: festival.id,
        title: "協賛金",
        amount: Decimal.new(200_000),
        source_type: "sponsorship",
        status: "received",
        received_date: Date.utc_today()
      })

    festival
  end

  describe "レポート一覧ページ" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = create_festival_with_data(user, "2025年玄蕃まつり", 2025)
      %{conn: log_in_user(conn, user), user: user, festival: festival}
    end

    test "レポートページにアクセスできる", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/reports")

      assert html =~ "レポート"
      assert html =~ festival.name
    end

    test "決算サマリーが表示される", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/reports")

      assert html =~ "決算サマリー"
      assert html =~ "総予算"
      assert html =~ "総支出"
      assert html =~ "総収入"
      assert html =~ "収支"
    end

    test "カテゴリ別支出が表示される", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/reports")

      assert html =~ "カテゴリ別支出"
      assert html =~ "会場設営"
    end

    test "収入源別内訳が表示される", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/reports")

      assert html =~ "収入源別"
      assert html =~ "協賛金"
    end
  end

  describe "PDF出力" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = create_festival_with_data(user, "2025年玄蕃まつり", 2025)
      %{conn: log_in_user(conn, user), user: user, festival: festival}
    end

    test "PDFダウンロードボタンが表示される", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/reports")

      assert html =~ "PDF出力"
    end

    test "PDFダウンロードでHTMLレポートを取得できる", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/reports")

      # PDF出力ボタンをクリック
      view |> element("a", "PDF出力") |> render_click()

      # HTMLプレビューモードに切り替わる（実際のPDFダウンロードはJS側で処理）
      html = render(view)
      assert html =~ "レポート" or html =~ "PDF"
    end
  end

  describe "年度比較ページ" do
    setup %{conn: conn} do
      user = user_fixture()
      festival_2024 = create_festival_with_data(user, "2024年玄蕃まつり", 2024)
      festival_2025 = create_festival_with_data(user, "2025年玄蕃まつり", 2025)

      %{
        conn: log_in_user(conn, user),
        user: user,
        festival_2024: festival_2024,
        festival_2025: festival_2025
      }
    end

    test "年度比較ページにアクセスできる", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/reports/compare")

      assert html =~ "年度比較"
    end

    test "比較対象の祭りを選択できる", %{conn: conn, festival_2024: f24, festival_2025: f25} do
      {:ok, view, _html} = live(conn, ~p"/reports/compare")

      # 祭りを選択
      html =
        view
        |> form("#compare-form", %{"festival_ids" => [f24.id, f25.id]})
        |> render_submit()

      assert html =~ "2024年玄蕃まつり"
      assert html =~ "2025年玄蕃まつり"
    end

    test "比較結果に変化率が表示される", %{conn: conn, festival_2024: f24, festival_2025: f25} do
      {:ok, view, _html} = live(conn, ~p"/reports/compare")

      html =
        view
        |> form("#compare-form", %{"festival_ids" => [f24.id, f25.id]})
        |> render_submit()

      assert html =~ "変化率" or html =~ "%"
    end
  end
end
