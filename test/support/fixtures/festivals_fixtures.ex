defmodule MatsuriOps.FestivalsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MatsuriOps.Festivals` context.
  """

  alias MatsuriOps.Festivals

  def valid_festival_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: "テスト祭り#{System.unique_integer()}",
      description: "テスト用の祭りです",
      start_date: Date.utc_today(),
      end_date: Date.add(Date.utc_today(), 1),
      venue_name: "テスト会場",
      venue_address: "東京都渋谷区",
      scale: "medium",
      status: "planning",
      expected_visitors: 1000,
      expected_vendors: 50
    })
  end

  def festival_fixture(user, attrs \\ %{}) do
    attrs = valid_festival_attributes(attrs)

    {:ok, festival} = Festivals.create_festival(user, attrs)
    festival
  end

  def festival_member_fixture(festival, user, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        festival_id: festival.id,
        user_id: user.id,
        role: "staff"
      })

    {:ok, member} = Festivals.add_member_to_festival(attrs)
    member
  end
end
