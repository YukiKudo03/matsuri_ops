defmodule MatsuriOps.SocialMedia.SocialAccountTest do
  use MatsuriOps.DataCase, async: true

  alias MatsuriOps.SocialMedia.SocialAccount

  describe "changeset/2" do
    test "valid changeset with required fields" do
      changeset = SocialAccount.changeset(%SocialAccount{}, %{
        platform: "twitter",
        account_name: "test_account",
        festival_id: 1
      })

      assert changeset.valid?
    end

    test "invalid changeset without platform" do
      changeset = SocialAccount.changeset(%SocialAccount{}, %{
        account_name: "test_account",
        festival_id: 1
      })

      refute changeset.valid?
      assert %{platform: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset without account_name" do
      changeset = SocialAccount.changeset(%SocialAccount{}, %{
        platform: "twitter",
        festival_id: 1
      })

      refute changeset.valid?
      assert %{account_name: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset without festival_id" do
      changeset = SocialAccount.changeset(%SocialAccount{}, %{
        platform: "twitter",
        account_name: "test"
      })

      refute changeset.valid?
      assert %{festival_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset with invalid platform" do
      changeset = SocialAccount.changeset(%SocialAccount{}, %{
        platform: "invalid",
        account_name: "test",
        festival_id: 1
      })

      refute changeset.valid?
      assert %{platform: ["is invalid"]} = errors_on(changeset)
    end

    test "valid changeset with all optional fields" do
      changeset = SocialAccount.changeset(%SocialAccount{}, %{
        platform: "twitter",
        account_name: "test",
        festival_id: 1,
        account_id: "12345",
        access_token: "token123",
        refresh_token: "refresh123",
        expires_at: DateTime.utc_now(),
        is_active: true
      })

      assert changeset.valid?
    end
  end

  describe "platforms/0" do
    test "returns all available platforms" do
      platforms = SocialAccount.platforms()
      assert "twitter" in platforms
      assert "instagram" in platforms
      assert "facebook" in platforms
      assert length(platforms) == 3
    end
  end

  describe "platform_label/1" do
    test "returns correct label for twitter" do
      assert SocialAccount.platform_label("twitter") == "X (Twitter)"
    end

    test "returns correct label for instagram" do
      assert SocialAccount.platform_label("instagram") == "Instagram"
    end

    test "returns correct label for facebook" do
      assert SocialAccount.platform_label("facebook") == "Facebook"
    end

    test "returns unknown for invalid platform" do
      assert SocialAccount.platform_label("invalid") == "不明"
    end
  end

  describe "platform_color/1" do
    test "returns correct color for twitter" do
      assert SocialAccount.platform_color("twitter") == "bg-black"
    end

    test "returns correct color for instagram" do
      color = SocialAccount.platform_color("instagram")
      assert String.contains?(color, "purple")
    end

    test "returns correct color for facebook" do
      assert SocialAccount.platform_color("facebook") == "bg-blue-600"
    end

    test "returns gray for unknown platform" do
      assert SocialAccount.platform_color("unknown") == "bg-gray-500"
    end
  end

  describe "token_valid?/1" do
    test "returns true when expires_at is nil" do
      account = %SocialAccount{expires_at: nil}
      assert SocialAccount.token_valid?(account) == true
    end

    test "returns true when expires_at is in the future" do
      future = DateTime.utc_now() |> DateTime.add(3600, :second)
      account = %SocialAccount{expires_at: future}
      assert SocialAccount.token_valid?(account) == true
    end

    test "returns false when expires_at is in the past" do
      past = DateTime.utc_now() |> DateTime.add(-3600, :second)
      account = %SocialAccount{expires_at: past}
      assert SocialAccount.token_valid?(account) == false
    end
  end
end
