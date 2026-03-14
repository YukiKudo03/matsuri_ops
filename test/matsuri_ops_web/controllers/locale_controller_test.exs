defmodule MatsuriOpsWeb.LocaleControllerTest do
  use MatsuriOpsWeb.ConnCase, async: true

  describe "GET /locale/:locale" do
    test "switches locale to ja and redirects to root", %{conn: conn} do
      conn = get(conn, "/locale/ja")

      assert redirected_to(conn) == "/"
      assert get_session(conn, :locale) == "ja"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "言語を日本語に切り替えました"
    end

    test "switches locale to vi and redirects to root", %{conn: conn} do
      conn = get(conn, "/locale/vi")

      assert redirected_to(conn) == "/"
      assert get_session(conn, :locale) == "vi"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "Đã chuyển sang tiếng Việt"
    end

    test "defaults to ja for unsupported locale", %{conn: conn} do
      conn = get(conn, "/locale/en")

      assert redirected_to(conn) == "/"
      assert get_session(conn, :locale) == "ja"
    end

    test "redirects to referer path when referer header is set", %{conn: conn} do
      conn =
        conn
        |> put_req_header("referer", "http://localhost:4000/festivals")
        |> get("/locale/ja")

      assert redirected_to(conn) == "/festivals"
    end

    test "redirects to root when referer has no path", %{conn: conn} do
      conn =
        conn
        |> put_req_header("referer", "http://localhost:4000")
        |> get("/locale/ja")

      assert redirected_to(conn) == "/"
    end
  end
end
