defmodule MatsuriOps.Repo.Migrations.CreateQrCodes do
  use Ecto.Migration

  def change do
    create table(:qr_codes) do
      add :name, :string, null: false
      add :code_type, :string, null: false, default: "custom"
      add :target_url, :string, null: false
      add :svg_data, :text
      add :scan_count, :integer, default: 0
      add :festival_id, references(:festivals, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:qr_codes, [:festival_id])
    create index(:qr_codes, [:code_type])
  end
end
