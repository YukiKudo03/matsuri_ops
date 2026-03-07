defmodule MatsuriOps.Festivals.FestivalMember do
  use Ecto.Schema
  import Ecto.Changeset

  schema "festival_members" do
    field :role, :string
    field :assigned_area, :string
    field :notes, :string

    belongs_to :festival, MatsuriOps.Festivals.Festival
    belongs_to :user, MatsuriOps.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(festival_member, attrs) do
    festival_member
    |> cast(attrs, [:role, :assigned_area, :notes, :festival_id, :user_id])
    |> validate_required([:role, :festival_id, :user_id])
    |> unique_constraint([:festival_id, :user_id])
    |> foreign_key_constraint(:festival_id)
    |> foreign_key_constraint(:user_id)
  end
end
