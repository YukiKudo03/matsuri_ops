defmodule MatsuriOps.OperationsFixtures do
  @moduledoc """
  Test fixtures for Operations context.
  """

  alias MatsuriOps.Operations

  def valid_incident_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      title: "テストインシデント#{System.unique_integer([:positive])}",
      description: "インシデント説明",
      severity: "low",
      category: "other",
      location: "メインステージ付近",
      status: "reported"
    })
  end

  def incident_fixture(festival, reported_by, attrs \\ %{}) do
    attrs =
      attrs
      |> valid_incident_attributes()
      |> Map.put(:festival_id, festival.id)
      |> Map.put(:reported_by_id, reported_by.id)

    {:ok, incident} = Operations.create_incident(attrs)
    incident
  end

  def valid_area_status_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: "エリア#{System.unique_integer([:positive])}",
      crowd_level: 2,
      notes: "通常状態"
    })
  end

  def area_status_fixture(festival, attrs \\ %{}) do
    attrs =
      attrs
      |> valid_area_status_attributes()
      |> Map.put(:festival_id, festival.id)

    {:ok, area_status} = Operations.create_area_status(attrs)
    area_status
  end

  def area_status_fixture(festival, updated_by, attrs) when is_map(attrs) do
    attrs =
      attrs
      |> valid_area_status_attributes()
      |> Map.put(:festival_id, festival.id)
      |> Map.put(:updated_by_id, updated_by.id)

    {:ok, area_status} = Operations.create_area_status(attrs)
    area_status
  end
end
