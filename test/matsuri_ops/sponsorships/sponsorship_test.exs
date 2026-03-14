defmodule MatsuriOps.Sponsorships.SponsorshipTest do
  use MatsuriOps.DataCase, async: true

  alias MatsuriOps.Sponsorships.Sponsorship

  describe "changeset/2" do
    test "valid changeset with required fields" do
      changeset = Sponsorship.changeset(%Sponsorship{}, %{
        tier: "gold",
        amount: 100000
      })

      assert changeset.valid?
    end

    test "invalid changeset without tier" do
      changeset = Sponsorship.changeset(%Sponsorship{}, %{amount: 100000})
      refute changeset.valid?
      assert %{tier: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset without amount" do
      changeset = Sponsorship.changeset(%Sponsorship{}, %{tier: "gold"})
      refute changeset.valid?
      assert %{amount: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset with invalid tier" do
      changeset = Sponsorship.changeset(%Sponsorship{}, %{tier: "diamond", amount: 100000})
      refute changeset.valid?
      assert %{tier: ["is invalid"]} = errors_on(changeset)
    end

    test "invalid changeset with invalid payment_status" do
      changeset = Sponsorship.changeset(%Sponsorship{}, %{
        tier: "gold",
        amount: 100000,
        payment_status: "invalid"
      })

      refute changeset.valid?
    end

    test "invalid changeset with zero amount" do
      changeset = Sponsorship.changeset(%Sponsorship{}, %{tier: "gold", amount: 0})
      refute changeset.valid?
    end

    test "valid changeset with all fields" do
      changeset = Sponsorship.changeset(%Sponsorship{}, %{
        tier: "platinum",
        amount: 500000,
        payment_status: "paid",
        contract_date: ~D[2026-06-01],
        payment_date: ~D[2026-07-01],
        notes: "年間契約"
      })

      assert changeset.valid?
    end
  end

  describe "tiers/0" do
    test "returns all valid tiers" do
      tiers = Sponsorship.tiers()
      assert "platinum" in tiers
      assert "gold" in tiers
      assert "silver" in tiers
      assert "bronze" in tiers
      assert "supporter" in tiers
    end
  end

  describe "payment_statuses/0" do
    test "returns all valid payment statuses" do
      statuses = Sponsorship.payment_statuses()
      assert "pending" in statuses
      assert "partial" in statuses
      assert "paid" in statuses
      assert "cancelled" in statuses
      assert "refunded" in statuses
    end
  end
end
