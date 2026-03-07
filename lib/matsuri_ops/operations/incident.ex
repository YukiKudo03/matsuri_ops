defmodule MatsuriOps.Operations.Incident do
  use Ecto.Schema
  import Ecto.Changeset

  @severities ~w(low medium high critical)
  @statuses ~w(reported acknowledged in_progress resolved closed)
  @categories ~w(medical security lost_item weather equipment other)

  schema "incidents" do
    field :title, :string
    field :description, :string
    field :severity, :string, default: "low"
    field :category, :string
    field :location, :string
    field :status, :string, default: "reported"
    field :resolution, :string
    field :reported_at, :utc_datetime
    field :resolved_at, :utc_datetime

    belongs_to :festival, MatsuriOps.Festivals.Festival
    belongs_to :reported_by, MatsuriOps.Accounts.User
    belongs_to :assigned_to, MatsuriOps.Accounts.User
    belongs_to :resolved_by, MatsuriOps.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def severities, do: @severities
  def statuses, do: @statuses
  def categories, do: @categories

  def changeset(incident, attrs) do
    incident
    |> cast(attrs, [
      :title,
      :description,
      :severity,
      :category,
      :location,
      :status,
      :resolution,
      :reported_at,
      :resolved_at,
      :festival_id,
      :reported_by_id,
      :assigned_to_id,
      :resolved_by_id
    ])
    |> validate_required([:title, :festival_id])
    |> validate_inclusion(:severity, @severities)
    |> validate_inclusion(:status, @statuses)
    |> validate_inclusion(:category, @categories ++ [nil])
    |> foreign_key_constraint(:festival_id)
    |> foreign_key_constraint(:reported_by_id)
    |> foreign_key_constraint(:assigned_to_id)
    |> foreign_key_constraint(:resolved_by_id)
    |> maybe_set_reported_at()
    |> maybe_set_resolved_at()
  end

  defp maybe_set_reported_at(changeset) do
    if get_field(changeset, :reported_at) == nil && get_change(changeset, :id) == nil do
      put_change(changeset, :reported_at, DateTime.utc_now(:second))
    else
      changeset
    end
  end

  defp maybe_set_resolved_at(changeset) do
    status = get_change(changeset, :status)

    cond do
      status in ["resolved", "closed"] && is_nil(get_field(changeset, :resolved_at)) ->
        put_change(changeset, :resolved_at, DateTime.utc_now(:second))

      status not in ["resolved", "closed", nil] ->
        put_change(changeset, :resolved_at, nil)

      true ->
        changeset
    end
  end
end
