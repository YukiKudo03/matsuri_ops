defmodule MatsuriOps.DocumentsTest do
  @moduledoc """
  文書管理機能のテスト。

  TDDフェーズ: 🔴 RED → 🟢 GREEN
  """

  use MatsuriOps.DataCase

  alias MatsuriOps.Documents
  alias MatsuriOps.Documents.{Document, DocumentVersion}
  alias MatsuriOps.Festivals

  import MatsuriOps.AccountsFixtures

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

  describe "documents" do
    setup do
      user = user_fixture()
      festival = create_festival(user)
      %{user: user, festival: festival}
    end

    @valid_attrs %{
      title: "運営マニュアル",
      description: "祭り運営の手順書",
      file_name: "manual.pdf",
      file_path: "/uploads/documents/manual.pdf",
      file_size: 1024,
      content_type: "application/pdf",
      category: "manual"
    }

    @invalid_attrs %{title: nil, file_name: nil}

    test "list_documents/1 returns all documents for a festival", %{festival: festival, user: user} do
      document = document_fixture(festival, user)
      assert Documents.list_documents(festival.id) == [document]
    end

    test "get_document!/1 returns the document with given id", %{festival: festival, user: user} do
      document = document_fixture(festival, user)
      assert Documents.get_document!(document.id) == document
    end

    test "create_document/1 with valid data creates a document", %{festival: festival, user: user} do
      attrs = Map.merge(@valid_attrs, %{festival_id: festival.id, uploaded_by_id: user.id})
      assert {:ok, %Document{} = document} = Documents.create_document(attrs)
      assert document.title == "運営マニュアル"
      assert document.file_name == "manual.pdf"
      assert document.category == "manual"
    end

    test "create_document/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Documents.create_document(@invalid_attrs)
    end

    test "update_document/2 with valid data updates the document", %{festival: festival, user: user} do
      document = document_fixture(festival, user)
      update_attrs = %{title: "更新されたマニュアル"}
      assert {:ok, %Document{} = document} = Documents.update_document(document, update_attrs)
      assert document.title == "更新されたマニュアル"
    end

    test "delete_document/1 deletes the document", %{festival: festival, user: user} do
      document = document_fixture(festival, user)
      assert {:ok, %Document{}} = Documents.delete_document(document)
      assert_raise Ecto.NoResultsError, fn -> Documents.get_document!(document.id) end
    end

    test "change_document/1 returns a document changeset", %{festival: festival, user: user} do
      document = document_fixture(festival, user)
      assert %Ecto.Changeset{} = Documents.change_document(document)
    end
  end

  describe "document versions" do
    setup do
      user = user_fixture()
      festival = create_festival(user)
      document = document_fixture(festival, user)
      %{user: user, festival: festival, document: document}
    end

    test "list_document_versions/1 returns all versions for a document", %{document: document, user: user} do
      version = version_fixture(document, user)
      versions = Documents.list_document_versions(document.id)
      assert length(versions) == 1
      assert hd(versions).id == version.id
    end

    test "create_document_version/1 creates a new version", %{document: document, user: user} do
      attrs = %{
        document_id: document.id,
        uploaded_by_id: user.id,
        version_number: 2,
        file_path: "/uploads/documents/manual_v2.pdf",
        file_size: 2048,
        change_notes: "レイアウト修正"
      }

      assert {:ok, %DocumentVersion{} = version} = Documents.create_document_version(attrs)
      assert version.version_number == 2
      assert version.change_notes == "レイアウト修正"
    end

    test "get_latest_version/1 returns the latest version", %{document: document, user: user} do
      _version1 = version_fixture(document, user, %{version_number: 1})
      version2 = version_fixture(document, user, %{version_number: 2})

      latest = Documents.get_latest_version(document.id)
      assert latest.id == version2.id
      assert latest.version_number == 2
    end
  end

  describe "document search" do
    setup do
      user = user_fixture()
      festival = create_festival(user)
      %{user: user, festival: festival}
    end

    test "search_documents/2 finds documents by title", %{festival: festival, user: user} do
      doc1 = document_fixture(festival, user, %{title: "運営マニュアル"})
      _doc2 = document_fixture(festival, user, %{title: "予算計画書"})

      results = Documents.search_documents(festival.id, "マニュアル")
      assert length(results) == 1
      assert hd(results).id == doc1.id
    end

    test "search_documents/2 finds documents by category", %{festival: festival, user: user} do
      _doc1 = document_fixture(festival, user, %{category: "manual"})
      doc2 = document_fixture(festival, user, %{category: "budget"})

      results = Documents.search_documents(festival.id, %{category: "budget"})
      assert length(results) == 1
      assert hd(results).id == doc2.id
    end

    test "search_documents/2 returns empty list when no match", %{festival: festival} do
      results = Documents.search_documents(festival.id, "存在しない")
      assert results == []
    end
  end

  # Helper functions
  defp document_fixture(festival, user, attrs \\ %{}) do
    {:ok, document} =
      attrs
      |> Enum.into(%{
        title: "テストドキュメント#{System.unique_integer()}",
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

  defp version_fixture(document, user, attrs \\ %{}) do
    {:ok, version} =
      attrs
      |> Enum.into(%{
        document_id: document.id,
        uploaded_by_id: user.id,
        version_number: 1,
        file_path: "/uploads/documents/test_v1.pdf",
        file_size: 1024,
        change_notes: "初期バージョン"
      })
      |> Documents.create_document_version()

    version
  end
end
