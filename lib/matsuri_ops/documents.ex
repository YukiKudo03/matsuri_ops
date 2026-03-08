defmodule MatsuriOps.Documents do
  @moduledoc """
  文書管理コンテキスト。

  文書のCRUD操作、バージョン管理、検索機能を提供する。
  """

  import Ecto.Query, warn: false
  alias MatsuriOps.Repo
  alias MatsuriOps.Documents.{Document, DocumentVersion}

  # Document functions

  @doc """
  祭りに関連する全ての文書を取得する。
  """
  def list_documents(festival_id) do
    Document
    |> where([d], d.festival_id == ^festival_id)
    |> order_by([d], desc: d.updated_at)
    |> Repo.all()
  end

  @doc """
  指定されたIDの文書を取得する。
  """
  def get_document!(id), do: Repo.get!(Document, id)

  @doc """
  文書を作成する。
  """
  def create_document(attrs \\ %{}) do
    %Document{}
    |> Document.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  文書を更新する。
  """
  def update_document(%Document{} = document, attrs) do
    document
    |> Document.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  文書を削除する。
  """
  def delete_document(%Document{} = document) do
    Repo.delete(document)
  end

  @doc """
  文書のchangesetを返す。
  """
  def change_document(%Document{} = document, attrs \\ %{}) do
    Document.changeset(document, attrs)
  end

  # DocumentVersion functions

  @doc """
  文書の全バージョンを取得する。
  """
  def list_document_versions(document_id) do
    DocumentVersion
    |> where([v], v.document_id == ^document_id)
    |> order_by([v], desc: v.version_number)
    |> Repo.all()
  end

  @doc """
  文書バージョンを作成する。
  """
  def create_document_version(attrs \\ %{}) do
    %DocumentVersion{}
    |> DocumentVersion.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  文書の最新バージョンを取得する。
  """
  def get_latest_version(document_id) do
    DocumentVersion
    |> where([v], v.document_id == ^document_id)
    |> order_by([v], desc: v.version_number)
    |> limit(1)
    |> Repo.one()
  end

  @doc """
  文書バージョンのchangesetを返す。
  """
  def change_document_version(%DocumentVersion{} = version, attrs \\ %{}) do
    DocumentVersion.changeset(version, attrs)
  end

  # Search functions

  @doc """
  文書を検索する。

  ## 引数
  - festival_id: 祭りID
  - query: 検索クエリ（文字列またはマップ）
    - 文字列: タイトルで部分一致検索
    - マップ: フィールド指定検索（例: %{category: "manual"}）
  """
  def search_documents(festival_id, query) when is_binary(query) do
    search_term = "%#{query}%"

    Document
    |> where([d], d.festival_id == ^festival_id)
    |> where([d], ilike(d.title, ^search_term) or ilike(d.description, ^search_term))
    |> order_by([d], desc: d.updated_at)
    |> Repo.all()
  end

  def search_documents(festival_id, %{category: category}) do
    Document
    |> where([d], d.festival_id == ^festival_id)
    |> where([d], d.category == ^category)
    |> order_by([d], desc: d.updated_at)
    |> Repo.all()
  end

  def search_documents(festival_id, _) do
    list_documents(festival_id)
  end
end
