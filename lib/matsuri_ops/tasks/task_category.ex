defmodule MatsuriOps.Tasks.TaskCategory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "task_categories" do
    field :name, :string
    field :description, :string
    field :sort_order, :integer, default: 0

    belongs_to :festival, MatsuriOps.Festivals.Festival
    has_many :tasks, MatsuriOps.Tasks.Task, foreign_key: :category_id

    timestamps(type: :utc_datetime)
  end

  def changeset(task_category, attrs) do
    task_category
    |> cast(attrs, [:name, :description, :sort_order, :festival_id])
    |> validate_required([:name, :festival_id])
    |> foreign_key_constraint(:festival_id)
  end
end
