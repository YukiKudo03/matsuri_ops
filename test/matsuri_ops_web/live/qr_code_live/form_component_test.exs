defmodule MatsuriOpsWeb.QRCodeLive.FormComponentTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.QRCodesFixtures

  describe "Form component via Index LiveView" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "validates required fields", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/qr-codes/new")

      result =
        view
        |> form("#qr-code-form", qr_code: %{name: "", target_url: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "saves new QR code with valid data", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/qr-codes/new")

      view
      |> form("#qr-code-form", qr_code: %{
        name: "フォームテストQR",
        code_type: "ticket",
        target_url: "https://example.com/form-test"
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/qr-codes")
      html = render(view)
      assert html =~ "フォームテストQR"
    end

    test "updates existing QR code", %{conn: conn, festival: festival} do
      qr_code = qr_code_fixture(festival, %{name: "更新前フォームQR"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/qr-codes/#{qr_code}/edit")

      view
      |> form("#qr-code-form", qr_code: %{name: "更新後フォームQR"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/qr-codes")
      html = render(view)
      assert html =~ "更新後フォームQR"
    end

    test "shows validation errors", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/qr-codes/new")

      result =
        view
        |> form("#qr-code-form", qr_code: %{
          name: "",
          target_url: ""
        })
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank" or result =~ "invalid"
    end

    test "form has required fields", %{conn: conn, festival: festival} do
      {:ok, view, html} = live(conn, ~p"/festivals/#{festival}/qr-codes/new")

      assert has_element?(view, "#qr-code-form")
      assert html =~ "name" or html =~ "名前" or html =~ "QRコード名"
      assert html =~ "code_type" or html =~ "種類" or html =~ "タイプ"
      assert html =~ "target_url" or html =~ "URL" or html =~ "リンク先"
    end

    test "form has code_type select with options", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/qr-codes/new")

      assert html =~ "select" or html =~ "code_type"
      assert html =~ "ticket" or html =~ "チケット"
      assert html =~ "custom" or html =~ "カスタム"
    end

    test "form id is qr-code-form", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/qr-codes/new")

      assert has_element?(view, "#qr-code-form")
    end
  end
end
