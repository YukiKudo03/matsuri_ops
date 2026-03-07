defmodule MatsuriOps.Budgets.BudgetCategory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "budget_categories" do
    field :name, :string
    field :description, :string
    field :budget_amount, :decimal, default: Decimal.new(0)
    field :sort_order, :integer, default: 0

    belongs_to :festival, MatsuriOps.Festivals.Festival
    has_many :expenses, MatsuriOps.Budgets.Expense, foreign_key: :category_id

    timestamps(type: :utc_datetime)
  end

  def changeset(budget_category, attrs) do
    budget_category
    |> cast(attrs, [:name, :description, :budget_amount, :sort_order, :festival_id])
    |> validate_required([:name, :festival_id])
    |> validate_number(:budget_amount, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:festival_id)
  end
end
