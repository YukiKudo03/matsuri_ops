defmodule MatsuriOps.Gallery do
  @moduledoc """
  ギャラリー管理コンテキスト。

  来場者の写真投稿、承認フロー、ギャラリー表示を提供する。
  """

  import Ecto.Query, warn: false
  alias MatsuriOps.Repo
  alias MatsuriOps.Gallery.GalleryImage

  @doc """
  祭りに関連する全ての画像を取得する。
  """
  def list_gallery_images(festival_id) do
    GalleryImage
    |> where([g], g.festival_id == ^festival_id)
    |> order_by([g], [desc: g.inserted_at])
    |> preload(:approved_by)
    |> Repo.all()
  end

  @doc """
  承認済みの画像のみを取得する。
  """
  def list_approved_images(festival_id) do
    GalleryImage
    |> where([g], g.festival_id == ^festival_id)
    |> where([g], g.status == "approved")
    |> order_by([g], [desc: g.featured, desc: g.inserted_at])
    |> Repo.all()
  end

  @doc """
  注目画像を取得する。
  """
  def list_featured_images(festival_id) do
    GalleryImage
    |> where([g], g.festival_id == ^festival_id)
    |> where([g], g.status == "approved")
    |> where([g], g.featured == true)
    |> order_by([g], [desc: g.inserted_at])
    |> Repo.all()
  end

  @doc """
  審査待ちの画像を取得する。
  """
  def list_pending_images(festival_id) do
    GalleryImage
    |> where([g], g.festival_id == ^festival_id)
    |> where([g], g.status == "pending")
    |> order_by([g], [asc: g.inserted_at])
    |> Repo.all()
  end

  @doc """
  ステータスでフィルタした画像を取得する。
  """
  def list_images_by_status(festival_id, status) do
    GalleryImage
    |> where([g], g.festival_id == ^festival_id)
    |> where([g], g.status == ^status)
    |> order_by([g], [desc: g.inserted_at])
    |> preload(:approved_by)
    |> Repo.all()
  end

  @doc """
  画像を取得する。

  見つからない場合は`Ecto.NoResultsError`を発生させる。
  """
  def get_gallery_image!(id) do
    GalleryImage
    |> Repo.get!(id)
    |> Repo.preload(:approved_by)
  end

  @doc """
  画像を取得する。見つからない場合はnilを返す。
  """
  def get_gallery_image(id), do: Repo.get(GalleryImage, id)

  @doc """
  画像を作成する（来場者からの投稿）。
  """
  def create_gallery_image(attrs \\ %{}) do
    %GalleryImage{}
    |> GalleryImage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  画像を更新する。
  """
  def update_gallery_image(%GalleryImage{} = gallery_image, attrs) do
    gallery_image
    |> GalleryImage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  画像を削除する。
  """
  def delete_gallery_image(%GalleryImage{} = gallery_image) do
    Repo.delete(gallery_image)
  end

  @doc """
  画像の変更用changesetを返す。
  """
  def change_gallery_image(%GalleryImage{} = gallery_image, attrs \\ %{}) do
    GalleryImage.changeset(gallery_image, attrs)
  end

  @doc """
  画像を承認する。
  """
  def approve_image(%GalleryImage{} = gallery_image, user_id) do
    gallery_image
    |> GalleryImage.approve_changeset(user_id)
    |> Repo.update()
  end

  @doc """
  画像を却下する。
  """
  def reject_image(%GalleryImage{} = gallery_image) do
    gallery_image
    |> GalleryImage.reject_changeset()
    |> Repo.update()
  end

  @doc """
  注目画像のステータスを切り替える。
  """
  def toggle_featured(%GalleryImage{} = gallery_image) do
    gallery_image
    |> GalleryImage.toggle_featured_changeset()
    |> Repo.update()
  end

  @doc """
  閲覧数をインクリメントする。
  """
  def increment_view_count(%GalleryImage{} = gallery_image) do
    gallery_image
    |> GalleryImage.increment_view_changeset()
    |> Repo.update()
  end

  @doc """
  いいね数をインクリメントする。
  """
  def increment_like_count(%GalleryImage{} = gallery_image) do
    gallery_image
    |> GalleryImage.increment_like_changeset()
    |> Repo.update()
  end

  @doc """
  祭りのギャラリー統計を取得する。
  """
  def get_statistics(festival_id) do
    stats =
      GalleryImage
      |> where([g], g.festival_id == ^festival_id)
      |> select([g], %{
        total_count: count(g.id),
        approved_count: sum(fragment("CASE WHEN ? = 'approved' THEN 1 ELSE 0 END", g.status)),
        pending_count: sum(fragment("CASE WHEN ? = 'pending' THEN 1 ELSE 0 END", g.status)),
        rejected_count: sum(fragment("CASE WHEN ? = 'rejected' THEN 1 ELSE 0 END", g.status)),
        featured_count: sum(fragment("CASE WHEN ? THEN 1 ELSE 0 END", g.featured)),
        total_views: sum(g.view_count),
        total_likes: sum(g.like_count)
      })
      |> Repo.one()

    %{
      total_count: stats.total_count || 0,
      approved_count: stats.approved_count || 0,
      pending_count: stats.pending_count || 0,
      rejected_count: stats.rejected_count || 0,
      featured_count: stats.featured_count || 0,
      total_views: stats.total_views || 0,
      total_likes: stats.total_likes || 0
    }
  end

  @doc """
  一括承認する。
  """
  def approve_all_pending(festival_id, user_id) do
    from(g in GalleryImage,
      where: g.festival_id == ^festival_id and g.status == "pending"
    )
    |> Repo.update_all(
      set: [
        status: "approved",
        approved_by_id: user_id,
        approved_at: DateTime.utc_now() |> DateTime.truncate(:second)
      ]
    )
  end

  @doc """
  人気の画像を取得する（いいね数順）。
  """
  def list_popular_images(festival_id, limit \\ 10) do
    GalleryImage
    |> where([g], g.festival_id == ^festival_id)
    |> where([g], g.status == "approved")
    |> order_by([g], [desc: g.like_count, desc: g.view_count])
    |> limit(^limit)
    |> Repo.all()
  end

  @doc """
  最近の画像を取得する。
  """
  def list_recent_images(festival_id, limit \\ 10) do
    GalleryImage
    |> where([g], g.festival_id == ^festival_id)
    |> where([g], g.status == "approved")
    |> order_by([g], [desc: g.inserted_at])
    |> limit(^limit)
    |> Repo.all()
  end
end
