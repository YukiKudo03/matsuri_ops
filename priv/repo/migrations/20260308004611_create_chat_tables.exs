defmodule MatsuriOps.Repo.Migrations.CreateChatTables do
  use Ecto.Migration

  def change do
    create table(:chat_rooms) do
      add :name, :string, null: false
      add :room_type, :string, null: false, default: "general"
      add :description, :text
      add :festival_id, references(:festivals, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:chat_rooms, [:festival_id])
    create index(:chat_rooms, [:room_type])

    create table(:messages) do
      add :content, :text, null: false
      add :message_type, :string, default: "text"
      add :chat_room_id, references(:chat_rooms, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :nilify_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:chat_room_id])
    create index(:messages, [:user_id])
    create index(:messages, [:inserted_at])

    create table(:read_statuses) do
      add :read_at, :utc_datetime, null: false
      add :message_id, references(:messages, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:read_statuses, [:message_id, :user_id])
    create index(:read_statuses, [:user_id])
  end
end
