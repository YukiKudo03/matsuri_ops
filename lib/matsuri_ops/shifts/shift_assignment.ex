defmodule MatsuriOps.Shifts.ShiftAssignment do
  @moduledoc """
  シフト割り当てスキーマ。

  スタッフとシフトの関連を管理する。
  """

  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(assigned confirmed declined)

  schema "shift_assignments" do
    field :status, :string, default: "assigned"
    field :notes, :string

    belongs_to :shift, MatsuriOps.Shifts.Shift
    belongs_to :user, MatsuriOps.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(assignment, attrs) do
    assignment
    |> cast(attrs, [:status, :notes, :shift_id, :user_id])
    |> validate_required([:shift_id, :user_id])
    |> validate_inclusion(:status, @statuses)
    |> foreign_key_constraint(:shift_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint([:shift_id, :user_id])
  end

  def statuses, do: @statuses
end
