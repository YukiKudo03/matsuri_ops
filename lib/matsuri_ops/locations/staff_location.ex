defmodule MatsuriOps.Locations.StaffLocation do
  @moduledoc """
  スタッフ位置情報スキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "staff_locations" do
    field :latitude, :float
    field :longitude, :float
    field :accuracy, :float
    field :heading, :float
    field :speed, :float

    belongs_to :user, MatsuriOps.Accounts.User
    belongs_to :festival, MatsuriOps.Festivals.Festival

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(staff_location, attrs) do
    staff_location
    |> cast(attrs, [:latitude, :longitude, :accuracy, :heading, :speed, :user_id, :festival_id])
    |> validate_required([:latitude, :longitude, :user_id, :festival_id])
    |> validate_number(:latitude, greater_than_or_equal_to: -90, less_than_or_equal_to: 90)
    |> validate_number(:longitude, greater_than_or_equal_to: -180, less_than_or_equal_to: 180)
    |> unique_constraint([:user_id, :festival_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:festival_id)
  end
end
