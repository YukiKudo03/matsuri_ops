defmodule MatsuriOps.Repo.Migrations.CreateSponsorships do
  use Ecto.Migration

  def change do
    create table(:sponsors) do
      add :name, :string, null: false
      add :contact_name, :string
      add :contact_email, :string
      add :contact_phone, :string
      add :address, :text
      add :industry, :string
      add :website, :string
      add :logo_url, :string
      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    create index(:sponsors, [:name])

    create table(:sponsorships) do
      add :tier, :string, null: false
      add :amount, :integer, null: false
      add :payment_status, :string, null: false, default: "pending"
      add :contract_date, :date
      add :payment_date, :date
      add :notes, :text
      add :festival_id, references(:festivals, on_delete: :delete_all), null: false
      add :sponsor_id, references(:sponsors, on_delete: :restrict), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:sponsorships, [:festival_id])
    create index(:sponsorships, [:sponsor_id])
    create index(:sponsorships, [:tier])
    create index(:sponsorships, [:payment_status])
    create unique_index(:sponsorships, [:festival_id, :sponsor_id])

    create table(:sponsor_benefits) do
      add :name, :string, null: false
      add :description, :text
      add :status, :string, null: false, default: "pending"
      add :completed_at, :utc_datetime
      add :sponsorship_id, references(:sponsorships, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:sponsor_benefits, [:sponsorship_id])
    create index(:sponsor_benefits, [:status])
  end
end
