defmodule MatsuriOps.ShiftsFixtures do
  @moduledoc """
  Test fixtures for Shifts context.
  """

  alias MatsuriOps.Shifts

  def valid_shift_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: "テストシフト#{System.unique_integer([:positive])}",
      start_time: DateTime.utc_now() |> DateTime.truncate(:second),
      end_time: DateTime.utc_now() |> DateTime.add(3600) |> DateTime.truncate(:second)
    })
  end

  def shift_fixture(festival, attrs \\ %{}) do
    attrs =
      attrs
      |> valid_shift_attributes()
      |> Map.put(:festival_id, festival.id)

    {:ok, shift} = Shifts.create_shift(attrs)
    shift
  end
end
