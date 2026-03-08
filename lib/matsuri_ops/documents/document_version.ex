defmodule MatsuriOps.Documents.DocumentVersion do
  @moduledoc """
  文書バージョンスキーマ。

  文書の各バージョンを管理し、変更履歴を追跡する。
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "document_versions" do
    field :version_number, :integer
    field :file_path, :string
    field :file_size, :integer
    field :change_notes, :string

    belongs_to :document, MatsuriOps.Documents.Document
    belongs_to :uploaded_by, MatsuriOps.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(version, attrs) do
    version
    |> cast(attrs, [:version_number, :file_path, :file_size, :change_notes, :document_id, :uploaded_by_id])
    |> validate_required([:version_number, :file_path, :file_size, :document_id])
    |> validate_number(:version_number, greater_than: 0)
    |> foreign_key_constraint(:document_id)
    |> foreign_key_constraint(:uploaded_by_id)
    |> unique_constraint([:document_id, :version_number])
  end
end
