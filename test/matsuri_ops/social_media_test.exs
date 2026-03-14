defmodule MatsuriOps.SocialMediaTest do
  use MatsuriOps.DataCase, async: true

  alias MatsuriOps.SocialMedia
  alias MatsuriOps.SocialMedia.{SocialAccount, SocialPost}

  describe "social_accounts" do
    setup do
      festival = festival_fixture()
      %{festival: festival}
    end

    @valid_attrs %{
      platform: "twitter",
      account_name: "test_account"
    }

    def social_account_fixture(festival, attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put(:festival_id, festival.id)
        |> SocialMedia.create_social_account()

      account
    end

    test "list_social_accounts/1 returns all accounts for a festival", %{festival: festival} do
      account = social_account_fixture(festival)
      accounts = SocialMedia.list_social_accounts(festival.id)
      assert length(accounts) == 1
      assert hd(accounts).id == account.id
    end

    test "list_active_accounts/1 returns only active accounts", %{festival: festival} do
      social_account_fixture(festival, %{is_active: true})
      social_account_fixture(festival, %{platform: "instagram", account_name: "ig_account", is_active: false})

      active = SocialMedia.list_active_accounts(festival.id)
      assert length(active) == 1
    end

    test "get_account_by_platform/2 returns the active account for a platform", %{festival: festival} do
      social_account_fixture(festival, %{platform: "twitter", account_name: "tw"})

      account = SocialMedia.get_account_by_platform(festival.id, "twitter")
      assert account.platform == "twitter"
    end

    test "get_account_by_platform/2 returns nil for non-existent platform", %{festival: festival} do
      assert SocialMedia.get_account_by_platform(festival.id, "instagram") == nil
    end

    test "get_social_account!/1 returns the account", %{festival: festival} do
      account = social_account_fixture(festival)
      found = SocialMedia.get_social_account!(account.id)
      assert found.id == account.id
    end

    test "get_social_account!/1 raises for non-existent id" do
      assert_raise Ecto.NoResultsError, fn ->
        SocialMedia.get_social_account!(999_999)
      end
    end

    test "create_social_account/1 with valid data creates an account", %{festival: festival} do
      attrs = Map.put(@valid_attrs, :festival_id, festival.id)
      assert {:ok, %SocialAccount{} = account} = SocialMedia.create_social_account(attrs)
      assert account.platform == "twitter"
      assert account.account_name == "test_account"
    end

    test "create_social_account/1 with invalid platform returns error", %{festival: festival} do
      attrs =
        @valid_attrs
        |> Map.put(:festival_id, festival.id)
        |> Map.put(:platform, "invalid")

      assert {:error, %Ecto.Changeset{}} = SocialMedia.create_social_account(attrs)
    end

    test "create_social_account/1 without required fields returns error", %{festival: festival} do
      attrs = %{festival_id: festival.id}
      assert {:error, %Ecto.Changeset{}} = SocialMedia.create_social_account(attrs)
    end

    test "update_social_account/2 with valid data updates the account", %{festival: festival} do
      account = social_account_fixture(festival)
      {:ok, updated} = SocialMedia.update_social_account(account, %{account_name: "updated_name"})
      assert updated.account_name == "updated_name"
    end

    test "update_social_account/2 with invalid data returns error", %{festival: festival} do
      account = social_account_fixture(festival)
      assert {:error, %Ecto.Changeset{}} = SocialMedia.update_social_account(account, %{platform: "invalid"})
    end

    test "delete_social_account/1 deletes the account", %{festival: festival} do
      account = social_account_fixture(festival)
      assert {:ok, %SocialAccount{}} = SocialMedia.delete_social_account(account)
      assert_raise Ecto.NoResultsError, fn -> SocialMedia.get_social_account!(account.id) end
    end

    test "change_social_account/2 returns a changeset", %{festival: festival} do
      account = social_account_fixture(festival)
      assert %Ecto.Changeset{} = SocialMedia.change_social_account(account)
    end

    test "change_social_account/2 with attrs returns a changeset", %{festival: festival} do
      account = social_account_fixture(festival)
      changeset = SocialMedia.change_social_account(account, %{account_name: "new"})
      assert %Ecto.Changeset{} = changeset
    end
  end

  describe "social_posts" do
    setup do
      festival = festival_fixture()
      user = user_fixture()
      %{festival: festival, user: user}
    end

    @valid_attrs %{
      content: "テスト投稿です #祭り",
      platforms: ["twitter"]
    }

    def social_post_fixture(festival, user, attrs \\ %{}) do
      {:ok, post} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put(:festival_id, festival.id)
        |> Map.put(:created_by_id, user.id)
        |> SocialMedia.create_social_post()

      post
    end

    test "list_social_posts/1 returns all posts for a festival", %{festival: festival, user: user} do
      post = social_post_fixture(festival, user)
      posts = SocialMedia.list_social_posts(festival.id)
      assert length(posts) == 1
      assert hd(posts).id == post.id
    end

    test "list_posts_by_status/2 filters by status", %{festival: festival, user: user} do
      social_post_fixture(festival, user)
      social_post_fixture(festival, user, %{content: "下書き"})

      drafts = SocialMedia.list_posts_by_status(festival.id, "draft")
      assert length(drafts) == 2
    end

    test "list_scheduled_posts/1 returns only scheduled posts", %{festival: festival, user: user} do
      post = social_post_fixture(festival, user)
      scheduled_at = DateTime.utc_now() |> DateTime.add(3600, :second)
      {:ok, _} = SocialMedia.schedule_post(post, scheduled_at)

      _draft = social_post_fixture(festival, user, %{content: "下書き投稿"})

      scheduled = SocialMedia.list_scheduled_posts(festival.id)
      assert length(scheduled) == 1
      assert hd(scheduled).status == "scheduled"
    end

    test "list_pending_scheduled_posts/0 returns posts past their scheduled time", %{festival: festival, user: user} do
      post = social_post_fixture(festival, user)
      # Schedule in the past
      past_time = DateTime.utc_now() |> DateTime.add(-3600, :second)
      {:ok, _} = SocialMedia.schedule_post(post, past_time)

      pending = SocialMedia.list_pending_scheduled_posts()
      assert length(pending) >= 1
    end

    test "get_social_post!/1 returns the post", %{festival: festival, user: user} do
      post = social_post_fixture(festival, user)
      found = SocialMedia.get_social_post!(post.id)
      assert found.id == post.id
    end

    test "get_social_post!/1 raises for non-existent id" do
      assert_raise Ecto.NoResultsError, fn ->
        SocialMedia.get_social_post!(999_999)
      end
    end

    test "create_social_post/1 with valid data creates a post and extracts hashtags", %{festival: festival, user: user} do
      attrs =
        @valid_attrs
        |> Map.put(:festival_id, festival.id)
        |> Map.put(:created_by_id, user.id)

      assert {:ok, %SocialPost{} = post} = SocialMedia.create_social_post(attrs)
      assert post.content == "テスト投稿です #祭り"
      assert post.status == "draft"
      assert "#祭り" in post.hashtags
    end

    test "create_social_post/1 with content exceeding twitter limit returns error", %{festival: festival, user: user} do
      long_content = String.duplicate("あ", 300)
      attrs =
        @valid_attrs
        |> Map.put(:festival_id, festival.id)
        |> Map.put(:created_by_id, user.id)
        |> Map.put(:content, long_content)

      assert {:error, %Ecto.Changeset{}} = SocialMedia.create_social_post(attrs)
    end

    test "create_social_post/1 with invalid platforms returns error", %{festival: festival, user: user} do
      attrs =
        @valid_attrs
        |> Map.put(:festival_id, festival.id)
        |> Map.put(:created_by_id, user.id)
        |> Map.put(:platforms, ["invalid_platform"])

      assert {:error, %Ecto.Changeset{}} = SocialMedia.create_social_post(attrs)
    end

    test "update_social_post/2 updates content and re-extracts hashtags", %{festival: festival, user: user} do
      post = social_post_fixture(festival, user)
      {:ok, updated} = SocialMedia.update_social_post(post, %{content: "更新 #新タグ #テスト"})
      assert updated.content == "更新 #新タグ #テスト"
      assert "#新タグ" in updated.hashtags
      assert "#テスト" in updated.hashtags
    end

    test "update_social_post/2 with invalid data returns error", %{festival: festival, user: user} do
      post = social_post_fixture(festival, user)
      assert {:error, %Ecto.Changeset{}} = SocialMedia.update_social_post(post, %{content: nil})
    end

    test "delete_social_post/1 deletes the post", %{festival: festival, user: user} do
      post = social_post_fixture(festival, user)
      assert {:ok, %SocialPost{}} = SocialMedia.delete_social_post(post)
      assert_raise Ecto.NoResultsError, fn -> SocialMedia.get_social_post!(post.id) end
    end

    test "change_social_post/2 returns a changeset", %{festival: festival, user: user} do
      post = social_post_fixture(festival, user)
      assert %Ecto.Changeset{} = SocialMedia.change_social_post(post)
    end

    test "change_social_post/2 with attrs returns a changeset", %{festival: festival, user: user} do
      post = social_post_fixture(festival, user)
      changeset = SocialMedia.change_social_post(post, %{content: "変更"})
      assert %Ecto.Changeset{} = changeset
    end

    test "schedule_post/2 schedules a post", %{festival: festival, user: user} do
      post = social_post_fixture(festival, user)
      scheduled_at = DateTime.utc_now() |> DateTime.add(3600, :second)

      {:ok, scheduled} = SocialMedia.schedule_post(post, scheduled_at)
      assert scheduled.status == "scheduled"
      assert scheduled.scheduled_at != nil
    end

    test "mark_as_posted/2 marks post as posted with external ids", %{festival: festival, user: user} do
      post = social_post_fixture(festival, user)
      external_ids = %{"twitter" => "123456789"}

      {:ok, posted} = SocialMedia.mark_as_posted(post, external_ids)
      assert posted.status == "posted"
      assert posted.external_ids == external_ids
      assert posted.posted_at != nil
    end

    test "mark_as_failed/2 marks post as failed with error message", %{festival: festival, user: user} do
      post = social_post_fixture(festival, user)

      {:ok, failed} = SocialMedia.mark_as_failed(post, "API error")
      assert failed.status == "failed"
      assert failed.error_message == "API error"
    end

    test "update_analytics/2 updates analytics data", %{festival: festival, user: user} do
      post = social_post_fixture(festival, user)
      analytics = %{likes: 10, shares: 5, comments: 3, reach: 100}

      {:ok, updated} = SocialMedia.update_analytics(post, analytics)
      assert updated.likes_count == 10
      assert updated.shares_count == 5
      assert updated.comments_count == 3
      assert updated.reach_count == 100
    end

    test "duplicate_post/1 creates a copy as draft", %{festival: festival, user: user} do
      post = social_post_fixture(festival, user)
      {:ok, posted} = SocialMedia.mark_as_posted(post, %{})

      {:ok, copy} = SocialMedia.duplicate_post(posted)
      assert copy.content == posted.content
      assert copy.platforms == posted.platforms
      assert copy.status == "draft"
      assert copy.id != posted.id
    end

    test "get_statistics/1 returns statistics for a festival", %{festival: festival, user: user} do
      social_post_fixture(festival, user)
      social_post_fixture(festival, user, %{content: "投稿2"})
      post3 = social_post_fixture(festival, user, %{content: "投稿3"})
      {:ok, _} = SocialMedia.mark_as_posted(post3, %{})

      stats = SocialMedia.get_statistics(festival.id)
      assert stats.total_posts == 3
      assert stats.draft_count == 2
      assert stats.posted_count == 1
    end

    test "get_statistics/1 includes connected accounts count", %{festival: festival, user: user} do
      # Create an account
      SocialMedia.create_social_account(%{
        platform: "twitter",
        account_name: "test",
        festival_id: festival.id,
        is_active: true
      })

      social_post_fixture(festival, user)

      stats = SocialMedia.get_statistics(festival.id)
      assert stats.connected_accounts == 1
    end

    test "get_statistics/1 returns zeros for empty festival" do
      festival = festival_fixture(%{name: "空の祭り"})
      stats = SocialMedia.get_statistics(festival.id)
      assert stats.total_posts == 0
      assert stats.posted_count == 0
      assert stats.connected_accounts == 0
    end

    test "popular_hashtags/2 returns hashtags sorted by frequency", %{festival: festival, user: user} do
      social_post_fixture(festival, user, %{content: "投稿 #祭り #塩尻"})
      social_post_fixture(festival, user, %{content: "投稿2 #祭り"})
      social_post_fixture(festival, user, %{content: "投稿3 #祭り #イベント"})

      hashtags = SocialMedia.popular_hashtags(festival.id, 10)
      assert length(hashtags) == 3
      assert hd(hashtags) == {"#祭り", 3}
      other_hashtags = Enum.map(tl(hashtags), fn {tag, _count} -> tag end)
      assert "#塩尻" in other_hashtags
      assert "#イベント" in other_hashtags
    end

    test "popular_hashtags/2 with limit restricts results", %{festival: festival, user: user} do
      social_post_fixture(festival, user, %{content: "#a #b #c"})
      social_post_fixture(festival, user, %{content: "#a #b"})
      social_post_fixture(festival, user, %{content: "#a"})

      hashtags = SocialMedia.popular_hashtags(festival.id, 1)
      assert length(hashtags) == 1
    end
  end

  describe "SocialPost schema" do
    test "extract_hashtags/1 extracts hashtags from content" do
      content = "素晴らしい祭り！ #塩尻 #祭り2026 #楽しい"
      hashtags = SocialPost.extract_hashtags(content)

      assert "#塩尻" in hashtags
      assert "#祭り2026" in hashtags
      assert "#楽しい" in hashtags
      assert length(hashtags) == 3
    end

    test "extract_hashtags/1 returns empty list for nil" do
      assert SocialPost.extract_hashtags(nil) == []
    end

    test "extract_hashtags/1 returns empty list for content without hashtags" do
      assert SocialPost.extract_hashtags("no hashtags here") == []
    end

    test "extract_hashtags/1 deduplicates hashtags" do
      content = "#祭り #祭り #祭り"
      hashtags = SocialPost.extract_hashtags(content)
      assert length(hashtags) == 1
    end

    test "character_count/2 returns correct count for twitter" do
      content = "Hello World!"
      assert SocialPost.character_count(content, "twitter") == 12
    end

    test "character_count/2 returns correct count for instagram" do
      content = "テスト"
      assert SocialPost.character_count(content, "instagram") == 3
    end

    test "character_count/2 handles nil content" do
      assert SocialPost.character_count(nil, "twitter") == 0
    end

    test "character_limit/1 returns correct limit for each platform" do
      assert SocialPost.character_limit("twitter") == 280
      assert SocialPost.character_limit("instagram") == 2200
      assert SocialPost.character_limit("facebook") == 63206
    end

    test "character_limit/1 returns default for unknown platform" do
      assert SocialPost.character_limit("unknown") == 1000
    end

    test "available_platforms/0 returns platform list" do
      platforms = SocialPost.available_platforms()
      assert "twitter" in platforms
      assert "instagram" in platforms
      assert "facebook" in platforms
    end

    test "statuses/0 returns status list" do
      statuses = SocialPost.statuses()
      assert "draft" in statuses
      assert "scheduled" in statuses
      assert "posted" in statuses
      assert "failed" in statuses
    end

    test "status_label/1 returns correct labels" do
      assert SocialPost.status_label("draft") == "下書き"
      assert SocialPost.status_label("scheduled") == "予約済"
      assert SocialPost.status_label("posting") == "投稿中"
      assert SocialPost.status_label("posted") == "投稿済"
      assert SocialPost.status_label("failed") == "失敗"
      assert SocialPost.status_label("unknown") == "不明"
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
