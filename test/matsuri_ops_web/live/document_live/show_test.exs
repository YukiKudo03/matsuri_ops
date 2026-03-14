defmodule MatsuriOpsWeb.DocumentLive.ShowTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.DocumentsFixtures

  describe "Show page" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      document = document_fixture(festival, %{
        title: "テスト資料",
        file_name: "report.pdf",
        category: "contract",
        file_size: 2048,
        content_type: "application/pdf"
      })
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, document: document}
    end

    test "renders document details page", %{conn: conn, festival: festival, document: document} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/documents/#{document}")

      assert html =~ document.title
    end

    test "redirects if not logged in", %{festival: festival, document: document} do
      conn = build_conn()
      assert {:error, redirect} = live(conn, ~p"/festivals/#{festival}/documents/#{document}")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays document info", %{conn: conn, festival: festival, document: document} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/documents/#{document}")

      assert html =~ document.title
      assert html =~ document.file_name
    end

    test "shows file metadata", %{conn: conn, festival: festival, document: document} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/documents/#{document}")

      assert html =~ document.content_type or html =~ "pdf"
    end
  end
end
