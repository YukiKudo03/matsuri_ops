defmodule MatsuriOps.Festivals.FestivalTest do
  use MatsuriOps.DataCase, async: true

  alias MatsuriOps.Festivals.Festival

  describe "changeset/2" do
    test "valid changeset with required fields" do
      changeset = Festival.changeset(%Festival{}, %{
        name: "テスト祭り",
        start_date: ~D[2026-08-15],
        end_date: ~D[2026-08-16]
      })

      assert changeset.valid?
    end

    test "invalid changeset without name" do
      changeset = Festival.changeset(%Festival{}, %{
        start_date: ~D[2026-08-15],
        end_date: ~D[2026-08-16]
      })

      refute changeset.valid?
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset with invalid scale" do
      changeset = Festival.changeset(%Festival{}, %{
        name: "祭り",
        start_date: ~D[2026-08-15],
        end_date: ~D[2026-08-16],
        scale: "huge"
      })

      refute changeset.valid?
      assert %{scale: ["is invalid"]} = errors_on(changeset)
    end

    test "invalid changeset with invalid status" do
      changeset = Festival.changeset(%Festival{}, %{
        name: "祭り",
        start_date: ~D[2026-08-15],
        end_date: ~D[2026-08-16],
        status: "invalid"
      })

      refute changeset.valid?
      assert %{status: ["is invalid"]} = errors_on(changeset)
    end

    test "invalid changeset with end_date before start_date" do
      changeset = Festival.changeset(%Festival{}, %{
        name: "祭り",
        start_date: ~D[2026-08-20],
        end_date: ~D[2026-08-15]
      })

      refute changeset.valid?
      assert %{end_date: ["must be after start date"]} = errors_on(changeset)
    end

    test "valid changeset with same start and end date" do
      changeset = Festival.changeset(%Festival{}, %{
        name: "一日祭り",
        start_date: ~D[2026-08-15],
        end_date: ~D[2026-08-15]
      })

      assert changeset.valid?
    end

    test "valid changeset with all optional fields" do
      changeset = Festival.changeset(%Festival{}, %{
        name: "大祭り",
        description: "年に一度の大祭り",
        scale: "large",
        start_date: ~D[2026-08-15],
        end_date: ~D[2026-08-17],
        venue_name: "中央広場",
        venue_address: "東京都渋谷区",
        expected_visitors: 10000,
        expected_vendors: 50,
        status: "preparation"
      })

      assert changeset.valid?
    end
  end

  describe "scales/0" do
    test "returns all valid scales" do
      scales = Festival.scales()
      assert "small" in scales
      assert "medium" in scales
      assert "large" in scales
    end
  end

  describe "statuses/0" do
    test "returns all valid statuses" do
      statuses = Festival.statuses()
      assert "planning" in statuses
      assert "preparation" in statuses
      assert "active" in statuses
      assert "completed" in statuses
      assert "cancelled" in statuses
    end
  end
end
