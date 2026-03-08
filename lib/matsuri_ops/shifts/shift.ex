defmodule MatsuriOps.Shifts.Shift do
  @moduledoc """
  シフトスキーマ。

  祭りのスタッフシフトを管理する。
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "shifts" do
    field :name, :string
    field :start_time, :utc_datetime
    field :end_time, :utc_datetime
    field :location, :string
    field :required_staff, :integer, default: 1
    field :description, :string

    belongs_to :festival, MatsuriOps.Festivals.Festival
    has_many :assignments, MatsuriOps.Shifts.ShiftAssignment

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(shift, attrs) do
    shift
    |> cast(attrs, [:name, :start_time, :end_time, :location, :required_staff, :description, :festival_id])
    |> validate_required([:name, :start_time, :end_time, :festival_id])
    |> validate_number(:required_staff, greater_than: 0)
    |> validate_time_range()
    |> foreign_key_constraint(:festival_id)
  end

  defp validate_time_range(changeset) do
    start_time = get_field(changeset, :start_time)
    end_time = get_field(changeset, :end_time)

    if start_time && end_time && DateTime.compare(end_time, start_time) != :gt do
      add_error(changeset, :end_time, "は開始時間より後である必要があります")
    else
      changeset
    end
  end
end
