defmodule MatsuriOps.Festivals.Festival do
  use Ecto.Schema
  import Ecto.Changeset

  @scales ~w(small medium large)
  @statuses ~w(planning preparation active completed cancelled)

  schema "festivals" do
    field :name, :string
    field :description, :string
    field :scale, :string, default: "medium"
    field :start_date, :date
    field :end_date, :date
    field :venue_name, :string
    field :venue_address, :string
    field :expected_visitors, :integer
    field :expected_vendors, :integer
    field :status, :string, default: "planning"

    belongs_to :organizer, MatsuriOps.Accounts.User
    has_many :festival_members, MatsuriOps.Festivals.FestivalMember
    has_many :members, through: [:festival_members, :user]
    has_many :tasks, MatsuriOps.Tasks.Task
    has_many :task_categories, MatsuriOps.Tasks.TaskCategory
    has_many :budget_categories, MatsuriOps.Budgets.BudgetCategory
    has_many :expenses, MatsuriOps.Budgets.Expense
    has_many :incomes, MatsuriOps.Budgets.Income

    timestamps(type: :utc_datetime)
  end

  def scales, do: @scales
  def statuses, do: @statuses

  def changeset(festival, attrs) do
    festival
    |> cast(attrs, [
      :name,
      :description,
      :scale,
      :start_date,
      :end_date,
      :venue_name,
      :venue_address,
      :expected_visitors,
      :expected_vendors,
      :status,
      :organizer_id
    ])
    |> validate_required([:name, :start_date, :end_date])
    |> validate_inclusion(:scale, @scales)
    |> validate_inclusion(:status, @statuses)
    |> validate_dates()
  end

  defp validate_dates(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    if start_date && end_date && Date.compare(start_date, end_date) == :gt do
      add_error(changeset, :end_date, "must be after start date")
    else
      changeset
    end
  end
end
