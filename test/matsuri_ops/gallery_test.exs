defmodule MatsuriOps.GalleryTest do
  use MatsuriOps.DataCase, async: true

  alias MatsuriOps.Gallery
  alias MatsuriOps.Gallery.GalleryImage

  describe "gallery_images" do
    setup do
      festival = festival_fixture()
      user = user_fixture()
      %{festival: festival, user: user}
    end

    @valid_attrs %{
      title: "テスト画像",
      description: "テスト説明",
      image_url: "https://example.com/image.jpg",
      contributor_name: "山田太郎",
      contributor_email: "test@example.com"
    }
    @update_attrs %{
      title: "更新された画像",
      description: "更新された説明"
    }
    @invalid_attrs %{image_url: nil}

    def gallery_image_fixture(festival, attrs \\ %{}) do
      {:ok, gallery_image} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put(:festival_id, festival.id)
        |> Gallery.create_gallery_image()

      gallery_image
    end

    test "list_gallery_images/1 returns all gallery_images for a festival", %{festival: festival} do
      gallery_image = gallery_image_fixture(festival)
      images = Gallery.list_gallery_images(festival.id)
      assert length(images) == 1
      assert hd(images).id == gallery_image.id
    end

    test "list_approved_images/1 returns only approved images", %{festival: festival, user: user} do
      pending = gallery_image_fixture(festival)
      approved = gallery_image_fixture(festival, %{title: "承認済み"})
      {:ok, _} = Gallery.approve_image(approved, user.id)

      approved_images = Gallery.list_approved_images(festival.id)
      assert length(approved_images) == 1
      assert hd(approved_images).title == "承認済み"

      refute Enum.any?(approved_images, &(&1.id == pending.id))
    end

    test "list_pending_images/1 returns only pending images", %{festival: festival} do
      _pending = gallery_image_fixture(festival)
      _other = gallery_image_fixture(festival, %{title: "別の画像"})

      pending_images = Gallery.list_pending_images(festival.id)
      assert length(pending_images) == 2
      assert Enum.all?(pending_images, &(&1.status == "pending"))
    end

    test "list_featured_images/1 returns featured approved images", %{festival: festival, user: user} do
      image = gallery_image_fixture(festival)
      {:ok, approved} = Gallery.approve_image(image, user.id)
      {:ok, _featured} = Gallery.toggle_featured(approved)

      featured = Gallery.list_featured_images(festival.id)
      assert length(featured) == 1
    end

    test "list_images_by_status/2 returns images filtered by status", %{festival: festival, user: user} do
      _pending = gallery_image_fixture(festival)
      approved_img = gallery_image_fixture(festival, %{title: "承認画像"})
      {:ok, _} = Gallery.approve_image(approved_img, user.id)

      pending_images = Gallery.list_images_by_status(festival.id, "pending")
      assert length(pending_images) == 1
      assert hd(pending_images).status == "pending"

      approved_images = Gallery.list_images_by_status(festival.id, "approved")
      assert length(approved_images) == 1
      assert hd(approved_images).status == "approved"

      rejected_images = Gallery.list_images_by_status(festival.id, "rejected")
      assert Enum.empty?(rejected_images)
    end

    test "get_gallery_image!/1 returns the gallery_image with given id", %{festival: festival} do
      gallery_image = gallery_image_fixture(festival)
      found = Gallery.get_gallery_image!(gallery_image.id)
      assert found.id == gallery_image.id
    end

    test "get_gallery_image!/1 raises for non-existent id", %{festival: _festival} do
      assert_raise Ecto.NoResultsError, fn ->
        Gallery.get_gallery_image!(999_999)
      end
    end

    test "get_gallery_image/1 returns the gallery_image with given id", %{festival: festival} do
      gallery_image = gallery_image_fixture(festival)
      found = Gallery.get_gallery_image(gallery_image.id)
      assert found.id == gallery_image.id
    end

    test "get_gallery_image/1 returns nil for non-existent id", %{festival: _festival} do
      assert Gallery.get_gallery_image(999_999) == nil
    end

    test "create_gallery_image/1 with valid data creates a gallery_image", %{festival: festival} do
      attrs = Map.put(@valid_attrs, :festival_id, festival.id)
      assert {:ok, %GalleryImage{} = gallery_image} = Gallery.create_gallery_image(attrs)
      assert gallery_image.title == "テスト画像"
      assert gallery_image.status == "pending"
      assert gallery_image.view_count == 0
      assert gallery_image.like_count == 0
    end

    test "create_gallery_image/1 with invalid data returns error changeset", %{festival: festival} do
      attrs = Map.put(@invalid_attrs, :festival_id, festival.id)
      assert {:error, %Ecto.Changeset{}} = Gallery.create_gallery_image(attrs)
    end

    test "create_gallery_image/1 with invalid url returns error changeset", %{festival: festival} do
      attrs =
        @valid_attrs
        |> Map.put(:festival_id, festival.id)
        |> Map.put(:image_url, "not-a-url")

      assert {:error, %Ecto.Changeset{} = changeset} = Gallery.create_gallery_image(attrs)
      assert %{image_url: ["有効なURLを入力してください"]} = errors_on(changeset)
    end

    test "update_gallery_image/2 with valid data updates the gallery_image", %{festival: festival} do
      gallery_image = gallery_image_fixture(festival)
      assert {:ok, %GalleryImage{} = updated} = Gallery.update_gallery_image(gallery_image, @update_attrs)
      assert updated.title == "更新された画像"
      assert updated.description == "更新された説明"
    end

    test "update_gallery_image/2 with invalid data returns error changeset", %{festival: festival} do
      gallery_image = gallery_image_fixture(festival)
      assert {:error, %Ecto.Changeset{}} = Gallery.update_gallery_image(gallery_image, %{image_url: "bad"})
    end

    test "delete_gallery_image/1 deletes the gallery_image", %{festival: festival} do
      gallery_image = gallery_image_fixture(festival)
      assert {:ok, %GalleryImage{}} = Gallery.delete_gallery_image(gallery_image)
      assert_raise Ecto.NoResultsError, fn -> Gallery.get_gallery_image!(gallery_image.id) end
    end

    test "change_gallery_image/2 returns a changeset", %{festival: festival} do
      gallery_image = gallery_image_fixture(festival)
      assert %Ecto.Changeset{} = Gallery.change_gallery_image(gallery_image)
    end

    test "change_gallery_image/2 with attrs returns a changeset", %{festival: festival} do
      gallery_image = gallery_image_fixture(festival)
      changeset = Gallery.change_gallery_image(gallery_image, %{title: "新しいタイトル"})
      assert %Ecto.Changeset{} = changeset
      assert Ecto.Changeset.get_change(changeset, :title) == "新しいタイトル"
    end

    test "approve_image/2 changes status to approved and sets approver", %{festival: festival, user: user} do
      gallery_image = gallery_image_fixture(festival)
      assert gallery_image.status == "pending"

      {:ok, approved} = Gallery.approve_image(gallery_image, user.id)
      assert approved.status == "approved"
      assert approved.approved_by_id == user.id
      assert approved.approved_at != nil
    end

    test "reject_image/1 changes status to rejected", %{festival: festival} do
      gallery_image = gallery_image_fixture(festival)
      {:ok, rejected} = Gallery.reject_image(gallery_image)
      assert rejected.status == "rejected"
    end

    test "toggle_featured/1 toggles the featured status", %{festival: festival} do
      gallery_image = gallery_image_fixture(festival)
      assert gallery_image.featured == false

      {:ok, featured} = Gallery.toggle_featured(gallery_image)
      assert featured.featured == true

      {:ok, unfeatured} = Gallery.toggle_featured(featured)
      assert unfeatured.featured == false
    end

    test "increment_view_count/1 increments the view count", %{festival: festival} do
      gallery_image = gallery_image_fixture(festival)
      assert gallery_image.view_count == 0

      {:ok, updated} = Gallery.increment_view_count(gallery_image)
      assert updated.view_count == 1
    end

    test "increment_like_count/1 increments the like count", %{festival: festival} do
      gallery_image = gallery_image_fixture(festival)
      assert gallery_image.like_count == 0

      {:ok, updated} = Gallery.increment_like_count(gallery_image)
      assert updated.like_count == 1
    end

    test "get_statistics/1 returns statistics for a festival", %{festival: festival, user: user} do
      gallery_image_fixture(festival)
      gallery_image_fixture(festival, %{title: "画像2"})
      image3 = gallery_image_fixture(festival, %{title: "画像3"})
      {:ok, _} = Gallery.approve_image(image3, user.id)

      stats = Gallery.get_statistics(festival.id)
      assert stats.total_count == 3
      assert stats.pending_count == 2
      assert stats.approved_count == 1
    end

    test "get_statistics/1 returns zero counts for empty festival" do
      festival = festival_fixture(%{name: "空の祭り"})
      stats = Gallery.get_statistics(festival.id)
      assert stats.total_count == 0
      assert stats.pending_count == 0
      assert stats.approved_count == 0
      assert stats.rejected_count == 0
      assert stats.featured_count == 0
      assert stats.total_views == 0
      assert stats.total_likes == 0
    end

    test "approve_all_pending/2 approves all pending images", %{festival: festival, user: user} do
      gallery_image_fixture(festival)
      gallery_image_fixture(festival, %{title: "画像2"})
      gallery_image_fixture(festival, %{title: "画像3"})

      {count, _} = Gallery.approve_all_pending(festival.id, user.id)
      assert count == 3

      pending = Gallery.list_pending_images(festival.id)
      assert length(pending) == 0
    end

    test "approve_all_pending/2 returns 0 when no pending images", %{festival: festival, user: user} do
      {count, _} = Gallery.approve_all_pending(festival.id, user.id)
      assert count == 0
    end

    test "list_popular_images/2 returns images sorted by likes", %{festival: festival, user: user} do
      image1 = gallery_image_fixture(festival)
      image2 = gallery_image_fixture(festival, %{title: "人気画像"})

      {:ok, approved2} = Gallery.approve_image(image2, user.id)
      {:ok, approved2} = Gallery.increment_like_count(approved2)
      {:ok, _approved2} = Gallery.increment_like_count(approved2)

      {:ok, approved1} = Gallery.approve_image(image1, user.id)
      {:ok, _} = Gallery.increment_like_count(approved1)

      popular = Gallery.list_popular_images(festival.id, 10)
      assert length(popular) == 2
      assert hd(popular).title == "人気画像"
    end

    test "list_popular_images/2 with limit restricts results", %{festival: festival, user: user} do
      for i <- 1..5 do
        img = gallery_image_fixture(festival, %{title: "画像#{i}"})
        {:ok, approved} = Gallery.approve_image(img, user.id)
        Gallery.increment_like_count(approved)
      end

      popular = Gallery.list_popular_images(festival.id, 3)
      assert length(popular) == 3
    end

    test "list_recent_images/2 returns recently approved images", %{festival: festival, user: user} do
      image1 = gallery_image_fixture(festival)
      image2 = gallery_image_fixture(festival, %{title: "最近の画像"})

      {:ok, _} = Gallery.approve_image(image1, user.id)
      {:ok, _} = Gallery.approve_image(image2, user.id)

      recent = Gallery.list_recent_images(festival.id, 10)
      assert length(recent) == 2
    end

    test "list_recent_images/2 does not return pending images", %{festival: festival} do
      _pending = gallery_image_fixture(festival)

      recent = Gallery.list_recent_images(festival.id, 10)
      assert Enum.empty?(recent)
    end

    test "list_recent_images/2 with limit restricts results", %{festival: festival, user: user} do
      for i <- 1..5 do
        img = gallery_image_fixture(festival, %{title: "画像#{i}"})
        Gallery.approve_image(img, user.id)
      end

      recent = Gallery.list_recent_images(festival.id, 2)
      assert length(recent) == 2
    end
  end

  defp festival_fixture(attrs \\ %{}) do
    {:ok, festival} =
      attrs
      |> Enum.into(%{
        name: "テスト祭り #{System.unique_integer()}",
        start_date: ~D[2026-08-15],
        end_date: ~D[2026-08-16],
        status: "planning"
      })
      |> MatsuriOps.Festivals.create_festival()

    festival
  end

  defp user_fixture(attrs \\ %{}) do
    unique_id = System.unique_integer([:positive])
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "test#{unique_id}@example.com",
        password: "Password123!"
      })
      |> MatsuriOps.Accounts.register_user()

    user
  end
end
