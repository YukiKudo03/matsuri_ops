defmodule MatsuriOps.AdvertisingFixtures do
  @moduledoc """
  Test fixtures for Advertising context.
  """

  alias MatsuriOps.Advertising

  def valid_ad_banner_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: "テスト広告#{System.unique_integer([:positive])}",
      image_url: "https://example.com/ad#{System.unique_integer([:positive])}.jpg",
      link_url: "https://example.com/sponsor",
      position: "sidebar",
      display_weight: 1,
      start_date: Date.utc_today(),
      end_date: Date.utc_today() |> Date.add(30),
      is_active: true
    })
  end

  def ad_banner_fixture(festival, attrs \\ %{}) do
    attrs =
      attrs
      |> valid_ad_banner_attributes()
      |> Map.put(:festival_id, festival.id)

    {:ok, ad_banner} = Advertising.create_ad_banner(attrs)
    ad_banner
  end

  def valid_sponsor_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: "テストスポンサー#{System.unique_integer([:positive])}"
    })
  end

  def sponsor_fixture(attrs \\ %{}) do
    attrs = valid_sponsor_attributes(attrs)

    {:ok, sponsor} = MatsuriOps.Sponsorships.create_sponsor(attrs)
    sponsor
  end
end
