defmodule MatsuriOps.AdvertisingTest do
  use MatsuriOps.DataCase, async: true

  alias MatsuriOps.Advertising
  alias MatsuriOps.Advertising.AdBanner

  describe "ad_banners" do
    setup do
      festival = festival_fixture()
      sponsor = sponsor_fixture()
      %{festival: festival, sponsor: sponsor}
    end

    @valid_attrs %{
      name: "テスト広告バナー",
      position: "sidebar",
      link_url: "https://example.com",
      display_weight: 10
    }
    @update_attrs %{
      name: "更新された広告バナー",
      position: "header",
      link_url: "https://example.com/updated",
      display_weight: 50
    }
    @invalid_attrs %{name: nil, position: nil}

    def ad_banner_fixture(festival, sponsor \\ nil, attrs \\ %{}) do
      {:ok, ad_banner} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put(:festival_id, festival.id)
        |> then(fn attrs ->
          if sponsor, do: Map.put(attrs, :sponsor_id, sponsor.id), else: attrs
        end)
        |> Advertising.create_ad_banner()

      ad_banner
    end

    test "list_ad_banners/1 returns all ad_banners for a festival", %{festival: festival, sponsor: sponsor} do
      ad_banner = ad_banner_fixture(festival, sponsor)
      banners = Advertising.list_ad_banners(festival.id)
      assert length(banners) == 1
      assert hd(banners).id == ad_banner.id
    end

    test "list_ad_banners/1 returns empty list for festival with no ad_banners", %{festival: _festival} do
      other_festival = festival_fixture(%{name: "別の祭り"})
      assert Advertising.list_ad_banners(other_festival.id) == []
    end

    test "list_active_banners/1 returns only active banners within date range", %{festival: festival} do
      _active = ad_banner_fixture(festival, nil, %{is_active: true})
      _inactive = ad_banner_fixture(festival, nil, %{name: "無効バナー", is_active: false})

      banners = Advertising.list_active_banners(festival.id)
      assert length(banners) == 1
    end

    test "list_active_banners_by_position/2 filters by position", %{festival: festival} do
      ad_banner_fixture(festival, nil, %{position: "sidebar"})
      ad_banner_fixture(festival, nil, %{name: "ヘッダーバナー", position: "header"})

      sidebar_banners = Advertising.list_active_banners_by_position(festival.id, "sidebar")
      assert length(sidebar_banners) == 1
      assert hd(sidebar_banners).position == "sidebar"
    end

    test "list_banners_by_sponsor/1 returns banners for a sponsor", %{festival: festival, sponsor: sponsor} do
      ad_banner_fixture(festival, sponsor)
      ad_banner_fixture(festival, nil, %{name: "スポンサーなし"})

      banners = Advertising.list_banners_by_sponsor(sponsor.id)
      assert length(banners) == 1
    end

    test "get_ad_banner!/1 returns the ad_banner with given id", %{festival: festival} do
      ad_banner = ad_banner_fixture(festival)
      found = Advertising.get_ad_banner!(ad_banner.id)
      assert found.id == ad_banner.id
    end

    test "get_ad_banner!/1 raises for non-existent id" do
      assert_raise Ecto.NoResultsError, fn ->
        Advertising.get_ad_banner!(999_999)
      end
    end

    test "get_ad_banner/1 returns the ad_banner", %{festival: festival} do
      ad_banner = ad_banner_fixture(festival)
      found = Advertising.get_ad_banner(ad_banner.id)
      assert found.id == ad_banner.id
    end

    test "get_ad_banner/1 returns nil for non-existent id" do
      assert Advertising.get_ad_banner(999_999) == nil
    end

    test "create_ad_banner/1 with valid data creates an ad_banner", %{festival: festival} do
      attrs = Map.put(@valid_attrs, :festival_id, festival.id)
      assert {:ok, %AdBanner{} = ad_banner} = Advertising.create_ad_banner(attrs)
      assert ad_banner.name == "テスト広告バナー"
      assert ad_banner.position == "sidebar"
      assert ad_banner.click_count == 0
      assert ad_banner.impression_count == 0
    end

    test "create_ad_banner/1 with invalid data returns error changeset", %{festival: festival} do
      attrs = Map.put(@invalid_attrs, :festival_id, festival.id)
      assert {:error, %Ecto.Changeset{}} = Advertising.create_ad_banner(attrs)
    end

    test "create_ad_banner/1 with invalid position returns error changeset", %{festival: festival} do
      attrs =
        @valid_attrs
        |> Map.put(:festival_id, festival.id)
        |> Map.put(:position, "invalid_position")

      assert {:error, %Ecto.Changeset{} = changeset} = Advertising.create_ad_banner(attrs)
      assert %{position: ["is invalid"]} = errors_on(changeset)
    end

    test "create_ad_banner/1 with invalid url returns error changeset", %{festival: festival} do
      attrs =
        @valid_attrs
        |> Map.put(:festival_id, festival.id)
        |> Map.put(:link_url, "not-a-url")

      assert {:error, %Ecto.Changeset{} = changeset} = Advertising.create_ad_banner(attrs)
      assert %{link_url: ["有効なURLを入力してください"]} = errors_on(changeset)
    end

    test "create_ad_banner/1 with invalid display_weight returns error", %{festival: festival} do
      attrs =
        @valid_attrs
        |> Map.put(:festival_id, festival.id)
        |> Map.put(:display_weight, 0)

      assert {:error, %Ecto.Changeset{}} = Advertising.create_ad_banner(attrs)
    end

    test "create_ad_banner/1 with display_weight over 100 returns error", %{festival: festival} do
      attrs =
        @valid_attrs
        |> Map.put(:festival_id, festival.id)
        |> Map.put(:display_weight, 101)

      assert {:error, %Ecto.Changeset{}} = Advertising.create_ad_banner(attrs)
    end

    test "create_ad_banner/1 with end_date before start_date returns error", %{festival: festival} do
      attrs =
        @valid_attrs
        |> Map.put(:festival_id, festival.id)
        |> Map.put(:start_date, ~D[2026-08-20])
        |> Map.put(:end_date, ~D[2026-08-10])

      assert {:error, %Ecto.Changeset{} = changeset} = Advertising.create_ad_banner(attrs)
      assert %{end_date: [_msg]} = errors_on(changeset)
    end

    test "update_ad_banner/2 with valid data updates the ad_banner", %{festival: festival} do
      ad_banner = ad_banner_fixture(festival)
      assert {:ok, %AdBanner{} = updated} = Advertising.update_ad_banner(ad_banner, @update_attrs)
      assert updated.name == "更新された広告バナー"
      assert updated.position == "header"
      assert updated.display_weight == 50
    end

    test "update_ad_banner/2 with invalid data returns error changeset", %{festival: festival} do
      ad_banner = ad_banner_fixture(festival)
      assert {:error, %Ecto.Changeset{}} = Advertising.update_ad_banner(ad_banner, @invalid_attrs)
    end

    test "delete_ad_banner/1 deletes the ad_banner", %{festival: festival} do
      ad_banner = ad_banner_fixture(festival)
      assert {:ok, %AdBanner{}} = Advertising.delete_ad_banner(ad_banner)
      assert_raise Ecto.NoResultsError, fn -> Advertising.get_ad_banner!(ad_banner.id) end
    end

    test "change_ad_banner/1 returns an ad_banner changeset", %{festival: festival} do
      ad_banner = ad_banner_fixture(festival)
      assert %Ecto.Changeset{} = Advertising.change_ad_banner(ad_banner)
    end

    test "change_ad_banner/2 with attrs returns a changeset", %{festival: festival} do
      ad_banner = ad_banner_fixture(festival)
      changeset = Advertising.change_ad_banner(ad_banner, %{name: "新名前"})
      assert %Ecto.Changeset{} = changeset
    end

    test "increment_click/1 increments the click count", %{festival: festival} do
      ad_banner = ad_banner_fixture(festival)
      assert ad_banner.click_count == 0

      {:ok, updated} = Advertising.increment_click(ad_banner)
      assert updated.click_count == 1

      {:ok, updated2} = Advertising.increment_click(updated)
      assert updated2.click_count == 2
    end

    test "increment_click/1 with id increments the click count", %{festival: festival} do
      ad_banner = ad_banner_fixture(festival)
      {:ok, updated} = Advertising.increment_click(ad_banner.id)
      assert updated.click_count == 1
    end

    test "increment_click/1 with invalid id returns error" do
      assert {:error, :not_found} = Advertising.increment_click(999_999)
    end

    test "increment_impression/1 increments the impression count", %{festival: festival} do
      ad_banner = ad_banner_fixture(festival)
      assert ad_banner.impression_count == 0

      {:ok, updated} = Advertising.increment_impression(ad_banner)
      assert updated.impression_count == 1
    end

    test "toggle_active/1 toggles the is_active status", %{festival: festival} do
      ad_banner = ad_banner_fixture(festival, nil, %{is_active: true})
      assert ad_banner.is_active == true

      {:ok, updated} = Advertising.toggle_active(ad_banner)
      assert updated.is_active == false

      {:ok, updated2} = Advertising.toggle_active(updated)
      assert updated2.is_active == true
    end

    test "get_statistics/1 returns statistics for a festival", %{festival: festival} do
      ad_banner_fixture(festival, nil, %{position: "sidebar"})
      ad_banner_fixture(festival, nil, %{name: "バナー2", position: "sidebar"})
      ad_banner_fixture(festival, nil, %{name: "バナー3", position: "header"})

      stats = Advertising.get_statistics(festival.id)
      assert stats.total_count == 3
      assert stats.active_count == 3
      assert stats.by_position["sidebar"] == 2
      assert stats.by_position["header"] == 1
    end

    test "get_statistics/1 returns zeros for empty festival" do
      festival = festival_fixture(%{name: "空の祭り"})
      stats = Advertising.get_statistics(festival.id)
      assert stats.total_count == 0
      assert stats.active_count == 0
      assert stats.total_clicks == 0
      assert stats.total_impressions == 0
    end

    test "calculate_ctr/1 calculates click-through rate", %{festival: festival} do
      ad_banner = ad_banner_fixture(festival)

      assert Advertising.calculate_ctr(ad_banner) == 0.0

      {:ok, updated} = Advertising.increment_impression(ad_banner)
      {:ok, updated} = Advertising.increment_impression(updated)
      {:ok, updated} = Advertising.increment_impression(updated)
      {:ok, updated} = Advertising.increment_impression(updated)
      {:ok, updated} = Advertising.increment_impression(updated)
      {:ok, updated} = Advertising.increment_impression(updated)
      {:ok, updated} = Advertising.increment_impression(updated)
      {:ok, updated} = Advertising.increment_impression(updated)
      {:ok, updated} = Advertising.increment_impression(updated)
      {:ok, updated} = Advertising.increment_impression(updated)

      {:ok, updated} = Advertising.increment_click(updated)
      {:ok, updated} = Advertising.increment_click(updated)

      # 2 / 10 * 100 = 20.0%
      assert Advertising.calculate_ctr(updated) == 20.0
    end

    test "select_weighted_banner/1 selects a banner based on weight", %{festival: festival} do
      banner1 = ad_banner_fixture(festival, nil, %{display_weight: 90})
      banner2 = ad_banner_fixture(festival, nil, %{name: "バナー2", display_weight: 10})

      banners = [banner1, banner2]
      selected = Advertising.select_weighted_banner(banners)

      assert selected in banners
    end

    test "select_weighted_banner/1 returns nil for empty list", %{festival: _festival} do
      assert Advertising.select_weighted_banner([]) == nil
    end

    test "select_weighted_banner/1 returns the only banner when list has one", %{festival: festival} do
      banner = ad_banner_fixture(festival, nil, %{display_weight: 50})
      assert Advertising.select_weighted_banner([banner]).id == banner.id
    end
  end

  describe "AdBanner schema" do
    test "positions/0 returns valid positions" do
      positions = AdBanner.positions()
      assert "header" in positions
      assert "sidebar" in positions
      assert "footer" in positions
      assert "popup" in positions
    end

    test "position_label/1 returns correct labels" do
      assert AdBanner.position_label("header") == "ヘッダー"
      assert AdBanner.position_label("sidebar") == "サイドバー"
      assert AdBanner.position_label("footer") == "フッター"
      assert AdBanner.position_label("popup") == "ポップアップ"
      assert AdBanner.position_label("unknown") == "不明"
    end

    test "increment_click_changeset/1 increments click_count" do
      banner = %AdBanner{click_count: 5}
      changeset = AdBanner.increment_click_changeset(banner)
      assert Ecto.Changeset.get_change(changeset, :click_count) == 6
    end

    test "increment_impression_changeset/1 increments impression_count" do
      banner = %AdBanner{impression_count: 10}
      changeset = AdBanner.increment_impression_changeset(banner)
      assert Ecto.Changeset.get_change(changeset, :impression_count) == 11
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

  defp sponsor_fixture(attrs \\ %{}) do
    {:ok, sponsor} =
      attrs
      |> Enum.into(%{
        name: "テストスポンサー #{System.unique_integer()}"
      })
      |> MatsuriOps.Sponsorships.create_sponsor()

    sponsor
  end
end
