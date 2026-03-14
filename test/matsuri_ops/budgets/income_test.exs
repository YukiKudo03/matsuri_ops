defmodule MatsuriOps.Budgets.IncomeTest do
  use MatsuriOps.DataCase, async: true

  alias MatsuriOps.Budgets.Income

  describe "changeset/2" do
    test "valid changeset with required fields" do
      changeset = Income.changeset(%Income{}, %{
        title: "スポンサー収入",
        amount: Decimal.new("100000"),
        festival_id: 1
      })

      assert changeset.valid?
    end

    test "invalid changeset without title" do
      changeset = Income.changeset(%Income{}, %{amount: Decimal.new("100"), festival_id: 1})
      refute changeset.valid?
      assert %{title: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset without amount" do
      changeset = Income.changeset(%Income{}, %{title: "収入", festival_id: 1})
      refute changeset.valid?
      assert %{amount: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset with zero amount" do
      changeset = Income.changeset(%Income{}, %{title: "収入", amount: Decimal.new("0"), festival_id: 1})
      refute changeset.valid?
    end

    test "invalid changeset with negative amount" do
      changeset = Income.changeset(%Income{}, %{title: "収入", amount: Decimal.new("-100"), festival_id: 1})
      refute changeset.valid?
    end

    test "invalid changeset with invalid status" do
      changeset = Income.changeset(%Income{}, %{
        title: "収入",
        amount: Decimal.new("100"),
        festival_id: 1,
        status: "invalid"
      })

      refute changeset.valid?
    end

    test "valid changeset with all fields" do
      changeset = Income.changeset(%Income{}, %{
        title: "チケット売上",
        description: "初日分",
        amount: Decimal.new("500000"),
        source_type: "ticket_sales",
        received_date: ~D[2026-08-15],
        receipt_number: "R-001",
        status: "confirmed",
        notes: "メモ",
        festival_id: 1
      })

      assert changeset.valid?
    end

    test "invalid source_type returns error" do
      changeset = Income.changeset(%Income{}, %{
        title: "収入",
        amount: Decimal.new("100"),
        festival_id: 1,
        source_type: "invalid_type"
      })

      refute changeset.valid?
    end
  end

  describe "statuses/0" do
    test "returns all valid statuses" do
      statuses = Income.statuses()
      assert "expected" in statuses
      assert "confirmed" in statuses
      assert "received" in statuses
      assert "cancelled" in statuses
    end
  end

  describe "source_types/0" do
    test "returns all valid source types" do
      types = Income.source_types()
      assert "sponsorship" in types
      assert "grant" in types
      assert "ticket_sales" in types
      assert "vendor_fees" in types
      assert "donation" in types
      assert "other" in types
    end
  end
end
