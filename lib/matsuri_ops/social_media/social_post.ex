defmodule MatsuriOps.SocialMedia.SocialPost do
  @moduledoc """
  ソーシャル投稿スキーマ。

  SNS投稿の作成、予約、実行を管理する。
  """

  use Ecto.Schema
  import Ecto.Changeset

  @statuses ["draft", "scheduled", "posting", "posted", "failed"]
  @platforms ["twitter", "instagram", "facebook"]

  schema "social_posts" do
    field :content, :string
    field :platforms, {:array, :string}, default: []
    field :scheduled_at, :utc_datetime
    field :posted_at, :utc_datetime
    field :status, :string, default: "draft"
    field :external_ids, :map, default: %{}
    field :media_urls, {:array, :string}, default: []
    field :hashtags, {:array, :string}, default: []
    field :error_message, :string

    # 分析データ
    field :likes_count, :integer, default: 0
    field :shares_count, :integer, default: 0
    field :comments_count, :integer, default: 0
    field :reach_count, :integer, default: 0

    belongs_to :festival, MatsuriOps.Festivals.Festival
    belongs_to :created_by, MatsuriOps.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(social_post, attrs) do
    social_post
    |> cast(attrs, [
      :content,
      :platforms,
      :scheduled_at,
      :status,
      :media_urls,
      :hashtags,
      :festival_id,
      :created_by_id
    ])
    |> validate_required([:content, :platforms, :festival_id])
    |> validate_inclusion(:status, @statuses)
    |> validate_platforms()
    |> validate_content_length()
    |> foreign_key_constraint(:festival_id)
    |> foreign_key_constraint(:created_by_id)
  end

  @doc """
  投稿実行用changeset。
  """
  def post_changeset(social_post, external_ids) do
    social_post
    |> change(
      status: "posted",
      posted_at: DateTime.utc_now() |> DateTime.truncate(:second),
      external_ids: external_ids
    )
  end

  @doc """
  投稿失敗用changeset。
  """
  def fail_changeset(social_post, error_message) do
    social_post
    |> change(status: "failed", error_message: error_message)
  end

  @doc """
  予約投稿用changeset。
  """
  def schedule_changeset(social_post, scheduled_at) do
    truncated_at = DateTime.truncate(scheduled_at, :second)
    social_post
    |> change(status: "scheduled", scheduled_at: truncated_at)
  end

  @doc """
  分析データ更新用changeset。
  """
  def analytics_changeset(social_post, analytics) do
    social_post
    |> change(
      likes_count: analytics[:likes] || social_post.likes_count,
      shares_count: analytics[:shares] || social_post.shares_count,
      comments_count: analytics[:comments] || social_post.comments_count,
      reach_count: analytics[:reach] || social_post.reach_count
    )
  end

  @doc """
  利用可能なステータスを返す。
  """
  def statuses, do: @statuses

  @doc """
  利用可能なプラットフォームを返す。
  """
  def available_platforms, do: @platforms

  @doc """
  ステータスのラベルを返す。
  """
  def status_label("draft"), do: "下書き"
  def status_label("scheduled"), do: "予約済"
  def status_label("posting"), do: "投稿中"
  def status_label("posted"), do: "投稿済"
  def status_label("failed"), do: "失敗"
  def status_label(_), do: "不明"

  @doc """
  ハッシュタグを抽出する。
  """
  def extract_hashtags(content) when is_binary(content) do
    Regex.scan(~r/#[\p{L}\p{N}_]+/u, content)
    |> List.flatten()
    |> Enum.uniq()
  end

  def extract_hashtags(_), do: []

  @doc """
  文字数を返す（プラットフォーム別の制限考慮）。
  """
  def character_count(content, "twitter"), do: String.length(content || "")
  def character_count(content, "instagram"), do: String.length(content || "")
  def character_count(content, _), do: String.length(content || "")

  @doc """
  プラットフォーム別の文字数制限を返す。
  """
  def character_limit("twitter"), do: 280
  def character_limit("instagram"), do: 2200
  def character_limit("facebook"), do: 63206
  def character_limit(_), do: 1000

  defp validate_platforms(changeset) do
    validate_change(changeset, :platforms, fn _, platforms ->
      invalid = Enum.reject(platforms, &(&1 in @platforms))

      if Enum.empty?(invalid) do
        []
      else
        [{:platforms, "無効なプラットフォームが含まれています: #{Enum.join(invalid, ", ")}"}]
      end
    end)
  end

  defp validate_content_length(changeset) do
    content = get_field(changeset, :content)
    platforms = get_field(changeset, :platforms) || []

    if is_nil(content) do
      changeset
    else
      Enum.reduce(platforms, changeset, fn platform, acc ->
        limit = character_limit(platform)
        count = character_count(content, platform)

        if count > limit do
          add_error(acc, :content, "#{platform}の文字数制限（#{limit}文字）を超えています（現在#{count}文字）")
        else
          acc
        end
      end)
    end
  end
end
