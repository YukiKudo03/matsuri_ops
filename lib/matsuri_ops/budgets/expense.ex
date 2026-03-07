defmodule MatsuriOps.Budgets.Expense do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(pending submitted approved rejected paid)
  @payment_methods ~w(cash bank_transfer credit_card other)

  schema "expenses" do
    field :title, :string
    field :description, :string
    field :amount, :decimal
    field :quantity, :integer, default: 1
    field :unit_price, :decimal
    field :expense_date, :date
    field :payment_method, :string
    field :receipt_number, :string
    field :receipt_url, :string
    field :status, :string, default: "pending"
    field :notes, :string
    field :approved_at, :utc_datetime

    belongs_to :festival, MatsuriOps.Festivals.Festival
    belongs_to :category, MatsuriOps.Budgets.BudgetCategory
    belongs_to :submitted_by, MatsuriOps.Accounts.User
    belongs_to :approved_by, MatsuriOps.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def statuses, do: @statuses
  def payment_methods, do: @payment_methods

  def changeset(expense, attrs) do
    expense
    |> cast(attrs, [
      :title,
      :description,
      :amount,
      :quantity,
      :unit_price,
      :expense_date,
      :payment_method,
      :receipt_number,
      :receipt_url,
      :status,
      :notes,
      :festival_id,
      :category_id,
      :submitted_by_id
    ])
    |> validate_required([:title, :amount, :festival_id])
    |> validate_inclusion(:status, @statuses)
    |> validate_inclusion(:payment_method, @payment_methods ++ [nil])
    |> validate_number(:amount, greater_than: 0)
    |> validate_number(:quantity, greater_than: 0)
    |> foreign_key_constraint(:festival_id)
    |> foreign_key_constraint(:category_id)
    |> foreign_key_constraint(:submitted_by_id)
    |> calculate_amount()
  end

  def approval_changeset(expense, attrs) do
    expense
    |> cast(attrs, [:status, :approved_by_id, :approved_at])
    |> validate_inclusion(:status, @statuses)
    |> maybe_set_approved_at()
  end

  defp calculate_amount(changeset) do
    quantity = get_field(changeset, :quantity)
    unit_price = get_field(changeset, :unit_price)

    if quantity && unit_price && is_nil(get_change(changeset, :amount)) do
      amount = Decimal.mult(Decimal.new(quantity), unit_price)
      put_change(changeset, :amount, amount)
    else
      changeset
    end
  end

  defp maybe_set_approved_at(changeset) do
    status = get_change(changeset, :status)

    if status in ["approved", "rejected"] && is_nil(get_field(changeset, :approved_at)) do
      put_change(changeset, :approved_at, DateTime.utc_now(:second))
    else
      changeset
    end
  end
end
