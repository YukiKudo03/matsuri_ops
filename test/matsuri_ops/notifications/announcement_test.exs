defmodule MatsuriOps.Notifications.AnnouncementTest do
  use MatsuriOps.DataCase, async: true

  alias MatsuriOps.Notifications.Announcement

  describe "changeset/2" do
    test "valid changeset with required fields" do
      changeset = Announcement.changeset(%Announcement{}, %{
        title: "テストお知らせ",
        content: "内容です",
        festival_id: 1
      })

      assert changeset.valid?
    end

    test "invalid changeset without title" do
      changeset = Announcement.changeset(%Announcement{}, %{content: "内容", festival_id: 1})
      refute changeset.valid?
      assert %{title: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset without content" do
      changeset = Announcement.changeset(%Announcement{}, %{title: "タイトル", festival_id: 1})
      refute changeset.valid?
      assert %{content: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset with invalid priority" do
      changeset = Announcement.changeset(%Announcement{}, %{
        title: "お知らせ",
        content: "内容",
        festival_id: 1,
        priority: "invalid"
      })

      refute changeset.valid?
    end

    test "invalid changeset with invalid target_audience" do
      changeset = Announcement.changeset(%Announcement{}, %{
        title: "お知らせ",
        content: "内容",
        festival_id: 1,
        target_audience: "invalid"
      })

      refute changeset.valid?
    end

    test "valid changeset with all fields" do
      changeset = Announcement.changeset(%Announcement{}, %{
        title: "緊急お知らせ",
        content: "重要な内容",
        priority: "urgent",
        target_audience: "staff",
        expires_at: DateTime.utc_now() |> DateTime.add(3600),
        festival_id: 1,
        created_by_id: 1
      })

      assert changeset.valid?
    end
  end

  describe "priorities/0" do
    test "returns all valid priorities" do
      priorities = Announcement.priorities()
      assert "low" in priorities
      assert "normal" in priorities
      assert "high" in priorities
      assert "urgent" in priorities
    end
  end

  describe "target_audiences/0" do
    test "returns all valid target audiences" do
      audiences = Announcement.target_audiences()
      assert "all" in audiences
      assert "staff" in audiences
      assert "admin" in audiences
    end
  end
end
