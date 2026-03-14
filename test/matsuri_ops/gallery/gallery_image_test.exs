defmodule MatsuriOps.Gallery.GalleryImageTest do
  use MatsuriOps.DataCase, async: true

  alias MatsuriOps.Gallery.GalleryImage

  describe "changeset/2" do
    test "valid changeset with required fields" do
      changeset = GalleryImage.changeset(%GalleryImage{}, %{
        image_url: "https://example.com/test.jpg",
        festival_id: 1
      })

      assert changeset.valid?
    end

    test "invalid changeset without image_url" do
      changeset = GalleryImage.changeset(%GalleryImage{}, %{festival_id: 1})
      refute changeset.valid?
      assert %{image_url: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset without festival_id" do
      changeset = GalleryImage.changeset(%GalleryImage{}, %{
        image_url: "https://example.com/test.jpg"
      })

      refute changeset.valid?
      assert %{festival_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset with bad URL" do
      changeset = GalleryImage.changeset(%GalleryImage{}, %{
        image_url: "not-a-url",
        festival_id: 1
      })

      refute changeset.valid?
      assert %{image_url: ["有効なURLを入力してください"]} = errors_on(changeset)
    end

    test "valid changeset with all optional fields" do
      changeset = GalleryImage.changeset(%GalleryImage{}, %{
        image_url: "https://example.com/test.jpg",
        festival_id: 1,
        title: "テスト",
        description: "説明",
        thumbnail_url: "https://example.com/thumb.jpg",
        contributor_name: "太郎",
        contributor_email: "test@example.com",
        featured: true
      })

      assert changeset.valid?
    end

    test "invalid changeset with bad email format" do
      changeset = GalleryImage.changeset(%GalleryImage{}, %{
        image_url: "https://example.com/test.jpg",
        festival_id: 1,
        contributor_email: "not-an-email"
      })

      refute changeset.valid?
      assert %{contributor_email: [_msg]} = errors_on(changeset)
    end

    test "invalid changeset with invalid status" do
      changeset = GalleryImage.changeset(%GalleryImage{}, %{
        image_url: "https://example.com/test.jpg",
        festival_id: 1,
        status: "invalid_status"
      })

      refute changeset.valid?
      assert %{status: ["is invalid"]} = errors_on(changeset)
    end
  end

  describe "statuses/0" do
    test "returns all valid statuses" do
      statuses = GalleryImage.statuses()
      assert "pending" in statuses
      assert "approved" in statuses
      assert "rejected" in statuses
      assert length(statuses) == 3
    end
  end

  describe "status_label/1" do
    test "returns correct label for pending" do
      assert GalleryImage.status_label("pending") == "審査中"
    end

    test "returns correct label for approved" do
      assert GalleryImage.status_label("approved") == "承認済"
    end

    test "returns correct label for rejected" do
      assert GalleryImage.status_label("rejected") == "却下"
    end

    test "returns unknown for invalid status" do
      assert GalleryImage.status_label("invalid") == "不明"
    end
  end

  describe "approve_changeset/2" do
    test "sets status to approved with approver and timestamp" do
      image = %GalleryImage{status: "pending"}
      changeset = GalleryImage.approve_changeset(image, 42)

      assert Ecto.Changeset.get_change(changeset, :status) == "approved"
      assert Ecto.Changeset.get_change(changeset, :approved_by_id) == 42
      assert Ecto.Changeset.get_change(changeset, :approved_at) != nil
    end
  end

  describe "reject_changeset/1" do
    test "sets status to rejected" do
      image = %GalleryImage{status: "pending"}
      changeset = GalleryImage.reject_changeset(image)

      assert Ecto.Changeset.get_change(changeset, :status) == "rejected"
    end
  end

  describe "toggle_featured_changeset/1" do
    test "toggles featured from false to true" do
      image = %GalleryImage{featured: false}
      changeset = GalleryImage.toggle_featured_changeset(image)

      assert Ecto.Changeset.get_change(changeset, :featured) == true
    end

    test "toggles featured from true to false" do
      image = %GalleryImage{featured: true}
      changeset = GalleryImage.toggle_featured_changeset(image)

      assert Ecto.Changeset.get_change(changeset, :featured) == false
    end
  end

  describe "increment_view_changeset/1" do
    test "increments view_count by 1" do
      image = %GalleryImage{view_count: 5}
      changeset = GalleryImage.increment_view_changeset(image)

      assert Ecto.Changeset.get_change(changeset, :view_count) == 6
    end

    test "increments from 0" do
      image = %GalleryImage{view_count: 0}
      changeset = GalleryImage.increment_view_changeset(image)

      assert Ecto.Changeset.get_change(changeset, :view_count) == 1
    end
  end

  describe "increment_like_changeset/1" do
    test "increments like_count by 1" do
      image = %GalleryImage{like_count: 10}
      changeset = GalleryImage.increment_like_changeset(image)

      assert Ecto.Changeset.get_change(changeset, :like_count) == 11
    end

    test "increments from 0" do
      image = %GalleryImage{like_count: 0}
      changeset = GalleryImage.increment_like_changeset(image)

      assert Ecto.Changeset.get_change(changeset, :like_count) == 1
    end
  end
end
