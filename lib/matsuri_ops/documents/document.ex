defmodule MatsuriOps.Documents.Document do
  @moduledoc """
  文書スキーマ。

  祭りに関連する文書（マニュアル、企画書、予算書など）を管理する。
  """

  use Ecto.Schema
  import Ecto.Changeset

  @categories ~w(manual budget plan report contract other)

  schema "documents" do
    field :title, :string
    field :description, :string
    field :file_name, :string
    field :file_path, :string
    field :file_size, :integer
    field :content_type, :string
    field :category, :string, default: "other"

    belongs_to :festival, MatsuriOps.Festivals.Festival
    belongs_to :uploaded_by, MatsuriOps.Accounts.User
    has_many :versions, MatsuriOps.Documents.DocumentVersion

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(document, attrs) do
    document
    |> cast(attrs, [
      :title,
      :description,
      :file_name,
      :file_path,
      :file_size,
      :content_type,
      :category,
      :festival_id,
      :uploaded_by_id
    ])
    |> validate_required([:title, :file_name, :file_path, :file_size, :content_type, :festival_id])
    |> validate_inclusion(:category, @categories)
    |> foreign_key_constraint(:festival_id)
    |> foreign_key_constraint(:uploaded_by_id)
  end

  def categories, do: @categories
end
