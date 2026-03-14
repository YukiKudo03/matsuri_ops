defmodule MatsuriOps.Documents.DocumentTest do
  use MatsuriOps.DataCase, async: true

  alias MatsuriOps.Documents.Document

  describe "changeset/2" do
    @valid_attrs %{
      title: "テスト文書",
      file_name: "test.pdf",
      file_path: "/uploads/test.pdf",
      file_size: 1024,
      content_type: "application/pdf",
      festival_id: 1
    }

    test "valid changeset with required fields" do
      changeset = Document.changeset(%Document{}, @valid_attrs)
      assert changeset.valid?
    end

    test "invalid changeset without title" do
      changeset = Document.changeset(%Document{}, Map.delete(@valid_attrs, :title))
      refute changeset.valid?
      assert %{title: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset without file_name" do
      changeset = Document.changeset(%Document{}, Map.delete(@valid_attrs, :file_name))
      refute changeset.valid?
    end

    test "invalid changeset with invalid category" do
      changeset = Document.changeset(%Document{}, Map.put(@valid_attrs, :category, "invalid"))
      refute changeset.valid?
    end

    test "valid changeset with all optional fields" do
      changeset = Document.changeset(%Document{}, Map.merge(@valid_attrs, %{
        description: "テスト文書の説明",
        category: "manual",
        uploaded_by_id: 1
      }))

      assert changeset.valid?
    end
  end

  describe "categories/0" do
    test "returns all valid categories" do
      categories = Document.categories()
      assert "manual" in categories
      assert "budget" in categories
      assert "plan" in categories
      assert "report" in categories
      assert "contract" in categories
      assert "other" in categories
    end
  end
end
