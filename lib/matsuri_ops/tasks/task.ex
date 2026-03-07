defmodule MatsuriOps.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(pending in_progress completed cancelled blocked)
  @priorities ~w(low medium high urgent)

  schema "tasks" do
    field :title, :string
    field :description, :string
    field :status, :string, default: "pending"
    field :priority, :string, default: "medium"
    field :due_date, :date
    field :start_date, :date
    field :estimated_hours, :decimal
    field :actual_hours, :decimal
    field :progress_percent, :integer, default: 0
    field :is_milestone, :boolean, default: false
    field :sort_order, :integer, default: 0

    belongs_to :festival, MatsuriOps.Festivals.Festival
    belongs_to :category, MatsuriOps.Tasks.TaskCategory
    belongs_to :parent, MatsuriOps.Tasks.Task
    belongs_to :assignee, MatsuriOps.Accounts.User
    belongs_to :created_by, MatsuriOps.Accounts.User

    has_many :children, MatsuriOps.Tasks.Task, foreign_key: :parent_id
    has_many :checklist_items, MatsuriOps.Tasks.ChecklistItem

    timestamps(type: :utc_datetime)
  end

  def statuses, do: @statuses
  def priorities, do: @priorities

  def changeset(task, attrs) do
    task
    |> cast(attrs, [
      :title,
      :description,
      :status,
      :priority,
      :due_date,
      :start_date,
      :estimated_hours,
      :actual_hours,
      :progress_percent,
      :is_milestone,
      :sort_order,
      :festival_id,
      :category_id,
      :parent_id,
      :assignee_id,
      :created_by_id
    ])
    |> validate_required([:title, :festival_id])
    |> validate_inclusion(:status, @statuses)
    |> validate_inclusion(:priority, @priorities)
    |> validate_number(:progress_percent, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
    |> foreign_key_constraint(:festival_id)
    |> foreign_key_constraint(:category_id)
    |> foreign_key_constraint(:parent_id)
    |> foreign_key_constraint(:assignee_id)
    |> foreign_key_constraint(:created_by_id)
  end
end
