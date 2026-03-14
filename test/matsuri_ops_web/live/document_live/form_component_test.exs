defmodule MatsuriOpsWeb.DocumentLive.FormComponentTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.DocumentsFixtures

  describe "New document form" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "validates required fields", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/documents/new")

      result =
        view
        |> form("#document-form", document: %{title: "", file_name: "", file_path: "", file_size: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "saves new document", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/documents/new")

      view
      |> form("#document-form", document: %{
        title: "新規ドキュメント",
        description: "テスト説明",
        category: "other",
        file_name: "new_doc.pdf",
        file_path: "/uploads/new_doc.pdf",
        file_size: "4096",
        content_type: "application/pdf"
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/documents")
      assert render(view) =~ "新規ドキュメント"
    end

    test "form has fields: title, description, category, file_name, file_path, file_size, content_type", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/documents/new")

      assert html =~ "title" or html =~ "タイトル"
      assert html =~ "description" or html =~ "説明"
      assert html =~ "category" or html =~ "カテゴリ"
      assert html =~ "file_name" or html =~ "ファイル名"
      assert html =~ "file_path" or html =~ "ファイルパス"
      assert html =~ "file_size" or html =~ "ファイルサイズ"
      assert html =~ "content_type" or html =~ "コンテンツタイプ"
    end
  end
end
