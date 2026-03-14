defmodule MatsuriOps.GalleryFixtures do
  @moduledoc """
  Test fixtures for Gallery context.
  """

  alias MatsuriOps.Gallery

  def valid_gallery_image_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      image_url: "https://example.com/img#{System.unique_integer([:positive])}.jpg",
      title: "テスト画像#{System.unique_integer([:positive])}",
      description: "テスト画像の説明",
      thumbnail_url: "https://example.com/thumb#{System.unique_integer([:positive])}.jpg",
      contributor_name: "テスト投稿者",
      contributor_email: "test@example.com",
      status: "pending",
      featured: false
    })
  end

  def gallery_image_fixture(festival, attrs \\ %{}) do
    attrs =
      attrs
      |> valid_gallery_image_attributes()
      |> Map.put(:festival_id, festival.id)

    {:ok, gallery_image} = Gallery.create_gallery_image(attrs)
    gallery_image
  end
end
