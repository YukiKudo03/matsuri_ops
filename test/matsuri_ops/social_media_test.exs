defmodule MatsuriOps.SocialMediaTest do
  use MatsuriOps.DataCase

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
      draft = social_post_fixture(festival, user, %{content: "下書き"})

      drafts = SocialMedia.list_posts_by_status(festival.id, "draft")
      assert length(drafts) == 2
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

    test "popular_hashtags/2 returns hashtags sorted by frequency", %{festival: festival, user: user} do
      social_post_fixture(festival, user, %{content: "投稿 #祭り #塩尻"})
      social_post_fixture(festival, user, %{content: "投稿2 #祭り"})
      social_post_fixture(festival, user, %{content: "投稿3 #祭り #イベント"})

      hashtags = SocialMedia.popular_hashtags(festival.id, 10)
      assert length(hashtags) == 3
      # 最も多い#祭りが最初に来る
      assert hd(hashtags) == {"#祭り", 3}
      # 他のハッシュタグは1回ずつ
      other_hashtags = Enum.map(tl(hashtags), fn {tag, _count} -> tag end)
      assert "#塩尻" in other_hashtags
      assert "#イベント" in other_hashtags
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

    test "character_count/2 returns correct count for twitter" do
      content = "Hello World!"
      assert SocialPost.character_count(content, "twitter") == 12
    end

    test "character_limit/1 returns correct limit for each platform" do
      assert SocialPost.character_limit("twitter") == 280
      assert SocialPost.character_limit("instagram") == 2200
      assert SocialPost.character_limit("facebook") == 63206
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
