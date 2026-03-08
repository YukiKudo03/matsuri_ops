defmodule MatsuriOps.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    create table(:documents) do
      add :title, :string, null: false
      add :description, :text
      add :file_name, :string, null: false
      add :file_path, :string, null: false
      add :file_size, :integer, null: false
      add :content_type, :string, null: false
      add :category, :string, default: "other"
      add :festival_id, references(:festivals, on_delete: :delete_all), null: false
      add :uploaded_by_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:documents, [:festival_id])
    create index(:documents, [:category])
    create index(:documents, [:uploaded_by_id])

    create table(:document_versions) do
      add :version_number, :integer, null: false
      add :file_path, :string, null: false
      add :file_size, :integer, null: false
      add :change_notes, :text
      add :document_id, references(:documents, on_delete: :delete_all), null: false
      add :uploaded_by_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:document_versions, [:document_id])
    create unique_index(:document_versions, [:document_id, :version_number])
  end
end
