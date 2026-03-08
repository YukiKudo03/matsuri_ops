defmodule MatsuriOps.Repo.Migrations.CreateAdBanners do
  use Ecto.Migration

  def change do
    create table(:ad_banners) do
      add :name, :string, null: false
      add :image_url, :string
      add :link_url, :string
      add :position, :string, null: false, default: "sidebar"
      add :display_weight, :integer, default: 10
      add :start_date, :date
      add :end_date, :date
      add :click_count, :integer, default: 0
      add :impression_count, :integer, default: 0
      add :is_active, :boolean, default: true

      add :festival_id, references(:festivals, on_delete: :delete_all), null: false
      add :sponsor_id, references(:sponsors, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:ad_banners, [:festival_id])
    create index(:ad_banners, [:sponsor_id])
    create index(:ad_banners, [:position])
    create index(:ad_banners, [:is_active])
  end
end
