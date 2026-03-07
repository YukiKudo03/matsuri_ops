defmodule MatsuriOps.Operations do
  @moduledoc """
  The Operations context for day-of festival operations.
  """

  import Ecto.Query, warn: false
  alias MatsuriOps.Repo
  alias MatsuriOps.Operations.{Incident, AreaStatus}

  ## Incidents

  def list_incidents(festival_id) do
    Incident
    |> where([i], i.festival_id == ^festival_id)
    |> order_by([i], desc: i.reported_at)
    |> preload([:reported_by, :assigned_to])
    |> Repo.all()
  end

  def list_active_incidents(festival_id) do
    Incident
    |> where([i], i.festival_id == ^festival_id and i.status not in ["resolved", "closed"])
    |> order_by([i], [desc: i.severity, desc: i.reported_at])
    |> preload([:reported_by, :assigned_to])
    |> Repo.all()
  end

  def get_incident!(id), do: Repo.get!(Incident, id) |> Repo.preload([:reported_by, :assigned_to, :resolved_by])

  def create_incident(attrs \\ %{}) do
    %Incident{}
    |> Incident.changeset(attrs)
    |> Repo.insert()
    |> broadcast_incident_change(:incident_created)
  end

  def update_incident(%Incident{} = incident, attrs) do
    incident
    |> Incident.changeset(attrs)
    |> Repo.update()
    |> broadcast_incident_change(:incident_updated)
  end

  def delete_incident(%Incident{} = incident) do
    Repo.delete(incident)
  end

  def change_incident(%Incident{} = incident, attrs \\ %{}) do
    Incident.changeset(incident, attrs)
  end

  def incident_stats(festival_id) do
    stats =
      Incident
      |> where([i], i.festival_id == ^festival_id)
      |> group_by([i], i.status)
      |> select([i], {i.status, count(i.id)})
      |> Repo.all()
      |> Map.new()

    severity_stats =
      Incident
      |> where([i], i.festival_id == ^festival_id and i.status not in ["resolved", "closed"])
      |> group_by([i], i.severity)
      |> select([i], {i.severity, count(i.id)})
      |> Repo.all()
      |> Map.new()

    %{
      total: Enum.reduce(stats, 0, fn {_k, v}, acc -> acc + v end),
      by_status: stats,
      active_by_severity: severity_stats
    }
  end

  ## Area Status

  def list_area_status(festival_id) do
    AreaStatus
    |> where([a], a.festival_id == ^festival_id)
    |> order_by([a], asc: a.name)
    |> Repo.all()
  end

  def get_area_status!(id), do: Repo.get!(AreaStatus, id)

  def get_area_status_by_name(festival_id, name) do
    Repo.get_by(AreaStatus, festival_id: festival_id, name: name)
  end

  def create_area_status(attrs \\ %{}) do
    %AreaStatus{}
    |> AreaStatus.changeset(attrs)
    |> Repo.insert()
    |> broadcast_area_change(:area_updated)
  end

  def update_area_status(%AreaStatus{} = area_status, attrs) do
    area_status
    |> AreaStatus.changeset(attrs)
    |> Repo.update()
    |> broadcast_area_change(:area_updated)
  end

  def delete_area_status(%AreaStatus{} = area_status) do
    Repo.delete(area_status)
  end

  def change_area_status(%AreaStatus{} = area_status, attrs \\ %{}) do
    AreaStatus.changeset(area_status, attrs)
  end

  ## PubSub

  @topic "operations"

  def subscribe(festival_id) do
    Phoenix.PubSub.subscribe(MatsuriOps.PubSub, "#{@topic}:#{festival_id}")
  end

  defp broadcast_incident_change({:ok, incident} = result, event) do
    Phoenix.PubSub.broadcast(
      MatsuriOps.PubSub,
      "#{@topic}:#{incident.festival_id}",
      {event, incident}
    )
    result
  end

  defp broadcast_incident_change(result, _event), do: result

  defp broadcast_area_change({:ok, area} = result, event) do
    Phoenix.PubSub.broadcast(
      MatsuriOps.PubSub,
      "#{@topic}:#{area.festival_id}",
      {event, area}
    )
    result
  end

  defp broadcast_area_change(result, _event), do: result
end
