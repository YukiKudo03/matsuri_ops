defmodule MatsuriOps.Repo.Migrations.CreateFestivals do
  use Ecto.Migration

  def change do
    # 祭り規模: small (~2,000人), medium (2,000~10,000人), large (10,000人~)
    create table(:festivals) do
      add :name, :string, null: false
      add :description, :text
      add :scale, :string, default: "medium"
      add :start_date, :date, null: false
      add :end_date, :date, null: false
      add :venue_name, :string
      add :venue_address, :string
      add :expected_visitors, :integer
      add :expected_vendors, :integer
      add :status, :string, default: "planning"
      add :organizer_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:festivals, [:status])
    create index(:festivals, [:start_date])
    create index(:festivals, [:organizer_id])

    # 祭りメンバー（役割割り当て）
    create table(:festival_members) do
      add :festival_id, references(:festivals, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :role, :string, null: false
      add :assigned_area, :string
      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:festival_members, [:festival_id, :user_id])
    create index(:festival_members, [:user_id])
  end
end
