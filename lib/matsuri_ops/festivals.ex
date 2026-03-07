defmodule MatsuriOps.Festivals do
  @moduledoc """
  The Festivals context.
  """

  import Ecto.Query, warn: false
  alias MatsuriOps.Repo
  alias MatsuriOps.Festivals.{Festival, FestivalMember}

  ## Festival

  def list_festivals do
    Repo.all(Festival)
  end

  def list_festivals_by_status(status) do
    Festival
    |> where([f], f.status == ^status)
    |> order_by([f], desc: f.start_date)
    |> Repo.all()
  end

  def get_festival!(id), do: Repo.get!(Festival, id)

  def get_festival(id), do: Repo.get(Festival, id)

  def get_festival_with_members!(id) do
    Festival
    |> Repo.get!(id)
    |> Repo.preload(festival_members: :user)
  end

  def create_festival(attrs \\ %{}) do
    %Festival{}
    |> Festival.changeset(attrs)
    |> Repo.insert()
  end

  def update_festival(%Festival{} = festival, attrs) do
    festival
    |> Festival.changeset(attrs)
    |> Repo.update()
  end

  def delete_festival(%Festival{} = festival) do
    Repo.delete(festival)
  end

  def change_festival(%Festival{} = festival, attrs \\ %{}) do
    Festival.changeset(festival, attrs)
  end

  ## Festival Members

  def list_festival_members(festival_id) do
    FestivalMember
    |> where([fm], fm.festival_id == ^festival_id)
    |> preload(:user)
    |> Repo.all()
  end

  def get_festival_member!(id), do: Repo.get!(FestivalMember, id)

  def get_festival_member(festival_id, user_id) do
    Repo.get_by(FestivalMember, festival_id: festival_id, user_id: user_id)
  end

  def add_member_to_festival(attrs \\ %{}) do
    %FestivalMember{}
    |> FestivalMember.changeset(attrs)
    |> Repo.insert()
  end

  def update_festival_member(%FestivalMember{} = festival_member, attrs) do
    festival_member
    |> FestivalMember.changeset(attrs)
    |> Repo.update()
  end

  def remove_member_from_festival(%FestivalMember{} = festival_member) do
    Repo.delete(festival_member)
  end

  def change_festival_member(%FestivalMember{} = festival_member, attrs \\ %{}) do
    FestivalMember.changeset(festival_member, attrs)
  end

  def member_of_festival?(festival_id, user_id) do
    FestivalMember
    |> where([fm], fm.festival_id == ^festival_id and fm.user_id == ^user_id)
    |> Repo.exists?()
  end
end
