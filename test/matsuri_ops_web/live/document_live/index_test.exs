defmodule MatsuriOpsWeb.DocumentLive.IndexTest do
  use MatsuriOpsWeb.ConnCase

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures

  alias MatsuriOps.Festivals
  alias MatsuriOps.Documents

  defp create_festival(user) do
    {:ok, festival} =
      Festivals.create_festival(user, %{
        name: "テスト祭り",
        start_date: Date.new!(2025, 8, 1),
        end_date: Date.new!(2025, 8, 2),
        scale: "medium",
        status: "planning"
      })

    festival
  end

  defp create_document(festival, user, attrs \\ %{}) do
    {:ok, document} =
      attrs
      |> Enum.into(%{
        title: "テストドキュメント",
        description: "テスト用の文書",
        file_name: "test.pdf",
        file_path: "/uploads/documents/test.pdf",
        file_size: 1024,
        content_type: "application/pdf",
        category: "other",
        festival_id: festival.id,
        uploaded_by_id: user.id
      })
      |> Documents.create_document()

    document
  end

  describe "Index" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = create_festival(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "lists all documents for festival", %{conn: conn, festival: festival, user: user} do
      document = create_document(festival, user, %{title: "運営マニュアル"})
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival.id}/documents")

      assert html =~ "文書管理"
      assert html =~ document.title
    end

    test "shows empty state when no documents", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival.id}/documents")

      assert html =~ "文書がありません"
    end

    test "can search documents by title", %{conn: conn, festival: festival, user: user} do
      _doc1 = create_document(festival, user, %{title: "運営マニュアル"})
      _doc2 = create_document(festival, user, %{title: "予算計画書"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival.id}/documents")

      result =
        view
        |> form("#search-form", %{search: "マニュアル"})
        |> render_submit()

      assert result =~ "運営マニュアル"
      refute result =~ "予算計画書"
    end
  end
end
