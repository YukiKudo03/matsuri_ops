defmodule MatsuriOps.Tasks.ChecklistItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "checklist_items" do
    field :content, :string
    field :is_completed, :boolean, default: false
    field :completed_at, :utc_datetime
    field :sort_order, :integer, default: 0

    belongs_to :task, MatsuriOps.Tasks.Task
    belongs_to :completed_by, MatsuriOps.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(checklist_item, attrs) do
    checklist_item
    |> cast(attrs, [:content, :is_completed, :completed_at, :sort_order, :task_id, :completed_by_id])
    |> validate_required([:content, :task_id])
    |> foreign_key_constraint(:task_id)
    |> foreign_key_constraint(:completed_by_id)
    |> maybe_set_completed_at()
  end

  defp maybe_set_completed_at(changeset) do
    is_completed = get_change(changeset, :is_completed)
    completed_at = get_field(changeset, :completed_at)

    cond do
      is_completed == true && is_nil(completed_at) ->
        put_change(changeset, :completed_at, DateTime.utc_now(:second))

      is_completed == false ->
        put_change(changeset, :completed_at, nil)
        |> put_change(:completed_by_id, nil)

      true ->
        changeset
    end
  end
end
