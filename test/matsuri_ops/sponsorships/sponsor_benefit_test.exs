defmodule MatsuriOps.Sponsorships.SponsorBenefitTest do
  use MatsuriOps.DataCase, async: true

  alias MatsuriOps.Sponsorships.SponsorBenefit

  describe "changeset/2" do
    test "valid changeset with required fields" do
      changeset = SponsorBenefit.changeset(%SponsorBenefit{}, %{
        name: "ロゴ掲載",
        status: "pending"
      })

      assert changeset.valid?
    end

    test "invalid changeset without name" do
      changeset = SponsorBenefit.changeset(%SponsorBenefit{}, %{status: "pending"})
      refute changeset.valid?
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset with invalid status" do
      changeset = SponsorBenefit.changeset(%SponsorBenefit{}, %{
        name: "特典",
        status: "invalid"
      })

      refute changeset.valid?
      assert %{status: ["is invalid"]} = errors_on(changeset)
    end

    test "valid changeset with all fields" do
      changeset = SponsorBenefit.changeset(%SponsorBenefit{}, %{
        name: "ブース提供",
        description: "メイン会場にブースを提供",
        status: "completed",
        completed_at: DateTime.utc_now()
      })

      assert changeset.valid?
    end
  end

  describe "statuses/0" do
    test "returns all valid statuses" do
      statuses = SponsorBenefit.statuses()
      assert "pending" in statuses
      assert "in_progress" in statuses
      assert "completed" in statuses
      assert "cancelled" in statuses
    end
  end
end
