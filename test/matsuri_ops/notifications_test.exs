defmodule MatsuriOps.NotificationsTest do
  @moduledoc """
  通知・お知らせ機能のテスト。

  TDDフェーズ: 🔴 RED → 🟢 GREEN
  """

  use MatsuriOps.DataCase

  alias MatsuriOps.Notifications
  alias MatsuriOps.Notifications.{Announcement, PushSubscription}
  alias MatsuriOps.Festivals

  import MatsuriOps.AccountsFixtures

  defp create_festival(user) do
    {:ok, festival} =
      Festivals.create_festival(user, %{
        name: "テスト祭り",
        start_date: Date.new!(2025, 8, 1),
        end_date: Date.new!(2025, 8, 2),
        scale: "medium",
        status: "planning"
      })

    festival
  end

  describe "announcements" do
    setup do
      user = user_fixture()
      festival = create_festival(user)
      %{user: user, festival: festival}
    end

    @valid_attrs %{
      title: "重要なお知らせ",
      content: "祭りの開始時間が変更になりました",
      priority: "high",
      target_audience: "all"
    }

    @invalid_attrs %{title: nil, content: nil}

    test "list_announcements/1 returns all announcements for a festival", %{festival: festival, user: user} do
      announcement = announcement_fixture(festival, user)
      assert Notifications.list_announcements(festival.id) == [announcement]
    end

    test "get_announcement!/1 returns the announcement with given id", %{festival: festival, user: user} do
      announcement = announcement_fixture(festival, user)
      assert Notifications.get_announcement!(announcement.id) == announcement
    end

    test "create_announcement/1 with valid data creates an announcement", %{festival: festival, user: user} do
      attrs = Map.merge(@valid_attrs, %{festival_id: festival.id, created_by_id: user.id})
      assert {:ok, %Announcement{} = announcement} = Notifications.create_announcement(attrs)
      assert announcement.title == "重要なお知らせ"
      assert announcement.priority == "high"
    end

    test "create_announcement/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Notifications.create_announcement(@invalid_attrs)
    end

    test "update_announcement/2 with valid data updates the announcement", %{festival: festival, user: user} do
      announcement = announcement_fixture(festival, user)
      update_attrs = %{title: "更新されたお知らせ"}
      assert {:ok, %Announcement{} = announcement} = Notifications.update_announcement(announcement, update_attrs)
      assert announcement.title == "更新されたお知らせ"
    end

    test "delete_announcement/1 deletes the announcement", %{festival: festival, user: user} do
      announcement = announcement_fixture(festival, user)
      assert {:ok, %Announcement{}} = Notifications.delete_announcement(announcement)
      assert_raise Ecto.NoResultsError, fn -> Notifications.get_announcement!(announcement.id) end
    end

    test "list_active_announcements/1 returns only active announcements", %{festival: festival, user: user} do
      _expired = announcement_fixture(festival, user, %{
        expires_at: DateTime.add(DateTime.utc_now(), -1, :day) |> DateTime.truncate(:second)
      })
      active = announcement_fixture(festival, user, %{
        expires_at: DateTime.add(DateTime.utc_now(), 1, :day) |> DateTime.truncate(:second)
      })

      announcements = Notifications.list_active_announcements(festival.id)
      assert length(announcements) == 1
      assert hd(announcements).id == active.id
    end
  end

  describe "push subscriptions" do
    setup do
      user = user_fixture()
      %{user: user}
    end

    test "create_push_subscription/1 creates a subscription", %{user: user} do
      attrs = %{
        user_id: user.id,
        endpoint: "https://push.example.com/123",
        p256dh_key: "key123",
        auth_key: "auth123"
      }

      assert {:ok, %PushSubscription{} = sub} = Notifications.create_push_subscription(attrs)
      assert sub.endpoint == "https://push.example.com/123"
    end

    test "list_push_subscriptions/1 returns subscriptions for a user", %{user: user} do
      {:ok, sub} = Notifications.create_push_subscription(%{
        user_id: user.id,
        endpoint: "https://push.example.com/123",
        p256dh_key: "key123",
        auth_key: "auth123"
      })

      subscriptions = Notifications.list_push_subscriptions(user.id)
      assert length(subscriptions) == 1
      assert hd(subscriptions).id == sub.id
    end

    test "delete_push_subscription/1 deletes the subscription", %{user: user} do
      {:ok, sub} = Notifications.create_push_subscription(%{
        user_id: user.id,
        endpoint: "https://push.example.com/123",
        p256dh_key: "key123",
        auth_key: "auth123"
      })

      assert {:ok, _} = Notifications.delete_push_subscription(sub)
      assert Notifications.list_push_subscriptions(user.id) == []
    end
  end

  # Helper functions
  defp announcement_fixture(festival, user, attrs \\ %{}) do
    {:ok, announcement} =
      attrs
      |> Enum.into(%{
        title: "テストお知らせ#{System.unique_integer()}",
        content: "テスト内容",
        priority: "normal",
        target_audience: "all",
        festival_id: festival.id,
        created_by_id: user.id
      })
      |> Notifications.create_announcement()

    announcement
  end
end
