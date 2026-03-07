defmodule MatsuriOps.Repo.Migrations.CreateBudgetsAndExpenses do
  use Ecto.Migration

  def change do
    # 予算カテゴリ
    create table(:budget_categories) do
      add :name, :string, null: false
      add :description, :text
      add :budget_amount, :decimal, null: false, default: 0
      add :sort_order, :integer, default: 0
      add :festival_id, references(:festivals, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:budget_categories, [:festival_id])

    # 経費（支出）
    create table(:expenses) do
      add :title, :string, null: false
      add :description, :text
      add :amount, :decimal, null: false
      add :quantity, :integer, default: 1
      add :unit_price, :decimal
      add :expense_date, :date
      add :payment_method, :string
      add :receipt_number, :string
      add :receipt_url, :string
      add :status, :string, default: "pending"
      add :notes, :text

      add :festival_id, references(:festivals, on_delete: :delete_all), null: false
      add :category_id, references(:budget_categories, on_delete: :nilify_all)
      add :submitted_by_id, references(:users, on_delete: :nilify_all)
      add :approved_by_id, references(:users, on_delete: :nilify_all)
      add :approved_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:expenses, [:festival_id])
    create index(:expenses, [:category_id])
    create index(:expenses, [:status])
    create index(:expenses, [:submitted_by_id])

    # 収入
    create table(:incomes) do
      add :title, :string, null: false
      add :description, :text
      add :amount, :decimal, null: false
      add :source_type, :string
      add :received_date, :date
      add :receipt_number, :string
      add :status, :string, default: "expected"
      add :notes, :text

      add :festival_id, references(:festivals, on_delete: :delete_all), null: false
      add :recorded_by_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:incomes, [:festival_id])
    create index(:incomes, [:status])
  end
end
