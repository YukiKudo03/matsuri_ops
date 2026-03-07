defmodule MatsuriOps.Repo.Migrations.CreateIncidents do
  use Ecto.Migration

  def change do
    # インシデント（当日発生する問題・緊急事態）
    create table(:incidents) do
      add :title, :string, null: false
      add :description, :text
      add :severity, :string, default: "low"
      add :category, :string
      add :location, :string
      add :status, :string, default: "reported"
      add :resolution, :text
      add :reported_at, :utc_datetime
      add :resolved_at, :utc_datetime

      add :festival_id, references(:festivals, on_delete: :delete_all), null: false
      add :reported_by_id, references(:users, on_delete: :nilify_all)
      add :assigned_to_id, references(:users, on_delete: :nilify_all)
      add :resolved_by_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:incidents, [:festival_id])
    create index(:incidents, [:status])
    create index(:incidents, [:severity])
    create index(:incidents, [:reported_at])

    # エリア混雑度
    create table(:area_status) do
      add :name, :string, null: false
      add :crowd_level, :integer, default: 0
      add :weather_temp, :decimal
      add :weather_wbgt, :decimal
      add :notes, :text

      add :festival_id, references(:festivals, on_delete: :delete_all), null: false
      add :updated_by_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:area_status, [:festival_id])
    create unique_index(:area_status, [:festival_id, :name])
  end
end
