defmodule MatsuriOps.Repo.Migrations.CreateGalleryImages do
  use Ecto.Migration

  def change do
    create table(:gallery_images) do
      add :title, :string
      add :description, :text
      add :image_url, :string, null: false
      add :thumbnail_url, :string
      add :contributor_name, :string
      add :contributor_email, :string
      add :status, :string, null: false, default: "pending"
      add :featured, :boolean, default: false
      add :view_count, :integer, default: 0
      add :like_count, :integer, default: 0

      add :festival_id, references(:festivals, on_delete: :delete_all), null: false
      add :approved_by_id, references(:users, on_delete: :nilify_all)
      add :approved_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:gallery_images, [:festival_id])
    create index(:gallery_images, [:status])
    create index(:gallery_images, [:featured])
    create index(:gallery_images, [:approved_by_id])
  end
end
