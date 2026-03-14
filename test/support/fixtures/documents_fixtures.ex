defmodule MatsuriOps.DocumentsFixtures do
  @moduledoc """
  Test fixtures for Documents context.
  """

  alias MatsuriOps.Documents

  def valid_document_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      title: "テストドキュメント#{System.unique_integer([:positive])}",
      file_name: "test.pdf",
      file_path: "/uploads/test.pdf",
      file_size: 1024,
      content_type: "application/pdf",
      category: "other"
    })
  end

  def document_fixture(festival, attrs \\ %{}) do
    attrs =
      attrs
      |> valid_document_attributes()
      |> Map.put(:festival_id, festival.id)

    {:ok, document} = Documents.create_document(attrs)
    document
  end
end
