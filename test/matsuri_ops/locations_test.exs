defmodule MatsuriOps.LocationsTest do
  @moduledoc """
  スタッフ位置管理機能のテスト。

  TDDフェーズ: 🔴 RED → 🟢 GREEN
  """

  use MatsuriOps.DataCase

  alias MatsuriOps.Locations
  alias MatsuriOps.Festivals

  import MatsuriOps.AccountsFixtures

  defp create_festival(user) do
    {:ok, festival} =
      Festivals.create_festival(user, %{
        name: "テスト祭り",
        start_date: Date.new!(2025, 8, 1),
        end_date: Date.new!(2025, 8, 2),
        scale: "medium",
        status: "active"
      })

    festival
  end

  describe "StaffLocation" do
    test "スタッフの位置を更新できる" do
      user = user_fixture()
      festival = create_festival(user)

      {:ok, location} =
        Locations.update_staff_location(%{
          user_id: user.id,
          festival_id: festival.id,
          latitude: 36.1234,
          longitude: 138.5678
        })

      assert location.user_id == user.id
      assert location.festival_id == festival.id
      assert location.latitude == 36.1234
      assert location.longitude == 138.5678
    end

    test "同じユーザーの位置を更新すると上書きされる" do
      user = user_fixture()
      festival = create_festival(user)

      {:ok, _} = Locations.update_staff_location(%{
        user_id: user.id,
        festival_id: festival.id,
        latitude: 36.1234,
        longitude: 138.5678
      })

      {:ok, location} = Locations.update_staff_location(%{
        user_id: user.id,
        festival_id: festival.id,
        latitude: 36.9999,
        longitude: 138.9999
      })

      assert location.latitude == 36.9999
      assert location.longitude == 138.9999

      # 1件のみ存在
      locations = Locations.list_staff_locations(festival.id)
      assert length(locations) == 1
    end

    test "祭りのスタッフ位置一覧を取得できる" do
      user1 = user_fixture()
      user2 = user_fixture()
      festival = create_festival(user1)

      {:ok, _} = Locations.update_staff_location(%{user_id: user1.id, festival_id: festival.id, latitude: 36.1, longitude: 138.1})
      {:ok, _} = Locations.update_staff_location(%{user_id: user2.id, festival_id: festival.id, latitude: 36.2, longitude: 138.2})

      locations = Locations.list_staff_locations(festival.id)
      assert length(locations) == 2
    end

    test "古い位置情報は除外できる" do
      user1 = user_fixture()
      user2 = user_fixture()
      festival = create_festival(user1)

      # user1の位置を登録（最新）
      {:ok, _} = Locations.update_staff_location(%{user_id: user1.id, festival_id: festival.id, latitude: 36.1, longitude: 138.1})

      # user2の位置を古い時刻で登録
      {:ok, old_location} = Locations.update_staff_location(%{user_id: user2.id, festival_id: festival.id, latitude: 36.2, longitude: 138.2})

      # 直接DBで古い時刻に更新
      old_time = DateTime.utc_now() |> DateTime.add(-3600, :second) |> DateTime.truncate(:second)
      Ecto.Changeset.change(old_location, %{updated_at: old_time})
      |> MatsuriOps.Repo.update!()

      # 30分以内の位置のみ取得
      locations = Locations.list_staff_locations(festival.id, within_minutes: 30)
      assert length(locations) == 1
    end
  end

  describe "broadcast (リアルタイム通知)" do
    test "位置更新時にPubSubでブロードキャストされる" do
      user = user_fixture()
      festival = create_festival(user)

      Locations.subscribe(festival.id)

      {:ok, location} = Locations.update_staff_location(%{
        user_id: user.id,
        festival_id: festival.id,
        latitude: 36.1234,
        longitude: 138.5678
      })

      assert_receive {:location_updated, ^location}
    end
  end

  describe "get_staff_location/2" do
    test "特定ユーザーの位置を取得できる" do
      user = user_fixture()
      festival = create_festival(user)

      {:ok, _} = Locations.update_staff_location(%{user_id: user.id, festival_id: festival.id, latitude: 36.1, longitude: 138.1})

      location = Locations.get_staff_location(festival.id, user.id)
      assert location.latitude == 36.1
    end

    test "位置が未登録の場合はnilを返す" do
      user = user_fixture()
      festival = create_festival(user)

      location = Locations.get_staff_location(festival.id, user.id)
      assert is_nil(location)
    end
  end
end
