defmodule MatsuriOps.SocialMedia do
  @moduledoc """
  ソーシャルメディア管理コンテキスト。

  SNSアカウント連携、投稿管理、分析機能を提供する。
  """

  import Ecto.Query, warn: false
  alias MatsuriOps.Repo
  alias MatsuriOps.SocialMedia.{SocialAccount, SocialPost}

  # =====================
  # Social Account CRUD
  # =====================

  @doc """
  祭りのソーシャルアカウント一覧を取得する。
  """
  def list_social_accounts(festival_id) do
    SocialAccount
    |> where([a], a.festival_id == ^festival_id)
    |> order_by([a], [asc: a.platform])
    |> Repo.all()
  end

  @doc """
  アクティブなソーシャルアカウント一覧を取得する。
  """
  def list_active_accounts(festival_id) do
    SocialAccount
    |> where([a], a.festival_id == ^festival_id and a.is_active == true)
    |> Repo.all()
  end

  @doc """
  プラットフォームでアカウントを取得する。
  """
  def get_account_by_platform(festival_id, platform) do
    SocialAccount
    |> where([a], a.festival_id == ^festival_id and a.platform == ^platform)
    |> where([a], a.is_active == true)
    |> Repo.one()
  end

  @doc """
  ソーシャルアカウントを取得する。
  """
  def get_social_account!(id), do: Repo.get!(SocialAccount, id)

  @doc """
  ソーシャルアカウントを作成する。
  """
  def create_social_account(attrs \\ %{}) do
    %SocialAccount{}
    |> SocialAccount.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  ソーシャルアカウントを更新する。
  """
  def update_social_account(%SocialAccount{} = social_account, attrs) do
    social_account
    |> SocialAccount.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  ソーシャルアカウントを削除する。
  """
  def delete_social_account(%SocialAccount{} = social_account) do
    Repo.delete(social_account)
  end

  @doc """
  ソーシャルアカウントの変更用changesetを返す。
  """
  def change_social_account(%SocialAccount{} = social_account, attrs \\ %{}) do
    SocialAccount.changeset(social_account, attrs)
  end

  # =====================
  # Social Post CRUD
  # =====================

  @doc """
  祭りのソーシャル投稿一覧を取得する。
  """
  def list_social_posts(festival_id) do
    SocialPost
    |> where([p], p.festival_id == ^festival_id)
    |> order_by([p], [desc: p.inserted_at])
    |> preload(:created_by)
    |> Repo.all()
  end

  @doc """
  ステータスでフィルタした投稿一覧を取得する。
  """
  def list_posts_by_status(festival_id, status) do
    SocialPost
    |> where([p], p.festival_id == ^festival_id and p.status == ^status)
    |> order_by([p], [desc: p.inserted_at])
    |> preload(:created_by)
    |> Repo.all()
  end

  @doc """
  予約済み投稿を取得する（投稿時刻順）。
  """
  def list_scheduled_posts(festival_id) do
    SocialPost
    |> where([p], p.festival_id == ^festival_id and p.status == "scheduled")
    |> order_by([p], [asc: p.scheduled_at])
    |> preload(:created_by)
    |> Repo.all()
  end

  @doc """
  投稿待ちの予約投稿を取得する。
  """
  def list_pending_scheduled_posts do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    SocialPost
    |> where([p], p.status == "scheduled" and p.scheduled_at <= ^now)
    |> order_by([p], [asc: p.scheduled_at])
    |> Repo.all()
  end

  @doc """
  ソーシャル投稿を取得する。
  """
  def get_social_post!(id) do
    SocialPost
    |> Repo.get!(id)
    |> Repo.preload(:created_by)
  end

  @doc """
  ソーシャル投稿を作成する。
  """
  def create_social_post(attrs \\ %{}) do
    changeset =
      %SocialPost{}
      |> SocialPost.changeset(attrs)

    # ハッシュタグを自動抽出
    content = Map.get(attrs, :content) || Map.get(attrs, "content")
    hashtags = SocialPost.extract_hashtags(content)

    changeset
    |> Ecto.Changeset.put_change(:hashtags, hashtags)
    |> Repo.insert()
  end

  @doc """
  ソーシャル投稿を更新する。
  """
  def update_social_post(%SocialPost{} = social_post, attrs) do
    changeset = SocialPost.changeset(social_post, attrs)

    # ハッシュタグを再抽出
    content = Ecto.Changeset.get_field(changeset, :content)
    hashtags = SocialPost.extract_hashtags(content)

    changeset
    |> Ecto.Changeset.put_change(:hashtags, hashtags)
    |> Repo.update()
  end

  @doc """
  ソーシャル投稿を削除する。
  """
  def delete_social_post(%SocialPost{} = social_post) do
    Repo.delete(social_post)
  end

  @doc """
  ソーシャル投稿の変更用changesetを返す。
  """
  def change_social_post(%SocialPost{} = social_post, attrs \\ %{}) do
    SocialPost.changeset(social_post, attrs)
  end

  @doc """
  投稿を予約する。
  """
  def schedule_post(%SocialPost{} = social_post, scheduled_at) do
    social_post
    |> SocialPost.schedule_changeset(scheduled_at)
    |> Repo.update()
  end

  @doc """
  投稿を実行済みにする。
  """
  def mark_as_posted(%SocialPost{} = social_post, external_ids \\ %{}) do
    social_post
    |> SocialPost.post_changeset(external_ids)
    |> Repo.update()
  end

  @doc """
  投稿を失敗にする。
  """
  def mark_as_failed(%SocialPost{} = social_post, error_message) do
    social_post
    |> SocialPost.fail_changeset(error_message)
    |> Repo.update()
  end

  @doc """
  分析データを更新する。
  """
  def update_analytics(%SocialPost{} = social_post, analytics) do
    social_post
    |> SocialPost.analytics_changeset(analytics)
    |> Repo.update()
  end

  # =====================
  # Statistics
  # =====================

  @doc """
  祭りのソーシャルメディア統計を取得する。
  """
  def get_statistics(festival_id) do
    post_stats =
      SocialPost
      |> where([p], p.festival_id == ^festival_id)
      |> select([p], %{
        total_posts: count(p.id),
        posted_count: sum(fragment("CASE WHEN ? = 'posted' THEN 1 ELSE 0 END", p.status)),
        scheduled_count: sum(fragment("CASE WHEN ? = 'scheduled' THEN 1 ELSE 0 END", p.status)),
        draft_count: sum(fragment("CASE WHEN ? = 'draft' THEN 1 ELSE 0 END", p.status)),
        total_likes: sum(p.likes_count),
        total_shares: sum(p.shares_count),
        total_reach: sum(p.reach_count)
      })
      |> Repo.one()

    account_count =
      SocialAccount
      |> where([a], a.festival_id == ^festival_id and a.is_active == true)
      |> select([a], count(a.id))
      |> Repo.one()

    %{
      total_posts: post_stats.total_posts || 0,
      posted_count: post_stats.posted_count || 0,
      scheduled_count: post_stats.scheduled_count || 0,
      draft_count: post_stats.draft_count || 0,
      total_likes: post_stats.total_likes || 0,
      total_shares: post_stats.total_shares || 0,
      total_reach: post_stats.total_reach || 0,
      connected_accounts: account_count || 0
    }
  end

  @doc """
  人気のハッシュタグを取得する。
  """
  def popular_hashtags(festival_id, limit \\ 10) do
    SocialPost
    |> where([p], p.festival_id == ^festival_id)
    |> select([p], p.hashtags)
    |> Repo.all()
    |> List.flatten()
    |> Enum.frequencies()
    |> Enum.sort_by(fn {_, count} -> -count end)
    |> Enum.take(limit)
  end

  @doc """
  投稿をコピーして下書きを作成する。
  """
  def duplicate_post(%SocialPost{} = social_post) do
    attrs = %{
      content: social_post.content,
      platforms: social_post.platforms,
      media_urls: social_post.media_urls,
      festival_id: social_post.festival_id,
      created_by_id: social_post.created_by_id,
      status: "draft"
    }

    create_social_post(attrs)
  end
end
