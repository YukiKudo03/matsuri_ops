defmodule MatsuriOps.Repo.Migrations.CreateSocialMediaTables do
  use Ecto.Migration

  def change do
    # ソーシャルアカウントテーブル
    create table(:social_accounts) do
      add :platform, :string, null: false
      add :account_name, :string, null: false
      add :account_id, :string
      add :access_token, :text
      add :refresh_token, :text
      add :expires_at, :utc_datetime
      add :is_active, :boolean, default: true

      add :festival_id, references(:festivals, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:social_accounts, [:festival_id])
    create index(:social_accounts, [:platform])
    create unique_index(:social_accounts, [:festival_id, :platform, :account_id])

    # ソーシャル投稿テーブル
    create table(:social_posts) do
      add :content, :text, null: false
      add :platforms, {:array, :string}, null: false, default: []
      add :scheduled_at, :utc_datetime
      add :posted_at, :utc_datetime
      add :status, :string, null: false, default: "draft"
      add :external_ids, :map, default: %{}
      add :media_urls, {:array, :string}, default: []
      add :hashtags, {:array, :string}, default: []
      add :error_message, :text

      # 分析データ
      add :likes_count, :integer, default: 0
      add :shares_count, :integer, default: 0
      add :comments_count, :integer, default: 0
      add :reach_count, :integer, default: 0

      add :festival_id, references(:festivals, on_delete: :delete_all), null: false
      add :created_by_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:social_posts, [:festival_id])
    create index(:social_posts, [:status])
    create index(:social_posts, [:scheduled_at])
    create index(:social_posts, [:created_by_id])
  end
end
