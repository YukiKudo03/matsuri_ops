defmodule MatsuriOpsWeb.QRCodeLive.IndexTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.QRCodesFixtures

  describe "Index page" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "renders QR code page", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/qr-codes")

      assert html =~ "QRコード管理"
    end

    test "redirects if not logged in", %{festival: festival} do
      conn = build_conn()
      assert {:error, redirect} = live(conn, ~p"/festivals/#{festival}/qr-codes")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays statistics", %{conn: conn, festival: festival} do
      _qr_code = qr_code_fixture(festival, %{name: "統計テストQR"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/qr-codes")

      assert html =~ "total_count" or html =~ "total_scans" or html =~ "合計" or html =~ "スキャン"
    end

    test "displays QR codes in table", %{conn: conn, festival: festival} do
      qr_code = qr_code_fixture(festival, %{name: "テーブル表示QR"})

      {:ok, view, html} = live(conn, ~p"/festivals/#{festival}/qr-codes")

      assert html =~ "テーブル表示QR"
      assert has_element?(view, "#qr_codes") or has_element?(view, "#qr-codes")
      assert has_element?(view, "#qr_codes-#{qr_code.id}") or has_element?(view, "#qr-code-#{qr_code.id}")
    end

    test "can filter by type", %{conn: conn, festival: festival} do
      _ticket_qr = qr_code_fixture(festival, %{name: "チケットQR", code_type: "ticket"})
      _info_qr = qr_code_fixture(festival, %{name: "情報QR", code_type: "info"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/qr-codes")

      html =
        view
        |> render_click("filter", %{"type" => "ticket"})

      assert html =~ "チケットQR"
    end

    test "can delete QR code", %{conn: conn, festival: festival} do
      qr_code = qr_code_fixture(festival, %{name: "削除対象QR"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/qr-codes")

      assert render(view) =~ "削除対象QR"

      view
      |> render_click("delete", %{"id" => to_string(qr_code.id)})

      refute render(view) =~ "削除対象QR"
    end

    test "opens new QR modal", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/qr-codes")

      view
      |> element("a", "新規QRコード")
      |> render_click()

      assert_patch(view, ~p"/festivals/#{festival}/qr-codes/new")
      assert has_element?(view, "#qr-code-form")
    end

    test "saves new QR code", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/qr-codes/new")

      view
      |> form("#qr-code-form", qr_code: %{
        name: "新規QRコード",
        code_type: "ticket",
        target_url: "https://example.com/ticket"
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/qr-codes")
      assert render(view) =~ "新規QRコード"
    end

    test "opens edit modal", %{conn: conn, festival: festival} do
      qr_code = qr_code_fixture(festival, %{name: "編集対象QR"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/qr-codes/#{qr_code}/edit")

      assert html =~ "編集対象QR"
      assert html =~ "QRコード編集" or html =~ "編集"
    end

    test "updates QR code", %{conn: conn, festival: festival} do
      qr_code = qr_code_fixture(festival, %{name: "更新前QR"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/qr-codes/#{qr_code}/edit")

      view
      |> form("#qr-code-form", qr_code: %{name: "更新後QR"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/qr-codes")
      assert render(view) =~ "更新後QR"
    end
  end
end
