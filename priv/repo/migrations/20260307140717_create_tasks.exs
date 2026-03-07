defmodule MatsuriOps.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    # タスクカテゴリ（11大タスク）
    create table(:task_categories) do
      add :name, :string, null: false
      add :description, :text
      add :sort_order, :integer, default: 0
      add :festival_id, references(:festivals, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:task_categories, [:festival_id])

    # タスク（WBS構造）
    create table(:tasks) do
      add :title, :string, null: false
      add :description, :text
      add :status, :string, default: "pending"
      add :priority, :string, default: "medium"
      add :due_date, :date
      add :start_date, :date
      add :estimated_hours, :decimal
      add :actual_hours, :decimal
      add :progress_percent, :integer, default: 0
      add :is_milestone, :boolean, default: false
      add :sort_order, :integer, default: 0

      add :festival_id, references(:festivals, on_delete: :delete_all), null: false
      add :category_id, references(:task_categories, on_delete: :nilify_all)
      add :parent_id, references(:tasks, on_delete: :nilify_all)
      add :assignee_id, references(:users, on_delete: :nilify_all)
      add :created_by_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:tasks, [:festival_id])
    create index(:tasks, [:category_id])
    create index(:tasks, [:parent_id])
    create index(:tasks, [:assignee_id])
    create index(:tasks, [:status])
    create index(:tasks, [:due_date])

    # タスク依存関係（ガントチャート用）
    create table(:task_dependencies) do
      add :predecessor_id, references(:tasks, on_delete: :delete_all), null: false
      add :successor_id, references(:tasks, on_delete: :delete_all), null: false
      add :dependency_type, :string, default: "finish_to_start"

      timestamps(type: :utc_datetime)
    end

    create unique_index(:task_dependencies, [:predecessor_id, :successor_id])

    # チェックリスト項目
    create table(:checklist_items) do
      add :content, :string, null: false
      add :is_completed, :boolean, default: false
      add :completed_at, :utc_datetime
      add :sort_order, :integer, default: 0
      add :task_id, references(:tasks, on_delete: :delete_all), null: false
      add :completed_by_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:checklist_items, [:task_id])
  end
end
