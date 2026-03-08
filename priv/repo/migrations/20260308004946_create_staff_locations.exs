defmodule MatsuriOps.Repo.Migrations.CreateStaffLocations do
  use Ecto.Migration

  def change do
    create table(:staff_locations) do
      add :latitude, :float, null: false
      add :longitude, :float, null: false
      add :accuracy, :float
      add :heading, :float
      add :speed, :float
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :festival_id, references(:festivals, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:staff_locations, [:user_id, :festival_id])
    create index(:staff_locations, [:festival_id])
    create index(:staff_locations, [:updated_at])
  end
end
