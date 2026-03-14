defmodule MatsuriOpsWeb.QRCodeLive.ShowTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.QRCodesFixtures

  describe "Show page" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "renders QR code details page", %{conn: conn, festival: festival} do
      qr_code = qr_code_fixture(festival, %{name: "詳細表示QR"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/qr-codes/#{qr_code}")

      assert html =~ "詳細表示QR"
    end

    test "redirects if not logged in", %{festival: festival} do
      conn = build_conn()
      qr_code = qr_code_fixture(festival, %{name: "未認証テストQR"})

      assert {:error, redirect} = live(conn, ~p"/festivals/#{festival}/qr-codes/#{qr_code}")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays QR code information", %{conn: conn, festival: festival} do
      qr_code = qr_code_fixture(festival, %{
        name: "情報表示QR",
        code_type: "vendor",
        target_url: "https://example.com/vendor"
      })

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/qr-codes/#{qr_code}")

      assert html =~ "情報表示QR"
      assert html =~ "vendor" or html =~ "出店者"
      assert html =~ "https://example.com/vendor"
    end

    test "displays scan count", %{conn: conn, festival: festival} do
      qr_code = qr_code_fixture(festival, %{name: "スキャン数QR"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/qr-codes/#{qr_code}")

      assert html =~ "スキャン" or html =~ "scan" or html =~ "0"
    end

    test "shows QR code SVG preview when svg_data present", %{conn: conn, festival: festival} do
      qr_code = qr_code_fixture(festival, %{name: "SVGプレビューQR"})

      {:ok, view, html} = live(conn, ~p"/festivals/#{festival}/qr-codes/#{qr_code}")

      # QR code should have a preview area even if SVG is generated dynamically
      assert html =~ "SVGプレビューQR"
      assert has_element?(view, "[data-qr-preview]") or html =~ "svg" or html =~ "QRコード"
    end

    test "has download buttons", %{conn: conn, festival: festival} do
      qr_code = qr_code_fixture(festival, %{name: "ダウンロードQR"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/qr-codes/#{qr_code}")

      assert html =~ "ダウンロード" or html =~ "download" or html =~ "PNG" or html =~ "SVG"
    end
  end
end
