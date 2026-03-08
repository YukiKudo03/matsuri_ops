defmodule MatsuriOps.Gallery.GalleryImage do
  @moduledoc """
  ギャラリー画像スキーマ。

  来場者から投稿された写真の管理を行う。
  """

  use Ecto.Schema
  import Ecto.Changeset

  @statuses ["pending", "approved", "rejected"]

  schema "gallery_images" do
    field :title, :string
    field :description, :string
    field :image_url, :string
    field :thumbnail_url, :string
    field :contributor_name, :string
    field :contributor_email, :string
    field :status, :string, default: "pending"
    field :featured, :boolean, default: false
    field :view_count, :integer, default: 0
    field :like_count, :integer, default: 0
    field :approved_at, :utc_datetime

    belongs_to :festival, MatsuriOps.Festivals.Festival
    belongs_to :approved_by, MatsuriOps.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(gallery_image, attrs) do
    gallery_image
    |> cast(attrs, [
      :title,
      :description,
      :image_url,
      :thumbnail_url,
      :contributor_name,
      :contributor_email,
      :status,
      :featured,
      :festival_id
    ])
    |> validate_required([:image_url, :festival_id])
    |> validate_inclusion(:status, @statuses)
    |> validate_format(:contributor_email, ~r/^[^\s]+@[^\s]+$/, message: "は有効なメールアドレスである必要があります")
    |> validate_url(:image_url)
    |> foreign_key_constraint(:festival_id)
  end

  @doc """
  承認用changeset。
  """
  def approve_changeset(gallery_image, user_id) do
    gallery_image
    |> change(
      status: "approved",
      approved_by_id: user_id,
      approved_at: DateTime.utc_now() |> DateTime.truncate(:second)
    )
  end

  @doc """
  却下用changeset。
  """
  def reject_changeset(gallery_image) do
    gallery_image
    |> change(status: "rejected")
  end

  @doc """
  閲覧数インクリメント用changeset。
  """
  def increment_view_changeset(gallery_image) do
    change(gallery_image, view_count: gallery_image.view_count + 1)
  end

  @doc """
  いいね数インクリメント用changeset。
  """
  def increment_like_changeset(gallery_image) do
    change(gallery_image, like_count: gallery_image.like_count + 1)
  end

  @doc """
  注目画像設定用changeset。
  """
  def toggle_featured_changeset(gallery_image) do
    change(gallery_image, featured: !gallery_image.featured)
  end

  @doc """
  利用可能なステータスを返す。
  """
  def statuses, do: @statuses

  @doc """
  ステータスのラベルを返す。
  """
  def status_label("pending"), do: "審査中"
  def status_label("approved"), do: "承認済"
  def status_label("rejected"), do: "却下"
  def status_label(_), do: "不明"

  defp validate_url(changeset, field) do
    validate_change(changeset, field, fn _, value ->
      if is_nil(value) || value == "" || String.match?(value, ~r/^https?:\/\/.+/) do
        []
      else
        [{field, "有効なURLを入力してください"}]
      end
    end)
  end
end
