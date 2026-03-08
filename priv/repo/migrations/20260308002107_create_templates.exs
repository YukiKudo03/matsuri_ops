defmodule MatsuriOps.Repo.Migrations.CreateTemplates do
  use Ecto.Migration

  def change do
    create table(:templates) do
      add :name, :string, null: false
      add :description, :text
      add :scale, :string, default: "medium"
      add :default_expected_visitors, :integer
      add :default_expected_vendors, :integer
      add :is_public, :boolean, default: false

      add :creator_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:templates, [:creator_id])
    create index(:templates, [:is_public])
  end
end
