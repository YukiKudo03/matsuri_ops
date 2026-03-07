defmodule MatsuriOps.Budgets.Income do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(expected confirmed received cancelled)
  @source_types ~w(sponsorship grant ticket_sales vendor_fees donation other)

  schema "incomes" do
    field :title, :string
    field :description, :string
    field :amount, :decimal
    field :source_type, :string
    field :received_date, :date
    field :receipt_number, :string
    field :status, :string, default: "expected"
    field :notes, :string

    belongs_to :festival, MatsuriOps.Festivals.Festival
    belongs_to :recorded_by, MatsuriOps.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def statuses, do: @statuses
  def source_types, do: @source_types

  def changeset(income, attrs) do
    income
    |> cast(attrs, [
      :title,
      :description,
      :amount,
      :source_type,
      :received_date,
      :receipt_number,
      :status,
      :notes,
      :festival_id,
      :recorded_by_id
    ])
    |> validate_required([:title, :amount, :festival_id])
    |> validate_inclusion(:status, @statuses)
    |> validate_inclusion(:source_type, @source_types ++ [nil])
    |> validate_number(:amount, greater_than: 0)
    |> foreign_key_constraint(:festival_id)
    |> foreign_key_constraint(:recorded_by_id)
  end
end
