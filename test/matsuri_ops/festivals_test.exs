defmodule MatsuriOps.FestivalsTest do
  use MatsuriOps.DataCase, async: true

  alias MatsuriOps.Festivals
  alias MatsuriOps.Festivals.{Festival, FestivalMember}

  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures

  describe "festivals" do
    setup do
      user = user_fixture()
      %{user: user}
    end

    test "list_festivals/0 returns all festivals", %{user: user} do
      festival = festival_fixture(user)
      all_festivals = Festivals.list_festivals()
      assert Enum.any?(all_festivals, fn f -> f.id == festival.id end)
    end

    test "list_festivals_by_status/1 returns festivals with given status", %{user: user} do
      planning = festival_fixture(user, %{status: "planning"})
      active = festival_fixture(user, %{status: "active"})

      planning_results = Festivals.list_festivals_by_status("planning")
      active_results = Festivals.list_festivals_by_status("active")

      assert Enum.any?(planning_results, fn f -> f.id == planning.id end)
      assert Enum.any?(active_results, fn f -> f.id == active.id end)
      refute Enum.any?(planning_results, fn f -> f.id == active.id end)
    end

    test "list_user_festivals/1 returns festivals for a specific user", %{user: user} do
      festival = festival_fixture(user)
      other_user = user_fixture()
      _other_festival = festival_fixture(other_user)

      result = Festivals.list_user_festivals(user)
      assert length(result) == 1
      assert hd(result).id == festival.id
    end

    test "get_festival!/1 returns the festival with given id", %{user: user} do
      festival = festival_fixture(user)
      assert Festivals.get_festival!(festival.id) == festival
    end

    test "get_festival/1 returns the festival with given id", %{user: user} do
      festival = festival_fixture(user)
      assert Festivals.get_festival(festival.id) == festival
    end

    test "get_festival/1 returns nil for non-existent id" do
      assert Festivals.get_festival(-1) == nil
    end

    test "get_festival_with_members!/1 returns festival with preloaded members", %{user: user} do
      festival = festival_fixture(user)
      member_user = user_fixture()
      _member = festival_member_fixture(festival, member_user)

      result = Festivals.get_festival_with_members!(festival.id)
      assert result.id == festival.id
      assert length(result.festival_members) == 1
      assert hd(result.festival_members).user.id == member_user.id
    end

    test "create_festival/1 with valid data creates a festival" do
      valid_attrs = %{
        name: "新しい祭り",
        start_date: ~D[2025-08-01],
        end_date: ~D[2025-08-02],
        status: "planning",
        scale: "medium"
      }

      assert {:ok, %Festival{} = festival} = Festivals.create_festival(valid_attrs)
      assert festival.name == "新しい祭り"
      assert festival.status == "planning"
    end

    test "create_festival/2 with user creates a festival with organizer", %{user: user} do
      valid_attrs = %{
        name: "ユーザー作成祭り",
        start_date: ~D[2025-08-01],
        end_date: ~D[2025-08-02],
        status: "planning",
        scale: "small"
      }

      assert {:ok, %Festival{} = festival} = Festivals.create_festival(user, valid_attrs)
      assert festival.name == "ユーザー作成祭り"
      assert festival.organizer_id == user.id
    end

    test "create_festival/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Festivals.create_festival(%{name: nil})
    end

    test "update_festival/2 with valid data updates the festival", %{user: user} do
      festival = festival_fixture(user)
      update_attrs = %{name: "更新された祭り"}

      assert {:ok, %Festival{} = updated} = Festivals.update_festival(festival, update_attrs)
      assert updated.name == "更新された祭り"
    end

    test "delete_festival/1 deletes the festival", %{user: user} do
      festival = festival_fixture(user)
      assert {:ok, %Festival{}} = Festivals.delete_festival(festival)
      assert_raise Ecto.NoResultsError, fn -> Festivals.get_festival!(festival.id) end
    end

    test "change_festival/1 returns a festival changeset", %{user: user} do
      festival = festival_fixture(user)
      assert %Ecto.Changeset{} = Festivals.change_festival(festival)
    end
  end

  describe "festival_members" do
    setup do
      user = user_fixture()
      festival = festival_fixture(user)
      member_user = user_fixture()
      %{user: user, festival: festival, member_user: member_user}
    end

    test "list_festival_members/1 returns all members for a festival", %{
      festival: festival,
      member_user: member_user
    } do
      _member = festival_member_fixture(festival, member_user)

      result = Festivals.list_festival_members(festival.id)
      assert length(result) == 1
      assert hd(result).user_id == member_user.id
    end

    test "get_festival_member!/1 returns the member with given id", %{
      festival: festival,
      member_user: member_user
    } do
      member = festival_member_fixture(festival, member_user)
      assert Festivals.get_festival_member!(member.id).id == member.id
    end

    test "get_festival_member/2 returns the member by festival and user", %{
      festival: festival,
      member_user: member_user
    } do
      _member = festival_member_fixture(festival, member_user)
      result = Festivals.get_festival_member(festival.id, member_user.id)
      assert result.user_id == member_user.id
    end

    test "get_festival_member/2 returns nil for non-existent member", %{festival: festival} do
      assert Festivals.get_festival_member(festival.id, -1) == nil
    end

    test "add_member_to_festival/1 with valid data adds a member", %{
      festival: festival,
      member_user: member_user
    } do
      attrs = %{festival_id: festival.id, user_id: member_user.id, role: "leader"}

      assert {:ok, %FestivalMember{} = member} = Festivals.add_member_to_festival(attrs)
      assert member.role == "leader"
    end

    test "update_festival_member/2 updates the member", %{
      festival: festival,
      member_user: member_user
    } do
      member = festival_member_fixture(festival, member_user, %{role: "staff"})

      assert {:ok, %FestivalMember{} = updated} =
               Festivals.update_festival_member(member, %{role: "leader"})

      assert updated.role == "leader"
    end

    test "remove_member_from_festival/1 removes the member", %{
      festival: festival,
      member_user: member_user
    } do
      member = festival_member_fixture(festival, member_user)

      assert {:ok, %FestivalMember{}} = Festivals.remove_member_from_festival(member)
      assert Festivals.get_festival_member(festival.id, member_user.id) == nil
    end

    test "member_of_festival?/2 returns true when user is member", %{
      festival: festival,
      member_user: member_user
    } do
      _member = festival_member_fixture(festival, member_user)
      assert Festivals.member_of_festival?(festival.id, member_user.id) == true
    end

    test "member_of_festival?/2 returns false when user is not member", %{festival: festival} do
      assert Festivals.member_of_festival?(festival.id, -1) == false
    end

    test "change_festival_member/1 returns a changeset", %{
      festival: festival,
      member_user: member_user
    } do
      member = festival_member_fixture(festival, member_user)
      assert %Ecto.Changeset{} = Festivals.change_festival_member(member)
    end
  end
end
