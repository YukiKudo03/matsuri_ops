defmodule MatsuriOps.Tasks.TaskDependency do
  use Ecto.Schema
  import Ecto.Changeset

  @dependency_types ~w(finish_to_start start_to_start finish_to_finish start_to_finish)

  schema "task_dependencies" do
    field :dependency_type, :string, default: "finish_to_start"

    belongs_to :predecessor, MatsuriOps.Tasks.Task
    belongs_to :successor, MatsuriOps.Tasks.Task

    timestamps(type: :utc_datetime)
  end

  def dependency_types, do: @dependency_types

  def changeset(task_dependency, attrs) do
    task_dependency
    |> cast(attrs, [:dependency_type, :predecessor_id, :successor_id])
    |> validate_required([:predecessor_id, :successor_id])
    |> validate_inclusion(:dependency_type, @dependency_types)
    |> unique_constraint([:predecessor_id, :successor_id])
    |> foreign_key_constraint(:predecessor_id)
    |> foreign_key_constraint(:successor_id)
    |> validate_not_self_referential()
  end

  defp validate_not_self_referential(changeset) do
    predecessor_id = get_field(changeset, :predecessor_id)
    successor_id = get_field(changeset, :successor_id)

    if predecessor_id && successor_id && predecessor_id == successor_id do
      add_error(changeset, :successor_id, "cannot depend on itself")
    else
      changeset
    end
  end
end
