defmodule MatsuriOps.Repo.Migrations.CreateCameras do
  use Ecto.Migration

  def change do
    create table(:cameras) do
      add :name, :string, null: false
      add :description, :text
      add :stream_url, :string, null: false
      add :stream_type, :string, null: false, default: "hls"
      add :location, :string
      add :latitude, :float
      add :longitude, :float
      add :status, :string, null: false, default: "offline"
      add :thumbnail_url, :string
      add :settings, :map, default: %{}
      add :festival_id, references(:festivals, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:cameras, [:festival_id])
    create index(:cameras, [:status])

    create table(:camera_recordings) do
      add :status, :string, null: false, default: "recording"
      add :started_at, :utc_datetime, null: false
      add :ended_at, :utc_datetime
      add :file_path, :string
      add :file_size, :bigint
      add :duration_seconds, :integer
      add :camera_id, references(:cameras, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:camera_recordings, [:camera_id])
    create index(:camera_recordings, [:status])
  end
end
