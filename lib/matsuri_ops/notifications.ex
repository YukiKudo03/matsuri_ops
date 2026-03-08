defmodule MatsuriOps.Notifications do
  @moduledoc """
  通知・お知らせコンテキスト。

  お知らせのCRUD操作とプッシュ通知の管理を提供する。
  """

  import Ecto.Query, warn: false
  alias MatsuriOps.Repo
  alias MatsuriOps.Notifications.{Announcement, PushSubscription}

  # Announcement functions

  @doc """
  祭りに関連する全てのお知らせを取得する。
  """
  def list_announcements(festival_id) do
    Announcement
    |> where([a], a.festival_id == ^festival_id)
    |> order_by([a], desc: a.inserted_at)
    |> Repo.all()
  end

  @doc """
  祭りに関連する有効なお知らせのみを取得する。
  """
  def list_active_announcements(festival_id) do
    now = DateTime.utc_now()

    Announcement
    |> where([a], a.festival_id == ^festival_id)
    |> where([a], is_nil(a.expires_at) or a.expires_at > ^now)
    |> order_by([a], [desc: :priority, desc: :inserted_at])
    |> Repo.all()
  end

  @doc """
  指定されたIDのお知らせを取得する。
  """
  def get_announcement!(id), do: Repo.get!(Announcement, id)

  @doc """
  お知らせを作成する。
  """
  def create_announcement(attrs \\ %{}) do
    result =
      %Announcement{}
      |> Announcement.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, announcement} ->
        broadcast_announcement(announcement)
        {:ok, announcement}

      error ->
        error
    end
  end

  @doc """
  お知らせを更新する。
  """
  def update_announcement(%Announcement{} = announcement, attrs) do
    announcement
    |> Announcement.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  お知らせを削除する。
  """
  def delete_announcement(%Announcement{} = announcement) do
    Repo.delete(announcement)
  end

  @doc """
  お知らせのchangesetを返す。
  """
  def change_announcement(%Announcement{} = announcement, attrs \\ %{}) do
    Announcement.changeset(announcement, attrs)
  end

  # PushSubscription functions

  @doc """
  ユーザーのプッシュ通知購読を取得する。
  """
  def list_push_subscriptions(user_id) do
    PushSubscription
    |> where([s], s.user_id == ^user_id)
    |> Repo.all()
  end

  @doc """
  プッシュ通知購読を作成する。
  """
  def create_push_subscription(attrs \\ %{}) do
    %PushSubscription{}
    |> PushSubscription.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  プッシュ通知購読を削除する。
  """
  def delete_push_subscription(%PushSubscription{} = subscription) do
    Repo.delete(subscription)
  end

  # PubSub functions

  @doc """
  お知らせチャンネルを購読する。
  """
  def subscribe_announcements(festival_id) do
    Phoenix.PubSub.subscribe(MatsuriOps.PubSub, "announcements:#{festival_id}")
  end

  defp broadcast_announcement(%Announcement{} = announcement) do
    Phoenix.PubSub.broadcast(
      MatsuriOps.PubSub,
      "announcements:#{announcement.festival_id}",
      {:new_announcement, announcement}
    )
  end
end
