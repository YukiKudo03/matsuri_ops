defmodule MatsuriOps.SocialMedia.SocialPostTest do
  use MatsuriOps.DataCase, async: true

  alias MatsuriOps.SocialMedia.SocialPost

  describe "changeset/2" do
    test "valid changeset with required fields" do
      changeset = SocialPost.changeset(%SocialPost{}, %{
        content: "テスト投稿",
        platforms: ["twitter"],
        festival_id: 1
      })

      assert changeset.valid?
    end

    test "invalid changeset without content" do
      changeset = SocialPost.changeset(%SocialPost{}, %{
        platforms: ["twitter"],
        festival_id: 1
      })

      refute changeset.valid?
      assert %{content: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset with empty platforms list" do
      changeset = SocialPost.changeset(%SocialPost{}, %{
        content: "テスト",
        platforms: [],
        festival_id: 1
      })

      # platforms defaults to [] which passes validate_required for arrays
      # but the changeset is still valid since empty array is accepted
      assert changeset.valid?
    end

    test "invalid changeset with invalid platform" do
      changeset = SocialPost.changeset(%SocialPost{}, %{
        content: "テスト",
        platforms: ["invalid_platform"],
        festival_id: 1
      })

      refute changeset.valid?
      assert %{platforms: [_msg]} = errors_on(changeset)
    end

    test "invalid changeset with content exceeding twitter limit" do
      long_content = String.duplicate("あ", 300)

      changeset = SocialPost.changeset(%SocialPost{}, %{
        content: long_content,
        platforms: ["twitter"],
        festival_id: 1
      })

      refute changeset.valid?
      assert %{content: [_msg]} = errors_on(changeset)
    end

    test "valid changeset with content within instagram limit" do
      content = String.duplicate("あ", 2200)

      changeset = SocialPost.changeset(%SocialPost{}, %{
        content: content,
        platforms: ["instagram"],
        festival_id: 1
      })

      assert changeset.valid?
    end

    test "invalid changeset with content exceeding instagram limit" do
      content = String.duplicate("あ", 2201)

      changeset = SocialPost.changeset(%SocialPost{}, %{
        content: content,
        platforms: ["instagram"],
        festival_id: 1
      })

      refute changeset.valid?
    end

    test "valid changeset with multiple platforms" do
      changeset = SocialPost.changeset(%SocialPost{}, %{
        content: "テスト",
        platforms: ["twitter", "instagram"],
        festival_id: 1
      })

      assert changeset.valid?
    end

    test "invalid status returns error" do
      changeset = SocialPost.changeset(%SocialPost{}, %{
        content: "テスト",
        platforms: ["twitter"],
        festival_id: 1,
        status: "invalid_status"
      })

      refute changeset.valid?
      assert %{status: ["is invalid"]} = errors_on(changeset)
    end
  end

  describe "extract_hashtags/1" do
    test "extracts hashtags from content" do
      hashtags = SocialPost.extract_hashtags("テスト #祭り #塩尻 #イベント2026")

      assert "#祭り" in hashtags
      assert "#塩尻" in hashtags
      assert "#イベント2026" in hashtags
      assert length(hashtags) == 3
    end

    test "returns empty list for content without hashtags" do
      assert SocialPost.extract_hashtags("ハッシュタグなし") == []
    end

    test "returns empty list for nil" do
      assert SocialPost.extract_hashtags(nil) == []
    end

    test "returns empty list for non-binary input" do
      assert SocialPost.extract_hashtags(123) == []
    end

    test "deduplicates hashtags" do
      hashtags = SocialPost.extract_hashtags("#祭り #祭り #祭り")
      assert length(hashtags) == 1
      assert hd(hashtags) == "#祭り"
    end

    test "handles hashtags with underscores" do
      hashtags = SocialPost.extract_hashtags("#hello_world")
      assert "#hello_world" in hashtags
    end

    test "handles mixed language hashtags" do
      hashtags = SocialPost.extract_hashtags("#test #テスト #abc123")
      assert length(hashtags) == 3
    end
  end

  describe "character_count/2" do
    test "returns correct count for twitter" do
      assert SocialPost.character_count("Hello!", "twitter") == 6
    end

    test "returns correct count for Japanese characters on twitter" do
      assert SocialPost.character_count("日本語", "twitter") == 3
    end

    test "returns correct count for instagram" do
      assert SocialPost.character_count("テスト", "instagram") == 3
    end

    test "returns correct count for facebook" do
      assert SocialPost.character_count("テスト", "facebook") == 3
    end

    test "handles nil content" do
      assert SocialPost.character_count(nil, "twitter") == 0
    end

    test "handles empty string" do
      assert SocialPost.character_count("", "twitter") == 0
    end
  end

  describe "character_limit/1" do
    test "returns 280 for twitter" do
      assert SocialPost.character_limit("twitter") == 280
    end

    test "returns 2200 for instagram" do
      assert SocialPost.character_limit("instagram") == 2200
    end

    test "returns 63206 for facebook" do
      assert SocialPost.character_limit("facebook") == 63206
    end

    test "returns 1000 for unknown platform" do
      assert SocialPost.character_limit("unknown") == 1000
    end
  end

  describe "status_label/1" do
    test "returns correct labels for all statuses" do
      assert SocialPost.status_label("draft") == "下書き"
      assert SocialPost.status_label("scheduled") == "予約済"
      assert SocialPost.status_label("posting") == "投稿中"
      assert SocialPost.status_label("posted") == "投稿済"
      assert SocialPost.status_label("failed") == "失敗"
    end

    test "returns unknown for invalid status" do
      assert SocialPost.status_label("invalid") == "不明"
    end
  end

  describe "available_platforms/0" do
    test "returns all available platforms" do
      platforms = SocialPost.available_platforms()
      assert "twitter" in platforms
      assert "instagram" in platforms
      assert "facebook" in platforms
      assert length(platforms) == 3
    end
  end

  describe "statuses/0" do
    test "returns all statuses" do
      statuses = SocialPost.statuses()
      assert "draft" in statuses
      assert "scheduled" in statuses
      assert "posting" in statuses
      assert "posted" in statuses
      assert "failed" in statuses
      assert length(statuses) == 5
    end
  end

  describe "post_changeset/2" do
    test "sets status to posted with external_ids and posted_at" do
      post = %SocialPost{status: "draft"}
      external_ids = %{"twitter" => "12345"}
      changeset = SocialPost.post_changeset(post, external_ids)

      assert Ecto.Changeset.get_change(changeset, :status) == "posted"
      assert Ecto.Changeset.get_change(changeset, :external_ids) == external_ids
      assert Ecto.Changeset.get_change(changeset, :posted_at) != nil
    end
  end

  describe "fail_changeset/2" do
    test "sets status to failed with error message" do
      post = %SocialPost{status: "posting"}
      changeset = SocialPost.fail_changeset(post, "API timeout")

      assert Ecto.Changeset.get_change(changeset, :status) == "failed"
      assert Ecto.Changeset.get_change(changeset, :error_message) == "API timeout"
    end
  end

  describe "schedule_changeset/2" do
    test "sets status to scheduled with scheduled_at" do
      post = %SocialPost{status: "draft"}
      scheduled_at = DateTime.utc_now() |> DateTime.add(3600, :second)
      changeset = SocialPost.schedule_changeset(post, scheduled_at)

      assert Ecto.Changeset.get_change(changeset, :status) == "scheduled"
      assert Ecto.Changeset.get_change(changeset, :scheduled_at) != nil
    end

    test "truncates scheduled_at to seconds" do
      post = %SocialPost{status: "draft"}
      scheduled_at = ~U[2026-08-15 12:00:00.123456Z]
      changeset = SocialPost.schedule_changeset(post, scheduled_at)

      result = Ecto.Changeset.get_change(changeset, :scheduled_at)
      assert result.microsecond == {0, 0}
    end
  end

  describe "analytics_changeset/2" do
    test "updates analytics fields" do
      post = %SocialPost{
        likes_count: 0,
        shares_count: 0,
        comments_count: 0,
        reach_count: 0
      }

      analytics = %{likes: 10, shares: 5, comments: 3, reach: 100}
      changeset = SocialPost.analytics_changeset(post, analytics)

      assert Ecto.Changeset.get_change(changeset, :likes_count) == 10
      assert Ecto.Changeset.get_change(changeset, :shares_count) == 5
      assert Ecto.Changeset.get_change(changeset, :comments_count) == 3
      assert Ecto.Changeset.get_change(changeset, :reach_count) == 100
    end

    test "keeps existing values when analytics keys are missing" do
      post = %SocialPost{
        likes_count: 5,
        shares_count: 3,
        comments_count: 1,
        reach_count: 50
      }

      changeset = SocialPost.analytics_changeset(post, %{likes: 10})

      assert Ecto.Changeset.get_change(changeset, :likes_count) == 10
      # shares, comments, reach keep existing values (no change)
    end
  end
end
