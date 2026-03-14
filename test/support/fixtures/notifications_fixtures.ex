defmodule MatsuriOps.NotificationsFixtures do
  @moduledoc """
  Test fixtures for Notifications context.
  """

  alias MatsuriOps.Notifications

  def valid_announcement_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      title: "テストお知らせ#{System.unique_integer([:positive])}",
      content: "テストお知らせの内容",
      priority: "normal",
      target_audience: "all"
    })
  end

  def announcement_fixture(festival, user, attrs \\ %{}) do
    attrs =
      attrs
      |> valid_announcement_attributes()
      |> Map.put(:festival_id, festival.id)
      |> Map.put(:created_by_id, user.id)

    {:ok, announcement} = Notifications.create_announcement(attrs)
    announcement
  end
end
