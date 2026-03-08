defmodule MatsuriOps.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:announcements) do
      add :title, :string, null: false
      add :content, :text, null: false
      add :priority, :string, default: "normal"
      add :target_audience, :string, default: "all"
      add :expires_at, :utc_datetime
      add :festival_id, references(:festivals, on_delete: :delete_all), null: false
      add :created_by_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:announcements, [:festival_id])
    create index(:announcements, [:priority])
    create index(:announcements, [:expires_at])

    create table(:push_subscriptions) do
      add :endpoint, :string, null: false
      add :p256dh_key, :string, null: false
      add :auth_key, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:push_subscriptions, [:user_id])
    create unique_index(:push_subscriptions, [:endpoint])
  end
end
