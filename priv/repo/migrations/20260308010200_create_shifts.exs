defmodule MatsuriOps.Repo.Migrations.CreateShifts do
  use Ecto.Migration

  def change do
    create table(:shifts) do
      add :name, :string, null: false
      add :start_time, :utc_datetime, null: false
      add :end_time, :utc_datetime, null: false
      add :location, :string
      add :required_staff, :integer, default: 1
      add :description, :text
      add :festival_id, references(:festivals, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:shifts, [:festival_id])
    create index(:shifts, [:start_time])

    create table(:shift_assignments) do
      add :status, :string, default: "assigned"
      add :notes, :text
      add :shift_id, references(:shifts, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:shift_assignments, [:shift_id])
    create index(:shift_assignments, [:user_id])
    create unique_index(:shift_assignments, [:shift_id, :user_id])
  end
end
