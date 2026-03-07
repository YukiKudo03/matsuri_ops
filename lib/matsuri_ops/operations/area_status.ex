defmodule MatsuriOps.Operations.AreaStatus do
  use Ecto.Schema
  import Ecto.Changeset

  schema "area_status" do
    field :name, :string
    field :crowd_level, :integer, default: 0
    field :weather_temp, :decimal
    field :weather_wbgt, :decimal
    field :notes, :string

    belongs_to :festival, MatsuriOps.Festivals.Festival
    belongs_to :updated_by, MatsuriOps.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(area_status, attrs) do
    area_status
    |> cast(attrs, [:name, :crowd_level, :weather_temp, :weather_wbgt, :notes, :festival_id, :updated_by_id])
    |> validate_required([:name, :festival_id])
    |> validate_number(:crowd_level, greater_than_or_equal_to: 0, less_than_or_equal_to: 5)
    |> unique_constraint([:festival_id, :name])
    |> foreign_key_constraint(:festival_id)
    |> foreign_key_constraint(:updated_by_id)
  end

  def crowd_level_label(level) do
    case level do
      0 -> "閑散"
      1 -> "やや空き"
      2 -> "通常"
      3 -> "やや混雑"
      4 -> "混雑"
      5 -> "非常に混雑"
      _ -> "不明"
    end
  end

  def crowd_level_color(level) do
    case level do
      0 -> "bg-green-100"
      1 -> "bg-green-200"
      2 -> "bg-yellow-100"
      3 -> "bg-yellow-300"
      4 -> "bg-orange-300"
      5 -> "bg-red-400"
      _ -> "bg-gray-100"
    end
  end
end
