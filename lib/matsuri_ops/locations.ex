defmodule MatsuriOps.Locations do
  @moduledoc """
  スタッフ位置管理機能を提供するコンテキスト。

  位置情報の更新、一覧取得、リアルタイム通知を行う。
  """

  import Ecto.Query
  alias MatsuriOps.Repo
  alias MatsuriOps.Locations.StaffLocation

  @pubsub MatsuriOps.PubSub

  @doc """
  スタッフの位置を更新する（upsert）。
  """
  def update_staff_location(attrs) do
    result =
      %StaffLocation{}
      |> StaffLocation.changeset(attrs)
      |> Repo.insert(
        on_conflict: {:replace, [:latitude, :longitude, :accuracy, :heading, :speed, :updated_at]},
        conflict_target: [:user_id, :festival_id],
        returning: true
      )

    case result do
      {:ok, location} ->
        location = Repo.preload(location, :user)
        broadcast_location(location)
        {:ok, location}

      error ->
        error
    end
  end

  @doc """
  祭りのスタッフ位置一覧を取得する。

  ## Options
  - `:within_minutes` - 指定分数以内に更新された位置のみ取得
  """
  def list_staff_locations(festival_id, opts \\ []) do
    within_minutes = Keyword.get(opts, :within_minutes)

    query =
      StaffLocation
      |> where([l], l.festival_id == ^festival_id)
      |> preload(:user)
      |> order_by([l], desc: l.updated_at)

    query =
      if within_minutes do
        cutoff = DateTime.add(DateTime.utc_now(), -within_minutes * 60, :second)
        where(query, [l], l.updated_at >= ^cutoff)
      else
        query
      end

    Repo.all(query)
  end

  @doc """
  特定ユーザーの位置を取得する。
  """
  def get_staff_location(festival_id, user_id) do
    StaffLocation
    |> where([l], l.festival_id == ^festival_id and l.user_id == ^user_id)
    |> preload(:user)
    |> Repo.one()
  end

  @doc """
  位置情報を削除する。
  """
  def delete_staff_location(%StaffLocation{} = location) do
    Repo.delete(location)
  end

  ## PubSub

  def subscribe(festival_id) do
    Phoenix.PubSub.subscribe(@pubsub, topic(festival_id))
  end

  def unsubscribe(festival_id) do
    Phoenix.PubSub.unsubscribe(@pubsub, topic(festival_id))
  end

  defp broadcast_location(location) do
    Phoenix.PubSub.broadcast(@pubsub, topic(location.festival_id), {:location_updated, location})
  end

  defp topic(festival_id), do: "locations:#{festival_id}"
end
