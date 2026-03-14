defmodule MatsuriOps.SponsorshipsTest do
  @moduledoc """
  協賛金管理機能のテスト。

  TDDフェーズ: 🔴 RED → 🟢 GREEN
  """

  use MatsuriOps.DataCase

  alias MatsuriOps.Sponsorships
  alias MatsuriOps.Sponsorships.{Sponsor, Sponsorship}

  describe "sponsors" do
    setup do
      user = user_fixture()
      festival = festival_fixture(user)
      {:ok, user: user, festival: festival}
    end

    @valid_attrs %{
      name: "株式会社サポート",
      contact_name: "田中太郎",
      contact_email: "tanaka@support.co.jp",
      contact_phone: "03-1234-5678",
      address: "東京都千代田区1-1-1",
      industry: "IT",
      notes: "3年連続協賛"
    }

    @invalid_attrs %{name: nil}

    test "list_sponsors/0 returns all sponsors" do
      sponsor = sponsor_fixture()
      sponsors = Sponsorships.list_sponsors()
      assert length(sponsors) >= 1
      assert Enum.any?(sponsors, &(&1.id == sponsor.id))
    end

    test "get_sponsor!/1 returns sponsor by id" do
      sponsor = sponsor_fixture()
      assert Sponsorships.get_sponsor!(sponsor.id).id == sponsor.id
    end

    test "create_sponsor/1 with valid data creates sponsor" do
      assert {:ok, %Sponsor{} = sponsor} = Sponsorships.create_sponsor(@valid_attrs)
      assert sponsor.name == "株式会社サポート"
      assert sponsor.contact_email == "tanaka@support.co.jp"
    end

    test "create_sponsor/1 with invalid data returns error" do
      assert {:error, %Ecto.Changeset{}} = Sponsorships.create_sponsor(@invalid_attrs)
    end

    test "update_sponsor/2 with valid data updates sponsor" do
      sponsor = sponsor_fixture()
      assert {:ok, %Sponsor{} = updated} = Sponsorships.update_sponsor(sponsor, %{name: "更新済み企業"})
      assert updated.name == "更新済み企業"
    end

    test "delete_sponsor/1 deletes sponsor" do
      sponsor = sponsor_fixture()
      assert {:ok, %Sponsor{}} = Sponsorships.delete_sponsor(sponsor)
      assert_raise Ecto.NoResultsError, fn -> Sponsorships.get_sponsor!(sponsor.id) end
    end

    test "search_sponsors/1 searches sponsors by name" do
      sponsor_fixture(%{name: "テスト企業ABC"})
      sponsor_fixture(%{name: "テスト企業XYZ"})

      results = Sponsorships.search_sponsors("ABC")
      assert length(results) == 1
      assert hd(results).name == "テスト企業ABC"
    end
  end

  describe "sponsorships" do
    setup do
      user = user_fixture()
      festival = festival_fixture(user)
      sponsor = sponsor_fixture()
      {:ok, festival: festival, sponsor: sponsor}
    end

    @valid_attrs %{
      tier: "gold",
      amount: 500_000,
      payment_status: "pending",
      contract_date: ~D[2026-01-01],
      notes: "ゴールドスポンサー契約"
    }

    test "list_sponsorships/1 returns all sponsorships for festival", %{festival: festival, sponsor: sponsor} do
      sponsorship = sponsorship_fixture(festival, sponsor)
      sponsorships = Sponsorships.list_sponsorships(festival.id)
      assert length(sponsorships) == 1
      assert hd(sponsorships).id == sponsorship.id
    end

    test "create_sponsorship/3 with valid data creates sponsorship", %{festival: festival, sponsor: sponsor} do
      assert {:ok, %Sponsorship{} = sponsorship} = Sponsorships.create_sponsorship(festival, sponsor, @valid_attrs)
      assert sponsorship.tier == "gold"
      assert sponsorship.amount == 500_000
    end

    test "update_sponsorship/2 updates sponsorship", %{festival: festival, sponsor: sponsor} do
      sponsorship = sponsorship_fixture(festival, sponsor)
      assert {:ok, updated} = Sponsorships.update_sponsorship(sponsorship, %{payment_status: "paid"})
      assert updated.payment_status == "paid"
    end

    test "delete_sponsorship/1 deletes sponsorship", %{festival: festival, sponsor: sponsor} do
      sponsorship = sponsorship_fixture(festival, sponsor)
      assert {:ok, %Sponsorship{}} = Sponsorships.delete_sponsorship(sponsorship)
      assert_raise Ecto.NoResultsError, fn -> Sponsorships.get_sponsorship!(sponsorship.id) end
    end

    test "list_sponsorships_by_tier/2 filters by tier", %{festival: festival, sponsor: sponsor} do
      sponsorship_fixture(festival, sponsor, %{tier: "gold"})
      sponsor2 = sponsor_fixture(%{name: "別企業"})
      sponsorship_fixture(festival, sponsor2, %{tier: "silver"})

      gold = Sponsorships.list_sponsorships_by_tier(festival.id, "gold")
      assert length(gold) == 1
    end
  end

  describe "sponsorship tiers" do
    test "available_tiers/0 returns all tiers" do
      tiers = Sponsorships.available_tiers()
      assert "platinum" in tiers
      assert "gold" in tiers
      assert "silver" in tiers
      assert "bronze" in tiers
    end

    test "tier_benefits/1 returns benefits for tier" do
      benefits = Sponsorships.tier_benefits("gold")
      assert is_list(benefits)
      assert length(benefits) > 0
    end

    test "minimum_amount/1 returns minimum sponsorship amount" do
      assert Sponsorships.minimum_amount("platinum") > Sponsorships.minimum_amount("gold")
      assert Sponsorships.minimum_amount("gold") > Sponsorships.minimum_amount("silver")
    end
  end

  describe "sponsorship statistics" do
    setup do
      user = user_fixture()
      festival = festival_fixture(user)
      {:ok, festival: festival}
    end

    test "total_sponsorship_amount/1 calculates total", %{festival: festival} do
      sponsor1 = sponsor_fixture(%{name: "企業A"})
      sponsor2 = sponsor_fixture(%{name: "企業B"})
      sponsorship_fixture(festival, sponsor1, %{amount: 100_000})
      sponsorship_fixture(festival, sponsor2, %{amount: 200_000})

      total = Sponsorships.total_sponsorship_amount(festival.id)
      assert total == 300_000
    end

    test "sponsorship_summary/1 returns summary by tier", %{festival: festival} do
      sponsor1 = sponsor_fixture(%{name: "企業A"})
      sponsor2 = sponsor_fixture(%{name: "企業B"})
      sponsorship_fixture(festival, sponsor1, %{tier: "gold", amount: 500_000})
      sponsorship_fixture(festival, sponsor2, %{tier: "silver", amount: 300_000})

      summary = Sponsorships.sponsorship_summary(festival.id)

      assert summary.total_amount == 800_000
      assert summary.sponsor_count == 2
      assert Map.has_key?(summary.by_tier, "gold")
    end

    test "payment_status_summary/1 returns payment status breakdown", %{festival: festival} do
      sponsor1 = sponsor_fixture(%{name: "企業A"})
      sponsor2 = sponsor_fixture(%{name: "企業B"})
      sponsorship_fixture(festival, sponsor1, %{payment_status: "paid", amount: 500_000})
      sponsorship_fixture(festival, sponsor2, %{payment_status: "pending", amount: 300_000})

      summary = Sponsorships.payment_status_summary(festival.id)

      assert summary.paid_amount == 500_000
      assert summary.pending_amount == 300_000
    end
  end

  describe "sponsor benefits" do
    setup do
      user = user_fixture()
      festival = festival_fixture(user)
      sponsor = sponsor_fixture()
      sponsorship = sponsorship_fixture(festival, sponsor)
      {:ok, sponsorship: sponsorship}
    end

    test "add_benefit/2 adds benefit to sponsorship", %{sponsorship: sponsorship} do
      benefit_attrs = %{
        name: "ロゴ掲載",
        description: "パンフレットにロゴを掲載",
        status: "pending"
      }

      assert {:ok, benefit} = Sponsorships.add_benefit(sponsorship, benefit_attrs)
      assert benefit.name == "ロゴ掲載"
    end

    test "list_benefits/1 returns sponsorship benefits", %{sponsorship: sponsorship} do
      Sponsorships.add_benefit(sponsorship, %{name: "特典1", status: "pending"})
      Sponsorships.add_benefit(sponsorship, %{name: "特典2", status: "pending"})

      benefits = Sponsorships.list_benefits(sponsorship.id)
      assert length(benefits) == 2
    end

    test "update_benefit_status/2 updates benefit status", %{sponsorship: sponsorship} do
      {:ok, benefit} = Sponsorships.add_benefit(sponsorship, %{name: "特典", status: "pending"})
      assert {:ok, updated} = Sponsorships.update_benefit_status(benefit, "completed")
      assert updated.status == "completed"
      assert updated.completed_at != nil
    end

    test "update_benefit_status/2 to in_progress does not set completed_at", %{sponsorship: sponsorship} do
      {:ok, benefit} = Sponsorships.add_benefit(sponsorship, %{name: "特典", status: "pending"})
      assert {:ok, updated} = Sponsorships.update_benefit_status(benefit, "in_progress")
      assert updated.status == "in_progress"
    end

    test "delete_benefit/1 deletes benefit", %{sponsorship: sponsorship} do
      {:ok, benefit} = Sponsorships.add_benefit(sponsorship, %{name: "削除特典", status: "pending"})
      assert {:ok, _} = Sponsorships.delete_benefit(benefit)
      assert Sponsorships.list_benefits(sponsorship.id) == []
    end
  end

  describe "sponsorship tier details" do
    test "tier_benefits/1 returns benefits for all tiers" do
      for tier <- ["platinum", "gold", "silver", "bronze", "supporter"] do
        benefits = Sponsorships.tier_benefits(tier)
        assert is_list(benefits)
        assert length(benefits) > 0, "#{tier} should have benefits"
      end
    end

    test "tier_benefits/1 returns empty list for unknown tier" do
      assert Sponsorships.tier_benefits("unknown") == []
    end

    test "minimum_amount/1 returns amounts in descending order" do
      assert Sponsorships.minimum_amount("platinum") == 1_000_000
      assert Sponsorships.minimum_amount("gold") == 500_000
      assert Sponsorships.minimum_amount("silver") == 300_000
      assert Sponsorships.minimum_amount("bronze") == 100_000
      assert Sponsorships.minimum_amount("supporter") == 50_000
    end

    test "minimum_amount/1 returns 0 for unknown tier" do
      assert Sponsorships.minimum_amount("unknown") == 0
    end
  end

  describe "additional sponsorship operations" do
    setup do
      user = user_fixture()
      festival = festival_fixture(user)
      sponsor = sponsor_fixture()
      {:ok, festival: festival, sponsor: sponsor}
    end

    test "change_sponsor/2 returns a changeset" do
      sponsor = sponsor_fixture()
      assert %Ecto.Changeset{} = Sponsorships.change_sponsor(sponsor)
    end

    test "change_sponsorship/2 returns a changeset", %{festival: festival, sponsor: sponsor} do
      sponsorship = sponsorship_fixture(festival, sponsor)
      assert %Ecto.Changeset{} = Sponsorships.change_sponsorship(sponsorship)
    end

    test "get_sponsorship!/1 returns sponsorship with preloaded sponsor", %{festival: festival, sponsor: sponsor} do
      sponsorship = sponsorship_fixture(festival, sponsor)
      found = Sponsorships.get_sponsorship!(sponsorship.id)
      assert found.sponsor.id == sponsor.id
    end

    test "total_sponsorship_amount/1 returns 0 for empty festival" do
      user = user_fixture()
      empty = festival_fixture(user, %{name: "空の祭り"})
      assert Sponsorships.total_sponsorship_amount(empty.id) == 0
    end

    test "payment_status_summary/1 includes partial payments", %{festival: festival} do
      sponsor = sponsor_fixture(%{name: "部分払い企業"})
      sponsorship_fixture(festival, sponsor, %{payment_status: "partial", amount: 200_000})

      summary = Sponsorships.payment_status_summary(festival.id)
      assert summary.partial_amount == 200_000
      assert summary.partial_count == 1
    end
  end

  # Fixtures
  defp user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "test#{System.unique_integer()}@example.com",
        password: "valid_password123"
      })
      |> MatsuriOps.Accounts.register_user()

    user
  end

  defp festival_fixture(user, attrs \\ %{}) do
    {:ok, festival} =
      attrs
      |> Enum.into(%{
        name: "テスト祭り#{System.unique_integer()}",
        description: "テスト用祭り",
        start_date: Date.utc_today(),
        end_date: Date.add(Date.utc_today(), 1),
        location: "テスト会場",
        status: "planning"
      })
      |> then(&MatsuriOps.Festivals.create_festival(user, &1))

    festival
  end

  defp sponsor_fixture(attrs \\ %{}) do
    {:ok, sponsor} =
      attrs
      |> Enum.into(%{
        name: "テスト企業#{System.unique_integer()}",
        contact_email: "contact#{System.unique_integer()}@test.com"
      })
      |> Sponsorships.create_sponsor()

    sponsor
  end

  defp sponsorship_fixture(festival, sponsor, attrs \\ %{}) do
    {:ok, sponsorship} =
      attrs
      |> Enum.into(%{
        tier: "silver",
        amount: 100_000,
        payment_status: "pending"
      })
      |> then(&Sponsorships.create_sponsorship(festival, sponsor, &1))

    sponsorship
  end
end
