defmodule MatsuriOps.SocialMediaFixtures do
  @moduledoc """
  Test fixtures for SocialMedia context.
  """

  alias MatsuriOps.SocialMedia

  def valid_social_account_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      platform: "twitter",
      account_name: "test_account#{System.unique_integer([:positive])}"
    })
  end

  def social_account_fixture(festival, attrs \\ %{}) do
    attrs =
      attrs
      |> valid_social_account_attributes()
      |> Map.put(:festival_id, festival.id)

    {:ok, social_account} = SocialMedia.create_social_account(attrs)
    social_account
  end

  def valid_social_post_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      content: "テスト投稿#{System.unique_integer([:positive])}",
      platforms: ["twitter"]
    })
  end

  def social_post_fixture(festival, user, attrs \\ %{}) do
    attrs =
      attrs
      |> valid_social_post_attributes()
      |> Map.put(:festival_id, festival.id)
      |> Map.put(:created_by_id, user.id)

    {:ok, social_post} = SocialMedia.create_social_post(attrs)
    social_post
  end
end
